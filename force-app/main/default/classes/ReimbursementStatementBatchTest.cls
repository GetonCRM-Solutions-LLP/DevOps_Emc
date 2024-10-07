@isTest
public with sharing class ReimbursementStatementBatchTest {
     public static testmethod void method1(){
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmailonDeactivation__c objSendEmail = TestDataFactory.sendEmailCustomSetting(true, 'YearToDateReimbursementStatement', 'test.email@gmail.com');
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2019 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        insert vehicleType;
       
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(true,'Delta',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, conList, 10, irsRateObj.id);
        system.assertEquals(11, reimList.size(),true);
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim(true, conList, system.today().adddays(-14), system.today().addDays(-1), 10, irsRateObj.id);
        System.runAs(userObj) {
            //ReimbursementStatementBatch objbatch1 = new ReimbursementStatementBatch('02-2022');
            //Database.executeBatch(objbatch1,1); 
            ReimbursementStatementBatch objbatch = new ReimbursementStatementBatch();
            Database.executeBatch(objbatch,1); 
    
        }
    }
}