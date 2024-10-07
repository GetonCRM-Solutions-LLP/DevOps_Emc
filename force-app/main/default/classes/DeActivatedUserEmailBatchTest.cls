@isTest
public class DeActivatedUserEmailBatchTest
{
   public static testmethod void Testmethod1()
    {   TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c tdKeys =TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = true;
        setting.Send_to_me__c = false;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);

        Account acc = new Account();
        acc = TestDataFactory.createAccount(false,'Test',true);
        acc.Vehicle_Types__c=vehicleObj.name;
        acc.True_Dialog__c = true;
        acc.Vehicle_Types__c = vehicleObj.Name;
        insert acc;

        List<Contact> AdminconList = new List<Contact>();
        AdminconList = TestDataFactory.createDriverContact(false, acc.Id, 'Admin', vehicleObj.Name, 'test.patel111478gocAdmin', 1);
        AdminconList[0].send_deactivation_Email__c=true;
     	Insert  AdminconList;
        List<Contact> ManagerconList = new List<Contact>();
        ManagerconList = TestDataFactory.createDriverContact(false, acc.Id, 'Manager', vehicleObj.Name, 'test.patel111478gocman', 1);
		ManagerconList[0].send_deactivation_Email__c=true;
     	Insert  ManagerconList;
     
        List<Contact> DriverconList = new List<Contact>();
        DriverconList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.patel111478dri', 1);
     	DriverconList[0].Manager__c = ManagerconList[0].Id;
     	insert DriverconList;
 	    
     	List<Bi_Weekly_Reimbursement__c> biweek= new List<Bi_Weekly_Reimbursement__c>();
        biweek =TestDataFactory.createBiweeklyReim(true,DriverconList,system.today().addDays(-15),system.today(),1,irsRateObj.id);

        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(false,DriverconList,1,irsRateObj.id);
        er[0].Contact_Id__c = DriverconList[0].Id;
        er[0].Month__c = DeActivatedUserBatch.currentMonth(0);
        er[0].Name = contact.lastname+':'+er[0].month__c;
        er[0].Status__c = 'Pending';
        er[0].Triplog_Status__c = 'U';
        insert er;
        
        
        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.EMP_Mileage__c = 100;
        emp.EmployeeReimbursement__c = er[0].id;
        emp.Bi_Weekly_Reimbursement__c = biweek[0].id;
        insert emp;
     
        DriverconList[0].Deactivated_Date__c =  System.today();
     	update DriverconList;
        
     	OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        
     	Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
        DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch(DriverconList[0].id);
		DeActivatedUserEmailBatch batchmileageobj1 = new DeActivatedUserEmailBatch();
     	DeActivatedUserEmailBatch batchmileageobj2 = new DeActivatedUserEmailBatch(toAddresses);
     	batchmileageobj.buildNoMileageEmail('','','','');
        //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
        DataBase.executeBatch(batchmileageobj, 1);
        Test.stopTest();
    } 
    /*
    public static testmethod void Testmethod2()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

         
        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = true;
        setting.Send_to_me__c = false;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;
        
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        acc.Vehicle_Types__c = '2020 Dodge Charger';
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c = null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        
        con.Deactivated_Date__c =  System.today();
     	update con;
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
            DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch();
            batchmileageobj.buildNoMileageEmail('','','','');
            //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
            DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }
    public static testmethod void Testmethod3()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = true;
        setting.Send_to_me__c = false;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 2.20;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 24;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.Mileage__c = 20;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        
        con.Deactivated_Date__c =  System.today();
     	update con;
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
            DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch();
            batchmileageobj.buildNoMileageEmail('','','','');
            //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
            DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }

    public static testmethod void Testmethod4()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = true;
        setting.Send_to_me__c = false;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 0;
        er.MPG__c = 0;
        er.Maintenance_and_Tires__c = 0;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.Mileage__c = 0;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        
        con.Deactivated_Date__c =  System.today();
     	update con;
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
        DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch();
        batchmileageobj.buildNoMileageEmail('','','','');
        //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
        DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }
    public static testmethod void Testmethod5()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = true;
        setting.Send_to_me__c = false;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 0;
        er.MPG__c = 0;
        er.Maintenance_and_Tires__c = 0;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.Mileage__c = 0;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        con.Deactivated_Date__c =  System.today();
     	update con;
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
        DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch();
        batchmileageobj.buildNoMileageEmail('','','','');
        //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
        DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }
     public static testmethod void Testmethod6()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = false;
        setting.Send_to_me__c = true;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c = null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 0;
        er.MPG__c = 0;
        er.Maintenance_and_Tires__c = 0;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.Mileage__c = 10;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        con.Deactivated_Date__c =  System.today();
     	update con;
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
        DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch(con.id);
        batchmileageobj.buildNoMileageEmail('','','','');
        //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
        DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    } 
    public static testmethod void Testmethod10()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

         
        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = false;
        setting.Send_to_me__c = true;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;
        
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        acc.Vehicle_Types__c = '2020 Dodge Charger';
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        
        con.Deactivated_Date__c =  System.today();
     	update con;
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
            DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch();
            batchmileageobj.buildNoMileageEmail('','','','');
            //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
            DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }
    public static testmethod void Testmethod8()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = false;
        setting.Send_to_me__c = true;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c = null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 2.20;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 24;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.Mileage__c = 20;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        con.Deactivated_Date__c =  System.today();
     	update con;
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
            DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch();
            batchmileageobj.buildNoMileageEmail('','','','');
            //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
            DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }
     public static testmethod void Testmethod7()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = false;
        setting.Send_to_me__c = true;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c = null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 0;
        er.MPG__c = 0;
        er.Maintenance_and_Tires__c = 0;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.Mileage__c = 0;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        con.Deactivated_Date__c =  System.today();
     	update con;
        
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
        DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch();
        batchmileageobj.buildNoMileageEmail('','','','');
        //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
        DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }
    public static testmethod void Testmethod9()
    {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Gujrat';
        obj_Address.City__c ='AHM';
        obj_Address.Abbreviation__c ='GJ';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'DeActivatedUserEmailBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        SendEmailonDeactivation__c setting = new SendEmailonDeactivation__c();
        setting.Send_to_Admin__c = false;
        setting.Send_to_me__c = true;
        setting.Name = 'DeActivatedUserEmailBatch';
        setting.BCCEmailaddresses__c = 'test@mymail.com,test1@mymail.com';
        insert setting;

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Dodge Charger';
        veh.Year__c = '2020';
        insert veh;
        
        Account acc = new Account();        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;        
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'Admin Contact';
        c.LastName = 'Test Contact';
        c.Triplog_UserID__c = 'test id';
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel111478gocAdmin@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = acc.Id;
        c.Role__c = 'Admin';
        c.Maintenance_and_Tires__c = 4.00;
        c.MPG__c = 22.00;
        c.send_deactivation_Email__c = true;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Triplog_Status__c = 'U';
        c.Vehicle_Type__c = '2020 Dodge Charger';
        c.Activation_Date__c=system.today();
        insert c;

        Contact co = new Contact();
        co.FirstName = 'Manager Contact';
        co.LastName = 'Test Contact';
        co.Triplog_UserID__c = 'test id';
        co.isCommunityUser__c = true;
        co.External_Email__c = 'test.patel111478gocman@gmail.com';
        co.IsDeactivated__c = false;
        co.AccountId = acc.Id;
        co.Manager__c = c.Id;
        co.Role__c = 'Manager';
        co.Maintenance_and_Tires__c = 4.00;
        co.MPG__c = 2.00;
        co.Mailingcity = 'AHM';
        co.MailingState = 'GJ';
        co.Triplog_Status__c = 'U';
        co.send_deactivation_Email__c = true;
        co.Vehicle_Type__c = '2020 Dodge Charger';
        co.Activation_Date__c=system.today();
        insert co;

        Contact con = new Contact();
        con.FirstName = 'Driver Contact';
        con.LastName = 'Test Contact temp';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  null;
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel111478dri@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = acc.Id;
        con.Role__c = 'Driver';
        con.Maintenance_and_Tires__c = 40.00;
        con.MPG__c = 50.00;
        con.Manager__c = co.Id;
        con.Mailingcity = 'AHM';
        con.MailingState = 'GJ';
        con.Triplog_Status__c = 'U';
        con.send_deactivation_Email__c = true;
        con.Vehicle_Type__c = '2020 Dodge Charger';
        con.Activation_Date__c=system.today();
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Month__c = DeActivatedUserBatch.currentMonth(0);
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 0;
        er.MPG__c = 0;
        er.Maintenance_and_Tires__c = 0;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Mileage__c emp = new  Employee_Mileage__c();
        emp.Name = 'DelToMumbai';
        emp.Contact_Email_Id__c = 'abc@abc.com';
        emp.Trip_Date__c = Date.today().addDays(-10);
        emp.Trip_Origin__c = 'Delhi';
        emp.Trip_Destination__c = 'Mumbai';
        emp.Mileage__c = 0;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        con.Deactivated_Date__c =  System.today();
     	update con;
        
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Test.startTest();
        List<String> toAddresses = new List<String>();
        toAddresses.add('natavar.goc@gmail.com');
        List<String> contactList = new List<String>();
        contactList.add(con.id);
        DeActivatedUserEmailBatch batchmileageobj = new DeActivatedUserEmailBatch(contactList);
        batchmileageobj.buildNoMileageEmail('','','','');
        //batchmileageobj.buildemail(owea.get(0).Id,toAddresses,'','');
        DataBase.executeBatch(batchmileageobj, 1);            
        Test.stopTest();
    }*/
}