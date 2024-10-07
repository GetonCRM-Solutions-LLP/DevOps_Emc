@isTest
public class mileageremoveapprovaldateTest {
    @isTest
    public static void TestMethod1(){
        TriggerConfig__c cusmsetting = TestDataFactory.triggerConfigCustomSetting(True);
        SendEmail__c  SendEmailcusmsetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc;
        Account acc2;
        List<Contact> con ;
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True, 'Test Account', true);
            Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            con = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2); 
            userObj = TestDataFactory.createUser(True, profileObj.Id, con[0].Id);
        }
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(true, con, 0, createIRSRate.Id);
        er[0].Status__c = 'Approved' ;
        update er;
        
        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, con, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (True, 1, er, br);
        emp1[0].Trip_Date__c = system.today().addDays(-1);
        update emp1;
        
        test.startTest();
        MileageTriggerHandler.MileageRemoveApprovalDateHandler(emp1);
        MileageTriggerHandler.updateWorkingDays(emp1);
        MileageTriggerHandler.workingDaysforBiweeklyDrivers(emp1);
        

        delete emp1;
        test.stopTest();
    }

}