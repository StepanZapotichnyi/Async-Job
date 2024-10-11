public class CryptoData {

    public class RateLimit {
    }

    public class Price{
        public Decimal USD;
    }

    public String Response;
    public String Message;
    public Boolean HasWarning;
    public Integer Type;
    public RateLimit RateLimit;
    public  Map<String, Price> Data = new Map<String,CryptoData.Price>(); 
    public String ParamWithError;

    public static CryptoData parse(String json) {
        return (CryptoData) System.JSON.deserialize(json, CryptoData.class);
    }
   
}