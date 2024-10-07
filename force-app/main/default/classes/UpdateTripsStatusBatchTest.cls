/*
    @Description: Test class for UpdateTripsStatusBatch
*/

@isTest
public class UpdateTripsStatusBatchTest {
    
    public static testmethod void updateTripStatustest() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
       
        Get_Trip_Date_Settings__c obj_Get_Trip_Date_Settings = new Get_Trip_Date_Settings__c();
        obj_Get_Trip_Date_Settings.Name ='Date Settings';
        obj_Get_Trip_Date_Settings.Start_Date__c ='2019-01-01';
        obj_Get_Trip_Date_Settings.End_Date__c ='2019-01-31';
        obj_Get_Trip_Date_Settings.Last_N_Days__c ='31';
        insert obj_Get_Trip_Date_Settings;

        Account acc ;
        List<Contact> con ;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
        acc = TestDataFactory.createAccount(True, 'Delta account', False);
        con = TestDataFactory.createDriverContact(True, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
        }

        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, con, 1, createIRSRate.Id);
        er[0].Month__c = '12-2018';
        Insert er[0];
        
        conReim.put(con[0].Id,er[0]);
        
        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, con, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (True, 0, er, br);
        emp1[0].Trip_Date__c =  date.today().adddays(-1);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].Approved_Date__c = system.today();
        Update emp1;

        Test.startTest();
        
            Test.SetMock( HttpCalloutMock.class, new updateTripsStatusBatchMock() );
            UpdateTripsStatusBatch updateStatusObj = new UpdateTripsStatusBatch( new List<String> { '12-2018' }, Acc.Id);
            DataBase.executeBatch( updateStatusObj );
        
            UpdateTripsStatusBatch updateStatusObj2 = new UpdateTripsStatusBatch( er[0].Id);
            DataBase.executeBatch( updateStatusObj2 );
            
            UpdateTripsStatusBatch updateStatusObj3 = new UpdateTripsStatusBatch( new List<String> {emp1[0].Id });
            DataBase.executeBatch( updateStatusObj3 );
        Test.stopTest();
    }
    
}