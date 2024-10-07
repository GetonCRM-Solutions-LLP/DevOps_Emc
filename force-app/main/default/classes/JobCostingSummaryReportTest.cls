@isTest
public with sharing class JobCostingSummaryReportTest {
    public static testmethod void test1(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');    
        daylight_saving_time_config__c  dayLightCustomSetting = TestDataFactory.daylightCustomSetting(true, '2022' ,system.today(), date.valueOf(system.today().addDays(60))); 
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 2);
        vehicleType.Name = '2020 AWD Ford Escape';
        vehicleType.vehicle__c = 'AWD Ford Escape';
        Insert vehicleType;
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;

        Account acc;
        List<Contact> contact;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(True,'Delta account',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            acc = TestDataFactory.createAccount(True,'Delta account',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            Acc.Triplog_Status__c = 'U';
            acc.Pay_Period_Days__c = 13;
            Update acc;

            contact = TestDataFactory.createDriverContact(true,acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contact[0].Id);
        }
        
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, contact, 2, irsRateObj.id);
        system.assertEquals(3, reimList.size(),true);

        List<Bi_Weekly_Reimbursement__c> biweeklyReimList = TestDataFactory.createBiweeklyReim(true, contact,  date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 3, irsRateObj.id);
        List<Employee_Mileage__c> mileageList = TestDataFactory.getEmpMileage(false, 2, reimList, biweeklyReimList);
        mileageList[1].Tag__c = 'Admin';
        mileageList[1].Trip_Date__c = date.valueOf('2021-06-02');
        insert mileageList;
        system.debug('mileageList== '+mileageList.size() );
        Test.startTest();
        Test.setCurrentPage(Page.JobCostingSummary);
        String conId = ApexPages.currentPage().getParameters().put('id',contact[0].Id);
        String startDate = ApexPages.currentPage().getParameters().put('startDate','2021-06-01');
        String endDate = ApexPages.currentPage().getParameters().put('endDate','2021-08-28');
        JobCostingSummaryReport objClass = new JobCostingSummaryReport();
        JobCostingSummaryReport.MileageTagWrapper obj = new JobCostingSummaryReport.MileageTagWrapper();
        obj.tag = 'test';
        obj.mileage = 12.22;
        obj.variable = 43.33;
        Test.stopTest();
    }
}