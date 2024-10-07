@isTest
public with sharing class ChangeTripStatusByAdminTest {
    public static testmethod void method1() {
       
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        daylight_saving_time_config__c customSetting2 = TestDataFactory.dayLightCustomSetting(true,'2022', System.today(), System.today() + 60);
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_1 = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
       
        TriplogPutCall__c sendemailme = new TriplogPutCall__c();
        sendemailme.name = 'ChangeTripStatusByAdmin';
        sendemailme.TriplogPut__c = true;
        insert sendemailme;

            //RecordUtilityClass.createRecordsAdminDashboardController();
            Test.setMock(HttpCalloutMock.class, new ChangeTripStatusinTripLogTestMock());

            UserRole uRole = TestDataFactory.getUserRole();
            Profile profileObj = TestDataFactory.getUserProfile();
            User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
            User userObj;
            
            Account acc;
            List<Contact> currentAdmin;
            List<Contact> conList;
            System.runAs(admin) {               
                
                acc = TestDataFactory.createAccount(false,'Test',true);
                acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
                acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
                acc.Pay_Period_Days__c = 13;
                insert acc;
                Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
                currentAdmin = TestDataFactory.createDriverContact(true, acc.Id, 'Admin', vehicleObj.Name, 'Paras.Patel', 2);
                conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'paras.dhanani',  1);
                conList[0].Vehicle_Type__c = vehicleObj.Name;
                Insert conList[0];
                
                system.assertEquals(1, conList.size(), true);
                userObj = TestDataFactory.createUser(True, profileObj.Id, currentAdmin[0].Id);
            }    
        
            String lastMonth = Utils.fetchMonths(1, 0)[0]; 
            
            List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(false,conList,0, obj_IRS_Mileage_Rate_1.Id);
            er[0].Month__c = lastMonth;
            insert er;
         
            List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-26),System.today().addDays(-13), 1, obj_IRS_Mileage_Rate_1.Id);
            List<Employee_Mileage__c> driverMileagesList = TestDataFactory.getEmpMileage (True, 0, er, br);
            driverMileagesList[0].Trip_Status__c = 'Not Approved Yet';
            driverMileagesList[0].Trip_Id__c = 496532;
            update  driverMileagesList[0];

            List<Employee_Mileage__c> driverMileagesList1 = TestDataFactory.getEmpMileage (True, 0, er, br);
            driverMileagesList1[0].Trip_Status__c = 'Rejected';
            driverMileagesList1[0].Trip_Id__c = 705873;
            update  driverMileagesList1[0];

            List<Employee_Mileage__c> driverMileagesList2 = TestDataFactory.getEmpMileage (True, 0, er, br);
            driverMileagesList2[0].Trip_Status__c = 'Approved';
            driverMileagesList2[0].Trip_Id__c = 893657;
            update  driverMileagesList2[0];
        
             ChangeTripStatusByAdmin batchobj = new ChangeTripStatusByAdmin(acc.id,lastMonth);
             Database.executeBatch(batchobj);
    }
}