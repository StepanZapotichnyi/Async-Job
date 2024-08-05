public with sharing class PortfolioCryptoService {
    public static String FIRST_CALL = 'First';
    public static String SECOND_CALL = 'Second';
    public static String THIRD_CALL = 'Third';
    public static String PREFIX = '{"Data":';
    public static String SUFFIX = ' }';
    public static String ERROR = 'Error';



    public static PriceCrypto retrievePortfolioCryptoData() {

    //  string test = 'https://min-api.cryptocompare.com/data/price?tsyms=ANKR,AR,HEGIC,KAS,RNDR,ILV,PUNDIX,SXP,KP3R,XOR,LUNA,RGT,MINE,FRAX,HNT,TLM,NMR,SRM,YFI,BUNNY,NXM,FARM,CUSD,BADGER,BNT,XYO,ALCX,GALA,ALICE,VLX,XEM,STMX,FLUX,MTL,BAND,TRB,ASTR,COIN,STPT,CTXC,DUSK,DFI,SDAO,DENT,BLZ,TROY,NUM,STPT,ALGO';
        // HttpCallouts.HttpResponseWrapper responseFirstOfPart = HttpCallouts.executeHttpRequest(test);
        // HttpCallouts.HttpResponseWrapper responseSecondOfPart = HttpCallouts.executeHttpRequest(test);
        ///for() 
        HttpCallouts.HttpResponseWrapper responseFirstOfPart = HttpCallouts.executeHttpRequest(UtilityToPortfolio.getCryptoEndpoint(FIRST_CALL));
        HttpCallouts.HttpResponseWrapper responseSecondOfPart = HttpCallouts.executeHttpRequest(UtilityToPortfolio.getCryptoEndpoint(SECOND_CALL));
        HttpCallouts.HttpResponseWrapper responseThirdOfPart = HttpCallouts.executeHttpRequest(UtilityToPortfolio.getCryptoEndpoint(THIRD_CALL));
        System.debug(responseFirstOfPart);

        PriceCrypto response;
            if(isResponseValid(responseFirstOfPart) && isResponseValid(responseSecondOfPart) && isResponseValid(responseThirdOfPart)){
                List<String>  responsBodies = new List<String>();
                  responsBodies.add(responseFirstOfPart.responseBody);
                  responsBodies.add(responseSecondOfPart.responseBody);
                  responsBodies.add(responseThirdOfPart.responseBody);
                System.debug( 'ss' +responsBodies);
                response = deserializeAllResponses(responsBodies);
            }
            
         return response;
    }

    public static Boolean isResponseValid(HttpCallouts.HttpResponseWrapper response){
        return response.statusCode >= 200 && response.statusCode < 300;
    }   

    public static PriceCrypto deserializeAllResponses(List<String> responseBodies){
        PriceCrypto  combinedResponses = new PriceCrypto();

        List<PriceCrypto> deserializedResponses =   deserializeResponse(responseBodies);

        for(PriceCrypto response : deserializedResponses){

            if((response?.Response?.contains(ERROR) == true)) {
                System.debug('else++' + response);
                return response;
            }
        }
        
        combinedResponses.mergeData(deserializedResponses); 
        
        return combinedResponses;
    }

    public static List<PriceCrypto> deserializeResponse(List<String> bodies) {
        List<PriceCrypto> priceCrypto = new List<PriceCrypto>();
     
        for(String body : bodies){
            if (body.contains('Error')) {
                priceCrypto.add((PriceCrypto) JSON.deserialize(body, PriceCrypto.class));
            } else {
                String formattedBody = PREFIX + body + SUFFIX;
                priceCrypto.add((PriceCrypto) JSON.deserialize(formattedBody, PriceCrypto.class));
            }
        }
        return priceCrypto;
    }

}