@istest
public with sharing class SendActivaitonEmailToDriverTest {
    public static testmethod void testMethod4(){
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'SendActivaitonEmailToDriver';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        SendEmailToMe__c  objSendEmailToMe = new SendEmailToMe__c();
        objSendEmailToMe.Name = 'SendActivaitonEmailToDriver';
        objSendEmailToMe.Send_email_to_me__c = true;
        insert objSendEmailToMe;

        Account acc = TestUtilityClass.getTestSingleAccount();
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093359.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Contact con = RecordUtilityClass.buildAdminContact(acc);
        con.Role__c = 'Driver';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.Time_Zone__c = 'US/Mountain' ;
        insert con;
       
        SendActivaitonEmailToDriver mil = new SendActivaitonEmailToDriver();
         Database.executeBatch(mil, 1);
    }
}