public with sharing class ContactUpdaterScheduler implements Schedulable{
    
    public void execute(SchedulableContext sch) {
        System.debug('error');
        Database.executeBatch(new ContactFieldsUpdater());
    }
}