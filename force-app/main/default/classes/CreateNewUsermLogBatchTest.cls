@isTest	
public class CreateNewUsermLogBatchTest {
    @isTest
    Public Static void testMethod1 (){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 2,30304);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0); 
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 0);
        vehicleType.Name = String.valueOf(System.today().year())+ ' Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;
        
        UserRole userRole_1 = TestDataFactory.getUserRole();
        Profile profile_1 = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole_1.Id);
        
        User user_1;
        User user_2;
        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
        Contact obj_Contact2;
        List<Contact> obj_Driver_list1;
        Contact obj_Manager_list1;
        
        System.runAs(admin) {
            obj_Account = RecordUtilityClass.buildAccount();
            obj_Account.Vehicle_Types__c = String.valueOf(System.today().year())+' Full-Size Sedan';
            obj_Account.Cell_Phone__c = 'Employee Provide';
            insert obj_Account;
            Contact contact_1 = new Contact(AccountId = obj_Account.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com',Activation_Date__c=system.today());
            insert contact_1;
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;

            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            system.debug('obj_Manager_list=='+obj_Manager_list );
            insert obj_Manager_list;

            obj_Driver_list = TestDataFactory.createDriverContact(false, obj_Account.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            obj_Driver_list[0].Driving_States__c = 'CA';
            obj_Driver_list[0].Triplog_UserID__c=null;
            Insert obj_Driver_list;
            
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
                );
            insert user_1;
        }

        test.startTest();
        Test.setMock( HttpCalloutMock.class, new CreateNewUserCalloutMock());
        Database.executeBatch(new CreateNewUsermLogBatch(),200);
        test.stopTest();
    }
}