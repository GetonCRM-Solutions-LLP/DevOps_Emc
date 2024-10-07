public with sharing class FAVRReport implements Schedulable {
   public void execute(SchedulableContext sc) {
        Sendreport();
    }
    public Static void Sendreport() {
        try {
            String Subject;
            String htmlbody;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            String csv = 'Id,Name,Email,Account Name,Vehicle Type\n';
            for (Contact con : [SELECT id, Name, Email, Account.Name, Vehicle_Type__c FROM contact WHERE Deactivated_Date__c = NULL AND Reimbursement_Type__c = 'FAVR'  AND Account.isUsingTriplog__c = TRUE  AND Fixed_Amount__c = NULL  AND AccountId != '0010Z00001ygUenQAE'  AND Role__c != 'Admin'  AND Role__c != 'Manager'   AND (NOT Vehicle_Type__c  LIKE '%Mileage Rate%')]) {
                csv += Con.ID + ',' + Con.Name +',' + Con.Email +',' + Con.Account.Name +',' + Con.Vehicle_Type__c + '\n';
            }
            attach.setBody(blob.valueOf(csv));
            attach.setFileName('FAVR Report.Csv');
            Subject = 'FAVR Report';
            htmlbody = 'Please find the attach FAVR Driver Reprot for whom the Fixed Amount is null ';
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            String toEmail = 'willh@mburse.com';
            String[] toAddresses = new String[] {toEmail};
            email.setToAddresses(toAddresses);
            email.setSubject(Subject);
            email.setHTMLBody(htmlbody);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        } catch (Exception e ) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}