@isTest
public with sharing class ResourceControllerTest {
    public static testmethod void method1() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 2);
        TriplogPutCall__c customPut = new TriplogPutCall__c();
        customPut.name = 'GetDriverData';
        customPut.TriplogPut__c = true;
        insert customPut;
        
        NewDashboardVideoLink__c NewDashboardCustom = TestDataFactory.NewDashboardVideoLink(true);
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;

        Account acc;
        List<Contact> contact;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(True,'Delta account',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            acc = TestDataFactory.createAccount(True,'Delta account',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            Acc.Triplog_Status__c = 'U';
            acc.Pay_Period_Days__c = 13;
            Update acc;

            contact = TestDataFactory.createDriverContact(true,acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contact[0].Id);
        }
        ResourceController.getContactDetail (contact[0].Id);
        ResourceController objresource = new ResourceController ();
    }
    
}