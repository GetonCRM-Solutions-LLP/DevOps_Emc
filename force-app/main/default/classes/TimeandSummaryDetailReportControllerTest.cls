@isTest

public with sharing class TimeandSummaryDetailReportControllerTest {
    @isTest    
    public static void test1(){
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
            SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
            daylight_saving_time_config__c  dayLightCustomSetting = TestDataFactory.daylightCustomSetting(true, '2022' ,system.today(), date.valueOf(system.today().addDays(60))); 
            IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
            Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true,0);

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

            List<Bi_Weekly_Reimbursement__c> biweeklyReimList = TestDataFactory.createBiweeklyReim(true, contact,  date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 2, irsRateObj.id);
            system.debug('biweeklyReimList== '+biweeklyReimList );
            List<Employee_Mileage__c> mileageList = TestDataFactory.getEmpMileage(true, 1, reimList, biweeklyReimList);
            
            Test.startTest();
            Test.setCurrentPage(Page.TimeandSummaryDetailReport);
            String conId = ApexPages.currentPage().getParameters().put('id',acc.Id);
            String startDate = ApexPages.currentPage().getParameters().put('startDate',String.valueOf(date.valueof(system.today().adddays(-14))));
            String endDate = ApexPages.currentPage().getParameters().put('endDate',String.valueOf(date.valueof(system.today().adddays(-1))));
            TimeandSummaryDetailReportController objClass = new TimeandSummaryDetailReportController();
            Test.stopTest();
    }
}