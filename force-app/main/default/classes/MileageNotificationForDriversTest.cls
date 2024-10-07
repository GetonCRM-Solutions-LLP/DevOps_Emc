@isTest
public class MileageNotificationForDriversTest {
    public static testmethod void test() {
        SendEmail__c  customEmailSetting =  new SendEmail__c ();
        customEmailSetting.Name = 'SendMileageReminderforDelta';
        customEmailSetting.Send_email_from_code__c= false;
        insert customEmailSetting;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;

        
        TriggerConfig__c customEmailSetting1 =  new TriggerConfig__c();
        customEmailSetting1.Name = 'Defaulttrigger';
        customEmailSetting1.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting1;
        
        SendEmailonDeactivation__c objCustom = new SendEmailonDeactivation__c();
        objCustom.Name = 'SendMileageReminderforDelta';        
        objCustom.BCCEmailaddresses__c = 'test@gmail.com';
        objCustom.Send_to_Driver__c = true;
        insert objCustom;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;

        Account acc = new Account();
        acc.Name = 'SPBS';
        acc.Enable_Email_For_Managers__c = true;
        acc.Triplog_API__c = 'slkjhgfdsnbvcxuytrew';
        acc.Approval_Template_Message__c = 'test message';
        insert acc;

        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'TestdataContact';
        cont.AccountId = acc.Id;
        cont.External_Email__c = 'testd@email.com';
        cont.Fixed_Amount__c = 371.28;
        cont.MailingCity = 'Abilene';
        cont.MailingState = 'TX';
        cont.Driving_States__c = 'TX';
        cont.Time_Zone__c = 'America/Chicago';
        cont.Monthly_Mileage_Limit__c = 100.00;
        cont.Role__c = 'Driver/Admin';
        cont.Driver_Type__c = 'Driver - Salary';
        cont.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont;
        
        Contact cont1 = new Contact();
        cont1.FirstName = 'teste';
        cont1.LastName = 'Testdat1aContact';
        cont1.AccountId = acc.Id;
        cont1.External_Email__c = 'tes1td@email.com';
        cont1.Fixed_Amount__c = 371.28;
        cont1.MailingCity = 'Abilene';
        cont1.MailingState = 'TX';
        cont1.Driving_States__c = 'TX';
        cont1.Time_Zone__c = 'America/Chicago';
        cont1.Monthly_Mileage_Limit__c = 100.00;
        cont1.Role__c = 'Driver/Admin';
        cont1.Driver_Type__c = 'Driver - Full Time';
        cont1.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont1;
      
        MileageNotificationForDrivers objBatch = new MileageNotificationForDrivers();
        Database.executeBatch(objBatch);
    }
}