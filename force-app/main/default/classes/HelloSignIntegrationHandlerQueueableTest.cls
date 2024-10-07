@isTest
public class HelloSignIntegrationHandlerQueueableTest {
   @isTest
   public static void test1(){
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
            con2List = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            con2List[0].Email = 'abcTest@mailinator.com';
            insert con2List;
            
            userObj = TestDataFactory.createUser(true,profileObj.Id,contactObj.Id);
        }

        HelloSignIntegrationHandlerQueueable helloSign = new HelloSignIntegrationHandlerQueueable(con2List[0].Email);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HelloSignCalloutMock());
        System.enqueueJob(helloSign);
        Test.stopTest();
   }
}