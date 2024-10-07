@istest
public with sharing class MonthlyComplianceStatusBatchTest {
    @TestSetup
    public static void CreateData() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        Account acc = new Account();     
        List<Contact> combinedList = new List<Contact>();
        List<Contact> conList = new List<Contact>();
        List<Contact> conList1 = new List<Contact>();
        List<Contact> conList2 = new List<Contact>();
        List<Contact> conList3 = new List<Contact>();
        List<Contact> conList4 = new List<Contact>();
        List<Contact> conList5 = new List<Contact>();
        List<Contact> conList6 = new List<Contact>();
        List<Contact> conList7 = new List<Contact>();
        List<Contact> conList8 = new List<Contact>();
        List<Contact> conList9 = new List<Contact>();
        List<Contact> conList10 = new List<Contact>();
        List<Contact> conList11 = new List<Contact>();
        List<Contact> conList12 = new List<Contact>();
        
        List<Employee_Reimbursement__c> combinedReimList = new List<Employee_Reimbursement__c>();
        List<Employee_Reimbursement__c>reim =new List<Employee_Reimbursement__c>();
        List<Employee_Reimbursement__c>reim1 =new List<Employee_Reimbursement__c>();
        List<Employee_Reimbursement__c>reim2 =new List<Employee_Reimbursement__c>();
        
        List<Employee_Mileage__c> combinedEmpList = new List<Employee_Mileage__c>();
        List<Employee_Mileage__c> emp =new List<Employee_Mileage__c>();
        List<Employee_Mileage__c> emp1 =new List<Employee_Mileage__c>();
        List<Employee_Mileage__c> emp2 =new List<Employee_Mileage__c>();
        
        List<Bi_Weekly_Reimbursement__c> combinedBiweekList = new List<Bi_Weekly_Reimbursement__c>();
        List<Bi_Weekly_Reimbursement__c> biweek= new List<Bi_Weekly_Reimbursement__c>();
        List<Bi_Weekly_Reimbursement__c> biweek1= new List<Bi_Weekly_Reimbursement__c>();
        List<Bi_Weekly_Reimbursement__c> biweek2= new List<Bi_Weekly_Reimbursement__c>();
        
        
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Vehicle_Types__c=vehicleObj.name;
            acc.True_Dialog__c = true;
            acc.Vehicle_Types__c = vehicleObj.Name;
            Insert acc;
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            conlist[0].Insurance__c = 'Yes';
            conlist[0].Vehicle_Age__c = 'Yes';
            conlist[0].Vehicle_Value_Check__c = 'Yes';
            conlist[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist);
           
          
            
            conList1 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist1[0].Insurance__c = 'Yes';
            conlist1[0].Vehicle_Age__c = 'Yes';
            conlist1[0].Vehicle_Value_Check__c = 'No';
			conlist1[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist1);
 
            conList2 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist2[0].Insurance__c = 'Yes';
            conlist2[0].Vehicle_Age__c = 'Yes';
            conlist2[0].Vehicle_Value_Check__c = 'No';
			conlist2[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist2);
            
           
            
            conList3 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist3[0].Insurance__c = 'Yes';
            conlist3[0].Vehicle_Age__c = 'Yes';
            conlist3[0].Vehicle_Value_Check__c = null;
            conlist3[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist3);
            
            conList4 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist4[0].Insurance__c = 'Yes';
            conlist4[0].Vehicle_Age__c = 'No';
            conlist4[0].Vehicle_Value_Check__c = null;
            conlist4[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist4);
            
            conList5 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist5[0].Insurance__c = 'Yes';
            conlist5[0].Vehicle_Age__c = null;
            conlist5[0].Vehicle_Value_Check__c = null;
            conlist5[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist5);
            
            conList6 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist6[0].Insurance__c = 'Not Submitted';
            conlist6[0].Vehicle_Age__c = null;
            conlist6[0].Vehicle_Value_Check__c = null;
            conlist6[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist6);
            
            conList7 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist7[0].Insurance__c = 'Insurance Card';
            conlist7[0].Vehicle_Age__c = null;
            conlist7[0].Vehicle_Value_Check__c = null;
            conlist7[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist7);
            
            conList8 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist8[0].Insurance__c = 'Not Meeting Plan Minimum';
            conlist8[0].Vehicle_Age__c = null;
            conlist8[0].Vehicle_Value_Check__c = null;
            conlist8[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist8);
            
            conList9 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist9[0].Insurance__c = 'Expired';
            conlist9[0].Vehicle_Age__c = null;
            conlist9[0].Vehicle_Value_Check__c = null;
            conlist9[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist9);
            
            conList10 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist10[0].Insurance__c = 'No Expiration Date';
            conlist10[0].Vehicle_Age__c = null;
            conlist10[0].Vehicle_Value_Check__c = null;
            conlist10[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist10);
            
            conList11 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist11[0].Insurance__c = 'Missing Umbrella Policy';
            conlist11[0].Vehicle_Age__c = null;
            conlist11[0].Vehicle_Value_Check__c = null;
            conlist11[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist11);
			
            conList12 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email1', 1);
            conlist12[0].Insurance__c = 'Missing Insurance Dec Page';
            conlist12[0].Vehicle_Age__c = null;
            conlist12[0].Vehicle_Value_Check__c = null;
            conlist12[0].Activation_Date__c=system.today().addmonths(-2);
            combinedList.addAll(conlist12);
            insert combinedList;
                
            System.debug(combinedList.size());
            
            reim = TestDataFactory.createPendingReimbursement(false,conList,1,irsRateObj.id);
            reim[0].Status__c = 'Approved';
            reim[0].Month__c = date.today().addMonths(-1).Month() + '-' + date.today().addMonths(-1).Year();
            reim[0].Approved_Date__c = system.today();
            combinedReimList.addAll(reim);
            
            reim1 = TestDataFactory.createPendingReimbursement(false,conList1,1,irsRateObj.id);
            reim1[0].Status__c = 'Approved';
            reim1[0].Month__c = date.today().addMonths(-1).Month() + '-' + date.today().addMonths(-1).Year();
            reim1[0].Approved_Date__c = system.today();
            combinedReimList.addAll(reim1);
            
            reim2 = TestDataFactory.createPendingReimbursement(false,conList2,1,irsRateObj.id);
            reim2[0].Status__c = 'Approved';
            reim2[0].Month__c = date.today().addMonths(-1).Month() + '-' + date.today().addMonths(-1).Year();
            reim2[0].Approved_Date__c = system.today();
            combinedReimList.addAll(reim2);
            
            Insert combinedReimList;
            
            biweek =TestDataFactory.createBiweeklyReim(false,conList,system.today().addDays(-15),system.today(),1,irsRateObj.id);
            combinedBiweekList.addAll(biweek);
            
            biweek1 =TestDataFactory.createBiweeklyReim(false,conList1,system.today().addDays(-15),system.today(),1,irsRateObj.id);
            combinedBiweekList.addAll(biweek1);
            
            biweek2 =TestDataFactory.createBiweeklyReim(false,conList2,system.today().addDays(-15),system.today(),1,irsRateObj.id);
            combinedBiweekList.addAll(biweek2);
            insert combinedBiweekList;
            emp=TestDataFactory.getEmpMileage(false,3,reim,biweek);
            emp[0].EMP_Mileage__c=1500;
            for(Employee_Mileage__c em :emp){
                em.Approved_Date__c = System.today();
				em.Trip_Status__c='Approved';
            }
            insert emp;
        
            emp1=TestDataFactory.getEmpMileage(false,3,reim1,biweek1);
            for(Employee_Mileage__c em :emp1){
                em.Approved_Date__c = System.today();
                em.Trip_Status__c='Approved';
            }
            insert emp1;
           
            emp2=TestDataFactory.getEmpMileage(false,3,reim2,biweek2);
            for(Employee_Mileage__c em :emp1){
                em.Approved_Date__c = System.today(); 	
                em.Trip_Status__c='Approved';
            }
            insert emp2;
        }
    }
    @istest
    public static void test(){
        list<Employee_Reimbursement__c>rollupquery =[select id ,Total_Mileage__c From Employee_Reimbursement__c ];
        test.startTest();
        MonthlyComplianceStatusBatch i = new MonthlyComplianceStatusBatch();
        Database.executeBatch(I,20);
        String newExeTime = '0 0 3 * * ?';
        String jobId = System.schedule('Scheduler Test', newExeTime, i);
        AnnualTaxliabilityReport i2 =new AnnualTaxliabilityReport();
         test.stopTest();
    }

}