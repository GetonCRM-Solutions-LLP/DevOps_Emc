@isTest
public class Account_update_gasprice_Controller_Test
{

     public static testmethod void Account_update_gasprice_Controller_Testmethod1()
    {
        Batch_Configuration__c batchConfig = new Batch_Configuration__c(); 
        batchConfig.Name='Test';
        batchConfig.Update_Reim_fuel_price_for_Account__c = true;
        insert batchConfig;
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        list<account> acclist = new  list<account>();
        for(integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        Insert acclist;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;

        Vehicle_URL_Mapping__c veh1 = new Vehicle_URL_Mapping__c();
        veh1.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/Honda-Civic.png';
        veh1.vehicle__c = 'Toyota Camry';
        veh1.Year__c = '2017';
        insert veh1;

        list<contact> conlist = new  list<contact>();
        
        
        conlist.add(new  contact(FirstName='FirstName201',
                                lastName = 'testManager201', 
                                accountid = acclist[0].id, 
                                External_Email__c = 'test_Managr101@test99.com', 
                                Fixed_Amount__c = 5000, 
                                Maintenance_and_Tires__c = 2000, 
                                Vehicle1Odometer__c = 120, 
                                Vehicle2Odometer__c = 150,
                                isCommunityUser__c =true,
                                Activation_Date__c = System.today(), 
                                MailingStreet = 'testMailingCity', 
                                MailingCity = 'testCity',
                                MailingState = 'NY', 
                                MailingPostalCode = '110085', 
                                MailingCountry = 'TestCountry', 
                                MPG__c = 12,
                                compliancestatus__c = 'Yes', 
                                Vehicle_Type__c = '2019 Full-Size Vehicle', 
                                Role__c = 'Driver', 
                                Monthly_Mileage_Limit__c = 100
                            ));
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
        er.Fuel_Price__c = null;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er.Fuel_Price__c = 1;
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
        
        PageReference pageRef = Page.updatefuelprice;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(acclist[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acclist[0]);
        Account_update_gasprice_Controller obj_Account_update_gasprice_Controller = new Account_update_gasprice_Controller(sc);
        
        obj_Account_update_gasprice_Controller.updategasprice();
        obj_Account_update_gasprice_Controller.backtoAccount();
       // System.Assertequals();
    }
     public static testmethod void Account_update_gasprice_Controller_Testmethod2()
    {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Batch_Configuration__c batchConfig = new Batch_Configuration__c(); 
        batchConfig.Name='Test';
        batchConfig.Update_Reim_fuel_price_for_Account__c = true;
        insert batchConfig;
        
        list<account> acclist = new  list<account>();
        for(integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        Insert acclist;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;
        
        list<contact> conlist = new  list<contact>();
     

        conlist.add(new  contact(FirstName='FirstName201',
                                lastName = 'testManager201', 
                                accountid = acclist[0].id, 
                                External_Email__c = 'test_Managr101@test99.com', 
                                Fixed_Amount__c = 5000, 
                                Maintenance_and_Tires__c = 2000, 
                                Vehicle1Odometer__c = 120, 
                                Vehicle2Odometer__c = 150,
                                isCommunityUser__c =true,
                                Activation_Date__c = System.today(),
                                MailingStreet = 'testMailingCity', 
                                MailingCity = 'testCity',
                                MailingState = 'NY', 
                                MailingPostalCode = '110085', 
                                MailingCountry = 'TestCountry', 
                                MPG__c = 12,
                                compliancestatus__c = 'Yes', 
                                Vehicle_Type__c = '2019 Full-Size Vehicle', 
                                Role__c = 'Driver/Manager', 
                                Monthly_Mileage_Limit__c = 100
                            ));
       // conlist.add(new  contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acclist[0].id, External_Email__c = 'test_Admin1@test089.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Monthly_Mileage_Limit__c = 100));
        Insert conlist;
        
        
        list<Gas_Prices__c> gaslist = new  list<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) 
        {
            gaslist.add(new  Gas_Prices__c(City__c = 'Delhi' + i, Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 't' + i));
        }
        insert gaslist;
        
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
        
        PageReference pageRef = Page.updatefuelprice;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(acclist[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acclist[0]);
        Account_update_gasprice_Controller obj_Account_update_gasprice_Controller = new Account_update_gasprice_Controller(sc);
        
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