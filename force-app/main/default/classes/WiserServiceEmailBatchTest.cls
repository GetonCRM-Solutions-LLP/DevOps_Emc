@isTest
private class WiserServiceEmailBatchTest {
	
	@isTest static void  WiserServiceEmailBatchTest() {

		Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
		
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting; 

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

		RG_CummuntyUserCreateTgr.isRecursive = false;

		list<Account> accountValues = new list<Account>();		
		for(integer i=1; i < 100; i++)
		{	
		Account innerAccount = new Account();
        innerAccount.Name = 'TestAccount' + i;
        accountValues.add(innerAccount);
    	}
    	insert accountValues;

    	Account accWeiser = new Account();
    	accWeiser.Name = 'Weiser Security Services';
    	insert accWeiser;

    	list<Account> accountQuery = new list<Account>();
        accountQuery = [SELECT Id, Name 
        						FROM Account 
        						WHERE Name = 'Weiser Security Services' OR Name like '%TestAccount%'];
        

        integer i = 1;
 		list<Contact> contactValues = new list<Contact>();
 		list<Employee_Reimbursement__c> emReimburs = new list<Employee_Reimbursement__c>();
		for(Account ac : accountQuery )
		{			
			Contact innerContact = new Contact();
	        innerContact.FirstName = 'FName' + i ;        
	        innerContact.LastName = 'lName' + i;	        
	        innerContact.External_Email__c = 'test'+i+'@gmail.com';
	        innerContact.Email = 'test'+i+'@test.com';
			innerContact.Vehicle_Type__c = '2019 Full-Size Sedan';
	        integer Remainder = Math.Mod(i,4);        
	        if (Remainder == 1)
	        {	
	        	innerContact.Role__c = 'Driver';
	        	innerContact.AccountId = accWeiser.Id;
	        }
	        else if(Remainder == 2)
	        {
	        	innerContact.Role__c = 'Admin';
	        	innerContact.AccountId = accWeiser.Id;
	        }
	        else if(Remainder == 3)
	        {
	        	innerContact.Role__c = 'Driver/Manager';
	        	innerContact.AccountId = ac.Id;
	        }
	        else 
	        {
	        	innerContact.Role__c = 'Manager';
	        	innerContact.AccountId = ac.Id;
	        }

	        innerContact.isCommunityUser__c = true;
	        innerContact.compliancestatus__c = 'Yes';
	        contactValues.add(innerContact);
	        i++;
	    }	    
	    insert contactValues;
	            	
        Employee_Reimbursement__c erRec = new Employee_Reimbursement__c();
        list<Contact> contactQuery = new list<Contact>();
        contactQuery = [ Select id, FirstName,
        					    LastName, 
        						External_Email__c, Email, 
        						Role__c,
        						isCommunityUser__c,
        						compliancestatus__c
        					From Contact 
        					Where LastName like 'lName' ];        
        
        integer j = 1;				
        for(Contact a : contactQuery)
        {        	
	    	erRec.Contact_Id__c = a.Id;
	        erRec.month__c = '01-2018';
	        erRec.Name = a.LastName+':'+erRec.month__c;
	        erRec.Status__c = 'Pending';
	        erRec.Fuel_Price__c = 2.22 + j ;        
	        erRec.Fixed_Amount__c = 10.10 + j ;
	        emReimburs.add(erRec);	
	        j++;  
        }      
	    

   		insert emReimburs;

        WiserServiceEmailBatch b = new WiserServiceEmailBatch();
		Database.executeBatch(b,1);

        
	}
	
	
	
}