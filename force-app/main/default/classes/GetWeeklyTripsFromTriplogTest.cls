@isTest
public with sharing class GetWeeklyTripsFromTriplogTest {
    public static testmethod void GetTriptest() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);

        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmailToMe__c sendEmail = new SendEmailToMe__c();
        sendEmail.Name = 'GetTripCallOutApprovePutCall';
        sendEmail.Send_email_to_me__c = true;
        insert sendEmail;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        Get_Trip_Date_Settings__c obj_Get_Trip_Date_Settings = new Get_Trip_Date_Settings__c();
        obj_Get_Trip_Date_Settings.Name ='Date Settings';
        obj_Get_Trip_Date_Settings.Start_Date__c ='2020-08-01';
        obj_Get_Trip_Date_Settings.End_Date__c ='2020-08-31';
        obj_Get_Trip_Date_Settings.Last_N_Days__c ='31';
        insert obj_Get_Trip_Date_Settings;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account acc;
        Contact contact;
        Contact con;
        System.runAs(admin) {
            acc = new Account();           
            acc.Name = 'Test Accounts';
            acc.Triplog_API__c = '123456789';
            acc.Triplog_Status__c = 'U';
            acc.Bi_Weekly_Pay_Period__c = true;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-13);
            acc.isUsingTriplog__c = true;
            insert Acc;
            Contact contact_1 = new Contact(AccountId = acc.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com',Deactivated_Date__c =null,Role__c = 'Driver',Vehicle_Type__c = '2019 Mileage Rate', MailingState = 'CA',Activation_Date__c=System.today(),Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;
            contact = new Contact();
            contact.lastname = 'Test Contact';
            contact.AccountId = Acc.Id;
            contact.External_Email__c = 'minkesh.patel1478@gmail.com';
            contact.Email = 'minkesh.patel1478@gmail.com';
            contact.isCommunityUser__c = true;
            contact.MailingCity='ahmedabad';
            contact.Vehicle_Type__c = '2019 Mileage Rate';
            contact.MailingState='GJ';
            contact.Deactivated_Date__c = NULL;
            contact.Time_Zone__c = 'US/Eastern';
            contact.Activation_Date__c=System.today();
            contact.Cell_Phone__c='Company Provide';
            contact.Reimbursement_Frequency__c='Monthly Reimbursement';
            insert contact;
            contactids.add(contact.Id);
            
            con = new Contact();
            con.lastname = 'Test Con';
            con.AccountId = Acc.Id;
            con.External_Email__c = 'minkesh.patel1357@gmail.com';
            con.Email = 'minkesh.patel1357@gmail.com';
            con.Triplog_Status__c = 'U';
            con.Vehicle_Type__c = '2019 Mileage Rate';
            con.Time_Zone__c = 'US/Eastern';
            con.isCommunityUser__c = true;
            con.Cell_Phone__c='Company Provide';
            con.Activation_Date__c=System.today();
            con.Reimbursement_Frequency__c='Monthly Reimbursement';
            insert con;
            
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
        contactids.add(con.Id);
        Date MonthDate = System.today()-6;
        String currentMonthDateStr = DateTime.newInstance(MonthDate.year(),MonthDate.month(),MonthDate.day()).format('MM-yyyy');
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        er.month__c =currentMonthDateStr ;
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        conReim.put(con.Id,er);
        
        Bi_Weekly_Reimbursement__c biReim = new Bi_Weekly_Reimbursement__c();
        bireim.Approved_Date__c = system.today().addDays(-1);
        bireim.Status__c = 'Pending';
        bireim.Name = '03/02/2024 to 03/08/2024';
        bireim.Start_Date__c = Date.parse('03/02/2024');
        bireim.End_Date__c = Date.parse('03/08/2024');
        bireim.Contact__c = contact.id;
        insert bireim;
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        emp.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp.Trip_Date__c = system.today();
        emp.StartTime__c =  datetime.newInstance(2024, 3, 5, 12, 30, 0);
        emp.EndTime__c =  datetime.newInstance(2024, 3, 5, 12, 45, 0);
        insert emp;
        
        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetWeeklyTripsFromTriplog obj = new GetWeeklyTripsFromTriplog('U');
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
}