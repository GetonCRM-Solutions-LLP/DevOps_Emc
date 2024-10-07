@isTest
public class CreateNewBiweeklyReimScheduleTest {
	public static testMethod void testschedule() {
        
        Test.StartTest();
     	//Account accountObj = TestDataFactory.createAccount(true,'Test',true);       
         CreateNewBiweeklyReimSchedule sh1 = new CreateNewBiweeklyReimSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); Test.stopTest();
    }
}