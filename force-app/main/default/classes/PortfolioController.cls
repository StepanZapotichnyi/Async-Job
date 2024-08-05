public with sharing class PortfolioController {
   
    @AuraEnabled
    public static Account createPortfolio(String name) {
        //custon object add
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
    public static void updateTransaction( Opportunity opportunityTransaction){
       System.debug('He+++' +opportunityTransaction);
      
            Opportunity opportunity = new Opportunity();
            opportunity.Id = opportunityTransaction.Id;
            opportunity.Quantity__c = opportunityTransaction.Quantity__c;
            opportunity.Price_Per_Coin__c = opportunityTransaction.Price_Per_Coin__c.setscale(5);
            update opportunity;

       
    }
    @AuraEnabled
    public static void deleteTransaction(Id opportunityId){
        
        try{
            List<Opportunity> opportunityToDelete = [SELECT Id FROM Opportunity WHERE Id = :opportunityId ];
            if(!opportunityToDelete.isEmpty()){
                delete opportunityToDelete;
            }

        }catch (PortfolioControllerException e){
            throw new PortfolioControllerException('Error deleting transaction: ' + e.getMessage());
        }
         
    }


    @AuraEnabled
    public static void deletePortfolio(Id portfolioId){
        
        try{
            List<Account> accountToDelete = [SELECT Id FROM Account WHERE Id = :portfolioId ];
            if(!accountToDelete.isEmpty()){
                delete accountToDelete;
            }

        }catch (PortfolioControllerException e){
            throw new PortfolioControllerException('Error deleting portfolio: ' + e.getMessage());
        }
         
    }


    @AuraEnabled
    public static void createTransaction(Id accountId, String name, Decimal quantity, Decimal pricePerCoin){
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = accountId;

        opportunity.Name = name;
        // opportunity.Price__c = pricePerCoin;
        opportunity.Quantity__c = quantity;

        opportunity.Price_Per_Coin__c = pricePerCoin;
        //opportunity.Profit_And_Loss__c = pricePerCoin;

        opportunity.CloseDate = Date.today().addYears(150);
        opportunity.StageName = 'Prospecting';

        insert opportunity;

        // return opportunity;

    }

    // @AuraEnabled 
    // public static List<Opportunity> getTransaction(List<Id> accountId) {
    //     Lsit<Opportunity> opportunities = [SELECT Id, Name, Quantity__c, Price_Per_Coin__c FROM Opportunity WHERE AccountId In: accountId];
       
    //     return opportunities;
    // }

    @AuraEnabled 
    public static List<Opportunity> getTransaction(List<Id> accountId) {
        List<String>  tokens = new List<String>();

        List<Opportunity> opportunities = [
            SELECT
                 Id, Name, Quantity__c, Price_Per_Coin__c, Price__c, Profit_And_Loss__c
            FROM
                Opportunity 
            WHERE 
                AccountId In: accountId
        ];


        for (Opportunity Op : opportunities){
            tokens.add(Op.Name);
        }

        Map<String,Decimal> tokenAndPrices = getTokenPrices(tokens);
        Map<Id,Decimal> profitAndLoss = calculateProfitAndLoss(opportunities, tokenAndPrices );
        System.debug(profitAndLoss);


        for(Opportunity o : opportunities){
            o.Price__c = tokenAndPrices.get(o.Name);
            o.Profit_And_Loss__c = profitAndLoss.get(o.Id);
        }
       
        return opportunities;
    }

    public static Map<String,Decimal> getTokenPrices(List<String> tokens){
       
        Map<String,Decimal> tokenAndPrices = new Map<String,Decimal>();

        PriceCrypto   responses = PortfolioCryptoService.retrievePortfolioCryptoData();
        System.debug('' + responses.Data);

        // if(!responses?.Response?.contains('Error')){
            for(String nameToken : tokens){
                for (String token : responses.Data.keySet()) {
                    PriceCrypto.Price price = responses.Data.get(token);
                    if(token.equals(nameToken)){
                        System.debug('Currency: ' + token + ', Price in USD: ' + price.USD);
                        tokenAndPrices.put(token, price.USD);
                    }
                }
            }
        // }else{
        //     throw new PortfolioControllerException('Error deleting portfolio: ' + responses.Message);
        // }

        return tokenAndPrices;
    }

    public static Map<Id, Decimal> calculateProfitAndLoss(List<Opportunity> opportunities, Map<String,Decimal> tokenAndPrices) {
       
        Map<Id, Decimal> profitMap = new Map<Id, Decimal>();
        
        for (Opportunity op : opportunities) {
            String token = op.Name;
            if (tokenAndPrices.containsKey(token)) {
                Decimal price = tokenAndPrices.get(token);
                System.debug('New++'+price);
                
                Decimal perCoin = op.Price_Per_Coin__c;
                System.debug( 'old++'+perCoin);
                Decimal quantity = op.Quantity__c;
                System.debug('sum+++'+price);
                Decimal profit = (price - perCoin)  * quantity; 


                profitMap.put(op.Id, profit.setscale(5));
                // System.debug('Currency: ' + token + ', Profit in USD: ' + profit.stripTrailingZeros());
            }
        }
        return profitMap;
    }


    public class PortfolioControllerException extends Exception {
            
    }
}