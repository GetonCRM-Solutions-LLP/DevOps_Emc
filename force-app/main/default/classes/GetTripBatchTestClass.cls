@istest
public class GetTripBatchTestClass {

    
    public static testmethod void GetTriptest() {
        List<Id> contactids = new List<Id>();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c  objSendEmail = new SendEmail__c();
        objSendEmail.Name = 'Send Email For Compliance';
        objSendEmail.Send_email_from_code__c = false;
        insert objSendEmail;

        SendEmailToMe__c objSendEmailToMe = new SendEmailToMe__c();
        objSendEmailToMe.Name = 'GetTripCallOutApprovePutCall';
        objSendEmailToMe.Send_email_to_me__c = true;
        insert objSendEmailToMe;
        
        Get_Trip_Date_Settings__c tripdatesetting = new Get_Trip_Date_Settings__c();
        tripdatesetting.Name = 'Date Settings';
        tripdatesetting.End_Date__c = '03/31/2019';
        tripdatesetting.Start_Date__c = '03/01/2019';
        tripdatesetting.Last_N_Days__c = '31';
        insert tripdatesetting;
        
        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'S';
        insert Acc;
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = Acc.Id;
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
        contact.Email = 'minkesh.patel1478@gmail.com';
        contact.isCommunityUser__c = true;
        insert contact;
        contactids.add(contact.Id);
        
        Contact con = new Contact();
        con.lastname = 'Test Con';
        con.AccountId = Acc.Id;
        con.External_Email__c = 'minkesh.patel1357@gmail.com';
        con.Email = 'minkesh.patel1357@gmail.com';
        con.Triplog_Status__c = 'S';
        con.isCommunityUser__c = true;
        insert con;
        contactids.add(con.Id);
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        
        er.month__c = '03-2019';
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
        conReim.put(con.Id,er);

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        emp.Trip_Id__c = 122;
        insert emp;
        
        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        GetTripBatchClass trip = new GetTripBatchClass();
        GetTripBatchClass trip1 = new GetTripBatchClass(acc.id,'U');
        GetTripBatchClass trip2 = new GetTripBatchClass(contactids,'U');
        GetTripBatchClass trip3 = new GetTripBatchClass('U');
        Database.executeBatch(trip3, 1);
        
        Test.stopTest();
    }
}