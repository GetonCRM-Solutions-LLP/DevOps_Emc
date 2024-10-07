/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Schedule class for CNCA account send email on 9th date of every month.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 18 May 2020
 */
public class ScheduleMonthlyReimEmailCNCA implements schedulable {
    List<Employee_Reimbursement__c> reimbursementList ;
    public void execute (SchedulableContext SC) {
        sendexcelfile();
    }
    public void sendexcelfile(){
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        reimbursementList = [SELECT Month__c,Contact_Id_Employee_ID__c,Contact_Id_Name__c,Contact_Id_External_Email__c,
                                    Monthly_Total_Reimbursement__c ,Fixed_Amount__c,Total_Monthly_Approved_Variable__c
                            FROM Employee_Reimbursement__c 
                            WHERE Contact_Id_Deactivated_Date__c = null 
                                and Month__c =: lastMonth
                                and Contact_Id__r.Account.Name =: System.label.CNCA_Account];

        string header ='Month'+'\t'+'EmployeeID'+'\t'+ 'Name'+'\t'+'E-mail'+'\t'+'Fixed Amount'+'\t'+'Variable Amount'+'\t'+'Total Monthly Reimbursement'+' \n';
        String finalstr = header;
        for(Employee_Reimbursement__c obj : reimbursementList){
            String Recordstring = obj.Month__c+'\t'+obj.Contact_Id_Employee_ID__c+'\t'+obj.Contact_Id_Name__c+'\t'+obj.Contact_Id_External_Email__c+'\t'+obj.Fixed_Amount__c+'\t'+obj.Total_Monthly_Approved_Variable__c+'\t'+obj.Monthly_Total_Reimbursement__c+'\n';
            finalstr = finalstr + Recordstring;
        }
        EmailTemplate templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Monthly_Reimbursement_Report' Limit 1];
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        blob excel = blob.valueOf(finalstr);
        attach.setBody(excel);
        attach.setFileName('Monthly Reimbursement Report.xls');
        
        //string[] address = new string[]{System.label.JenniferCNCAEmail};
        Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
        String newemailBody = templateId.HtmlValue;
        newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        String[] sendingTo = new String[]{'jbracco@abelhr.com'};
        String[] sendingToBccAdd = new String[]{'minkeshp@askemc.com'};
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