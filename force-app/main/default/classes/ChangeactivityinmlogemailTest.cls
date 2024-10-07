@isTest
public class ChangeactivityinmlogemailTest {
    public static TESTMETHOD void Changeactivity(){
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriplogPutCall__c sendemailme = new TriplogPutCall__c();
        sendemailme.name = 'GetDriverData';
        sendemailme.TriplogPut__c = true;
        insert sendemailme;
       
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'SendEmailForSubmittedMileage';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.Mileage_Lockdate__c = true;
        customSetting.MappingMileage__c = true;
        customSetting.MapTriAppReje__c = true;
        insert customSetting;
        
        SendEmailToMe__c  objSendEmailToMe = new SendEmailToMe__c();
        objSendEmailToMe.Name = 'SendEmailForSubmittedMileage';
        objSendEmailToMe.Send_email_to_me__c = true;
        insert objSendEmailToMe;
        
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        daylight_saving_time_config__c customSetting4 =  new daylight_saving_time_config__c();
        customSetting4.Name = '2021';
        customSetting4.Start_Date__c = System.today();
        customSetting4.End_Date__c = System.today() + 60;
        insert customSetting4;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
       
       Account acc = new Account();
        acc.Name = 'PL Marketing';
        acc.Triplog_API__c = 'asasadfdfsdfsdasaddf';
        acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
        acc.Pay_Period_Days__c = 6;
        insert acc;
        
        System.debug('Account id: '+acc.Id);
        Contact conadmin = new Contact();
        conadmin.LastName = 'TestContact';
        conadmin.AccountId = acc.Id;
        conadmin.Role__c = 'Admin';
        conadmin.External_Email__c = 'tessst@email.com';
        conadmin.Fixed_Amount__c = 371.28;
        conadmin.MailingCity = 'Abilene';
        conadmin.MailingState = 'TX';
        conadmin.Time_Zone__c = 'US/Mountain' ;
        
        insert conadmin;
        
        Contact con = new Contact();
        con.LastName = 'TestContact';
        con.AccountId = acc.Id;
        con.Manager__c = conadmin.id;
        con.External_Email__c = 'test@email.com';
        con.Fixed_Amount__c = 371.28;
        con.MailingCity = 'Abilene';
        con.MailingState = 'TX';
        con.Time_Zone__c = 'US/Mountain' ;
        con.Driving_States__c = 'TX';
        con.Vehicle_Type__c = '2019 Mileage Rate';
        //con.Time_Zone__c = 'America/Chicago';
        con.Monthly_Mileage_Limit__c = 100.00;
        insert con;
        
    
        Gas_Prices__c gprice = new Gas_Prices__c();
        gprice.City__c = 'Abilene';
        gprice.Fuel_Price__c = 65;
        gprice.State__c = 'TX';
        gprice.Month_Year__c = date.today().adddays(-1);
        insert gprice;
        
        Employee_Reimbursement__c er5 = new Employee_Reimbursement__c();
        er5.Contact_Id__c = con.Id;
        er5.Name = 'Reimbersment Test';
        er5.Month__c = '10-2017';
        er5.Status__c = 'Pending';
        er5.Fuel_Price__c = 10.00;
        insert er5;
		
        Bi_Weekly_Reimbursement__c bob = new Bi_Weekly_Reimbursement__c();
        bob.name = '9/19/2021 to 10/2/2021';
        bob.Contact__c = con.id;
        insert bob;		
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er5.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'EMP-Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = date.today().adddays(-1);
        emp.Bi_Weekly_Reimbursement__c = bob.Id;
        insert emp;
         
        String json = '[{\"id\":"'+emp.id+'",\"adminId\":"'+conadmin.Id+'",\"tripdate\":\"2021-08-17\",\"conName\":\"NIkita Patel\",\"conEmail\":\"nikita.patel@kiwiqa.com\",\"oldActivity\":\"Business\",\"mileage\":\"100\",\"actualMileage\":\"100\",\"tripId\":2000669507,\"accApi\":\"28beeea973f34daf89050a9b6a3b1a71\"},{\"id\":\"a0B4C000004DOjMUAW\",\"adminId\":"'+conadmin.Id+'",\"tripdate\":\"2021-08-09\",\"conName\":\"NIkita Patel\",\"conEmail\":\"nikita.patel@kiwiqa.com\",\"oldActivity\":\"Business\",\"mileage\":\"1.6\",\"actualMileage\":\"1.6\",\"tripId\":2000698284,\"accApi\":\"28beeea973f34daf89050a9b6a3b1a71\"}]';
        system.debug('json='+json);
        Test.startTest();
        ChangeActivityInMlogEmail  ChangeActivity = new ChangeActivityInMlogEmail('Commute',json);
        Database.executeBatch( ChangeActivity, 1);
        Test.stopTest();
        
        
    }
}