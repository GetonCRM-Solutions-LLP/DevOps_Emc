@isTest
public class ManageNotificationControllerTest {
    
    @TestSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());
        SendEmail__c objSendEmail = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        SendEmail__c objSendEmail1 = TestDataFactory.sendEmailCustomSetting(true,'SendMileageReminderforDelta');        
        TriggerConfig__c objTriggerConfig = TestDataFactory.triggerConfigCustomSetting(true);        
        SendEmailonDeactivation__c objSendEmalDeactivate= TestDataFactory.sendEmailCustomSetting(true,'SendMileageReminderforDelta','test@gmail.com');        
        Vehicle_URL_Mapping__c objVehicleURLMapping = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c objIrsMileageRate = TestDataFactory.createIRSRate(true,0);        
        daylight_saving_time_config__c objDayLightSaveTimeConfig =  TestDataFactory.dayLightCustomSetting(true,'2022', System.today(), System.today() + 60);
        TrueDialog_Keys__c objTrueDialogKeys = TestDataFactory.createTrueDialog(true);
        
        UserRole objUserRole = TestDataFactory.getUserRole();
        Profile objProfile = TestDataFactory.getUserProfile();
        User objAdmin = TestDataFactory.getSystemAdminUser(objUserRole.Id);
        User objGeneral;
        
        Account objAccount = new Account();
        Contact objContact = new Contact();
        List<Contact> lstContactDrivers = new List<Contact>();
        List<Contact> lstContactAdmins = new List<Contact>();
        List<Contact> lstContactManagers = new List<Contact>();
        
        System.runAs(objAdmin) {
            objAccount = TestDataFactory.createAccount(true,'Test',true);
            objContact = TestDataFactory.createCICDContact(true,objAccount.Id);
            lstContactAdmins = TestDataFactory.createDriverContact(true, objAccount.Id, 'Admin', objVehicleURLMapping.Name, 'dialog.email', 1);
            lstContactManagers = TestDataFactory.createDriverContact(true, objAccount.Id, 'Manager', objVehicleURLMapping.Name, 'dialg.email', 1);
            lstContactDrivers = TestDataFactory.createDriverContact(false, objAccount.Id, 'Driver', objVehicleURLMapping.Name, 'test.email', 1);
            lstContactDrivers[0].Manager__c = lstContactManagers[0].Id;
            lstContactDrivers[0].Notification_Message__c = 'Test Message';
            lstContactDrivers[0].Notification_Date__c = system.today();
            lstContactDrivers[0].TrueDialog_Contact_Id__c = '2345678';
            insert lstContactDrivers;
            objGeneral = TestDataFactory.createUser(true, objProfile.Id, lstContactDrivers[0].Id);
        }
        List<Employee_Reimbursement__c> lstEmployeeReimbursements = TestDataFactory.createPendingReimbursement(true, lstContactDrivers, 10, objIrsMileageRate.id);
        system.assertEquals(11, lstEmployeeReimbursements.size(),true);
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReimbursements = TestDataFactory.createBiweeklyReim(true, lstContactDrivers, system.today().adddays(-14), system.today().addDays(-1), 10, objIrsMileageRate.id);
        
        List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 10, lstEmployeeReimbursements, lstBiWeeklyReimbursements);

        Attachment objAttachment = TestDataFactory.createAttachment(true, lstContactDrivers[0].id);
        List<Address__c> lstaddresses = TestDataFactory.createAddress(true, 10,0986);

        Message__c objMsg = new Message__c();
        objMsg.Message__c = 'test contact id';
        objMsg.Contacts__c = lstContactDrivers[0].Id;
        insert objMsg;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment');
        attach.body = bodyBlob;
        attach.parentId = objMsg.id;
        insert attach;
        
    }
    
    @isTest
    static void newEmployeeDataAdmin(){
        
        Account objAccount = [Select id from Account where Name = 'Test'];
        Contact objContactAdmin = [Select id from Contact where Role__c = 'Admin'];        
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            String conWrapper = ManageNotificationController.NewEmployeeData(objAccount.Id,objContactAdmin.Id);
            ManageNotificationController.NewEmployeeData(objAccount.Id,null);
            System.assertEquals(conWrapper, conWrapper, 'Wrapper is not correct');
        }
        Test.stopTest();
    }
    
    @isTest
    static void newEmployeeDataManager(){
        
        Account objAccount = [Select id from Account where Name = 'Test'];
        Contact objContact = [Select id from Contact where Role__c = 'Manager'];
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            String conWrapper = ManageNotificationController.NewEmployeeData(objAccount.Id,objContact.Id);
            System.assertEquals(conWrapper, conWrapper, 'Wrapper is not correct');
        }
        Test.stopTest();
    }
    
    @isTest
    static void uploadLocation(){
         Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
        
        
        String json = '[{\"name\":\"The White House\",\"address\":\"1600 Pennsylvania Ave NW, Washington, DC 20500\",\"activity\":\"Business\",\"userId\":\"20000649\"},{\"name\":\"The White House\",\"address\":\"1600 Pennsylvania Ave NW, Washington, DC 20500\",\"latitude\":38.683885,\"longitude\":-8.6109719,\"activity\":\"Business\",\"userId\":\"20000649\"}]';
        
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];

        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.UploadLocation(json ,objAccount.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    static void manageNotificationController(){
        
        Account objAccount = [Select id, True_Dialog__c, Name from Account where Name = 'Test'];
        Contact objContact = [Select id from Contact where Role__c = 'Admin'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
        
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.manageNotificationController(objAccount.Id, objContact.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void clearMassNotification(){
        
        Account objAccount = [Select id, True_Dialog__c, Name from Account where Name = 'Test'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');

        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.clearMassNotification(objAccount.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void clearNotification(){
               
        Contact objContactDriver = [Select id,Role__c,Notification_Message__c,Notification_Date__c from Contact where Role__c = 'Driver'];       
        System.assertEquals('Driver',objContactDriver.Role__c, 'Contact is not correct');
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.clearNotification(objContactDriver.Id );
        }
        Test.stopTest();
    }

    @isTest
    static void importMileage(){
               
        Account objAccount = [Select id, True_Dialog__c, Name from Account where Name = 'Test'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');

        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            String response = ManageNotificationController.ImportMileage(objAccount.Id);    
        }
        Test.stopTest();
    }
   
    @isTest
    static void sendAllInsuranceEmailTest(){
        
        //List<IRS_Mileage_Rate__c> lstIrsMileageRates =  RecordUtilityClass.insertIrsRate();        
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        Contact objContactAdmin = [Select id from Contact where Role__c = 'Admin'];
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        Attachment objAttachment = [select id from Attachment where parentId =: objContactDriver.id];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        
        String json2 = '[{\"name\":\"The White House\",\"Trip_Date\":\"08/31/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Trip_Status\":\"rejected\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"33\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"},{\"name\":\"The White House\",\"Trip_Date\":\"08/30/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Trip_Status\":\"Approved\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"22\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"},{\"name\":\"The White House\",\"Trip_Date\":\"08/30/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"26\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"}]';

        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            //ManageNotificationController.isTestClass = true;
                    
            ManageNotificationController.sendAllInsuranceEmail(json2, objContactAdmin.Id);
        }
        System.assertEquals('Test', objAccount.Name, 'One Account Must be Created.');
    }    
    @isTest
    static void editInlineNewEmployeeTest(){
        
        //List<IRS_Mileage_Rate__c> lstIrsMileageRates =  RecordUtilityClass.insertIrsRate();        
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        Contact objContactAdmin = [Select id from Contact where Role__c = 'Admin'];
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        Attachment objAttachment = [select id from Attachment where parentId =: objContactDriver.id];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        
        //String jsonStr = '[{\"triploguserid\":\"20000339\",\"role\":\"Driver/Admin\",\"notiMessage\":\"Test123gdd\",\"notificationDate\":\"2021-06-30\",\"name\":\"Jaytik\",\"massEmail\":false,\"lastname\":\"Luhar\",\"isEditable\":false,\"insuranceId\":\"00P6s0000077Rj9EAE\",\"insurance\":null,\"fullname\":\"Jaytik Luhar\",\"expirationDate\":null}]';        
		String jsonStr = '[{"contactId":"'+objContactDriver.id+'","triploguserid":"20000649","name":"John","lastname":"Doe","role":"Manager","fullname":"John Doe","insurance":"Health Plan A","contactEmail":"johndoe@example.com","notiMessage":"You have a new message","insuranceId":"INS001","unReadMessageCount":"3","isEditable":true,"massEmail":true,"massText":false,"expirationDate":"2024-12-31","notificationDate":"2024-10-21","contactPicture":"/path/to/picture.jpg","trueDialogId":"TD001","massNotiText":true,"insuranceFile":false,"locationFile":true,"messageHolder":true}]';

        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            //ManageNotificationController.isTestClass = true;
                    
            ManageNotificationController.editInlineNewEmployee(jsonStr ,objContactAdmin.Id);

        }
        System.assertEquals('Test', objAccount.Name, 'One Account Must be Created.');
    }    
    @isTest
    static void updateImportMileageTest(){
        
        //List<IRS_Mileage_Rate__c> lstIrsMileageRates =  RecordUtilityClass.insertIrsRate();        
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        List<Contact> lstAdminContact = [Select id from Contact where Role__c = 'Admin'];
        List<Contact> lstDriverContact = [Select id,Name,Email from Contact where Role__c = 'Driver'];
        Attachment objAttachment = [select id from Attachment where parentId =: lstDriverContact[0].id];
        User objUser = [Select id from User where ContactId =: lstDriverContact[0].id ];
        List<Employee_Reimbursement__c> lstEmployeeReimbursements = [SELECT id FROM Employee_Reimbursement__c WHERE Contact_Id__c = :lstDriverContact[0].Id];
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        
        // String json5 = '[{"totalMileage":"0.00","reimbursementId":\''+lstEmpMil[0].Id+'\',"mpg":null,"maintaincetyre":null,"iseditable":false,"fuelprice":null,"driverName":\''+lstDriverContact[0].Name+'\''+',"contactId":\''+lstDriverContact[0].Id+'\''+',"contactEmail":\''+lstDriverContact[0].Email+'\''+'}]';

        String json5 = '[{"totalMileage":"0.00",'
        + '"reimbursementId":"' + lstEmployeeReimbursements[0].Id + '",'
        + '"mpg":null,'
        + '"maintaincetyre":null,'
        + '"iseditable":false,'
        + '"fuelprice":null,'
        + '"driverName":"' + lstDriverContact[0].Name + '",'
        + '"contactId":"' + lstDriverContact[0].Id + '",'
        + '"contactEmail":"' + lstDriverContact[0].Email + '"}]';
    
        // Output the JSON string
        System.debug(json5);
    

        Test.startTest();
        System.runAs(objUser) {
             System.debug('JSON string ==> '+json5);
            ManageNotificationController mc = new ManageNotificationController();
            //ManageNotificationController.isTestClass = true;                
            ManageNotificationController.UpdateImportMileage(json5);
        }
        System.assertEquals('Test', objAccount.Name, 'One Account Must be Created.');
    }    
    @isTest
    static void updateImportMileageTest2(){       
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        Contact objContactAdmin = [Select id from Contact where Role__c = 'Admin'];
        Contact objContactDriver = [Select id,Name,Email from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        List<Employee_Mileage__c> lstEmpMil = [SELECT id FROM Employee_Mileage__c];
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            //ManageNotificationController.isTestClass = true;                
            ManageNotificationController.UpdateImportMileage(null);
        }
        System.assertEquals('Test', objAccount.Name, 'One Account Must be Created.');
    }    
   
    @isTest
    static void getAllMessageByContactTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());
        Test.startTest();
        TrueDialogSendMessageAPI.getAllMessageByContact(lstDriverContact[0].id);
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void sendMessageToMultipleContactsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id,TrueDialog_Contact_Id__c FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];


        List<String> lstTDContactId = new List<String>();
        lstTDContactId.add(lstDriverContact[0].TrueDialog_Contact_Id__c);
        
        String lstTDContactIdJson = JSON.serialize(lstTDContactId);

        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());
        Test.startTest();
        ManageNotificationController.sendMessageToMultipleContacts(lstTDContactIdJson,'Hello');
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void sendImageToMultipleContactsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id,TrueDialog_Contact_Id__c FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];


        List<String> lstTDContactId = new List<String>();
        lstTDContactId.add(lstDriverContact[0].TrueDialog_Contact_Id__c);
        
        String lstTDContactIdJson = JSON.serialize(lstTDContactId);

        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());
        Test.startTest();
        ManageNotificationController.sendImageToMultipleContacts(lstTDContactIdJson,'Unit Test Attachment','att1.jpg','Test  Message');
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
        @isTest
    static void sendInsuranceEmailTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id,Email,Name,TrueDialog_Contact_Id__c FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];


        List<String> lstTDContactId = new List<String>();
        lstTDContactId.add(lstDriverContact[0].TrueDialog_Contact_Id__c);
        
        String lstTDContactIdJson = JSON.serialize(lstTDContactId);

        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());
        Test.startTest();
        ManageNotificationController.sendInsuranceEmail(lstDriverContact[0].Id,lstDriverContact[0].Name,lstDriverContact[0].Email);
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
}