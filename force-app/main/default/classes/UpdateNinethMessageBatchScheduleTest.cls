@isTest
public class UpdateNinethMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateNinethMessageBatchSchedule sh1 = new UpdateNinethMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update NinethMessage', sch, sh1); Test.stopTest(); 
    }
}