@istest
public class scheduledGetTripBatchTest {
    public static testMethod void scheduledGetTripBatchTestMethod() {
        Test.startTest();
        scheduledGetTripBatch schBt = new scheduledGetTripBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schBt);
        Test.stopTest();
    }
}