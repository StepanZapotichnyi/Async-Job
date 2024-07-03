@isTest
public class PriceCryptoTest {
    @isTest
    static void testParseToMap() {
        String json = '{' +
            '    "Response": "Success",' +
            '    "Message": "Data Retrieved Successfully",' +
            '    "HasWarning": false,' +
            '    "Type": 100,' +
            '    "RateLimit": {},' +
            '    "Data": {' +
            '        "BTC": 0.00001536,' +
            '        "ETH": 0.0002829,' +
            '        "ADA": 2.594,' +
            '        "W": 2.721,' +
            '        "XRP": 2.027,' +
            '        "NOT": 65.41,' +
            '        "TON": 0.8675,' +
            '        "BNB": 0.001678,' +
            '        "MATIC": 1.75,' +
            '        "APT": 0.1447,' +
            '        "SOL": 0.007268,' +
            '        "PEPE": 88590.41,' +
            '        "WIF": 0.4898,' +
            '        "PEOPLE": 11.78,' +
            '        "SHIB": 54727.94,' +
            '        "AVAX": 0.03678,' +
            '        "TRX": 8.574,' +
            '        "DOT": 0.1696,' +
            '        "NEAR": 0.2001,' +
            '        "UNI": 0.09941,' +
            '        "LINK": 0.07017,' +
            '        "KAS": 6.952' +
            '    }' +
            '}';

        Map<String, Decimal> cryptoPrices = PriceCrypto.parseToMap(json);
        System.debug('cryptoPrices: ' + cryptoPrices);

        // Assertions to verify the parsed values
        System.assertEquals(0.00001536, cryptoPrices.get('BTC'));
        System.assertEquals(0.0002829, cryptoPrices.get('ETH'));
        System.assertEquals(2.594, cryptoPrices.get('ADA'));
    }
}


// @IsTest
// public class JSON2Apex_Test {
	
// 	static testMethod void testParse() {
// 		String json = '{'+
// 		'    \"Response\": \"Error\",'+
// 		'    \"Message\": \"tsyms param is empty or null.\",'+
// 		'    \"HasWarning\": false,'+
// 		'    \"Type\": 2,'+
// 		'    \"RateLimit\": {},'+
// 		'    \"Data\": {},'+
// 		'    \"ParamWithError\": \"tsyms\"'+
// 		'}'+
// 		'{'+
// 		'    \"BTC\": 0.00001536,'+
// 		'    \"ETH\": 0.0002829,'+
// 		'    \"ADA\": 2.594,'+
// 		'    \"W\": 2.721,'+
// 		'    \"XRP\": 2.027,'+
// 		'    \"NOT\": 65.41,'+
// 		'    \"TON\": 0.8675,'+
// 		'    \"BNB\": 0.001678,'+
// 		'    \"MATIC\": 1.75,'+
// 		'    \"APT\": 0.1447,'+
// 		'    \"SOL\": 0.007268,'+
// 		'    \"PEPE\": 88590.41,'+
// 		'    \"WIF\": 0.4898,'+
// 		'    \"PEOPLE\": 11.78,'+
// 		'    \"SHIB\": 54727.94,'+
// 		'    \"AVAX\": 0.03678,'+
// 		'    \"TRX\": 8.574,'+
// 		'    \"DOT\": 0.1696,'+
// 		'    \"NEAR\": 0.2001,'+
// 		'    \"UNI\": 0.09941,'+
// 		'    \"LINK\": 0.07017,'+
// 		'    \"KAS\": 6.952'+
// 		'}';
// 		JSON2Apex obj = JSON2Apex.parse(json);
// 		System.assert(obj != null);
// 	}
// }