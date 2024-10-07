@isTest
public class UpdateSeventhMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateSeventhMessageBatchSchedule sh1 = new UpdateSeventhMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update SeventhMessage', sch, sh1); Test.stopTest(); 
    }
}