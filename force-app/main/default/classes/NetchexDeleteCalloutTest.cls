@isTest
public class NetchexDeleteCalloutTest {
    public static testMethod Void testMethod1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NetchexDeleteMockclass());
        NetchexDeleteCallout.DeletedataFromNetchex('2020-08-14','2020-08-20',System.now());
        Test.stopTest();
    }
}