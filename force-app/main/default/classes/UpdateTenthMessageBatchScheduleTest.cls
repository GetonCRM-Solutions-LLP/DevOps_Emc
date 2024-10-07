@isTest
public class UpdateTenthMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateTenthMessageBatchSchedule sh1 = new UpdateTenthMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update TenthMessage', sch, sh1); Test.stopTest(); 
    }
}