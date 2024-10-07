@isTest
public with sharing class ScheduleCreateReimMonthlyTest {
    public static testmethod void reimburMethod1() {
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_1 = new IRS_Mileage_Rate__c();
        obj_IRS_Mileage_Rate_1.year__c='2021';
        obj_IRS_Mileage_Rate_1.IRS_Rate__c =0.578;
        insert obj_IRS_Mileage_Rate_1;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        Account acc = new Account();
        acc.Name = 'Anton Paar';
        acc.Triplog_API__c = 'test1';
        acc.IsUsingTriplog__c = true;
        acc.Motor_Vehicle_Record_Check_Document__c = true;
        insert acc;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Contact con1 = new Contact();
        con1.LastName = 'testsdfsdfs';
        con1.Triplog_UserID__c = 'test';
        con1.isCommunityUser__c = true;
        con1.External_Email__c = 'test.patel143478@gmail.com';
        con1.IsDeactivated__c = false;
        con1.AccountId = acc.Id;
        con1.Employee_ID__c = 'eid';
        con1.Role__c = 'Manager';
        con1.compliancestatus__c = 'Yes';
        con1.Vehicle_Type__c = '2019 Full-Size Sedan';
        insert con1;  

        Contact conList = new Contact();
        conList.FirstName = 'testFn';
        conList.LastName = 'testLn';
        conList.accountid = acc.id;
        conList.MPG__c = 5;
        conList.Maintenance_and_Tires__c = 3;
        conList.Triplog_UserID__c = con1.Triplog_UserID__c;
        conList.External_Email__c = 'test_Managr101@test99.com';
        conList.Manager__c = con1.Id;
        conList.Fixed_Amount__c = 20;
        conList.Vehicle1Odometer__c = 10;
        conList.isCommunityUser__c = true;
        conList.MailingStreet = 'denverstreet';
        conList.MailingCity = 'Denver';
        conList.MailingState = 'CA';
        conList.MailingPostalCode = '110085';
        conList.MailingCountry = 'US';
        conList.compliancestatus__c = 'Yes';
        conList.Vehicle_Type__c = '2019 Full-Size Sedan';
        conList.Role__c = 'Driver';
        conList.Activation_Date__c = System.today()- 3;
        conList.Monthly_Mileage_Limit__c = 100;
        insert conList;

        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Denver';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-1);
        gasprice.State__c = 'CA';
        insert gasprice;
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = conList.Id;
        er.month__c = lastMonth;
        er.Name = conList.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = gasprice.Fuel_Price__c;
        er.MPG__c = conList.MPG__c;
        er.IRS_Mileage_Rate__c = obj_IRS_Mileage_Rate_1.id;
        er.Maintenance_and_Tires__c = conList.Maintenance_and_Tires__c;
        er.Fixed_Amount__c = conList.Fixed_Amount__c;
        er.Triplog_Status__c = 'U';
        
        insert er;

        Test.startTest();
        // ScheduleMonthlyReimEmailCNCA schBt  = new ScheduleMonthlyReimEmailCNCA();
        // String sch = '0 0 0 18 * ?';
        ScheduleCreateReimMonthly abc = new ScheduleCreateReimMonthly(); 
        abc.createReim();
        Test.stopTest();
    }
}