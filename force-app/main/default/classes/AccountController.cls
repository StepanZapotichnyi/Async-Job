public with sharing class AccountController {
  
    public static List<Id> getAllAccountIds() {
        List<Id> accountIds = new List<Id>();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        for(Account acc : accounts){
            accountIds.add(acc.Id);
        }
        return accountIds;
    }
    
    
    public static void updateNumberOfContacts(List<Id> accountIds){
        
        List<Account> newAccounts = new List<Account>();
        
        List<AggregateResult> groupedResults = [ 
            SELECT 
                AccountId, COUNT(Id) contactCount 
            FROM 
                Contact 
            WHERE 
                AccountId IN :accountIds 
            GROUP BY 
                AccountId
        ]; 
        
        for(AggregateResult ar : groupedResults) {
            Id accountId = (Id) ar.get('AccountId');
            Integer contactCount = (Integer) ar.get('contactCount');
            Account account = new Account();
            account.Id = accountId;
            account.Number_Of_Contacts__c = contactCount;
            newAccounts.add(account);
        }

        if(!newAccounts.isEmpty()){
            System.debug('upd' + newAccounts);
            update newAccounts;
        }
    }

    
}