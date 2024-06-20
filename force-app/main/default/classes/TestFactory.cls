public with sharing class TestFactory {
    
    public static List<Account> createAccount(Integer amountAccounts) {
        List<Account>  testAccount = new List<Account>();
        for(Integer i = 0; i < amountAccounts; i++) {
            Account account = new Account();
            account.Name = 'TestAccount' + i;
            account.AnnualRevenue = 66600;
            account.Count_of_Bitcoin__c = '0.555';
            account.AccountNumber = 'TestAccountNumber' + i;
            account.AccountNumber = 'TestAccountNumber' + i;
            account.BillingState = 'CA';
            testAccount.add(account);
        }
        return testAccount; 
    }

    public static List<Contact> createContactToAccount(List<Account> accountIds, Integer amountContacts) {
       
        List<Contact>  testContacts = new List<Contact>();

        for(Account account : accountIds) {
          for(Integer i = 0; i < amountContacts; i++){
              Contact contact = new Contact();
              contact.LastName = 'Test Contact';
              contact.FirstName = 'Test Contact';
              contact.Last_Update__c = Datetime.newInstance(1960, 2, 19);
              contact.AccountId = account.Id;
                testContacts.add(contact);
            }
        }

        return testContacts; 
    }

    public static List<String> createTestCrone(Integer minuteInterval) {
        List<String> crones = new List<String>();
            
        if(minuteInterval != 0 && minuteInterval <= 60)  {
            for (Integer i = 0; i < 60; i += minuteInterval) {
                String crone = '0 '+ i +' * * * ?';
                crones.add(crone);
            }
        }else {
            String crone = '0 0 * * * ?';
            crones.add(crone);
        }
        System.debug(crones);
        return crones;
    }

    public static String geMockString() {
        String mockString = '{'+
		'    \"result\": \"success\",'+
		'    \"documentation\": \"https://www.exchangerate-api.com/docs\",'+
		'    \"terms_of_use\": \"https://www.exchangerate-api.com/terms\",'+
		'    \"time_last_update_unix\": 1718150401,'+
		'    \"time_last_update_utc\": \"Wed, 12 Jun 2024 00:00:01 +0000\",'+
		'    \"time_next_update_unix\": 1718236801,'+
		'    \"time_next_update_utc\": \"Thu, 13 Jun 2024 00:00:01 +0000\",'+
		'    \"base_code\": \"USD\",'+
		'    \"conversion_rates\": {'+
		'        \"USD\": 1,'+
		'        \"AED\": 3.6725,'+
		'        \"AFN\": 70.5397,'+
		'        \"KMF\": 458.1632,'+
		'        \"KRW\": 1377.3991,'+
		'        \"KWD\": 0.3068,'+
		'        \"KYD\": 0.8333,'+
		'        \"KZT\": 450.7831,'+
		'        \"LAK\": 21766.2930,'+
		'        \"LBP\": 89500.0000,'+
		'        \"LKR\": 303.0583,'+
		'        \"LRD\": 194.7738,'+
		'        \"LSL\": 18.5850,'+
		'        \"LYD\": 4.8688,'+
		'        \"MAD\": 9.9548,'+
		'        \"MDL\": 17.6660,'+
		'        \"MGA\": 4446.9574,'+
		'        \"MKD\": 57.2397,'+
		'        \"MMK\": 2101.2519,'+
		'        \"MNT\": 3369.0139,'+
		'        \"MOP\": 8.0464,'+
		'        \"MRU\": 39.2335,'+
		'        \"MUR\": 46.4209,'+
		'        \"MVR\": 15.4534,'+
		'        \"MWK\": 1742.6743,'+
		'        \"MXN\": 18.5026,'+
		'        \"MYR\": 4.7200,'+
		'        \"MZN\": 63.7907,'+
		'        \"NAD\": 18.5850,'+
		'        \"NGN\": 1492.6764,'+
		'        \"NIO\": 36.8076,'+
		'        \"NOK\": 10.7007,'+
		'        \"NPR\": 133.7577,'+
		'        \"NZD\": 1.6294,'+
		'        \"OMR\": 0.3845,'+
		'        \"PAB\": 1.0000,'+
		'        \"PEN\": 3.7825,'+
		'        \"PGK\": 3.8774,'+
		'        \"PHP\": 58.7537,'+
		'        \"PKR\": 278.5611,'+
		'        \"PLN\": 4.0405,'+
		'        \"PYG\": 7505.0295,'+
		'        \"QAR\": 3.6400,'+
		'        \"RON\": 4.6372,'+
		'        \"RSD\": 109.0042,'+
		'        \"RUB\": 89.1709,'+
		'        \"RWF\": 1312.6291,'+
		'        \"SAR\": 3.7500,'+
		'        \"SBD\": 8.3453,'+
		'        \"SCR\": 13.4990,'+
		'        \"SDG\": 449.0873,'+
		'        \"SEK\": 10.4888,'+
		'        \"SGD\": 1.3532,'+
		'        \"SHP\": 0.7852,'+
		'        \"CZK\": 22.4420,'+
		'        \"SLL\": 22442.0480,'+
		'        \"SOS\": 571.9119,'+
		'        \"SRD\": 31.7313,'+
		'        \"SSP\": 1797.9804,'+
		'        \"STN\": 22.8165,'+
		'        \"SYP\": 12891.3947,'+
		'        \"SZL\": 18.5850,'+
		'        \"THB\": 36.7316,'+
		'        \"TJS\": 10.8136,'+
		'        \"TMT\": 3.5000,'+
		'        \"TND\": 3.1363,'+
		'        \"TTD\": 6.7692,'+
		'        \"ZWL\": 13.4639'+
		'    }'+
		'}';
        return  mockString;
    }
}