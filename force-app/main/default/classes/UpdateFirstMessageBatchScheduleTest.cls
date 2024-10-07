@isTest
public class UpdateFirstMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateFirstMessageBatchSchedule sh1 = new UpdateFirstMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update FirstMessage', sch, sh1); 
        Test.stopTest(); 
    }
}