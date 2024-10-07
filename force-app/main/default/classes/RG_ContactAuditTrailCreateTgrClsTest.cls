@isTest
public class RG_ContactAuditTrailCreateTgrClsTest{
    public static testmethod void Testmethod1(){
    SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        Account acc = TestUtilityClass.getTestSingleAccount();
      //  Contact con1 = TestUtilityClass.getTestSingleContact(acc);
        Contact con = TestUtilityClass.getTestSingleContact(acc);
        con.Fixed_Amount__c = 10;
        con.Vehicle1Odometer__c = 10;
        con.Vehicle2Odometer__c = 10;
        con.Maintenance_and_Tires__c = 50;
        con.MailingStreet = 'test';
        con.MPG__c = 10;
        con.Role__c ='Driver';
      //  con.Manager__c = con1.Id;
        con.compliancestatus__c = 'No – Vehicle Value';
        con.Vehicle_Type__c = 'HONDA';
        List<contact> conList = new List<contact>();
        conList.add(con);
        update conList;
        RG_ContactAuditTrailCreateTgrCls.TrackHistory(conList,conList);
        RG_ContactAuditTrailCreateTgrCls.populatestaticValue(conList);
        con.compliancestatus__c = 'No – Vehicle Age';
        update con;
        con.compliancestatus__c = 'No – Vehicle Value';
        update con;
        con.Role__c ='Admin';
        update con;
        
    }
}