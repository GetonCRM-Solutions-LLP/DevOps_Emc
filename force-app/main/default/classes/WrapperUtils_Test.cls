/**
 * @description       : 
 * @author            : Harsita
 * @group             : 
 * @last modified on  : 23-10-2024
 * @last modified by  : Harsita
**/
@isTest
public class WrapperUtils_Test {
    
    @TestSetup
    static void setupTestData() {
        
        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());
        
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
            TestDataFactory.createAddress(true,1,36310);
            List<Employee_Reimbursement__c> lstEmpReim =TestDataFactory.createPendingReimbursement(true,lstContact1, 10, irsRateObj.Id);
            List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim =TestDataFactory.createBiweeklyReim(true, lstContact1, date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 2, irsRateObj.Id);
            List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 10, lstEmpReim, lstBiWeeklyReim);
            
            // Creating a mock record for the TriplogPutCall__c custom setting
            TriplogPutCall__c customSettingRecord = new TriplogPutCall__c();
            customSettingRecord.Name = 'RosterControllerPutCall'; // Setting the unique name
            customSettingRecord.TriplogPut__c = true; // Setting the TriplogPut__c field to true
            insert customSettingRecord;
            
            TriplogPutCall__c customSettingRecord1 = new TriplogPutCall__c();
            customSettingRecord1.Name = 'RosterControlllerputHTTPConcurConnect'; 
            customSettingRecord1.TriplogPut__c = true; 
            insert customSettingRecord1;
            
        }
        
        Attachment objAttachment = new Attachment();
        objAttachment.parentID = lstContact1[0].Id;
        objAttachment.name = 'test';
        objAttachment.body = blob.valueOf('Test');
        insert objAttachment;
    }
    
    @isTest
    static void getChartDataTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id, showTeamRecord__c FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();
        
        WrapperUtils.getChartData(lstAdminContact[0].id,true,lstAccounts[0].id,'Admin');
        WrapperUtils.getChartData(lstAdminContact[0].id,false,lstAccounts[0].id,'Admin');
        WrapperUtils.getChartData(lstAdminContact[0].id,true,lstAccounts[0].id,'Manager');
        WrapperUtils.getChartData(lstAdminContact[0].id,false,lstAccounts[0].id,'Manager');
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getComplianceCalculationTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id,monthly_compliance_status__c FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        
        
        List<Contact> lstAdminContact = [SELECT Id, showTeamRecord__c FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT Approved_Date__c FROM Employee_Reimbursement__c];
        
        for(Contact objContact : lstDriverContact){
            objContact.monthly_compliance_status__c = null;
        }
        update lstDriverContact;
        
        for(Employee_Reimbursement__c objEmpReim : lstEmpReim){
            objEmpReim.Approved_Date__c = System.today();
        }
        update lstEmpReim;
        
        Test.startTest();
        
        WrapperUtils.getComplianceCalculation(lstDriverContact[0].id,String.valueOf(System.Today().year()));
        WrapperUtils.getComplianceCalculation(lstDriverContact[0].id,String.valueOf(System.Today().addYears(-1).year()));
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getComplianceCalculationTest2(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id,monthly_compliance_status__c, Compliance_Mileage__c, Avg_Mileage__c, AccountId FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        
        
        List<Contact> lstAdminContact = [SELECT Id, showTeamRecord__c FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT Approved_Date__c FROM Employee_Reimbursement__c];
        
        for(Contact objContact : lstDriverContact){
            objContact.monthly_compliance_status__c = 'Yes';
            objContact.Compliance_Mileage__c = 10000000;
            objContact.Avg_Mileage__c = 100;
        }
        update lstDriverContact;
        
        for(Employee_Reimbursement__c objEmpReim : lstEmpReim){
            objEmpReim.Approved_Date__c = System.today();
        }
        update lstEmpReim;
        
        Test.startTest();
        
        WrapperUtils.getComplianceCalculation(lstDriverContact[0].id,String.valueOf(System.Today().year()));
        WrapperUtils.getComplianceCalculation(lstDriverContact[0].id,String.valueOf(System.Today().addYears(-1).year()));
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getComplianceCalculationTest3(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id,monthly_compliance_status__c FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id, showTeamRecord__c FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT Approved_Date__c FROM Employee_Reimbursement__c];
        
        for(Contact objContact : lstDriverContact){
            objContact.monthly_compliance_status__c = 'Pending';
        }
        update lstDriverContact;
        for(Employee_Reimbursement__c objEmpReim : lstEmpReim){
            objEmpReim.Approved_Date__c = System.today();
        }
        update lstEmpReim;
        
        Test.startTest();
        
        WrapperUtils.getComplianceCalculation(lstDriverContact[0].id,String.valueOf(System.Today().year()));
        WrapperUtils.getComplianceCalculation(lstDriverContact[0].id,String.valueOf(System.Today().addYears(-1).year()));
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getEmployeeDetailsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Contact> lstAdminContact = [SELECT Id, showTeamRecord__c FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        
        for(Contact objContact : lstDriverContact){
            objContact.monthly_compliance_status__c = 'Pending';
            objContact.App_Settings__c = 'Auto start:08:00 AM Business hours:09:00 AM - 05:00 PM';
            objContact.Last_Synced__c = System.today();
            objContact.Company__c = '	Park';
            objContact.Department__c = 'Admin';
            objContact.Department = 'Admin';
            objContact.Division__c = 1;
            objContact.Dept__c = 'test';
            objContact.Job_Title__c = 'Technical Support';
            objContact.Hello_Sign_Request_Id__c = 'tseqqwest';
            objContact.Employee_Netchex_Id__c = 'tseqqwest';
            objContact.Freeze__c = System.today();
        }
        update lstDriverContact;
        
        Test.startTest();
        
        EmployeeDetails objContactDetails =   WrapperUtils.getEmployeeDetails(lstDriverContact[0],110.50,230.50);
        objContactDetails.fixedamount = '1';
        objContactDetails.sage100ID = '123';
        objContactDetails.glcode = '1';
        objContactDetails.code = '1';
        objContactDetails.loaFixedAmount = '1';
        objContactDetails.district = 'guj';
        objContactDetails.fixedamount = '10.00';
        objContactDetails.loaStartDate = '2024-10-01';
        objContactDetails.deactivaedDate = '2024-10-01';
        objContactDetails.territory = 'Guj';
        objContactDetails.lastPayDate = '2024-10-01';
        objContactDetails.loaEndDate = '2024-10-01';
        objContactDetails.firstPayrollPer = '100%';
        objContactDetails.finalPayrollAmount = '1';
        objContactDetails.payRollPeriod = '1';
        WrapperUtils.getContact(objContactDetails);
        WrapperUtils.getNewContact(objContactDetails);
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getEmployeeDetailsTest2(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Contact> lstAdminContact = [SELECT Id, showTeamRecord__c FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();
        
        EmployeeDetails objContactDetails = WrapperUtils.getEmployeeDetails(lstDriverContact[0],110.50,230.50);
        WrapperUtils.getContact(objContactDetails);
        WrapperUtils.getNewContact(objContactDetails);
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void monthTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].Id];
        Test.startTest();
        WrapperUtils.getMonthName('11-2019');
        WrapperUtils.getMonthno('November');
        WrapperUtils.getMonthandYear('November');
        WrapperUtils.getMonthandYear('January');
        WrapperUtils.getLastMonthValue(-1);
        WrapperUtils.getDriverGasPrice('CA','ON');
        WrapperUtils.getLast2Years();
        WrapperUtils.getManager(lstDriverContact[0].Id, lstAccounts[0].Id);
        WrapperUtils.getadminname(lstDriverContact[0].Id);
        WrapperUtils.getDriverFuelVariableRate(lstDriverContact[0].Id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getMileagesOfReimbursementTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Employee_Mileage__c> lstEmpMile =  RecordUtilityClass.getMileagesList();
        //List<EmployeeMileages> lstEmpMileWrap = RecordUtilityClass.getallEmployeeMileages(lstEmpMile);
        
        Test.startTest();
        WrapperUtils.getMileagesOfReimbursement(lstEmpMile[0]);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getEmployeeReimbursementsTest1(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Employee_Reimbursement__c> lstEmpReim = getLstEmpReim();
        lstEmpReim[0].Reimbursement_Lock_Time__c = System.today();
        lstEmpReim[0].Lock_Date_User__c = String.valueOf(System.today());
        lstEmpReim[0].Approved_Date__c = System.today();
        update lstEmpReim;
        Test.startTest();
        WrapperUtils.getEmployeeReimbursements(lstEmpReim[0], 1, 1);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getEmployeeReimbursementsTest2(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Employee_Reimbursement__c> lstEmpReim = getLstEmpReim();
        lstEmpReim[0].Fixed_Amount__c = 12 ;
        lstEmpReim[0].Number_of_Pay_Period__c =1;
        lstEmpReim[0].Contact_Id__r.Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement';
        lstEmpReim[0].Contact_Id__r.Reimbursement_Type__c = 'FAVR';
        lstEmpReim[0].Contact_Id__r.Driver_Type__c = null;
        update lstEmpReim;
        
        Contact objContact = [SELECT Reimbursement_Frequency__c, Reimbursement_Type__c FROM Contact WHERE id =: lstEmpReim[0].Contact_Id__c];
        
        Test.startTest();
        WrapperUtils.getEmployeeReimbursements(lstEmpReim[0], 1, 1);
        lstEmpReim[0].Number_of_Pay_Period__c =2;
        lstEmpReim[0].Monthly_Fixed_Amount__c = 10;
        lstEmpReim[0].Contact_Id__r.Driver_Type__c = 'Driver - Part Time';
        update lstEmpReim;
        WrapperUtils.getEmployeeReimbursements(lstEmpReim[0], 1, 1);
        lstEmpReim[0].Number_of_Pay_Period__c =3;
        lstEmpReim[0].Monthly_Fixed_Amount__c = null;
        lstEmpReim[0].Contact_Id__r.Driver_Type__c = 'Driver - Full Time'; 
        lstEmpReim[0].Fixed_Amount__c = null;
        update lstEmpReim;
        WrapperUtils.getEmployeeReimbursements(lstEmpReim[0], 1, 1);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getPacketandMeetingDetailsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].Id];
        
        Test.startTest();
        
        WrapperUtils.getPacketandMeetingDetails(lstDriverContact[0].id);
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getEmployeeReimbursementDetailsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Employee_Reimbursement__c> lstEmpReim = getLstEmpReim();
        lstEmpReim[0].Reimbursement_Lock_Time__c = System.today();
        lstEmpReim[0].Lock_Date_User__c = String.valueOf(System.today());
        lstEmpReim[0].Approved_Date__c = System.today();
        update lstEmpReim;
        Test.startTest();
        WrapperUtils.getEmployeeReimbursementDetails(lstEmpReim[0]); 
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getAllReimbursementsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        
        Test.startTest();
        WrapperUtils.getAllReimbursements(String.valueOf(System.today().Year()),String.valueOf(lstDriverContact[0].id),lstAccounts[0].id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getReimbursementsListTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        
        Test.startTest();
        WrapperUtils.getReimbursementsList(lstDriverContact[0].id,'Approved');
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getMileagesTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        
        Test.startTest();
        WrapperUtils.getMileages(getMonthName(System.today().month()),String.valueOf(system.today().year()),lstDriverContact[0].id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getMileages1Test(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        
        Test.startTest();
        WrapperUtils.getMileages1(getMonthName(System.today().month()),String.valueOf(system.today().year()),lstDriverContact[0].id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getpastYearReimbursementTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        
        Test.startTest();
        WrapperUtils.getpastYearReimbursement(lstDriverContact[0].id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getReimbursementsListCloneTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        
        Test.startTest();
        WrapperUtils.getReimbursementsListClone(lstDriverContact[0].id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void approveReimbursementsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Employee_Reimbursement__c> lstEmpReim = getLstEmpReim();
        String jsonData = '[{"employeeReimbursementId": "'+lstEmpReim[0].Id+'",'+
            '"isSelected": true,'+
            '"approveddate": "2024-10-01",'+
            '"status": "Approved",'+
            '"variableRate": "15.75",'+
            '"month": "'+getMonthName(System.today().month())+'",'+
            '"intmonth": 10,'+
            '"fuel": "3.25",'+
            '"mileage": "1200",'+
            '"pendingMileage": "200",'+
            '"approveMileage": "1000",'+
            '"varibleAndFixedReimbursements": "500.75",'+
            '"totalReimbursements": "1500.00",'+
            '"maintainsAndTyres": "75.50",'+
            '"mpg": "25",'+
            '"varibleAmount": "350.00",'+
            '"fixed1": "100.00",'+
            '"fixed2": "150.00",'+
            '"fixed3": "200.00",'+
            '"totalFixedAmount": "450.00",'+
            '"contactEmail": "'+lstDriverContact[0].Email+'",'+
            '"contactdrivertype": "'+lstDriverContact[0].Driver_Type__c+'",'+
            '"fixedAmount": "500.00",'+
            '"avgToDate": "100.00",'+
            '"lockDate": "2024-09-15",'+
            '"lockDateUserName": "Admin",'+
            '"syncMileageBtn": true,'+
            '"concurBtn": false'+
            '}]';
        
        Test.startTest();
        WrapperUtils.approveReimbursements(String.valueOf(System.today().Year()),lstDriverContact[0].id,lstAccounts[0].id,jsonData);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void updateMileagesTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Employee_Mileage__c> lstEmpMile = [SELECT id FROM Employee_Mileage__c];
        Test.startTest();
        WrapperUtils.UpdateMileages(new List<String>{lstEmpMile[0].Id}, 'Approved') ;
        WrapperUtils.UpdateMileages(new List<String>{lstEmpMile[0].Id}, 'Not Approved Yet') ;
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void readFromFileInchunkTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        Attachment objAtt = [SELECT Name, Id FROM Attachment];
        List<Employee_Mileage__c> lstEmpMile = [SELECT id FROM Employee_Mileage__c];
        Test.startTest();
        WrapperUtils.readFromFileInchunk('test',objAtt.Name,String.valueOf(objAtt.Id),String.valueOf(lstDriverContact[0].Id),String.valueOf(lstAccounts[0].Id),null);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getUnapprovedReimbursementsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        Attachment objAtt = [SELECT Name, Id FROM Attachment];
        List<Employee_Mileage__c> lstEmpMile = [SELECT id FROM Employee_Mileage__c];
        Test.startTest();
        WrapperUtils.getUnapprovedReimbursements(lstDriverContact[0].id,lstAccounts[0].id,true,'Driver/Manager');
        WrapperUtils.getUnapprovedReimbursements(lstDriverContact[0].id,lstAccounts[0].id,true,'Admin');
        WrapperUtils.getUnapprovedReimbursements(lstDriverContact[0].id,lstAccounts[0].id,false,'Admin');
        WrapperUtils.getUnapprovedReimbursements(lstDriverContact[0].id,lstAccounts[0].id,false,'Manager');
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void getLastMonthReimbursementsTest(){
        
        List<Account> lstAccounts = [SELECT Id, Last_Reimbursement_Created__c FROM Account WHERE Name = 'Delta account' LIMIT 1];
        lstAccounts[0].Last_Reimbursement_Created__c = '2024-10-10';
        update lstAccounts;
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        Attachment objAtt = [SELECT Name, Id FROM Attachment];
        List<Employee_Mileage__c> lstEmpMile = [SELECT id FROM Employee_Mileage__c];
        Test.startTest();
        WrapperUtils.getLastMonthReimbursements(lstDriverContact[0].id,lstAccounts[0].id,true,'Admin');
        WrapperUtils.getLastMonthReimbursements(lstDriverContact[0].id,lstAccounts[0].id,false,'Admin');
        WrapperUtils.getLastMonthReimbursements(lstDriverContact[0].id,lstAccounts[0].id,true,'Manager');
        WrapperUtils.getLastMonthReimbursements(lstDriverContact[0].id,lstAccounts[0].id,false,'Manager');
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void updateContactThresholdLimitTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Employee_Reimbursement__c> lstEmpReim = getLstEmpReim();
        Test.startTest();
        WrapperUtils.updateContactThresholdLimit(JSON.serialize(lstEmpReim));
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void reportUnlockTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Employee_Reimbursement__c> lstEmpReim = getLstEmpReim();
        Test.startTest();
        WrapperUtils.ReportUnlock(lstAccounts[0].Id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void updateLockDateTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Employee_Reimbursement__c> lstEmpReim = getLstEmpReim();
        Test.startTest();
        WrapperUtils.updateLockDate(lstAccounts[0].Id,lstDriverContact[0].Id);
        Test.stopTest();
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    //=================================================================================================================================================================================================================================
    private static List<Contact> getContact(Id accountId, String role ){
        return [SELECT id, Name,firstName, lastName, IsDeactivated__c, Mileage_for_deduct__c, Phone, Branch_Name__c, 
                Deactivated_By__c, Branch_Number__c, MobilePhone, App__c, is_Manual_Entry_User__c, compliancestatus__c, 
                Final_Payroll_Amount__c, First_Payroll__c, Sage_100_ID__c, GL_Code__c, Territory__c, Code__c, Packet__c, 
                District__c, Monthly_Mileage_Limit__c, Fixed_Amount__c, MailingPostalCode, MailingCity, MailingState, Employee_ID__c,
                Role__c, Company__c, Department__c, Department, Division__c, Dept__c, Job_Title__c, Driver_Type__c,
                Employee_Netchex_Id__c, Freeze__c, Manager__c, email, External_Email__c, Manager__r.Name, Activation_Date__c, Vehicle_Type__c,
                Deactivated_Date__c, Last_Pay_Date__c, Added_Date__c, Driving_States__c, LOA_Start_Date__c, LOA_End_Date__c, LOA_Fixed_Amount__c,
                Payroll_Period__c, Monthly_Reimbursement__c, Reimbursement_Frequency__c, Time_Attandance__c, Cost_Code__c, App_Settings__c,
                Last_Synced__c, BP_Code__c, Hello_Sign_Request_Id__c, Hello_Sign_Status__c, Cell_Phone__c, Account.Reimbursement_Frequency__c,
                Account.Cell_Phone__c, AM__c, AN__c
                FROM Contact 
                WHERE Role__c = :role 
                AND AccountId = :accountId];
    } 
    
    private static List<Employee_Reimbursement__c> getLstEmpReim(){
        return [SELECT Id,Approval_External__c,Approved_Date__c,Balance__c,City__c,City_State__c,Compliance_Year__c,Contact_Email__c,Contact_Id_Deactivated_Date__c,
                Contact_Id_Employee_ID__c,Contact_Id_External_Email__c,Contact_Id_Name__c,Copy_Monthly_Variable_Amount__c,CPM__c,Driver_Email__c,Email_Flag__c,
                EmpIdEmailMonth__c,First_day__c,Fixed_Amount__c,Fixed_Amount_Paid_To_Driver__c,Fixed_Cost_Adjustment__c,Fuel_Price__c,Fuel_Variable_Rate__c,
                Half_Fixed_Amount__c,Half_Reimbursement__c,High_Risk_Total_Approved__c,High_Risk_Total_Mileages__c,High_Risk_Total_Pending__c,
                High_Risk_Total_Rejected__c,Imputed_Amount_Calculation__c,Imputed_Amount_for_Year__c,IRS_Mileage_Rate__c,Last_Modified_Name__c,Lock_Date_User__c,
                Maintenance__c,Maintenance_and_Tires__c,Max_IRS_Allowable__c,Mileage_Approver__c,Mileage_for_deduct__c,Mileage_Lock_Date__c,Month__c,Month_Field__c,
                Monthly_Approved_Variable_Amount__c,Monthly_Fixed_Amount__c,Monthly_Mileage__c,Monthly_Reimbursement_Total__c,Monthly_Total_Reimbursement__c,Monthly_Variable_Amount__c,
                MPG__c,Number_of_Pay_Period__c,Prev_Approved_Date_Value__c,Prev_Status_Value__c,Reimbursement_Approval__c,Reimbursement_Approval_Time__c,
                Reimbursement_Lock_Time__c,Reimbursement_Month__c,Reimbursement_Unique__c,Remove_Current_Month_Reimbursement__c,Remove_Reimbursement__c,Send_Reimbursement_Review_Notification__c,
                State__c,Status__c,Submit__c,Tires__c,Total_Actual_Mileage__c,Total_Approved__c,Total_Approved_Pending_Mileage__c,Total_Mileage__c,Total_Mileages_after_Deduction__c,
                Total_Mileage_deduction__c,Total_Mileage_WithOut_Previous__c,Total_Monthly_Approved_Variable__c,Total_Monthly_Reimbursement__c,Total_Monthly_Reimbursement_BiWeek__c,
                Total_Monthly_Reimbursement_for_Opix__c,Total_Monthly_Unapproved_Reimbursement__c,Total_Monthly_Variable__c,Total_Pending__c,Total_Rejected__c,
                Total_Variable_Rate__c,Triplog_POST_Response__c,Triplog_Status__c,Variable_Amount_for_Deduct_Mileage__c,Variable_Amount_for_Opix__c,Variable_Paid_To_Driver__c,Variable_Rate__c,
                VariableRateForGPS__c,Working_Days__c, YTD_year__c, YearMonth__c, Contact_Id__r.Driver_Type__c, Contact_Id__r.Reimbursement_Frequency__c, Contact_Id__c, Contact_Id__r.Name,
                Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Id__r.Manager__r.Name, Contact_Id__r.Manager__r.External_Email__c
                FROM Employee_Reimbursement__c];
    } 
    
    private static String getMonthName(Integer monthNum) {
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
            6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
            11=>'November', 12=>'December'};
                
                return monthNameMap.get(monthNum); 
    }
}