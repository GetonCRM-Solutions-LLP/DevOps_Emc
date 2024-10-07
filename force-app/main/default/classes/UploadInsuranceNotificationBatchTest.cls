@isTest
public with sharing class UploadInsuranceNotificationBatchTest {
    @isTest
    public static void testMethod1(){
        TriggerConfig__c triggerConfigCustomSetting = TestDataFactory.triggerConfigCustomSetting(True);
        SendEmail__c triggerCon = TestDataFactory.sendEmailCustomSetting(True,'UploadInsuranceNotificationBatch');
        SendEmail__c triggerCon1 = TestDataFactory.sendEmailCustomSetting(True,'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehType = TestDataFactory.createVehicleData(True, 3);
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        
        Account objAcc;
         List<Contact> objadminContact;
        List<Contact> objDriverContact;
        System.runAs(admin) {
            objAcc = TestDataFactory.createAccount(True, 'Test Account', True);
            
            objadminContact = TestDataFactory.createDriverContact(True, objAcc.Id, 'Admin', vehType.Name, 'paras.dhanani', 1);
            objDriverContact = TestDataFactory.createDriverContact(False, objAcc.Id, 'Driver', vehType.Name, 'parasm.patel', 1);
            objDriverContact[0].IsCreatedFromCommunity__c = false;
            objDriverContact[0].isCommunityUser__c = false;
            objDriverContact[0].Insurance_Declaration_Status__c = 'Skip';
            objDriverContact[0].Insurance_Attachment_Id__c = null;
            objDriverContact[0].Activation_Date__c  = System.today().addDays(-5);
             system.assertEquals(1, objadminContact.size(), True);
            
            Insert objDriverContact[0];
            userObj = TestDataFactory.createUser(True, profileObj.Id, objDriverContact[0].Id);
        }
        Test.startTest(); 
        UploadInsuranceNotificationBatch uploadInsurance = new UploadInsuranceNotificationBatch();
        database.executebatch(uploadInsurance, 1);
        Test.stopTest();
    }
}