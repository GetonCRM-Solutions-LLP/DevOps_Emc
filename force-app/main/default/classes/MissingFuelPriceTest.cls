@isTest
public with sharing class MissingFuelPriceTest {
    @testSetup
    static void setup() {
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c objIrsMileageRate = TestDataFactory.createIRSRate(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);

        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;

        Account acc;
        Contact con1 = new Contact();

        acc = TestDataFactory.createAccount(false,'Test',true);
        acc.Name = 'Test987';
        acc.isUsingTriplog__c = true;
        insert acc;

        Vehicle_URL_Mapping__c objVehicleUrlMap = TestDataFactory.createVehicleData(false, 0);
        objVehicleUrlMap.Name = String.valueof(System.today().year())+ ' Full-Size Sedan';
        objVehicleUrlMap.vehicle__c = 'Full-Size Sedan';
        Insert objVehicleUrlMap;
        System.debug('vehicle url--@'+objVehicleUrlMap);
        List<Contact> lstcontact = new List<Contact>();
        List<Vehicle_URL_Mapping__c> objVehicleUrlMap1 = [select Id,Name, Year__c, Vehicle__c, URL__c,Vehicle_Mapping__c FROM Vehicle_URL_Mapping__c];
        System.debug('vehicle url1--@'+objVehicleUrlMap1);
        Contact objContact = TestDataFactory.createDriverContacts(false, acc.Id, 'Driver', objVehicleUrlMap1[0].Name, 'Test.654','Yes');
        lstcontact.add(objContact);
        insert lstcontact;
        userObj = TestDataFactory.createUser(true, profileObj.Id, objContact.Id);

        List<Employee_Reimbursement__c> lstEmpReim = TestDataFactory.createPendingReimbursement(false,lstcontact, 1, objIrsMileageRate.Id);
        List<Employee_Reimbursement__c> reimToInsert = new List<Employee_Reimbursement__c>();
        for (Employee_Reimbursement__c reim : lstEmpReim) {
            reim.Fuel_Price__c = 3.50;
            reim.Month__c = System.now().addMonths(-1).format('MM-YYYY');
            reimToInsert.add(reim);
        }
        insert reimToInsert;
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim = TestDataFactory.createBiweeklyReim(false, lstcontact, System.TODAY(), System.TODAY().addDays(7), 1, objIrsMileageRate.Id);
        List<Bi_Weekly_Reimbursement__c> bwReimToInsert = new List<Bi_Weekly_Reimbursement__c>();
        for (Bi_Weekly_Reimbursement__c reim : lstBiWeeklyReim) {
            reim.Fuel_Price__c = 3.50;
            reim.Month__c = System.now().addMonths(-1).format('MM-YYYY');
            bwReimToInsert.add(reim);
        }
        insert bwReimToInsert;

        List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(false, 2, lstEmpReim, lstBiWeeklyReim);
        List<Employee_Mileage__c> mils = new List<Employee_Mileage__c>();
        for (Employee_Mileage__c mil : lstEmpMil) {
            mil.Trip_Date__c = Date.today().addDays(-5);
            mil.Fuel_price__c = 0;
            mils.add(mil);
        }
        insert mils;
    }

    @isTest
    static void testMissingFuelPriceBatch() {
        // Query for mileages before the batch runs
        List<Employee_Mileage__c> mileagesBefore = [SELECT Id, Fuel_price__c, EmployeeReimbursement__r.Fuel_Price__c 
                                                    FROM Employee_Mileage__c 
                                                    WHERE Fuel_price__c = 0 OR Fuel_price__c = null];
        
        System.assertNotEquals(0, mileagesBefore.size(), 'There should be mileages with zero or null fuel price before the batch runs');
        
        Test.startTest();
        MissingFuelPrice batch = new MissingFuelPrice();
        batch.execute(null, mileagesBefore);
        // executeBatch(batch, 100);
        Test.stopTest();
        
        // Query for mileages after the batch runs
        List<Employee_Mileage__c> mileagesAfter = [SELECT Id, Fuel_price__c, EmployeeReimbursement__r.Fuel_Price__c 
                                                   FROM Employee_Mileage__c 
                                                   WHERE Id IN :mileagesBefore];
        
        System.assertEquals(mileagesBefore.size(), mileagesAfter.size(), 'The number of mileages should remain the same');
        
        for (Employee_Mileage__c mileage : mileagesAfter) {
            System.assertNotEquals(null, mileage.Fuel_price__c, 'Fuel price should not be null after batch execution');
            System.assertEquals(3.50, mileage.Fuel_price__c, 
                                'Mileage fuel price should match the reimbursement fuel price');
        }
    }

    @isTest
    static void testMissingFuelPriceBatchWithNoUpdates() {
        // Update all mileages to have a non-zero fuel price
        List<Employee_Mileage__c> allMileages = [SELECT Id, Fuel_price__c FROM Employee_Mileage__c];
        for (Employee_Mileage__c mileage : allMileages) {
            mileage.Fuel_price__c = 3.75;
        }
        update allMileages;

        Test.startTest();
        MissingFuelPrice batch = new MissingFuelPrice();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        List<Employee_Mileage__c> mileagesAfter = [SELECT Id, Fuel_price__c FROM Employee_Mileage__c];
        for (Employee_Mileage__c mileage : mileagesAfter) {
            System.assertEquals(3.75, mileage.Fuel_price__c, 'Fuel price should remain unchanged');
        }
    }
}