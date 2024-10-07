@istest
public class UpdateLastToLastMonthMileagesBatchTest {
    
    public static testmethod void testMethod3(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'SendEmailForSubmittedMileage');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account acc ;
        List<Contact> conList;
        
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test Account',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            
            acc = TestDataFactory.createAccount(true,'Test Account',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            update acc;
            
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
        
        String lastMonth = Utils.fetchMonths(2, 1)[1];
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, conList, 1, createIRSRate.Id);
        er[0].Approved_Date__c = system.today()-4;
        er[0].Month__c = lastMonth;
        er[0].Status__c = 'Approved';
        Insert er[0];
        
        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);   
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (True, 0, er, br);
        Batch_Setup__c btstp = TestDataFactory.getTestBatchSetup(True);
        
        UpdateLastToLastMonthMileagesBatch last = new UpdateLastToLastMonthMileagesBatch();
        Database.executeBatch(last, 1);
    } 
    
    /* public static testmethod void testMethod4(){
TriggerConfig__c customSetting =  new TriggerConfig__c();
customSetting.Name = 'Defaulttrigger';
customSetting.MappingGasPriceTrigger__c = true;
insert customSetting;

SendEmail__c customSetting1 =  new SendEmail__c();
customSetting1.Name = 'Send Email For Compliance';
customSetting1.Send_email_from_code__c= true;
insert customSetting1;

Account acc = TestUtilityClass.getTestSingleAccount();
Contact con = TestUtilityClass.getTestSingleContact(acc);
Employee_Reimbursement__c emp = TestUtilityClass.getTestEmployeeReimbursement(con);
Contact cont =TestUtilityClass.getTestSingleContact2(acc);
Employee_Reimbursement__c empr = TestUtilityClass.getTestEmployeeReimbursement3(cont);
Employee_Mileage__c empMil = TestUtilityClass.getTestEmployeeMileage(emp);
Batch_Setup__c batc = TestUtilityClass.getTestBatchSetup();
UpdateLastToLastMonthMileagesBatch last = new UpdateLastToLastMonthMileagesBatch();
Database.executeBatch(last, 1);
} 
*/
}