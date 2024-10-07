@isTest
public class RG_AutoApprovedEmailClassTest {
    public static testmethod void approvedEmailTestMethod() {

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.mileageremoveapprovaldate__c = false;
        customSetting.MappingGasPriceTrigger__c = false;
        customSetting.MappingGasPriceTriggerUpdateConvertedDat__c = false;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmail__c customSet =  new SendEmail__c();
        customSet.Name = 'RG_AutoApprovedEmailClass';
        customSet.Send_email_from_code__c= false;
        insert customSet;
        
        SendEmailToMe__c customSetMe = new SendEmailToMe__c();
        customSetMe.Name = 'RG_AutoApprovedEmailClass';
        customSetMe.Send_email_to_me__c = true;
        insert customSetMe;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;

        Account acc = new Account();
        acc.Name = 'Acme Corporation';
        acc.Enable_Email_For_Managers__c = true;
        acc.Approval_Template_Message__c = 'test message';
        insert acc;

        Contact cont = new Contact();
        cont.LastName = 'TestdataContact';
        cont.AccountId = acc.Id;
        cont.External_Email__c = 'testd@email.com';
        cont.Fixed_Amount__c = 371.28;
        cont.MailingCity = 'Abilene';
        cont.MailingState = 'TX';
        cont.Driving_States__c = 'TX';
        cont.Time_Zone__c = 'America/Chicago';
        cont.Monthly_Mileage_Limit__c = 100.00;
        cont.Deactivated_Date__c = Date.today().addMonths(4);
        cont.Role__c = 'Driver/Admin';
        cont.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont;
        
        Contact con = new Contact();
        con.LastName = 'TestContact';
        con.AccountId = acc.Id;
        con.External_Email__c = 'test@email.com';
        con.Fixed_Amount__c = 371.28;
        con.MailingCity = 'Abilene';
        con.MailingState = 'TX';
        con.Driving_States__c = 'TX';
        con.Time_Zone__c = 'America/Chicago';
        con.Monthly_Mileage_Limit__c = 100.00;
        //con.Deactivated_Date__c = Date.today().addMonths(5);
        con.Role__c = 'Driver/Admin';
        con.Vehicle_Type__c = '2019 Full-Size Vehicle';
        con.Manager__c = cont.Id;
        insert con;
        
        Contact con2 = new Contact();
        con2.LastName = 'TestContact2';
        con2.AccountId = acc.Id;
        con2.External_Email__c = 'test2@email.com';
        con2.Fixed_Amount__c = 371.28;
        con2.MailingCity = 'Abilene';
        con2.MailingState = 'TX';
        con2.Driving_States__c = 'TX';
        con2.Time_Zone__c = 'America/Chicago';
        con2.Monthly_Mileage_Limit__c = 100.00;
        //con2.Deactivated_Date__c = Date.today().addMonths(5);
        con2.Role__c = 'Driver/Admin';
        con2.Manager__c = con.Id;
        con2.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert con2;
        
        Contact cont3 = new Contact();
        cont3.LastName = 'TestContact3';
        cont3.AccountId = acc.Id;
        cont3.External_Email__c = 'test3@email.com';
        cont3.Fixed_Amount__c = 371.28;
        cont3.MailingCity = 'Abilene';
        cont3.MailingState = 'TX';
        cont3.Driving_States__c = 'TX';
        cont3.Time_Zone__c = 'America/Chicago';
        cont3.Monthly_Mileage_Limit__c = 100.00;
        //cont3.Deactivated_Date__c = Date.today().addMonths(5);
        cont3.Role__c = 'Driver';
        cont3.Manager__c = con2.Id;
        cont3.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont3;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Driver']; 
        User user = new User(Alias = 'standt', 
                            Email='standarduser1@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser2@testorg.com',
                            Contactid = con.id,
                            IsActive = True
                        );
        insert user;

        String tempDate = date.today().addMonths(-1).Month() + '-' + date.today().addMonths(-1).Year();
        String lastMonth = tempDate.left(2);

        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = lastMonth;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;

        Employee_Reimbursement__c er2 = new Employee_Reimbursement__c();
        er2.Contact_Id__c = cont3.Id;
        er2.Name = 'Reimbersment Test2';
        er2.Month__c = lastMonth;
        er2.Status__c = 'Pending';
        er2.Fuel_Price__c = 20.00;
        insert er2;

        Employee_Reimbursement__c er3 = new Employee_Reimbursement__c();
        er3.Contact_Id__c = con2.Id;
        er3.Name = 'Reimbersment Test4';
        er3.Month__c = lastMonth;
        System.debug('er3.Month__c =='+er3.Month__c );
        er3.Status__c = 'Pending';
        er3.Fuel_Price__c = 50.00;
        insert er3;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = 'Not Approved Yet';
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = date.today().adddays(-1);
        insert emp;

        Test.startTest();
        RG_AutoApprovedEmailClass batchcon = new RG_AutoApprovedEmailClass();
        DataBase.executeBatch(batchcon, 1);
        Test.stopTest();
    }
    public static testmethod void test2() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.mileageremoveapprovaldate__c = false;
        customSetting.MappingGasPriceTrigger__c = false;
        customSetting.MappingGasPriceTriggerUpdateConvertedDat__c = false;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= false;
        insert customSetting1;
        
        SendEmail__c customSet =  new SendEmail__c();
        customSet.Name = 'RG_AutoApprovedEmailClass';
        customSet.Send_email_from_code__c = false;        
        insert customSet;
        
        SendEmailToMe__c customSetMe = new SendEmailToMe__c();
        customSetMe.Name = 'RG_AutoApprovedEmailClass';
        customSetMe.Send_email_to_me__c = true;
        insert customSetMe;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;

        Account acc = new Account();
        acc.Name = 'Acme Corporation';
        acc.Enable_Email_For_Managers__c = true;
        acc.Approval_Template_Message__c = '';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'TestContact';
        con.AccountId = acc.Id;
        con.External_Email__c = 'test@email.com';
        con.Fixed_Amount__c = 371.28;
        con.MailingCity = 'Abilene';
        con.MailingState = 'TX';
        con.Driving_States__c = 'TX';
        con.Time_Zone__c = 'America/Chicago';
        con.Monthly_Mileage_Limit__c = 100.00;
        //con.Deactivated_Date__c = Date.today().addMonths(5);
        con.Role__c = 'Driver';
        con.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert con;

        
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Driver']; 
        User user = new User(Alias = 'standt', 
                            Email='standarduser1@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser2@testorg.com',
                            Contactid = con.id,
                            IsActive = True
                        );
        insert user;
        
        list<Gas_Prices__c> gaslist = new  list<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) 
        {
            gaslist.add(new  Gas_Prices__c(City__c = 'Delhi' + i, Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 't' + i));
        }
        Insert gaslist;

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = '09-2017';
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = 'Not Approved Yet';
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = date.today().adddays(-1);
        insert emp;

        Test.startTest();
        RG_AutoApprovedEmailClass batchcon = new RG_AutoApprovedEmailClass();
        DataBase.executeBatch(batchcon, 1);
        Test.stopTest();
    }
}