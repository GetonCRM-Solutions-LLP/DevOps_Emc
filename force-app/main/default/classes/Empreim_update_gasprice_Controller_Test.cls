@isTest
public class Empreim_update_gasprice_Controller_Test
{

     public static testmethod void Empreim_update_gasprice_Controller_Testmethod1()
    {
        Batch_Configuration__c  obj_Batch_Configuration = new Batch_Configuration__c();
        obj_Batch_Configuration.Name ='test';
        obj_Batch_Configuration.Emp_reim_update_gasprice_for_Contact__c = true;
        insert obj_Batch_Configuration;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        list<account> acclist = new  list<account>();
        for(integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        Insert acclist;
        
        list<contact> conlist = new  list<contact>();
        
        
        conlist.add(new  contact(FirstName='FirstName201',lastName = 'testManager201', accountid = acclist[0].id, External_Email__c = 'test_Managr101@test99.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150,isCommunityUser__c =true,Deactivated_Date__c =null, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver', Monthly_Mileage_Limit__c = 100));
       // conlist.add(new  contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acclist[0].id, External_Email__c = 'test_Admin1@test089.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Monthly_Mileage_Limit__c = 100));
        Insert conlist;
        
        
        list<Gas_Prices__c> gaslist = new  list<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) 
        {
            gaslist.add(new  Gas_Prices__c(City__c = 'Delhi' + i, Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 't' + i));
        }
        Insert gaslist;
        
         Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = conlist[0].Id;
        
        er.month__c = getLastMonthValue(-1);
        er.Name = conlist[0].lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
      //  er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        
        PageReference pageRef = Page.updatefuelsinreimbersments;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(er.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(er);
        Empreim_update_gasprice_Controller obj_Account_update_gasprice_Controller = new Empreim_update_gasprice_Controller(sc);
        
        obj_Account_update_gasprice_Controller.updategasprice();
        obj_Account_update_gasprice_Controller.backtoAccount();
       // System.Assertequals();
    }
     public static testmethod void Empreim_update_gasprice_Controller_Testmethod2()
    {
    Batch_Configuration__c  obj_Batch_Configuration = new Batch_Configuration__c();
        obj_Batch_Configuration.Name ='test';
        obj_Batch_Configuration.Emp_reim_update_gasprice_for_Contact__c = true;
        insert obj_Batch_Configuration;
    
    TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
    
        list<account> acclist = new  list<account>();
        for(integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        Insert acclist;
        
        list<contact> conlist = new  list<contact>();
        
        
        conlist.add(new  contact(FirstName='FirstName201',lastName = 'testManager201', accountid = acclist[0].id, External_Email__c = 'test_Managr101@test99.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150,isCommunityUser__c =true, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver', Monthly_Mileage_Limit__c = 100));
       // conlist.add(new  contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acclist[0].id, External_Email__c = 'test_Admin1@test089.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Monthly_Mileage_Limit__c = 100));
        Insert conlist;
        
        
        list<Gas_Prices__c> gaslist = new  list<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) 
        {
            gaslist.add(new  Gas_Prices__c(City__c = 'Delhi' + i, Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 't' + i));
        }
        Insert gaslist;
        
         Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = conlist[0].Id;
        
        er.month__c = getLastMonthValue(-1);
        er.Name = conlist[0].lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        // er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
      //  er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        
         PageReference pageRef = Page.updatefuelsinreimbersments;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(er.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(er);
        Empreim_update_gasprice_Controller obj_Account_update_gasprice_Controller = new Empreim_update_gasprice_Controller(sc);
        
        obj_Account_update_gasprice_Controller.updategasprice();
        obj_Account_update_gasprice_Controller.backtoAccount();
         // System.Assertequals();
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