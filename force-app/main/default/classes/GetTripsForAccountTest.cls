@istest
public class GetTripsForAccountTest {
    public static testMethod void GetTripsForAccountTestMethod() {
        Account a = new Account();
        a.Name = 'Test';
        a.Triplog_API__c = '123456789';
        a.Triplog_Status__c = 'U';
        insert a;
        
        Test.StartTest();
        GetTripsForAccount obj_GetTripsForAccount = new GetTripsForAccount();
        obj_GetTripsForAccount.GetTripsForAcc(a.Id, a.Triplog_Status__c);
        Test.StopTest();
    }
}