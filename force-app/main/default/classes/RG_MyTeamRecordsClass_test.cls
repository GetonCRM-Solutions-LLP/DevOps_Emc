@isTest
public class RG_MyTeamRecordsClass_test
{
    public static testmethod void RG_MyTeamRecordsClass_Test_method1() 
    {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

         SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;

        List<account> acclist = new List<account>();
        for(Integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        insert acclist;

        List<contact> conlist = new List<contact>();
        Contact mgrInsert = new  contact(firstname='first1Name121',lastName = 'testManagerEmail011', accountid = acclist[0].id, External_Email__c = 'testManagerr11@test12.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100);
        insert mgrInsert;
        
        for(integer i = 0; i < 8; i++) {
            conlist.add(new  contact(FirstName='FirstName101'+ i,lastName = 'LastTest110' + i, Manager__c = mgrInsert.id, accountid = acclist[i].id, Manager_External_Email__c = 'testManager91'+i+'@test01' + i + '.com', External_Email__c = 'test77' + i + '@test11' + i + '.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity' + i, MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry' + i, MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType' + i, Role__c = 'Driver', Monthly_Mileage_Limit__c = 100));
        }
        conlist.add(new  contact(FirstName='FirstName201',lastName = 'testManager201', accountid = acclist[0].id, External_Email__c = 'test_Managr101@test99.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100));
        insert conlist;

        Contact co = new contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acclist[0].id, External_Email__c = 'test_Admin1@test089.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Manager__c = mgrInsert.Id,Monthly_Mileage_Limit__c = 100);
        insert co;
        conlist.add(co);
        
        List<Contact> updatecon = new List<Contact>();
        for(Contact c: conlist) {
            c.FirstName = 'Test Contact';
            c.External_Email__c = c.Id+'@xyz.com';
            c.Fixed_Amount__c = 8000;
            c.Maintenance_and_Tires__c = 3000;
            c.Vehicle1Odometer__c = 130;
            c.Vehicle2Odometer__c = 160;
            c.MailingStreet = 'Sector-11';
            c.MailingCity = 'Ahmedabad';
            c.MailingState = 'gj';
            c.MailingPostalCode = '110086';
            c.MailingCountry = 'India';
            c.MPG__c = 15;
            c.compliancestatus__c = 'Yes';
            c.Vehicle_Type__c = 'TestVechleTypett';
            updatecon.add(c);
        }
        Update updatecon;
        
        List<Id> portaluserId = new List<Id>();
        for(Contact c: conlist) {
            portaluserId.add(c.id);
        }
        List<User> u = [SELECT Id, 
                            UserName, 
                            Profile.Name, 
                            ContactId,
                            Contact.AccountId
                            FROM User
                            WHERE Contact.id in: portaluserId];
        
        List<Employee_Reimbursement__c> empReimbList = new List<Employee_Reimbursement__c>();
        String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        String lastmonth = temp1.left(2);
        if(lastmonth.contains('-')) {
            lastmonth = '0' + temp1;
        } else {
            lastmonth = temp1;
        }
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'ManagerReimbursement', Contact_Id__c = conlist[8].id, Month__c = lastmonth,Status__c = 'Pending',Approved_Date__c= null));
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = conlist[0].id, Month__c = lastmonth));
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = mgrInsert.id, Month__c = lastmonth));
        insert empReimbList;
        
        List<Employee_Mileage__c> empMileage = new List<Employee_Mileage__c>();
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToIndore', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-9), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Indore', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToHyderabad', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-8), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Hyderabad', Mileage__c = 10, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToBangalore', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-7), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Bangalore', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToPune', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-6), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Pune', Mileage__c = 20, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToBhopal', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-5), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Bhopal', Mileage__c = 50, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToGurgao', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-4), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Gurgao', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToJaipur', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-3), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Jaipur', Mileage__c = 80, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToRohtak', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-2), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Rohtak', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToRohtak', Contact_Email_Id__c = 'testManagerr11@test.com', Trip_Date__c = Date.today().addDays(-2), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Rohtak', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[2].id));
        insert empMileage;

        /*List<Gas_Prices__c> gaslist = new List<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) {
            gaslist.add(new  Gas_Prices__c(City__c = 'ahmedabad', Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 'gj'));
        }
        insert gaslist;*/
        Gas_Prices__c gas = new  Gas_Prices__c(City__c = 'ahmedabad', Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-1), State__c = 'gj');
        insert gas;

        Test.StartTest();
        PageReference myVfPage = Page.RG_DashboardAdmin1;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('supid',co.Id);
        RG_MyTeamRecordsClass obj_RG_MyTeamRecordsClass = new RG_MyTeamRecordsClass();
        obj_RG_MyTeamRecordsClass.UpdateRecord();
        obj_RG_MyTeamRecordsClass.pageredirect();
        obj_RG_MyTeamRecordsClass.backMethod();
        Test.StopTest();   
    }
    public static testmethod void RG_MyTeamRecordsClass_Test_method2() 
    {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

         SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        List<account> acclist = new List<account>();
        for(Integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        insert acclist;

        /*List<Gas_Prices__c> gaslist = new List<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) {
            gaslist.add(new  Gas_Prices__c(City__c = 'ahmedabad', Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 'gj'));
        }*/
        Gas_Prices__c gas = new  Gas_Prices__c(City__c = 'ahmedabad', Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-1), State__c = 'gj');
        insert gas;

        List<contact> conlist = new List<contact>();
        Contact mgrInsert = new  contact(firstname='first1Name121',lastName = 'testManagerEmail011', accountid = acclist[0].id, External_Email__c = 'testManagerr11@test12.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100);
        insert mgrInsert;
        
        for(integer i = 0; i < 8; i++) {
            conlist.add(new  contact(FirstName='FirstName101'+ i,lastName = 'LastTest110' + i, Manager__c = mgrInsert.id, accountid = acclist[i].id, Manager_External_Email__c = 'testManager91'+i+'@test01' + i + '.com', External_Email__c = 'test77' + i + '@test11' + i + '.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity' + i, MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry' + i, MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType' + i, Role__c = 'Driver', Monthly_Mileage_Limit__c = 100));
        }
        conlist.add(new  contact(FirstName='FirstName201',lastName = 'testManager201', accountid = acclist[0].id, External_Email__c = 'test_Managr101@test99.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100));
        insert conlist;

        Contact conAdmin = new contact(FirstName='FirstName30199',showTeamRecord__c = true, lastName = 'testAdmin30199', accountid = acclist[0].id, External_Email__c = 'test_Admin1@test08999.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Manager__c = mgrInsert.Id, Monthly_Mileage_Limit__c = 100);
        insert conAdmin;
        conlist.add(conAdmin);

        Contact dri = new  contact(FirstName='FirstName10101', Deactivated_Date__c = system.today(), showTeamRecord__c = true, lastName = 'LastTest11001' , Manager__c = conAdmin.id, accountid = acclist[0].id, External_Email__c = 'test770199@test110199.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'ahmedabad', MailingState = 'gj', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver', Monthly_Mileage_Limit__c = 100);
        insert dri;
        conlist.add(dri);
        
        List<Contact> updatecon = new List<Contact>();
        for(Contact c: conlist) {
            c.FirstName = 'Test Contact';
            c.External_Email__c = c.Id+'@xyz.com';
            c.Fixed_Amount__c = 8000;
            c.Maintenance_and_Tires__c = 3000;
            c.Vehicle1Odometer__c = 130;
            c.Vehicle2Odometer__c = 160;
            c.Deactivated_Date__c = null;
            c.MailingStreet = 'Sector-11';
            c.MailingCity = 'Ahmedabad';
            c.MailingState = 'gj';
            c.MailingPostalCode = '110086';
            c.MailingCountry = 'India';
            c.MPG__c = 15;
            c.compliancestatus__c = 'Yes';
            c.Vehicle_Type__c = 'TestVechleTypett';
            updatecon.add(c);
        }
        Update updatecon;
        
        List<Id> portaluserId = new List<Id>();
        for(Contact c: conlist) {
            portaluserId.add(c.id);
        }
        List<User> u = [SELECT Id, 
                            UserName, 
                            Profile.Name, 
                            ContactId,
                            Contact.AccountId
                            FROM User
                            WHERE Contact.id in: portaluserId];
        
        List<Employee_Reimbursement__c> empReimbList = new List<Employee_Reimbursement__c>();
        String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        String lastmonth = temp1.left(2);
        if(lastmonth.contains('-')) {
            lastmonth = '0' + temp1;
        } else {
            lastmonth = temp1;
        }
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'ManagerReimbursement', Contact_Id__c = conlist[8].id, Month__c = lastmonth,Status__c = 'Pending',Approved_Date__c= null));
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = conlist[0].id, Month__c = lastmonth));
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = dri.id, Month__c = lastmonth));
        insert empReimbList;
        
        List<Employee_Mileage__c> empMileage = new List<Employee_Mileage__c>();
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToIndore', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-9), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Indore', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToHyderabad', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-8), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Hyderabad', Mileage__c = 10, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToBangalore', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-7), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Bangalore', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToPune', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-6), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Pune', Mileage__c = 20, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToBhopal', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-5), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Bhopal', Mileage__c = 50, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToGurgao', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-4), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Gurgao', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToJaipur', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-3), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Jaipur', Mileage__c = 80, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToRohtak', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-2), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Rohtak', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToRohtak', Contact_Email_Id__c = 'testManagerr11@test.com', Trip_Date__c = Date.today().addDays(-2), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Rohtak', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[2].id));
        insert empMileage;

        Test.StartTest();
        PageReference myVfPage = Page.RG_DashboardAdmin1;
        Test.setCurrentPage(myVfPage);
        //ApexPages.currentPage().getParameters().put('man',mgrInsert.Id);
        ApexPages.currentPage().getParameters().put('dr',dri.Id);
        RG_MyTeamRecordsClass obj_RG_MyTeamRecordsClass = new RG_MyTeamRecordsClass();
        obj_RG_MyTeamRecordsClass.UpdateRecord();
        obj_RG_MyTeamRecordsClass.pageredirect();
        obj_RG_MyTeamRecordsClass.backMethod();
        Test.StopTest();
    }
}