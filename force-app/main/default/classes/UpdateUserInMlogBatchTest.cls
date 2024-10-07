@isTest
public with sharing class UpdateUserInMlogBatchTest {
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
            con1.Activation_Date__c=system.today();
            con1.Cell_Phone__c='Company Provide';
            con1.Reimbursement_Frequency__c='Monthly Reimbursement';
            insert con1;
        }
        Test.startTest();
        // Id batchJobId = Database.executeBatch(new UpdateUserInMlogBatchTest(), 200);
        UpdateUserInMlogBatch i = new UpdateUserInMlogBatch();
        ID jobID =Database.executeBatch(I);
        Test.stopTest();
    }
}