@isTest
public class TriplogAppVersionUpdateBatchTest {
       @isTest static void myUnitTest() {
        
        //Insert Custom setting data
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
       // vehicleType.Name = '2019 Full-Size Sedan';
        //vehicleType.vehicle__c = 'Full-Size Sedan';
        //insert vehicleType;
           Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {           
           
            acc = TestDataFactory.createAccount(true,'Delta',true);
             Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        } 
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TriplogUserIdUpdateBatchTestMock());
            TriplogAppVersionUpdateBatch batchobj = new TriplogAppVersionUpdateBatch();
            TriplogAppVersionUpdateBatch.getTripIds(acc.Triplog_API__c);  
            batchobj.responseOfAPICall = TriplogAppVersionUpdateBatch.getTripIds(acc.Triplog_API__c);           
            Database.executeBatch(batchobj,1);
        Test.StopTest();
    }
}