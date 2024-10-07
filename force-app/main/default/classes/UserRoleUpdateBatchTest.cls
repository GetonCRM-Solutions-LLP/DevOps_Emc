@isTest
private class UserRoleUpdateBatchTest {
	
	@isTest static void test_method_one() 
	{
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		
		System.runAs (thisUser) 
		{
			Address__c obj_Address = new Address__c();
			obj_Address.State__c ='Alabama';
			obj_Address.City__c ='Abbeville';
			obj_Address.Abbreviation__c ='AL';
			obj_Address.ZIP_Code__c ='36310'; 
			obj_Address.Time_Zone__c = 'America/Phoenix';
			List<Address__c> obj_list_Address = new List<Address__c>();
			obj_list_Address.add(obj_Address);
			insert obj_list_Address;

			Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
			veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
			veh.vehicle__c = 'Full-Size Sedan';
			veh.Year__c = '2019';
			insert veh;

			SendEmail__c customSetting1 =  new SendEmail__c();
			customSetting1.Name = 'Send Email For Compliance';
			customSetting1.Send_email_from_code__c= true;
			insert customSetting1;
				
			Account obj_account = new Account();
			obj_account.Name='Test Account';
			Insert obj_account;

			Contact objcontact = new Contact();
			objcontact.FirstName='tt';
			objcontact.Lastname='testdsfsdfsdfdsfsfsdfsdfds';
			objcontact.email='test3242342@gmail.com';
			objcontact.External_Email__c='test3242342@gmail.com';
			objcontact.Vehicle_Type__c = '2019 Full-Size Sedan' ;
			objcontact.Role__c = 'Manager';
			objcontact.Accountid = obj_account.id;
			objcontact.compliancestatus__c ='Yes';
			objcontact.Deactivated_Date__c = null;
			objcontact.IsCreatedFromCommunity__c = true;
			Insert objcontact;

			objcontact.Role__c='Driver';
			objcontact.FirstName='tts';
			objcontact.External_Email__c='test242342@gmail.com';
			update objcontact;
		}

		UserRoleUpdateBatch userBatch = new UserRoleUpdateBatch();
        database.executebatch(userBatch, 1);

	}
}