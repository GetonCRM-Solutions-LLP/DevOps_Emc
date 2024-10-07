@isTest
public class ManageNotificationControllerTest {
    
    @TestSetup
    static void setupTestData() {
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
            insert lstContactDrivers;
            objGeneral = TestDataFactory.createUser(true, objProfile.Id, lstContactDrivers[0].Id);
        }
        List<Employee_Reimbursement__c> lstEmployeeReimbursements = TestDataFactory.createPendingReimbursement(true, lstContactDrivers, 10, objIrsMileageRate.id);
        system.assertEquals(11, lstEmployeeReimbursements.size(),true);
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReimbursements = TestDataFactory.createBiweeklyReim(true, lstContactDrivers, system.today().adddays(-14), system.today().addDays(-1), 10, objIrsMileageRate.id);
        Attachment objAttachment = TestDataFactory.createAttachment(true, lstContactDrivers[0].id);
        List<Address__c> lstaddresses = TestDataFactory.createAddress(true, 10,0986);
        
    }
    
    @isTest
    public static void newEmployeeDataAdmin(){
        
        Account objAccount = [Select id from Account where Name = 'Test'];
        Contact objContactAdmin = [Select id from Contact where Role__c = 'Admin'];        
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            String conWrapper = ManageNotificationController.NewEmployeeData(objAccount.Id,objContactAdmin.Id);
            System.assertEquals(conWrapper, conWrapper, 'Wrapper is not correct');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void newEmployeeDataManager(){
        
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
    public static void uploadLocation(){
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
        
        
        String json = '[{\"name\":\"The White House\",\"address\":\"1600 Pennsylvania Ave NW, Washington, DC 20500\",\"activity\":\"Business\",\"userId\":\"20000649\"},{\"name\":\"The White House\",\"address\":\"1600 Pennsylvania Ave NW, Washington, DC 20500\",\"latitude\":38.683885,\"longitude\":-8.6109719,\"activity\":\"Business\",\"userId\":\"20000649\"}]';
        
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.UploadLocation(json ,objAccount.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void newConData(){
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
        
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.NewConData(objAccount.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void manageNotificationController(){
        
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
    public static void deleteTrips(){
        
        
        Contact objContactAdmin = [Select id,Role__c from Contact where Role__c = 'Admin'];
        System.assertEquals('Admin',objContactAdmin.Role__c, 'Contact is not correct');
        
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.DeleteTrips(objContactAdmin.Id);
        }
        Test.stopTest();
    }

    @isTest
    public static void clearMassNotification(){
        
        
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
    public static void clearNotification(){
               
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
    public static void importMileage(){
               
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
    public static void uploadMileage(){
               
        Account objAccount = [Select id, True_Dialog__c, Name from Account where Name = 'Test'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');

        Contact objContactDriver = [Select id,Employee_ID__c,AccountId,External_Email__c from Contact where Role__c = 'Driver'];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        System.debug('objContactDriver@@-'+objContactDriver);
        Employee_Reimbursement__c objEmployeeReimbursement = [select id,Month__c,Contact_Id__c,Contact_Id__r.Employee_ID__c,Contact_Id__r.AccountId, name,MPG__c,Maintenance_and_Tires__c from Employee_Reimbursement__c where Contact_Id__c =:objContactDriver.Id limit 1];
        objEmployeeReimbursement.Contact_Id__r.Employee_ID__c =objContactDriver.Employee_ID__c;
        objEmployeeReimbursement.Contact_Id__r.AccountId = objContactDriver.AccountId;
        Update objEmployeeReimbursement;
        // Assuming objEmployeeReimbursement.Month__c and objContactDriver.Employee_ID__c are not null
        System.debug('objEmployeeReimbursement@@-'+objEmployeeReimbursement);
        String month = objEmployeeReimbursement.Month__c != null ? objEmployeeReimbursement.Month__c.trim() : '';
        String employeeId = objContactDriver.Employee_ID__c != null ? objContactDriver.Employee_ID__c.trim() : '';

        String json1 = '[{\"name\":\"The White House\",\"Trip_Date\":\" ' + month + ' \",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"26\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\": ' +Integer.valueOf(employeeId) + ' }]';

        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.UploadMileage(json1,objContactDriver.AccountId,objContactDriver.Id,'2021-06-30','2021-08-31');    
        }
        Test.stopTest();
    }

    @isTest
    public static void testMethod1(){
        
        //List<IRS_Mileage_Rate__c> lstIrsMileageRates =  RecordUtilityClass.insertIrsRate();        
        
        Account objAccount = [Select id,Name from Account where Name = 'Test'];
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
        Contact objContactAdmin = [Select id from Contact where Role__c = 'Admin'];
        Contact objContactDriver = [Select id from Contact where Role__c = 'Driver'];
        Attachment objAttachment = [select id from Attachment where parentId =: objContactDriver.id];
        User objUser = [Select id from User where ContactId =: objContactDriver.id ];
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        
        //String json = '[{\"name\":\"The White House\",\"address\":\"1600 Pennsylvania Ave NW, Washington, DC 20500\",\"activity\":\"Business\",\"userId\":\"20000649\"},{\"name\":\"The White House\",\"address\":\"1600 Pennsylvania Ave NW, Washington, DC 20500\",\"latitude\":38.683885,\"longitude\":-8.6109719,\"activity\":\"Business\",\"userId\":\"20000649\"}]';
        String json2 = '[{\"name\":\"The White House\",\"Trip_Date\":\"08/31/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Trip_Status\":\"rejected\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"33\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"},{\"name\":\"The White House\",\"Trip_Date\":\"08/30/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Trip_Status\":\"Approved\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"22\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"},{\"name\":\"The White House\",\"Trip_Date\":\"08/30/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"26\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"}]';
        // String json1 = '[{\"contactId\":\" '+con1.id + ' \",\"name\":\"Business\",\"notiMessage\":\"1600 Pennsylvania Ave NW, Washington, DC 20500\"}]';
        String json3 = '[{\"triploguserid\":\"20000339\",\"role\":\"Driver/Admin\",\"notiMessage\":\"Test123gdd\",\"notificationDate\":\"2021-06-30\",\"name\":\"Jaytik\",\"massEmail\":false,\"lastname\":\"Luhar\",\"isEditable\":false,\"insuranceId\":\"00P6s0000077Rj9EAE\",\"insurance\":null,\"fullname\":\"Jaytik Luhar\",\"expirationDate\":null}]';        
        String json4 = '[{"employeeId":"123456","proratedAmount":"100","name":"Divya ","loaEnd":"01/10/2022","loaStart":"01/04/2022"},{"employeeId":"2345","proratedAmount":"200","name":"priyankaben patelben","loaEnd":"01/10/2022","loaStart":"01/05/2022"},{"employeeId":"154641","proratedAmount":"300","name":"Harshad ","loaEnd":"01/10/2022","loaStart":"01/06/2022"},{"employeeId":"123789","proratedAmount":"400.25","name":"Atindnra ","loaEnd":"01/10/2022","loaStart":"01/07/2022"}]';
        String json5 = '[{"totalMileage":"0.00","reimbursementId":null,"mpg":null,"maintaincetyre":null,"iseditable":false,"fuelprice":null,"driverName":"Priyanka Gajera","contactId":null,"contactEmail":"test.email1@gmail.com"}]';
        Test.startTest();
        System.runAs(objUser) {
            ManageNotificationController mc = new ManageNotificationController();
            ManageNotificationController.isTestClass = true;
                    
            ManageNotificationController.sendAllInsuranceEmail(json2, objContactAdmin.Id);
            ManageNotificationController.getdriverInsurance(objAttachment.id);
            ManageNotificationController.editInlineNewEmployee(json3 ,objContactAdmin.Id);
            ManageNotificationController.UploadLOA(json4,objAccount.Id,'2021-06-30','2021-08-31');                    
            ManageNotificationController.UploadLOA(json4,objAccount.Id,String.valueOf(system.today().adddays(-14)), String.valueOf(system.today().addDays(-1)));                    
            ManageNotificationController.UpdateImportMileage(json5);
        }
    }    
    /** 
* ********************************************************
* test method for Sending Message API callout
* ********************************************************
*/
    
    @isTest
    public static void sendMessageToMultipleContacts(){
        
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2019 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;    
        
        Account objAccount1 = TestDataFactory.createAccount(true, 'demo', false);
        
        Contact objContact1  = TestDataFactory.createCICDContact(false, objAccount1.id);        
        objContact1.email='test@gmail.com';
        objContact1.MobilePhone='+13239638840';
        objContact1.lastName='Veer';
        objContact1.firstName='Sharma';
        objContact1.External_Email__c='test@gmail.com';
        objContact1.TrueDialog_Contact_Id__c='81071892';
        objContact1.MobilePhone='9843223443';
        insert objContact1;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Priyanka';
        con2.LastName = 'Gajera';
        con2.AccountId = objAccount1.Id;
        con2.External_Email__c = 'minkegsh.patel1478@gmail.com';
        con2.Deactivated_Date__c = Null;
        con2.Role__c = 'Admin';
        con2.Insurance_Attachment_Id__c = Null;
        con2.Employee_ID__c = '123456';
        con2.MobilePhone='2232316533';
        con2.Activation_Date__c = System.today();
        con2.Cell_Phone__c = 'Company Provide';
        insert con2;
        
        List<String> lstTDContactId = new List<String>();
        lstTDContactId.add(objContact1.TrueDialog_Contact_Id__c);
        
        String lstTDContactIdJson = JSON.serialize(lstTDContactId);
        
        
        Message__c message = new Message__c();
        message.Message__c='test contact id';
        message.Contacts__c=objContact1.id;
        insert message;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment');
        attach.body=bodyBlob;
        attach.parentId=message.id;
        insert attach;
        
        List<Id> idList =new List<Id>();
        idList.add(objContact1.id);
        
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());   
        Test.startTest();
        
        TrueDialogSendMessageAPI.getAllMessageByContact(objContact1.id);
        ManageNotificationController.sendMessageToMultipleContacts(lstTDContactIdJson,'Hello');
        ManageNotificationController.getUnreadMessageCount();
        ManageNotificationController.UpdateUnreadMessageStatus(objContact1.Id);
        ManageNotificationController.TrueDialogContact(objAccount1.Id,con2.id);
        Test.stopTest();        
    }
    
    @isTest
    public static void sendMessageToMultipleContacts1(){
        
        //List<Address__c> objAddress = TestDataFactory.createAddress(true, 10,0986);
        
        
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2019 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;
        
        Account a = TestDataFactory.createAccount(true, 'demo', false);
        
        Contact c  = TestDataFactory.createCICDContact(false, a.id);
        
        c.email='test@gmail.com';
        c.MobilePhone='+13239638840';
        c.lastName='Veer';
        c.firstName='Sharma';
        c.External_Email__c='test@gmail.com';
        c.TrueDialog_Contact_Id__c='81071892';
        c.MobilePhone='9843223443';
        insert c;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Priyanka';
        con2.LastName = 'Gajera';
        con2.AccountId = a.Id;
        con2.External_Email__c = 'minkegsh.patel1478@gmail.com';
        con2.Deactivated_Date__c = Null;
        con2.Role__c = 'Admin';
        con2.Insurance_Attachment_Id__c = Null;
        con2.Employee_ID__c = '123456';
        con2.MobilePhone='2232316533';
        con2.Activation_Date__c = System.today();
        con2.Cell_Phone__c = 'Company Provide';
        insert con2;
        
        List<String> lstTDContactId = new List<String>();
        lstTDContactId.add(c.TrueDialog_Contact_Id__c);
        
        String lstTDContactIdJson = JSON.serialize(lstTDContactId);        
        
        Message__c message = new Message__c();
        message.Message__c='test contact id';
        message.Contacts__c=c.id;
        insert message;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment');
        attach.body=bodyBlob;
        attach.parentId=message.id;
        insert attach;
        
        List<Id> idList =new List<Id>();
        idList.add(c.id);
        
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());   
        Test.startTest();
        
        ManageNotificationController.sendImageToMultipleContacts(lstTDContactIdJson,'Unit Test Attachment','att1.jpg','Test  Message');
        Test.stopTest();   
    }    
    
    
}