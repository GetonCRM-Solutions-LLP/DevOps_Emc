global class SendEmailToUploadonJuly Implements Schedulable {
    //Schedule Every Year crone job
    public Boolean flag{get;set;}
    public SendEmailToUploadonJuly()
    {
        flag=false;
    }
    global void execute(SchedulableContext sc) {
        sendMail();
       /* SendEmailToUploadonJuly schedule = new SendEmailToUploadonJuly();
        String sch ='0 0 0 18 7 ?';
        System.schedule('Yearly base Scheduled Job',sch, schedule);*/
    }
    //Send Email functionality
    public void sendMail() {
        List<Messaging.MassEmailMessage> mails = new List<Messaging.MassEmailMessage>();
        List<id> conId= new List<Id>();
        string header = 'Name, Email, Error \n';
        string finalstr = header ;
        list<string> roleList = new list<string>();
        roleList.add('Driver');
        roleList.add('Driver/Manager');
        roleList.add(StaticValues.roleAdminDriver);
        List<Contact> conList =[SELECT Name, Role__c, External_Email__c, FirstName FROM Contact
                                    WHERE Role__c IN : roleList AND Active__c = True];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:'driverservices@mburse.com'];
        List<EmailTemplate> temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue FROM EmailTemplate 
                                                                WHERE DeveloperName = 'Send_Email_At_July']);
        
        
        Messaging.SingleEmailMessage mail;
        Integer totalcontacts = conList.size();
        try {
            for(Contact c: conList) {
                try {
                List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
                List<String> sendingTo = new List<String>();
                    string htmlbody = '';
                    mail = new Messaging.SingleEmailMessage();
                    if (owea.size() > 0) 
                    {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    sendingTo.add(c.External_Email__c);
                    mail.setToAddresses(sendingTo);
                    mail.setSubject(temp[0].Subject);
                    htmlbody = temp[0].HTMLValue;
                    htmlbody = htmlbody.replace('{!Contact.FirstName}',c.FirstName);
                    htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                    mail.setPlainTextBody(htmlbody);
                    List<String> bccaddress = new list<String>();
                    bccaddress.add('driverservices@mburse.com');
                    mail.setBccAddresses(bccaddress);
                    mail.setHtmlBody(htmlbody);
                    mail_list.add(mail);
                    Messaging.sendEmail(mail_list);
                      
                } catch(Exception e) {
                flag=true;
                    string recordString = c.Name + ',' + c.External_Email__c + ',' + e.getmessage() + '\n';
                    finalstr = finalstr + recordString;
                }
            }
        } catch(Exception e) {
        }
        finally {
            // send CSV to 
            if(flag==true)
            {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(finalstr);
            string csvname= 'Contact.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {'sanket.goc@gmail.com'};
            email.setSubject('Contact CSV');
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Contact CSV');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                if(!Test.isRunningTest()){
                    Messaging.SendEmailResult [] sendSinglemail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                }
            }
                
        }
    }
}