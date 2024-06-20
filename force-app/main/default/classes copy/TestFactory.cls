public with sharing class TestFactory {
    
    public static List<Account> createAccount(Integer amountAccounts) {
        List<Account>  testAccount = new List<Account>();
        for(Integer i = 0; i < amountAccounts; i++) {
            Account account = new Account();
            account.Name = 'TestAccount' + i;
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
          for(Integer i = 0; i <= amountContacts; i++){
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
}