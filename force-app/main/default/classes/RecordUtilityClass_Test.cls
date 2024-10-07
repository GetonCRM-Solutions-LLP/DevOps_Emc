@isTest
public with sharing class RecordUtilityClass_Test {
    public RecordUtilityClass_Test() {
        
    }
    public static Testmethod void RecordUtilityClass_TestMethod1()
    {
        RecordUtilityClass obj = new RecordUtilityClass();
        RecordUtilityClass.exceptionEmail();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        RecordUtilityClass.insertIrsRate();
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',Pay_Period_Days__c = 13, True_Dialog__c = false, Pay_Period_Start_Date__c = system.today().adddays(-30),Triplog_API__c = 'khdkfhsld34khdlf4545');
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com',Activation_Date__c=system.today(),Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;

            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
    
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;       
    
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            insert obj_Manager_list;
    
            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            insert obj_Driver_list;
          user_1 = new User( 
            Email = 'yourusername@gmail.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = contact_1.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
          );
          insert user_1;
        }
    }
    public static Testmethod void RecordUtilityClass_TestMethod2()
    {   
        RecordUtilityClass obj = new RecordUtilityClass();
        RecordUtilityClass.exceptionEmail();
        RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsAdminDashboardController();
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
    }
    public static Testmethod void RecordUtilityClass_TestMethod3()
    {   
        RecordUtilityClass obj = new RecordUtilityClass();
        RecordUtilityClass.exceptionEmail();
        RecordUtilityClass.insertIrsRate();

        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        RecordUtilityClass.createRecordsforManagerDashboard();
    }
    public static Testmethod void RecordUtilityClass_TestMethod4()
    {   
        RecordUtilityClass obj = new RecordUtilityClass();
        RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.exceptionEmail();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account acc;
        Contact con;       
        List<Contact> listContactManager;
        List<Contact> listContactDriver;

        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',Pay_Period_Days__c = 13, True_Dialog__c = false, Pay_Period_Start_Date__c = system.today().adddays(-30),Triplog_API__c = 'khdkfhsld34khdlf4545'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com',Activation_Date__c=system.today(),Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;

            acc = RecordUtilityClass.buildAccount();
            insert acc;
    
            con = RecordUtilityClass.buildAdminContact(acc);
            insert con;
            
            listContactManager = RecordUtilityClass.buildManagerContact(acc,con);
            insert listContactManager;

            listContactDriver = RecordUtilityClass.buildDriverContact(acc,listContactManager[0]);
            insert listContactDriver;
          user_1 = new User( 
            Email = 'yourusername@gmail.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = contact_1.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
          );
          insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
            List<Employee_Reimbursement__c> listEmp = RecordUtilityClass.buildPendingEmployee_Reimbursement(listContactDriver);
            insert listEmp;

            RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(listEmp);
        }
        Test.stopTest(); 
    }
    

    public static Testmethod void RecordUtilityClass_TestMethod5(){

        RecordUtilityClass obj = new RecordUtilityClass();
        RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.exceptionEmail();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account acc;
        Contact con;
        // List<Contact> obj_Manager_list;
        // List<Contact> obj_Driver_list;
        List<Contact> listContactManager;
        List<Contact> listContactDriver;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',Pay_Period_Days__c = 13, True_Dialog__c = false, Pay_Period_Start_Date__c = system.today().adddays(-30),Triplog_API__c = 'khdkfhsld34khdlf4545'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com',Activation_Date__c=system.today(),Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;

            acc = RecordUtilityClass.buildAccount();
            insert acc;
    
            con = RecordUtilityClass.buildAdminContact(acc);
            insert con;     
            listContactManager = RecordUtilityClass.buildManagerContact(acc,con);
            insert listContactManager;

            listContactDriver = RecordUtilityClass.buildDriverContact(acc,listContactManager[0]);
            insert listContactDriver;

            user_1 = new User( 
            Email = 'yourusername@gmail.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = contact_1.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
            List<Employee_Reimbursement__c> listemp = RecordUtilityClass.buildPendingEmployee_Reimbursement(listContactDriver);
            insert listemp;
            RecordUtilityClass.getEmployeeReimbursements(listemp);
        }       
        Test.stopTest(); 
    }

    public static Testmethod void RecordUtilityClass_TestMethod6(){
       
        RecordUtilityClass obj = new RecordUtilityClass();
        RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.exceptionEmail();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account acc;
        Contact con;
        List<Contact> listContactManager;
        List<Contact> listContactDriver;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',Pay_Period_Days__c = 13, True_Dialog__c = false, Pay_Period_Start_Date__c = system.today().adddays(-30),Triplog_API__c = 'khdkfhsld34khdlf4545'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com',Activation_Date__c=system.today(),Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;

            acc = RecordUtilityClass.buildAccount();
            insert acc;
    
            con = RecordUtilityClass.buildAdminContact(acc);
            insert con;       

            listContactManager = RecordUtilityClass.buildManagerContact(acc,con);
            insert listContactManager;

            listContactDriver = RecordUtilityClass.buildDriverContact(acc,listContactManager[0]);
            insert listContactDriver;

            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
            List<Employee_Reimbursement__c> listemp = RecordUtilityClass.buildPendingEmployee_Reimbursement(listContactDriver);
            insert listemp;
            
            list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList1 = RecordUtilityClass.buildPendingBiReimbursement(listContactDriver);
            insert empBIweekReimbursementList1;
            
            List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(listemp,empBIweekReimbursementList1[0].Id);
            obj_Employee_Mileage_list[0].Approved_Date__c = Date.today();
            obj_Employee_Mileage_list[0].Trip_Status__c = StaticValues.noApprovedYet;
            insert obj_Employee_Mileage_list;
            RecordUtilityClass.getMileagesOfReimbursement(obj_Employee_Mileage_list[0]);
        }
     
        Test.stopTest(); 
    }

}