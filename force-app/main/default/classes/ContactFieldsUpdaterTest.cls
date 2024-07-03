@isTest
public with sharing class ContactFieldsUpdaterTest {
    
    @IsTest
    static void testUpdateFieldLatsUpdate() {
        
        Integer testNumber = 5;
        List<Account> testAccounts = TestFactory.createAccount(testNumber);
        insert testAccounts;

        List<Contact> testContacts = TestFactory.createContactToAccount(testAccounts, testNumber);
        insert testContacts;

        Test.startTest();
        ContactFieldsUpdater updater = new ContactFieldsUpdater();
        Id batchId = Database.executeBatch(updater);
        Test.stopTest();
        
        List<Contact> contacts  = [SELECT Id, AccountId, Last_Update__c  FROM Contact WHERE AccountId IN : testAccounts];

        for(Contact cont : contacts){
            Assert.areEqual(cont.Last_Update__c, System.now(), 'Contacts should will be updat: ' + System.now());
        }
    }
}