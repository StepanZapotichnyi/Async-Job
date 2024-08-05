public class PriceCrypto {

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
    public  Map<String, Price> Data = new Map<String,PriceCrypto.Price>(); // Changed Data to a Map<String, Object>
    public String ParamWithError;

    public static PriceCrypto parse(String json) {
        return (PriceCrypto) System.JSON.deserialize(json, PriceCrypto.class);
    }


    public void mergeData(List<PriceCrypto> others) {
       
        for(PriceCrypto other : others){
        
            if (other == null) return;
            
            for (String key : other.Data.keySet()) {
                this.Data.put(key, other.Data.get(key));
            }

        } 
    }

   
}