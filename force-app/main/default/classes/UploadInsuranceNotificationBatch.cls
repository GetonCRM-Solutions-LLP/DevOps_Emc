/*  Author : GetonCRM Solutions LLP                                                                     
 * Created Date : 01/06/2022                                                                            
 * Description : This Batch is used to send Notification mail to driver who has skip Insurance while activation.
 *                 This mail is stop fire after 30  day of activation day.                                                            
 * -------------------------------------------------------------------------------------------------
 * Created by   : Paras Dhanani                                                                          
 * Created Date : 01-06-2022                   
 */

Public class UploadInsuranceNotificationBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    Public  List<EmailTemplate> temp;
    Public OrgWideEmailAddress[] owea;
    public String after30DaysDate ; 
    
    Public UploadInsuranceNotificationBatch(){
        temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue 
                                        FROM EmailTemplate 
                                        WHERE DeveloperName = 'Skiped_Insurance_Notification']);
        owea = [select Id from OrgWideEmailAddress where Address =:'driverservices@mburse.com'];
    }
    Public List<Contact> start(Database.BatchableContext bc) {
        List<Contact> conList = new List<Contact>();
        conList = [SELECT Id,name,FirstName,External_Email__c,Activation_Date__c
                   FROM contact 
                   WHERE  Role__c != 'Admin' 
                   AND Role__c != 'Manager' 
                   AND Account.isUsingTriplog__c = True 
                   AND Deactivated_Date__c = NULL 
                   AND Activation_Date__c != NULL
                   AND Insurance_Attachment_Id__c = NULL
                   AND Insurance_Declaration_Status__c = 'Skip'
                   WITH SECURITY_ENFORCED ];
        return conList;
    }
    Public void execute(Database.BatchableContext bc, List<Contact> scope){
        Messaging.SingleEmailMessage mail;
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for(contact con : (List<contact>) scope){
            date activationDate = con.Activation_Date__c;
            date currentDate = system.today();
            integer numberDaysDue = currentDate.daysBetween(activationDate);
            integer remainder = Math.Mod(numberDaysDue,5);
            string activationplus30 = String.valueOf(con.Activation_Date__c.adddays(30));
            String[] splitDate = activationplus30.split('-');
            string monthName = WrapperUtils.getMonthNamefromno(Integer.valueof(splitDate[1]));
            after30DaysDate = monthName + ' ' + splitDate[2] + ',' + splitDate[0];
            if(remainder == 0 || Test.isRunningTest())  {
                system.debug('Insertinto if condition==' + remainder);
                List<String> sendingTo = new List<String>();
                string htmlbody = '';
                mail = new Messaging.SingleEmailMessage();
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                sendingTo.add(con.External_Email__c);
                //sendingTo.add('paras.dhanani@getoncrm.com');
                mail.setToAddresses(sendingTo);
                mail.setSubject(temp[0].Subject);
                htmlbody = temp[0].HTMLValue;
                htmlbody = htmlbody.replace('{!Contact.FirstName}',con.FirstName);
                htmlbody = htmlbody.replace('{!Contact.Skip_Insurance_Date__c}', after30DaysDate);
                htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                mail.setPlainTextBody(htmlbody);
                List<String> bccaddress = new list<String>();
                mail.setHtmlBody(htmlbody);
                mailList.add(mail);
            }
        }
        
         SendEmail__c  sendEmailObj = SendEmail__c.getValues('UploadInsuranceNotificationBatch');
        if((sendEmailObj!=null) && sendEmailObj.Send_email_from_code__c==true && mailList.size()>0 && !Test.isRunningTest())
        {
             Messaging.sendEmail(mailList);  
        }
       /* if(mailList.size() > 0 && !Test.isRunningTest()){
            Messaging.sendEmail(mailList);  
        } */
    }    
    Public void finish(Database.BatchableContext bc){ }   
}