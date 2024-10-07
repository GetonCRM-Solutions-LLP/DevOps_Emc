@isTest

public class TriplogUserIdUpdateBatchTest {
       @isTest static void myUnitTest() {
        
        //Insert Custom setting data
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
       
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            
            acc = TestDataFactory.createAccount(true,'Test Accounts',false);
        Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
        //Insert Contact data 
        Contact con = new Contact();
        con.FirstName = 'Test1';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'USA';
        con.Phone = '1232434445';
        con.External_Email__c = 'test@gmail.com';
        con.Deactivated_Date__c = null;
        con.Triplog_UserID__c = null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c = 100;
        con.IsCreatedFromCommunity__c = true; 
        con.Vehicle_Type__c  = vehicleType.Name;
        insert con;

        contact con2 = new contact();
        con2.FirstName = 'Test';
        con2.LastName = 'contact2';
        con2.AccountId = acc.Id;
        con2.MailingStreet = 'Test Street';
        con2.MailingCity = 'Test City';
        con2.MailingState = 'ON';
        con2.MailingPostalCode = '123';
        con2.MailingCountry = 'USA';
        con2.Phone = '1232434445';
        con2.External_Email__c = 'test2@gmail.com';
        con2.Deactivated_Date__c = null;
        con2.Triplog_UserID__c = null;
        con2.isCommunityUser__c = True;
        con2.Role__c = 'Driver';
        con2.Monthly_Mileage_Limit__c = 100;
        con2.IsCreatedFromCommunity__c = true; 
        con2.Vehicle_Type__c  = vehicleType.Name;
        insert con2;
        
        conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'test.email', 1);
        userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        Map<String,Contact> contactMap = new Map<String,Contact>();
        for(Contact currentContact : [Select id,Name,FirstName,Triplog_UserID__c,External_Email__c,Deactivated_Date__c From Contact Where Account.id =: acc.Id])
        {
            contactMap.put(currentContact.External_Email__c.toLowerCase(),currentContact);
        }
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TriplogUserIdUpdateBatchTestMock());
        TriplogUserIdUpdateBatch batchobj = new TriplogUserIdUpdateBatch(acc.Id,acc.Triplog_API__c,contactMap);
        TriplogUserIdUpdateBatch.getTripIds(acc.Triplog_API__c);  
        batchobj.responseOfAPICall = TriplogUserIdUpdateBatch.getTripIds(acc.Triplog_API__c);  
         
        Database.executeBatch(batchobj,10);
        Test.StopTest();
   }
}