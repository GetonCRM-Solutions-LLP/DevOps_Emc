@isTest
public with sharing class ManageGasPriceControllerTest {
    public static testmethod void test1(){
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'TestContact';
        con.AccountId = acc.Id;
        con.External_Email__c = 'test@email.com';
        con.Fixed_Amount__c = 371.28;
        con.MailingCity = 'Abilene';
        con.MailingState = 'TX';
        con.Time_Zone__c = 'US/Mountain' ;
        con.Driving_States__c = 'TX';
        con.Time_Zone__c = 'America/Chicago';
        con.Role__c = 'Driver';
        con.Vehicle_Type__c  = '2019 Full-Size Sedan';
        con.Monthly_Mileage_Limit__c = 100.00;
        insert con;
        
        Gas_Prices__c gasPriceObj = new Gas_Prices__c();
        gasPriceObj.City__c = 'Abilene';
        gasPriceObj.Fuel_Price__c = 65;
        gasPriceObj.Month_Year__c = System.today().tostartofmonth();
        gasPriceObj.State__c = 'TX';
        insert gasPriceObj;

        Gas_Prices__c gasPriceObj1 = new Gas_Prices__c();
        gasPriceObj1.City__c = 'Townsend';
        gasPriceObj1.Fuel_Price__c = 6;
        gasPriceObj1.Month_Year__c = System.today().tostartofmonth();
        gasPriceObj1.State__c = 'DE';
        insert gasPriceObj1;

        list<Gas_Price_LineItem__c> gasLinelist = new  list<Gas_Price_LineItem__c>();
        Gas_Price_LineItem__c objLineItem = new Gas_Price_LineItem__c();
        objLineItem.Gas_Price__c = gasPriceObj.Id;
        objLineItem.City__c = 'Abilene';
        objLineItem.Date__c = System.today();
        objLineItem.Fuel_Price__c = 1.02;
        gasLinelist.add(objLineItem);
        
        Gas_Price_LineItem__c objLineItem1 = new Gas_Price_LineItem__c();
        objLineItem1.Gas_Price__c = gasPriceObj1.Id;
        objLineItem1.City__c = 'Townsend';
        objLineItem1.Date__c = System.today()-7;
        objLineItem1.Fuel_Price__c = 1.03;
        gasLinelist.add(objLineItem1);

        String items = Json.serialize(gasLinelist);
        
        ManageGasPriceController.searchInfo objSearch = new ManageGasPriceController.searchInfo();
        objSearch.selectedMonth = '06-2020';
        objSearch.selectedState = 'TX';

        String info = JSON.serialize(objSearch);
        ManageGasPriceController.FormatDate(System.today());
        ManageGasPriceController objManage = new ManageGasPriceController();
        objManage.GetMailingStates();
        objManage.GetGasPriceOptions();
        ManageGasPriceController.SaveAllGasPrice(items,info);
        ManageGasPriceController.GetWeeksOfMonth(info);
    }
}