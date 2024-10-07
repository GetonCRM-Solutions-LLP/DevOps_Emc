@isTest
public class SendMileageReminderForDelta_Test {
   @isTest
    public static  void testSendMileageReminderForDelta() {
        // Set up test data
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.Vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        SendEmail__c sendEmailSetting = new SendEmail__c();
        sendEmailSetting.Name = 'SendMileageReminderforDelta';
        sendEmailSetting.Send_email_from_code__c = true;
        insert sendEmailSetting;

        SendEmailonDeactivation__c customSetting = new SendEmailonDeactivation__c();
        customSetting.Name = 'SendMileageReminderforDelta';
        customSetting.Send_to_Driver__c = true;
        insert customSetting;

        TriggerConfig__c triggerConfig = new TriggerConfig__c();
        triggerConfig.Name = 'Defaulttrigger';
        triggerConfig.MappingGasPriceTrigger__c = true;
        insert triggerConfig;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);

        // Insert Account and Contact data
        Account acc;
        List<Contact> conList;

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false, 'Test Account', true);
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 6;
            insert acc;

            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', veh.Name, 'JohnDoe', 1);
            conList[0].Deactivated_Date__c = null;
            conList[0].Vehicle_Type__c = '2019 Full-Size Sedan';
            insert conList[0];
        }

        Test.startTest();
        // Test default constructor
        SendMileageReminderForDelta defaultBatch = new SendMileageReminderForDelta();
        Database.executeBatch(defaultBatch, 1);

        // Test parameterized constructor
        SendMileageReminderForDelta paramBatch = new SendMileageReminderForDelta('Test Account', 'MonthlyMileageReminderEasternControls');
        Database.executeBatch(paramBatch, 1);
        
        SendMileageReminderForDelta scheduleBatchForEmail = new SendMileageReminderForDelta();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,scheduleBatchForEmail);

        Test.stopTest();
    }
}