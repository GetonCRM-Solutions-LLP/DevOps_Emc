global class SendEmailToJanuary implements Database.Batchable<sObject>,Database.Stateful{
    public SendEmailToJanuary() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query;
        if(!Test.isRunningTest()){
            query = 'SELECT Name, Role__c, External_Email__c, FirstName FROM Contact WHERE (Role__c  = \'Driver\' OR Role__c  = \'Driver/Manager\' OR Role__c  = \'Driver/Admin\') AND Active__c = true AND Account.isUsingTriplog__c = true';
        }
        else {
            query = 'SELECT id,name,FirstName,External_Email__c FROM Contact';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        for(Contact conObj : (List<Contact>) scope)
        {
            sendMail(conObj.FirstName,conObj.External_Email__c);
        }
    }
    global void finish(Database.BatchableContext BC) 
    {

    }
    public void sendMail(String conName,String email) {
        List<Messaging.MassEmailMessage> mails = new List<Messaging.MassEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:'driverservices@mburse.com'];
        List<EmailTemplate> temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue FROM EmailTemplate 
                                                                WHERE DeveloperName = 'Send_Email_At_January']);
       
        Messaging.SingleEmailMessage mail;
        List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
        List<String> sendingTo = new List<String>();
        string htmlbody = '';
        mail = new Messaging.SingleEmailMessage();
        if (owea.size() > 0) 
        {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        sendingTo.add(email);
        mail.setToAddresses(sendingTo);
        mail.setSubject(temp[0].Subject);
        htmlbody = temp[0].HTMLValue;
        htmlbody = htmlbody.replace('{!Contact.FirstName}',conName);
        htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        mail.setPlainTextBody(htmlbody);
        List<String> bccaddress = new list<String>();
        bccaddress.add('driverservices@mburse.com');
        mail.setBccAddresses(bccaddress);
        mail.setHtmlBody(htmlbody);
        mail_list.add(mail);
        if(!mail_list.isEmpty() && !Test.IsRunningTest()){
            Messaging.sendEmail(mail_list);
        }
        
    }
}