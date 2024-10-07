@isTest
public with sharing class LoadMileageLocationBatchTest {   
    static testMethod void loadTestMethod() {
        RecordUtilityClass.createRecordsAdminDashboardController();
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 1);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);

            Test.setMock(HttpCalloutMock.class, new LoadMileageLocationBatchTestMock());
            
            /*Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
            Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
            Contact selectedDriver = RecordUtilityClass.getDriverContact();
           */
          Account acc ;
        List<Contact> con ;
        List<Contact> adminCon ;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
        acc = TestDataFactory.createAccount(True, 'Delta account', False);
        con = TestDataFactory.createDriverContact(True, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
        adminCon = TestDataFactory.createDriverContact(True, acc.Id, 'Admin', vehicleType.Name, 'Paras.Patel1', 2);
        }

        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, con, 1, createIRSRate.Id);
        er[0].Month__c = '12-2018';
        Insert er[0];

            //List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
            List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(er);
            List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, con, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
            List<Employee_Mileage__c> driverMileagesList = TestDataFactory.getEmpMileage (True, 0, er, br);
            driverMileagesList[0].Trip_Date__c =  date.today().adddays(-1);
            driverMileagesList[0].Trip_Status__c = 'Approved';
            driverMileagesList[0].Approved_Date__c = system.today();
            driverMileagesList[0].FromLocationId__c = 30.212761 -97.659064;
            driverMileagesList[0].ToLocationId__c = 30.161151 -97.794057;
            Update driverMileagesList;

            
            /*List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
            driverMileagesList[0].Trip_Id__c = 104976448;
            update driverMileagesList;
            */
        String json = '{'+
        '    \"message\": \"OK\",'+
        '    \"location\": {'+
        '        \"id\": 143316643,'+
        '        \"url\": \"https://triplogmileage.com/web/api/locations/143316643\",'+
        '        \"lastUpdated\": \"2020-04-01T19:32:17.753Z\",'+
        '        \"display\": \"33.182021,-96.748293\",'+
        '        \"name\": null,'+
        '        \"address\": null,'+
        '        \"latitude\": 33.182021,'+
        '        \"longitude\": -96.748293,'+
        '        \"accuracy\": 5,'+
        '        \"defaultActivity\": null'+
        '    }'+
        '}';
        
       // Test.StartTest();  
        LoadMileageLocationBatch batchobj = new LoadMileageLocationBatch(new Set<Id>{er[0].Id}, true);
        Database.executeBatch(batchobj,10);
       // Test.StopTest();

    }

    static testMethod void loadTestMethod2() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 1);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);

            RecordUtilityClass.createRecordsAdminDashboardController();
            Test.setMock(HttpCalloutMock.class, new LoadMileageLocationBatchTestMock());
            Account acc ;
        List<Contact> con ;
        List<Contact> adminCon ;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
        acc = TestDataFactory.createAccount(True, 'Delta account', False);
        con = TestDataFactory.createDriverContact(True, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
        adminCon = TestDataFactory.createDriverContact(True, acc.Id, 'Admin', vehicleType.Name, 'Paras.Patel1', 2);
        }

        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, con, 1, createIRSRate.Id);
        er[0].Month__c = '12-2018';
        Insert er[0];

            //List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
            List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(er);
            List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, con, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
            List<Employee_Mileage__c> driverMileagesList = TestDataFactory.getEmpMileage (True, 0, er, br);
            driverMileagesList[0].Trip_Date__c =  date.today().adddays(-1);
            driverMileagesList[0].Trip_Status__c = 'Approved';
            driverMileagesList[0].Approved_Date__c = system.today();
            Update driverMileagesList;

            
            /*Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
            Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
            Contact selectedDriver = RecordUtilityClass.getDriverContact();
           
            List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
            List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(empReimbursementList);
            List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
            driverMileagesList[0].Trip_Id__c = 104976448;
            update driverMileagesList;
*/
            Set<Id> mileagesIdSet = new Set<Id>();
            for(Employee_Mileage__c empRei:driverMileagesList){
                mileagesIdSet.add(empRei.Id);
            }

            //Test.StartTest();
            LoadMileageLocationBatch batchobj = new LoadMileageLocationBatch(mileagesIdSet, false);
            Database.executeBatch(batchobj,10);
            //Test.StopTest();

    }

    /*static testMethod void loadTestMethod3() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
 
        Test.setMock(HttpCalloutMock.class, new LoadMileageLocationBatchTestMock());

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.mileageremoveapprovaldate__c = false;
        insert customSetting;

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Triplog_API__c = 'isduif388';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'FirstCont';
        con.LastName = 'TestContact';
        con.AccountId = acc.Id;
        con.External_Email__c = 'test@email.com';
        con.Fixed_Amount__c = 371.28;
        con.MailingCity = 'Fremont';
        con.MailingState = 'CA';        
        con.Monthly_Mileage_Limit__c = 100.00;
        con.Time_Zone__c = 'US/Mountain';
        insert con;

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = '03-2020';
        er.Status__c = 'Pending';
        insert er;
		
        Bi_Weekly_Reimbursement__c bob = new Bi_Weekly_Reimbursement__c();
        bob.name = '9/19/2021 to 10/2/2021';
        bob.Contact__c = con.id;
        insert bob;		
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.Rejected__c = true;
        emp.Mileage__c = 150.00;
        emp.FromLocationId__c = 5767;
        emp.ToLocationId__c = 23235;
        emp.Bi_Weekly_Reimbursement__c = bob.Id;
        insert emp;
        
        Test.StartTest();
        LoadMileageLocationBatch batchobj = new LoadMileageLocationBatch();
        Database.executeBatch(batchobj,10);
        Test.StopTest();
    }*/
}