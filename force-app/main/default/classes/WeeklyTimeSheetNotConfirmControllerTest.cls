@isTest
public with sharing class WeeklyTimeSheetNotConfirmControllerTest {
     public static testmethod void method1(){

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        SendEmailonDeactivation__c objSendEmail = new SendEmailonDeactivation__c();
        objSendEmail.Name ='YearToDateReimbursementStatement'; //YearToDateReimbursementStatement
        objSendEmail.BCCEmailaddresses__c = 'tezt@gmail.com,test.email.com';
        objSendEmail.Send_to_Driver__c = true;
        insert objSendEmail;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;

        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true, 0);

        Account acc = new Account();     
        Contact con1 = new Contact();    
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs(admin) {
            Account account_1 = TestDataFactory.createAccount(false,'Ermi',true);
            account_1.Bi_Weekly_Pay_Period__c = true;
            account_1.Pay_Period_Days__c = 6;
            account_1.Pay_Period_Start_Date__c = system.today().adddays(-7);
            insert account_1;
            
            List<Contact> lstContact1=TestDataFactory.createDriverContact(false, account_1.Id, 'Driver', veh.Name, 'paras.dhanani',  1);
            con1= lstContact1[0];
            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = account_1.Id;
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Driver_Type__c = 'Driver - Part Time';
            con1.Insurance_Attachment_Id__c = Null;
            con1.ReimbursementStatement__c = true;
            con1.Biweek_Reimbursement__c = True;
            con1.MailingState = 'MA';
            insert con1;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = con1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        
        Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = '03/06/2022 to 03/12/2022' ; 
            br.Contact__c = con1.Id;
            br.Start_Date__c = date.parse('03/06/2022');
            br.End_Date__c = system.today().adddays(-2);
            br.Confirm_Hours__c = False;
            br.MPG__c = con1.MPG__c;
            br.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
            br.Fixed_Amount__c = con1.Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Fuel_Price__c = 0;
        Insert br;
        
        WeeklyTimeSheetNotConfirmController objbatch = new WeeklyTimeSheetNotConfirmController();
        objbatch.getWeeklyDriversData();
    }
}