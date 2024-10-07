@isTest
public class BiWeekEmployeeReimbTriggerHandlerTest {
    public static testmethod void test1(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);                
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');        
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
   
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
           conList[0].Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement';
            update conList;
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
    
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, conList, 10, irsRateObj.id);
        system.assertEquals(11, reimList.size(),true);
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim(false, conList, system.today().adddays(-14), system.today().addDays(-1), 10, irsRateObj.id);
        biWeeklyReimList[0].Status__c = 'Approved';
        insert biWeeklyReimList;
        biWeeklyReimList[0].Count_Error_Check__c = 1 ;
        update biWeeklyReimList;
        biWeeklyReimList[0].Count_Error_Check__c = 2 ;
        update biWeeklyReimList ;
        biWeeklyReimList[0].Count_Error_Check__c = 3 ;
        update biWeeklyReimList ;
        List<Employee_Mileage__c> empMileage = TestDataFactory.getEmpMileage(true,5,reimList,biWeeklyReimList);
        Map<Id,Bi_Weekly_Reimbursement__c> empReimburseOld = new Map<Id,Bi_Weekly_Reimbursement__c>();
        empReimburseOld.put(biWeeklyReimList[0].Id,biWeeklyReimList[0]);
        set<Id> reimIdslst= new set<Id>();
        reimIdslst.add(biWeeklyReimList[0].Id);
        Test.startTest();
        System.runAs(userObj) {
            if(empMileage[0].Approved_Date__c == null ){
                empMileage[0].Approved_Date__c = biWeeklyReimList[0].Approved_Date__c ; 
            }
            
            if(empMileage[0].Rejected__c == true){
                empMileage[0].Trip_Status__c = 'Rejected';
            }
            update empMileage;
            BiWeekEmployeeReimbTriggerHandler biweeklyreim = new BiWeekEmployeeReimbTriggerHandler();
            BiWeekEmployeeReimbTriggerHandler.mileagefieldupdate(biWeeklyReimList,empReimburseOld,empReimburseOld);
            BiWeekEmployeeReimbTriggerHandler.updateConfirmFields(biWeeklyReimList,empReimburseOld,empReimburseOld);
            BiWeekEmployeeReimbTriggerHandler.IRSVehicleCHeck(reimIdslst);
        }
        Test.stopTest();
    }
}