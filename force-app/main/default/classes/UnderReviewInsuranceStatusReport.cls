public with sharing class UnderReviewInsuranceStatusReport implements Schedulable {
    public void execute(SchedulableContext sc) {
        Sendreport();
    }
    public static void sendReport() {
        try {
            String subject = 'Under Review Insurance Status Report';
            String htmlBody = 'Please find the attached Under Review Insurance Status employee report in CSV format.';
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'driverservices@mburse.com'];
            
            List<Contact> contacts = [
                SELECT Id, Name, Email, Insurance__c, Insurance_Upload_Date__c, Account.Name 
                FROM Contact 
                WHERE Insurance__c = 'Under Review' 
                AND Deactivated_Date__c = null 
                AND Account.isUsingTriplog__c = true 
                AND AccountId != '0010Z00001ygUenQAE'
            ];

            if (contacts.isEmpty()) {
                System.debug('No contacts found with Insurance status Under Review.');
                return;
            }

            String csv = 'Id,Name,Email,Account Name,Insurance Status,Upload Date\n';
            for (Contact con : [select id,Name,Email,Insurance__c,Insurance_Upload_Date__c,Account.Name from contact where Insurance__c='Under Review'   and Deactivated_Date__c =null and Account.isUsingTriplog__c =true and AccountId !='0010Z00001ygUenQAE']) {
                csv += Con.ID + ',' + Con.Name +',' + Con.Email +',' + Con.Account.Name +',' + Con.Insurance__c +',' + Con.Insurance_Upload_Date__c + '\n';
            }

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(Blob.valueOf(csv));
            attachment.setFileName('UnderReviewInsuranceStatusReport.csv');

            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
            
            if (!owea.isEmpty()) {
                email.setOrgWideEmailAddressId(owea[0].Id);
            }

            String toAddresses = Label.UnderReviewInsuranceToEmails;
            if (!String.isEmpty(toAddresses)) {
                email.setToAddresses(toAddresses.split(','));
            }

            String bccEmail = Label.DeveloperBCCToEmail;
            if (!String.isEmpty(bccEmail)) {
                email.setBccAddresses(bccEmail.split(','));
            }

            email.setSubject(subject);
            email.setHTMLBody(htmlBody);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    System.debug('Failed to send email: ' + result.getErrors()[0].getMessage());
                } else {
                    System.debug('Email sent successfully.');
                }
            }

        } catch (EmailException e) {
            System.debug('EmailException occurred: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('An unexpected error occurred: ' + e.getMessage());
        }
    }
}