// public class PriceCrypto {

//     public Map<String, Decimal> priceCrypto { get; set; }

//     public PriceCrypto(JSONParser parser) {
//         priceCrypto = new Map<String, Decimal>();
//         while (parser.nextToken() != System.JSONToken.END_OBJECT) {
//             if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
//                 String fieldName = parser.getText();
//                 if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
//                     Decimal value = parser.getDecimalValue();
//                     priceCrypto.put(fieldName, value);
//                 }
//             }
//         }
//     }

//     public static Map<String, Decimal> getCryptoPrices(String responseBody) {
//         if (Test.isRunningTest()) {
//             return new Map<String, Decimal>{ 'BTC' => 0.0002222 };
//         } else {
//             return parseToMap(responseBody);
//         }
//     } 
    
//     public static Map<String, Decimal> parseToMap(String json) {
//         PriceCrypto priceCryptoInstance = parse(json);
//         return priceCryptoInstance.priceCrypto;
//     }

//     public static PriceCrypto parse(String json) {
//         System.JSONParser parser = System.JSON.createParser(json);
//         return new PriceCrypto(parser);
//     }
// }


public class PriceCrypto {
    // public Map<String, Decimal> priceCrypto { get; set; }
    
    public class RateLimit {
    }

    public String Response;
    public String Message;
    public Boolean HasWarning;
    public Integer Type;
    public RateLimit RateLimit;
    public Map<String, Decimal> Data;
    public String ParamWithError;

    public static PriceCrypto parse(String json) {
        return (PriceCrypto) System.JSON.deserialize(json, PriceCrypto.class);
    }

    // public static Map<String, Decimal> parseToMap(String json) {
    //     PriceCrypto priceCryptoInstance = parse(json);
    //     return priceCryptoInstance.Data;
    // }
}
