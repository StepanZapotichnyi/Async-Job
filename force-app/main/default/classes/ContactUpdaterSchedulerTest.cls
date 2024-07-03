@isTest
public with sharing class ContactUpdaterSchedulerTest {
    @isTest
    static void testSchedulJob() {

        Integer testNumber = 5;
        List<Account> testAccounts = TestFactory.createAccount(testNumber);
        insert testAccounts;

        List<Contact> testContacts = TestFactory.createContactToAccount(testAccounts, testNumber);
        insert testContacts;

        String CRON_EXP = '0 0 2 * * ?';


        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new ContactUpdaterScheduler());
        Test.stopTest();

        List<AsyncApexJob> apexResult = [
            SELECT 
                ApexClassId, Id,  JobType, Status,  CronTriggerId
            FROM 
                AsyncApexJob
            WHERE
                JobType in ('ScheduledApex')
        ];
        
        Assert.areEqual(1, apexResult.size(), 'There should be one scheduled job.');

        for(AsyncApexJob jobApex : apexResult) {
            Assert.areEqual(jobId, jobApex.CronTriggerId, 'The job ID should match the scheduled job ID.');
        }        

    }
}