@istest
public class schMileageNotificationForDriversTest {
    public static testMethod void scheduledSendMileageDeltaTestMethod() {
      
        Test.startTest();
        scheduledMileageNotificationForDrivers schMailDelta = new scheduledMileageNotificationForDrivers();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schMailDelta);
        Test.stopTest();
    }
}