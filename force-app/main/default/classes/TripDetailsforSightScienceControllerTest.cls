@isTest
public class TripDetailsforSightScienceControllerTest {

    @isTest
    static void testCheckBiweeklyPayPeriod() {
        // insert custom setting
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        //SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,1);
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        user userObj;
        Account acc = new Account();
        acc = TestDataFactory.createAccount(false,'Test',true);
        acc.Vehicle_Types__c=vehicleObj.name;
        acc.True_Dialog__c = true;
        acc.Vehicle_Types__c = vehicleObj.Name;
        Insert acc;
        List<Contact> conList = new List<Contact>();
        conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
        Profile profileObj = TestDataFactory.getUserProfile();
        userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        IRS_Mileage_Rate__c objIRSRate = new IRS_Mileage_Rate__c();
        objIRSRate.year__c = '2021';
        objIRSRate.IRS_Rate__c= 12.0;
        insert objIRSRate;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = conList[0].Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = '09-2021';
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00; 
        er.Fixed_Amount__c = conList[0].Fixed_Amount__c;
        er.Maintenance_and_Tires__c = conList[0].Maintenance_and_Tires__c;
        er.MPG__c = conList[0].MPG__c;
        er.IRS_Mileage_Rate__c= objIRSRate.Id;
        er.Fuel_Price__c = 2.14;
        insert er;
        
        Bi_Weekly_Reimbursement__c bob = new Bi_Weekly_Reimbursement__c();
        bob.name = '9/19/2021 to 10/2/2021';
        bob.Contact__c = conList[0].id;
        insert bob;
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = conList[0].External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = 'Approved';
        emp.Approved_Date__c = system.today();
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = Date.today();
        emp.Bi_Weekly_Reimbursement__c = bob.id;
        insert emp;
        // Set up the test context
        Test.startTest();
        TripDetailsforSightScienceController.checkBiweeklyPayPeriod(Date.today().adddays(-1).format(), Date.today().adddays(1).format(), conList[0].Id);
        Test.stopTest();

        // Retrieve and validate results
        TripDetailsforSightScienceController.tripDetailWrapper[] tripDetails = TripDetailsforSightScienceController.tripDetailWrapperList;
        // System.assertNotEquals(null, tripDetails);
        // System.assertEquals(1, tripDetails.size());
        TripDetailsforSightScienceController.tripDetailWrapper wrapper = tripDetails[0];
        // System.assertEquals('Priyanka Gajera', wrapper.Name);
        // System.assertEquals(Date.today(), wrapper.TripDate);
        // System.assertEquals('Approved', wrapper.status);
        // Add more assertions for other fields as needed
    }
}