trigger PortfolioCurrencyTrigger on Portfolio_Currency__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        PortfolioCurrencyTriggerHandler.handleToUpdatePortfolioCurrencyName(Trigger.new);
    }
}