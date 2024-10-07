Global class WelComeEmailforPLMarketing implements Database.Batchable<sObject>
{
    string accountId = System.Label.PL_Marketing;
    Global List<EmailTemplate> temp;
    Global OrgWideEmailAddress[] owea;
    global WelComeEmailforPLMarketing() {
         temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue 
                                         FROM EmailTemplate 
											WHERE DeveloperName = 'WelCome_Email_for_PLMarketing']);
         owea = [select Id from OrgWideEmailAddress where Address =:'driverservices@mburse.com'];
    } 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Name,FirstName,External_Email__c,Fixed_Amount__c from Contact WHERE AccountId =: accountId ';
        if(test.isRunningTest())
            query = 'select id,Name,FirstName,External_Email__c,Fixed_Amount__c from Contact';
        system.debug('query=='+query);  
        return Database.getQueryLocator(query);   
    }
    
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        system.debug('');
        List<Messaging.MassEmailMessage> mails = new List<Messaging.MassEmailMessage>(); 
        Messaging.SingleEmailMessage mail;
        List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
        for(Contact c: Scope) {
            c.Fixed_Amount__c = c.Fixed_Amount__c == null ? 0 : c.Fixed_Amount__c;
            system.debug('Fixed_Amount__c=='+c.Fixed_Amount__c);
            List<String> sendingTo = new List<String>();
            string htmlbody = '';
            mail = new Messaging.SingleEmailMessage();
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            sendingTo.add(c.External_Email__c);
            mail.setToAddresses(sendingTo);
            mail.setSubject(temp[0].Subject);
            htmlbody = temp[0].HTMLValue;
            htmlbody = htmlbody.replace('{!Contact.FirstName}', c.FirstName);
            htmlbody = htmlbody.replace('{!Contact.Fixed_Amount__c}', string.valueof(c.Fixed_Amount__c)); 
            htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
            mail.setPlainTextBody(htmlbody);
            List<String> bccaddress = new list<String>();
            //bccaddress.add('driverservices@mburse.com');
            //mail.setBccAddresses(bccaddress);
            mail.setHtmlBody(htmlbody);
            mail_list.add(mail);
            system.debug('mail_list');
        }
        if(mail_list.size()>0 && !Test.isRunningTest()){
            Messaging.sendEmail(mail_list);  
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }    
}