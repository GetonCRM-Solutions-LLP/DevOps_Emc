@isTest
Public class drivermanagermydetailcontrollerTest{
    public static testmethod void objMethod1(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        customEmailSetting.ContactTriBiReimCreate__c  = true;
        insert customEmailSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Contact obj_admin_contact;
        Account obj_acc;
        List<Contact> obj_Manager_list;
        List<Contact> obj_driver_contact;
        System.runAs(admin) {
            obj_acc= new Account( Name = 'PL Marketing');
            obj_acc.Bi_Weekly_Pay_Period__c = true;
            obj_acc.Pay_Period_Days__c = 13;
            obj_acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            obj_acc.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
            insert obj_acc;
           
            obj_admin_contact = RecordUtilityClass.buildAdminContact(obj_acc);
            insert obj_admin_contact;   
            
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_acc,obj_admin_contact);
            insert obj_Manager_list;
    
            obj_driver_contact = RecordUtilityClass.buildDriverContact(obj_acc,obj_Manager_list[0]);
            insert obj_driver_contact ;
            
            Contact contact_2 = new Contact(AccountId = obj_acc.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com');
            insert contact_2 ;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_2.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        
        Attachment att = new Attachment();
        att.parentID = obj_admin_contact.Id;
        att.name = 'test';
        att.body = blob.valueOf('Test');
        insert att;
        
        Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = system.today()-13 + ' to ' + system.today() ; 
            br.Contact__c = obj_driver_contact[0].Id;
            br.Start_Date__c = system.today()-13;
            br.End_Date__c = system.today() ;
            br.MPG__c = obj_driver_contact[0].MPG__c;
            br.Maintenance_and_Tires__c = obj_driver_contact[0].Maintenance_and_Tires__c;
            br.Fixed_Amount__c = obj_driver_contact[0].Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Fuel_Price__c = 0;
        Insert br;
         
        Test.startTest();
        System.runAs(user_1) {
            Test.setCurrentPage(Page.drivermanagermydetail);
            ApexPages.currentPage().getParameters().put('id',obj_admin_contact.Id);
            ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
            drivermanagermydetailcontroller objDriver = new drivermanagermydetailcontroller();
            drivermanagermydetailcontroller.contactDataAsString = 'test';
            drivermanagermydetailcontroller.getAccountid();
            drivermanagermydetailcontroller.getRedirected();
            drivermanagermydetailcontroller.getLast2Years();
            drivermanagermydetailcontroller.getAllReimbursements(String.valueOf(System.today().year()),obj_driver_contact[0].Id,obj_acc.Id);
            drivermanagermydetailcontroller.getReimbursementsList();
            drivermanagermydetailcontroller.getDriverDetailsClone(obj_admin_contact.Id);
            drivermanagermydetailcontroller.getMileages('June',String.valueOf(system.today().year()),obj_driver_contact[0].Id);
            drivermanagermydetailcontroller.getdriverInsurance(obj_driver_contact[0].Id,att.Id);
            drivermanagermydetailcontroller.getCompliance(obj_driver_contact[0].Id);
            drivermanagermydetailcontroller.getPacketandMeeting(obj_driver_contact[0].Id);
            //drivermanagermydetailcontroller.readFromFileInchunk('test',att.Name,String.valueOf(att.Id),String.valueOf(obj_driver_contact[0].Id),String.valueOf(obj_acc.Id),null);
            drivermanagermydetailcontroller.TimeAttendance(obj_driver_contact[0].Id,'2021');
            drivermanagermydetailcontroller.getBiweekMileages(string.valueOf(br));
            drivermanagermydetailcontroller.ApproveBiweekMileages(string.valueOf(br));
        }
        Test.stopTest();
    }
    public static testmethod void objMethod2(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        customEmailSetting.ContactTriBiReimCreate__c  = true;
        insert customEmailSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Contact obj_admin_contact;
        Account obj_acc;
        List<Contact> obj_Manager_list;
        List<Contact> obj_driver_contact;
        System.runAs(admin) {
            obj_acc= new Account( Name = 'PL Marketing');
            obj_acc.Bi_Weekly_Pay_Period__c = true;
            obj_acc.Pay_Period_Days__c = 13;
            obj_acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            obj_acc.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
            insert obj_acc;
           
            obj_admin_contact = RecordUtilityClass.buildAdminContact(obj_acc);
            insert obj_admin_contact;   
            
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_acc,obj_admin_contact);
            insert obj_Manager_list;
    
            obj_driver_contact = RecordUtilityClass.buildDriverContact(obj_acc,obj_Manager_list[0]);
            insert obj_driver_contact ;
            
            Contact contact_2 = new Contact(AccountId = obj_acc.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com');
            insert contact_2 ;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_2.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        drivermanagermydetailcontroller.getAllReimbursements(String.valueOf(1),obj_driver_contact[0].Id,obj_acc.Id);
        drivermanagermydetailcontroller.getAccountid();
        drivermanagermydetailcontroller.getContactid();
        drivermanagermydetailcontroller.getRedirected();
    }
}