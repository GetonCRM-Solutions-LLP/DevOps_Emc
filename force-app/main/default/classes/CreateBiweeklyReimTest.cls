@isTest
public class CreateBiweeklyReimTest {
    @isTest    
    public static void reimburMethod1() {
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(false, 3);
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Denver';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-1);
        gasprice.State__c = 'CA';
        insert gasprice;
        
        Account acc;     
        List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact();    
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Test Accounts');
            account_1.Bi_Weekly_Pay_Period__c = true;
            account_1.Pay_Period_Days__c = 3;
            account_1.Pay_Period_Start_Date__c = system.today().adddays(-3);
            account_1.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
            insert account_1;
            
            acc = new Account();             
            acc.Name = 'PL Marketing';
            acc.Bi_Weekly_Pay_Period__c = true;
            acc.Pay_Period_Days__c = 3;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-2);
            acc.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
            insert acc;
            
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com',MailingCity = 'Atlanta' , Activation_Date__c = system.today(),
                                            MailingState = 'GJ');
            insert contact_1;
            
            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = account_1.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = system.today().adddays(1);
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2019 Full-Size Sedan';
            con1.MailingCity = 'Atlanta';
            con1.MailingState = 'GJ';
            con1.Activation_Date__c = system.today().adddays(-1);
            con1.Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement';
            
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
        br.Name = '04/14/2022 to 04/18/2023'; 
        br.Contact__c = con1.Id;
        //br.Start_Date__c = Date.valueOf('2022-04-14');
        br.Start_Date__c = system.today().adddays(-3);
        br.End_Date__c = system.today() ;
        
        //br.End_Date__c = Date.valueOf('2022-04-18') ;
        br.MPG__c = con1.MPG__c;
        br.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
        br.Fixed_Amount__c = con1.Fixed_Amount__c;
        br.Status__c = 'Pending';
        br.Fuel_Price__c = gasprice.Fuel_Price__c;
        Insert br;
        
        Test.startTest();
        
        CreateBiweeklyReim biweeklyReim = new CreateBiweeklyReim(); 
        Database.executeBatch(biweeklyReim);
        Test.stopTest();
    }
}