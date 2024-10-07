@isTest
public class HelloSignGetSignedDocumentBatchTest {
    @TestSetup static void setupmethod(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Hello_Sign__c helloCustom  = TestDataFactory.helloSignCustomSetting(true);
        TriggerConfig__c customSetting = TestDataFactory.triggerConfigCustomSetting(false);
        customSetting.Name = 'Defaulttrigger';
        customSetting.mileageremoveapprovaldate__c = false;
        customSetting.MappingGasPriceTrigger__c = false;
        customSetting.MappingGasPriceTriggerUpdateConvertedDat__c = false;
        insert customSetting;
        
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
        List<Contact> conList;
        List<Contact> con1List;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(false,'Test Account',true);
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            acc.Enable_Email_For_Managers__c = true;
            acc.Approval_Template_Message__c = 'test message';
            Insert acc;
            
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Manager', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Deactivated_Date__c = Date.today().addMonths(4);
            conList[0].Hello_Sign_Status__c = 'awaiting_signature';
            Insert conList[0];
            
            system.assertEquals(1, conList.size(), true);
            userObj = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profileObj.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contactObj.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert userObj;
        }  
    }
    public static testmethod void test1() {
        HelloSignGetSignedDocumentBatch obj = new HelloSignGetSignedDocumentBatch();
        Database.executeBatch(obj);
    }
}