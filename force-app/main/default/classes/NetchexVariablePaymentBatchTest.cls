@isTest
public with sharing class NetchexVariablePaymentBatchTest {
    public static testmethod void test() {
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        Netchex_Email__c objCustom = new Netchex_Email__c();
		objCustom.Name = 'NetchexVariablePaymentBatch';        
        objCustom.BCC_Address__c = 'test@gmail.com';
        objCustom.Send_Email_From_Code__c = true;
        insert objCustom;

        daylight_saving_time_config__c customSetting2 =  new daylight_saving_time_config__c();
        customSetting2.Name = '2020';
        customSetting2.Start_Date__c = System.today();
        customSetting2.End_Date__c = System.today() + 60;
        insert customSetting2;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;

        Account acc = new Account();
        acc.Name = 'SPBS';
        acc.Enable_Email_For_Managers__c = true;
        acc.Approval_Template_Message__c = 'test message';
        insert acc;

        Contact cont = new Contact();
        cont.LastName = 'TestdataContact';
        cont.AccountId = acc.Id;
        cont.External_Email__c = 'testd@email.com';
        cont.Fixed_Amount__c = 371.28;
        cont.MailingCity = 'Abilene';
        cont.MailingState = 'TX';
        cont.Driving_States__c = 'TX';
        cont.Time_Zone__c = 'America/Chicago';
        cont.Monthly_Mileage_Limit__c = 100.00;
        cont.Role__c = 'Driver/Admin';
        cont.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont;

        String lastMonth = Utils.fetchMonths(1, 0)[0]; 
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = cont.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = lastMonth;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = cont.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = 'Not Approved Yet';
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.TimeZone__c = 'US/Mountain';
        emp.Trip_Date__c = date.today().adddays(-1);
        insert emp;

        String startDate = '2020-01-01';
        String endDate = '2020-03-22';
        NetchexVariablePaymentBatch objBatch = new NetchexVariablePaymentBatch(system.now(),startDate,'test@gmail.com','test');
        Database.executeBatch(objBatch);
    }
}