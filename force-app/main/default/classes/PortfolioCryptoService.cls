public with sharing class PortfolioCryptoService {
    public static String PREFIX = '{"Data":';
    public static String SUFFIX = ' }';
    public static String ERROR = 'Error';

    public static Map<String, CryptoData.Price>  retrievePortfolioCryptoData() {

        List<String> containerCryptoSymbols = UtilityToPortfolio.getContainerCryptoSymbols();
        List<String> responseBodies = new List<String>();
        Map<String, CryptoData.Price> cryptoNameToPrice; 

        for(String st : containerCryptoSymbols) {
            String endpoint = UtilityToPortfolio.getCryptoEndpoint(st);
            HttpCallouts.HttpResponseWrapper response = HttpCallouts.executeHttpRequest(endpoint);
            if(isResponseValid(response)){
                responseBodies.add(response.responseBody); 
            }
        }
        if(!responseBodies.isEmpty()){
            cryptoNameToPrice = combineCryptoResponses(responseBodies); 
        }else{
            throw new PortfolioCryptoServiceException('Error retrieving crypto data.');
        }

            
        return cryptoNameToPrice;
    }

    public static Boolean isResponseValid(HttpCallouts.HttpResponseWrapper response){
        return response.statusCode >= 200 && response.statusCode < 300;
    }   

    public static  Map<String, CryptoData.Price> combineCryptoResponses(List<String> responseBodies){

        List<CryptoData> deserializedResponses = deserializeResponse(responseBodies);

        for(CryptoData response : deserializedResponses){
            if(response?.Response?.contains(ERROR) == true) {
                throw new PortfolioCryptoServiceException(response.Message);
        
            }
        }
        
        Map<String, CryptoData.Price> combinedResponses = mergeCryptoData(deserializedResponses); 
        
        return combinedResponses;
    }


    public static List<CryptoData> deserializeResponse(List<String> bodies) {
        List<CryptoData> cryptoData = new List<CryptoData>();
        for(String body : bodies){
            if (body.contains(ERROR)) {
                CryptoData.add((CryptoData) JSON.deserialize(body, CryptoData.class));
            } else {
                String formattedBody = PREFIX + body + SUFFIX;
                CryptoData.add((CryptoData) JSON.deserialize(formattedBody, CryptoData.class));
            }
        }
        return CryptoData;
    }


    public static Map<String, CryptoData.Price> mergeCryptoData(List<CryptoData> deserializedCryptoData) { 
       
        Map<String, CryptoData.Price> data = new Map<String,  CryptoData.Price>(); 

        for(CryptoData cryptoData : deserializedCryptoData){

            for (String key : cryptoData.Data.keySet()) {
                data.put(key, cryptoData.Data.get(key));
            }
        }
        return data; 
    }

    public class PortfolioCryptoServiceException extends Exception {
            
    }

}