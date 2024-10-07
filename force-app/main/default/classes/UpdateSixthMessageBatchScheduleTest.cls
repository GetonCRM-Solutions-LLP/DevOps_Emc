@isTest
public class UpdateSixthMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateSixthMessageBatchSchedule sh1 = new UpdateSixthMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update SixthMessage', sch, sh1); Test.stopTest(); 
    }
}