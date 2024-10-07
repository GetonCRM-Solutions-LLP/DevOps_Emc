@isTest
public with sharing class DeActivatedAdminEmailBatch_clone_Test {
	
	testmethod public static void deactivatedemailMethod()
	{
		SendEmail__c sendemail = new SendEmail__c();
		sendemail.Name = 'Send Email For Compliance';
		sendemail.Send_email_from_code__c = true;
		insert sendemail;

		SendEmailToMe__c sendemailme = new SendEmailToMe__c();
		sendemailme.name = 'DeActivatedAdminEmailBatch_clone';
		sendemailme.Send_email_to_me__c = true;
		insert sendemailme;
		
		IRS_Mileage_Rate__c irsMileage = new IRS_Mileage_Rate__c();
		irsMileage.year__c = '2019';
		irsMileage.IRS_Rate__c = 0.545;
		insert irsMileage;

		IRS_Mileage_Rate__c irsMileage1 = new IRS_Mileage_Rate__c();
		irsMileage1.year__c = '2018';
		irsMileage1.IRS_Rate__c = 0.595;
		insert irsMileage1;

		TriggerConfig__c config = new TriggerConfig__c();
		config.Name = 'Defaulttrigger';
		config.MappingGasPriceTrigger__c = true;
		insert config;

		Account acc = TestUtilityClass.getTestSingleAccount();
		
		List<Contact> conlist = new List<Contact>();
		Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Bremen';
        con.MailingState = 'AL';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'test@gmail.com';
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c=1;
		con.Deactivated_Date__c = System.today() - 5;
		con.Last_Pay_Date__c = System.today();
		con.send_deactivation_Email__c = true;
		con.Sent_Tax_Liability_report_to_Admin__c = false;
		con.MPG__c = 10;
		con.Vehicle_Type__c = '2018';
		con.Employee_ID__c  = '1';
		con.Maintenance_and_Tires__c = 2;
		con.Fixed_Amount__c = 10;
		con.compliancestatus__c = 'Yes';
		conlist.add(con);

		Contact con2 = new Contact();
		con2.FirstName = 'Test';
		con2.LastName = 'Contact';
		con2.AccountId = acc.Id;
		con2.MailingStreet = 'Test Street';
		con2.MailingCity = 'Bremen';
		con2.MailingState = 'AL';
		con2.MailingPostalCode = '123';
		con2.MailingCountry = 'CA';
		con2.Phone = '1232434445';
		con2.External_Email__c = 'test3@gmail.com';
		con2.isCommunityUser__c = True;
		con2.Role__c = 'Driver';
		con2.Monthly_Mileage_Limit__c=1;
		con2.Deactivated_Date__c = System.today() - 130;  //Current month is April and it take december
		con2.Last_Pay_Date__c = System.today();
		con2.send_deactivation_Email__c = true;
		con2.Sent_Tax_Liability_report_to_Admin__c = false;
		con2.MPG__c = 10;
		con2.Vehicle_Type__c = '2018';
		con2.Employee_ID__c  = '1';
		con2.Maintenance_and_Tires__c = 2;
		con2.Fixed_Amount__c = 10;
		con2.compliancestatus__c = 'Yes';
		conlist.add(con2);

		Contact con3 = new Contact();
		con3.FirstName = 'Test';
		con3.LastName = 'Contact';
		con3.AccountId = acc.Id;
		con3.MailingStreet = 'Test Street';
		con3.MailingCity = 'Bremen';
		con3.MailingState = 'AL';
		con3.MailingPostalCode = '123';
		con3.MailingCountry = 'CA';
		con3.Phone = '1232434445';
		con3.External_Email__c = 'test4@gmail.com';
		con3.isCommunityUser__c = True;
		con3.Role__c = 'Driver';
		con3.Monthly_Mileage_Limit__c=1;
		con3.Deactivated_Date__c = System.today() - 130;  //Current month is April and it take december
		con3.Last_Pay_Date__c = System.today();
		con3.send_deactivation_Email__c = true;
		con3.Sent_Tax_Liability_report_to_Admin__c = false;
		con3.MPG__c = 107;
		con3.Vehicle_Type__c = '2018';
		con3.Employee_ID__c  = '1';
		con3.Maintenance_and_Tires__c = 27;
		con3.Fixed_Amount__c = 170;
		con3.compliancestatus__c = 'Yes';
		conlist.add(con3);

		Contact con4 = new Contact();
		con4.FirstName = 'Test';
		con4.LastName = 'Contact';
		con4.AccountId = acc.Id;
		con4.MailingStreet = 'Test Street';
		con4.MailingCity = 'Bremen';
		con4.MailingState = 'AL';
		con4.MailingPostalCode = '123';
		con4.MailingCountry = 'CA';
		con4.Phone = '1232434445';
		con4.External_Email__c = 'test5@gmail.com';
		con4.IsCommunityUser__c = True;
		con4.Role__c = 'Driver';
		con4.Monthly_Mileage_Limit__c=1;
		con4.Deactivated_Date__c = date.today().addmonths(-8);
		con4.Last_Pay_Date__c = System.today();
		con4.Send_deactivation_Email__c = true;
		con4.Sent_Tax_Liability_report_to_Admin__c = false;
		con4.MPG__c = 78;
		con4.Vehicle_Type__c = '2018';
		con4.Employee_ID__c  = '1';
		con4.Maintenance_and_Tires__c = 92;
		con4.Fixed_Amount__c = 56;
		con4.Compliancestatus__c = 'Yes';
		conlist.add(con4);

		Contact con5 = new Contact();
		con5.FirstName = 'Test';
		con5.LastName = 'Contact';
		con5.AccountId = acc.Id;
		con5.MailingStreet = 'Test Street';
		con5.MailingCity = 'Bremen';
		con5.MailingState = 'AL';
		con5.MailingPostalCode = '123';
		con5.MailingCountry = 'CA';
		con5.Phone = '1232434445';
		con5.External_Email__c = 'test6@gmail.com';
		con5.IsCommunityUser__c = True;
		con5.Role__c = 'Driver';
		con5.Monthly_Mileage_Limit__c=1;
		con5.Deactivated_Date__c = date.today().addmonths(-6);
		con5.Last_Pay_Date__c = System.today();
		con5.Send_deactivation_Email__c = true;
		con5.Sent_Tax_Liability_report_to_Admin__c = false;
		con5.MPG__c = 456;
		con5.Vehicle_Type__c = '2018';
		con5.Employee_ID__c  = '1';
		con5.Maintenance_and_Tires__c = 40;
		con5.Fixed_Amount__c = 45;
		con5.Compliancestatus__c = 'Yes';
		conlist.add(con5);

		Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Role__C = 'Admin';
        con1.AccountId = acc.Id;
        con1.External_Email__c = 'test1@gmail.com';
        con1.send_deactivation_Email__c = true;
        con1.compliancestatus__c = 'Yes';
        conlist.add(con1);

        Contact con7 = new Contact();
        con7.FirstName = 'Test';
        con7.LastName = 'Contact';
        con7.Role__C = 'Admin';
        con7.AccountId = acc.Id;
        con7.External_Email__c = 'test7@gmail.com';
        con7.send_deactivation_Email__c = true;
        con7.compliancestatus__c = 'Yes';
        conlist.add(con7);
        insert conlist;


        /*Employee_Reimbursement__c empReimb = new Employee_Reimbursement__c();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        empReimb.Contact_Id__c = con.id;
        empReimb.Name = 'Test';
        empReimb.Fuel_Price__c = 134;
        empReimb.MPG__c = 47;
        empReimb.Fixed_Amount__c = 50;
        empReimb.Month__c =  ilmr.getLastMonthValue(-1);
        empReimb.Monthly_Mileage__c = 50;
        empReimb.Approved_Date__c = System.today() - 10;
        empReimb.Status__c='Approved';
        insert empReimb;*/
        List<Employee_Reimbursement__c> reimbursmentList = new List<Employee_Reimbursement__c>();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        for(Integer i=0;i<conlist.size();i++)
        {
        	Employee_Reimbursement__c empReimb = new Employee_Reimbursement__c();
	        empReimb.Contact_Id__c = conlist[i].id;
	        empReimb.Name = 'Test';
	        empReimb.Fuel_Price__c = 134;
	        empReimb.MPG__c = 47;
	        empReimb.Fixed_Amount__c = 50;
	        empReimb.Month__c =  ilmr.getLastMonthValue(-i);
	        empReimb.Monthly_Mileage__c = 50;
	        empReimb.Approved_Date__c = System.today() - 10;
	        empReimb.Maintenance_and_Tires__c =10;
	        empReimb.Status__c='Approved';
	        reimbursmentList.add(empReimb);	
        }	
        for(Integer i=0;i<conlist.size();i++)
        {
        	Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
			empReim.Contact_Id__c = con.id;
			empReim.Name = 'Test';
			empReim.Fuel_Price__c = 34;
			empReim.MPG__c = 45;
			empReim.Approved_Date__c = null;
			empReim.Status__c='Pending';
			empReim.Monthly_Mileage__c = 50;
			empReim.Maintenance_and_Tires__c =10;
	        reimbursmentList.add(empReim);	
        }	
        for(Integer i=0;i<conlist.size();i++)
        {
        	Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
			empReim.Contact_Id__c = con4.id;
	        empReim.Name = 'Test';
	        empReim.Fuel_Price__c = 1234;
	        empReim.MPG__c = 4567;
	        empReim.Month__c =  ilmr.getLastMonthValue(-5);
	        empReim.Maintenance_and_Tires__c =10;
	        reimbursmentList.add(empReim);	
        }	
        insert reimbursmentList;
		Employee_Reimbursement__c reimbursment1 = TestUtilityClass.getTestEmployeeReimbursement2(con);
		Employee_Reimbursement__c reimbursment2 = TestUtilityClass.getTestEmployeeReimbursement5(con);
		Employee_Reimbursement__c reimbursment3 = TestUtilityClass.getTestEmployeeReimbursement2(con2);
		Employee_Reimbursement__c reimbursment5 = TestUtilityClass.getTestEmployeeReimbursement5(con2);
		Employee_Reimbursement__c reimbursment4 = TestUtilityClass.getTestEmployeeReimbursement(con2);
		Employee_Reimbursement__c reimbursment10 = TestUtilityClass.getTestEmployeeReimbursement4(con2);
		Employee_Reimbursement__c reimbursment9 = TestUtilityClass.getTestEmployeeReimbursement2(con3);
		Employee_Reimbursement__c reimbursment8 = TestUtilityClass.getTestEmployeeReimbursement(con4);
		Employee_Reimbursement__c reimbursment6 = TestUtilityClass.getTestEmployeeReimbursement2(con4);
		Employee_Reimbursement__c reimbursment7 = TestUtilityClass.getTestEmployeeReimbursement2(con5);

		Employee_Mileage__c empMil  = new Employee_Mileage__c();
		List<Employee_Mileage__c> mileagelist = new List<Employee_Mileage__c>();
        for(Integer i=0;i<reimbursmentList.size();i++)
        {	empMil  = new Employee_Mileage__c();
        	empMil.Name = 'Test';
	        empMil.EmployeeReimbursement__c = reimbursmentList[i].id;
	        empMil.Contact_Email_Id__c = 'test@gmail.com';
	        empMil.Mileage__c = 510;
	        empMil.Approved_Date__c = System.today();
	        empMil.Trip_Status__c = 'Approved';
	        empMil.Rejected__c = False;
	        mileagelist.add(empMil);
        }
        insert mileagelist;

		Test.startTest();
		Gas_Prices__c gasPr = new Gas_Prices__c();
        gasPr.Fuel_Price__c = 123 ;
        gasPr.Month_Year__c = date.newInstance(2018,02,01);
        gasPr.State__c = 'Ts';
        
        insert gasPr;
		DeActivatedAdminEmailBatch_clone deactivationbatch = new DeActivatedAdminEmailBatch_clone();
		Database.executeBatch(deactivationbatch);
		Test.stopTest();
	}
}