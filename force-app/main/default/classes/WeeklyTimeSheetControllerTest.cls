@isTest
public with sharing class WeeklyTimeSheetControllerTest {
     public static testmethod void method1(){
         TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'SendEmailForSubmittedMileage');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account acc ;
        List<Contact> conList;
       
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Ermi',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            acc = TestDataFactory.createAccount(true,'Ermi',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            update acc;
           
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].External_Email__c = 'minkesh.patel1478@gmail.com';
            update conList[0];
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
         List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-7),System.today().addDays(-1), 1, createIRSRate.Id);
        
        Test.startTest();
        WeeklyTimeSheetController objbatch = new WeeklyTimeSheetController();
        objbatch.getWeeklyDriversData();
        WeeklyTimeSheetController millock1 = new WeeklyTimeSheetController();
            String sch = '0 0 2 * * ?'; 
      system.schedule('Test Territory Check', sch, millock1);
      Test.stopTest();
    }
}