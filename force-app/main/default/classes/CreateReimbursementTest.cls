@isTest
public with sharing class CreateReimbursementTest {
    public static testmethod void reimburMethod1() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_1 = TestDataFactory.createIRSRate(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10, 43567);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;
        List<Contact> conList;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            update acc;
            
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'paras.dhanani',  1);
            Insert conList[0];
            
            system.assertEquals(1, conList.size(), true);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contactObj.Id);
        }    
        String lastMonth = Utils.fetchMonths(1, -1)[0];
        
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(false,conList,2, obj_IRS_Mileage_Rate_1.Id);
        reimList[0].EmpIdEmailMonth__c = '123';
        Insert reimList;
        
        Test.startTest();    
        CreateReimbursement abc = new CreateReimbursement(); 
        Database.executeBatch(abc);
        Database.SaveResult sr1 = (Database.SaveResult)
            JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
        Test.stopTest();
    }
}