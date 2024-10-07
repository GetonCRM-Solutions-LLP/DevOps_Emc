@isTest
public class ScheduleBiWeeklyReimCreateForErmiTest {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        ScheduleBiWeeklyReimCreateForErmi sh1 = new ScheduleBiWeeklyReimCreateForErmi();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); Test.stopTest(); 
    }
}