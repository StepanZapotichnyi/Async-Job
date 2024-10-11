public with sharing class CryptoInvestorController {

    @AuraEnabled
    public static InvestmentDetailsWrapper getInvestmentDetails() {

        PortfolioCurrencyController.PortfolioCurrencyWrapper portfolioCurrencyDetails = PortfolioCurrencyController.getPortfolioCurrencyDetails();
    
        Decimal totalBalanceInvestment = portfolioCurrencyDetails.netInvestment;
        List<Portfolio_Currency__c> portfolioCurrencies = portfolioCurrencyDetails.portfolioCurrencies;

        Decimal currencyBalance = calculetedAllQuntity(portfolioCurrencyDetails.symbolToTotalQuantityMap);
       
        List<Portfolio__c> portfolios = PortfolioController.getPortfolios();
        List<Transaction__c> transactions = TransactionController.getAllTransaction();
        
        return new InvestmentDetailsWrapper(totalBalanceInvestment, currencyBalance, portfolios, transactions);
    }
    
    public static Decimal calculetedAllQuntity(Map<String, Decimal> symbolToTotalQuantityMap){
        try{
            Map<String,CryptoData.Price>  pricesCtyptoCurrency = getPricesCtyptoCurrency();

            Decimal totalValue = 0;
            
            for (String symbol : symbolToTotalQuantityMap.keySet()) {
                Decimal quantity = symbolToTotalQuantityMap.get(symbol);
                if (pricesCtyptoCurrency.containsKey(symbol)) {
                    CryptoData.Price priceToSymbol = pricesCtyptoCurrency.get(symbol);
                    Decimal price = priceToSymbol.USD;
                    totalValue += quantity * price;
                }
            }

            totalValue = totalValue.setScale(4);
            return totalValue;
        } catch (Exception e) {
            throw new CryptoInvestorControllerException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PortfolioCurrencyDetails> getDataTableDetails(Id portfolioId) {
    
        List<PortfolioCurrencyDetails> dataTableDetails = new List<PortfolioCurrencyDetails>();
    
        Map<String, CryptoData.Price> pricesCtyptoCurrency = getPricesCtyptoCurrency();
    
        List<Portfolio_Currency__c> portfolioCurrencies = [
            SELECT
                Id, Name, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM 
                Portfolio_Currency__c
            Where 
                PortfolioId__c =: portfolioId
        ];
    
        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencies) {
            if (portfolioCurrency.Total_Quantity__c <= 0) {
                continue;
            }

            String portfolioCurrencyId = portfolioCurrency.Id;
            String symbol = portfolioCurrency.Symbol__c;
            String totalQuantity = String.valueOf(portfolioCurrency.Total_Quantity__c);
            
            String portfolioIdStr = portfolioCurrency.PortfolioId__c;
    
            String price = '0';
            String totalCost = '0';
    
            if (pricesCtyptoCurrency.containsKey(symbol)) {
                CryptoData.Price priceToSymbol = pricesCtyptoCurrency.get(symbol);
                price = String.valueOf(priceToSymbol.USD);
            }
    
            Map<Id, Decimal> portfolioCurrencySummaryMap = new Map<Id, Decimal>();
            for (PortfolioCurrencySummary__c currencySummary : portfolioCurrency.PortfolioCurrencySummaries__r) {
                portfolioCurrencySummaryMap.put(currencySummary.Portfolio_CurrencyId__c, currencySummary.Total_Cost__c);
            }
    
            if (portfolioCurrencySummaryMap.containsKey(portfolioCurrencyId)) {
                totalCost = String.valueOf(portfolioCurrencySummaryMap.get(portfolioCurrencyId));
            }
    
            PortfolioCurrencyDetails detail = new PortfolioCurrencyDetails(
                portfolioCurrencyId,
                symbol,
                totalQuantity,
                portfolioIdStr,
                price,
                totalCost
            );
    
            dataTableDetails.add(detail);
        }
        
        return dataTableDetails;
    }

    public static Map<String,CryptoData.Price> getPricesCtyptoCurrency() {
        try {
            Map<String, CryptoData.Price> pricesCtyptoCurrency = PortfolioCryptoService.retrievePortfolioCryptoData();
            return pricesCtyptoCurrency;
        }   catch (Exception e) {
            throw new CryptoInvestorControllerException(e.getMessage());
        }

    }


    
    public class InvestmentDetailsWrapper {
        @AuraEnabled public Decimal totalBalanceInvestment;
        @AuraEnabled public Decimal currencyBalance;
        @AuraEnabled public List<Portfolio__c> portfolios;
        @AuraEnabled public List<Transaction__c> transactions;
        

        
        public InvestmentDetailsWrapper(Decimal totalBalanceInvestment, Decimal currencyBalance, List<Portfolio__c> portfolios, List<Transaction__c> transactions) {
            this.totalBalanceInvestment = totalBalanceInvestment;
            this.currencyBalance = currencyBalance;
            this.portfolios = portfolios;
            this.transactions = transactions;
        }
    }

    public class CryptoInvestorControllerException extends Exception {
            
    }
}

