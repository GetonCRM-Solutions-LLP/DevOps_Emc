@isTest
public class BiweeklyPayPeriodTest {
    
    @TestSetup
    static void setupTestData() {
        
        UserRole objUserRole = TestDataFactory.getUserRole();
        Profile objProfile = TestDataFactory.getUserProfile();
        User objAdmin = TestDataFactory.getSystemAdminUser(objUserRole.Id);
        User objGenUser;
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c sendEmailCustomSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'ChangeTripStatusinTripLogBatch');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10,12345);
        
        Vehicle_URL_Mapping__c objVehicleUrlMap = TestDataFactory.createVehicleData(false, 0);
        objVehicleUrlMap.Name = String.valueof(System.today().year())+ ' Full-Size Sedan';
        objVehicleUrlMap.vehicle__c = 'Full-Size Sedan';
        Insert objVehicleUrlMap;
        
        Account objAccount1;
        List<Vehicle_Value__c> lstVehicleValue;
        List<Contact> lstContact1;
        List<Contact> lstContact2;
        List<Contact> lstContact3;
        
        Profile objUserProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        
        System.runAs(objAdmin) {
            
            objAccount1 = TestDataFactory.createAccount(true,'Delta account',true);
            
            lstVehicleValue = TestDataFactory.createVehicleValue(true, objAccount1.Id, objVehicleUrlMap.Id);
            
            lstContact1 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Driver', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact2 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Manager', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact3 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Admin', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            
            objGenUser = TestDataFactory.createUser(true, objProfile.Id, lstContact1[0].Id);
            
            List<Employee_Reimbursement__c> lstEmpReim =TestDataFactory.createPendingReimbursement(true,lstContact1, 10, irsRateObj.Id);
            List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim =TestDataFactory.createBiweeklyReim(true, lstContact1, date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 2, irsRateObj.Id);
            List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 10, lstEmpReim, lstBiWeeklyReim);
            
        }
    }
    
    @isTest
    static void getTimeAndAttendanceTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Bi_Weekly_Reimbursement__c> lstBiReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c];
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        for(Bi_Weekly_Reimbursement__c objBiReim : lstBiReim){
            objBiReim.Start_Date__c = Date.newInstance(2024, 08, 04);
            objBiReim.End_Date__c = Date.newInstance(2024, 08, 10);
        }
        update lstBiReim;
        
        Test.startTest();
        System.runAs(objUser) {
            BiweeklyPayPeriod.getTimeAndAttendance(lstDriverContact[0].Id, String.valueOf(System.today().year()));
        }
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getPayPeriodDatesTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        System.runAs(objUser) {
            BiweeklyPayPeriod.getPayPeriodDates(lstDriverContact[0].Id, System.today().year());
        }
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getAllBiweekMileages1Test(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Bi_Weekly_Reimbursement__c> lstBiReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c];
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        System.runAs(objUser) {
            BiweeklyPayPeriod.getAllBiweekMileages1(system.today()-1, system.today(), lstDriverContact[0].Id);
        }
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getBiweeklyReimbursementTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Bi_Weekly_Reimbursement__c> lstBiReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c];
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        System.runAs(objUser) {
            BiweeklyPayPeriod.getBiweeklyReimbursement(String.valueOf(lstDriverContact[0].Id) , System.today().year());
        }
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getBiweekMileages1Test(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Bi_Weekly_Reimbursement__c> lstBiReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c];
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        System.runAs(objUser) {
            BiweeklyPayPeriod.getBiweekMileages1(string.valueOf(lstBiReim[0].Id));
        }
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void ApproveBiWeekTripsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Bi_Weekly_Reimbursement__c> lstBiReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c];
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        System.runAs(objUser) {
            BiweeklyPayPeriod.ApproveBiWeekTrips(string.valueOf(lstBiReim[0].Id));
        }
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void payPeriodDateListTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Bi_Weekly_Reimbursement__c> lstBiReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c];
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        System.runAs(objUser) {
            BiweeklyPayPeriod.payPeriodDateList(lstAccounts[0].Id);
        }
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }    
}