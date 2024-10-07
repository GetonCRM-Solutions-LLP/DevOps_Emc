@isTest
public  class UpdateEighthMessageBatchScheduleTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        UpdateEighthMessageBatchSchedule sh1 = new UpdateEighthMessageBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update EighthMessage', sch, sh1); Test.stopTest(); 
    }
}