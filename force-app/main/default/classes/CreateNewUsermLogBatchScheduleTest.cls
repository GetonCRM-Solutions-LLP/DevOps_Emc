@isTest
Global class CreateNewUsermLogBatchScheduleTest {
	   public static testMethod void testschedule() {
        
        Test.StartTest();
        CreateNewUsermLogBatchSchedule sh1 = new CreateNewUsermLogBatchSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest(); 
    }
}