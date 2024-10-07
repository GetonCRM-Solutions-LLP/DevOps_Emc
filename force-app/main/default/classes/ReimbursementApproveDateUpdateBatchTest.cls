@isTest
public class ReimbursementApproveDateUpdateBatchTest {
    public static testmethod void reimburMethod1() {
        SendEmail__c  objSendEmail = new SendEmail__c();
        objSendEmail.Name = 'Send Email For Compliance';
        objSendEmail.Send_email_from_code__c = false;
        insert objSendEmail;

        TriggerConfig__c customSetting = new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        Account acc = new Account();
        acc.Name = 'test';
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
        con1.Deactivated_Date__c =  system.now()-35;
        con1.isCommunityUser__c = true;
        con1.External_Email__c = 'test.patel143478@gmail.com';
        con1.IsDeactivated__c = false;
        con1.AccountId = acc.Id;
        con1.Employee_ID__c = 'eid';
        con1.Role__c = 'Manager';
        con1.Vehicle_Type__c = '2019 Full-Size Sedan';
        insert con1;  

        Contact conList = new Contact();
        conList.FirstName = 'testFn';
        conList.LastName = 'testLn';
        conList.accountid = acc.id;
        conList.MPG__c = 5;
        conList.Maintenance_and_Tires__c = 3;
        conList.Triplog_UserID__c = con1.Triplog_UserID__c;
        conList.Deactivated_Date__c = con1.Deactivated_Date__c;
        conList.External_Email__c = 'test_Managr101@test99.com';
        conList.IsDeactivated__c = con1.IsDeactivated__c;
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
        conList.Monthly_Mileage_Limit__c = 100;
        insert conList;

/*
        conList.Deactivated_Date__c = System.today();
        update conList;*/

        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Denver';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-1);
        gasprice.State__c = 'CA';
        insert gasprice;

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = conList.Id;
        er.month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = conList.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = gasprice.Fuel_Price__c;
        er.MPG__c = conList.MPG__c;
        er.Maintenance_and_Tires__c = conList.Maintenance_and_Tires__c;
        er.Fixed_Amount__c = conList.Fixed_Amount__c;
        er.Triplog_Status__c = 'U';
        
        insert er;
        
        Test.startTest();
        ReimbursementApproveDateUpdateBatch batchcon = new ReimbursementApproveDateUpdateBatch();
        DataBase.executeBatch(batchcon, 50);
        Test.stopTest();

    }

}