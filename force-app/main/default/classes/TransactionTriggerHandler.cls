 public with sharing class TransactionTriggerHandler {

    public static void handleToUpdatePortfolioCurrency(List<Transaction__c> tranascations) {

        Map<Id, List<Transaction__c>> portfolioCurrencyIdsToTransactions = new Map<Id, List<Transaction__c>>();
        for (Transaction__c txn : tranascations) {
            if (txn.Portfolio_CurrencyId__c != null) {
               
                if (!portfolioCurrencyIdsToTransactions.containsKey(txn.Portfolio_CurrencyId__c)) {
                    portfolioCurrencyIdsToTransactions.put(txn.Portfolio_CurrencyId__c, new List<Transaction__c>());
                }

                portfolioCurrencyIdsToTransactions.get(txn.Portfolio_CurrencyId__c).add(txn);
            }
        }
        updatePortfolioCurrency(portfolioCurrencyIdsToTransactions);
    }


    public static void updatePortfolioCurrency(Map<Id, List<Transaction__c>> portfolioCurrencyIdsToTransactions) {
        System.debug( 'update'+portfolioCurrencyIdsToTransactions );
        
        List<Portfolio_Currency__c> portfolioCurrencyList = [
             SELECT 
                Id, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM 
                Portfolio_Currency__c 
                WHERE Id IN :portfolioCurrencyIdsToTransactions.keySet()
        ];

        System.debug( 'update'+ portfolioCurrencyList);
        Map <Id, Map<String, Decimal>> totalCalculate  = calculatePortfolioCurrencyTotals(portfolioCurrencyIdsToTransactions, portfolioCurrencyList);
            
        for (Portfolio_Currency__c pf : portfolioCurrencyList) {
            if (totalCalculate.containsKey(pf.Id)) {
                Map<String, Decimal> calculations = totalCalculate.get(pf.Id);

                pf.Total_Quantity__c = calculations.get('totalQuantity');
                
            }
        } 

        if(!portfolioCurrencyList.isEmpty()){
            update portfolioCurrencyList;
            updatePortfolioCurrencySummaries(portfolioCurrencyList, totalCalculate);
        }
        
    }   


    public static Map<Id, Map<String, Decimal>> calculatePortfolioCurrencyTotals(Map<Id, List<Transaction__c>> portfolioCurrencyIdsToTransactions, List<Portfolio_Currency__c> portfolioCurrencyList) {
    
        Map<Id, Map<String, Decimal>> totalCalculate = new Map<Id, Map<String, Decimal>>();
        
        Map<Id, Portfolio_Currency__c> portfolioCurrencyMap = new Map<Id, Portfolio_Currency__c>(portfolioCurrencyList);
        
        for (Id portfolioCurrencyId : portfolioCurrencyIdsToTransactions.keySet()) {
            Portfolio_Currency__c pf = portfolioCurrencyMap.get(portfolioCurrencyId);
            
            Decimal totalQuantity = pf.Total_Quantity__c ?? 0;
            Decimal totalCost = 0;
            Decimal totalProfit = 0;
            
            for (Transaction__c txn : portfolioCurrencyIdsToTransactions.get(portfolioCurrencyId)) {
                Decimal quantity = txn.Quantity__c ?? 0;
                Decimal amount = txn.Amount__c ?? 0;
                
                if (txn.Type_Transaction__c == 'Buy') {
                    totalQuantity += quantity;
                    totalCost += amount; 
                } else if (txn.Type_Transaction__c == 'Sell') {
                    totalQuantity -= quantity;
                    totalProfit += amount; 
                }
            }
            
                totalCalculate.put(portfolioCurrencyId, new Map<String, Decimal>{
                    'totalCost' => totalCost,
                    'totalQuantity' => totalQuantity,
                    'totalProfit' => totalProfit
                });
        }
        
        return totalCalculate;
    }
    

    public static void updatePortfolioCurrencySummaries(List<Portfolio_Currency__c> portfolioCurrencyList, Map <Id, Map<String, Decimal>> totalCalculate){
        
        List<PortfolioCurrencySummary__c> portfolioCurrencySummaryListToUpdate = new List<PortfolioCurrencySummary__c>();
    
        for(Portfolio_Currency__c portfolioCurrency : portfolioCurrencyList) {
            for(PortfolioCurrencySummary__c currencySummary : portfolioCurrency.PortfolioCurrencySummaries__r) {
                currencySummary.Total_Cost__c = currencySummary.Total_Cost__c + totalCalculate.get(currencySummary.Portfolio_CurrencyId__c).get('totalCost');
                currencySummary.Total_Profit__c = currencySummary.Total_Profit__c + totalCalculate.get(currencySummary.Portfolio_CurrencyId__c).get('totalProfit');

                portfolioCurrencySummaryListToUpdate.add(currencySummary);
            }
        }
        if(!portfolioCurrencySummaryListToUpdate.isEmpty()){

            update portfolioCurrencySummaryListToUpdate;
        }

    }

   

 }



    // }

    // public static void updateTotalProfit(Decimal spend){
        
    // }
    
    //   totalCalculate = isValidTottalQuantity(totalCalculate);
    // public static Map <Id, Map<String, Decimal>> isValidTottalQuantity(Map <Id, Map<String, Decimal>> totalCalculate ){

    //     for (Id portfolioCurrencyId : totalCalculate.keySet()) {

    //         Map<String, Decimal> calculations = totalCalculate.get(portfolioCurrencyId);
    //         Decimal totalCost = 0; 
    //         Decimal totalQuantity = 0;
    //         System.debug('totalQuantity');
    //         System.debug(calculations.get('totalCost') <= 0 && calculations.get('totalQuantity') <= 0 );

    //         if (calculations.get('totalCost') < 0 && calculations.get('totalQuantity') <= 0) {
    //             System.debug('ss' + calculations);
    //             calculations.put('totalCost', totalCost);
    //             calculations.put('totalQuantity', calculations.get('totalQuantity'));
    //         }
    //         totalCalculate.put(portfolioCurrencyId, calculations);
    //     }   

    //     return totalCalculate;
    // }