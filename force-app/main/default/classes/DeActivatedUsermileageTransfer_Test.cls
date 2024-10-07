@isTest
Public Class DeActivatedUsermileageTransfer_Test
{
    Static testMethod void testMethod1()
    {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c = true;
        insert customSetting1;

        Account acc = new Account();
        acc.name = 'Test';
        acc.Triplog_API__c = 'test2';
        acc.isUsingTriplog__c = true;
        Insert acc;

        Gas_Prices__c g = new Gas_Prices__c();
        g.Fuel_Price__c = 2.20;
        g.Month_Year__c = Date.valueof('2019-07-01');
        g.State__c = 'GJ';
        g.City__c = 'AHM';
        insert g;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        

        List<Contact> cList = new List<Contact>();
        Contact c = new Contact();
        c.LastName = 'test1';
        c.Triplog_UserID__c = 'test1';
        c.Deactivated_Date__c =  system.now();
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel14178@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Driver/Manager';
        c.Maintenance_and_Tires__c = 40.00;
        c.MPG__c = 50.00;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Vehicle_Type__c = '2019 Full-Size Sedan';
       // insert c;
        cList.add(c);

        Contact c1 = new Contact();
        c1.LastName = 'test';
        c1.Triplog_UserID__c = 'test';
        //c1.Deactivated_Date__c =  system.now();
        c1.isCommunityUser__c = true;
        c1.External_Email__c = 'test.patel1478@gmail.com';
        c1.IsDeactivated__c = false;
        c1.AccountId = acc.Id;
        c1.Role__c = 'Driver';
        c1.Maintenance_and_Tires__c = 40.00;
        c1.MPG__c = 50.00;
        c1.Mailingcity = 'AHM';
        c1.MailingState = 'GJ';
        c1.Vehicle_Type__c = '2019 Full-Size Sedan';
        cList.add(c1);
        insert cList;

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Name = 'Virn:08-2019';
        er.Contact_Id__c = c.id; 
        er.Month__c = '02-2020';
        insert er;

        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Name = 'Virn:07-2019';
        er1.Contact_Id__c = c1.id; 
        er1.Month__c = '01-2020';
        insert er1;
        
        Employee_Mileage__c em = new Employee_Mileage__c();
        em.Name = 'MileageNameone';
        em.EmployeeReimbursement__c =  er.id;
        em.Trip_Status__c = StaticValues.noApprovedYet;
        em.Approved_Date__c = null;
        em.Carry_Forward_Mileage__c = false;
        em.Contact_Email_Id__c = 'test.patel1478@gmail.com';
        em.Mileage__c = 20.5;
        insert em;

        Employee_Mileage__c em1 = new Employee_Mileage__c();
        em1.Name = 'MileageNameone1';
        em1.EmployeeReimbursement__c =  er.id;
        em1.Trip_Status__c = StaticValues.noApprovedYet;
        em1.Approved_Date__c = null;
        em1.Carry_Forward_Mileage__c = false;
        em1.Contact_Email_Id__c = 'test.patel1478@gmail.com';
        em1.Mileage__c = 21.5;
        insert em1;

        Employee_Mileage__c em2 = new Employee_Mileage__c();
        em2.Name = 'MileageNameone2';
        em2.EmployeeReimbursement__c =  er1.id;
        em2.Trip_Status__c =StaticValues.noApprovedYet;
        em2.Approved_Date__c = null;
        em2.Carry_Forward_Mileage__c = false;
        em2.Contact_Email_Id__c = 'test.patel1478@gmail.com';
        em2.Mileage__c = 22.5;
        insert em2;
        
        Employee_Reimbursement__c empReimb = new Employee_Reimbursement__c();
        empReimb.Name = 'Virn:01-2020';
        empReimb.Contact_Id__c = c.id; 
        empReimb.Month__c = '02-2020';
        insert empReimb;
        
        Employee_Mileage__c empMil=new Employee_Mileage__c();
        empMil.Trip_Status__c=Label.Not_Approved_Yet_Mileage_Status;
        empMil.Approved_Date__c=null;
        empMil.EmployeeReimbursement__c =  empReimb.id;
        empMil.Contact_Email_Id__c = 'test.patel1478@gmail.com';
        insert empMil;
        
        c1.Deactivated_Date__c =  system.now();
        update c1;
        
        List<String> contactIds=new List<String>();
        contactIds.add(c1.id);

        Test.startTest();
        DeActivatedUsermileageTransfer obj = new DeActivatedUsermileageTransfer();
        Database.executeBatch(obj);
        
        DeActivatedUsermileageTransfer objacc = new DeActivatedUsermileageTransfer(acc.id);
        Database.executeBatch(objacc);

        DeActivatedUsermileageTransfer objcon = new DeActivatedUsermileageTransfer(contactIds);
        Database.executeBatch(objcon);
        
        Test.stopTest();
    }
}