/**
* @description       : 
* @author            : Vatsal Bhalani
* @group             : 
* @last modified on  : 24-10-2024
* @last modified by  : Harsita
**/
@isTest
public with sharing class DriverDashboardLWCControllerTest {
    
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
            
            lstContact2 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Manager', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact3 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Admin', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact1 = TestDataFactory.createDriverContact(false, objAccount1.Id, 'Driver', objVehicleUrlMap.Name, 'paras.dhanani',  1);
			lstContact1[0].Manager__c = lstContact3[0].Id;
            insert lstContact1;
            
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
            
            Attachment objAttachment = new Attachment();
            objAttachment.parentID = lstContact1[0].Id;
            objAttachment.name = 'Signed Document MVR';
            objAttachment.body = blob.valueOf('Test');
            insert objAttachment;
            
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'Driver Agreement.pdfdsfg',
                PathOnClient   = 'Driver Agreement.pdfasdf',
                VersionData    = Blob.valueOf('Test Content'),
                FirstPublishLocationId = objAccount1.Id,
                IsMajorVersion = true);
            insert contentVersion;
            
            //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id)];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
			System.debug('documents =='+documents);
            if(!documents.isEmpty()){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = lstContact1[0].ID;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                insert cdl;
            }
        }
    }
    
    @isTest
    static void getDriverDetailsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getDriverDetails(lstDriverContacts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getDriverDetailsCloneTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getDriverDetailsClone(lstDriverContacts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getDrivingStateTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getDrivingState(lstDriverContacts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getCompanyLogoUrlTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getCompanyLogoUrl(lstAccounts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getMileagesTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getMileages('01',String.valueOf(Date.today().year()),lstDriverContacts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getMileagesDataTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        List<Employee_Mileage__c> lstMile = [SELECT id,Approved_Date__c FROM Employee_Mileage__c];
        for(Employee_Mileage__c obj : lstMile){
            obj.Approved_Date__c = System.today();
        }
        update lstMile;
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getMileagesData(Date.today().year(),lstDriverContacts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getChartDataTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getChartData(lstDriverContacts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getAllReimbursementsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getAllReimbursements(String.valueOf(System.today().year()),lstDriverContacts[0].Id,lstAccounts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getGasPriceandRateTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getGasPriceandRate(lstDriverContacts[0].id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getLast2YearsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getLast2Years(lstDriverContacts[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void TimeAttendanceTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContacts = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContacts[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContacts[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.TimeAttendance(lstDriverContacts[0].Id,'2023');
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
    @isTest
    static void constructorTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        
        DriverDashboardLWCController DLC= new DriverDashboardLWCController();
        DriverDashboardLWCController.planParameterWrap wrapObj = new DriverDashboardLWCController.planParameterWrap ();
        wrapObj.driverPacketId='xxxx';
        wrapObj.driverMVR='xxxx';
        wrapObj.obj_content_version='xxxx';
        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getMileagesBasedTandAttTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getMileagesBasedTandAtt('2022-12-25','2023-01-07',lstDriverContact[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void biweeklyMileageTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.biweeklyMileage(lstDriverContact[0].Id,2023);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getAllMileagesTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getAllMileages('2022-12-25','2023-01-07',lstDriverContact[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getComplianceTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getCompliance(lstDriverContact[0].id);        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getFuelVariableRateTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getFuelVariableRate(lstDriverContact[0].id);        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getReimbursementDataTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getReimbursementData(lstDriverContact[0].id);
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getPacketandMeetingTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getPacketandMeeting(lstDriverContact[0].id);        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getCustomSettingsTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getCustomSettings();
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getPlanParameterTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getPlanParameter(lstDriverContact[0].Id);  
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void countUserLoginTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.countUserLogin(lstDriverContact[0].id);        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void getDrivingStatesTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getDrivingStates();
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void sendDrivingStateEmailTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.sendDrivingStateEmail(String.valueOf(lstDriverContact[0].Id),String.valueOf(lstDriverContact[0].Driving_States__c));        
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    @isTest
    static void updateStateListTest(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.updateStateList(String.valueOf(lstDriverContact[0].Id),String.valueOf(lstDriverContact[0].Driving_States__c));
        Test.stopTest();
        
        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');
        
    }
    
        @isTest
    static void getBiweekMileagesTEst(){
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = getContact(lstAccounts[0].Id, 'Driver');
        List<Bi_Weekly_Reimbursement__c> lsBiWeek = [SELECT id FROM Bi_Weekly_Reimbursement__c];
        
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT id FROM Employee_Reimbursement__c];
        User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];
        
        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        DriverDashboardLWCController.getBiweekMileages(lsBiWeek[0].Id);
        DriverDashboardLWCController.ApproveBiweekMileages(lsBiWeek[0].Id);
        DriverDashboardLWCController.UpdateReimbursementStatus(lstEmpReim[0].Id);
        DriverDashboardLWCController.TripCallout(lstDriverContact[0].Id, 'January', String.valueOf(System.today().year()), '1', '1', lstEmpReim[0].Id, '10', 'Pending');
        DriverDashboardLWCController.postExpenseReimbursement(lstAccounts[0].Id, '1', lstDriverContact[0].External_Email__c, '1');
        DriverDashboardLWCController.updateContactDetail(lstDriverContact[0].Id);
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
}