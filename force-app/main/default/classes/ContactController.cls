public with sharing class ContactController implements Queueable {
    public List<Id> accountIds;

    public ContactController(List<Id> ids) {
        this.accountIds = ids;
    }

    public void execute(QueueableContext qc) {
        createContactToAccounts(accountIds);
    }

    public static void createContactToAccounts(List<Id> accountIds) {

        List<Contact> newContacts = new List<Contact>();

        for(Id accountId : accountIds) {
            Contact contact = new Contact();
            contact.LastName = 'Joi';
            contact.FirstName = 'Peter';
            contact.AccountId = accountId;
            newContacts.add(contact);
        }

        if(!newContacts.isEmpty()){
            insert newContacts;
            AccountController.updateNumberOfContacts(accountIds);
        }

    }   

    public static void updateFieldLatsUpdate(List<Contact> contacts){ 
    
        List<Contact> contactsToUpdate= new List<Contact>();
            
        for (Contact contact : contacts) {
            contact.Last_Update__c = System.now();
            contactsToUpdate.add(contact);
        }
        
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }

    }
}
