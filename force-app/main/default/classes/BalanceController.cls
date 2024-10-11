public with sharing class BalanceController {
    
//     @AuraEnabled
//     public static Balance__c createdBalance(Decimal amount) {
//         //custon object add
//         System.debug(amount);
//         Balance__c balance = new Balance__c();
//         balance.Name = 'Balance';
//         balance.Total_Invest__c = amount;

//         insert balance;
//         System.debug(balance);
//         return balance;
//     }

//     @AuraEnabled
//     public static void updatedBalance(Decimal amount, Id balanceId) {
//         //custon object add
//         System.debug(amount);
//         Balance__c balance = new Balance__c();
//         balance.Id = balanceId;
//         balance.Total_Invest__c = amount;

//         update balance;
//     }


//     @AuraEnabled
//     public static List<Balance__c> getBalance(){

//         List<Balance__c> a = new List<Balance__c>();
//         // System.debug('after'+ balanceId);
//         // if(balanceId != null ){
//         //     System.debug('if'+ balanceId);
//             a = [SELECT Id, Name, Total_PNL_today__c, Total_P__c, Total_Invest__c FROM Balance__c ];
//         // }else{
//         //     System.debug('else'+ balanceId);
//         //     System.debug('else'+ a);
//         //     //    return [SELECT Id, Name, Total_PNL_today__c, Total_P__c, Total_Invest__c FROM Balance__c]; 
//         //     return a; 
//         // }   
//         // System.debug('e'+ a);
//         return a; 

//     }

    
//     // @AuraEnabled
//     // public static void deleteBalance(){
//     //     List<Balance__c> a =[SELECT CreatedById, Name, Total_PNL_today__c, Total_P__c, Total_Invest__c FROM Balance__c ];
//     //     for (Balance__c b : a){
//     //         delete b;
//     //     }
//     // }

    
}