trigger AccountTrigger on Account (before update, after update) {

    if(Trigger.isAfter && Trigger.isUpdate) {
            AccountTriggerHandler.updateAccounts(Trigger.new, Trigger.oldMap);
    
    }   
}