@isTest
public class CreateBiweeklyReimScheduleTest {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        CreateBiweeklyReimSchedule sh1 = new CreateBiweeklyReimSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); Test.stopTest(); 
    }
}