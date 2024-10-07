@isTest
public class HelloSignIntegrationHandlerTest {
    @TestSetup static void setupmethod(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Hello_Sign__c helloCustom  = TestDataFactory.helloSignCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        vehicleType.Name = '2020 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);

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
            acc.Vehicle_Types__c = '2020 Full-Size Sedan';
            acc.Hello_Sign_Admin_Sign__c = true;
            insert acc;        
            con2List = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            
            userObj = TestDataFactory.createUser(true,profileObj.Id,contactObj.Id);
        }

        ContentVersion versionObj = new ContentVersion();
        versionObj.versionData = Blob.valueOf('Some Text');
        versionObj.title = 'Driver Agreement';
        versionObj.pathOnClient ='Driver Agreement.pdf';
        versionObj.FirstPublishLocationId = con2List[0].Id; 
        insert versionObj;        
        Set<String> newUserEmailSet = new Set<String>();
        newUserEmailSet.add(con2List[0].External_Email__c);
        HelloSignIntegrationHandler.sendSignatureRequestForDriver(newUserEmailSet);
    }
    public static testmethod void test1() {
        Vehicle_URL_Mapping__c vum = [select id from Vehicle_URL_Mapping__c limit 1];
    }   
}