global class SendActivaitonEmailToDriver implements Database.Batchable<sObject>, Database.Stateful {
    List<EmailTemplate> emailTemplate; 
    public List<Contact> obj_contact_list;
    public OrgWideEmailAddress[] owea;
    public SendActivaitonEmailToDriver() {
        emailTemplate = [SELECT Id, Body, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Notifiation_For_Activation' LIMIT 1];
        owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address =:'driverservices@mburse.com'];
        Date nextWeek = system.today().addDays(2); 
        if(!Test.isRunningTest()) {
            obj_contact_list = [SELECT Id, Role__c, Activation_Date__c,
                                        External_Email__c, FirstName, Added_Date__c
                                    FROM Contact 
                                    WHERE (Role__c ='Driver' 
                                            OR Role__c = 'Driver/Manager' 
                                            OR Role__c =: StaticValues.roleAdminDriver) and Activation_Date__c =: system.today().addDays(2) ];
            
        } else {
            obj_contact_list = [SELECT Id, Role__c, Activation_Date__c,
                                        External_Email__c, FirstName, Added_Date__c
                                    FROM Contact 
                                    WHERE (Role__c ='Driver' 
                                            OR Role__c = 'Driver/Manager' 
                                            OR Role__c =: StaticValues.roleAdminDriver) LIMIT 5 ];
        }
    }

    global List<Contact> start(Database.BatchableContext BC) {
        return obj_contact_list;
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        for(Contact c : scope) {
            mail = new Messaging.SingleEmailMessage();
            SendEmailToMe__c  objSendEmailToMe = SendEmailToMe__c.getValues('SendActivaitonEmailToDriver');
            List<String> address = new List<String>();
            if(objSendEmailToMe.Send_email_to_me__c == true)
            {
                //address.add('sanket.goswami@getoncrm.com');
                //address.add(c.External_Email__c);
                mail.setBCCAddresses(new string[]{'driverservices@mburse.com'});                    
            }
            else
            {
                address.add(c.External_Email__c);
                //mail.setBCCAddresses(new string[]{'minkeshp@askemc.com','driverservices@mburse.com'});
            }                
            mail.setToAddresses(address);
            mail.setSubject(emailTemplate[0].Subject);
            String newemailBody = emailTemplate[0].HtmlValue;
            Date todayDate = system.today().addDays(2);
            newemailBody = newemailBody.replace('{!Contact.Name}', c.FirstName);
            if(c.Added_Date__c != null) {
                Date addedDate = c.Added_Date__c;
                newemailBody = newemailBody.replace('{!DateAdded}', addedDate.month()+'/'+addedDate.day()+'/'+addedDate.year());
            }
            newemailBody = newemailBody.replace('{!ActivationDate}', todayDate.month()+'/'+todayDate.day()+'/'+todayDate.year());
            
            newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
            mail.setPlainTextBody(newemailBody);
            mail.setHtmlBody(newemailBody);
            mail_list.add(mail);
        }
        SendEmail__c  objSendEmail = SendEmail__c.getValues('SendActivaitonEmailToDriver');
        if(!mail_list.isEmpty()  &&(objSendEmail!=null) && (objSendEmail.Send_email_from_code__c==true) && !Test.isRunningTest())  {
            Messaging.sendEmail(mail_list);   
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}