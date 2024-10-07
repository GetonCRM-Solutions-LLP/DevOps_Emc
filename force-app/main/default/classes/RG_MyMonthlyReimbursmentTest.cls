@isTest
public class RG_MyMonthlyReimbursmentTest {
     public static testmethod void RG_MyMonthlyReimbursmentTestMethod() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account acc = new  Account();
        acc.name = 'Delta';
        acc.Motor_Vehicle_Record_Check_Document__c = true;
        insert acc;

        List<Contact> conList = new List<Contact>();
        Contact mgrInsert = new  contact(firstname='first1Name121', 
                                            lastName = 'testManagerEmail011', accountid = acc.id, 
                                            External_Email__c = 'testManagerr11@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = null, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = null, compliancestatus__c = 'Yes', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver/Manager', 
                                            Monthly_Mileage_Limit__c = 100, Odometer_Editable__c = true);
        insert mgrInsert;
        conList.add(mgrInsert);

        AuditTrail__c audit = new AuditTrail__c();
        audit.Contact__c = mgrInsert.id;
        audit.Field__c = 'auditField';
        audit.Modifiedby__c = 'test';
        audit.NewValue__c = 'newvalue';
        audit.OldValue__c = 'oldvalue';
        audit.Timestamp__c = System.now();
        insert audit;
        
        Contact manCon = new  contact(firstname='first1Name1212', 
                                            lastName = 'testManagerEmail0112', accountid = acc.id, 
                                            External_Email__c = 'testManagerr121@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = 12, compliancestatus__c = 'Yes', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', 
                                            Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true, Odometer_Editable__c = true);
        insert manCon;
        conList.add(manCon);

        Contact drCon = new  contact(FirstName='FirstName10167', lastName = 'LastTest11067', 
                                        Manager__c = manCon.id, accountid = acc.id, 
                                        Manager_External_Email__c = 'testManager9167@test01.com', 
                                        External_Email__c = 'testManager9167@test01.com', 
                                        Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, 
                                        Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, 
                                        MailingStreet = 'testMailingCity', MailingCity = 'testCity1', 
                                        MailingState = 'CA', MailingPostalCode = '110085', 
                                        MailingCountry = 'TestCountry', MPG__c = 12, 
                                        Compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechle1Type', 
                                        Role__c = 'Driver', Odometer_Editable__c = true, Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true);
        insert drCon;
        conList.add(drCon);
        Employee_Reimbursement__c emp = new Employee_Reimbursement__c();
        emp.Month__c = '12-2018';
        emp.Contact_Id__c = drCon.Id;
        emp.Name = 'test';
        //emp.Total_Mileage__c = 2;
        //emp.Total_Monthly_Reimbursement__c = '2';
        insert emp;
        List<Id> portaluserId = new List<Id>();
        for(Contact c: conlist) {
            portaluserId.add(c.id);
        }
        
        List<User> u = [SELECT
                            Id, 
                            UserName, 
                            Profile.Name, 
                            ContactId,
                            Contact.AccountId
                            FROM User 
                            WHERE ContactId in: portaluserId];

        String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        String lastmonth = temp1.left(2);
        if(lastmonth.contains('-')) {
            lastmonth = '0' + temp1;
        } else {
            lastmonth = temp1;
        }
        Employee_Reimbursement__c empReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = manCon.id, Month__c = lastmonth);   
        insert empReimb;

        Employee_Mileage__c empMileage = new Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'abctest@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = empReimb.id,MPG__c=12,Maintenance_and_Tires__c=12,Fuel_price__c=12);
        insert empMileage;

        Employee_Reimbursement__c eReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement67', Contact_Id__c = drCon.id, Month__c = lastmonth);   
        insert eReimb;

        Employee_Mileage__c eMileage = new Employee_Mileage__c(Name = 'DelToMumbai67', Contact_Email_Id__c = 'abctest12@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = eReimb.id,MPG__c=12,Maintenance_and_Tires__c=12,Fuel_price__c=12);
        insert eMileage;

        User thisUser = [select id, profile.name,contactid from user where profile.name =: 'Customer Community Login User - Driver' and IsActive =: true and contactId =: drCon.id limit 1];
        System.runAs(thisUser) {
            PageReference pageRef = Page.RG_MonthlyReimbursementSummary;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',mgrInsert.Id);
            ApexPages.currentPage().getParameters().put('man',manCon.Id);
            ApexPages.currentPage().getParameters().put('dr',drCon.Id);
            ApexPages.currentPage().getParameters().put('vehicleOneValue','200');
            ApexPages.currentPage().getParameters().put('vehicleTwoValue','200');
            RG_MyMonthlyReimbursment myMonthlyReim = new  RG_MyMonthlyReimbursment();
            myMonthlyReim.obj_status = 'test';
            myMonthlyReim.obj_category = 'test1';
            myMonthlyReim.totalmileages = 10.10;
            myMonthlyReim.drid = 'tesing';
            //RG_MyMonthlyReimbursment.updateWebinarecord = new RG_MyMonthlyReimbursment.updateWebinarecord();
           /* myMonthlyReim.imDriver = true;*/
           // RG_MyMonthlyReimbursment.MileageWrapper obj = new RG_MyMonthlyReimbursment.MileageWrapper();
            myMonthlyReim.imMan = true;
            /*myMonthlyReim.imManDr = true;
            myMonthlyReim.isManagerDriver = true;
            myMonthlyReim.isSuperManagerDriver = true;
            myMonthlyReim.isDriver = true;
            myMonthlyReim.isSuperManager = true;
            myMonthlyReim.isManager = true;*/
            myMonthlyReim.dueDate = System.today();
          //  myMonthlyReim.isMVRCheck = true;
          //  myMonthlyReim.obj_status = 'test';
          //  myMonthlyReim.accesstoken = 'test';
            myMonthlyReim.manid = manCon.id;
            myMonthlyReim.pname = 'Customer Community Login User - Manager';
        //    myMonthlyReim.obj_driver_meeting_status = 'test';
            myMonthlyReim.isEditable = true;
            myMonthlyReim.sendConfirmationEmail();
            myMonthlyReim.updateByMonth();
            myMonthlyReim.closePopup();
            myMonthlyReim.closePopup1();
            myMonthlyReim.refreshPage();
           // myMonthlyReim.updatestatus();
            myMonthlyReim.savecontact();
            //myMonthlyReim.userContactSave();
            
            myMonthlyReim.showPopup();
            myMonthlyReim.showPopup1();
            myMonthlyReim.savePDF();
            myMonthlyReim.backMethod(); 
            myMonthlyReim.vehicleOdometer(); 
           Attachment obj= myMonthlyReim.myattachment;  
        }
    }
    public static testmethod void RG_MyMonthlyReimbursmentTestMethod1() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account acc = new  Account();
        acc.name = 'test';
        acc.Motor_Vehicle_Record_Check_Document__c = true;
        insert acc;
        List<Contact> conList = new List<Contact>();
        Contact mgrInsert = new  contact(firstname='first1Name121', 
                                            lastName = 'testManagerEmail011', accountid = acc.id, 
                                            External_Email__c = 'testManagerr11@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = 12, compliancestatus__c = 'Yes', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver/Manager', 
                                            Monthly_Mileage_Limit__c = 100, Odometer_Editable__c = true);
        insert mgrInsert;
        conList.add(mgrInsert);

        Contact manCon = new  contact(firstname='first1Name1212', 
                                            lastName = 'testManagerEmail0112', accountid = acc.id, 
                                            External_Email__c = 'testManagerr121@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = 12, compliancestatus__c = 'Yes', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', 
                                            Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true, Odometer_Editable__c = true);
        insert manCon;
        conList.add(manCon);

        Contact drCon = new  contact(FirstName='FirstName10167', lastName = 'LastTest11067', 
                                        Manager__c = manCon.id, accountid = acc.id, 
                                        Manager_External_Email__c = 'testManager9167@test01.com', 
                                        External_Email__c = 'testManager9167@test01.com', 
                                        Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, 
                                        Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, 
                                        MailingStreet = 'testMailingCity', MailingCity = 'testCity1', 
                                        MailingState = 'CA', MailingPostalCode = '110085', 
                                        MailingCountry = 'TestCountry', MPG__c = 12, 
                                        Compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechle1Type', 
                                        Role__c = 'Driver', Odometer_Editable__c = true, Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true);
        insert drCon;
        conList.add(drCon);

        List<Id> portaluserId = new List<Id>();
        for(Contact c: conlist) {
            portaluserId.add(c.id);
        }
        
        List<User> u = [SELECT
                            Id, 
                            UserName, 
                            Profile.Name, 
                            ContactId,
                            Contact.AccountId
                            FROM User 
                            WHERE ContactId in: portaluserId];

        String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        String lastmonth = temp1.left(12);
        if(lastmonth.contains('-')) {
            lastmonth = '0' + temp1;
        } else {
            lastmonth = temp1;
        }
        Employee_Reimbursement__c empReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = manCon.id, Month__c = lastmonth);   
        insert empReimb;

        Employee_Mileage__c empMileage = new Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'abctest@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = empReimb.id);
        insert empMileage;

        Employee_Reimbursement__c eReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement67', Contact_Id__c = drCon.id, Month__c = lastmonth);   
        insert eReimb;

        Employee_Mileage__c eMileage = new Employee_Mileage__c(Name = 'DelToMumbai67', Contact_Email_Id__c = 'abctest12@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = eReimb.id);
        insert eMileage;

        User thisUser = [select id, profile.name,contactid from user where profile.name =: 'Customer Community Login User - Driver' and IsActive =: true and contactId =: drCon.id limit 1];
        System.runAs(thisUser) {
            PageReference pageRef = Page.RG_MonthlyReimbursementSummary;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('man',manCon.Id);
            ApexPages.currentPage().getParameters().put('dr',drCon.Id);
            //ApexPages.currentPage().getParameters().put('id',drCon.Id);
            RG_MyMonthlyReimbursment myMonthlyReim = new  RG_MyMonthlyReimbursment();
            myMonthlyReim.imDriver = true;
            myMonthlyReim.imMan = true;
            myMonthlyReim.imManDr = true;
            myMonthlyReim.isManagerDriver = true;
            myMonthlyReim.isSuperManagerDriver = true;
            myMonthlyReim.isDriver = true;
            myMonthlyReim.isSuperManager = true;
            myMonthlyReim.isManager = true;
            myMonthlyReim.dueDate = System.today();
            myMonthlyReim.isMVRCheck = false;
           // myMonthlyReim.obj_status = 'test';
           // myMonthlyReim.accesstoken = 'test';
            myMonthlyReim.manid = 'test';
            myMonthlyReim.pname = 'test';
          //  myMonthlyReim.obj_driver_meeting_status = 'test';
            myMonthlyReim.isEditable = true;
            myMonthlyReim.sendConfirmationEmail();
            myMonthlyReim.updateByMonth();
            myMonthlyReim.closePopup();
            myMonthlyReim.closePopup1();
            myMonthlyReim.refreshPage();
          //  myMonthlyReim.updatestatus();
            myMonthlyReim.savecontact();
            myMonthlyReim.userContactSave();
           
            myMonthlyReim.showPopup();
            myMonthlyReim.showPopup1();
            myMonthlyReim.savePDF();
            myMonthlyReim.backMethod();    
        }
    }
    public static testmethod void RG_MyMonthlyReimbursmentTestMethod2() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account acc = new  Account();
        acc.name = 'test';
        acc.Motor_Vehicle_Record_Check_Document__c = true;
        insert acc;
        List<Contact> conList = new List<Contact>();
        Contact mgrInsert = new  contact(firstname='first1Name121', 
                                            lastName = 'testManagerEmail011', accountid = acc.id, 
                                            External_Email__c = 'testManagerr11@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = 12, compliancestatus__c = 'No – Vehicle Age    ', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver/Manager', 
                                            Monthly_Mileage_Limit__c = 100, Odometer_Editable__c = true);
        insert mgrInsert;
        conList.add(mgrInsert);

        Contact manCon = new  contact(firstname='first1Name1212', 
                                            lastName = 'testManagerEmail0112', accountid = acc.id, 
                                            External_Email__c = 'testManagerr121@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = 12, compliancestatus__c = 'No – Vehicle Age', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', 
                                            Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true, Odometer_Editable__c = true);
        insert manCon;
        conList.add(manCon);

        Contact drCon = new  contact(FirstName='FirstName10167', lastName = 'LastTest11067', 
                                        Manager__c = manCon.id, accountid = acc.id, 
                                        Manager_External_Email__c = 'testManager9167@test01.com', 
                                        External_Email__c = 'testManager9167@test01.com', 
                                        Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, 
                                        Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, 
                                        MailingStreet = 'testMailingCity', MailingCity = 'testCity1', 
                                        MailingState = 'CA', MailingPostalCode = '110085', 
                                        MailingCountry = 'TestCountry', MPG__c = 12, 
                                        Compliancestatus__c = 'No – Vehicle Age', Vehicle_Type__c = 'TestVechle1Type', 
                                        Role__c = 'Driver', Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true, Odometer_Editable__c = true);
        insert drCon;
        conList.add(drCon);

        List<Id> portaluserId = new List<Id>();
        for(Contact c: conlist) {
            portaluserId.add(c.id);
        }
        
        List<User> u = [SELECT
                            Id, 
                            UserName, 
                            Profile.Name, 
                            ContactId,
                            Contact.AccountId
                            FROM User 
                            WHERE ContactId in: portaluserId];

        String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        String lastmonth = temp1.left(2);
        if(lastmonth.contains('-')) {
            lastmonth = '0' + temp1;
        } else {
            lastmonth = temp1;
        }
        Employee_Reimbursement__c empReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = manCon.id, Month__c = lastmonth);   
        insert empReimb;

        Employee_Mileage__c empMileage = new Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'abctest@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = empReimb.id);
        insert empMileage;

        Employee_Reimbursement__c eReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement67', Contact_Id__c = drCon.id, Month__c = lastmonth);   
        insert eReimb;

        Employee_Mileage__c eMileage = new Employee_Mileage__c(Name = 'DelToMumbai67', Contact_Email_Id__c = 'abctest12@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = eReimb.id);
        insert eMileage;

        User thisUser = [select id, profile.name,contactid from user where profile.name =: 'Customer Community Login User - Driver' and IsActive =: true and contactId =: drCon.id limit 1];
        System.runAs(thisUser) {
            PageReference pageRef = Page.RG_MonthlyReimbursementSummary;
            ApexPages.currentPage().getParameters().put('man',manCon.Id);
            ApexPages.currentPage().getParameters().put('dr',drCon.Id);
            //ApexPages.currentPage().getParameters().put('id',drCon.Id);
            //ApexPages.currentPage().getParameters().put('vehicleOneValue','1');
            //ApexPages.currentPage().getParameters().put('vehicleTwoValue','2');
            Test.setCurrentPage(pageRef);
            RG_MyMonthlyReimbursment myMonthlyReim = new  RG_MyMonthlyReimbursment();
            myMonthlyReim.imDriver = true;
            myMonthlyReim.imMan = true;
            myMonthlyReim.imManDr = true;
            myMonthlyReim.isManagerDriver = true;
            myMonthlyReim.isSuperManagerDriver = true;
            myMonthlyReim.isDriver = true;
            myMonthlyReim.isSuperManager = true;
            myMonthlyReim.isManager = true;
            myMonthlyReim.dueDate = System.today();
         //   myMonthlyReim.isMVRCheck = false;
          //  myMonthlyReim.obj_status = 'test';
            myMonthlyReim.manid = 'test';
         //   myMonthlyReim.obj_driver_meeting_status = 'test';
            myMonthlyReim.isEditable = true;
            myMonthlyReim.sendConfirmationEmail();
            myMonthlyReim.updateByMonth();
            myMonthlyReim.closePopup();
            myMonthlyReim.closePopup1();
            myMonthlyReim.refreshPage();
         //   myMonthlyReim.updatestatus();
            myMonthlyReim.savecontact();
            myMonthlyReim.userContactSave();
            //myMonthlyReim.vehicleOdometer();
            myMonthlyReim.showPopup();
            myMonthlyReim.showPopup1();
            myMonthlyReim.savePDF();
            myMonthlyReim.backMethod(); 
        }
    }
    public static testmethod void RG_MyMonthlyReimbursmentTestMethod3() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account acc = new  Account();
        acc.name = 'test';
        acc.Motor_Vehicle_Record_Check_Document__c = true;
        insert acc;
        List<Contact> conList = new List<Contact>();
        Contact mgrInsert = new  contact(firstname='first1Name121', 
                                            lastName = 'testManagerEmail011', accountid = acc.id, 
                                            External_Email__c = 'testManagerr11@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = 12, compliancestatus__c = 'No – Vehicle Age    ', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver/Manager', 
                                            Monthly_Mileage_Limit__c = 100, Odometer_Editable__c = true);
        insert mgrInsert;
        conList.add(mgrInsert);

        Contact manCon = new  contact(firstname='first1Name1212', 
                                            lastName = 'testManagerEmail0112', accountid = acc.id, 
                                            External_Email__c = 'testManagerr121@test12.com', Fixed_Amount__c = 5000, 
                                            Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, 
                                            Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', 
                                            MailingCity = 'testCity', MailingState = 'CA', 
                                            MailingPostalCode = '110085', MailingCountry = 'TestCountry', 
                                            MPG__c = 12, compliancestatus__c = 'No – Vehicle Age', 
                                            Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', 
                                            Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true, Odometer_Editable__c = true);
        insert manCon;
        conList.add(manCon);

        Contact drCon = new  contact(FirstName='FirstName10167', lastName = 'LastTest11067', 
                                        Manager__c = manCon.id, accountid = acc.id, 
                                        Manager_External_Email__c = 'testManager9167@test01.com', 
                                        External_Email__c = 'testManager9167@test01.com', 
                                        Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, 
                                        Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, 
                                        MailingStreet = 'testMailingCity', MailingCity = 'testCity1', 
                                        MailingState = 'CA', MailingPostalCode = '110085', 
                                        MailingCountry = 'TestCountry', MPG__c = 12, 
                                        Compliancestatus__c = 'No – Vehicle Age', Vehicle_Type__c = 'TestVechle1Type', 
                                        Role__c = 'Driver', Monthly_Mileage_Limit__c = 100,Enable_Reports__c = true, Odometer_Editable__c = true);
        insert drCon;
        conList.add(drCon);

        List<Id> portaluserId = new List<Id>();
        for(Contact c: conlist) {
            portaluserId.add(c.id);
        }
        
        List<User> u = [SELECT
                            Id, 
                            UserName, 
                            Profile.Name, 
                            ContactId,
                            Contact.AccountId
                            FROM User 
                            WHERE ContactId in: portaluserId];

        String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        String lastmonth = temp1.left(2);
        if(lastmonth.contains('-')) {
            lastmonth = '0' + temp1;
        } else {
            lastmonth = temp1;
        }
        Employee_Reimbursement__c empReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = manCon.id, Month__c = lastmonth);   
        insert empReimb;

        Employee_Mileage__c empMileage = new Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'abctest@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = empReimb.id);
        insert empMileage;

        Employee_Reimbursement__c eReimb = new  Employee_Reimbursement__c(Name = 'DriverReimbursement67', Contact_Id__c = drCon.id, Month__c = lastmonth);   
        insert eReimb;

        Employee_Mileage__c eMileage = new Employee_Mileage__c(Name = 'DelToMumbai67', Contact_Email_Id__c = 'abctest12@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = eReimb.id);
        insert eMileage;

        User thisUser = [select id, profile.name,contactid from user where profile.name =: 'Customer Community Login User - Driver' and IsActive =: true and contactId =: drCon.id limit 1];
        System.runAs(thisUser) {
            PageReference pageRef = Page.RG_MonthlyReimbursementSummary;
            ApexPages.currentPage().getParameters().put('man',manCon.Id);
            ApexPages.currentPage().getParameters().put('dr',drCon.Id);
            //ApexPages.currentPage().getParameters().put('id',drCon.Id);
            //ApexPages.currentPage().getParameters().put('vehicleOneValue','1');
            //ApexPages.currentPage().getParameters().put('vehicleTwoValue','2');
            Test.setCurrentPage(pageRef);
            RG_MyMonthlyReimbursment myMonthlyReim = new  RG_MyMonthlyReimbursment();
            myMonthlyReim.imDriver = true;
            myMonthlyReim.imMan = true;
            myMonthlyReim.imManDr = true;
            myMonthlyReim.isManagerDriver = true;
            myMonthlyReim.isSuperManagerDriver = true;
            myMonthlyReim.isDriver = true;
            myMonthlyReim.isSuperManager = true;
            myMonthlyReim.isManager = true;
            myMonthlyReim.dueDate = System.today();
         //   myMonthlyReim.isMVRCheck = false;
          //  myMonthlyReim.obj_status = 'test';
            myMonthlyReim.manid = 'test';
         //   myMonthlyReim.obj_driver_meeting_status = 'test';
            myMonthlyReim.isEditable = true;
            myMonthlyReim.sendConfirmationEmail();
            myMonthlyReim.updateByMonth();
            myMonthlyReim.closePopup();
            myMonthlyReim.closePopup1();
            myMonthlyReim.refreshPage();
         //   myMonthlyReim.updatestatus();
            myMonthlyReim.savecontact();
            myMonthlyReim.userContactSave();
            //myMonthlyReim.vehicleOdometer();
            myMonthlyReim.showPopup();
            myMonthlyReim.showPopup1();
            myMonthlyReim.savePDF();
            myMonthlyReim.backMethod(); 
        }
    }
}