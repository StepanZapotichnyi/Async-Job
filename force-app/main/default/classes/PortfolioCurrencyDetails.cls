public class PortfolioCurrencyDetails {
    @AuraEnabled public String portfolioCurrencyId { get; set; }
    @AuraEnabled public String symbol { get; set; }
    @AuraEnabled public String totalQuantity { get; set; }
    @AuraEnabled public String portfolioId { get; set; }
    @AuraEnabled public String price { get; set; }
    @AuraEnabled public String totalCost { get; set; }
    
    
    public PortfolioCurrencyDetails(String portfolioCurrencyId, String symbol, String totalQuantity, String portfolioId, String price, String totalCost) {
        this.portfolioCurrencyId = portfolioCurrencyId;
        this.symbol = symbol;
        this.totalQuantity = totalQuantity;
        this.portfolioId = portfolioId;
        this.price = price;
        this.totalCost = totalCost;
    }
}