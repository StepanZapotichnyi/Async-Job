
// public class ExchangeRateResponse {
	
// 	public String result {get;set;} 
// 	public String documentation {get;set;} 
// 	public String terms_of_use {get;set;} 
// 	public Integer time_last_update_unix {get;set;} 
// 	public String time_last_update_utc {get;set;} 
// 	public Integer time_next_update_unix {get;set;} 
// 	public String time_next_update_utc {get;set;} 
// 	public String base_code {get;set;} 
// 	public Map<String, Decimal> conversion_rates {get;set;} 


// 	public ExchangeRateResponse(JSONParser parser) {
// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
// 				String text = parser.getText();
// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
// 					if (text == 'result') {
// 						result = parser.getText();
// 					} else if (text == 'documentation') {
// 						documentation = parser.getText();
// 					} else if (text == 'terms_of_use') {
// 						terms_of_use = parser.getText();
// 					} else if (text == 'time_last_update_unix') {
// 						time_last_update_unix = parser.getIntegerValue();
// 					} else if (text == 'time_last_update_utc') {
// 						time_last_update_utc = parser.getText();
// 					} else if (text == 'time_next_update_unix') {
// 						time_next_update_unix = parser.getIntegerValue();
// 					} else if (text == 'time_next_update_utc') {
// 						time_next_update_utc = parser.getText();
// 					} else if (text == 'base_code') {
// 						base_code = parser.getText();
// 					} else if (text == 'conversion_rates') {
// 						conversion_rates = new Map<String, Decimal>();
// 						while (parser.nextToken() != System.JSONToken.END_OBJECT) {
// 							if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
// 								String textR = parser.getText();
// 								if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
// 									conversion_rates.put(textR, parser.getDoubleValue());
// 								}
// 							}
// 						}
// 					} else {
// 						System.debug(LoggingLevel.WARN, 'ExchangeRateResponse consuming unrecognized property: '+text);
// 						consumeObject(parser);
// 					}
// 				}
// 			}
// 		}
// 	}
	
// 	public static ExchangeRateResponse parse(String json) {
// 		System.JSONParser parser = System.JSON.createParser(json);
// 		return new ExchangeRateResponse(parser);
// 	}
	
// 	public static void consumeObject(System.JSONParser parser) {
// 		Decimal depth = 0;
// 		do {
// 			System.JSONToken curr = parser.getCurrentToken();
// 			if (curr == System.JSONToken.START_OBJECT || 
// 				curr == System.JSONToken.START_ARRAY) {
// 				depth++;
// 			} else if (curr == System.JSONToken.END_OBJECT ||
// 				curr == System.JSONToken.END_ARRAY) {
// 				depth--;
// 			}
// 		} while (depth > 0 && parser.nextToken() != null);
// 	}
	
// }

public class ExchangeRateResponse {
    public String result {get;set;}
    public String documentation {get;set;}
    public String terms_of_use {get;set;}
    public Integer time_last_update_unix {get;set;}
    public String time_last_update_utc {get;set;}
    public Integer time_next_update_unix {get;set;}
    public String time_next_update_utc {get;set;}
    public String base_code {get;set;}
    public Map<String, Decimal> conversion_rates {get;set;}

    public ExchangeRateResponse(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'result') {
                        result = parser.getText();
                     } else if (text == 'documentation') {
                        documentation = parser.getText();
                    } else if (text == 'terms_of_use') {
                        terms_of_use = parser.getText();
                    } else if (text == 'time_last_update_unix') {
                        time_last_update_unix = parser.getIntegerValue();
                    } else if (text == 'time_last_update_utc') {
                        time_last_update_utc = parser.getText();
                    } else if (text == 'time_next_update_unix') {
                        time_next_update_unix = parser.getIntegerValue();
                    } else if (text == 'time_next_update_utc') {
                        time_next_update_utc = parser.getText();
                    } else if (text == 'base_code') {
                        base_code = parser.getText();
                    } else if (text == 'conversion_rates') {
                        conversion_rates = new Map<String, Decimal>();
                        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                                String textR = parser.getText();
                                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                                    conversion_rates.put(textR, parser.getDecimalValue());
                                }
                            }
                        }
                    } else {
                        System.debug(LoggingLevel.WARN, 'ExchangeRateResponse consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public static ExchangeRateResponse parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ExchangeRateResponse(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}

