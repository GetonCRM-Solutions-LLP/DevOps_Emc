public class ScheduleDailyEmailforUploadDocuments implements schedulable {
   
    List<Attachment> attachmentList;
    public void execute (SchedulableContext SC) {
        sendexcelfile();
    }
    public void sendexcelfile(){
        
        List<id> contactIds = new List<id>();
        for (Contact curr: [select id,name from contact where account.Name != 'test account'])
        contactIds.add(curr.id);

        attachmentList = [select id,name,Parent.name from Attachment where CreatedDate = TODAY and ParentId =: contactIds];
        
        if(!attachmentList.isEmpty()){
            string header ='Attachment Name'+'\t'+'UploadedBy'+ '\n';
            String finalstr = header;
        
                for(Attachment att : attachmentList){
                String Recordstring = att.name + '\t'+ att.Parent.name +'\n';
                finalstr = finalstr + Recordstring;
            }
            EmailTemplate templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Daily_Uploaded_Document' Limit 1];
            OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            blob excel = blob.valueOf(finalstr);
            attach.setBody(excel);
            attach.setFileName('Daily Documents Uploaded Report.xls');
            
            //string[] address = new string[]{System.label.JenniferCNCAEmail};
            Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
            String newemailBody = templateId.HtmlValue;
            newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
            newemailBody = newemailBody.replace('{contact.Name}',  'Perla');
            String[] sendingTo = new String[]{'willh@mburse.com'};
            String[] sendingToBccAdd = new String[]{'perlab@mburse.com'};
            Emailwithattch.setSubject(templateId.subject);
            Emailwithattch.setHtmlBody(newemailBody);
            Emailwithattch.setOrgWideEmailAddressId(owea.get(0).Id);
            Emailwithattch.setToaddresses(sendingTo);
            Emailwithattch.setBccAddresses(sendingToBccAdd);
            Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            
            SendEmail__c  objSendEmail = SendEmail__c.getValues('ScheduleMonthlyReimEmailCNCA');
            if(!Test.isRunningTest() && objSendEmail.Send_email_from_code__c == true){  
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailwithattch});
                }
        }
    }
}