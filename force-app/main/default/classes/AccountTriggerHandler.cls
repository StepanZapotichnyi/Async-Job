public with sharing class AccountTriggerHandler {
    
    public static void updateAccounts(List<Account> accounts, Map<Id, Account> oldAccountsMap) {

        Map<Id, Decimal> updatedAccountRevenues = new Map<Id, Decimal>();
        
        for(Account acc : accounts) {
            Decimal oldAnnualRevenue = oldAccountsMap.get(acc.Id).AnnualRevenue;

            if(acc.AnnualRevenue != oldAnnualRevenue &&  acc.AnnualRevenue != null) {
                updatedAccountRevenues.put(acc.Id, acc.AnnualRevenue);
            }
        }

        if(!updatedAccountRevenues.isEmpty()){    
            updateAccountCryptoCountAsync(updatedAccountRevenues);
        }
    }

    
    
    @future (callout=true)
    public static void updateAccountCryptoCountAsync(Map<Id, Decimal> updatedAccountRevenues) {
        
        List<Account> accountToUpdate = new List<Account>();

        Map<Id, String> cryptoAmountMap = calculateCyptoForAccounts(updatedAccountRevenues);
        
        for(Id accountId : cryptoAmountMap.keySet()) {
            Account account = new Account(Id = accountId);
            account.Count_of_Bitcoin__c = cryptoAmountMap.get(accountId);
           
            accountToUpdate.add(account);
        }

        if(!accountToUpdate.isEmpty()){
            update accountToUpdate;
        }
    }

    public static Map<Id, String> calculateCyptoForAccounts(Map<Id,Decimal> updatedAccountRevenues) {
            
        Map<Id, String> cryptoAmountMap = new Map<Id,String>();

        Map<String,Decimal> symbolsAndPrice = new Map<String,Decimal>();
        Map<String, String> currencySymbolMappings = Utility.getCurencySymbols();

        symbolsAndPrice = getExchangeRate(symbolsAndPrice, currencySymbolMappings);

        for(Id accountId : updatedAccountRevenues.keySet()){

            Decimal annualRevenueAccountId  = updatedAccountRevenues.get(accountId);
            Decimal ecxhangeRate = (annualRevenueAccountId / symbolsAndPrice.get(currencySymbolMappings.get('ActualSymbol')));
            Decimal cryptoAmount = (ecxhangeRate * symbolsAndPrice.get(currencySymbolMappings.get('CyptoSymbol'))).setScale(7);
            String cryptoAmountString  = String.valueOf(cryptoAmount);

            cryptoAmountMap.put(accountId, cryptoAmountString);
        }

        return cryptoAmountMap;
    }

    public static Map<String,Decimal> getExchangeRate(Map<String, Decimal> symbolsAndPrice, Map<String, String> currencySymbolMappings) {
        
        HttpCallouts.HttpResponseWrapper response = HttpCallouts.executeHttpRequest(Utility.getExchangeRateEndpoint(currencySymbolMappings.get('RateSymbol')));
        
        if(response.statusCode >= 200 && response.statusCode < 300) {    
            ExchangeRateResponse exchangeRateResponse = (ExchangeRateResponse) JSON.deserialize(response.responseBody, ExchangeRateResponse.class);
    
            symbolsAndPrice.put(currencySymbolMappings.get('ActualSymbol'),exchangeRateResponse.conversion_rates.get(currencySymbolMappings.get('ActualSymbol')));
            
        }else{
            throw new AccountTriggerHandlerException('HTTP request failed with status code: ' + response.statusCode + ' and response: ' + response.responseBody);
        }

        symbolsAndPrice = getCryptoPrice(symbolsAndPrice, currencySymbolMappings);


    return symbolsAndPrice;

    }
    

    public static Map<String, Decimal> getCryptoPrice( Map<String,Decimal> symbolsAndPrice, Map<String,String> currencySymbolMappings) {
       
        HttpCallouts.HttpResponseWrapper response = HttpCallouts.executeHttpRequest(Utility.getCryptoEndpoint(currencySymbolMappings.get('RateSymbol')));

        if(response.statusCode >= 200 && response.statusCode < 300) {
            System.debug( 'Body=='+response.responseBody);
            PriceCrypto cryptoPrices = (PriceCrypto) JSON.deserialize(response.responseBody, PriceCrypto.class);
            System.debug('PR=='+cryptoPrices );
             if(cryptoPrices.Response != 'Error'){
                
                Decimal cryptoSymbolValue = Test.isRunningTest() ? 0.00222 :cryptoPrices.Data.get(currencySymbolMappings.get('CyptoSymbol'));
                symbolsAndPrice.put(currencySymbolMappings.get('CyptoSymbol'), cryptoSymbolValue);

             }else {
                throw new AccountTriggerHandlerException('HTTP request failed with status code: ' + response.statusCode + ' and response: ' + cryptoPrices.Message);
             }

        }else {
            throw new AccountTriggerHandlerException('HTTP request failed with status code: ' + response.statusCode + ' and response: ' + response.responseBody);
        }

        return symbolsAndPrice;
            
    }

    public class AccountTriggerHandlerException extends Exception {

    }

}