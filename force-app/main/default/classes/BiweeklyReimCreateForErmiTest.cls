@isTest
public class BiweeklyReimCreateForErmiTest {
    @isTest    
    public static void reimburMethod1() {
            
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_1 = new IRS_Mileage_Rate__c();
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        obj_IRS_Mileage_Rate_1.year__c='2021';
        obj_IRS_Mileage_Rate_1.IRS_Rate__c =0.578;
        insert obj_IRS_Mileage_Rate_1;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
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
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact();    
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Ermi');
            account_1.Bi_Weekly_Pay_Period__c = true;
            account_1.Pay_Period_Days__c = 6;
            account_1.Pay_Period_Start_Date__c = system.today().adddays(-130);
            insert account_1;
            
             Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com',MailingCity = 'Atlanta',
                MailingState = 'GJ');
            insert contact_1;
          /*  
            for(Integer i; i<=10; i++){
                
                Contact con = new Contact();        
                con.FirstName = 'Priyanka';
                con.LastName = 'Gajera';
                con.Employee_ID__c = '123456';
                con.AccountId = account_1.Id;
                con.account.Name = acc.Name;
                con.External_Email__c = 'minkfesh.patel1478'+ i + '@gmail.com';
                con.Deactivated_Date__c = Null;
                con.Insurance_Attachment_Id__c = Null;
                con.Vehicle_Type__c = '2019 Full-Size Sedan';  
                con.Role__c = 'Driver';
                con.Driver_Type__c = 'Driver - Full Time';
                
                conList.add(con);
            }
            insert conList;
           */ 
            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = account_1.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2019 Full-Size Sedan';
            con1.MailingCity = 'Atlanta';
            con1.MailingState = 'GJ';
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
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con1.Id;
        er.Name = 'Test Mileage';
        er.Month__c = '11-2022';
        insert er;
        
        Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = system.today()-13 + ' to ' + system.today() ; 
            br.Contact__c = con1.Id;
            br.Start_Date__c = system.today()-13;
            br.End_Date__c = system.today() ;
            br.MPG__c = con1.MPG__c;
            br.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
            br.Fixed_Amount__c = con1.Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Fuel_Price__c =  gasprice.Fuel_Price__c;
        br.Employee_Reimbursement__c = er.Id;
        	 br.Count_Error_Check__c = 0;
        Insert br;
        
        Test.startTest();
        
        BiweeklyReimCreateForErmi weeklyReimforErmi = new BiweeklyReimCreateForErmi(); 
        Database.executeBatch(weeklyReimforErmi);
        Test.stopTest();
    }
}