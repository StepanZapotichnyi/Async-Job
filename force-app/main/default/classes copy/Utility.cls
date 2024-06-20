public with sharing class Utility {
    public static String CONFIG = 'Config';
    public static final String DATA_PATH =  'data/';
    public static final String PRICE = 'price?';


    public static Async_Apex_Job__mdt getAsyncApexJob(String config) {
        Async_Apex_Job__mdt result = Async_Apex_Job__mdt.getInstance(config);
        return result;
    }

    
    public static String getEndpoinCrypto(String currencySymbol, String listCrypto) {

        Async_Apex_Job__mdt result = getAsyncApexJob(CONFIG);
        String keyFsym =  'fsym=' + currencySymbol;  
        String keytsyms = '&tsyms=' + listCrypto;

        String endpointUrl = result.EndpointUrlForCrypto__c + DATA_PATH + PRICE+ keyFsym + keytsyms;
        return endpointUrl;
    //String endpointUrl = 'https://min-api.cryptocompare.com/';
   
    // String data =  'data/';
    // String price = 'price?';
    }

      
}