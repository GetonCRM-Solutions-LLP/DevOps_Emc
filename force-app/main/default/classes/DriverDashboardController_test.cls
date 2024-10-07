@isTest
public class DriverDashboardController_test {
    public static testmethod void DriverDashboardControllerTestMethod() {

        NewDashboardVideoLink__C videoLinkCustomSetting = TestDataFactory.NewDashboardVideoLink(True);
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2019 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;

        UserRole userRole_1 = TestDataFactory.getUserRole();
        Profile profile_1 = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole_1.Id);
        User user_1;
      
        List<Contact> obj_admin_contact;
        Account obj_acc;
        List<Contact> obj_Manager_list;
        List<Contact> obj_driver_contact;
        
        System.runAs(admin) {
             obj_acc = TestDataFactory.createAccount(false,'Test Accounts',true);
            obj_acc.Bi_Weekly_Pay_Period__c = true;
            obj_acc.Pay_Period_Days__c = 13;
            obj_acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            insert obj_acc;
           
            obj_admin_contact = TestDataFactory.createDriverContact(True, obj_acc.Id, 'Admin', '2019 Full-Size Sedan', 'Paras.dhanani', 1);
            obj_Manager_list = TestDataFactory.createDriverContact(True, obj_acc.Id, 'Manager', '2019 Full-Size Sedan', 'Paras.dhanani1', 1);
            obj_driver_contact = TestDataFactory.createDriverContact(False, obj_acc.Id, 'Driver', '2019 Full-Size Sedan', 'Paras.dhanani2', 1);
            obj_driver_contact[0].Driver_Type__c = 'Driver - Part Time';
            Insert obj_driver_contact[0];
         
            Contact contact_2 = new Contact(AccountId = obj_acc.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com');
            insert contact_2 ;
            
            user_1 = TestDataFactory.createUser(true, profile_1.Id, contact_2.Id);
           /* user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_2.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;*/
        }        
        Attachment att = new Attachment();
        att.parentID = obj_admin_contact[0].Id;
        att.name = 'test';
        att.body = blob.valueOf('Test');
        insert att;
        
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, obj_driver_contact, 10, irsRateObj.id);
        system.assertEquals(11, reimList.size(),true);
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim(true, obj_driver_contact, system.today().adddays(-14), system.today().addDays(-2), 10, irsRateObj.id);
        Attachment attach = TestDataFactory.createAttachment(true, obj_driver_contact[0].id);
        List<Attachment> attachments = [select id, name from Attachment where parent.id =: obj_driver_contact[0].id];

        Test.startTest();
        System.runAs(user_1) {
            Test.setCurrentPage(Page.driverDashboardClone);
            String conId = ApexPages.currentPage().getParameters().put('id',obj_driver_contact[0].Id);
            String accId = ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
            DriverDashboardController ddc = new DriverDashboardController();
            DriverDashboardController.getAccountid();
            DriverDashboardController.getContactid();
            DriverDashboardController.getLast2Years();
            DriverDashboardController.getRedirected();
            DriverDashboardController.getReimbursementsList();
            DriverDashboardController.getDriverDetails();
            DriverDashboardController.getAllReimbursements(String.valueOf(Date.today().year()),obj_driver_contact[0].Id,obj_acc.Id);
            DriverDashboardController.getAllReimbursements('2018',obj_driver_contact[0].Id,obj_acc.Id);
            DriverDashboardController.contactDataAsString = 'test';
            DateTime dt = DateTime.now();
            String monthName = dt.format('MMMMMMM');
            DriverDashboardController.getMileages(monthName,String.valueOf(System.today().year()),obj_driver_contact[0].Id);
            DriverDashboardController.TimeAttendance(obj_driver_contact[0].Id,'2021');
            //DriverDashboardController.readFromFile(String.valueof(documentObj.Body),driList[0].Id,acc.Id,documentObj.Name);
            //DriverDashboardController.readFromFileInchunk('test',att.Name,String.valueOf(att.Id),String.valueOf(obj_driver_contact[0]),String.valueOf(obj_acc.Id), '3423p4923493258jfd32');
            DriverDashboardController.getCompliance(String.valueOf(obj_driver_contact[0].Id));
            DriverDashboardController.getPacketandMeeting(String.valueOf(obj_driver_contact[0].Id));
            DriverDashboardController.biweeklyMileage(obj_driver_contact[0].id,2021);
            DriverDashboardController.getAllMileages('2021-11-12','2021-12-30',obj_driver_contact[0].id);
            DriverDashboardController.getBiweekMileages(string.valueOf(biWeeklyReimList[0]));
            DriverDashboardController.getdriverInsurance(attach.Id);
            DriverDashboardController.getDriverGasPrice('TN' , 'Atlanta');
            DriverDashboardController.sendInsuranceEmail(String.valueOf(obj_driver_contact[0].Id), 'Test', 'test@gmail.com');
            DriverDashboardController.getMileagesBasedTandAtt('2021-11-12','2021-12-30',obj_driver_contact[0].id);
            DriverDashboardController.getCustomSettings();
        }
        Test.stopTest();
    }
    
}