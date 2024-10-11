public with sharing class TransactionController {

    @AuraEnabled
    public static void createTransaction(String data) {
        Map<String, Object> transactionData = (Map<String, Object>) JSON.deserializeUntyped(data);

        Transaction__c newTransaction = new Transaction__c();
        newTransaction.Type_Transaction__c = (String) transactionData.get('typeTransaction');
        newTransaction.Amount__c =  Decimal.valueOf((String) transactionData.get('amountTransaction'));
        newTransaction.Quantity__c = (Decimal) transactionData.get('quantityTransaction');
        newTransaction.Portfolio_CurrencyId__c = isValidPortfolioCurrencyId(transactionData);

        insert newTransaction;

    }

    public static Id isValidPortfolioCurrencyId(Map<String, Object> transactionData){

        Id portfolioCurrencyId = (Id) transactionData.get('portfolioCurrencyId');
        if(portfolioCurrencyId == null){
            portfolioCurrencyId = PortfolioCurrencyController.createPortfolioCurrency(transactionData);
        }
        
        return portfolioCurrencyId;
    }
    
    @AuraEnabled
    public static List<Transaction__c> getAllTransaction() {

        return [
            SELECT
                 Id, Name, Amount__c, Quantity__c, Type_Transaction__c, Price_Per_Coin__c, CreatedDate, Symbol__c
            FROM 
                Transaction__c];
    }

}
