@isTest
public with sharing class ContactControllerTest {
    @isTest 
    static void testEnqueueJob(){

        Integer testNumber = 5;
        List<Account> testAccounts = TestFactory.createAccount(testNumber);
        insert testAccounts;
        
        List<Contact> testContacts = TestFactory.createContactToAccount(testAccounts, testNumber);
        insert testContacts;
        
        List<Id> testIds = new List<Id>();
        for (Account acc : testAccounts) {
            testIds.add(acc.Id);
        }
        
        Test.startTest();

        ContactController createdContact = new ContactController(testIds);
        System.enqueueJob(createdContact);
        
        Test.stopTest();
        
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :testIds];
        List<Account> accounts = [SELECT Id, Name, Number_Of_Contacts__c FROM Account WHERE Id IN :testIds];

        Assert.areEqual(contacts.size(), testContacts.size() + testNumber, 'Contacts should will be creat: ' + (testContacts.size() + testNumber));

        for(Account acc : accounts) {
            Assert.areEqual(acc.Number_Of_Contacts__c, testNumber + 1, 'Field Number Of Contacts should should will have Contacts: '+ (testNumber + 1));
        } 
            
    }
}