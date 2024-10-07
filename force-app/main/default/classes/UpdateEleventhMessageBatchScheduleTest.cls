@isTest
public class UpdateEleventhMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateEleventhMessageBatchSchedule sh1 = new UpdateEleventhMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update EleventhMessage', sch, sh1); 
        Test.stopTest(); 
    }
}