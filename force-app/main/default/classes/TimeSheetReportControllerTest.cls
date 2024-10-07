@isTest
public with sharing class TimeSheetReportControllerTest {
    public TimeSheetReportControllerTest() {

    }
    public static testmethod void test1(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        customEmailSetting.ContactTriBiReimCreate__c = false;
        insert customEmailSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        daylight_saving_time_config__c customSetting2 =  new daylight_saving_time_config__c();
        customSetting2.Name = '2022';
        customSetting2.Start_Date__c = System.today();
        customSetting2.End_Date__c = System.today() + 60;
        insert customSetting2;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        Account acc = new Account();  
        acc.Name = 'test account';
        acc.Vehicle_Types__c = veh.name;
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'U';
        acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
        acc.Pay_Period_Days__c = 13;
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = System.Label.ERMI_Account;
        contact.Vehicle_Type__c = '2019 Mileage Rate';
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Time_Zone__c = 'America/Chicago';
        contact.MailingCity = 'Abilene';
        contact.MailingState = 'TX';
        contact.Driving_States__c = 'TX';
        contact.Role__c = 'Driver';
        contact.Employee_Netchex_Id__c = 'abcsd';
        contact.Driver_Type__c = 'Driver - Full Time';
        contact.isCommunityUser__c = true;
        insert contact;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        er.month__c = '05-2020';
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        
        Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = system.today()-13 + ' to ' + system.today() ; 
            br.Contact__c = contact.Id;
            br.Start_Date__c = system.today()-13;
            br.End_Date__c = system.today() ;
            br.MPG__c = contact.MPG__c;
            br.Maintenance_and_Tires__c = contact.Maintenance_and_Tires__c;
            br.Fixed_Amount__c = contact.Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Fuel_Price__c = 0;
        Insert br;
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = contact.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.Bi_Weekly_Reimbursement__c = br.Id;
        emp.Mileage__c = 10.00;
        emp.Day_Of_Week__c = 'Mon';
        emp.Stay_Time__c = 10;
        emp.Fuel_price__c = 10.00;
        emp.Trip_Date__c = system.today()-10;
        emp.StartTime__c = system.now()-10;
        emp.EndTime__c =  system.now()-10;
        insert emp;

        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.EmployeeReimbursement__c = er.id;
        emp1.Contact_Email_Id__c = contact.External_Email__c;
        emp1.Name = 'Test Mileage Record1';
        emp1.Trip_Status__c = StaticValues.noApprovedYet;
        emp1.TimeZone__c = 'US/Mountain' ;
        emp1.Mileage__c = 102.00;
        emp1.Day_Of_Week__c = 'Mon';
        emp1.Bi_Weekly_Reimbursement__c = br.Id;
        emp1.Stay_Time__c = 15;
        emp1.Fuel_price__c = 15.00;
        emp1.Trip_Date__c = system.today()-12;
        emp1.StartTime__c = system.now()-10;
        emp1.EndTime__c =  system.now()-10;
        insert emp1;

        Test.startTest();
        Test.setCurrentPage(Page.TimeandSummaryReport);
        //String conId = ApexPages.currentPage().getParameters().put('id',contact.Id);
        String startDate = ApexPages.currentPage().getParameters().put('startDate','2020-01-22');
        String endDate = ApexPages.currentPage().getParameters().put('endDate','2020-08-22');
        TimeSheetReportController objClass = new TimeSheetReportController();
        Test.stopTest();
}
}