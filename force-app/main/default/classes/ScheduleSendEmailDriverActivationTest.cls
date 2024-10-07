@istest
public with sharing class ScheduleSendEmailDriverActivationTest {
    public static testMethod void scheduledSendMileageDeltaTestMethod() {
        Test.startTest();
        ScheduleSendEmailDriverActivation schMailDelta = new ScheduleSendEmailDriverActivation();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schMailDelta);
        Test.stopTest();
    }
}