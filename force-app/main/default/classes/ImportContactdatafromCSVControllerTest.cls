/**
 * @description       : 
 * @author            : Vatsal Bhalani
 * @group             : 
 * @last modified on  : 09-19-2024
 * @last modified by  : Vatsal Bhalani
**/
@isTest
public class ImportContactdatafromCSVControllerTest {

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
            
            objAccount1 = TestDataFactory.createAccount(false,'Delta account',true);
            objAccount1.Vehicle_Types__c = String.valueof(System.today().year())+ ' Full-Size Sedan';
            insert objAccount1;
            
            lstVehicleValue = TestDataFactory.createVehicleValue(true, objAccount1.Id, objVehicleUrlMap.Id);
            
            lstContact1 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Admin', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact2 = TestDataFactory.createDriverContact(false, objAccount1.Id, 'Manager', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact2[0].FirstName = 'John';
            lstContact2[0].LastName = 'smith';
            insert lstContact2;

        }
    }

    @isTest
    static void flNameNull1(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

       String strOriginal ='[{\"Firstname\":\" \",\"LastName\":\" \",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"2024-02-02T18:30:00.000Z\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 

        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
		objICD.processContacts();
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void flNameNull2(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

       String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\" \",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"2024-02-02T18:30:00.000Z\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 

        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
		objICD.processContacts();
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void successTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\"lna\",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"2024-02-02T18:30:00.000Z\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 
        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
        objICD.processContacts();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
     @isTest
    static void invalidDateTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\"lna\",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"7 sept\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 
        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
        objICD.processContacts();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void secondDateFromatTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\"lna\",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"09/22/2024\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 
        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
        objICD.processContacts();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void invalidZipCodeTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\"lna\",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":8012,\"ActivationDate\":\"2024-02-02T18:30:00.000Z\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 
        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
        objICD.processContacts();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void invalidCellPhoneTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\"lna\",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"2024-02-02T18:30:00.000Z\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9119466,\"DrivingState\":\"CO;WY;UT\"}]'; 
        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
        objICD.processContacts();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    
    
    @isTest
    static void invalidRoleTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\"lna\",\"EmailAddress\":\"testvatsal2@gmail.com\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Manager\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"2024-02-02T18:30:00.000Z\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 
       // String strOriginal ='[{\"Role\":\"Driver\",\"FirstName\":\"wo\",\"LastName\":\"pas\",\"EmailAddress\":\"wopas601856@yubua.com\",\"CellPhone\":1234565432,\"City\":\"Villa Rica\",\"State\":\"GA\",\"ZipCode\":30180,\"Department\":\"ENV\",\"JobTitle\":\"Inspector/Consultant\",\"ManagersFirstName\":\"ceni\",\"ManagersLastName\":\"pi\",\"ManagersEmail\":\"cenipi2424@zfobo.com\",\"InsuranceRate\":3134,\"LicenseandRegistration\":102,\"PersonalPropertyTax\":733,\"Depreciation\":4435,\"AnnualFixedCost\":8404,\"FixedAmount\":500.04,\"FCA\":1,\"TotalFixedAmount\":500.04,\"Meeting\":\"Attended\",\"Packet\":\"Sent\",\"DateAdded\":\"2021-10-19T18:30:00.000Z\",\"ActivationDate\":\"2022-01-31T18:30:00.000Z\",\"MPG\":25.5,\"Maint\":0.0738,\"Tires\":0.0689,\"MaintTires\":0.1427,\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"ComplianceMileage\":5000,\"VehicleURL\":\"https://f.hubspotusercontent40.net/hubfs/2511299/2022-Chevy-Silverado.jpeg\"},{\"Role\":\"Driver\",\"FirstName\":\"yu\",\"LastName\":\"bua\",\"EmailAddress\":\"wopas60185@yubua.com\",\"CellPhone\":1334565432,\"City\":\"Wilmington\",\"State\":\"NC\",\"ZipCode\":28412,\"Department\":\"ENV\",\"JobTitle\":\"Inspector/Consultant\",\"ManagersFirstName\":\"ceni\",\"ManagersLastName\":\"pi\",\"ManagersEmail\":\"cenipi2424@zfobo.com\",\"InsuranceRate\":2122,\"LicenseandRegistration\":177,\"PersonalPropertyTax\":262,\"Depreciation\":3844,\"AnnualFixedCost\":6405,\"FixedAmount\":381.1,\"FCA\":2,\"TotalFixedAmount\":381.1,\"Meeting\":\"Attended\",\"Packet\":\"Sent\",\"DateAdded\":\"2021-06-14T18:30:00.000Z\",\"ActivationDate\":\"2022-05-18T18:30:00.000Z\",\"MPG\":26,\"Maint\":0.0495,\"Tires\":0.0408,\"MaintTires\":0.0903,\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"ComplianceMileage\":5000,\"VehicleURL\":\"https://f.hubspotusercontent40.net/hubfs/2511299/2022-Chevy-Silverado.jpeg\",\"DrivingState\":\"CO;WY;UT\"}}]'; 
        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
        objICD.processContacts();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void invalidEmailTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];

        String strOriginal ='[{\"Firstname\":\"VatsTest\",\"LastName\":\"lna\",\"EmailAddress\":\"testvatcom\",\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"Role\":\"Driver\",\"City\":\"Denver\",\"State\":\"CO\",\"ZipCode\":80212,\"ActivationDate\":\"2024-02-02T18:30:00.000Z\",\"ManagersLastName\":\"smith\",\"ManagersFirstName\":\"John \",\"CellPhone\":9054119466,\"DrivingState\":\"CO;WY;UT\"}]'; 
       // String strOriginal ='[{\"Role\":\"Driver\",\"FirstName\":\"wo\",\"LastName\":\"pas\",\"EmailAddress\":\"wopas601856@yubua.com\",\"CellPhone\":1234565432,\"City\":\"Villa Rica\",\"State\":\"GA\",\"ZipCode\":30180,\"Department\":\"ENV\",\"JobTitle\":\"Inspector/Consultant\",\"ManagersFirstName\":\"ceni\",\"ManagersLastName\":\"pi\",\"ManagersEmail\":\"cenipi2424@zfobo.com\",\"InsuranceRate\":3134,\"LicenseandRegistration\":102,\"PersonalPropertyTax\":733,\"Depreciation\":4435,\"AnnualFixedCost\":8404,\"FixedAmount\":500.04,\"FCA\":1,\"TotalFixedAmount\":500.04,\"Meeting\":\"Attended\",\"Packet\":\"Sent\",\"DateAdded\":\"2021-10-19T18:30:00.000Z\",\"ActivationDate\":\"2022-01-31T18:30:00.000Z\",\"MPG\":25.5,\"Maint\":0.0738,\"Tires\":0.0689,\"MaintTires\":0.1427,\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"ComplianceMileage\":5000,\"VehicleURL\":\"https://f.hubspotusercontent40.net/hubfs/2511299/2022-Chevy-Silverado.jpeg\"},{\"Role\":\"Driver\",\"FirstName\":\"yu\",\"LastName\":\"bua\",\"EmailAddress\":\"wopas60185@yubua.com\",\"CellPhone\":1334565432,\"City\":\"Wilmington\",\"State\":\"NC\",\"ZipCode\":28412,\"Department\":\"ENV\",\"JobTitle\":\"Inspector/Consultant\",\"ManagersFirstName\":\"ceni\",\"ManagersLastName\":\"pi\",\"ManagersEmail\":\"cenipi2424@zfobo.com\",\"InsuranceRate\":2122,\"LicenseandRegistration\":177,\"PersonalPropertyTax\":262,\"Depreciation\":3844,\"AnnualFixedCost\":6405,\"FixedAmount\":381.1,\"FCA\":2,\"TotalFixedAmount\":381.1,\"Meeting\":\"Attended\",\"Packet\":\"Sent\",\"DateAdded\":\"2021-06-14T18:30:00.000Z\",\"ActivationDate\":\"2022-05-18T18:30:00.000Z\",\"MPG\":26,\"Maint\":0.0495,\"Tires\":0.0408,\"MaintTires\":0.0903,\"StandardVehicle\":\"'+String.valueof(System.today().year())+' Full-Size Sedan'+'\",\"ComplianceMileage\":5000,\"VehicleURL\":\"https://f.hubspotusercontent40.net/hubfs/2511299/2022-Chevy-Silverado.jpeg\",\"DrivingState\":\"CO;WY;UT\"}}]'; 
        Test.startTest();

        ImportContactdatafromCSVController objICD = new ImportContactdatafromCSVController(strOriginal, String.valueOf(lstAccounts[0].Id), String.valueOf(lstAdminContact[0].Id));
        objICD.processContacts();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }



}