@isTest
public class MileageLockDateUpdateControllerTest {
    @isTest
    static void testmethod1() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.Mileage_Lockdate__c = false;        
        insert customSetting;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        
        Account acc = new Account();
        Contact con1 = new Contact();
        System.runAs(admin) {
            acc.Name = 'Test Account';
            acc.Bi_Weekly_Pay_Period__c = true;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            acc.Last_Reimbursement_Created__c = '12-2021';
            acc.Trip_Status_Lock__c = system.today();
            insert acc;
            
            List<Account> acclist = new List<Account>();
            acclist.add(acc);
            
            Contact contact_1 = new Contact(AccountId = acc.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com');
            insert contact_1;
            
            con1.LastName = 'TestContact';
            con1.Role__c = 'Manager';
            con1.Car_Image__c = veh.URL__c;
            con1.Vehicle_Type__c = veh.Year__c +' '+veh.vehicle__c;
            con1.AccountId = acc.Id;
            con1.Activation_Date__c = system.today();
            con1.External_Email__c = 'test123@email.com';
            con1.Fixed_Amount__c = 371.28;
            con1.MailingCity = 'Abilene';
            con1.MailingState = 'TX';
            con1.Time_Zone__c = 'US/Mountain' ;
            con1.Driving_States__c = 'TX';
            con1.Fixed_Amount__c = 322.00;
            con1.Maintenance_and_Tires__c = 1.2;
            con1.MPG__c= 10.00;
            con1.Monthly_Mileage_Limit__c = 100.00;
            insert con1;
            
            List<Contact> conlist = new List<Contact>();
            conlist.add(con1);
            
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
            
            Report_Accessibility__c rptacc = new Report_Accessibility__c ();
            rptacc.Name = 'Test Report';
            rptacc.Mileage_Lock_Date__c = string.valueOf(system.today());
            Insert rptacc;
            
            test.startTest();
            MileageLockDateUpdateController millock = new MileageLockDateUpdateController();
            millock.updateLockdate();
                        MileageLockDateUpdateController millock1 = new MileageLockDateUpdateController();
            String sch = '0 0 2 * * ?'; 
			system.schedule('Test Territory Check', sch, millock1);
            test.stopTest();
        }
    }
}