public with sharing class ContactUpdaterScheduler implements Schedulable{
    
    public void execute(SchedulableContext sch) {
        Database.executeBatch(new ContactFieldsUpdater());
    }
}