@isTest
public with sharing class UpdateNotesAndTagsInMlogTest {
    @isTest
    public static void updateActivityStatusTest(){
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRate = TestDataFactory.createIRSRate(true,2023);

        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Atlanta';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-12);
        gasprice.State__c = 'AK';
        insert gasprice;

        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        Account acc;
        Contact con1 = new Contact();

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Name = 'Test Accounts';
            acc.isUsingTriplog__c = true;
            acc.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
            insert acc;

            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = acc.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = veh.Name;
            con1.MailingCity = 'Abilene';
            con1.MailingState = 'TX';
            con1.Time_Zone__c = 'US/Mountain' ;
            con1.Driving_States__c = 'TX';
            con1.Employee_ID__c = '234343456';
            con1.Triplog_UserID__c = '20001884';
            insert con1;
        }

        String monthName = '01-2023';
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con1.Id;
        er.Name = con1.Name + ':' + monthName;
        er.Month__c = monthName;
        er.Fuel_Price__c = 6.78;
        er.MPG__c = 14.00;
        er.Status__c = 'Approved';
        er.Approved_Date__c = System.today();
        er.Prev_Approved_Date_Value__c = er.Approved_Date__c;
        er.Prev_Status_Value__c = er.Status__c;
        er.Mileage_Lock_Date__c = null;
        insert er;

        Bi_Weekly_Reimbursement__c biReim = new Bi_Weekly_Reimbursement__c();
        bireim.Approved_Date__c = system.today().addDays(-1);
        bireim.Status__c = 'Pending';
        bireim.Name = '07/25/2021 to 08/07/2021';
        bireim.Start_Date__c = Date.parse('07/25/2021');
        bireim.End_Date__c = Date.parse('08/07/2021');
        bireim.Contact__c = con1.id;
        insert bireim;

        Employee_Mileage__c empMileage = new Employee_Mileage__c();
            empMileage.Name = 'Test Mileage ';
            empMileage.Contact_Email_Id__c = 'parasdhanani@gmail.com';
            empMileage.EmployeeReimbursement__c = er.Id;
            empMileage.Trip_Date__c = system.today();
            empMileage.Bi_Weekly_Reimbursement__c = biReim.Id;
            empMileage.Activity__c =  'Business';
            empMileage.Mileage__c =  51.20;
            empMileage.Fuel_price__c =  3.21;
            empMileage.Day_Of_Week__c = 'Tuesday';
            empMileage.MPG__c =  24.30;
            empMileage.TimeZone__c = 'US/Mountain' ;
            empMileage.Origin_Name__c = 'Test Origin ' ;
            empMileage.Trip_Destination__c = 'Test Destination ';
            // empMileage.Trip_Status__c = StaticValues.noApprovedYet;
            empMileage.Approved_Date__c = null;
            empMileage.Tag__c = 'Admin';
            empMileage.Rejected__c = false;
            empMileage.Trip_Id__c  = 143576 ;
            empMileage.StartTime__c = System.today()-1;
            empMileage.EndTime__c = System.today();
            empMileage.Notes__c='new note added';
            insert empMileage;
            List<String> mileId = new List<String>{empMileage.Id};
            UpdateNotesAndTagsInMlog.changedNotesAndTags(mileId);

    }
}