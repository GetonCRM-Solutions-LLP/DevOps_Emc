@isTest
public with sharing class UserReportAccessFromTriggerTest {
    public static testmethod void test1() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Super Manager/Driver']; 
        User userObj;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver/Admin', vehicleObj.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, p.Id, conList[0].Id);
        }     
        
        set<Id> currentUserIdsSet = new set<Id>();
        currentUserIdsSet.add(userObj.Id);
        UserReportAccessFromTrigger.createReportAccessibility(currentUserIdsSet);        
    }
}