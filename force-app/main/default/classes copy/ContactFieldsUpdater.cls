public with sharing class ContactFieldsUpdater implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<Account> accountIds = AccountController.getAllAccountIds();
        System.debug(accountIds);
    
        return Database.getQueryLocator([SELECT Id, AccountId, Last_Update__c  FROM Contact WHERE AccountId IN :accountIds ]); 
    }

    public void execute(Database.BatchableContext bc, List<Contact> contacts) {
        
        System.debug(contacts);
        ContactController.updateFieldLatsUpdate(contacts);
        
    }
        
    public void finish(Database.BatchableContext bc) {
     
    }
}