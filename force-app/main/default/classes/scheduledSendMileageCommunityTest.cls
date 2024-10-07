@istest
public class scheduledSendMileageCommunityTest {
    public static testMethod void scheduledSendMileageCommunityTestMethod() {
        Test.startTest();
        scheduledSendMileageCommunity schMailCom = new scheduledSendMileageCommunity();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schMailCom);
        Test.stopTest();
    }
}