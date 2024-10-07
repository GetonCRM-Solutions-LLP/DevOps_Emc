@isTest()
public class BiWeeklyComplianceReportControllerTest {
    
    public static testmethod void test1(){
 
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        insert customSetting;
        
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
        Contact con = new Contact();
        System.runAs(admin) {
            acc.Name = 'PL Marketing';
            acc.Pay_Period_Start_Date__c = Date.parse('01/25/2022');
            acc.Bi_Weekly_Pay_Period__c = true;
            acc.Pay_Period_Days__c = 13;
            insert acc;
            Contact contact_1 = new Contact(AccountId = acc.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com');
            insert contact_1;
            con.LastName = 'TestContact';
            con.Role__c = 'Driver';
            con.Car_Image__c = veh.URL__c;
            con.Vehicle_Type__c = veh.Year__c +' '+veh.vehicle__c;
            con.AccountId = acc.Id;
            con.Activation_Date__c = Date.parse('10/01/2021');
            con.Deactivated_Date__c = null;
            con.External_Email__c = 'test@email.com';
            con.Fixed_Amount__c = 371.28;
            con.MailingCity = 'Abilene';
            con.MailingState = 'TX';
            con.Time_Zone__c = 'US/Mountain' ;
            con.Driving_States__c = 'TX';
            con.Fixed_Amount__c = 322.00;
            con.Maintenance_and_Tires__c = 1.2;
            con.MPG__c= 10.00;
            con.Monthly_Mileage_Limit__c = 100.00;
            insert con;
            //added by megha
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
        IRS_Mileage_Rate__c objIRSRate = new IRS_Mileage_Rate__c();
        objIRSRate.year__c = '2021';
        objIRSRate.IRS_Rate__c= 12.0;
        insert objIRSRate;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = '09-2021';
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00; 
        er.Fixed_Amount__c = con.Fixed_Amount__c;
        er.Maintenance_and_Tires__c = con.Maintenance_and_Tires__c;
        er.MPG__c = con.MPG__c;
        er.IRS_Mileage_Rate__c= objIRSRate.Id;
        er.Fuel_Price__c = 2.14;
         insert er;
        
        Bi_Weekly_Reimbursement__c bob = new Bi_Weekly_Reimbursement__c();
        bob.name = '9/19/2021 to 10/2/2021';
        bob.Contact__c = con.id;
        insert bob;
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = 'Approved';
        emp.Approved_Date__c = system.today();
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = Date.parse('10/15/2021');
        emp.Bi_Weekly_Reimbursement__c = bob.id;
        insert emp;
        Test.startTest();
        System.runAs(user_1) {
            BiWeeklyComplianceReportController.ReibursementWrapper wrapReim = new BiWeeklyComplianceReportController.ReibursementWrapper();
            wrapReim.StartDate = '01-10-2021';
            wrapReim.EndDate = '18-10-2021';
            wrapReim.GasPrices = 2.30;
            wrapReim.FixedTotal = 234.50;
            wrapReim.VariableRate = 0.0310;
            wrapReim.TotalReimbursement = 342.5;
            wrapReim.Mileage = 500.5;
            wrapReim.IRSRate = 2.345;
            wrapReim.MaxAllowable = 2.345;
            wrapReim.ImputedIncome = 2.345;
            PageReference pgRef = Page.BiWeeklyComplianceReport; //Create Page Reference - 'Appt_New' is the name of Page
            Test.setCurrentPage(pgRef); //Set the page for Test Method
            ApexPages.currentPage().getParameters().put('id', Con.id);
            BiWeeklyComplianceReportController biweekComRpt = new BiWeeklyComplianceReportController();
            Test.stopTest();
        }
    }
}