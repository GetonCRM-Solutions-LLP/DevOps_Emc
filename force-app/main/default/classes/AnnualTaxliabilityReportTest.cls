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
        String currentYear = ApexPages.currentPage().getParameters().put('Year',String.valueOf(System.today().year()));
        AnnualTaxliabilityReport objClass = new AnnualTaxliabilityReport();
        AnnualTaxliabilityReport.TaxLiabilityWrapper obj = new AnnualTaxliabilityReport.TaxLiabilityWrapper();
        String header = objClass.xlsHeader;
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
    @isTest
    static void constructorTest2(){

        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];

        Test.startTest();
        Test.setCurrentPage(Page.AnnualTaxliabilityReport);
        String accid = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
        String currentYear = ApexPages.currentPage().getParameters().put('Year',String.valueOf(System.today().addyears(1).year()));
        AnnualTaxliabilityReport objClass = new AnnualTaxliabilityReport();
        AnnualTaxliabilityReport.TaxLiabilityWrapper obj = new AnnualTaxliabilityReport.TaxLiabilityWrapper();
        Test.stopTest();

        System.assertEquals(1, lstAccounts.size(), 'One Account Must be Created.');

    }
}