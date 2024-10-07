@istest
public class ScheduleHelloSignGetSignedDocumentTest {
    public static testMethod void scheduledGetTripBatchTestMethod() {
        Test.startTest();
        ScheduleHelloSignGetSignedDocumentBatch schBt = new ScheduleHelloSignGetSignedDocumentBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schBt);
        Test.stopTest();
    }
}