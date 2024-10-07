@istest
public class SendEmailForSubmittedMileageTest {
    public static testmethod void testMethod4(){

        Set<Id> contactids = new Set<Id>();
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'SendEmailForSubmittedMileage');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account acc ;
        List<Contact> conList;
       
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            acc = TestDataFactory.createAccount(true,'Test Account',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            update acc;
           
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].External_Email__c = 'minkesh.patel1478@gmail.com';
            update conList[0];
            contactids.add(conList[0].Id);
            
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
        
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, conList, 1, createIRSRate.Id);
        er[0].Approved_Date__c = system.today()-4;
        er[0].Month__c = lastMonth;
        er[0].Status__c = 'Approved';
        Insert er[0];        

        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
             
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (False, 0, er, br);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].Approved_Date__c = system.today();
        Insert emp1;

        List<Employee_Mileage__c> emp2 = TestDataFactory.getEmpMileage (False, 0, er, br);
        emp2[0].Trip_Status__c = 'Approved';
        emp2[0].Approved_Date__c = system.today();
        Insert emp2;
        
        SendEmailForSubmittedMileage mil = new SendEmailForSubmittedMileage();
        Database.executeBatch(mil, 1);
    }
}