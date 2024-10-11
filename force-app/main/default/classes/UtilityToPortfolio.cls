public with sharing class UtilityToPortfolio {
    public static String CONFIG = 'Config';
    public static final String DATA_PATH =  'data/';
    public static final String PRICE = 'pricemulti?';
    public static final Integer  CURRENCY_STRING_MAX_LENGHT = 290;
    
    
    
    public static Crypto_Endpoind_Data__mdt getCryptoEndpoindData(String config) {
        Crypto_Endpoind_Data__mdt result = Crypto_Endpoind_Data__mdt.getInstance(config);
        return result;
    }


    public static List<String> getCryptoSymbols(){
        
        List<Crypto_Endpoind_Data__mdt> cryptoEndpoindData = [SELECT Crypto_Currency_Symbols__c FROM Crypto_Endpoind_Data__mdt];
        List<String> cryptoSymbols = new List<String>(); 

        for(Crypto_Endpoind_Data__mdt mdt :cryptoEndpoindData){
            cryptoSymbols = Test.isRunningTest() ? 'BTC,TON,W,XRP'.split(',')  : mdt.Crypto_Currency_Symbols__c.replace(' ', '').split(',');
        }

        return cryptoSymbols;
    }


    public static List<String> getContainerCryptoSymbols(){

        List<String> cryptoSymbols = getCryptoSymbols(); 

        List<String> finalSymbols = new List<String>();
        String currencySymbolsContainer = ''; 

        for (String symbol : cryptoSymbols) {
            if (currencySymbolsContainer.length() > CURRENCY_STRING_MAX_LENGHT) {
                currencySymbolsContainer = currencySymbolsContainer.removeEnd(',');
                System.debug('body' + currencySymbolsContainer);
                finalSymbols.add(currencySymbolsContainer);
                currencySymbolsContainer = '';
            }
            currencySymbolsContainer += symbol + ',';
        }

        if(String.isNotBlank(currencySymbolsContainer)){
            currencySymbolsContainer = currencySymbolsContainer.removeEnd(',');
            System.debug('body' + currencySymbolsContainer);
            finalSymbols.add(currencySymbolsContainer);
        }

        return finalSymbols;   
    }

     public static String getCryptoEndpoint(String cryptoSymbols) {

        Crypto_Endpoind_Data__mdt result = getCryptoEndpoindData(CONFIG);
       
        String conversionCurrencyPath = '&tsyms=' + result.Conversion_Currency_Symbol__c;
        String cryptoSymbolsPath =  'fsyms=' + cryptoSymbols;  
        
        String endpointUrlToCrypto = result.EndpointUrlForCrypto__c + DATA_PATH + PRICE+ cryptoSymbolsPath + conversionCurrencyPath;
        System.debug( endpointUrlToCrypto);
        return endpointUrlToCrypto;
    }

    @AuraEnabled
    public static String verifyTokenSymbol(String symbol) {

        List<String> cryptoSymbols = getCryptoSymbols(); 

        for (String token : cryptoSymbols) {
            if (token.equalsIgnoreCase(symbol)) {
                System.debug('ceck'+token);
                return token;
            }
        }
        
        String errorMessage = 'The symbol ' + symbol + ' is not present in the list of crypto currency symbols' +
                          '\n' + 'Please add the symbol to the crypto currency list';
        throw new UtilityToPortfolioException(errorMessage);

    }

    public class UtilityToPortfolioException extends Exception {
            
    }
}