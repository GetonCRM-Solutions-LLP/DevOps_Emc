@isTest
public class UpdateForthMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateForthMessageBatchSchedule sh1 = new UpdateForthMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update ForthMessage', sch, sh1); 
        Test.stopTest(); 
    }
}