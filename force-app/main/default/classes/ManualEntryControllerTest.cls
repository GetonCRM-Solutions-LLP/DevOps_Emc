/**
 * @description       : 
 * @author            : Vatsal Bhalani
 * @group             : 
 * @last modified on  : 08-06-2024
 * @last modified by  : Vatsal Bhalani
**/
@isTest
public with sharing class ManualEntryControllerTest {
    
	@testSetup 
    static void setupData(){
		TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRate = TestDataFactory.createIRSRate(true,0);

        UserRole uRole = TestDataFactory.getUserRole();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        
        System.runAs(admin){
            Account objAccount = TestDataFactory.createAccount(true,'Test',true);

            List<Contact> lstContact = TestDataFactory.createDriverContact(false,objAccount.id,'Driver',veh.Name,'testmail',1);
            lstContact[0].MPG__c = 3.00;
            lstContact[0].Maintenance_and_Tires__c = 80.0000;  
            insert lstContact;

            List<Employee_Reimbursement__c> lstEmpReim = TestDataFactory.createPendingReimbursement(false, lstContact, 1, irsRate.Id);
            lstEmpReim[0].Month__c = getCurrentMonth();
            lstEmpReim[0].MPG__c = 3.00;
			lstEmpReim[0].Fuel_Price__c = 20.00;
            lstEmpReim[0].Maintenance_and_Tires__c = 80.0000;  
            insert lstEmpReim;

            List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim2 =TestDataFactory.createBiweeklyReim(true, lstContact, System.TODAY(), System.TODAY().addDays(7), 1, irsRate.Id);
            List<Employee_Mileage__c> lstEmpMil2 = TestDataFactory.getEmpMileage(true, 5, lstEmpReim, lstBiWeeklyReim2);

            // 2nd contact Bi-Weekly
			List<Contact> lstContact2 = TestDataFactory.createDriverContact(false,objAccount.id,'Driver',veh.Name,'testmail2',1);
            lstContact2[0].Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement';
            lstContact2[0].External_Email__c = 'bidriver@gmail.com';
            lstContact2[0].Email = 'bidriver@gmail.com';
            insert lstContact2;
            
			List<Employee_Reimbursement__c> lstEmpReim2 = TestDataFactory.createPendingReimbursement(false, lstContact2, 1, irsRate.Id);
            lstEmpReim2[0].Month__c = getCurrentMonth();
            lstEmpReim2[0].MPG__c = 3.00;
			lstEmpReim2[0].Fuel_Price__c = 30.00;
            lstEmpReim2[0].Maintenance_and_Tires__c = 80.0000;  
            insert lstEmpReim2;

            List<Bi_Weekly_Reimbursement__c> lstBiReim = TestDataFactory.createBiweeklyReim(false, lstContact2, System.today().addDays(-5), System.today().addDays(2) , 1, irsRate.Id);
            lstBiReim[0].Employee_Reimbursement__c = lstEmpReim2[0].Id;
            lstBiReim[0].MPG__c = 3.00;
			lstBiReim[0].Fuel_Price__c = 30.00;
            lstBiReim[0].Maintenance_and_Tires__c = 80.0000;  
            insert lstBiReim;
            
            List<Employee_Mileage__c> empMileage = TestDataFactory.getEmpMileage(true, 1, lstEmpReim2, lstBiReim);
        }
    }
    
    @isTest
    static void insertLocationUSATest() {
        
        List<Contact> lstContact = [SELECT id,AccountId FROM CONTACT WHERE Reimbursement_Frequency__c = 'Monthly Reimbursement' LIMIT 1];

        ManualEntryController.LocationWrapper objLocationWrapper = new ManualEntryController.LocationWrapper();
        objLocationWrapper.id = '123456789012345678';
        objLocationWrapper.Name = 'My Location';
        objLocationWrapper.Address = '123 Main Street';
        objLocationWrapper.Latitude = '37.7833';
        objLocationWrapper.Longitude = '-122.4167';
        objLocationWrapper.State = 'Alabama';
        objLocationWrapper.City = 'Blountsville';
        objLocationWrapper.ZipCode = '35031';
        objLocationWrapper.Range = '10';
        objLocationWrapper.Phone = '1234567890';
        
        ManualEntryController.LocationWrapper objLocationWrapper2 = new ManualEntryController.LocationWrapper();
        objLocationWrapper2.name = 'mLog Array';
        objLocationWrapper2.address = 'm, log, AL 20500';
        objLocationWrapper2.latitude = '38.8975';
        objLocationWrapper2.longitude = '-77.036477';
        objLocationWrapper2.activity = 'Business';
        objLocationWrapper2.userId = '20000446';
        objLocationWrapper2.id = '123456789012345679';
        objLocationWrapper2.State = 'Alabama';
        objLocationWrapper2.City = 'Blountsville';
        objLocationWrapper2.ZipCode = '20500';
        objLocationWrapper2.Range = '10';
        objLocationWrapper2.Phone = '1234567899';
        

        ManualEntryController.getAllUSStates();
        ManualEntryController.getAllCANStates();
        Test.startTest();
        ManualEntryController.insertLocation(JSON.serialize(objLocationWrapper),lstContact[0].AccountId,lstContact[0].id
                                             ,'USA',JSON.serialize(objLocationWrapper2));  
        System.assertEquals(1,lstContact.size(), 'Assert fail');         
        Test.stopTest();
    }
    
    @isTest
	static void insertLocationCanadaTest() {
        
        List<Contact> lstContact = [SELECT id,AccountId FROM CONTACT WHERE Reimbursement_Frequency__c = 'Monthly Reimbursement' LIMIT 1];

        ManualEntryController.LocationWrapper objLocationWrapper = new ManualEntryController.LocationWrapper();
        //objLocationWrapper.id = '123456789012345678';
        objLocationWrapper.Name = 'My Location';
        objLocationWrapper.Address = '123 Main Street';
        objLocationWrapper.Latitude = '37.7833';
        objLocationWrapper.Longitude = '-122.4167';
        objLocationWrapper.State = 'Alberta';
        objLocationWrapper.City = 'Blountsville';
        objLocationWrapper.ZipCode = '35031';
        objLocationWrapper.Range = '10';
        objLocationWrapper.Phone = '1234567890';

        ManualEntryController.LocationWrapper objLocationWrapper2 = new ManualEntryController.LocationWrapper();
        objLocationWrapper2.name = 'mLog Array';
        objLocationWrapper2.address = 'm, log, AL 20500';
        objLocationWrapper2.latitude = '38.8975';
        objLocationWrapper2.longitude = '-77.036477';
        objLocationWrapper2.activity = 'Business';
        objLocationWrapper2.userId = '20000446';

        Test.startTest();
        ManualEntryController.getAllUSStates();
        ManualEntryController.getAllCANStates();
        ManualEntryController.insertLocation(JSON.serialize(objLocationWrapper),lstContact[0].AccountId,lstContact[0].id
        ,'CANADA',JSON.serialize(objLocationWrapper2));
        ManualEntryController.getLocations(lstContact[0].id,'CANADA');
        System.assertEquals(1,lstContact.size(), 'Assert fail'); 
        Test.stopTest();
            
	}
    @isTest
	static void getLocationCanadaTest() {
        
        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Monthly Reimbursement' LIMIT 1];

        Test.startTest();
        ManualEntryController.getLocations(lstContact[0].id,'CANADA');
        System.assertEquals(1,lstContact.size(), 'Assert fail'); 
        Test.stopTest();
            
	}

    @isTest
	static void updateLocationUSATest() {
        
        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Monthly Reimbursement' LIMIT 1];
        
        Schema.Location objLocation = new Schema.Location();
        objLocation.Name = 'Test';
        objLocation.New_Location_Name__c = 'loc1'; 
        objLocation.Location_Address__c = 'loc2';
        objLocation.Range__c = 20;
        objLocation.Phone__c = '7648757983';
        objLocation.Longitude = 28.635308;
        objLocation.Latitude = 28.635308;
        objLocation.Driver__c = lstContact[0].id;
        insert objLocation;
        
        ManualEntryController.LocationWrapper objLocationWrapper2 = new ManualEntryController.LocationWrapper();
        objLocationWrapper2.id = String.valueOf(objLocation.Id);
        objLocationWrapper2.Name = String.valueOf(objLocation.Name);
        objLocationWrapper2.Latitude = String.valueOf(objLocation.Latitude);
        objLocationWrapper2.Longitude = String.valueOf(objLocation.Longitude);
        objLocationWrapper2.Range = String.valueOf(objLocation.Range__c);
        objLocationWrapper2.Phone = String.valueOf(objLocation.Phone__c);
        objLocationWrapper2.State = 'Alabama';
        objLocationWrapper2.City = 'Blountsville';
        objLocationWrapper2.ZipCode = '35031';
        objLocationWrapper2.Address = '123 Main Street';
        
        Test.startTest();
        
        ManualEntryController.getAllUSStates();
        ManualEntryController.getAllCANStates();
        ManualEntryController.updateLocation(JSON.serialize(objLocationWrapper2),lstContact[0].id,'USA');    
        System.assertEquals(1,lstContact.size(), 'Assert fail');         
        Test.stopTest();
            
	}

    @isTest
	static void updateLocationCanadaTest() {
        
        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Monthly Reimbursement' LIMIT 1];

        Schema.Location objLocation = new Schema.Location();
        objLocation.Name = 'Test';
        objLocation.New_Location_Name__c = 'loc1'; 
        objLocation.Location_Address__c = 'loc2';
        objLocation.Range__c = 20;
        objLocation.Phone__c = '7648757983';
        objLocation.Longitude = 28.635308;
        objLocation.Latitude = 28.635308;
        objLocation.Driver__c = lstContact[0].id;
        insert objLocation;
        
        ManualEntryController.LocationWrapper objLocationWrapper2 = new ManualEntryController.LocationWrapper();
        objLocationWrapper2.id = String.valueOf(objLocation.Id);
        objLocationWrapper2.Name = String.valueOf(objLocation.Name);
        objLocationWrapper2.Latitude = String.valueOf(objLocation.Latitude);
        objLocationWrapper2.Longitude = String.valueOf(objLocation.Longitude);
        objLocationWrapper2.Range = String.valueOf(objLocation.Range__c);
        objLocationWrapper2.Phone = String.valueOf(objLocation.Phone__c);
        objLocationWrapper2.State = 'Alberta';
        objLocationWrapper2.City = 'Blountsville';
        objLocationWrapper2.ZipCode = '35031';
        objLocationWrapper2.Address = '123 Main Street';

        Test.startTest();
        ManualEntryController.getAllUSStates();
        ManualEntryController.getAllCANStates();
        ManualEntryController.updateLocation(JSON.serialize(objLocationWrapper2),lstContact[0].id,'CANADA');
        System.assertEquals(1,lstContact.size(), 'Assert fail'); 
        Test.stopTest();
            
	}

    @isTest
    static void insertTripTest(){
        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Monthly Reimbursement' LIMIT 1];
        
        ManualEntryController.TripWrapper objTripWrapper = new ManualEntryController.TripWrapper();
        objTripWrapper.tripDate = getCurrentDateFormatted();
        objTripWrapper.startTime = '04:30 PM';
        objTripWrapper.endTime = '05:00 PM';
        objTripWrapper.origin = 'loc1';
        objTripWrapper.destination = 'loc2'; 
        objTripWrapper.originName = 'loc1';
        objTripWrapper.destinationName = 'loc2'; 
        objTripWrapper.mileage = '35.22';
        objTripWrapper.fromLat = 28.635308;
        objTripWrapper.fromLong = 30.635309;
        objTripWrapper.toLat = 29.635308;
        objTripWrapper.toLong = 30.635309;
        objTripWrapper.timeZone = 'US/Mountain';
        objTripWrapper.wayPoints = '';
        objTripWrapper.triplogApi = '';

        Test.startTest();
        ManualEntryController.insertTrip(lstContact[0].id,JSON.serialize(objTripWrapper),System.today().month());
        ManualEntryController.insertTrip(lstContact[0].id,JSON.serialize(objTripWrapper),System.today().addMonths(-1).month());
        ManualEntryController.insertTrip(lstContact[0].id,JSON.serialize(objTripWrapper),System.today().addMonths(-2).month());
        ManualEntryController.getTrips(lstContact[0].id,getCurrentMonth());
        System.assertEquals(1,lstContact.size(), 'Assert fail');
        Test.stopTest();
    }

    @isTest
    static void deleteTripTest() {
        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement' LIMIT 1];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT Id FROM Employee_Reimbursement__c WHERE Contact_Id__c = :lstContact[0].Id];
        List<Employee_Mileage__c> empMileage = [SELECT Id FROM Employee_Mileage__c WHERE EmployeeReimbursement__c IN :lstEmpReim];
        // List<Employee_Mileage__c> objTrip = [SELECT Id FROM Employee_Mileage__c WHERE Trip_Date__c = :System.today() LIMIT 1];
        // String tripIds = String.valueOf(empMileage[0].Id) + ',' + String.valueOf(objTrip[0].Id);
        Test.startTest();        
        ManualEntryController.deleteTrips(String.valueOf(empMileage[0].Id));
        System.assertEquals(1,lstContact.size(), 'Assert fail');
        Test.stopTest();
    }

    @isTest
    static void insertBiWeeklyTripTest(){
        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement' AND External_Email__c = 'bidriver@gmail.com' LIMIT 1];
        
        ManualEntryController.TripWrapper objTripWrapper = new ManualEntryController.TripWrapper();
        objTripWrapper.tripDate = getCurrentDateFormatted();
        objTripWrapper.startTime = '04:30 PM';
        objTripWrapper.endTime = '05:00 PM';
        objTripWrapper.origin = 'loc1';
        objTripWrapper.destination = 'loc2'; 
        objTripWrapper.originName = 'loc1';
        objTripWrapper.destinationName = 'loc2'; 
        objTripWrapper.mileage = '35.22';
        objTripWrapper.fromLat = 28.635308;
        objTripWrapper.fromLong = 30.635309;
        objTripWrapper.toLat = 29.635308;
        objTripWrapper.toLong = 30.635309;
        objTripWrapper.timeZone = 'US/Mountain';
        objTripWrapper.wayPoints = '';
        objTripWrapper.triplogApi = '';

        Test.startTest();
        ManualEntryController.insertTrip(lstContact[0].id,JSON.serialize(objTripWrapper),7);
        ManualEntryController.getTrips(lstContact[0].id,getCurrentMonth());
        System.assertEquals(1,lstContact.size(), 'Assert fail');
        Test.stopTest();
    }

	@isTest
    static void updateTripTest(){

        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement' LIMIT 1];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT Id FROM Employee_Reimbursement__c WHERE Contact_Id__c = :lstContact[0].Id];
        List<Employee_Mileage__c> empMileage = [SELECT Id FROM Employee_Mileage__c WHERE EmployeeReimbursement__c IN :lstEmpReim];

        ManualEntryController.TripWrapper objTripWrapper2 = new ManualEntryController.TripWrapper();
        objTripWrapper2.id = empMileage[0].Id;
        objTripWrapper2.tripDate = getCurrentDateFormatted();
        objTripWrapper2.startTime = '04:30 PM';
        objTripWrapper2.endTime = '05:00 PM';
        objTripWrapper2.origin = 'loc1';
        objTripWrapper2.destination = 'loc2'; 
        objTripWrapper2.originName = 'loc1';
        objTripWrapper2.destinationName = 'loc2'; 
        objTripWrapper2.mileage = '35.44';
        objTripWrapper2.fromLat = 28.635308;
        objTripWrapper2.fromLong = 30.635309;
        objTripWrapper2.toLat = 29.635308;
        objTripWrapper2.toLong = 30.635309;
        objTripWrapper2.timeZone = 'US/Mountain';
        objTripWrapper2.wayPoints = '';
        objTripWrapper2.triplogApi = '';
        
        Test.startTest();
        ManualEntryController.updateTrip(lstContact[0].id, JSON.serialize(objTripWrapper2));
        System.assertEquals(1,lstContact.size(), 'Assert fail');
        Test.stopTest();
    } 
    
    @isTest
    static void noTripFoundTest(){
        List<Contact> lstContact = [SELECT id FROM CONTACT WHERE Reimbursement_Frequency__c = 'Monthly Reimbursement' LIMIT 1];
		Test.startTest();        
        ManualEntryController.getTrips(lstContact[0].id,'2');
        System.assertEquals(1,lstContact.size(), 'Assert fail');
        Test.stopTest();
    }

    public static String getCurrentMonth(){
        Integer month = Integer.valueOf(System.today().month());
        String currentMonth;
        if(month>9){
            currentMonth = month + '-' + System.today().year();
        }else {
            currentMonth = '0' + month + '-' + System.today().year();
        }
        return currentMonth;
    }

    public static String getCurrentDateFormatted() {
        Date today = Date.today();
        
        // Format day with leading zero if needed
        String strDay = (today.day() < 10) ? '0' + today.day() : String.valueOf(today.day());
        
        // Format month with leading zero if needed
        String strMonth = (today.month() < 10) ? '0' + today.month() : String.valueOf(today.month());
        
        // Get the last two digits of the year
        String formatedYear = String.valueOf(today.year()).substring(2, 4);
        
        // Construct the formatted date
        String formatedDate = strMonth + '/' + strDay + '/' + formatedYear;

        return formatedDate;
    }
}