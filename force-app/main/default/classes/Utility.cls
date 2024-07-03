public with sharing class Utility {
    public static String CONFIG = 'Config';
    public static final String DATA_PATH =  'data/';
    public static final String PRICE = 'price?';
    public static final String LATEST = 'latest/';
    
    
    
    public static Async_Apex_Job__mdt getAsyncApexJob(String config) {
        Async_Apex_Job__mdt result = Async_Apex_Job__mdt.getInstance(config);
        return result;
    }
        
        
    public static Map<String, String> getCurencySymbols() {
        
        Async_Apex_Job__mdt result = getAsyncApexJob(CONFIG);

        String exchangeRateSymbol = Test.isRunningTest() ? 'USD' : result.ExchangeRateSymbol__c;
        String cryptoSymbol = Test.isRunningTest() ? 'BTC' : result.CryptoSymbol__c;
        String actualSymbol = Test.isRunningTest() ? 'CZK' : result.ActualSymbol__c;
        
        Map<String, String> currencySymbolMappings = new Map<String,String>{
            'RateSymbol'  => exchangeRateSymbol ,
            'CyptoSymbol'   => cryptoSymbol,
            'ActualSymbol' => actualSymbol
        };

        return currencySymbolMappings;
    }

    public static String getCryptoEndpoint(String currencySymbol) {

        Async_Apex_Job__mdt result = getAsyncApexJob(CONFIG);

        String listCrypto = Test.isRunningTest() ? 'BTC,TON,W,XRP' : result.List_of_crypto_currencies__c.replace(' ', '');
        String keyFsym =  'fsym=' + currencySymbol;  
        String keyTsyms = '&tsyms=' + listCrypto;

        String endpointUrlToBitcoin = result.EndpointUrlForCrypto__c + DATA_PATH + PRICE+ keyFsym + keyTsyms;
        return endpointUrlToBitcoin;
    }

    public static String getExchangeRateEndpoint(String currencySymbol){
        Async_Apex_Job__mdt result = getAsyncApexJob(CONFIG);

        String endpointUrlToUsd = result.EndpointUrlForUSD__c + result.API_KEY__c  + LATEST + currencySymbol;
        return endpointUrlToUsd;
    }



      
}