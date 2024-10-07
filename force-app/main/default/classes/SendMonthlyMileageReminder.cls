global class SendMonthlyMileageReminder implements Database.batchable<sObject>,Database.Stateful {

   
    public Map<String,List<String>> accountidEmails {get;set;}
    public SendMonthlyMileageReminder()
    {
        
        accountidEmails = new Map<String,List<String>>();
       /* String query = 'select Id, External_Email__c,Role__c,AccountId FROM Contact WHERE Account.Name = ' +'\'' + Label.Community_Account_Name + '\'' +' AND (Role__c = \'Admin\') AND (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:30)';
        for(Contact currentContact : (List<Contact>)Database.query(query))
        {
            if(accountidEmails.size()>0 && accountidEmails.containsKey(currentContact.AccountId))
            {
                List<String> accountEmailAddressList = accountidEmails.get(currentContact.AccountId);
                accountEmailAddressList.add(currentContact.External_Email__c);
                accountidEmails.put(currentContact.AccountId,accountEmailAddressList);
            }
            else {
                List<String> accountEmailAddressList = new List<String>();
                accountEmailAddressList.add(currentContact.External_Email__c);
                accountidEmails.put(currentContact.AccountId,accountEmailAddressList);
            }
        }*/

    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       String query = 'select Id,FirstName, External_Email__c,Role__c,AccountId FROM Contact WHERE Account.Name = ' +'\'' + Label.Community_Account_Name + '\'' +' AND (Role__c = \'Driver\' OR Role__c = \'Driver/Manager\' OR Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Admin\') AND ( Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:30  )';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    
    List<EmailTemplate> emailTemplate = new List<EmailTemplate>([SELECT Id, Subject, body from EmailTemplate WHERE developerName = 'Monthly_Mileage_Reminder']);
    OrgWideEmailAddress[] owea = [select Id ,address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
    List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
    SendEmailonDeactivation__c customSettings = SendEmailonDeactivation__c.getValues('SendMonthlyMileageReminder');  
        for(Contact currentContact : (List<Contact>)scope) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> myEmail = new List<String>();
            List<String> bccEmailaddress = new List<String>();  
            if(customSettings!=null && customSettings.Send_to_Driver__c == true && currentContact.External_Email__c != null){
                myEmail.add(currentContact.External_Email__c);
                mail.setToAddresses(myEmail);
                
                if(customSettings.BCCEmailaddresses__c!=null && customSettings.BCCEmailaddresses__c.contains(',')){
                    bccEmailaddress.addAll(customSettings.BCCEmailaddresses__c.split(','));
                }
                else if(customSettings.BCCEmailaddresses__c!=null) {
                    bccEmailaddress.add(customSettings.BCCEmailaddresses__c);
                }
            }
            else {
                if(customSettings.BCCEmailaddresses__c!=null && customSettings.BCCEmailaddresses__c.contains(',')){
                    myEmail.addAll(customSettings.BCCEmailaddresses__c.split(','));
                    mail.setToAddresses(myEmail);
                }
                else if(customSettings.BCCEmailaddresses__c!=null) {
                    myEmail.add(customSettings.BCCEmailaddresses__c);
                    mail.setToAddresses(myEmail);
                }
               
                
            }
            //myEmail.add(currentContact.External_Email__c);
            //mail.setToAddresses(myEmail);
            mail.setSubject(emailTemplate[0].Subject);
            if(emailTemplate[0].Body.contains('{!Contact.FirstName}') ){
                emailTemplate[0].Body = emailTemplate[0].Body.replace('{!Contact.FirstName}', currentContact.FirstName);
            }
            mail.setPlainTextBody(emailTemplate[0].Body); 
                  
            /*if(accountidEmails.containsKey(currentContact.AccountId))
            {       
                bccEmailaddress.addAll(accountidEmails.get(currentContact.AccountId));
                  
            }*/
            // if(label.Email_To_Address.contains(','))
            // {
            //     bccEmailaddress.addAll(label.Email_To_Address.split(','));
            // } 
            if(bccEmailaddress.size()>0)
            {
                mail.setBccAddresses(bccEmailaddress);     
            }            
            if (owea.size() > 0 ) 
            {
               mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            if(myEmail.size()>0)
            {
                singleEmailMessageList.add(mail);
            }
            
        }  
        SendEmail__c  sendEmailObj = SendEmail__c.getValues('SendMonthlyMileageReminder');
        if((sendEmailObj!=null) && sendEmailObj.Send_email_from_code__c==true && singleEmailMessageList.size()>0 && !Test.isRunningTest())
        {
            Messaging.sendEmail(singleEmailMessageList);  
        }     
    }    
   
    global void finish(Database.BatchableContext BC) {
        
    }
}