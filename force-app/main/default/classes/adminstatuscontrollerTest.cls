@isTest
private class adminstatuscontrollerTest
{
    static Testmethod void CaseOne() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        IRS_Mileage_Rate__c mileageRateObj = new IRS_Mileage_Rate__c();
        mileageRateObj.IRS_Rate__c = 12.9;
        mileageRateObj.year__c = String.valueOf((System.today().year()));
        insert mileageRateObj;
        
        IRS_Mileage_Rate__c mileageRateObj1 = new IRS_Mileage_Rate__c();
        mileageRateObj1.IRS_Rate__c = 12.9;
        mileageRateObj1.year__c = String.valueOf((System.today().year()-1));
        insert mileageRateObj1;

        Account accs = new Account();
        accs.Name = 'test';
        accs.Triplog_API__c = 'test1';
        accs.isUsingTriplog__c = true;
        accs.Motor_Vehicle_Record_Check_Document__c = true;
        insert accs;

        Contact con1 = new Contact();
        con1.LastName = 'testsdfsdfs';
        con1.Triplog_UserID__c = 'test';
        con1.Deactivated_Date__c =  system.now();
        con1.isCommunityUser__c = true;
        con1.External_Email__c = 'test.patel143478@gmail.com';
        con1.IsDeactivated__c = false;
        con1.AccountId = accs.Id;
        con1.Role__c = 'Admin';
       
        insert con1;

        Contact con = new Contact();
        con.LastName = 'test';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  system.now();
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel1478@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = accs.Id;
        con.Role__c = 'Driver';
        con.compliancestatus__c = 'Yes';
        insert con;

        Attachment att = new Attachment();
        att.parentID = con.Id;
        att.name = 'test';
        att.body = blob.valueOf('Test');
        insert att;

        /*Attendee__c obj_Attendee = new Attendee__c();
        obj_Attendee.Contact__c = con.id;
        obj_Attendee.Email__c =  con.External_Email__c;
        obj_Attendee.First_Name__c = con.FirstName;
        obj_Attendee.Last_Name__c = con.LastName;
        obj_Attendee.Registrant_key__c = '1234e6';
        obj_Attendee.Registration_date__c = System.today();
        obj_Attendee.Status__c = 'Driver Scheduled Meeting';
        obj_Attendee.Join_Url__c = ''; 
        insert obj_Attendee;*/

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        //er.isDriver = true;
        er.Contact_Id__c = con.Id;
        
        er.month__c = '11-2018';
        er.Name = con.lastname+':system.today()';
        er.Status__c = 'Approved';
        er.Fuel_Price__c = 1; 
        er.MPG__c = 10.00;
        er.Approved_Date__c = system.Today();
        er.Maintenance_and_Tires__c = 24;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = con.Id;
        
        er1.month__c = '08-2018';
        er1.Name = con.lastname+':system.today()';
        er1.Status__c = 'Approved';
        er1.Fuel_Price__c = 1; 
        er1.MPG__c = 10.00;
        er1.Maintenance_and_Tires__c = 24;
        er1.MPG__c = 10;
        er1.Approved_Date__c = system.Today();
        er1.Maintenance_and_Tires__c = 10;
        er1.Fixed_Amount__c = 10.10;
        er1.Triplog_Status__c = 'U';
        insert er1;

        Employee_Reimbursement__c er2 = new Employee_Reimbursement__c();
        er2.Contact_Id__c = con.Id;
        
        er2.month__c = '09-2018';
        er2.Name = con.lastname+':system.today()';
        er2.Status__c = 'Approved';
        er2.Fuel_Price__c = 1; 
        er2.MPG__c = 10.00;
        er2.Maintenance_and_Tires__c = 24;
        er2.MPG__c = 10;
        er2.Approved_Date__c = system.Today();
        er2.Maintenance_and_Tires__c = 10;
        er2.Fixed_Amount__c = 10.10;
        er2.Triplog_Status__c = 'U';
        insert er2;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        emp.Mileage__c = 10000;
        insert emp;

        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp1.Name = 'Test Mileage Record';
        emp1.EmployeeReimbursement__c = er1.id;
        emp1.Mileage__c = 10000;
        insert emp1;

        Employee_Mileage__c emp2 = new Employee_Mileage__c();
        emp2.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp2.Name = 'Test Mileage Record';
        emp2.EmployeeReimbursement__c = er2.id;
        emp2.Mileage__c = 10000;
        insert emp2;

        Test.StartTest();
        
        ApexPages.currentPage().getParameters().put('manid', String.valueOf(con1.Id));
        ApexPages.currentPage().getParameters().put('drid', String.valueOf(con.Id));
        adminstatuscontroller controller = new adminstatuscontroller();
        controller.driver = con;
        controller.compliancestatus();
        controller.isDriver = true;
        controller.isManager = true;
        controller.isSuperManager = true;
        controller.obj_reciptsize  = 10;
        controller.accesstoken = 'test';
        controller.obj_category = 'Driver Meeting';
        controller.currentdate = system.today();
        controller.compliancestatus();
       // controller.updatestatus();
        controller.obj_category = 'Signed Packet';
       // controller.updatestatus();
        controller.obj_category = 'Driver Packet';
       // controller.updatestatus();
        controller.showPopup();
        controller.showPopup1();
        controller.closePopup();
        controller.closePopup1();
      //  controller.updateWebinarecord();
  

    }
    static Testmethod void CaseOne1() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        IRS_Mileage_Rate__c mileageRateObj = new IRS_Mileage_Rate__c();
        mileageRateObj.IRS_Rate__c = 12.9;
        mileageRateObj.year__c = String.valueOf((System.today().year()));
        insert mileageRateObj;
        
        IRS_Mileage_Rate__c mileageRateObj1 = new IRS_Mileage_Rate__c();
        mileageRateObj1.IRS_Rate__c = 12.9;
        mileageRateObj1.year__c = String.valueOf((System.today().year()-1));
        insert mileageRateObj1;

        Account accs = new Account();
        accs.Name = 'test';
        accs.Triplog_API__c = 'test1';
        accs.isUsingTriplog__c = true;
        accs.Motor_Vehicle_Record_Check_Document__c = true;
        insert accs;

        Contact con1 = new Contact();
        con1.LastName = 'testsdfsdfs';
        con1.Triplog_UserID__c = 'test';
        con1.Deactivated_Date__c =  system.now();
        con1.isCommunityUser__c = true;
        con1.External_Email__c = 'test.patel143478@gmail.com';
        con1.IsDeactivated__c = false;
        con1.AccountId = accs.Id;
        con1.Role__c = 'Admin';
       
        insert con1;

        Contact con = new Contact();
        con.LastName = 'test';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  system.now();
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel1478@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = accs.Id;
        con.Role__c = 'Driver';
        con.compliancestatus__c = 'Yes';
        insert con;

        Attachment att = new Attachment();
        att.parentID = con.Id;
        att.name = 'test';
        att.body = blob.valueOf('Test');
        insert att;

       /* Attendee__c obj_Attendee = new Attendee__c();
        obj_Attendee.Contact__c = con.id;
        obj_Attendee.Email__c =  con.External_Email__c;
        obj_Attendee.First_Name__c = con.FirstName;
        obj_Attendee.Last_Name__c = con.LastName;
        obj_Attendee.Registrant_key__c = '1234e6';
        obj_Attendee.Registration_date__c = System.today();
        obj_Attendee.Status__c = 'Driver Scheduled Meeting';
        obj_Attendee.Join_Url__c = ''; 
        insert obj_Attendee;*/

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        //er.isDriver = true;
        er.Name = 'test';
        er.Contact_Id__c = con.Id;
        
        er.month__c = '06-2018';
        er.Name = con.lastname+':system.now()';
        er.Status__c = 'Approved';
        er.Fuel_Price__c = 1; 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;
        er.MPG__c = 10;
        er.Approved_Date__c = system.Today();
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        
        Employee_Reimbursement__c er5 = new Employee_Reimbursement__c();
        //er.isDriver = true;
        er5.Name = 'test';
        er5.Contact_Id__c = con.Id;
        
        er5.month__c = '09-2018';
        er5.Name = con.lastname+':system.now()';
        er5.Status__c = 'Approved';
        er5.Fuel_Price__c = 1; 
        er5.MPG__c = 10.00;
        er5.Maintenance_and_Tires__c = 24;
        er5.MPG__c = 10;
        er5.Approved_Date__c = system.Today();
        er5.Maintenance_and_Tires__c = 10;
        er5.Fixed_Amount__c = 10.10;
        er5.Triplog_Status__c = 'U';
        insert er5;

        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = con.Id;
        er1.Name = 'test';
        er1.month__c = '07-2018';
        er1.Name = con.lastname+':8-2018';
        er1.Status__c = 'Approved';
        er1.Fuel_Price__c = 1; 
        er1.MPG__c = 10.00;
        er1.Approved_Date__c = system.Today();
        er1.Maintenance_and_Tires__c = 24;
        er1.MPG__c = 10;
        er1.Maintenance_and_Tires__c = 10;
        er1.Fixed_Amount__c = 10.10;
        er1.Triplog_Status__c = 'U';
        insert er1;

        Employee_Reimbursement__c er2 = new Employee_Reimbursement__c();
        er2.Contact_Id__c = con.Id;
        er2.Name = 'test';
        er2.month__c = '08-2018';
        er2.Name = con.lastname+':8-2018';
        er2.Status__c = 'Approved';
        er2.Fuel_Price__c = 1; 
        er2.MPG__c = 10.00;
        er2.Maintenance_and_Tires__c = 24;
        er2.MPG__c = 10;
        er2.Approved_Date__c = system.Today();
        er2.Maintenance_and_Tires__c = 10;
        er2.Fixed_Amount__c = 10.10;
        er2.Triplog_Status__c = 'U';
        insert er2;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        emp.Mileage__c = 10000;
        insert emp;

        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp1.Name = 'Test Mileage Record';
        emp1.EmployeeReimbursement__c = er1.id;
        emp1.Mileage__c = 10000;
        insert emp1;

        Employee_Mileage__c emp2 = new Employee_Mileage__c();
        emp2.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp2.Name = 'Test Mileage Record';
        emp2.EmployeeReimbursement__c = er2.id;
        emp2.Mileage__c = 10000;
        insert emp2;

        Test.StartTest();
        ApexPages.currentPage().getParameters().put('manid', String.valueOf(con1.Id));
        ApexPages.currentPage().getParameters().put('drid', String.valueOf(con.Id));
       
        adminstatuscontroller controller = new adminstatuscontroller();
        controller.driver = con;
        controller.compliancestatus();
        controller.isDriver = true;
        controller.isManager = true;
        controller.isSuperManager = true;
        controller.obj_reciptsize  = 10;
        controller.accesstoken = 'test';
        controller.obj_category = 'Driver Meeting';
        controller.currentdate = system.today();
        controller.compliancestatus();
       // controller.updatestatus();
        controller.obj_category = 'Signed Packet';
       // controller.updatestatus();
        controller.obj_category = 'Driver Packet';
       // controller.updatestatus();
        controller.showPopup();
        controller.showPopup1();
        controller.closePopup();
        controller.closePopup1();
      //  controller.updateWebinarecord();
  

    }
    static Testmethod void CaseOne2() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        IRS_Mileage_Rate__c mileageRateObj = new IRS_Mileage_Rate__c();
        mileageRateObj.IRS_Rate__c = 12.9;
        mileageRateObj.year__c = String.valueOf((System.today().year()));
        insert mileageRateObj;
        
        IRS_Mileage_Rate__c mileageRateObj1 = new IRS_Mileage_Rate__c();
        mileageRateObj1.IRS_Rate__c = 12.9;
        mileageRateObj1.year__c = String.valueOf((System.today().year()-1));
        insert mileageRateObj1;

        Account accs = new Account();
        accs.Name = 'test';
        accs.Triplog_API__c = 'test1';
        accs.isUsingTriplog__c = true;
        accs.Motor_Vehicle_Record_Check_Document__c = true;
        insert accs;

        Contact con1 = new Contact();
        con1.LastName = 'testsdfsdfs';
        con1.Triplog_UserID__c = 'test';
        con1.Deactivated_Date__c =  system.now();
        con1.isCommunityUser__c = true;
        con1.External_Email__c = 'test.patel143478@gmail.com';
        con1.IsDeactivated__c = false;
        con1.AccountId = accs.Id;
        con1.Role__c = 'Admin';
       
        insert con1;

        Contact con = new Contact();
        con.LastName = 'test';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  system.now();
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel1478@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = accs.Id;
        con.Role__c = 'Driver';
        con.compliancestatus__c = 'Yes';
        insert con;

        Attachment att = new Attachment();
        att.parentID = con.Id;
        att.name = 'test';
        att.body = blob.valueOf('Test');
        insert att;

        /*Attendee__c obj_Attendee = new Attendee__c();
        obj_Attendee.Contact__c = con.id;
        obj_Attendee.Email__c =  con.External_Email__c;
        obj_Attendee.First_Name__c = con.FirstName;
        obj_Attendee.Last_Name__c = con.LastName;
        obj_Attendee.Registrant_key__c = '1234e6';
        obj_Attendee.Registration_date__c = System.today();
        obj_Attendee.Status__c = 'Driver Scheduled Meeting';
        obj_Attendee.Join_Url__c = ''; 
        insert obj_Attendee;*/

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        //er.isDriver = true;
        er.Name = 'test';
        er.Contact_Id__c = con.Id;
        er.Approved_Date__c = system.Today();
        er.month__c = '03-2018';
        er.Name = con.lastname+':system.now()';
        er.Status__c = 'Approved';
        er.Fuel_Price__c = 1; 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;

        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = con.Id;
        er1.Name = 'test';
        er1.month__c = '04-2018';
        er1.Name = con.lastname+':04-2018';
        er1.Status__c = 'Approved';
        er1.Approved_Date__c = system.Today();
        er1.Fuel_Price__c = 1; 
        er1.MPG__c = 10.00;
        er1.Maintenance_and_Tires__c = 24;
        er1.MPG__c = 10;
        er1.Maintenance_and_Tires__c = 10;
        er1.Fixed_Amount__c = 10.10;
        er1.Triplog_Status__c = 'U';
        insert er1;

        Employee_Reimbursement__c er2 = new Employee_Reimbursement__c();
        er2.Contact_Id__c = con.Id;
        er2.Name = 'test';
        er2.month__c = '12-2017';
        er2.Approved_Date__c = system.Today();
        er2.Name = con.lastname+':8-2018';
        er2.Status__c = 'Approved';
        er2.Fuel_Price__c = 1; 
        er2.MPG__c = 10.00;
        er2.Maintenance_and_Tires__c = 24;
        er2.MPG__c = 10;
        er2.Maintenance_and_Tires__c = 10;
        er2.Fixed_Amount__c = 10.10;
        er2.Triplog_Status__c = 'U';
        insert er2;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        emp.Mileage__c = 10000;
        insert emp;

        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp1.Name = 'Test Mileage Record';
        emp1.EmployeeReimbursement__c = er1.id;
        emp1.Mileage__c = 10000;
        insert emp1;

        Employee_Mileage__c emp2 = new Employee_Mileage__c();
        emp2.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp2.Name = 'Test Mileage Record';
        emp2.EmployeeReimbursement__c = er2.id;
        emp2.Mileage__c = 10000;
        insert emp2;

        Test.StartTest();
        ApexPages.currentPage().getParameters().put('manid', String.valueOf(con1.Id));
        ApexPages.currentPage().getParameters().put('drid', String.valueOf(con.Id));
        adminstatuscontroller controller = new adminstatuscontroller();
        controller.driver = con;
        controller.compliancestatus();
        controller.isDriver = true;
        controller.isManager = true;
        controller.isSuperManager = true;
        controller.obj_reciptsize  = 10;
        controller.accesstoken = 'test';
        controller.obj_category = 'Driver Meeting';
        controller.currentdate = system.today();
        controller.compliancestatus();
       // controller.updatestatus();
        controller.obj_category = 'Signed Packet';
       // controller.updatestatus();
        controller.obj_category = 'Driver Packet';
       // controller.updatestatus();
        controller.showPopup();
        controller.showPopup1();
        controller.closePopup();
        controller.closePopup1();
      //  controller.updateWebinarecord();
  

    }



    private static String getLastMonthValue() {
        String tempDate = date.today().Month() + '-' + date.today().Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }
        return lastMonth;
    }
}