public with sharing class PortfolioCurrencyController {

    public static Id createPortfolioCurrency(Map<String, Object> transactionData) {
       
        
        Portfolio_Currency__c portfolioCurrency = new Portfolio_Currency__c();
        portfolioCurrency.Name = (String) transactionData.get('symbol');
        portfolioCurrency.Symbol__c = (String) transactionData.get('symbol');
        portfolioCurrency.PortfolioId__c = (Id) transactionData.get('portfolioId');

        insert portfolioCurrency;    
        return portfolioCurrency.Id;
    }

    public static PortfolioCurrencyWrapper getPortfolioCurrencyDetails() {

        Map<String, Decimal> symbolToTotalQuantityMap = new Map<String, Decimal>();
        Decimal netInvestment = 0;
        Decimal totalCost = 0;
        Decimal totalProfit = 0;

        List<Portfolio_Currency__c> portfolioCurrencies = [
            SELECT
                Id, Name, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM Portfolio_Currency__c
        ];

        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencies) {
            String symbol = portfolioCurrency.Symbol__c;
            Decimal quantity = portfolioCurrency.Total_Quantity__c != null ? portfolioCurrency.Total_Quantity__c : 0;

            symbolToTotalQuantityMap.put(symbol, symbolToTotalQuantityMap.get(symbol) != null ? symbolToTotalQuantityMap.get(symbol) + quantity : quantity);

            if (!portfolioCurrency.PortfolioCurrencySummaries__r.isEmpty()) {
                for (PortfolioCurrencySummary__c currencySummary : portfolioCurrency.PortfolioCurrencySummaries__r) {
                    totalCost += currencySummary.Total_Cost__c != null ? currencySummary.Total_Cost__c : 0;
                    totalProfit += currencySummary.Total_Profit__c != null ? currencySummary.Total_Profit__c : 0;
                }
            }
        }

        netInvestment = totalCost - totalProfit;
        netInvestment = netInvestment > 0 ? netInvestment : 0; 
     

        return new PortfolioCurrencyWrapper(netInvestment, symbolToTotalQuantityMap, portfolioCurrencies);
    }

    public class PortfolioCurrencyWrapper {
        public Decimal netInvestment;
        public Map<String, Decimal> symbolToTotalQuantityMap;
        public List<Portfolio_Currency__c> portfolioCurrencies;

        public PortfolioCurrencyWrapper(Decimal netInvestment, Map<String, Decimal> symbolToTotalQuantityMap, List<Portfolio_Currency__c> portfolioCurrencies) {
            this.netInvestment = netInvestment;
            this.symbolToTotalQuantityMap = symbolToTotalQuantityMap;
            this.portfolioCurrencies = portfolioCurrencies;
        }
    }


}
