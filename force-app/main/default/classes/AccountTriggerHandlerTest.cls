@isTest
public with sharing class AccountTriggerHandlerTest {
    @IsTest
    static void testUpdateAccountsPositive() {

        String testMok = TestFactory.geMockString();

        Test.setMock(HttpCAlloutMock.class, new AccountTriggerHandlerMock(200, testMok));

        Integer testNumber = 300;
        List<Account> testAccounts = TestFactory.createAccount(testNumber);
        insert testAccounts;
        
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, Account> oldAccountsMap = new Map<Id, Account>();
        
        for (Account acc : testAccounts) {
            Account account = new Account(Id = acc.Id, AnnualRevenue = 25000000);
            accountsToUpdate.add(account);
            oldAccountsMap.put(acc.Id, acc);
        }

        Test.startTest();
        AccountTriggerHandler.updateAccounts(accountsToUpdate, oldAccountsMap);
        Test.stopTest();

        List<Account> accountsAfterUpdate = [SELECT ID, Name, AnnualRevenue, Count_of_Bitcoin__c  FROM Account WHERE ID IN: oldAccountsMap.keySet()];

        for(Account account : accountsAfterUpdate) {
            Assert.areNotEqual(account.Count_of_Bitcoin__c, null, 'Count_of_Bitcoin__c should not be null');
            Assert.areEqual('2473.0416184', account.Count_of_Bitcoin__c,'Count_of_Bitcoin__c should be updated to the correct value');

        }

    }

  
    @IsTest
    static void testGetExchangeRateNegative() {

        String testMock = '{ "error" : "Not found RateSymbol"}';
        Integer testCode = 400;
        Test.setMock(HttpCAlloutMock.class, new AccountTriggerHandlerMock(testCode, testMock));

        
        Map<String,Decimal> testSymbolsAndPrice = new Map<String, Decimal>();
        Map<String,String> testCurrencySymbolMappings = new Map<String, String>{
            'RateSymbol'  => 'eFr',
            'CyptoSymbol'   => 'rrt',
            'ActualSymbol' => 'ckz'      
        };
        
        String testMessage = 'HTTP request failed with status code: ' + String.valueOf(testCode) + ' and response: ' + testMock;

        try {

            Test.startTest();
            Map<String,Decimal> result = AccountTriggerHandler.getExchangeRate(testSymbolsAndPrice, testCurrencySymbolMappings);
            Test.stopTest();
            
        } catch (AccountTriggerHandler.AccountTriggerHandlerException e)  {
            Assert.areEqual(testMessage, e.getMessage(), 'Exception message should match the expected message.');
        }

    }

    @IsTest
    static void testGetCryptoPriceErrorNegative() {

        String message = 'RateSymbo or fsym is a required param.';
        String testMock = '{ "Response": "Error", "Message": "'  + message + '","HasWarning": false, "Type": 2,"RateLimit": {},"Data": {},"ParamWithError": "fsym"}';
        Integer testCode = 200;

        Test.setMock(HttpCAlloutMock.class, new AccountTriggerHandlerMock(testCode, testMock));

        
        Map<String,Decimal> testSymbolsAndPrice = new Map<String, Decimal>{
            'CZK' => 22.3
        };

        Map<String,String> testCurrencySymbolMappings = new Map<String, String>{
            'RateSymbol'  => '',
            'CyptoSymbol'   => 'rrt',
            'ActualSymbol' => 'ckz'      
        };
        
        String testMessage = 'HTTP request failed with status code: ' + String.valueOf(testCode) + ' and response: ' + message;
        
        try {

            Test.startTest();
            Map<String,Decimal> result = AccountTriggerHandler.getCryptoPrice(testSymbolsAndPrice, testCurrencySymbolMappings);
            Test.stopTest();
            
        } catch (AccountTriggerHandler.AccountTriggerHandlerException e){
            Assert.areEqual(testMessage, e.getMessage(), 'Exception message should match the expected message.');
        }

    }


    @IsTest
    static void testGetCryptoPriceNegative() {

        String testMock = '{ "Response": "Error", "Message": "Not fouund","HasWarning": false, "Type": 2,"RateLimit": {},"Data": {}}';
        Integer testCode = 400;

        Test.setMock(HttpCAlloutMock.class, new AccountTriggerHandlerMock(testCode, testMock));

        
        Map<String,Decimal> testSymbolsAndPrice = new Map<String, Decimal>{
            'CZK' => 22.3
        };

        Map<String,String> testCurrencySymbolMappings = new Map<String, String>{
            'RateSymbol'  => '',
            'CyptoSymbol'   => 'rrt',
            'ActualSymbol' => 'ckz'      
        };
        
        String testMessage = 'HTTP request failed with status code: ' + String.valueOf(testCode) + ' and response: ' + testMock;
        
        try {

            Test.startTest();
            Map<String,Decimal> result = AccountTriggerHandler.getCryptoPrice(testSymbolsAndPrice, testCurrencySymbolMappings);
            Test.stopTest();
            
        } catch (AccountTriggerHandler.AccountTriggerHandlerException e){
            System.debug(e);
            Assert.areEqual(testMessage, e.getMessage(), 'Exception message should match the expected message.');
        }

    }

    

      // @IsTest
    // static void testUpdateAccountsNegative() {

    //     String testMessage = 'No account revenues were updated.'; 
    //     Integer testNumber = 5;
    //     List<Account> testAccounts = TestFactory.createAccount(testNumber);
    //     insert testAccounts;

    //     Map<Id, Account> oldAccountsMap = new Map<Id, Account>();
        
    //     for(Account testAccount : testAccounts) {
    //         oldAccountsMap.put(testAccount.Id, testAccount);    
    //     }
    

    //     try {

    //         Test.startTest();
    //         AccountTriggerHandler.updateAccounts(testAccounts, oldAccountsMap);
    //         Test.stopTest();
            
    //     } catch (AccountTriggerHandler.AccountTriggerHandlerException e)  {
    //         Assert.areEqual(testMessage, e.getMessage());
    //     }
        
    // }



   
}