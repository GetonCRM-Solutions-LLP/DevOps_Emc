@isTest
public class UpdateReimAndMileageController_test {
    public static testMethod Void UpdateReimAndMileageController_TestMethod1() {

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account account = new Account();
        account.name = 'Test Account';
        insert account;
           
        Contact contact = new Contact();
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.lastname = 'Test Contact';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test1@test.com';
        contact.Fixed_Amount__c = 0.0;
        contact.MailingState = 'CA';
        contact.MailingCity = 'Canyon';
        contact.role__c = 'Driver';
        insert contact;
        
        Employee_Reimbursement__c erRec = new Employee_Reimbursement__c();
        erRec.Contact_Id__c = contact.Id;
        erRec.month__c = '01-2018';
        erRec.Name = contact.lastname+':'+erRec.month__c;
        erRec.Status__c = 'Pending';
        erRec.Fuel_Price__c = 2.22;
        erRec.Approved_Date__c = system.today() - 3;
        erRec.Fixed_Amount__c = 10.10;
        insert erRec;
        
        Employee_Mileage__c empMileageRec = new Employee_Mileage__c();
        empMileageRec.Contact_Email_Id__c = 'test1@test1.gmail.com';
        empMileageRec.Name = 'Test Mileage Record';
        empMileageRec.EmployeeReimbursement__c = erRec.id;
        empMileageRec.Fuel_price__c = erRec.Fuel_Price__c;
        empMileageRec.Trip_Status__c = 'Approved';
        empMileageRec.Approved_Date__c = system.today() - 1;
        insert empMileageRec;
        
        Test.startTest();
        PageReference pageRef = Page.UpdateReimAndMileage;
       
        Test.setCurrentPage(pageRef);
        UpdateReimAndMileageController controller = new UpdateReimAndMileageController();
        controller.Selected_contact_id = contact.id;
        controller.getTripStatus();
        controller.getReimbersments();
        controller.Selected_reimbersments = erRec.id;
        controller.getReimbersmentDetails();
        controller.getContacts();
        controller.getContactsMileages();
       
        
        Test.stopTest();
    }
    public static testMethod Void UpdateReimAndMileageController_TestMethod2() {

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
     
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account account = new Account();
        account.name = 'Test Account';
        insert account;
           
        Contact contact = new Contact();
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.lastname = 'Test Contact';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test2@test.com';
        contact.Fixed_Amount__c = 0.0;
        contact.MailingState = 'CA';
        contact.MailingCity = 'Canyon';
        contact.role__c = 'Driver';
        insert contact;
        
        Employee_Reimbursement__c erRec = new Employee_Reimbursement__c();
        erRec.Contact_Id__c = contact.Id;
        erRec.month__c = '01-2018';
        erRec.Name = contact.lastname+':'+erRec.month__c;
        erRec.Status__c = 'Pending';
        erRec.Fuel_Price__c = 2.22;
        erRec.Approved_Date__c = system.today() - 3;
        erRec.Fixed_Amount__c = 10.10;
        insert erRec;
        
        Employee_Mileage__c empMileageRec = new Employee_Mileage__c();
        empMileageRec.Contact_Email_Id__c = 'test1@test1.gmail.com';
        empMileageRec.Name = 'Test Mileage Record';
        empMileageRec.EmployeeReimbursement__c = erRec.id;
        empMileageRec.Fuel_price__c = erRec.Fuel_Price__c;
        empMileageRec.Trip_Status__c = 'Approved';
        empMileageRec.Approved_Date__c = system.today() - 1;
        insert empMileageRec;
        
        Test.startTest();
        PageReference pageRef = Page.UpdateReimAndMileage;
       
        Test.setCurrentPage(pageRef);
        UpdateReimAndMileageController controller = new UpdateReimAndMileageController();
        
        
        controller.getReimbersments();
        
        controller.getReimbersmentDetails();
       
        
        Test.stopTest();
    }
    public static testMethod Void UpdateReimAndMileageController_TestMethod3() {
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
     
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account account = new Account();
        account.name = 'Test Account';
        insert account;
           
        Contact contact = new Contact();
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.lastname = 'Test Contact';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test3@test.com';
        contact.Fixed_Amount__c = 0.0;
        contact.MailingState = 'CA';
        contact.MailingCity = 'Canyon';
        contact.role__c = 'Driver';
        insert contact;
        
        Employee_Reimbursement__c erRec = new Employee_Reimbursement__c();
        erRec.Contact_Id__c = contact.Id;
        erRec.month__c = '01-2018';
        erRec.Name = contact.lastname+':'+erRec.month__c;
        erRec.Status__c = 'Pending';
        erRec.Fuel_Price__c = 2.22;
        erRec.Approved_Date__c = system.today() - 3;
        erRec.Fixed_Amount__c = 10.10;
        insert erRec;
        
        Employee_Mileage__c empMileageRec = new Employee_Mileage__c();
        empMileageRec.Contact_Email_Id__c = 'test1@test1.gmail.com';
        empMileageRec.Name = 'Test Mileage Record';
        empMileageRec.EmployeeReimbursement__c = erRec.id;
        empMileageRec.Fuel_price__c = erRec.Fuel_Price__c;
        empMileageRec.Trip_Status__c = 'Approved';
        empMileageRec.Approved_Date__c = system.today() - 1;
        insert empMileageRec;
        
        Test.startTest();
        PageReference pageRef = Page.UpdateReimAndMileage;
       
        Test.setCurrentPage(pageRef);
        UpdateReimAndMileageController controller = new UpdateReimAndMileageController();
        controller.Selected_contact_id = contact.id;
        
        controller.getReimbersments();
        controller.Selected_reimbersments = erRec.id;
        
        controller.getReimbersmentDetails();
       
        controller.updateReimbersment();
        Test.stopTest();
    }
    public static testMethod Void UpdateReimAndMileageController_TestMethod4() {
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account account = new Account();
        account.name = 'Test Account';
        insert account;
           
        Contact contact = new Contact();
        contact.Vehicle_Type__c = '2019 Full-Size Sedan';
        contact.lastname = 'Test Contact';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test4@test.com';
        contact.Fixed_Amount__c = 0.0;
        contact.MailingState = 'CA';
        contact.MailingCity = 'Canyon';
        contact.role__c = 'Driver';
        insert contact;
        
        Employee_Reimbursement__c erRec = new Employee_Reimbursement__c();
        erRec.Contact_Id__c = contact.Id;
        erRec.month__c = '01-2018';
        erRec.Name = contact.lastname+':'+erRec.month__c;
        erRec.Status__c = 'Pending';
        erRec.Fuel_Price__c = 2.22;
        erRec.Approved_Date__c = system.today() - 3;
        erRec.Fixed_Amount__c = 10.10;
        insert erRec;
        
        Employee_Mileage__c empMileageRec = new Employee_Mileage__c();
        empMileageRec.Contact_Email_Id__c = 'test1@test1.gmail.com';
        empMileageRec.Name = 'Test Mileage Record';
        empMileageRec.EmployeeReimbursement__c = erRec.id;
        empMileageRec.Fuel_price__c = erRec.Fuel_Price__c;
        empMileageRec.Trip_Status__c = 'Approved';
        empMileageRec.Approved_Date__c = system.today() - 1;
        insert empMileageRec;
        
        Test.startTest();
        PageReference pageRef = Page.UpdateReimAndMileage;
       
        Test.setCurrentPage(pageRef);
        UpdateReimAndMileageController controller = new UpdateReimAndMileageController();
        controller.Selectedcontactid_mileages= contact.id;
        
        controller.getReimbersmentsmileages();
        controller.Selected_reimbersments_mileages= erRec.id;
        controller.Selected_contact_id = null;
        controller.showDetailofMileages();
        controller.updatemileages();
        controller.Selected_reimbersments_mileages =null;
        controller.obj_mileage_to_update = null;
        controller.updatemileages();
        controller.updateReimbersment();
        controller.cancelall();
        Test.stopTest();
    }

    
}