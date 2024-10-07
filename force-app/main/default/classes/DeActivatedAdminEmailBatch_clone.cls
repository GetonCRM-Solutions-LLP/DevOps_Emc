global class DeActivatedAdminEmailBatch_clone implements Database.Batchable<sObject>,Database.Stateful
{
    public String query;
    public EmailTemplate deactNoFinalTax, deactTaxLiability, deactNoTaxLiability, deactAppTaxLiablity, deactAppFinalPayDate;
    global Static Map<String,List<wrapppertax>> taxCalculation_conid_wrappaertax_map = new Map<String,List<wrapppertax>>();
    public DeActivatedAdminEmailBatch_clone() 
    {
    	 
    	deactNoFinalTax = [SELECT Id, HtmlValue,
		Name, Subject
		FROM EmailTemplate
		WHERE DeveloperName = 'Deactivation_email_to_the_Admin_No_Final_Tax'];

		deactTaxLiability = [SELECT Id, HtmlValue,
		Name, Subject
		FROM EmailTemplate
		WHERE DeveloperName = 'Deactivation_email_to_the_Admin_TAX_LIABILITY'];

		deactNoTaxLiability = [SELECT Id, HtmlValue,
		Name, Subject
		FROM EmailTemplate
		WHERE DeveloperName = 'Deactivation_email_to_the_Admin_NO_TAX_LIABILITY'];

		deactAppTaxLiablity = [SELECT Id, HtmlValue,
		Name, Subject
		FROM EmailTemplate
		WHERE DeveloperName = 'Deactivation_email_to_the_Admin_approved_TAX_LIABILITY'];

		deactAppFinalPayDate = [SELECT Id, HtmlValue,
		Name, Subject
		FROM EmailTemplate
		WHERE DeveloperName = 'Deactivation_email_to_the_Admin_APPROVED_BY_THE_FINAL_PAY_DATE'];
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        if (Test.isRunningTest()) 
        {
            String role = '(Role__c=\'' + 'Driver/Manager\' OR Role__c=\'' + 'Driver' + '\')';
            query = 'SELECT Id,Name,CreatedDate,FirstName,Deactivated_Date__c,External_Email__c,compliancestatus__c,AccountId,Manager_External_Email__c,Manager__r.FirstName,Manager__r.External_Email__c,Monthly_Mileage_Limit__c,Manager__r.send_deactivation_Email__c FROM Contact where ' + role + ' LIMIT 10';
        } 
        else 
        {
            SendEmail__c  objSendEmail = SendEmail__c.getValues('DeActivatedUserEmailBatch');
            if ((objSendEmail != null) && (objSendEmail.Send_email_from_code__c == true)) 
            {
                String role = '(Role__c=\'' + 'Driver/Manager\' OR Role__c=\'' + 'Driver' + '\')';
                query = 'SELECT Id,Name,CreatedDate,FirstName,Deactivated_Date__c,compliancestatus__c,External_Email__c,AccountId,Manager_External_Email__c,Manager__r.FirstName,Manager__r.External_Email__c,Monthly_Mileage_Limit__c,Manager__r.send_deactivation_Email__c FROM Contact WHERE Last_Pay_Date__c = Today and send_deactivation_Email__c=true and Sent_Tax_Liability_report_to_Admin__c=false and ' + role;
            } 
            else 
            {
                String role = 'Role__c=\'' + 'Admin\' and Role__c=\'' + 'Driver' + '\'';
                query = 'SELECT Id,Name,CreatedDate,FirstName,Deactivated_Date__c,External_Email__c,compliancestatus__c,AccountId,Manager_External_Email__c,Manager__r.FirstName,Manager__r.External_Email__c,Monthly_Mileage_Limit__c FROM Contact WHERE ' + role;
            }
        }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
    	
    	Set<Id> accountIds = new Set<Id>();
    	Map<String,String> contact_acccount_id_map = new Map<String,String>();
        for(Contact contactId : (List<Contact>) scope) {
            accountIds.add(contactId.AccountId);
            contact_acccount_id_map.put(contactId.Id,contactId.AccountId);
        }
        
        List<Contact> adminContact = [SELECT Id,Name,FirstName,External_Email__c,AccountId,send_deactivation_Email__c FROM Contact WHERE AccountId In: accountIds AND Role__C = 'Admin' and send_deactivation_Email__c=true];
        Map<String, Map<String,Contact>> accountAdmins = new Map<String, Map<String,Contact>>();
		Map<String,Contact> con_map = new Map<String,Contact>();
		
		
        for(Contact singleAdmin : adminContact) {
            if(!accountAdmins.containsKey(singleAdmin.AccountId)) 
            {
            	
               	con_map.put(singleAdmin.Id,singleAdmin);
                accountAdmins.put(singleAdmin.AccountId,con_map);
            }
            else
            {
            	con_map = accountAdmins.get(String.valueOf(singleAdmin.AccountId));                
                con_map.put(singleAdmin.Id,singleAdmin);
                accountAdmins.put(singleAdmin.AccountId,con_map);
            }
        }
       	
        List<String> obj_driverids = new List<String>();
        Map<String,String> driverMap = new Map<String,String>();
        Map<String,String> emaildecider = new Map<String,String>();
        Map<String,Boolean> emailboolean = new Map<String,Boolean>();
        List<Integer> quaterstatusList = new List<Integer>();
        Map<String,Map<Integer,wrapppertax>> obj_contactwise_tax = new Map<String,Map<Integer,wrapppertax>>();
        Map<String,Contact> obj_useForEmail_map = new Map<String,Contact>();
        for (Contact obj_singleContact : (List<Contact>) scope) 
        {
            if(obj_singleContact.compliancestatus__c == 'Yes')
            {
                if(obj_singleContact.Deactivated_Date__c.month()==12)
                {
                    // only 1 month that is 12 for tax calc                    
                    Map<Integer,wrapppertax> obj_map_for_tax = new Map<Integer,wrapppertax>();
                    List<Integer> obj_list_taxmonths =  new List<Integer>();  
                    wrapppertax obj_wrapppertax = new wrapppertax();
                    /*if(obj_contactwise_tax.containsKey(String.valueOf(obj_singleContact.id)))
                    {              

                    	obj_map_for_tax = obj_contactwise_tax.get(String.valueOf(obj_singleContact.id));                    	                    	
                    	if(obj_map_for_tax.containsKey(1))
                    	{                    		
                    		obj_wrapppertax = obj_map_for_tax.get(1);                    		
                    		obj_list_taxmonths = obj_wrapppertax.taxCalulationMonths;
                    		boolean flag= false;
                    		for(Integer k:obj_list_taxmonths)
                    		{
                    			if(k==12)
                    			{
                    				flag= true;
                    				break;
                    			}
                    		}
                    		if(flag==false)
                    		{
                    			obj_list_taxmonths.add(12);
                    			obj_wrapppertax.taxCalulationMonths = null;
                    			obj_wrapppertax.TaxThreshold = obj_wrapppertax.TaxThreshold + 416.67; 
	                    		obj_wrapppertax.taxCalulationMonths =obj_list_taxmonths;
	                    		obj_map_for_tax.put(1,obj_wrapppertax);
	                    		obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
                    		}                    		
                    	}
                    	else
                    	{
                    		obj_list_taxmonths.add(12);
                    		obj_wrapppertax.contactid =String.valueOf(obj_singleContact.id);
					        obj_wrapppertax.quarterno =1;
					        obj_wrapppertax.Mileages =0;
					        obj_wrapppertax.Reimbursements =0; 
					        obj_wrapppertax.MaxIRSrate  =0;
					        obj_wrapppertax.ImputedAmount = 0;
					        obj_wrapppertax.TaxThreshold = 416.67;
					        obj_wrapppertax.taxCalulationMonths = obj_list_taxmonths;
					        obj_map_for_tax.put(1,obj_wrapppertax);
	                    	obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);                    		
                    	}
                    }
                    else
                    {*/
                    		obj_list_taxmonths.add(12);
                    		obj_wrapppertax.contactid =String.valueOf(obj_singleContact.id);
					        obj_wrapppertax.quarterno =1;
					        obj_wrapppertax.Mileages =0;
					        obj_wrapppertax.Reimbursements =0; 
					        obj_wrapppertax.MaxIRSrate  =0;
					        obj_wrapppertax.ImputedAmount = 0;
					        obj_wrapppertax.TaxThreshold = 416.67;
					        obj_wrapppertax.taxCalulationMonths = obj_list_taxmonths;
					        obj_map_for_tax.put(1,obj_wrapppertax);
	                    	obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
                    	// create inner map and assign that inner map to outer map
                    /*}*/
                }
                else
                {   
                    Integer j=1;
                    List<Integer> obj_list_taxmonths =  new List<Integer>();
                    
                    if((obj_singleContact.Deactivated_Date__c.year()==obj_singleContact.CreatedDate.year()))
                    {
                        j=obj_singleContact.CreatedDate.month();                        
                    }
                    else if((obj_singleContact.Deactivated_Date__c.year()!=obj_singleContact.CreatedDate.year()))
                    {    
                    	obj_list_taxmonths.add(12);
                        j=1;
                    }
                    Map<Integer,wrapppertax> obj_map_for_tax = new Map<Integer,wrapppertax>();
                   
                    wrapppertax obj_wrapppertax = new wrapppertax();
                    if(obj_contactwise_tax.containsKey(String.valueOf(obj_singleContact.id)))
                    {
                    	obj_map_for_tax = obj_contactwise_tax.get(String.valueOf(obj_singleContact.id));                    	
                    }
                    for(Integer i=j;i<=obj_singleContact.Deactivated_Date__c.month();i++)
	                    {	                        
	                        if(i == 12 || i <= 2) 
	                        {
	                            if(obj_map_for_tax.containsKey(1))
	                            {
	                            	obj_wrapppertax = obj_map_for_tax.get(1);
	                            	obj_list_taxmonths = obj_wrapppertax.taxCalulationMonths;
		                    		boolean flag= false;
		                    		for(Integer k:obj_list_taxmonths)
		                    		{
		                    			if(k==i)
		                    			{
		                    				flag= true;
		                    				break;
		                    			}
		                    		}
		                    		if(flag==false)
		                    		{
		                    			obj_list_taxmonths.add(i);
		                    			obj_wrapppertax.taxCalulationMonths = null;
			                    		obj_wrapppertax.taxCalulationMonths =obj_list_taxmonths;
			                    		obj_wrapppertax.TaxThreshold = obj_wrapppertax.TaxThreshold + 416.67;
			                    		obj_map_for_tax.put(1,obj_wrapppertax);
			                    		obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
		                    		}
	                            }
	                            else
	                            {
	                            	obj_list_taxmonths.add(i);
		                    		obj_wrapppertax.contactid =String.valueOf(obj_singleContact.id);
							        obj_wrapppertax.quarterno =1;
							        obj_wrapppertax.Mileages =0;
							        obj_wrapppertax.Reimbursements =0; 
							        obj_wrapppertax.MaxIRSrate  =0;
							        obj_wrapppertax.ImputedAmount = 0;
							        obj_wrapppertax.TaxThreshold = 416.67;
							        obj_wrapppertax.taxCalulationMonths = obj_list_taxmonths;
							        obj_map_for_tax.put(1,obj_wrapppertax);
			                    	obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
	                            }
	                        }
	                        else if(3 <= i && i <= 5) 
	                        {
	                            if(obj_map_for_tax.containsKey(2))
	                            {
	                            	obj_wrapppertax = obj_map_for_tax.get(2);
	                            	obj_list_taxmonths = obj_wrapppertax.taxCalulationMonths;
		                    		boolean flag= false;
		                    		for(Integer k:obj_list_taxmonths)
		                    		{
		                    			if(k==i)
		                    			{
		                    				flag= true;
		                    				break;
		                    			}
		                    		}
		                    		if(flag==false)
		                    		{
		                    			obj_list_taxmonths.add(i);
		                    			obj_wrapppertax.taxCalulationMonths = null;
			                    		obj_wrapppertax.taxCalulationMonths =obj_list_taxmonths;
			                    		obj_wrapppertax.TaxThreshold = obj_wrapppertax.TaxThreshold + 416.67;
			                    		obj_map_for_tax.put(2,obj_wrapppertax);
			                    		obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
		                    		}
	                            }
	                            else
	                            {
	                            	obj_list_taxmonths.add(i);
		                    		obj_wrapppertax.contactid =String.valueOf(obj_singleContact.id);
							        obj_wrapppertax.quarterno =2;
							        obj_wrapppertax.Mileages =0;
							        obj_wrapppertax.Reimbursements =0; 
							        obj_wrapppertax.MaxIRSrate  =0;
							        obj_wrapppertax.ImputedAmount = 0;
							        obj_wrapppertax.TaxThreshold = 416.67;
							        obj_wrapppertax.taxCalulationMonths = obj_list_taxmonths;
							        obj_map_for_tax.put(2,obj_wrapppertax);
			                    	obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
	                            }
	                        }
	                        else if(6 <= i && i <= 8) 
	                        {
	                            if(obj_map_for_tax.containsKey(3))
	                            {
	                            	obj_wrapppertax = obj_map_for_tax.get(3);
	                            	obj_list_taxmonths = obj_wrapppertax.taxCalulationMonths;
		                    		boolean flag= false;
		                    		for(Integer k:obj_list_taxmonths)
		                    		{
		                    			if(k==i)
		                    			{
		                    				flag= true;
		                    				break;
		                    			}
		                    		}
		                    		if(flag==false)
		                    		{
		                    			obj_list_taxmonths.add(i);
		                    			obj_wrapppertax.taxCalulationMonths = null;
			                    		obj_wrapppertax.taxCalulationMonths =obj_list_taxmonths;
			                    		obj_wrapppertax.TaxThreshold = obj_wrapppertax.TaxThreshold + 416.67;
			                    		obj_map_for_tax.put(3,obj_wrapppertax);
			                    		obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
		                    		}
	                            }
	                            else
	                            {
	                            	obj_list_taxmonths.add(i);
		                    		obj_wrapppertax.contactid =String.valueOf(obj_singleContact.id);
							        obj_wrapppertax.quarterno =3;
							        obj_wrapppertax.Mileages =0;
							        obj_wrapppertax.Reimbursements =0; 
							        obj_wrapppertax.MaxIRSrate  =0;
							        obj_wrapppertax.ImputedAmount = 0;
							        obj_wrapppertax.TaxThreshold = 416.67;
							        obj_wrapppertax.taxCalulationMonths = obj_list_taxmonths;
							        obj_map_for_tax.put(3,obj_wrapppertax);
			                    	obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
	                            }
	                        }
	                        else if(9 <= i && i <= 11) 
	                        {
	                            if(obj_map_for_tax.containsKey(4))
	                            {
	                            	obj_wrapppertax = obj_map_for_tax.get(4);
	                            	obj_list_taxmonths = obj_wrapppertax.taxCalulationMonths;
		                    		boolean flag= false;
		                    		for(Integer k:obj_list_taxmonths)
		                    		{
		                    			if(k==i)
		                    			{
		                    				flag= true;
		                    				break;
		                    			}
		                    		}
		                    		if(flag==false)
		                    		{
		                    			obj_list_taxmonths.add(i);
		                    			obj_wrapppertax.taxCalulationMonths = null;
			                    		obj_wrapppertax.taxCalulationMonths =obj_list_taxmonths;
			                    		obj_wrapppertax.TaxThreshold = obj_wrapppertax.TaxThreshold + 416.67;
			                    		obj_map_for_tax.put(4,obj_wrapppertax);
			                    		obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
		                    		}
	                            }
	                            else
	                            {
	                            	obj_list_taxmonths.add(i);
		                    		obj_wrapppertax.contactid =String.valueOf(obj_singleContact.id);
							        obj_wrapppertax.quarterno =4;
							        obj_wrapppertax.Mileages =0;
							        obj_wrapppertax.Reimbursements =0; 
							        obj_wrapppertax.MaxIRSrate  =0;
							        obj_wrapppertax.ImputedAmount = 0;
							        obj_wrapppertax.TaxThreshold = 416.67;
							        obj_wrapppertax.taxCalulationMonths = obj_list_taxmonths;
							        obj_map_for_tax.put(4,obj_wrapppertax);
			                    	obj_contactwise_tax.put(String.valueOf(obj_singleContact.id),obj_map_for_tax);
	                            }
	                        } 
	                    }
                
                }
                obj_driverids.add(obj_singleContact.id);
                obj_useForEmail_map.put(String.valueOf(obj_singleContact.id),obj_singleContact);
            }
        }
        List<String> monthsuptoNow = new List<String>();
        monthsuptoNow = getAllMonths();
        List<Employee_Reimbursement__c> listEmployeeReimbursement = new List<Employee_Reimbursement__c>();
        
        if(obj_driverids.size()>0 && monthsuptoNow.size()>0)
        {
        	
            listEmployeeReimbursement = getAllReimbursements(obj_driverids,monthsuptoNow);  
        }
        Map<String,Double> obj_map_irsrate = new Map<String,Double>(); 
        obj_map_irsrate = getIrsMileageRate(); 
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();  
        
    	String addressLabel = Label.Test_emailAddress;
		List<String> obj_toaddresses = new List<String>();
		if(addressLabel.contains(',')){
			List<String> addresslist = new List<String>();
			addresslist = addressLabel.split(',');
			for(String s : addresslist)
			{
				obj_toaddresses.add(s);
			}
		}
		else
		{
			obj_toaddresses.add(addressLabel);
		}
        
        
        if(listEmployeeReimbursement.size()>0)
        {
            for(String obj_singleContact :obj_driverids)
            {
            	Map<String,Boolean> emailboolean1 = new Map<String,Boolean>();
            	List<Employee_Reimbursement__c> approvedEmployeeReimbursement = new List<Employee_Reimbursement__c>();
                List<Employee_Reimbursement__c> unapprovedEmployeeReimbursement = new List<Employee_Reimbursement__c>();
                approvedEmployeeReimbursement = getApprovedReimbursements(listEmployeeReimbursement,obj_singleContact);
                unapprovedEmployeeReimbursement = getUnApprovedReimbursements(listEmployeeReimbursement,obj_singleContact);
                if(approvedEmployeeReimbursement.size()>0 && unapprovedEmployeeReimbursement.size()==0 && obj_map_irsrate.size()>0)
                {

                    emailboolean1 = getTaxCalculation(obj_contactwise_tax,obj_map_irsrate,approvedEmployeeReimbursement,obj_singleContact);
                 	Boolean flag;
                    if(emailboolean1.containskey(obj_singleContact) && taxCalculation_conid_wrappaertax_map.containskey(obj_singleContact))
                    {
                    	
                    	flag = emailboolean1.get(obj_singleContact);
                    	if(flag == true){
                    		// No Tax
	                    	if(obj_useForEmail_map.containskey(obj_singleContact))
							{
								
								String name = obj_useForEmail_map.get(obj_singleContact).Name;
								if(contact_acccount_id_map.containsKey(obj_singleContact))
								{
									String accid = contact_acccount_id_map.get(obj_singleContact);
									
									if(accountAdmins.containsKey(accid))
									{
										Map<String,Contact> con_map1 = new Map<String,Contact>();
										con_map1 = accountAdmins.get(accid);										
										for(String s : con_map1.keySet())
										{
											
											String newEmailBody = deactNoFinalTax.HtmlValue;
											String adminname = con_map1.get(s).FirstName;
											newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.FirstName}',adminname);
											String adminEmailAddress = con_map1.get(s).External_Email__c;
										//	obj_toaddresses.add(adminEmailAddress);
											newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.Name}',name);
											newEmailBody = htmlReplaceText(newEmailBody,'{!$Label.Driver_Forword_Logo}',System.Label.Driver_Forword_Logo);
											messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
											//addlist1
											//obj_toaddresses.add('priyanka.goc@gmail.com');

											mail = buildemail(obj_toaddresses,deactNoFinalTax.Subject,newEmailBody);

											List<wrapppertax> wrapppertaxlist1 = taxCalculation_conid_wrappaertax_map.get(obj_singleContact);
											String contentCSV = '';
											for(wrapppertax w : wrapppertaxlist1)
											{
												contentCSV = String.valueOf(w.ImputedAmount)+','+String.valueOf(w.MaxIRSrate)+','+String.valueOf(w.Mileages)+','+String.valueOf(w.Reimbursements)+','+String.valueOf(w.TaxThreshold);
											}
											if(!contentCSV.contains('null'))
											{
												String content = 'ImputedAmount, MaxIRSrate, Mileages,Reimbursements,TaxThreshold\n' + contentCSV;
												Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
												attachment.setFileName( 'Compilance Calculation.csv' );
												attachment.setBody( Blob.valueOf( content ) );
												mail.setFileAttachments( new Messaging.EmailFileAttachment[]{ attachment } );
											}
											messages.add(mail);
										}
									}
								}
							}
                    	}
                    	else
                    	{
                    		// has tax
                    		// All are approved deactTaxLiability
							if(obj_useForEmail_map.containskey(obj_singleContact))
							{
								List<String> adminNameList = new List<String>();
								String name = obj_useForEmail_map.get(obj_singleContact).Name;
								
								
								if(contact_acccount_id_map.containsKey(obj_singleContact))
								{
									String accid = contact_acccount_id_map.get(obj_singleContact);
									
									if(accountAdmins.containsKey(accid))
									{
										Map<String,Contact> con_map1 = new Map<String,Contact>();
										con_map1 = accountAdmins.get(accid);
										for(String s : con_map1.keySet())
										{
											if(con_map1.containsKey(s))
											{
												String newEmailBody = deactTaxLiability.HtmlValue;
												String adminname = con_map1.get(s).FirstName;
												adminNameList.add(adminname);
												newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.FirstName}',adminname);
												String adminEmailAddress = con_map1.get(s).External_Email__c;
											//	obj_toaddresses.add(adminEmailAddress);
												newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.Name}',name);
												newEmailBody = htmlReplaceText(newEmailBody,'{!$Label.Driver_Forword_Logo}',System.Label.Driver_Forword_Logo);
												messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
												
											//	obj_toaddresses.add('priyanka.goc@gmail.com');
												mail = buildemail(obj_toaddresses,deactTaxLiability.Subject,newEmailBody);

												List<wrapppertax> wrapppertaxlist1 = taxCalculation_conid_wrappaertax_map.get(obj_singleContact);
												String contentCSV = '';
												for(wrapppertax w : wrapppertaxlist1)
												{
													contentCSV = String.valueOf(w.ImputedAmount)+','+String.valueOf(w.MaxIRSrate)+','+String.valueOf(w.Mileages)+','+String.valueOf(w.Reimbursements)+','+String.valueOf(w.TaxThreshold);
												}
												if(!contentCSV.contains('null'))
												{
													String content = 'ImputedAmount, MaxIRSrate, Mileages,Reimbursements,TaxThreshold\n' + contentCSV;
													Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
													attachment.setFileName( 'Compilance Calculation.csv' );
													attachment.setBody( Blob.valueOf( content ) );
													mail.setFileAttachments( new Messaging.EmailFileAttachment[]{ attachment } );
												}
												messages.add(mail);
											}
										}
									}
								}	
							}
                    	}
                    }
                }
                else if(approvedEmployeeReimbursement.size()>0 && unapprovedEmployeeReimbursement.size()>0 && obj_map_irsrate.size()>0)
                {
                	emailboolean1 = getTaxCalculation(obj_contactwise_tax,obj_map_irsrate,approvedEmployeeReimbursement,obj_singleContact);
                	Boolean flag;
                	if(emailboolean1.containskey(obj_singleContact))
                    {
                    	flag = emailboolean1.get(obj_singleContact);
                    	if(flag == true){
                    		// No Tax
                    		System.debug('obj_useForEmail_map:---'+obj_useForEmail_map);
                    		System.debug('taxCalculation_conid_wrappaertax_map:---'+taxCalculation_conid_wrappaertax_map);
							if(obj_useForEmail_map.containskey(obj_singleContact) && taxCalculation_conid_wrappaertax_map.containskey(obj_singleContact))
							{
								String name = obj_useForEmail_map.get(obj_singleContact).Name;
								if(contact_acccount_id_map.containsKey(obj_singleContact))
								{
									String accid = contact_acccount_id_map.get(obj_singleContact);
									
									if(accountAdmins.containsKey(accid))
									{
										Map<String,Contact> con_map1 = new Map<String,Contact>();
										con_map1 = accountAdmins.get(accid);
										for(String s : con_map1.keySet())
										{
											if(con_map1.containsKey(s))
											{
												String newEmailBody = deactNoTaxLiability.HtmlValue;
												String adminname = con_map1.get(s).FirstName;
												newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.FirstName}',adminname);
												String adminEmailAddress = con_map1.get(s).External_Email__c;
											//	obj_toaddresses.add(adminEmailAddress);
												newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.Name}',name);
												newEmailBody = htmlReplaceText(newEmailBody,'{!$Label.Driver_Forword_Logo}',System.Label.Driver_Forword_Logo);
												messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
												
											//	obj_toaddresses.add('priyanka.goc@gmail.com');
												mail = buildemail(obj_toaddresses,deactNoTaxLiability.Subject,newEmailBody);

												List<wrapppertax> wrapppertaxlist1 = taxCalculation_conid_wrappaertax_map.get(obj_singleContact);
												String contentCSV = '';
												for(wrapppertax w : wrapppertaxlist1)
												{
													contentCSV = String.valueOf(w.ImputedAmount)+','+String.valueOf(w.MaxIRSrate)+','+String.valueOf(w.Mileages)+','+String.valueOf(w.Reimbursements)+','+String.valueOf(w.TaxThreshold);
												}
												if(!contentCSV.contains('null'))
												{
													String content = 'ImputedAmount, MaxIRSrate, Mileages,Reimbursements,TaxThreshold\n' + contentCSV;
													Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
													attachment.setFileName( 'Compilance Calculation.csv' );
													attachment.setBody( Blob.valueOf( content ) );
													mail.setFileAttachments( new Messaging.EmailFileAttachment[]{ attachment } );
												}
												messages.add(mail);
											}
										}
									}
								}
							}
                    	}
                    	else
                    	{
                    		// has tax
                    		// All are approved deactTaxLiability
							if(obj_useForEmail_map.containskey(obj_singleContact))
							{
								String name = obj_useForEmail_map.get(obj_singleContact).Name;
								if(contact_acccount_id_map.containsKey(obj_singleContact))
								{
									String accid = contact_acccount_id_map.get(obj_singleContact);
									
									if(accountAdmins.containsKey(accid))
									{
										Map<String,Contact> con_map1 = new Map<String,Contact>();
										con_map1 = accountAdmins.get(accid);
										for(String s : con_map1.keySet())
										{
											if(con_map1.containsKey(s))
											{
												String newEmailBody = deactTaxLiability.HtmlValue;
												String adminname = con_map1.get(s).FirstName;

												newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.FirstName}',adminname);
												String adminEmailAddress = con_map1.get(s).External_Email__c;
											//	obj_toaddresses.add(adminEmailAddress);
												newEmailBody = htmlReplaceText(newEmailBody,'{!Contact.Name}',name);
												newEmailBody = htmlReplaceText(newEmailBody,'{!$Label.Driver_Forword_Logo}',System.Label.Driver_Forword_Logo);
												messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
												
											//	obj_toaddresses.add('priyanka.goc@gmail.com');
												mail = buildemail(obj_toaddresses,deactTaxLiability.Subject,newEmailBody);

												List<wrapppertax> wrapppertaxlist1 = taxCalculation_conid_wrappaertax_map.get(obj_singleContact);
												String contentCSV = '';
												for(wrapppertax w : wrapppertaxlist1)
												{
													contentCSV = String.valueOf(w.ImputedAmount)+','+String.valueOf(w.MaxIRSrate)+','+String.valueOf(w.Mileages)+','+String.valueOf(w.Reimbursements)+','+String.valueOf(w.TaxThreshold);
												}
												if(!contentCSV.contains('null'))
												{
													String content = 'ImputedAmount, MaxIRSrate, Mileages,Reimbursements,TaxThreshold\n' + contentCSV;
													Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
													attachment.setFileName( 'Compilance Calculation.csv' );
													attachment.setBody( Blob.valueOf( content ) );
													mail.setFileAttachments( new Messaging.EmailFileAttachment[]{ attachment } );
												}
												messages.add(mail);
											}
										}
									}
								}
							}
                    	}
                    }
                }
                else if(approvedEmployeeReimbursement.size()==0 && unapprovedEmployeeReimbursement.size()>0 && obj_map_irsrate.size()>0)
                {
                    // All are un approved
                }
            }
            SendEmailToMe__c  sendmailtome = SendEmailToMe__c.getValues('DeActivatedAdminEmailBatch_clone');
            if(sendmailtome.Send_email_to_me__c == true) 
            {
            	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);           	
            }
        }   
    }
    public Static Map<String,Boolean> getTaxCalculation(Map<String,Map<Integer,wrapppertax>> obj_contactwise_tax,Map<String,Double> obj_irsrate,List<Employee_Reimbursement__c> approvedEmployeeReimbursement,String contactid)
    {
    	
    	Map<Integer,wrapppertax> obj_currentcontactwise_tax1 = new Map<Integer,wrapppertax>();
    	Map<String,Boolean> emailboolean = new Map<String,Boolean>();
    	for(Employee_Reimbursement__c obj:approvedEmployeeReimbursement)
    	{
    		Map<Integer,wrapppertax> obj_currentcontactwise_tax = obj_contactwise_tax.get(String.valueOf(obj.Contact_Id__c));
    	
    		List<String> months = new List<String>();
    		if ((obj.Month__c != null) && (obj.Month__c.contains('-')))
    		{
    			months = obj.Month__c.split('-');
				if(obj_currentcontactwise_tax.containsKey(1))
				{
					wrapppertax obj_wrapppertax = obj_currentcontactwise_tax.get(1);
					if ((obj_wrapppertax.Mileages != null)) 
					{
                        Double dd = obj_wrapppertax.Mileages;
                        if (obj.Total_Mileage__c != null) 
                        {
                            dd = dd + obj.Total_Mileage__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Mileages = dd;
                	} 
                	else 
                	{
                        if (obj.Total_Mileage__c != null) {
                            obj_wrapppertax.Mileages = obj.Total_Mileage__c.setScale(2);
                        }
                	}
                	if ((obj_wrapppertax.Reimbursements != null))
                	{
                        Double dd = obj_wrapppertax.Reimbursements;
                        if (obj.Total_Monthly_Reimbursement__c != null)
                        {
                            dd = dd + obj.Total_Monthly_Reimbursement__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Reimbursements = dd;
                    }
                    else
                    {
                        if (obj.Total_Monthly_Reimbursement__c != null)
                        {
                            obj_wrapppertax.Reimbursements = obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                	}
                    if ((obj_wrapppertax.MaxIRSrate != null)) 
                    {
                        Decimal dd = obj_wrapppertax.MaxIRSrate;
                        if (obj_irsrate.containsKey(String.valueOf(months[1])) && (obj.Total_Mileage__c != null)) 
                        {
                            dd = dd + (((obj.Total_Mileage__c) * (obj_irsrate.get(String.valueOf(months[1])))));
                        }
                        dd = dd.setScale(2);
                        obj_wrapppertax.MaxIRSrate = dd;
                    } 
                    else 
                    {
                        if ((obj.Total_Mileage__c != null) && obj_irsrate.containsKey(String.valueOf(months[1])))
                        {
                            obj_wrapppertax.MaxIRSrate = ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                        }
                    }
                    Double dd1 = 0;
                    if (obj_wrapppertax.ImputedAmount != null)
                    {
                        dd1 = obj_wrapppertax.ImputedAmount;
                    }
                    if ((obj.Total_Monthly_Reimbursement__c != null) && (obj.Total_Mileage__c != null) && (obj_irsrate.containsKey(String.valueOf(months[1]))))
                    {
                        dd1 = dd1 + obj.Total_Monthly_Reimbursement__c - ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                    }
                    Decimal ddf2 = Decimal.valueOf(dd1);
                    dd1 = ddf2.setScale(2);
                    obj_wrapppertax.ImputedAmount = dd1;
                    obj_currentcontactwise_tax1.put(1,obj_wrapppertax);
				}    				 
				if(obj_currentcontactwise_tax.containsKey(2))
				{
					wrapppertax obj_wrapppertax = obj_currentcontactwise_tax.get(2);
					if ((obj_wrapppertax.Mileages != null)) 
					{
                        Double dd = obj_wrapppertax.Mileages;
                        if (obj.Total_Mileage__c != null) 
                        {
                            dd = dd + obj.Total_Mileage__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Mileages = dd;
                	} 
                	else 
                	{
                        if (obj.Total_Mileage__c != null) {
                            obj_wrapppertax.Mileages = obj.Total_Mileage__c.setScale(2);
                        }
                	}
                	if ((obj_wrapppertax.Reimbursements != null))
                	{
                        Double dd = obj_wrapppertax.Reimbursements;
                        if (obj.Total_Monthly_Reimbursement__c != null)
                        {
                            dd = dd + obj.Total_Monthly_Reimbursement__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Reimbursements = dd;
                    } 
                    else 
                    {
                        if (obj.Total_Monthly_Reimbursement__c != null) 
                        {
                            obj_wrapppertax.Reimbursements = obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                    }
                    if ((obj_wrapppertax.MaxIRSrate != null))
                    {
                        Decimal dd = obj_wrapppertax.MaxIRSrate;
                        if (obj_irsrate.containsKey(String.valueOf(months[1])) && (obj.Total_Mileage__c != null)) 
                        {
                            dd = dd + (((obj.Total_Mileage__c) * (obj_irsrate.get(String.valueOf(months[1])))));
                        }
                        dd = dd.setScale(2);
                        obj_wrapppertax.MaxIRSrate = dd;
                    } 
                    else
                    {
                        if ((obj.Total_Mileage__c != null) && obj_irsrate.containsKey(String.valueOf(months[1]))) 
                        {
                            obj_wrapppertax.MaxIRSrate = ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                        }
                    }
                    Double dd1 = 0;
                    if (obj_wrapppertax.ImputedAmount != null)
                    {
                        dd1 = obj_wrapppertax.ImputedAmount;
                    }
                    if ((obj.Total_Monthly_Reimbursement__c != null) && (obj.Total_Mileage__c != null) && (obj_irsrate.containsKey(String.valueOf(months[1])))) 
                    {
                        dd1 = dd1 + obj.Total_Monthly_Reimbursement__c - ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                    }
                    Decimal ddf2 = Decimal.valueOf(dd1);
                    dd1 = ddf2.setScale(2);
                    obj_wrapppertax.ImputedAmount = dd1;
                    obj_currentcontactwise_tax1.put(2,obj_wrapppertax);
    			}
				if(obj_currentcontactwise_tax.containsKey(3))
				{
					wrapppertax obj_wrapppertax = obj_currentcontactwise_tax.get(3);
                    if ((obj_wrapppertax.Mileages != null)) 
                    {
                        Double dd = obj_wrapppertax.Mileages;
                        if (obj.Total_Mileage__c != null) 
                        {
                            dd = dd + obj.Total_Mileage__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Mileages = dd;
                    } 
                    else 
                    {
                        if (obj.Total_Mileage__c != null) 
                        {
                            obj_wrapppertax.Mileages = obj.Total_Mileage__c.setScale(2);
                        }
                    }
                    if ((obj_wrapppertax.Reimbursements != null)) 
                    {
                        Double dd = obj_wrapppertax.Reimbursements;
                        if (obj.Total_Monthly_Reimbursement__c != null) 
                        {
                            dd = dd + obj.Total_Monthly_Reimbursement__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Reimbursements = dd;
                    } 
                    else 
                    {
                        if (obj.Total_Monthly_Reimbursement__c != null) 
                        {
                            obj_wrapppertax.Reimbursements = obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                    }
                    if ((obj_wrapppertax.MaxIRSrate != null)) 
                    {
                        Decimal dd = obj_wrapppertax.MaxIRSrate;
                        if (obj_irsrate.containsKey(String.valueOf(months[1])) && (obj.Total_Mileage__c != null)) 
                        {
                            dd = dd + (((obj.Total_Mileage__c) * (obj_irsrate.get(String.valueOf(months[1])))));
                        }
                        dd = dd.setScale(2);
                        obj_wrapppertax.MaxIRSrate = dd;
                    } 
                    else 
                    {
                        if ((obj.Total_Mileage__c != null) && obj_irsrate.containsKey(String.valueOf(months[1]))) 
                        {
                            obj_wrapppertax.MaxIRSrate = ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                        }
                    }
                    Double dd1 = 0;
                    if (obj_wrapppertax.ImputedAmount != null) 
                    {
                        dd1 = obj_wrapppertax.ImputedAmount;
                    }
                    if ((obj.Total_Monthly_Reimbursement__c != null) && (obj.Total_Mileage__c != null) && (obj_irsrate.containsKey(String.valueOf(months[1])))) 
                    {
                        dd1 = dd1 + obj.Total_Monthly_Reimbursement__c - ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                    }
                    Decimal ddf2 = Decimal.valueOf(dd1);
                    dd1 = ddf2.setScale(2);
                    obj_wrapppertax.ImputedAmount = dd1;
                    obj_currentcontactwise_tax1.put(3,obj_wrapppertax);
				}
				if(obj_currentcontactwise_tax.containsKey(4))
				{
					wrapppertax obj_wrapppertax = obj_currentcontactwise_tax.get(4);
                    if ((obj_wrapppertax.Mileages != null))
                    {
                        Double dd = obj_wrapppertax.Mileages;
                        if (obj.Total_Mileage__c != null) 
                        {
                            dd = dd + obj.Total_Mileage__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Mileages = dd;
                    } 
                    else 
                    {
                        if (obj.Total_Mileage__c != null) 
                        {
                            obj_wrapppertax.Mileages = obj.Total_Mileage__c.setScale(2);
                        }
                    }
                    if ((obj_wrapppertax.Reimbursements != null)) 
                    {
                        Double dd = obj_wrapppertax.Reimbursements;
                        if (obj.Total_Monthly_Reimbursement__c != null) 
                        {
                            dd = dd + obj.Total_Monthly_Reimbursement__c;
                        }
                        Decimal ddf = Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        obj_wrapppertax.Reimbursements = dd;
                    } 
                    else 
                    {
                        if (obj.Total_Monthly_Reimbursement__c != null) 
                        {
                            obj_wrapppertax.Reimbursements = obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                    }
                    if ((obj_wrapppertax.MaxIRSrate != null)) 
                    {
                        Decimal dd = obj_wrapppertax.MaxIRSrate;
                        if (obj_irsrate.containsKey(String.valueOf(months[1])) && (obj.Total_Mileage__c != null)) 
                        {
                            dd = dd + (((obj.Total_Mileage__c) * (obj_irsrate.get(String.valueOf(months[1])))));
                        }
                        dd = dd.setScale(2);
                        obj_wrapppertax.MaxIRSrate = dd;
                    } 
                    else 
                    {
                        if ((obj.Total_Mileage__c != null) && obj_irsrate.containsKey(String.valueOf(months[1]))) 
                        {
                            obj_wrapppertax.MaxIRSrate = ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                        }
                    }
                    Double dd1 = 0;
                    if (obj_wrapppertax.ImputedAmount != null) 
                    {
                        dd1 = obj_wrapppertax.ImputedAmount;
                    }
                    if ((obj.Total_Monthly_Reimbursement__c != null) && (obj.Total_Mileage__c != null) && (obj_irsrate.containsKey(String.valueOf(months[1])))) 
                    {
                        dd1 = dd1 + obj.Total_Monthly_Reimbursement__c - ((obj.Total_Mileage__c) * obj_irsrate.get(String.valueOf(months[1])));
                    }
                    Decimal ddf2 = Decimal.valueOf(dd1);
                    dd1 = ddf2.setScale(2);
                    obj_wrapppertax.ImputedAmount = dd1;
                    obj_currentcontactwise_tax1.put(4,obj_wrapppertax);
				}
    		}
    	}
    	wrapppertax wrapppertax1 = new wrapppertax();
    	wrapppertax wrapppertax2 = new wrapppertax();
    	wrapppertax wrapppertax3 = new wrapppertax();
    	wrapppertax wrapppertax4 = new wrapppertax();
    	Boolean flag = false;
    	Double totalmileages =0;
    	List<wrapppertax> wrapppertaxList = new List<wrapppertax>();
    	if (obj_currentcontactwise_tax1.containsKey(1)) 
    	{
            if (obj_currentcontactwise_tax1.get(1).Mileages != null) 
            {
                totalmileages = obj_currentcontactwise_tax1.get(1).Mileages;
            }
            if (totalmileages > obj_currentcontactwise_tax1.get(1).TaxThreshold) 
            {
                wrapppertax1 = obj_currentcontactwise_tax1.get(1);
                wrapppertax1.ImputedAmount = 0;
                obj_currentcontactwise_tax1.put(1, wrapppertax1);                
                flag = true;
            }
            else
            {
            	flag = false;
            }
            wrapppertaxList.add(wrapppertax1);
            //taxCalculation_conid_wrappaertax_map.put(contactid,wrapppertax1);
            emailboolean.put(contactid,flag);
        }
        if (obj_currentcontactwise_tax1.containsKey(2)) 
        {               
            if (obj_currentcontactwise_tax1.get(2).Mileages != null) 
            {
                totalmileages = totalmileages + obj_currentcontactwise_tax1.get(2).Mileages;
            }
            if(obj_currentcontactwise_tax1.containsKey(1)){
            	
            	if (totalmileages > (obj_currentcontactwise_tax1.get(1).TaxThreshold + obj_currentcontactwise_tax1.get(2).TaxThreshold)) 
	            {

	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                wrapppertax2.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            else
            {
            	if (totalmileages > obj_currentcontactwise_tax1.get(2).TaxThreshold) 
	            {
	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                wrapppertax2.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            wrapppertaxList.add(wrapppertax1);
            //taxCalculation_conid_wrappaertax_map.put(contactid,wrapppertax2);
        }
        if (obj_currentcontactwise_tax1.containsKey(3)) 
        {               
            if (obj_currentcontactwise_tax1.get(3).Mileages != null) 
            {
                totalmileages = totalmileages + obj_currentcontactwise_tax1.get(3).Mileages;
            }
            if(obj_currentcontactwise_tax1.containsKey(1) && obj_currentcontactwise_tax1.containsKey(2))
            {
            	if (totalmileages > (obj_currentcontactwise_tax1.get(1).TaxThreshold + obj_currentcontactwise_tax1.get(2).TaxThreshold + obj_currentcontactwise_tax1.get(3).TaxThreshold)) 
	            {
	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                wrapppertax3.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            else if(obj_currentcontactwise_tax1.containsKey(1))
            {
            	if (totalmileages > (obj_currentcontactwise_tax1.get(1).TaxThreshold + obj_currentcontactwise_tax1.get(3).TaxThreshold)) 
	            {
	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                wrapppertax3.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            else if(obj_currentcontactwise_tax1.containsKey(2))
            {
            	if (totalmileages > (obj_currentcontactwise_tax1.get(2).TaxThreshold + obj_currentcontactwise_tax1.get(3).TaxThreshold)) 
	            {
	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                wrapppertax3.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            wrapppertaxList.add(wrapppertax1);
	            //taxCalculation_conid_wrappaertax_map.put(contactid,wrapppertax3);
	            emailboolean.put(contactid,flag);
            }
            
        }
        if (obj_currentcontactwise_tax1.containsKey(4)) 
        {               
            if (obj_currentcontactwise_tax1.get(4).Mileages != null) 
            {
                totalmileages = totalmileages + obj_currentcontactwise_tax1.get(4).Mileages;
            }
            if(obj_currentcontactwise_tax1.containsKey(1) && obj_currentcontactwise_tax1.containsKey(2) && obj_currentcontactwise_tax1.containsKey(3)){
            	if (totalmileages > (obj_currentcontactwise_tax1.get(1).TaxThreshold + obj_currentcontactwise_tax1.get(2).TaxThreshold + obj_currentcontactwise_tax1.get(3).TaxThreshold + obj_currentcontactwise_tax1.get(4).TaxThreshold)) 
            	{
                    if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(3)) 
	                {
	                    wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                    wrapppertax3.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                }
	                wrapppertax4 = obj_currentcontactwise_tax1.get(4);
	                wrapppertax4.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(4, wrapppertax4);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            else if(obj_currentcontactwise_tax1.containsKey(1) && obj_currentcontactwise_tax1.containsKey(2)){
            	if (totalmileages > (obj_currentcontactwise_tax1.get(1).TaxThreshold + obj_currentcontactwise_tax1.get(2).TaxThreshold + obj_currentcontactwise_tax1.get(4).TaxThreshold)) 
            	{
            		if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(3)) 
	                {
	                    wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                    wrapppertax3.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                }
	                wrapppertax4 = obj_currentcontactwise_tax1.get(4);
	                wrapppertax4.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(4, wrapppertax4);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            else if((obj_currentcontactwise_tax1.containsKey(1)) && (obj_currentcontactwise_tax1.containsKey(3)))
            {
            	if (totalmileages > (obj_currentcontactwise_tax1.get(1).TaxThreshold + obj_currentcontactwise_tax1.get(3).TaxThreshold + obj_currentcontactwise_tax1.get(4).TaxThreshold)) 
            	{
	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(3)) 
	                {
	                    wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                    wrapppertax3.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                }
	                wrapppertax4 = obj_currentcontactwise_tax1.get(4);
	                wrapppertax4.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(4, wrapppertax4);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            else if((obj_currentcontactwise_tax1.containsKey(2)) && (obj_currentcontactwise_tax1.containsKey(3))){
            	if (totalmileages > (obj_currentcontactwise_tax1.get(2).TaxThreshold + obj_currentcontactwise_tax1.get(3).TaxThreshold + obj_currentcontactwise_tax1.get(4).TaxThreshold)) 
            	{
	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(3)) 
	                {
	                    wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                    wrapppertax3.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                }
	                wrapppertax4 = obj_currentcontactwise_tax1.get(4);
	                wrapppertax4.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(4, wrapppertax4);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            else
            {
            	if (totalmileages > obj_currentcontactwise_tax1.get(4).TaxThreshold) 
            	{
	                if (obj_currentcontactwise_tax1.containsKey(1)) 
	                {
	                    wrapppertax1 = obj_currentcontactwise_tax1.get(1);
	                    wrapppertax1.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(1, wrapppertax1);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(2)) 
	                {
	                    wrapppertax2 = obj_currentcontactwise_tax1.get(2);
	                    wrapppertax2.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(2, wrapppertax2);
	                }
	                if (obj_currentcontactwise_tax1.containsKey(3)) 
	                {
	                    wrapppertax3 = obj_currentcontactwise_tax1.get(3);
	                    wrapppertax3.ImputedAmount = 0;
	                    obj_currentcontactwise_tax1.put(3, wrapppertax3);
	                }
	                wrapppertax4 = obj_currentcontactwise_tax1.get(4);
	                wrapppertax4.ImputedAmount = 0;
	                obj_currentcontactwise_tax1.put(4, wrapppertax4);
	                flag = false;
	            }
	            else
	            {
	            	flag = true;
	            }
	            emailboolean.put(contactid,flag);
            }
            wrapppertaxList.add(wrapppertax1);
            //taxCalculation_conid_wrappaertax_map.put(contactid,wrapppertax4);
        }
        taxCalculation_conid_wrappaertax_map.put(contactid,wrapppertaxList);
        return emailboolean;
    }
    public static List<Employee_Reimbursement__c> getUnApprovedReimbursements(List<Employee_Reimbursement__c> listEmployeeReimbursement,String contactid)
    {
        List<Employee_Reimbursement__c> listEmployeeReimbursement1 = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c obj_current_Employee_Reimbursement :listEmployeeReimbursement)
        {
            if(obj_current_Employee_Reimbursement.Approved_Date__c==null && obj_current_Employee_Reimbursement.Status__c=='Pending' && obj_current_Employee_Reimbursement.Contact_Id__c == contactid)
            {
                listEmployeeReimbursement1.add(obj_current_Employee_Reimbursement);
            }
        }
        return listEmployeeReimbursement1;
    }
    public static List<Employee_Reimbursement__c> getApprovedReimbursements(List<Employee_Reimbursement__c> listEmployeeReimbursement,String contactid)
    {
        List<Employee_Reimbursement__c> listEmployeeReimbursement1 = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c obj_current_Employee_Reimbursement :listEmployeeReimbursement)
        {
            if(obj_current_Employee_Reimbursement.Approved_Date__c!=null && obj_current_Employee_Reimbursement.Status__c=='Approved' && obj_current_Employee_Reimbursement.Contact_Id__c == contactid)
            {
                listEmployeeReimbursement1.add(obj_current_Employee_Reimbursement);
            }
        }
        return listEmployeeReimbursement1;
    }
    global void finish(Database.BatchableContext BC) 
    {

    }

    public static Map<String,Double> getIrsMileageRate()
    {
        Map<String,Double> obj_irsrate = new Map<String,Double>();
        List<String> listofmonths = new List<String>();
        if(system.today().month()!=12)
        {
            listofmonths.add(String.valueOf((system.today().year())-1)); 
        }
        listofmonths.add(String.valueOf((system.today().year())));
        for(IRS_Mileage_Rate__c rate:[select id,year__c,IRS_Rate__c from IRS_Mileage_Rate__c where year__c =: listofmonths])
        {
            obj_irsrate.put(rate.year__c,Double.valueOf(rate.IRS_Rate__c));
        }
        return obj_irsrate;
    }
    public static List<Employee_Reimbursement__c> getAllReimbursements(List<String> contactIdForDriver, List<String> listcomplincemonth)
    {
        List<Employee_Reimbursement__c> listEmployeeReimbursement = new List<Employee_Reimbursement__c>();
        if(Test.isRunningTest()) 
        {
            
        listEmployeeReimbursement = [SELECT id, Total_Mileage__c,
                                     Total_Monthly_Reimbursement__c, Contact_Id__c,
                                     Contact_Id__r.Name, Contact_Id__r.Employee_ID__c,Contact_Id__r.Deactivated_Date__c,
                                     Contact_Id__r.External_Email__c, Month__c, Approved_Date__c,Status__c,Contact_Id__r.CreatedDate
                                     FROM Employee_Reimbursement__c
                                     WHERE Contact_Id__c = : contactIdForDriver];
            
        }
        else            
        {
            listEmployeeReimbursement = [SELECT id, Total_Mileage__c,
                                     Total_Monthly_Reimbursement__c, Contact_Id__c,
                                     Contact_Id__r.Name, Contact_Id__r.Employee_ID__c,Contact_Id__r.Deactivated_Date__c,
                                     Contact_Id__r.External_Email__c, Month__c, Approved_Date__c,Status__c,Contact_Id__r.CreatedDate
                                     FROM Employee_Reimbursement__c
                                     WHERE Contact_Id__c = : contactIdForDriver
                                             AND Month__c = :listcomplincemonth];
        }

        return listEmployeeReimbursement;
    }
    public static List<String> getAllMonths()
    {
        List<String> listcomplincemonth =  new List<String>();
        Integer month = system.today().month();
        if (month == 12) 
        {
            listcomplincemonth.add(String.valueOf(month) + '-' + system.today().year());
        } 
        else 
        {
            listcomplincemonth.add(String.valueOf(12) + '-' + (system.today().year() - 1));
            for (Integer i = 1; i <= month; i++) 
            {
                if (i < 10) 
                {
                    listcomplincemonth.add('0' + String.valueOf(i) + '-' + system.today().year());
                } 
                else if ((i == 10) || (i == 11)) 
                {
                    listcomplincemonth.add(String.valueOf(i) + '-' + (system.today().year()));
                }
            }
        }
        return listcomplincemonth;
    }
    global string htmlReplaceText(string htmlvalue,string toReplace,string actualValue)
    {
        if(htmlvalue.contains(toReplace) && (actualValue!=null))
        {
            htmlvalue = htmlvalue.replace(toReplace,actualValue);
        }
        return htmlvalue;   
    }
    global Messaging.singleEmailMessage buildemail(List<String> toAddresses,String subject,String html)
    {
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
        mail.setOrgWideEmailAddressId(owea.get(0).Id);                   
        mail.setToAddresses(toAddresses);        
        mail.setSubject(subject);
        mail.setHtmlBody(html);
    //    mail.setBCCAddresses(new string[]{'minkesh.patel@getoncrm.com','natavar.goc@gmail.com'});
        return mail;
    }
    public class wrapppertax {
        public String contactid {get; set;}
        public integer quarterno {get; set;}
        public Double Mileages {get; set;}
        public Double Reimbursements {get; set;}
        public Double MaxIRSrate {get; set;}
        public Double ImputedAmount {get; set;}
        public Double TaxThreshold {get; set;}
        public List<Integer> taxCalulationMonths {get; set;}
        public wrapppertax() {
            this.contactid = null;
            this.quarterno = null;
            this.Mileages = null;
            this.Reimbursements = null;
            this.MaxIRSrate = null;
            this.ImputedAmount = null;
            this.TaxThreshold = null;
            this.taxCalulationMonths = null;
        }   
    }
}