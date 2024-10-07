@isTest
public class UpdateCompliancemileageBatchTest {
    @isTest 
    public static void compliancemilTest(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        SendEmail__c sendEmailCustomSetting2 = TestDataFactory.sendEmailCustomSetting(true,'ConfirmTripTimeERMIController');
        SendEmail__c sendEmailCustomSetting3 = TestDataFactory.sendEmailCustomSetting(true,'ConfirmTripSyncErmi');
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            conList[0].Activation_Date__c = date.valueof('2022-12-01');
            update conList;

            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        Test.startTest();
        System.runAs(userObj) {
            UpdateCompliancemileageBatch comMil = new UpdateCompliancemileageBatch(); 
            Database.executeBatch(comMil);
        }
        Test.stopTest();
    }

}