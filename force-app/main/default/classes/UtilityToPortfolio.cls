public with sharing class UtilityToPortfolio {
    public static String CONFIG = 'Config';
    public static final String DATA_PATH =  'data/';
    public static final String PRICE = 'pricemulti?';
    
    
    
    public static Crypto_Endpoind_Data__mdt getCryptoEndpoindData(String config) {
        Crypto_Endpoind_Data__mdt result = Crypto_Endpoind_Data__mdt.getInstance(config);
        return result;
    }

    public static String getCryptoEndpoint(String numberOfLsit) {


        Crypto_Endpoind_Data__mdt result = getCryptoEndpoindData(CONFIG);
        String cryptoSymbols;
        if(numberOfLsit == 'First'){
            cryptoSymbols = Test.isRunningTest() ? 'BTC,TON,W,XRP' : result.First_List_Of_Crypto_Symbols__c.replace(' ', '');
        }else if(numberOfLsit == 'Second'){
            cryptoSymbols = Test.isRunningTest() ? 'BTC,TON,W,XRP' : result.Second_List_Of_Crypto_Symbols__c.replace(' ', '');
        }else if(numberOfLsit == 'Third'){
            cryptoSymbols = Test.isRunningTest() ? 'BTC,TON,W,XRP' : result.Third_List_Of_Crypto_Symbols__c.replace(' ', '');
        }
        String keyTsyms = '&tsyms=' + result.Currency_Symbol__c;
        String keyFsym =  'fsyms=' + cryptoSymbols;  
        
        String endpointUrlToCrypto = result.EndpointUrlForCrypto__c + DATA_PATH + PRICE+ keyFsym + keyTsyms;
        System.debug( endpointUrlToCrypto);
        return endpointUrlToCrypto;
    }

    @AuraEnabled
    public static String checkTokenPresenceSymbol(String symbol) {

        Crypto_Endpoind_Data__mdt result = getCryptoEndpoindData(CONFIG);

        List<String> cryptoSymbols = new List<String>();
        if (Test.isRunningTest()) {
            cryptoSymbols.addAll('BTC,TON,W,XRP'.split(','));
        } else {
            cryptoSymbols.addAll(result.First_List_Of_Crypto_Symbols__c.replace(' ', '').split(','));
            cryptoSymbols.addAll(result.Second_List_Of_Crypto_Symbols__c.replace(' ', '').split(','));
            cryptoSymbols.addAll(result.Third_List_Of_Crypto_Symbols__c.replace(' ', '').split(','));
           
        }

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
//https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,BNB,XRP,ADA,MATIC,SOL,AVAX,DOT,DOGE,SHIB,TRX,LINK,UNI,LTC,XLM,ETC,DAI,USDT,USDC,WBTC,LUNC,ATOM,KSM,FTM,EGLD,HBAR,XTZ,ICP,NEAR,QNT,ONE,GRT,CELO,SUSHI,AAVE,MKR,COMP,ZEC,IOT,ENJ,AUDIO,CRV,MANA,SAND,CHZ,BAT,CAKE,RUNE,RVN,ZIL,KAVA,SNX,REN,OCEAN
// &tsyms=USD