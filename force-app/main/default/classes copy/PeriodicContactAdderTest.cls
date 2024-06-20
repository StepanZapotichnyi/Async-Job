@isTest
public with sharing class PeriodicContactAdderTest {
    @isTest
    static void testSchedulJobPositive() {

        Integer testNumber = 5;
        List<Account> testAccounts = TestFactory.createAccount(testNumber);
        insert testAccounts;

        List<Contact> testContacts = TestFactory.createContactToAccount(testAccounts, testNumber);
        insert testContacts;

        List<String> testCrone = TestFactory.createTestCrone(testNumber);

        List<Id> testIds = new List<Id>();
        for (Account acc : testAccounts) {
            testIds.add(acc.Id);
        }

        Test.startTest();
        PeriodicContactAdder.schedulJob(testIds, testNumber);
        Test.stopTest();


        List<AsyncApexJob> apexResult = [
            SELECT 
                ApexClassId, Id,  JobType,Status 
            FROM 
                AsyncApexJob
            Where 
                JobType in ('ScheduledApex')
        ];

        Assert.areEqual(testCrone.size(), apexResult.size(),'The quantity crones must match with ids');

    }

    @IsTest
    static void testSchedulJobNegative() {
        
        Integer testNumber = 61;
        String testErrorMessage = 'Interval of job is incorrect. Please set the interval less than 60 or equal to 1 minutes';
        List<Account> testAccounts = TestFactory.createAccount(testNumber);
        insert testAccounts;

        List<Id> testIds = new List<Id>();
        for (Account acc : testAccounts) {
            testIds.add(acc.Id);
        }

        try{
            Test.startTest();
            PeriodicContactAdder.schedulJob(testIds, testNumber);
            Test.stopTest(); 
        } catch (PeriodicContactAdder.PeriodicContactAdderException e){
            Assert.areEqual(testErrorMessage, e.getMessage(), 'Thrown error message should be the same as in response');
        }

    }

}