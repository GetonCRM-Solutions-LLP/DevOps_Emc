@isTest
public with sharing class UploadConcurQuickExpenseTriplogTest {
    public static testmethod void testMethod1() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate = TestDataFactory.createIRSRate(true,0);
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;

        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;

        Account acc = new Account();
        acc.Name = 'SPBS';
        acc.Enable_Email_For_Managers__c = true;
        acc.Triplog_API__c = '75b59c50cefa4f8f9c3b5e824944ffe5';
        acc.Approval_Template_Message__c = 'test message';
        acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
        acc.Pay_Period_Days__c = 6;
        insert acc;

        List<Contact> contLst = TestDataFactory.createDriverContact(false,acc.Id,'Driver/Admin','2019 Full-Size Vehicle','testdataContact',1);
        Contact cont=contLst[0];
        cont.LastName = 'TestdataContact';
        cont.AccountId = acc.Id;
        cont.Fixed_Amount__c = 371.28;
        cont.MailingCity = 'Abilene';
        cont.MailingState = 'TX';
        cont.Driving_States__c = 'TX';
        cont.Monthly_Mileage_Limit__c = 100.00;
        insert cont;
        
        String lastMonth = Utils.fetchMonths(1, 0)[0]; 
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = cont.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = lastMonth;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;

        UploadConcurQuickExpenseTriplog.postTotalReimbursement(acc.Id,er.Month__c, cont.External_Email__c, String.valueOf(er.Total_Mileage__c));
        UploadConcurQuickExpenseTriplog.postTotalReimbursementForAllUser(acc.Id);
    }
}