@isTest
public class EmailChangeNotificationTest {
    
    @TestSetup
    static void makeData(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10, 93242);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 0);
        vehicleType.Name = String.valueof(System.today().year()) + ' Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;

        List<Contact> conList;
        List<Vehicle_Value__c> vehValue;
        
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            
            vehValue = TestDataFactory.createVehicleValue(true, acc.Id, vehicleType.Id);
            
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Deactivated_Date__c = system.today();
            conList[0].Vehicle_Value__c = vehValue[0].Value__c;
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].Activation_Date__c = system.today().adddays(-9);   
            Insert conList[0];
        }
    }

    @isTest
    static void emailChangeInMlog200Test() {

        List<Contact> lstContact = [SELECT id, Email From Contact WHERE Role__c = 'Driver' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EmailChangeNotificationMock(200));

        Test.startTest();
		EmailChangeNotification.emailChangeInMlog(String.valueOf(lstContact[0].Id), String.valueOf(lstContact[0].Email), false);
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'Assertion Failure');
    }
    @isTest
    static void emailChangeInMlog400Test() {

        List<Contact> lstContact = [SELECT id, Email From Contact WHERE Role__c = 'Driver' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EmailChangeNotificationMock(400));

        Test.startTest();
		EmailChangeNotification.emailChangeInMlog(String.valueOf(lstContact[0].Id), String.valueOf(lstContact[0].Email), false);
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'Assertion Failure');
    }
    @isTest
    static void emailChangeInMlog404Test() {

        List<Contact> lstContact = [SELECT id, Email From Contact WHERE Role__c = 'Driver' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EmailChangeNotificationMock(401));

        Test.startTest();
		EmailChangeNotification.emailChangeInMlog(String.valueOf(lstContact[0].Id), String.valueOf(lstContact[0].Email), false);
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'Assertion Failure');
    }
    @isTest
    static void emailChangeInMlog401Test() {

        List<Contact> lstContact = [SELECT id, Email From Contact WHERE Role__c = 'Driver' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EmailChangeNotificationMock(404));

        Test.startTest();
		EmailChangeNotification.emailChangeInMlog(String.valueOf(lstContact[0].Id), String.valueOf(lstContact[0].Email), false);
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'Assertion Failure');
    }
    @isTest
    static void emailChangeInMlog500Test() {

        List<Contact> lstContact = [SELECT id, Email From Contact WHERE Role__c = 'Driver' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EmailChangeNotificationMock(500));

        Test.startTest();
		EmailChangeNotification.emailChangeInMlog(String.valueOf(lstContact[0].Id), String.valueOf(lstContact[0].Email), false);
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'Assertion Failure');
    }
    @isTest
    static void emailChangeInMlogNoStatusCodeTest() {

        List<Contact> lstContact = [SELECT id, Email From Contact WHERE Role__c = 'Driver' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EmailChangeNotificationMock());

        Test.startTest();
		EmailChangeNotification.emailChangeInMlog(String.valueOf(lstContact[0].Id), String.valueOf(lstContact[0].Email), false);
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'Assertion Failure');
    }
    @isTest
    static void changedEmailNotificationTest() {

        List<Contact> lstContact = [SELECT id, Email From Contact WHERE Role__c = 'Driver' LIMIT 1];
        Map<Id, Contact> mapIdToContact = new Map<Id, Contact>();
        mapIdToContact.put(lstContact[0].Id, lstContact[0]);

        Test.startTest();
		EmailChangeNotification.changedEmailNotification(lstContact, mapIdToContact);
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'Assertion Failure');
    }
}