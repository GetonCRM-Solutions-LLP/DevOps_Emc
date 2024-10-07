/*********************************************************************************************
Description: For send Mail to YTC Admin where employee user name not equal to yokohomatire.com
*********************************************************************************************/

public with sharing class SendMonthlyYTCAdmin {
    String query;
    List<Contact> conList;
    public SendMonthlyYTCAdmin() {
        conList = new List<Contact>();
        query = 'SELECT Id, Name, External_Email__c, Employee_ID__c FROM Contact WHERE Account.Name = ' +'\'' + Label.YTC_Account_Name + '\'' +' AND (Not External_Email__c LIKE \'%yokohamatire.com\')' + +' AND Role__c = \'Driver\' AND ( Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:30  ) AND Send_Monthly_YTC_Admin__c=true';
        conList = database.query(query);
    }
    public void sendMailAdim() {
        String bodyTable = '', body;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        messaging.singleEmailMessage mail;
        OrgWideEmailAddress[] owea = [SELECT Id, address FROM OrgWideEmailAddress WHERE Address = 'driverservices@mburse.com'];
        bodyTable = '<table style="border:3px solid black; border-collapse:collapse;">' 
                            + '<tr  bgcolor="#d4d4d4">'
                                //+ '<th style="border:2px solid black; padding:7px;">' + 'Employee ID' + '</th>'  
                                + '<th style="border:2px solid black; padding:7px;">' + 'Name' + '</th>' 
                                + '<th style="border:2px solid black; padding:7px;">' + 'External Email' + '</th>'
                            + '</tr>';
        for(Contact con : conList) {
            bodyTable =  bodyTable +
                            + '<tr align="center">'
                                //+ '<td  style="border:2px solid black; padding:7px;">' + con.Employee_ID__c + '</td>'
                                + '<td  style="border:2px solid black; padding:7px;">' + con.Name + '</td>' 
                                + '<td  style="border:2px solid black; padding:7px;">' + con.External_Email__c + '</td>' 
                            + '</tr>'; 
        }
        bodyTable = bodyTable + '</table>';
        for(Contact c : [SELECT id, FirstName, External_Email__c FROM Contact WHERE Account.Name =: Label.YTC_Account_Name AND Role__c = 'Admin' AND Name != 'Stephanie Beaulac' AND Name != 'Jean Hall']) {
            mail = new  messaging.singleEmailMessage();
            body = 'Hi ' + c.FirstName + ',' + '<br/><br/>' + 
                        'Please do not forget to change User Name as well as check their employee ID and manager.' + 
                        '<br/><br/>' + bodyTable + 
                        '<br/><br/>' + 'Cheers,' + 
                        '<br/>' + 'Driver Services';
            if(owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            string[] toAddresses = new string[]{c.External_Email__c};
            mail.setToAddresses(toAddresses);
            //Email subject to be changed
            mail.setSubject('YTC Admin Notification: Change your employee details');
            //Body of email
            mail.setHtmlBody(body);
            //Sending the email
            mails.add(mail);
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
            SendEmail__c  objSendEmail = SendEmail__c.getValues('SendMonthlyYTCAdmin');
            if(objSendEmail.Send_email_from_code__c==true  &&(objSendEmail!=null))
            {
                Messaging.sendEmail(mails);
            }
    }
}