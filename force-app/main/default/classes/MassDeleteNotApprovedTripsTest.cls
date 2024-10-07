@isTest
public class MassDeleteNotApprovedTripsTest {
 public static testmethod void test1(){
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
     customSetting.ContactTriCommunityReimCreate__c  = false;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        daylight_saving_time_config__c customSetting2 =  new daylight_saving_time_config__c();
        customSetting2.Name = '2021';
        customSetting2.Start_Date__c = System.today();
        customSetting2.End_Date__c = System.today() + 7;
        insert customSetting2;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
     
         IRS_Mileage_Rate__c irs = new IRS_Mileage_Rate__c();
         irs.year__c = '2021';
         irs.IRS_Rate__c = 0.85;
         insert irs;
        
        Account acc = new Account();  
        acc.Name = 'Test Contacgt';
        acc.Vehicle_Types__c = veh.name;
        //acc.Triplog_API__c = '8e0ac6d1e82a439faaef1fdf0dc707b1';
        Acc.Triplog_Status__c = 'U';
        insert Acc;
        
        Contact contact = new Contact();
     
        contact.lastname = 'Test Contact';
        contact.AccountId = Acc.Id; //System.Label.PLMarketing;
        contact.Vehicle_Type__c = '2019 Mileage Rate';
        contact.External_Email__c = 'minkesh.patel1478@gmail.com';
     	contact.compliancestatus__c = 'Yes';
        contact.Time_Zone__c = 'America/Chicago';
        contact.MailingCity = 'Abilene';
        contact.MailingState = 'TX';
        contact.Driving_States__c = 'TX';
        contact.Role__c = 'Driver';
        contact.isCommunityUser__c = true;
     	contact.Fixed_Amount__c = 201.12;
        insert contact;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        er.month__c = '07-2021';
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
      	er.IRS_Mileage_Rate__c = irs.Id;
        insert er;
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = contact.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = 'Not Approved Yet';
     	emp.Approved_Date__c = null;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.Trip_Date__c = system.today();
        insert emp;

        Test.startTest();
     	MassDeleteNotApprovedTrips.DeleteUnApprovedTrips(Acc.Id,String.valueOf(system.today()),String.valueOf(system.today()));
        Test.stopTest();
}

}