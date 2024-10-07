@isTest
public class TripDetailReportControllerTest {
    @isTest 
    static void utilMethod1() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);       
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, conList, 10, irsRateObj.id);
        system.assertEquals(11, reimList.size(),true);
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim(true, conList, system.today().adddays(-14), system.today().addDays(-1), 10, irsRateObj.id);

        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (False, 0, reimList, biWeeklyReimList);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].Trip_Date__c = System.today();
        emp1[0].Approved_Date__c = system.today();
        Insert emp1;

        Attachment attach = TestDataFactory.createAttachment(true, conList[0].id);
        List<Attachment> attachments = [select id, name from Attachment where parent.id =: conList[0].id];
        
        Test.startTest();
        System.runAs(userObj) {           
            String startDate = string.valueOf(system.today().addDays(-2));
            String endDate = string.valueOf(system.today().addDays(3));
            TripDetailReportController.drivingTime(startDate,endDate,acc.Id);
        Test.stopTest();
        }
    }
}