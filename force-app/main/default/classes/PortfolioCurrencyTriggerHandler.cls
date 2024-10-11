public with sharing class PortfolioCurrencyTriggerHandler { 
    public static void  handleToUpdatePortfolioCurrencyName(List<Portfolio_Currency__c> portfolioCurrencies) {
        
        Map<Id, String> portfolioIdAndSymbols = new Map<Id, String>();

        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencies) { 
            portfolioIdAndSymbols.put(portfolioCurrency.PortfolioId__c, portfolioCurrency.Symbol__c);
        }

        List<Portfolio__c> portfolios = [SELECT Id, Name FROM Portfolio__c WHERE Id IN :portfolioIdAndSymbols.keySet()];
     
        Map<Id, String> portfolioCurrencyNames = new Map<Id, String>();
        for (Portfolio__c portfolio : portfolios) {
            String symbol = portfolioIdAndSymbols.get(portfolio.Id);
                String portfolioCurrencyName = symbol + '-' + portfolio.Name;
                portfolioCurrencyNames.put(portfolio.Id, portfolioCurrencyName); 
        }
        
        if (!portfolioCurrencyNames.isEmpty()) {
            updatePortfolioCurrencyNames(portfolioCurrencies, portfolioCurrencyNames);
        }
    }
    
    public static void updatePortfolioCurrencyNames(List<Portfolio_Currency__c> portfolioCurrencies, Map<Id, String> portfolioCurrencyNames) {
        List<Portfolio_Currency__c> portfolioCurrenciesToUpdate = new List<Portfolio_Currency__c>();

        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencies) {
            String newName = portfolioCurrencyNames.get(portfolioCurrency.PortfolioId__c);
                Portfolio_Currency__c updatedPortfolioCurrency = new Portfolio_Currency__c(
                    Id = portfolioCurrency.Id,
                    Name = newName);
                portfolioCurrenciesToUpdate.add(updatedPortfolioCurrency);
        }
    
        if (!portfolioCurrenciesToUpdate.isEmpty()) {
            update portfolioCurrenciesToUpdate;
            createPortfolioCurrencySummary(portfolioCurrenciesToUpdate);

        }

    }
    public static void createPortfolioCurrencySummary(List<Portfolio_Currency__c> portfolioCurrencyList) {
        List<PortfolioCurrencySummary__c> portfolioCurrencySummaryList = new List<PortfolioCurrencySummary__c>();

        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencyList) {
            PortfolioCurrencySummary__c portfolioCurrencySummary = new PortfolioCurrencySummary__c(
                Name = portfolioCurrency.Name,
                Portfolio_CurrencyId__c = portfolioCurrency.Id,
                Total_Profit__c = 0,
                Total_Cost__c = 0
            );
            portfolioCurrencySummaryList.add(portfolioCurrencySummary);
        }

        if (!portfolioCurrencySummaryList.isEmpty()) {
            insert portfolioCurrencySummaryList;
        }
    }
    
}
