@isTest
private class DeActivatedUserSchedulerTest {
	public static String CRON_EXP = '0 0 * * * ?';
	@isTest static void test_method_one() {
		Account account = new Account();
		account.Name = 'Test Account';
		account.Triplog_API__c = '1234567890';
		account.Triplog_Status__c = 'U';
		insert account;

		Contact managerContact = new Contact();
		managerContact.Salutation = 'Mr.';
		managerContact.FirstName = 'Manager';
		managerContact.LastName = 'Name';
		managerContact.AccountId = account.Id;
		managerContact.External_Email__c = 'manager@test.com';
		managerContact.Role__c = 'Manager';
		managerContact.Monthly_Mileage_Limit__c = 1000;
		managerContact.Maintenance_and_Tires__c = 1.5;
		managerContact.MPG__c = 15;
		managerContact.Mailingcity = 'Fort Worth';
		managerContact.MailingState = 'TX';
		managerContact.Triplog_Status__c = 'U';
		insert managerContact;

		Contact driverContact = new Contact();
		driverContact.Salutation = 'Mr.';
		driverContact.FirstName = 'John';
		driverContact.LastName = 'Deo';
		driverContact.AccountId = account.Id;
		driverContact.Email = 'testing@test.com';
		driverContact.External_Email__c = 'testing@test.com';
		driverContact.Manager__c = managerContact.Id;
		driverContact.Manager_External_Email__c = managerContact.External_Email__c;
		driverContact.Monthly_Mileage_Limit__c = 100;
		driverContact.Role__c = 'Driver';
		driverContact.Maintenance_and_Tires__c = 1;
		driverContact.MPG__c = 20;
		driverContact.Mailingcity = 'Fort Worth';
		driverContact.MailingState = 'TX';
		driverContact.Deactivated_Date__c = System.now();
		driverContact.Triplog_Status__c = 'U';
		insert driverContact;

		Gas_Prices__c gasPrice = new Gas_Prices__c();
		gasPrice.Fuel_Price__c = 2.00;
		gasPrice.State__c = driverContact.MailingState;
		gasPrice.City__c = driverContact.Mailingcity;
		gasPrice.Month_Year__c = Date.today().addmonths(-1).tostartofmonth();
		insert gasPrice;

		DeActivatedUserEmailBatch deActivatedUserEmail = new DeActivatedUserEmailBatch();
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetTripCalloutMock());
        String scheduledJobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new DeActivatedUserScheduler());
        System.debug('scheduledJobId:'+scheduledJobId);
        Database.executebatch(deActivatedUserEmail,1);
		Test.stopTest();
		
	}
}