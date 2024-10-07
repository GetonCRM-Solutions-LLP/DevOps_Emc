/*************************************************************************************************
Description:     Test class for SendMonthlyYTCAdmin class
Functionality:   For send Mail to YTC Admin where employee user name not equal to yokohomatire.com
*************************************************************************************************/
@isTest
public class SendMonthlyYTCAdminTest {
    public static testMethod Void SendMonthlyYTCAdminTestMethod() {
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'SendMonthlyYTCAdmin';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        Account acc = new Account();           
        acc.Name = 'YTC (Yokohama Tire Corporation)';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'U';
        insert Acc;
           
        Contact c = new Contact();
        c.lastname = 'Test Contact for test';
        c.AccountId = acc.Id;
        c.External_Email__c = 'testting@yokohamatire.com';
        c.Role__c = 'Driver';
        c.Send_Monthly_YTC_Admin__c = true;
        insert c;
        
        Contact con = new Contact();
        con.lastname = 'Test Contact for testing';
        con.AccountId = acc.Id;
        con.External_Email__c = 'test.test@yokohamatire.com';
        con.Role__c = 'Admin';
        con.Send_Monthly_YTC_Admin__c = true;
        insert con;
        
        Test.startTest();
        SendMonthlyYTCAdmin sendToAdmin = new SendMonthlyYTCAdmin();
        sendToAdmin.sendMailAdim();
        Test.stopTest();
    }
}