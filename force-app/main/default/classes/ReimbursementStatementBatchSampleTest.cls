@isTest
public with sharing class ReimbursementStatementBatchSampleTest{
     public static testmethod void method1(){

       
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;

        SendEmailonDeactivation__c objSendEmail = new SendEmailonDeactivation__c();
        objSendEmail.Name ='YearToDateReimbursementStatement'; //YearToDateReimbursementStatement
        objSendEmail.BCCEmailaddresses__c = 'tezt@gmail.com';
        objSendEmail.Send_to_Driver__c = true;
        insert objSendEmail;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;

        Account obj_Account = new Account();
        obj_Account.name='Delta';
        insert obj_Account;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        List<Contact> conList = new List<Contact>();
        Contact co = new Contact();
        co.FirstName = 'Test';
        co.LastName = 'Contact Admin';
        co.AccountId = obj_Account.Id;
        co.MailingStreet = 'Test Street';
        co.MailingCity = 'Test City';
        co.MailingState = 'ON';
        co.MailingPostalCode = '123';
        co.MailingCountry = 'CA';
        co.Phone = '1232434445';
        co.External_Email__c = 'minkesh.patelmanager01@gmail.com';
        co.Deactivated_Date__c = null;
        co.IsCommunityUser__c = true;        
        co.Role__c = 'Admin';
        co.Monthly_Mileage_Limit__c = 210;
        co.Vehicle_Type__c = '2019 Full-Size Sedan';
        //insert co;
        conList.add(co);

        Contact co1 = new Contact();
        co1.FirstName = 'Test1';
        co1.LastName = 'Contact Admin1';
        co1.AccountId = obj_Account.Id;
        co1.MailingStreet = 'Test Street1';
        co1.MailingCity = 'Test City';
        co1.MailingState = 'ON';
        co1.MailingPostalCode = '123';
        co1.MailingCountry = 'CA';
        co1.Phone = '1232434445';
        co1.External_Email__c = 'minkesh.patelmanager011@gmail.com';
        co1.Deactivated_Date__c = null;
        co1.IsCommunityUser__c = true;        
        co1.Role__c = 'Driver';
        co1.Monthly_Mileage_Limit__c = 210;
        co1.Vehicle_Type__c = '2019 Full-Size Sedan';
        //insert co1;
        conList.add(co1);
        insert conList;

        //List<Employee_Reimbursement__c> empRemList = new List<Employee_Reimbursement__c>();
        Employee_Reimbursement__c empRem1 = TestUtilityClass.getTestEmployeeReimbursement2(conList[0]);
       // empRemList.add(empRem1);
        Employee_Reimbursement__c empRem2 = TestUtilityClass.getTestEmployeeReimbursement2(conList[1]);
        //empRemList.add(empRem2);
        //Employee_Reimbursement__c empRem3 = TestUtilityClass.getTestEmployeeReimbursement2(conList[1]);
        //empRemList.add(empRem3);
        
        ReimbursementStatementBatchSample objbatch = new ReimbursementStatementBatchSample();
        Database.executeBatch(objbatch,1);
    }
}