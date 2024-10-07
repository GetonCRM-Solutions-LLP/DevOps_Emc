@isTest
public class SetFileVisibilityTest {
    @istest
     static void setupmethod(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Hello_Sign__c helloCustom  = TestDataFactory.helloSignCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2019 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;

        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;
        List<Contact> con2List;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(false,'Test Account',true);
            acc.Enable_Email_For_Managers__c = true;
            acc.Approval_Template_Message__c = 'test message';
            insert acc;        
            con2List = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            con2List[0].IsCreatedFromCommunity__c = true;
            insert con2List;
            userObj = TestDataFactory.createUser(true,profileObj.Id,contactObj.Id);
        }

        ContentVersion versionObj = new ContentVersion();
        versionObj.versionData = Blob.valueOf('Some Text');
        versionObj.title = 'Driver Agreement';
        versionObj.pathOnClient ='Driver Agreement.pdf';
        versionObj.FirstPublishLocationId = con2List[0].Id; 
        insert versionObj;   
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:versionObj.Id].ContentDocumentId;
        Test.startTest();
          System.runAs(userObj) {
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = acc.id;
            contentlink.ShareType= 'V';
            contentlink.ContentDocumentId = conDocId ;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;  
          }         
         Test.stopTest();
    } 
}