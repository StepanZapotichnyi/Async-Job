public with sharing class AccountController {
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
            update newAccounts;
        }
    }

    public static List<Account> getAllAccountIds(){
        return [SELECT Id FROM Account];
    }
}