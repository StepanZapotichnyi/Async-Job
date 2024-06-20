public with sharing class AccountTriggerHandler {

    public static void updateAccount(List<Account> accounts, Map<Id, Account> oldAccounts) {

        Map<Id, Decimal> accountIdsAndAnnualRevenue= new Map<Id, Decimal>();

        for(Account acc : accounts) {
            Decimal oldAnnualRevenue = oldAccounts.get(acc.Id).AnnualRevenue;
            if(acc.AnnualRevenue != oldAnnualRevenue &&  acc.AnnualRevenue != null) {
                accountIdsAndAnnualRevenue.put(acc.Id, acc.AnnualRevenue);
            } 
        }
        if(!accountIdsAndAnnualRevenue.isEmpty()){
            updateAccountBitcoinCountAsync(accountIdsAndAnnualRevenue);
        }
    }

    
    @future (callout=true)
    public static void updateAccountBitcoinCountAsync(Map<Id, Decimal> accountIdsAndAnnualRevenue) {

        Decimal currencyBitcoin = countBitcoin();
        
        List<Account> accountToUpdate = new List<Account>();
        
        for(Id accountId : accountIdsAndAnnualRevenue.keySet()) {
          
            Decimal usdFromCzk  = countUsd(accountIdsAndAnnualRevenue.get(accountId));
          
            Account account = new Account(Id = accountId);
            account.Count_of_Bitcoin__c = countBitcoinForAccount(usdFromCzk, currencyBitcoin);
            accountToUpdate.add(account);
        }
        
        if(!accountToUpdate.isEmpty()){
            update accountToUpdate;
        }
    }
    

    public static Decimal countBitcoin() {
        Decimal currencyBitcoin;
        String currencySymbol = 'USD'; 
        String listCripto = 'BTC,ETH,ADA,W,XRP,SHI,NOT,TON,BNB,MATIC,APT,SOL,PEPE,WIF,PEOPLE,SHIB,AVAX,TRX,DOT,NEAR,UNI,LINK,KAS,RNDR';
        
        HttpCallouts.HttpResponseWrapper responseBitcoin = HttpCallouts.executeHttpRequest(Utility.getEndpoinCrypto(currencySymbol, listCripto));

        
        System.debug(responseBitcoin);

        //String currencySymbol = "USD";  

        // String endpointUrl = "https://min-api.cryptocompare.com/";  
        // String dataPath = "data/";  
        // String priceQuery = "price?";  

        // String keyFsym = "fsym=" + currencySymbol;  
        // String cryptoList = "BTC,ETH,ADA,W,XRP,SHI,NOT,TON,BNB,MATIC,APT,SOL,PEPE,WIF,PEOPLE,SHIB,AVAX,TRX,DOT,NEAR,UNI,LINK,KAS,RNDR"; 
        // String keyTsyms = "&tsyms=" + cryptoList;  

        // String fullUrl = endpointUrl + dataPath + priceQuery + keyFsym + keyTsyms;

        
        // if(responseBitcoin.statusCode >= 200 && responseBitcoin.statusCode < 300) {
        //     Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBitcoin.responseBody);
        //     currencyBitcoin = (Decimal)resultMap.get('USD');
            
        // }
        return currencyBitcoin;
    }

    public static Decimal countUsd(Decimal sumCzk) {
       
        // HttpCallouts.HttpResponseWrapper responseUsd = HttpCallouts.executeHttpRequest();
        Decimal currencyUsd = 22.35;
        // if(responseUsd.statusCode == 200 && responseUsd.statusCode < 300) {
        //     Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBitcoin.responseBody);
        //     currencyUsd = (Decimal)resultMap.get('CZK') ;
        // }

        return sumCzk / currencyUsd;
    }

    public static String countBitcoinForAccount(Decimal usdFromCzk, Decimal currencyBitcoin) {

        Decimal sumBitcoin = (usdFromCzk / currencyBitcoin).setScale(7);
        return  sumBitcoin.toPlainString();
    }
}

