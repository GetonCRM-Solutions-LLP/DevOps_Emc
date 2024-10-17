/***********************************************************************************************
 * Author :- GetOnCRM Solutions LLP                                                                       
 * Created Date :- 16/03/2022                                                                             
 * Description :- Send an email to the Ermi's Part-time and Full-time driver who did not confirm          
 *                weekly time and mileage for the week of last completed pay period even if the.          
 *                for the Confirmation mail was send to that drivers.                                     
 * ---------------------------------------------------------------------------------------------
 * Modified by :- PARAS DHANANI                                                                           
 * Modified Date :- 17/10/2024                                                                            
 ***********************************************************************************************/

 Public with sharing  class WeeklyTimeSheetNotConfirmController implements Schedulable {

    Public  List<EmailTemplate> temp;
    Public  OrgWideEmailAddress[] owea;
    date reimEndDate = system.today().adddays(-2);
    
   
 
    Public WeeklyTimeSheetNotConfirmController() {
    system.debug('reimEndDate ==' + reimEndDate );
    
         temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue 
                                         FROM EmailTemplate 
                                        WHERE DeveloperName = 'Weekly_Time_Sheet_for_Not_Confirm_by_Driver']);
        String strOWEEmail= System.Label.Driver_Service_OWE;
        owea = [select Id ,Address from OrgWideEmailAddress where Address =:strOWEEmail WITH SECURITY_ENFORCED];
      
    } 

    Public void execute(SchedulableContext sc) {
        getWeeklyDriversData();
    }
    Public void getWeeklyDriversData (){
        system.debug('reimEndDate==' + reimEndDate);
        Messaging.SingleEmailMessage mail;
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for (Bi_Weekly_Reimbursement__c biweeklyReim : [SELECT id,name, Confirm_Hours__c,Contact__r.FirstName,Contact__r.External_Email__c         
                                                            FROM Bi_Weekly_Reimbursement__c
                                                            WHERE Contact__r.Account.Name = 'Ermi'
                                                             AND Confirm_Hours__c = false
                                                             AND Start_Date__c != Null
                                                             AND End_Date__c  != Null
                                                             AND End_Date__C =:  reimEndDate WITH SECURITY_ENFORCED]){
                List<String> sendingTo = new List<String>();
            string htmlbody = '';
            mail = new Messaging.SingleEmailMessage();
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }            
            sendingTo.add(biweeklyReim.Contact__r.External_Email__c);            
            mail.setToAddresses(sendingTo);
            mail.setSubject(temp[0].Subject);
            htmlbody = temp[0].HTMLValue;
            htmlbody = htmlbody.replace('{!Contact.FirstName}', biweeklyReim.Contact__r.FirstName);
            htmlbody = htmlbody.replace('{!Bi_Weekly_Reimbursement__c.Name}', biweeklyReim.name ); 
            htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
            mail.setPlainTextBody(htmlbody);
            String[] bccAddress = new String[] {'driverservices@mburse.com' , 'Ermitesting@mburse.com'};            
            mail.setBccAddresses(bccAddress);
            mail.setHtmlBody(htmlbody);
            mailList.add(mail);
        }
        if(mailList.size() > 0 && !Test.isRunningTest()){
            Messaging.sendEmail(mailList);  
        }
    }
}