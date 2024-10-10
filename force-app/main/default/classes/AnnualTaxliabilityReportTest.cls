@istest
public class AnnualTaxliabilityReportTest {

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
            
            objAccount1 = TestDataFactory.createAccount(true,'Delta account',true);
            
            lstVehicleValue = TestDataFactory.createVehicleValue(true, objAccount1.Id, objVehicleUrlMap.Id);
            
            lstContact1 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Driver', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact2 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Manager', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact3 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Admin', objVehicleUrlMap.Name, 'paras.dhanani',  1);

            objGenUser = TestDataFactory.createUser(true, objProfile.Id, lstContact1[0].Id);

            List<Employee_Reimbursement__c> lstEmpReim =TestDataFactory.createPendingReimbursement(true,lstContact1, 20, irsRateObj.Id);
            List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim =TestDataFactory.createBiweeklyReim(true, lstContact1, date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 2, irsRateObj.Id);
            List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 10, lstEmpReim, lstBiWeeklyReim);
            
        }
    }

    @isTest
    static void constructorTest(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];

        Test.startTest();
        Test.setCurrentPage(Page.AnnualTaxliabilityReport);
        String accid = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        // String currentYear = ApexPages.currentPage().getParameters().put('currentYear',String.valueOf(System.today().year()));
        String currentYear = ApexPages.currentPage().getParameters().put('Year',String.valueOf(System.today().year()));
        AnnualTaxliabilityReport objClass = new AnnualTaxliabilityReport();
        AnnualTaxliabilityReport.TaxLiabilityWrapper obj = new AnnualTaxliabilityReport.TaxLiabilityWrapper();
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void constructorTest2(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];

        Test.startTest();
        Test.setCurrentPage(Page.AnnualTaxliabilityReport);
        String accid = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        // String currentYear = ApexPages.currentPage().getParameters().put('currentYear',String.valueOf(System.today().year()));
        String currentYear = ApexPages.currentPage().getParameters().put('Year',String.valueOf(System.today().addyears(1).year()));
        AnnualTaxliabilityReport objClass = new AnnualTaxliabilityReport();
        AnnualTaxliabilityReport.TaxLiabilityWrapper obj = new AnnualTaxliabilityReport.TaxLiabilityWrapper();
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }

    // @istest
    // public static void CreateData() {
    //     TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
    //     SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
    //     TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
    //     Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
    //     IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);

    //     UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
    //     Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
    //     User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
    //     Account acc = new Account();     
    //     List<Contact> conList = new List<Contact>();
    //     List<Employee_Reimbursement__c>reim =new List<Employee_Reimbursement__c>();
    //     List<Employee_Mileage__c> emp =new List<Employee_Mileage__c>();
    //     List<Bi_Weekly_Reimbursement__c> biweek= new List<Bi_Weekly_Reimbursement__c>();        
        
    //     System.runAs(admin) {
    //         acc = TestDataFactory.createAccount(false,'Test',true);
    //         acc.Vehicle_Types__c=vehicleObj.name;
    //         acc.True_Dialog__c = true;
    //         acc.Vehicle_Types__c = vehicleObj.Name;
    //         Insert acc;
    //         conList = TestDataFactory.createDriverContact(True, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);       
            
    //         reim = TestDataFactory.createPendingReimbursement(false,conList,12,irsRateObj.id);
    //         reim[0].Status__c = 'Approved';
    //         reim[0].Month__c = date.today().addMonths(-1).Month() + '-' + date.today().addMonths(-1).Year();
    //         reim[0].Approved_Date__c = system.today();
    //         insert reim;
    //         biweek =TestDataFactory.createBiweeklyReim(True,conList,system.today().addDays(-15),system.today(),1,irsRateObj.id);            
           
    //         emp=TestDataFactory.getEmpMileage(true,3,reim,biweek);
            
    //         Test.startTest();
    //         Test.setCurrentPage(Page.AnnualTaxliabilityReport);
    //         String accid = ApexPages.currentPage().getParameters().put('accid',acc.Id);
    //         String currentYear = ApexPages.currentPage().getParameters().put('currentYear',String.valueOf(System.today().year()));
    //         AnnualTaxliabilityReport objClass = new AnnualTaxliabilityReport();
    //         AnnualTaxliabilityReport.TaxLiabilityWrapper obj = new AnnualTaxliabilityReport.TaxLiabilityWrapper();
    //         Test.stopTest();
    //     }
    // }
}