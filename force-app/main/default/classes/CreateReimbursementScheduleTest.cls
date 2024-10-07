@istest
public class CreateReimbursementScheduleTest {
    public static testmethod void testMethod1(){    
        Test.startTest();
        CreateReimbursementSchedule schBt = new CreateReimbursementSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schBt);
        Test.stopTest();
        
    }
}