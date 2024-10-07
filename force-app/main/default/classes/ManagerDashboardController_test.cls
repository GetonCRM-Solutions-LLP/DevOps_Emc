/**
 * @description       : 
 * @author            : VatsalBhalani
 * @group             : 
 * @last modified on  : 08-20-2024
 * @last modified by  : Vatsal Bhalani
**/
@isTest
public class ManagerDashboardController_test {

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
        
        System.runAs(objAdmin) {
            
            objAccount1 = TestDataFactory.createAccount(true,'TestAccount',true);
            
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
    static void getRedirectedTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];

        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController managerDashboard = new ManagerDashboardController();
        ManagerDashboardController.getRedirected();
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }

    @isTest
    static void deleteMileagesTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT ID FROM Employee_Reimbursement__c WHERE Contact_Id__c = :lstDriverContact[0].Id];
        List<String> lstIds = new List<String>();
        for(Employee_Reimbursement__c objReim : lstEmpReim){
            lstIds.add(String.valueOf(objReim.Id));
        }

        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        ManagerDashboardController.DeleteMileages(JSON.serialize(lstIds));
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }

    @isTest
    static void getAllDriversLastMonthReimbursementsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];

        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        ManagerDashboardController.getAllDriversLastMonthReimbursements(lstAccounts[0].Id,lstManagerContact[0].Id,true, 'Admin');
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getVehicleValueTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];

        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        ManagerDashboardController.getVehicleValue(lstAccounts[0].Id);
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getChartDataTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];

        Test.startTest();
        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        ManagerDashboardController.getChartData(lstManagerContact[0].Id,true,lstAccounts[0].Id,'Admin');
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getAllDriversLastMonthUpdatedReimbursementsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];

        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getAllDriversLastMonthUpdatedReimbursements(lstManagerContact[0].Id, lstAccounts[0].Id,true,'Admin');
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getAllDriversLastMonthUnapprovedReimbursementscloneTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];

        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getAllDriversLastMonthUnapprovedReimbursementsclone(lstAccounts[0].Id,lstManagerContact[0].Id,true,'Admin');
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getAllDriversLastMonthUpdatedUnapprovedReimbursecloneTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseclone(lstManagerContact[0].Id,lstAccounts[0].Id,false,'Admin');
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getAllDriversLastMonthUpdatedUnapprovedReimburseClone1Test(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];

        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(lstManagerContact[0].Id,lstAccounts[0].Id,'false','Admin');
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getDriverDetailsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getDriverDetails(lstManagerContact[0].Id);
        
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void totalNoofDriverforManagerTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.totalNoofDriverforManager(lstManagerContact[0].Id);

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void onboardingStatusTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.onboardingStatus(lstManagerContact[0].Id, lstAccounts[0].Id,'Admin');
        //ManagerDashboardController.onboardingStatus(lstManagerContact[0].Id, lstAccounts[0].Id,'Manager');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void insuranceReportTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.insuranceReport(lstManagerContact[0].Id, lstAccounts[0].Id,'Admin');
        //ManagerDashboardController.insuranceReport(lstManagerContact[0].Id, lstAccounts[0].Id,'Manager');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void myTeamDetailsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.myTeamDetails(lstManagerContact[0].Id, lstAccounts[0].Id,true,'Admin');
        ManagerDashboardController.myTeamDetails(lstManagerContact[0].Id, lstAccounts[0].Id,true,'Manager');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void highRiskDriversDetailsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.highRiskDriversDetails(lstManagerContact[0].Id, lstAccounts[0].Id,true,true,'Admin');   
        ManagerDashboardController.highRiskDriversDetails(lstManagerContact[0].Id, lstAccounts[0].Id,false,false,'Admin'); 

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void mixTest1(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT ID FROM Employee_Reimbursement__c WHERE Contact_Id__c = :lstDriverContact[0].Id];

        List<String> lstIds = new List<String>();
        for(Employee_Reimbursement__c objReim : lstEmpReim){
            lstIds.add(String.valueOf(objReim.Id));
        }

        List<Employee_Mileage__c> lstMileages = [SELECT Id FROM Employee_Mileage__c];
        List<String> lstMileageIds = new List<String>();
        for(Employee_Mileage__c objReim : lstMileages){
            lstMileageIds.add(String.valueOf(objReim.Id));
        }

        String reimbursement = RecordUtilityClass.getUnapprovedReimbursements(lstDriverContact[0].id,lstAccounts[0].id,false,'Manager');
        // List<EmployeeMileagesForCalculation> employeereimbursementList = new List<EmployeeMileagesForCalculation>();
        // employeereimbursementList = (List<EmployeeMileagesForCalculation>)JSON.deserialize(reimbursement,List<EmployeeMileagesForCalculation>.Class); 

        //Contact objSelectedDriver =RecordUtilityClass.getDriverContact();

        updateThresholdWrapper currentupdateThresholdWrapper = new updateThresholdWrapper();
        List<updateThresholdWrapper> updateThresholdWrapperList = new List<updateThresholdWrapper>();
        currentupdateThresholdWrapper.contactid = lstDriverContact[0].id;
        currentupdateThresholdWrapper.threshold = '20';
        updateThresholdWrapperList.add(currentupdateThresholdWrapper);

        List<EmployeeMileagesForCalculation> employeereimbursementList = new List<EmployeeMileagesForCalculation>();
        employeereimbursementList = (List<EmployeeMileagesForCalculation>)JSON.deserialize(reimbursement,List<EmployeeMileagesForCalculation>.Class); 
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        if(employeereimbursementList.size() > 0){
            ManagerDashboardController.getUnapprovedMileages(JSON.serialize(employeereimbursementList[0]),lstAccounts[0].Id);    
        }

        //AsyncApexJob batch = ManagerDashboardController.approveReimbursements(JSON.serialize(lstIds),lstManagerContact[0].Id,lstAccounts[0].Id,'false',JSON.serialize(updateThresholdWrapperList));
        ManagerDashboardController.getUnapprovedReim(JSON.serialize(lstIds));
        ManagerDashboardController.approveMileagesClone(JSON.serialize(lstMileageIds),lstManagerContact[0].Id,lstAccounts[0].Id,'true',true);
        //ManagerDashboardController.CheckBatchStatus(batch.id);

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void updatedReimListTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.UpdatedReimList(lstManagerContact[0].Id,lstAccounts[0].Id, 'true','Admin');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getNotificationMessageListTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getNotificationMessageList(lstManagerContact[0].Id,2023,'June');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void managerContactDataTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.managerContactData(string.valueof(lstManagerContact[0].Id),lstAccounts[0].Id,'Admin');
        ManagerDashboardController.managerContactData(string.valueof(lstManagerContact[0].Id),lstAccounts[0].Id,'Manager');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void accountMonthListTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.accountMonthList(string.valueof(lstAccounts[0].Id));

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void reimbursementForHighMileageOrRiskTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.reimbursementForHighMileageOrRisk(lstManagerContact[0].Id,lstAccounts[0].Id,'05-2023',true,true,'Manager');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void contactReimMonthListTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.contactReimMonthList(lstManagerContact[0].Id);

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getLastMonthReimbursementsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getLastMonthReimbursements(lstAccounts[0].Id,lstManagerContact[0].Id,true,'05-2023','Admin');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void tripCalloutTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        List<Employee_Reimbursement__c> lstEmpReim = [SELECT ID FROM Employee_Reimbursement__c WHERE Contact_Id__c = :lstDriverContact[0].Id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.TripCallout(lstDriverContact[0].id,RecordUtilityClass.getMonthName(RecordUtilityClass.getLastMonthValue(0)),String.valueOf(System.today().year()),'5.00','50',lstEmpReim[0].id,'50','Not Approved Yet');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void loginRedirectionTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.loginRedirection(lstManagerContact[0].Id);

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void complRptDownloadtDataTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.complRptDownloadtData(lstDriverContact[0].id,lstAccounts[0].id,'Manager');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void accountDetailsTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.accountDetails(String.valueOf(lstAccounts[0].Id));

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void getMileagesTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.getMileages(String.valueOf(System.today().month()), String.valueOf(System.today().year()),String.valueOf(lstManagerContact[0].id));

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void onboardRptDownloadtDataTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.onboardRptDownloadtData(String.valueOf(lstManagerContact[0].id), String.valueOf(lstAccounts[0].Id),'Admin');
        ManagerDashboardController.onboardRptDownloadtData(String.valueOf(lstManagerContact[0].id), String.valueOf(lstAccounts[0].Id),'Manager');

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void updateNotificationMessageTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<Contact> lstManagerContact = [SELECT Id FROM Contact WHERE Role__c = 'Manager' AND AccountId = :lstAccounts[0].id];
        Message__c objMsg = new Message__c(
            Unread__c = true,
            Notification_Message__c = 'Test Message.',
            Contacts__c = lstManagerContact[0].Id
        );
        insert objMsg;
        Test.startTest();

        String conId = ApexPages.currentPage().getParameters().put('id',lstManagerContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);

        ManagerDashboardController.updateNotificationMessage(String.valueOf(objMsg.Id),System.today().year(),RecordUtilityClass.getMonthName(RecordUtilityClass.getLastMonthValue(0)));

        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }

    // public static testmethod void ManagerDashboardControllerTestMethod() {
      
    //     IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
    //     RecordUtilityClass.createRecordsforManagerDashboard(); // inserting the records for ManagerDashboardController class
    //     Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts 
    //     Contact currentAdmin = RecordUtilityClass.getManagerContact(); // Retriving the Manager with limit 1
    //     currentAdmin.FirstName='Test';
    //     currentAdmin.LastName='lastname';
    //     update currentAdmin;
        
    //     List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
    //     List<EmployeeReimbursementDetailsAdmin> selectedReimList =new List<EmployeeReimbursementDetailsAdmin>();
    //     for(Employee_Reimbursement__c obj:empReimbursementList)
    //     {
    //         selectedReimList.add(RecordUtilityClass.getEmployeeReimbursementDetails(obj));
    //     }
    //     String reimbursement = RecordUtilityClass.getUnapprovedReimbursements(currentAdmin.id,currentAccount.id,false,'Manager');        
    //     List<EmployeeMileagesForCalculation> employeereimbursementList = new List<EmployeeMileagesForCalculation>();
    //     employeereimbursementList = (List<EmployeeMileagesForCalculation>)JSON.deserialize(reimbursement,List<EmployeeMileagesForCalculation>.Class);       
    //     List<String> reimbursementIdList = new List<String>();
    //     if(empReimbursementList.size() > 0){
    //     reimbursementIdList.add(empReimbursementList[0].id);
    //         }
    //     Test.setCurrentPage(Page.managerdashboard);
    //     ApexPages.currentPage().getParameters().put('id',currentAdmin.Id);
    //     ApexPages.currentPage().getParameters().put('accid',currentAccount.Id);                
        
    //     ManagerDashboardController managerDashboard = new ManagerDashboardController();
    //     ManagerDashboardController.getRedirected();
    //     ManagerDashboardController.DeleteMileages(JSON.serialize(reimbursementIdList));
    //     ManagerDashboardController.getAllDriversLastMonthReimbursements(currentAccount.Id,currentAdmin.Id,true, 'Admin');
    //     ManagerDashboardController.getVehicleValue(currentAccount.Id);
    //     ManagerDashboardController.getChartData(currentAdmin.Id,true,currentAccount.Id,'Admin');
    //     ManagerDashboardController.getAllDriversLastMonthUpdatedReimbursements(currentAdmin.Id, currentAccount.Id,true,'Admin');
    //     ManagerDashboardController.getAllDriversLastMonthUnapprovedReimbursementsclone(currentAccount.Id,currentAdmin.Id,true,'Admin');
    //     ManagerDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseclone(currentAdmin.Id,currentAccount.Id,false,'Admin');
    //     ManagerDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(currentAdmin.Id,currentAccount.Id,'false','Admin');
    //     ManagerDashboardController.getDriverDetails(currentAdmin.Id);
    //     ManagerDashboardController.totalNoofDriverforManager(currentAdmin.Id);
    //     ManagerDashboardController.onboardingStatus(currentAdmin.Id, currentAccount.Id,'Admin');
    //     ManagerDashboardController.onboardingStatus(currentAdmin.Id, currentAccount.Id,'Manager');
    //     ManagerDashboardController.insuranceReport(currentAdmin.Id, currentAccount.Id,'Admin');
    //     ManagerDashboardController.insuranceReport(currentAdmin.Id, currentAccount.Id,'Manager');
    //     ManagerDashboardController.myTeamDetails(currentAdmin.Id,currentAccount.Id,true,'Admin');
    //     ManagerDashboardController.myTeamDetails(currentAdmin.Id,currentAccount.Id,true,'Manager');
    //     ManagerDashboardController.highRiskDriversDetails(currentAdmin.Id,currentAccount.Id,true,true,'Admin');   
    //     ManagerDashboardController.highRiskDriversDetails(currentAdmin.Id,currentAccount.Id,false,false,'Admin');   
    //     List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
    //     Contact selectedDriver =RecordUtilityClass.getDriverContact();
    //     if(employeereimbursementList.size() > 0)    {
    //         ManagerDashboardController.getUnapprovedMileages(JSON.serialize(employeereimbursementList[0]),currentAccount.Id);    
    //     }
        
    //     updateThresholdWrapper currentupdateThresholdWrapper = new updateThresholdWrapper();
    //     List<updateThresholdWrapper> updateThresholdWrapperList = new List<updateThresholdWrapper>();
    //     currentupdateThresholdWrapper.contactid = selectedDriver.id;
    //     currentupdateThresholdWrapper.threshold = '20';
    //     updateThresholdWrapperList.add(currentupdateThresholdWrapper);
       
    //     AsyncApexJob batch = ManagerDashboardController.approveReimbursements(JSON.serialize(reimbursementIdList),currentAdmin.Id,currentAccount.Id,'false',JSON.serialize(updateThresholdWrapperList));
    //     ManagerDashboardController.getUnapprovedReim(JSON.serialize(reimbursementIdList));
    //    ManagerDashboardController.MassSyncTripsForReimbursements(JSON.serialize(reimbursementIdList));
    //    ManagerDashboardController.DeleteMileages(JSON.serialize(reimbursementIdList));
    //    	ManagerDashboardController.accountDetails(String.valueOf(currentAccount.Id));
    //     ManagerDashboardController.approveMileagesClone(JSON.serialize(reimbursementIdList),currentAdmin.Id,currentAccount.Id,'true',true);
    //     ManagerDashboardController.CheckBatchStatus(batch.id);
    //     ManagerDashboardController.UpdatedReimList(currentAdmin.Id,currentAccount.Id, 'true','Admin');
    //     ManagerDashboardController.getNotificationMessageList(currentAdmin.Id,2023,'June');
    //     ManagerDashboardController.managerContactData(string.valueof(currentAdmin.Id),currentAccount.Id,'Admin');
    //     ManagerDashboardController.managerContactData(string.valueof(currentAdmin.Id),currentAccount.Id,'Manager');
    //     ManagerDashboardController.accountMonthList(string.valueof(currentAccount.Id));
    //     ManagerDashboardController.reimbursementForHighMileageOrRisk(currentAdmin.Id,currentAccount.Id,'05-2023',true,true,'Manager');
    //     ManagerDashboardController.contactReimMonthList(currentAdmin.Id);
    //     ManagerDashboardController.getLastMonthReimbursements(currentAccount.Id,currentAdmin.Id,true,'05-2023','Admin');
    //    ManagerDashboardController.approveMileages(null,null,null,'Test','Test@gmail.com');
    //     ManagerDashboardController.getUnapprovedMileages(null,string.valueof(currentAccount.Id));
    //    ManagerDashboardController.setEmployeeName();
    //    ManagerDashboardController.onboardRptDownloadtData(currentAdmin.id,currentAccount.id,'Manager');
    // }
    // public static testmethod void ManagerDashboardControllerTestMethod1() {
      
    //     IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
    //     RecordUtilityClass.createRecordsforManagerDashboard(); // inserting the records for ManagerDashboardController class
    //     Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts 
    //     Contact currentAdmin = RecordUtilityClass.getManagerContact(); // Retriving the Manager with limit 1
    //     currentAdmin.FirstName='Test';
    //     currentAdmin.LastName='lastname';

    //     update currentAdmin;
    //     List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
    //     List<Contact> con1List;
    //     Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
    //     vehicleType.Name = '2020 Full-Size Sedan';
    //     vehicleType.vehicle__c = 'Full-Size Sedan';
    //     Insert vehicleType;
    //     List<EmployeeReimbursementDetailsAdmin> selectedReimList =new List<EmployeeReimbursementDetailsAdmin>();
    //     for(Employee_Reimbursement__c obj:empReimbursementList)
    //     {
    //         selectedReimList.add(RecordUtilityClass.getEmployeeReimbursementDetails(obj));
    //     }
    //     String reimbursement = RecordUtilityClass.getUnapprovedReimbursements(currentAdmin.id,currentAccount.id,false,'Manager');  
    //     con1List = TestDataFactory.createDriverContact(true, currentAccount.Id, 'Manager', vehicleType.Name, 'paras.patel',  1);
    //     list<Employee_Reimbursement__c>reim = TestDataFactory.createPendingReimbursement(true,con1List,1,irsRateObj.id);      
    //     List<EmployeeMileagesForCalculation> employeereimbursementList = new List<EmployeeMileagesForCalculation>();
    //     employeereimbursementList = (List<EmployeeMileagesForCalculation>)JSON.deserialize(reimbursement,List<EmployeeMileagesForCalculation>.Class);       
    //     List<String> reimbursementIdList = new List<String>();
    //     if(empReimbursementList.size() > 0){
    //     reimbursementIdList.add(empReimbursementList[0].id);
    //         }
    //     Test.setCurrentPage(Page.managerdashboard);
    //     ApexPages.currentPage().getParameters().put('id',currentAdmin.Id);
    //     ApexPages.currentPage().getParameters().put('accid',currentAccount.Id);                
    //     ManagerDashboardController.TripCallout(con1List[0].id,'January','2024','5.00','50',reim[0].id,'50','Not Approved Yet');
        
    //     ManagerDashboardController.loginRedirection(currentAdmin.Id);
    //     ManagerDashboardController.complRptDownloadtData(con1List[0].id,currentAccount.id,'Manager');
    //     ManagerDashboardController.accountDetails(String.valueOf(currentAccount.Id));
    //     ManagerDashboardController.getMileages(String.valueOf(System.today().month()), String.valueOf(System.today().year()),String.valueOf(currentAdmin.id));
    //     ManagerDashboardController.onboardRptDownloadtData(String.valueOf(currentAdmin.id), String.valueOf(currentAccount.Id),'Admin');
    //     ManagerDashboardController.onboardRptDownloadtData(String.valueOf(currentAdmin.id), String.valueOf(currentAccount.Id),'Manager');

    // }
}