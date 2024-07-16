public with sharing class PortfolioController {
   
    @AuraEnabled
    public static Account createPortfolio(String name) {
    
        Account account = new Account();
        account.Name = name;
        account.Portfolio_Name__c = name;

        insert account;

        return account;
    }


    @AuraEnabled
    public static List<Account> getPortfolios() {

        List<Account> accounts = [SELECT Id, Portfolio_Name__c FROM Account WHERE Portfolio_Name__c != null];
        return accounts;
        
        
    }

    @AuraEnabled
    public static Opportunity createTransaction(Id accountId, String name, Integer quantity, Integer pricePerCoin){

        // List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity opportunity = new Opportunity();

        opportunity.Name = name;
        opportunity.AccountId = accountId;
        opportunity.TotalOpportunityQuantity = quantity;
        opportunity.Price_Per_Coin__c = pricePerCoin;
        opportunity.CloseDate = Date.today().addYears(150);
        opportunity.StageName = 'Prospecting';

        System.debug('1' + accountId);
        System.debug('2' + name);
        System.debug('3' + quantity);
        System.debug('4' + pricePerCoin);

        insert opportunity;

        return opportunity;

    }

    @AuraEnabled 
    public static List<Opportunity> getTransaction(List<Id> accountId) {

        return [SELECT Id, Name, TotalOpportunityQuantity, Price_Per_Coin__c FROM Opportunity WHERE AccountId In: accountId];
    }

    
}