@istest
public with sharing class DeleteTripsBatchTest {
   @TestSetup
   static void DeleteTripsdata(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        Account acc = new Account();
        List<Contact> conList = new List<Contact>();
        List<Employee_Reimbursement__c>reim =new List<Employee_Reimbursement__c>();
        List<Bi_Weekly_Reimbursement__c> biweek= new List<Bi_Weekly_Reimbursement__c>();
        List<Employee_Mileage__c> emp =new List<Employee_Mileage__c>();
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Vehicle_Types__c=vehicleObj.name;
            acc.True_Dialog__c = true;
            acc.Vehicle_Types__c = vehicleObj.Name;
            Insert acc;
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            reim = TestDataFactory.createPendingReimbursement(true,conList,1,irsRateObj.id);
            biweek =TestDataFactory.createBiweeklyReim(true,conList,system.today().addDays(-15),system.today(),1,irsRateObj.id);
            emp=TestDataFactory.getEmpMileage(true,3,reim,biweek);
        }
   }
   @istest
   public static void test(){
       list<Employee_Mileage__c>mileage =[select id  From Employee_Mileage__c ];
       test.startTest();
       DeleteTripsBatch i = new DeleteTripsBatch();
       Database.executeBatch(i,2000);
       test.stopTest();
   }
}