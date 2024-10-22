@isTest
public with sharing class ChangeTripStatusinTripLogTest {
    
    @TestSetup
    static void setupTestData() {
        
        UserRole objUserRole = TestDataFactory.getUserRole();
        Profile objProfile = TestDataFactory.getUserProfile();
        User objAdmin = TestDataFactory.getSystemAdminUser(objUserRole.Id);
        User objGenUser;
        
        SendEmailonDeactivation__c obj = new SendEmailonDeactivation__c();
        obj.Name = 'flagmileagesemaildriver';
         obj.BCCEmailaddresses__c = 'minkeshp@askemc.com';
         obj.Send_to_me__c = true;
         obj.Send_to_Manager__c =false;
         obj.Send_to_Driver__c = true;
         obj.Send_to_Admin__c = false;
        insert obj;
        SendEmailonDeactivation__c obj1 = new SendEmailonDeactivation__c();
        obj1.Name = 'mileageprocess';
         obj1.BCCEmailaddresses__c = 'minkeshp@askemc.com';
         obj1.Send_to_me__c = true;
         obj1.Send_to_Manager__c =true;
         obj1.Send_to_Driver__c = true;
         obj1.Send_to_Admin__c = true;
        insert obj1;
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c sendEmailCustomSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'ChangeTripStatusinTripLogBatch');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10,12345);
        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'ChangeTripStatusinTripLog';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        Vehicle_URL_Mapping__c objVehicleUrlMap = TestDataFactory.createVehicleData(false, 0);
        objVehicleUrlMap.Name = String.valueof(System.today().year())+ ' Full-Size Sedan';
        objVehicleUrlMap.vehicle__c = 'Full-Size Sedan';
        Insert objVehicleUrlMap;
        
        Account objAccount1;
        List<Vehicle_Value__c> lstVehicleValue;
        List<Contact> lstContact1;
        List<Contact> lstContact2;
        List<Contact> lstContact3;

        Profile objUserProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        
        System.runAs(objAdmin) {
            
            objAccount1 = TestDataFactory.createAccount(true,'Delta account',true);
            
            lstVehicleValue = TestDataFactory.createVehicleValue(true, objAccount1.Id, objVehicleUrlMap.Id);
            lstContact3 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Admin', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact2 = TestDataFactory.createDriverContact(true, objAccount1.Id, 'Manager', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact1 = TestDataFactory.createDriverContact(false, objAccount1.Id, 'Driver', objVehicleUrlMap.Name, 'paras.dhanani',  1);
            lstContact1[0].Manager__c=lstContact2[0].id ;
            insert lstContact1;

            objGenUser = TestDataFactory.createUser(true, objProfile.Id, lstContact1[0].Id);

            List<Employee_Reimbursement__c> lstEmpReim =TestDataFactory.createPendingReimbursement(true,lstContact1, 10, irsRateObj.Id);
            List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim =TestDataFactory.createBiweeklyReim(true, lstContact1, date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 2, irsRateObj.Id);
            List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 10, lstEmpReim, lstBiWeeklyReim);
            List<Employee_Mileage__c> lstEmpMil2 = TestDataFactory.getEmpMileage(false, 10, lstEmpReim, lstBiWeeklyReim);
            for(Employee_Mileage__c objEmp:lstEmpMil2){
                objEmp.Trip_Status__c = 'Approved';
                objEmp.Approved_Date__c = system.today();
                objEmp.Trip_Date__c = system.today().addmonths(-1);
            }
            insert lstEmpMil2;
            List<Employee_Mileage__c> lstEmpMil3 = TestDataFactory.getEmpMileage(false, 10, lstEmpReim, lstBiWeeklyReim);
            for(Employee_Mileage__c objEmp:lstEmpMil3){
                objEmp.Trip_Status__c = 'Rejected';
                objEmp.Approved_Date__c = system.today();
                objEmp.Trip_Date__c = system.today().addmonths(-1);
            }
            insert lstEmpMil3;
        }
    }
    public static testmethod void method1() {
        List<String> approvedIdList = new List<String>();
        List<String> rejectedIdList = new List<String>(); 
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name = 'Delta account' LIMIT 1];
        List<Contact> lstDriverContact = [SELECT Id FROM Contact WHERE Role__c = 'Driver' AND AccountId = :lstAccounts[0].id];
        List<Contact> lstAdminContact = [SELECT Id FROM Contact WHERE Role__c = 'Admin' AND AccountId = :lstAccounts[0].id];
		List<Employee_Mileage__c> rejectedTrips=[SELECT Id FROM Employee_Mileage__c WHERE Trip_Status__c='Rejected' ];
        for(Employee_Mileage__c objEmp:rejectedTrips){
                rejectedIdList.add(objEmp.id);
        }
        List<Employee_Mileage__c> ApprovedTrips=[SELECT Id FROM Employee_Mileage__c WHERE Trip_Status__c='Approved' ];
        for(Employee_Mileage__c objEmp:ApprovedTrips){
                approvedIdList.add(objEmp.id);
        }
        
        Database.executeBatch(new ChangeTripStatusinTripLog(approvedIdList ,rejectedIdList,'test','test@gmail.com') );
    }
    
}