@isTest
public with sharing class UpdateTripIdControllerTest {
   static testmethod void myUnitTest() {
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
            insert acc;

            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = acc.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2023 Mileage Rate';
            con1.Employee_ID__c = '234343456';

            con1.Time_Zone__c = 'US/Mountain';
            con1.Driver_Type__c = 'Driver - Full Time';
            con1.Deactivated_Date__c = null;
            con1.Insurance_Attachment_Id__c = Null; 
            con1.compliancestatus__c = 'Yes';
            con1.ReimbursementStatementBatch__c = true;            
            con1.Manager__c = null;   
            con1.Monthly_Mileage_Limit__c = -1;  
            con1.MailingState = 'AK';
            con1.MailingCity = 'Atlanta';
            con1.Activation_Date__c = System.today()-12;
            insert con1;
        }
        
		PageReference pageRef = Page.UpdateTripId;	
		
		pageRef.getParameters().put('Id',String.valueOf(acc.Id)); 
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.standardController(acc);		
		UpdateTripIdController udpateTrip = new UpdateTripIdController(sc);
        udpateTrip.backMethod();
        udpateTrip.tripUserUpdatebatch();
		udpateTrip.tripUserUpdatebatchNew();
        
   }
   static testmethod void myUnitTest2() {
        
       

        //Insert Custom setting data
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

         //Insert Account data Using Utility class
        List<Account> accList = new List<Account>();
       
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Name = 'Test Accounts';
            acc.isUsingTriplog__c = true;
            insert acc;
            accList.add(acc);

            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = acc.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2023 Mileage Rate';
            con1.Employee_ID__c = '234343456';

            con1.Time_Zone__c = 'US/Mountain';
            con1.Driver_Type__c = 'Driver - Full Time';
            con1.Deactivated_Date__c = null;
            con1.Insurance_Attachment_Id__c = Null; 
            con1.compliancestatus__c = 'Yes';
            con1.ReimbursementStatementBatch__c = true;            
            con1.Manager__c = null;   
            con1.Monthly_Mileage_Limit__c = -1;  
            con1.MailingState = 'AK';
            con1.MailingCity = 'Atlanta';
            con1.Activation_Date__c = System.today()-12;
            insert con1;
        }
		
        Test.SetMock(HttpCalloutMock.class, new TriplogUserIdUpdateBatchTestMock());   
        
		PageReference pageRef = Page.UpdateTripId;	
		
		pageRef.getParameters().put('Id',String.valueOf(accList[0].Id)); 
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.standardController(accList[0]);		
		UpdateTripIdController udpateTrip = new UpdateTripIdController(sc);
        udpateTrip.backMethod();
       	udpateTrip.tripUserUpdatebatchNew();
       
   }
}