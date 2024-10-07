/********************************************************
Description: Test class for SendMonthlyYTCAdminSchedule
*********************************************************/
@isTest
public class SendMonthlyYTCAdminScheduleTest {
    static testmethod void  SendMonthlyYTCAdmintestschedule() {
        Test.StartTest();
        SendMonthlyYTCAdminSchedule sh1 = new SendMonthlyYTCAdminSchedule();      
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();
    }
}