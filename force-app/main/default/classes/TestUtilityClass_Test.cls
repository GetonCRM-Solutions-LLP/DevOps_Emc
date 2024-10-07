@isTest
public with sharing class TestUtilityClass_Test {
	testmethod public static void testdata()
	{
		SendEmail__c sendemail = new SendEmail__c();
		sendemail.Name = 'Send Email For Compliance';
		sendemail.Send_email_from_code__c = true;
		insert sendemail;

		TriggerConfig__c config = new TriggerConfig__c();
		config.Name = 'Defaulttrigger';
		config.MappingGasPriceTrigger__c = true;
		insert config;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
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

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'minkesh.patel1478@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.Monthly_Mileage_Limit__c = 0;
        insert con;
        
        IRS_Mileage_Rate__c irsRate = new IRS_Mileage_Rate__c();
        irsRate.year__c = '2020';
        irsRate.IRS_Rate__c = 2.05;
        insert irsRate;

        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        empReim.Contact_Id__c = con.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 34;
        empReim.MPG__c = 45;
        empReim.Approved_Date__c = null;
        empReim.Status__c='Pending';
        empReim.Month__c = '05-2020';
        empReim.Monthly_Mileage__c = 50;
        empReim.IRS_Mileage_Rate__c = irsRate.Id;
        empReim.Maintenance_and_Tires__c =10;
        insert empReim;
        

		TestUtilityClass obj = new TestUtilityClass();
		TestUtilityClass.getTestSingleAccount();
		TestUtilityClass.getTestSingleAccount2();
		TestUtilityClass.getTestSingleContact(acc);
		TestUtilityClass.getTestSingleContact2(acc);
		TestUtilityClass.getTestSingleContact3(acc);
		TestUtilityClass.getTestSingleContact4(acc,con);
		TestUtilityClass.getTestMultipleAccount();
		TestUtilityClass.getTestMultipleContact(acc);
		TestUtilityClass.getTestBatchConfig();
		TestUtilityClass.getTestBatchSetup();
		TestUtilityClass.getTestEmployeeReimbursement(con);
		TestUtilityClass.getTestEmployeeReimbursement2(con);
		TestUtilityClass.getTestEmployeeReimbursement3(con);
		TestUtilityClass.getTestEmployeeReimbursement4(con);
		TestUtilityClass.getTestEmployeeReimbursement5(con);
		TestUtilityClass.getTestEmployeeMileage(empReim);
		TestUtilityClass.getTestEmployeeMileage2(empReim);
		TestUtilityClass.getTestEmployeeMileage3(empReim);
		TestUtilityClass.getTestGasPrices();
		TestUtilityClass.getTestMultipleEmployeeReimbursement(con);

		}	
	
}