@isTest 
Public class UpdateUserIdandAppVertionBatchTest {
       @isTest 
       Public static void myUnitTest() {
      
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        List<Contact> adminConList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test', 1);
            conList[0].External_Email__c = 'test@gmail.com';
            conList[0].Email = 'test@gmail.com';
            update conList;

            adminConList = TestDataFactory.createDriverContact(true, acc.Id, 'Admin', vehicleObj.Name, 'test1.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }  
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TriplogUserIdUpdateBatchTestMock());
        
        UpdateUserIdandAppVertionBatch batchobj = new UpdateUserIdandAppVertionBatch(acc.Id); 
        UpdateUserIdandAppVertionBatch.getTripIds(acc.Triplog_API__c); 
        batchobj.responseOfAPICall = UpdateUserIdandAppVertionBatch.getTripIds(acc.Triplog_API__c);  
         
        Database.executeBatch(batchobj);
        Test.StopTest(); 
   }
}