public with sharing class InsuranceWorkflowEmailsBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    private List<String> accountNames;
    private static final String BCC_EMAIL = Label.DeveloperBCCToEmail;
    private static final String ADMIN_TEMPLATE_NAME = 'InsuranceExpirationEmailForAdmin';
    private static final String DRIVER_TEMPLATE_NAME = 'InsuranceExpirationEmailForDriver';
    private static final String EXPIRED_DRIVER_TEMPLATE_NAME = 'InsuranceExpirationEmailForExpiredDriver';
    private static final String DRIVER_SERVICES_EMAIL = 'driverservices@mburse.com';
    
    public InsuranceWorkflowEmailsBatch(List<String> accountNames) {
        this.accountNames = accountNames;
    }
    
    public InsuranceWorkflowEmailsBatch() {
        this(null);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name FROM Account WHERE isUsingTriplog__c = true AND Triplog_API__c != null';
        if (this.accountNames != null && !this.accountNames.isEmpty()) {
            query += ' AND Name IN :accountNames';
        }
        query += ' ORDER BY Name ASC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Message__c> msgList = new List<Message__c>();
        List<String> accountIds = new List<String>();
        
        for (Account acc : (List<Account>) scope) {
            accountIds.add(acc.Id);
        }
        
        List<Contact> adminList = [SELECT Id, Email, FirstName FROM Contact WHERE AccountId IN :accountIds AND Deactivated_Date__c = null AND (Role__c IN ('Admin', 'Driver/Admin')) AND FirstName != null];
        List<Contact> driverList = [SELECT Id, Email, FirstName, Name, Expiration_Date__c FROM Contact WHERE AccountId IN :accountIds AND Deactivated_Date__c = null AND (Role__c IN ('Driver', 'Driver/Admin', 'Driver/Manager')) AND Expiration_Date__c = NEXT_MONTH AND FirstName != null];
        List<Contact> expiredDriverList = [SELECT Id, Email, FirstName, Name, Expiration_Date__c FROM Contact WHERE AccountId IN :accountIds AND Deactivated_Date__c = null AND (Role__c IN ('Driver', 'Driver/Admin', 'Driver/Manager')) AND Expiration_Date__c = THIS_MONTH AND FirstName != null];
        

        EmailTemplate adminTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = :ADMIN_TEMPLATE_NAME LIMIT 1];
        EmailTemplate driverTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = :DRIVER_TEMPLATE_NAME LIMIT 1];
        EmailTemplate expiredDriverTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = :EXPIRED_DRIVER_TEMPLATE_NAME LIMIT 1];
        
        sendAdminEmails(adminList, driverList, adminTemplate, mailList, msgList);
        sendDriverEmails(driverList, driverTemplate, mailList, msgList);
        sendExpiredDriverEmails(expiredDriverList, expiredDriverTemplate, mailList, msgList);
        
        if (!mailList.isEmpty()) {
            Messaging.sendEmail(mailList);
        }
        
        try {
            List<Database.SaveResult> results = Database.insert(msgList, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error error : result.getErrors()) {
                        System.debug('Error: ' + error.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
    private void sendAdminEmails(List<Contact> adminList, List<Contact> driverList, EmailTemplate adminTemplate, List<Messaging.SingleEmailMessage> mailList, List<Message__c> msgList) {
        if (adminList.isEmpty() || driverList.isEmpty()) return;
        
        for (Contact admin : adminList) {
            String newEmailBody = adminTemplate.HtmlValue;
            String emailDetailsToBeAdded = buildDriverDetailsTable(driverList);
            
            newEmailBody = newEmailBody.replace('Table', emailDetailsToBeAdded);
            newEmailBody = newEmailBody.replace('{!Contact.FirstName}', admin.FirstName);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> { admin.Email });
            setCommonEmailProperties(mail, adminTemplate.Subject, newEmailBody);
            mailList.add(mail);
            
            Message__c newMessage = new Message__c();
            newMessage.Notification_Message__c = 'Employees with expiring insurance have been notified. Visit the tools page for a complete list.';
            newMessage.Unread__c = true;
            newMessage.Contacts__c = admin.Id;
            msgList.add(newMessage);
        }
    }
    
    private void sendDriverEmails(List<Contact> driverList, EmailTemplate driverTemplate, List<Messaging.SingleEmailMessage> mailList, List<Message__c> msgList) {
        if (driverList.isEmpty()) return;
        
        for (Contact driver : driverList) {
            String emailBody = driverTemplate.HtmlValue;
            emailBody = emailBody.replace('{!Contact.FirstName}', driver.FirstName);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> { driver.Email });
            setCommonEmailProperties(mail, driverTemplate.Subject, emailBody);
            mailList.add(mail);
            
            Message__c newMessage = new Message__c();
            newMessage.Notification_Message__c = 'Reminder, provide your proof of valid auto insurance within two weeks to avoid forfeiting your car allowance.';
            newMessage.Unread__c = true;
            newMessage.Contacts__c = driver.Id;
            msgList.add(newMessage);
        }
    }
    
    private void sendExpiredDriverEmails(List<Contact> expiredDriverList, EmailTemplate expiredDriverTemplate, List<Messaging.SingleEmailMessage> mailList, List<Message__c> msgList) {
        if (expiredDriverList.isEmpty()) return;
        
        for (Contact driver : expiredDriverList) {
            String emailBody = expiredDriverTemplate.HtmlValue;
            emailBody = emailBody.replace('{!Contact.FirstName}', driver.FirstName);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> { driver.Email });
            setCommonEmailProperties(mail, expiredDriverTemplate.Subject, emailBody);
            mailList.add(mail);
            
            Message__c newMessage = new Message__c();
            newMessage.Notification_Message__c = 'You will forfeit your car allowance unless you provide proof of valid auto insurance immediately.';
            newMessage.Unread__c = true;
            newMessage.Contacts__c = driver.Id;
            msgList.add(newMessage);
        }
    }
    
    private String buildDriverDetailsTable(List<Contact> driverList) {
        String emailDetailsToBeAdded = '';
        emailDetailsToBeAdded += '<div style="margin: auto; width: 50%; text-align: center;">';
        emailDetailsToBeAdded += '<table style="width: 100%; border-collapse: collapse; border: 1px solid black;">';
        emailDetailsToBeAdded += '<tr>';
        emailDetailsToBeAdded += '<th style="border-collapse: collapse; border: 1px solid black; padding: 8px; font-size: 14px; font-family: \'Calibri\',sans-serif;">Driver Name</th>';
        emailDetailsToBeAdded += '<th style="border-collapse: collapse; border: 1px solid black; padding: 8px; font-size: 14px; font-family: \'Calibri\',sans-serif;">Email Address</th>';
        emailDetailsToBeAdded += '<th style="border-collapse: collapse; border: 1px solid black; padding: 8px; font-size: 14px; font-family: \'Calibri\',sans-serif;">Insurance Expiration Date</th>';
        emailDetailsToBeAdded += '</tr>';
        
        for (Contact record : driverList) {
            emailDetailsToBeAdded += '<tr>';
            emailDetailsToBeAdded += '<td style="border-collapse: collapse; border: 1px solid black; padding: 8px; font-size: 14px; font-family: \'Calibri\',sans-serif;">' + record.Name + '</td>';
            emailDetailsToBeAdded += '<td style="border-collapse: collapse; border: 1px solid black; padding: 8px; font-size: 14px; font-family: \'Calibri\',sans-serif;">' + record.Email + '</td>';
            emailDetailsToBeAdded += '<td style="border-collapse: collapse; border: 1px solid black; padding: 8px; font-size: 14px; font-family: \'Calibri\',sans-serif;">' + record.Expiration_Date__c.format() + '</td>';
            emailDetailsToBeAdded += '</tr>';
        }
        
        emailDetailsToBeAdded += '</table></div>';
        return emailDetailsToBeAdded;
    }
    
    private void setCommonEmailProperties(Messaging.SingleEmailMessage mail, String subject, String htmlBody) {
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        if (!String.isEmpty(BCC_EMAIL)) {
            mail.setBccAddresses(BCC_EMAIL.split(','));
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing finished.');
    }
    
    public void execute(SchedulableContext sc) {
        InsuranceWorkflowEmailsBatch batch = new InsuranceWorkflowEmailsBatch();
        Database.executeBatch(batch, 1);
    }
}