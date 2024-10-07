@isTest public class UpdateComplianceMileageschedullerTest {
    @isTest
    public static void testschedule() {
        Test.StartTest();
        UpdateComplianceMileagescheduller sh1 = new UpdateComplianceMileagescheduller();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
}