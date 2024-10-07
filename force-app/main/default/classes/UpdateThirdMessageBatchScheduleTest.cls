@isTest
public class UpdateThirdMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateThirdMessageBatchSchedule sh1 = new UpdateThirdMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update ThirdMessage', sch, sh1); Test.stopTest(); 
    }
}