global class SendMileageReminderforDelta implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

    public List<String> accountList { get; set; }
    public List<EmailTemplate> emailTemplate;
    public String emailTemplateDeveloperName;

    // Default Constructor
    public SendMileageReminderforDelta() {
        this(Label.Delta_Account_Name, 'Monthly_mileage_reminder_New');
    }

    // Parameterized Constructor
    public SendMileageReminderforDelta(String accountNames, String emailTemplateName) {
        this.emailTemplateDeveloperName = emailTemplateName;
        System.debug('Email Template: ' + this.emailTemplateDeveloperName);
        this.accountList = new List<String>();
        if (accountNames != null) {
            this.accountList = accountNames.split(',');
        }
        System.debug('Account Names: ' + this.accountList);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Account List: ' + this.accountList);
        String query = 'SELECT Id, FirstName, External_Email__c, Role__c, AccountId ' +
                       'FROM Contact ' +
                       'WHERE Account.Name IN :accountList ' +
                       'AND (Role__c IN (\'Driver\', \'Driver/Manager\', \'' + StaticValues.roleAdminDriver + '\', \'Admin\')) ' +
                       'AND Account.isUsingTriplog__c = true ' +
                       'AND (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:30)';
        System.debug('Query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        emailTemplate = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = :emailTemplateDeveloperName];
        List<Attachment> attachments = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId = :emailTemplate[0].Id];
        OrgWideEmailAddress[] owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'driverservices@mburse.com'];
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        SendEmailonDeactivation__c customSettings = SendEmailonDeactivation__c.getValues('SendMileageReminderforDelta');

        for (Contact currentContact : (List<Contact>)scope) {
            try {
                Messaging.SingleEmailMessage mail = createEmailMessage(currentContact, customSettings, owea, attachments);
                if (mail != null) {
                    singleEmailMessageList.add(mail);
                }
            } catch (Exception e) {
                System.debug('Error creating email message: ' + e.getMessage());
            }
        }
        system.debug('should send '+shouldSendEmail(singleEmailMessageList));
        if (shouldSendEmail(singleEmailMessageList)) {
            System.debug('inside should send ');
            Messaging.sendEmail(singleEmailMessageList);
        }
    }

    private Messaging.SingleEmailMessage createEmailMessage(Contact currentContact, SendEmailonDeactivation__c customSettings, OrgWideEmailAddress[] owea, List<Attachment> attachments) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = getToAddresses(currentContact, customSettings);
        List<String> bccAddresses = getBccAddresses(customSettings);

        if (toAddresses.isEmpty()) {
            return null;
        }

        mail.setToAddresses(toAddresses);
        if (!bccAddresses.isEmpty()) {
            mail.setBccAddresses(bccAddresses);
        }

        mail.setSubject(emailTemplate[0].Subject);
        String htmlBody = personalizeEmailBody(currentContact, emailTemplate[0].HTMLValue);
        mail.setPlainTextBody(htmlBody);
        mail.setHtmlBody(htmlBody);

        if (!owea.isEmpty()) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }

        if (!attachments.isEmpty()) {
            List<Messaging.EmailFileAttachment> fileAttachments = createFileAttachments(attachments);
            mail.setFileAttachments(fileAttachments);
        }

        return mail;
    }

    private List<String> getToAddresses(Contact currentContact, SendEmailonDeactivation__c customSettings) {
        List<String> toAddresses = new List<String>();
        if (customSettings != null && customSettings.Send_to_Driver__c && currentContact.External_Email__c != null) {
            toAddresses.add(currentContact.External_Email__c);
        }
        return toAddresses;
    }

    private List<String> getBccAddresses(SendEmailonDeactivation__c customSettings) {
        List<String> bccAddresses = new List<String>();
        if (customSettings != null && customSettings.BCCEmailaddresses__c != null) {
            if (customSettings.BCCEmailaddresses__c.contains(',')) {
                bccAddresses.addAll(customSettings.BCCEmailaddresses__c.split(','));
            } else {
                bccAddresses.add(customSettings.BCCEmailaddresses__c);
            }
        }
        return bccAddresses;
    }

    private String personalizeEmailBody(Contact currentContact, String emailBody) {
        DateTime currentDate = DateTime.now();
        String monthString = currentDate.format('MMMM');
        String yearString = String.valueOf(currentDate.year());

        emailBody = emailBody.replace('{!CurrentMonth}', monthString);
        emailBody = emailBody.replace('{!CurrentYear}', yearString);

        if (currentContact.FirstName != null) {
            emailBody = emailBody.replace('{!Contact.FirstName}', currentContact.FirstName);
        } else {
            emailBody = emailBody.replace('{!Contact.FirstName}', '');
        }

        return emailBody;
    }

    private List<Messaging.EmailFileAttachment> createFileAttachments(List<Attachment> attachments) {
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        for (Attachment attachment : attachments) {
            Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
            fileAttachment.setFileName(attachment.Name);
            fileAttachment.setBody(attachment.Body);
            fileAttachment.setContentType(attachment.ContentType);
            fileAttachments.add(fileAttachment);
        }
        return fileAttachments;
    }

    private Boolean shouldSendEmail(List<Messaging.SingleEmailMessage> emailMessages) {
        SendEmail__c sendEmailObj = SendEmail__c.getValues('SendMileageReminderforDelta');
        return (sendEmailObj != null && sendEmailObj.Send_email_from_code__c && !emailMessages.isEmpty() && !Test.isRunningTest());
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch job finished.');
    }
    global void execute(SchedulableContext sc) { 
        SendMileageReminderforDelta sendBatch = new SendMileageReminderforDelta();
        database.executebatch(sendBatch,1);
        SendMileageReminderforDelta sendBatch1 = new SendMileageReminderforDelta('Eastern Controls','MonthlyMileageReminderEasternControls');
        database.executebatch(sendBatch1,1);
    }
}