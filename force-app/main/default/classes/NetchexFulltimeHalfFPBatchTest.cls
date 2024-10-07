@isTest
public class NetchexFulltimeHalfFPBatchTest {
	public static testmethod void test() {
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
		
        Netchex_Email__c objCustom = new Netchex_Email__c();
		objCustom.Name = 'NetchexFulltimeHalfFPBatch';        
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
        cont.Driver_Type__c = 'Driver - Salary';
        cont.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont;
		
        Contact cont1 = new Contact();
        cont1.LastName = 'Testdat1aContact';
        cont1.AccountId = acc.Id;
        cont1.External_Email__c = 'tes1td@email.com';
        cont1.Fixed_Amount__c = 371.28;
        cont1.MailingCity = 'Abilene';
        cont1.MailingState = 'TX';
        cont1.Driving_States__c = 'TX';
        cont1.Time_Zone__c = 'America/Chicago';
        cont1.Monthly_Mileage_Limit__c = 100.00;
        cont1.Role__c = 'Driver/Admin';
        cont1.Driver_Type__c = 'Driver - Full Time';
        cont1.Vehicle_Type__c = '2019 Full-Size Vehicle';
        insert cont1;
        
        String lastMonth = Utils.fetchMonths(1, 0)[0]; 
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = cont.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = lastMonth;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;
		
        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = cont1.Id;
        er1.Name = 'Reimbersment Test';
        er1.Month__c = lastMonth;
        er1.Status__c = 'Pending';
        er1.Fuel_Price__c = 10.00;
        insert er1;
        
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
        NetchexFulltimeHalfFPBatch objBatch = new NetchexFulltimeHalfFPBatch(system.now(),startDate,endDate,'test@gmail.com','test');
        Database.executeBatch(objBatch);
    }
}