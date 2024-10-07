/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use to send email on 28 date to all the driver for check the trips on 4th date of month.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 02 July 2021 | Sanket Goswami
 * @description: 
 */
global class MileageNotificationForDrivers implements Database.batchable<sObject>,Database.Stateful{
    public List<String> listAccount {get;set;}
    public MileageNotificationForDrivers() {
        String accountName = Label.TripstobeLogged;
        listAccount = new List<String>();
        if(accountName != null) {
            listAccount = accountName.split(',');
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String  query;
        if(!Test.isRunningTest()){
            query = 'select Id, FirstName, External_Email__c,Role__c,AccountId FROM Contact WHERE Account.Name IN: listAccount AND (Role__c = \'Driver\' OR Role__c = \'Driver/Manager\' OR Role__c = \''+StaticValues.roleAdminDriver+'\') AND (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:30)';
        } else { 
            query = 'select Id, FirstName, External_Email__c,Role__c,AccountId FROM Contact LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>([SELECT Id, Subject, body from EmailTemplate WHERE developerName = 'Mileage_Notification_For_Drivers']);
        OrgWideEmailAddress[] owea = [select Id ,address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        SendEmailonDeactivation__c customSettings = SendEmailonDeactivation__c.getValues('SendMileageReminderforDelta');  
        for(Contact currentContact : (List<Contact>)scope) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> myEmail = new List<String>();
            List<String> bccEmailaddress = new List<String>();  
            //myEmail.add('sanket.goswami@getoncrm.com');
            if(customSettings!=null && customSettings.Send_to_Driver__c == true && currentContact.External_Email__c != null) {
                myEmail.add(currentContact.External_Email__c);
                mail.setToAddresses(myEmail);
                
                if(customSettings.BCCEmailaddresses__c!=null && customSettings.BCCEmailaddresses__c.contains(',')) {
                    bccEmailaddress.addAll(customSettings.BCCEmailaddresses__c.split(','));
                }
                else if(customSettings.BCCEmailaddresses__c!=null) {
                    bccEmailaddress.add(customSettings.BCCEmailaddresses__c);
                }
            }

            mail.setSubject(emailTemplate[0].Subject);
            if(emailTemplate[0].Body.contains('{!Contact.FirstName}') ){
                emailTemplate[0].Body = emailTemplate[0].Body.replace('{!Contact.FirstName}', currentContact.FirstName);
            }
            mail.setPlainTextBody(emailTemplate[0].Body); 
            if(bccEmailaddress.size()>0) {
                mail.setBccAddresses(bccEmailaddress);     
            }     
            if (owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            if(myEmail.size()>0) {
                singleEmailMessageList.add(mail);
            }
        }  
        SendEmail__c  sendEmailObj = SendEmail__c.getValues('SendMileageReminderforDelta');
        if((sendEmailObj!=null) && sendEmailObj.Send_email_from_code__c==true && singleEmailMessageList.size()>0 && !Test.isRunningTest())
        {
            Messaging.sendEmail(singleEmailMessageList);  
        }   
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}