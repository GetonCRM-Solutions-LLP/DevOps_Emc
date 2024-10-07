@isTest
public class UpdateFifthMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateFifthMessageBatchSchedule sh1 = new UpdateFifthMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update FifthMessage', sch, sh1); Test.stopTest(); 
    }
}