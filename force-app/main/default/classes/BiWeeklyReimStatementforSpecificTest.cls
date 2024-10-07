@isTest
public with sharing class BiWeeklyReimStatementforSpecificTest {
     public static testmethod void method1(){

       
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;

        SendEmailonDeactivation__c objSendEmail = new SendEmailonDeactivation__c();
        objSendEmail.Name ='YearToDateReimbursementStatement'; //YearToDateReimbursementStatement
        objSendEmail.BCCEmailaddresses__c = 'tezt@gmail.com,test.email.com';
        objSendEmail.Send_to_Driver__c = true;
        insert objSendEmail;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Account acc = new Account();     
        Contact con1 = new Contact();    
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs(admin) {
            Account account_1 = new Account( Name = Label.BiWeeklyReimbursementStatementBatch);
            account_1.Bi_Weekly_Pay_Period__c = true;
            account_1.Pay_Period_Days__c = 13;
            account_1.Pay_Period_Start_Date__c = system.today().adddays(-130);
            insert account_1;
            
             Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com');
            insert contact_1;
            
            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = account_1.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2019 Full-Size Sedan';
            con1.ReimbursementStatement__c = true;
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
            br.Name = '12/26/2021 to 01/08/2022' ; 
            br.Contact__c = con1.Id;
            br.Start_Date__c = date.parse('12/26/2021');
            br.End_Date__c = date.parse('01/08/2022') ;
            br.MPG__c = con1.MPG__c;
            br.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
            br.Fixed_Amount__c = con1.Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Fuel_Price__c = 0;
        Insert br;
        
          Bi_Weekly_Reimbursement__c br1 = new Bi_Weekly_Reimbursement__c();
            br1.Name = '01/09/2022 to 01/22/2022'; 
            br1.Contact__c = con1.Id;
            br1.Start_Date__c = date.parse('01/09/2022') ;
            br1.End_Date__c = date.parse('01/22/2022') ;
            br1.MPG__c = con1.MPG__c;
            br1.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
            br1.Fixed_Amount__c = con1.Fixed_Amount__c;
            br1.Status__c = 'Pending';
            br1.Fuel_Price__c = 0;
        Insert br1;
        
        BiWeeklyReimStatementforSpecificDriver objbatch = new BiWeeklyReimStatementforSpecificDriver();
        Database.executeBatch(objbatch,1);
    }
}