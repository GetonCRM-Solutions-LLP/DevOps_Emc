@isTest
public class GetTripfromTriplogBatchClassTest {
    
    public static testmethod void GetTriptest() {
        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();

        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'Defaulttrigger');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        
        Get_Trip_Date_Settings__c obj_Get_Trip_Date_Settings = new Get_Trip_Date_Settings__c();
        obj_Get_Trip_Date_Settings.Name ='Date Settings';
        obj_Get_Trip_Date_Settings.Start_Date__c ='2020-08-01';
        obj_Get_Trip_Date_Settings.End_Date__c ='2020-08-31';
        obj_Get_Trip_Date_Settings.Last_N_Days__c ='31';
        insert obj_Get_Trip_Date_Settings;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account acc ;
        List<Contact> conList;
       
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            acc = TestDataFactory.createAccount(true,'Test',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            update acc;
           
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].External_Email__c = 'minkesh.patel1478@gmail.com';
            Insert conList[0];
            contactids.add(conList[0].Id);
            
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
        
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, conList, 1, createIRSRate.Id);
        er[0].Approved_Date__c = system.today()-4;
        er[0].Month__c = '09-2017';
        er[0].Status__c = 'Approved';
        Insert er[0];
        
        conReim.put(conList[0].Id,er[0]);

        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (false, conList, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
        br = TestDataFactory.createBiweeklyReim (false, conList, System.today().addDays(-13),System.today().addDays(0), 2, createIRSRate.Id);
        insert br;       
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (False, 1, er, br);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].Approved_Date__c = system.today();
        Insert emp1[0];

        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetTripfromTriplogBatchClass obj = new GetTripfromTriplogBatchClass('U', false);
        GetTripfromTriplogBatchClass obj1 = new GetTripfromTriplogBatchClass(Acc.Id,'U');
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
}