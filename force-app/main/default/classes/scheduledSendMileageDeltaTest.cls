@istest
public class scheduledSendMileageDeltaTest {
    public static testMethod void scheduledSendMileageDeltaTestMethod() {
    	Account account = new  Account(name = 'Delta');
        insert account;

        Contact contact = new  Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        contact.Role__c = 'Driver';
        contact.External_Email__c = 'manageremail.com@test.com';
        insert contact;

        Test.startTest();
        scheduledSendMileageDelta schMailDelta = new scheduledSendMileageDelta();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schMailDelta);
        Test.stopTest();
    }
}