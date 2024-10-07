@isTest
public class GetTripBatchClassTest {
    
    public static testmethod void GetTriptest() {

        RecordUtilityClass.vehicleUrlMapping();

        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'GetTripCallOutApprovePutCall';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'U';
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = Acc.Id;
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Time_Zone__c = 'America/Chicago';
        contact.MailingCity = 'Abilene';
        contact.MailingState = 'TX';
        contact.Driving_States__c = 'TX';
        contact.Email = 'minkesh.patel1478@gmail.com';
        contact.isCommunityUser__c = true;
        insert contact;
        contactids.add(contact.Id);
        
        Contact con = new Contact();
        con.lastname = 'Test Con';
        con.AccountId = Acc.Id;
        con.External_Email__c = 'minkesh.patel1357@gmail.com';
        con.Email = 'minkesh.patel1357@gmail.com';
        con.Time_Zone__c = 'America/Chicago';
        con.MailingCity = 'Abilene';
        con.MailingState = 'TX';
        con.Driving_States__c = 'TX';
        con.Triplog_Status__c = 'U';
        con.isCommunityUser__c = true;
        insert con;
        contactids.add(con.Id);
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        
        er.month__c = getLastMonthValue(-1);
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

        List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
        insert driverMileagesList;
        
        // Employee_Mileage__c emp = new Employee_Mileage__c();
        // emp.Contact_Email_Id__c = 'test@test.gmail.com';
        // emp.Name = 'Test Mileage Record';
        // emp.StartTime__c = DateTime.newInstance(2019, 6, 6, 3, 3, 3);
        // emp.EmployeeReimbursement__c = er.id;
        // insert emp;
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        
        insert emp;

        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetTripBatchClass obj = new GetTripBatchClass();
        DataBase.executeBatch(obj);
        GetTripBatchClass gt = new GetTripBatchClass(acc.Id, er.Triplog_Status__c);
        DataBase.executeBatch(gt);
        GetTripBatchClass gtB = new GetTripBatchClass(contactids, er.Triplog_Status__c);
        DataBase.executeBatch(gtB);
        Test.stopTest();
    }
    public static testmethod void GetTriptest1() {
        RecordUtilityClass.vehicleUrlMapping();

        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'GetTripCallOutApprovePutCall';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'A';
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.AccountId = Acc.Id;
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Email = 'minkesh.patel1478@gmail.com';
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Time_Zone__c = 'America/Chicago';
        contact.MailingCity = 'Abilene';
        contact.MailingState = 'TX';
        contact.Driving_States__c = 'TX';
        contact.isCommunityUser__c = true;
        insert contact;
        contactids.add(contact.Id);
        
        Contact con = new Contact();
        con.lastname = 'Test Con';
        con.AccountId = Acc.Id;
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.External_Email__c = 'minkesh.patel1357@gmail.com';
        con.Email = 'minkesh.patel1357@gmail.com';
        con.Triplog_Status__c = 'A';
        con.Time_Zone__c = 'America/Chicago';
        con.MailingCity = 'Abilene';
        con.MailingState = 'TX';
        con.Driving_States__c = 'TX';
        con.isCommunityUser__c = true;
        insert con;
        contactids.add(con.Id);
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        
        er.month__c = getLastMonthValue(-1);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'A';
        insert er;
        conReim.put(con.Id,er);
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        insert emp;
        
        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetTripBatchClass obj = new GetTripBatchClass();
        DataBase.executeBatch(obj);
        GetTripBatchClass gt = new GetTripBatchClass(acc.Id, er.Triplog_Status__c);
        DataBase.executeBatch(gt);
        GetTripBatchClass gtB = new GetTripBatchClass(contactids, er.Triplog_Status__c);
        DataBase.executeBatch(gtB);
        Test.stopTest();
    }
     public static testmethod void GetTriptest2() {
        RecordUtilityClass.vehicleUrlMapping();
        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'GetTripCallOutApprovePutCall';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'S';
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.AccountId = Acc.Id;
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Email = 'minkesh.patel1478@gmail.com';
        contact.Time_Zone__c = 'America/Chicago';
        contact.MailingCity = 'Abilene';
        contact.MailingState = 'TX';
        contact.Driving_States__c = 'TX';
        contact.isCommunityUser__c = true;
        insert contact;
        contactids.add(contact.Id);
        
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        
        er.month__c = getLastMonthValue(-1);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'S';
        insert er;
       // conReim.put(con.Id,er);
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        insert emp;
        
        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetTripBatchClass obj = new GetTripBatchClass();
        DataBase.executeBatch(obj);
        GetTripBatchClass gt = new GetTripBatchClass(acc.Id, er.Triplog_Status__c);
        DataBase.executeBatch(gt);
        GetTripBatchClass gtB = new GetTripBatchClass(contactids, er.Triplog_Status__c);
        DataBase.executeBatch(gtB);
        Test.stopTest();
    }
     public static testmethod void GetTriptest3() {
        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'GetTripCallOutApprovePutCall';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'U';
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = Acc.Id;
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Time_Zone__c = 'America/Chicago';
        contact.MailingCity = 'Abilene';
        contact.MailingState = 'TX';
        contact.Email = 'minkesh.patel1478@gmail.com';
        contact.isCommunityUser__c = true;
        insert contact;
        contactids.add(contact.Id);
        
        Contact con = new Contact();
        con.lastname = 'Test Con';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.AccountId = Acc.Id;
        con.External_Email__c = 'minkesh.patel1357@gmail.com';
        con.Email = 'minkesh.patel1357@gmail.com';
        con.Time_Zone__c = 'America/Chicago';
        con.MailingCity = 'Abilene';
        con.MailingState = 'TX';
        con.Triplog_Status__c = 'U';
        con.isCommunityUser__c = true;
        insert con;
        contactids.add(con.Id);
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        
        er.month__c = getLastMonthValue(-1);
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
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        
        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetTripBatchClass obj = new GetTripBatchClass();
        DataBase.executeBatch(obj);
        GetTripBatchClass obj1 = new GetTripBatchClass('U');
        DataBase.executeBatch(obj1);
        GetTripBatchClass gt = new GetTripBatchClass(acc.Id, er.Triplog_Status__c);
        DataBase.executeBatch(gt);
        GetTripBatchClass gtB = new GetTripBatchClass(contactids, er.Triplog_Status__c);
        DataBase.executeBatch(gtB);
        Test.stopTest();
    }
    public static String getLastMonthValue(Integer value) {
        String tempDate = date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }
        return lastMonth;
    }
}