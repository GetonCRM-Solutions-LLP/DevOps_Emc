@isTest
public class ScheduleDailyEmailforUploadDocumentsTest {
   @isTest
    public static void testMethod1(){
        
         SendEmail__c  objSendEmail = new SendEmail__c();
        objSendEmail.Name = 'Send Email For Compliance';
        objSendEmail.Send_email_from_code__c = true;
        insert objSendEmail;
        
         TriggerConfig__c cs = new TriggerConfig__c();
        cs.ContactTriggersendEmailForNewContact__c=true;
        cs.Name = 'Defaulttrigger';
     	insert cs;
        
        
        Account acc = new Account();
        acc.Name = 'Ermi';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.firstName = 'test';
        con.lastName = 'Method';
        con.External_Email__c = 'Test@gmail.com';
        insert con;
                
        Attachment att = new attachment();
        att.name = 'test attachement';
        att.ParentId = con.Id;
        att.Body = blob.valueOf('/services/data/v48.0/sobjects/Attachment/00P3r00001NBiqPEAT/Body');
        insert att;
        
         SendEmail__c  mail = new SendEmail__c();
        mail.Send_email_from_code__c = false;
        mail.Name = 'Send Daily Uploaded Documnet';
        insert mail;
        
        Test.startTest();
        ScheduleDailyEmailforUploadDocuments scheDoc = new ScheduleDailyEmailforUploadDocuments();
        scheDoc.execute(null);
        Test.stopTest();
    }
}