@isTest
public class MassSyncTripforCommuteBeforeTest {
    public static testmethod void GetTriptest() {
        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmailToMe__c  objSendEmailToMe = new SendEmailToMe__c();
        objSendEmailToMe.Name = 'GetTripCallOutApprovePutCall';
        objSendEmailToMe.Send_email_to_me__c = true;
        insert objSendEmailToMe;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        IRS_Mileage_Rate__c irs = new IRS_Mileage_Rate__c();
     irs.year__c = '2021';
     irs.IRS_Rate__c = 0.85;
     
     insert irs;

        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'U';
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = Acc.Id;
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Email = 'minkesh.patel1478@gmail.com';
        contact.isCommunityUser__c = true;
        contact.MailingCity='ahmedabad';
        contact.MailingState='GJ';
        contact.compliancestatus__c = 'No – Vehicle Age';
        contact.Vehicle_Type__c = '2019 Mileage Rate';
        insert contact;
        contactids.add(contact.Id);
        
        Contact con = new Contact();
        con.lastname = 'Test Con';
        con.AccountId = Acc.Id;
        con.External_Email__c = 'minkesh.patel1357@gmail.com';
        con.Email = 'minkesh.patel1357@gmail.com';
        con.Triplog_Status__c = 'U';
        con.compliancestatus__c = 'No – Vehicle Age';
        con.isCommunityUser__c = true;
        insert con;
        contactids.add(con.Id);
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        
        er.month__c = '09-2020';
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
        MassSyncTripforCommuteBefore.validate(Acc.Id,'2021-08-01','2021-08-16','07-2021','U',false, 'Business');
        Test.stopTest();
    }
}