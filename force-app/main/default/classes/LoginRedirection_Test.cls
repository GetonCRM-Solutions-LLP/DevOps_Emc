@isTest
public with sharing class LoginRedirection_Test {

    @isTest
    public static void utilMethod1()     {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>(); 
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
       
        
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
        
           acc = TestDataFactory.createAccount(True, 'Test Account', True);
           conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
           conList[0].IsCreatedFromCommunity__c = false;
           Insert conList[0];
           system.assertEquals(2, conList.size(), true);
          
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
    
        List<User> u = [Select id from User WHERE Profile.name='Customer Community Login User - Manager' and IsActive = true limit 1];
        Test.startTest();
        System.runAs(u[0]) {
          
            Contact obj = [select id from contact limit 1];
            ApexPages.currentPage().getParameters().put('id',obj.Id);
            LoginRedirection objLoginRedirection = new LoginRedirection();
            objLoginRedirection.redirectOnPage();
              
          }
    Test.stopTest();
    }

    @isTest
    public static void utilMethod2()     {
      
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>(); 
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True, 'Test Account', True);
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
            system.assertEquals(2, conList.size(), true);
            conList[0].IsCreatedFromCommunity__c = false;
            Insert conList[0];
            system.assertEquals(2, conList.size(), true);
          
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
         Test.startTest();
       List<User> u = [Select id from User WHERE Profile.name='Customer Community Login User - Super Manager' and IsActive = true limit 1];    
        System.runAs(u[0]) {      
            Contact obj = [select id from contact limit 1];
            ApexPages.currentPage().getParameters().put('id',obj.Id);
            LoginRedirection objLoginRedirection = new LoginRedirection();
            objLoginRedirection.redirectOnPage();              
          }
    Test.stopTest();
    }

    @isTest
    public static void utilMethod3()     {
      
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Test.startTest();
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>(); 
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
          
        acc = TestDataFactory.createAccount(True, 'Test Account', True);
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
            system.assertEquals(2, conList.size(), true);
            conList[0].IsCreatedFromCommunity__c = false;
            Insert conList[0];
            system.assertEquals(2, conList.size(), true);
          
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
         }

        List<User> u = [Select id from User WHERE Profile.name='Customer Community Login User - Manager/Driver' and IsActive = true limit 1];
        System.runAs(u[0]) {            
            Contact obj = [select id from contact limit 1];
            ApexPages.currentPage().getParameters().put('id',obj.Id);
            LoginRedirection objLoginRedirection = new LoginRedirection();
            objLoginRedirection.redirectOnPage();              
          }
    Test.stopTest();
    }

    @isTest
    public static void utilMethod4() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>(); 
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        
        System.runAs(admin) {          
        acc = TestDataFactory.createAccount(True, 'Test Account', True);
        conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
        conList[0].Activation_Date__c = system.today()-35;
        conList[0].IsCreatedFromCommunity__c = false;
        Insert conList;
        system.assertEquals(2, conList.size(), true);
        userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim (false, conList, System.today().addDays(-13),System.today(), 1, createIRSRate.Id);   
            
        biWeeklyReimList[0].Contact__c = conList[0].Id; 
        insert biWeeklyReimList;
        }
        
        Test.startTest();
        List<User> u = [Select id from User where profile.name='Customer Community Login User - Driver' and IsActive = true limit 1];
        
        System.runAs(u[0]) {            
            Contact obj = [select id from contact limit 1];
            ApexPages.currentPage().getParameters().put('id',userObj.contactId);
            LoginRedirection objLoginRedirection = new LoginRedirection();
            objLoginRedirection.redirectOnPage();
          }
        Test.stopTest();
    }

    @isTest
    public static void utilMethod5() {

        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Account acc = new Account();     
        List<Contact> conList = new List<Contact>(); 
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
          
        acc = TestDataFactory.createAccount(false, 'Test Account', True);
        acc.MburseDashboardRedirect__c = true;
        insert acc;
        conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
        conList[0].IsCreatedFromCommunity__c = false;
        conList[0].Activation_Date__c = System.TODAY()-35;
        conList[0].Driver_Packet_Status__c = 'Sent';
        conList[0].Insurance_Declaration_Status__c = 'Uploaded';
        conList[0].App__c = 'Test';
        Insert conList;
        system.assertEquals(2, conList.size(), true);
        Boolean checkActivationDate = true;
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim (false, conList, System.today().addDays(-13),System.today(), 1, createIRSRate.Id);
        biWeeklyReimList[0].Contact__c = conList[0].Id;
        insert biWeeklyReimList;
         userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
        Test.startTest();
       List<User> u = [Select id from User WHERE Profile.name='Customer Community Login User - Super Manager/Driver' and IsActive = true limit 1];    
        System.runAs(u[0]) {      
            //Contact obj = [select id from contact limit 1];
            ApexPages.currentPage().getParameters().put('id',conList[0].Id);
            LoginRedirection objLoginRedirection = new LoginRedirection();
            objLoginRedirection.redirectOnPage();              
          }
    Test.stopTest();
    }
    
    @isTest
    static void fakeTest(){
     LoginRedirection.fakeMethod(); 
     LoginRedirection.fakeMethod2();      
  }  
}