public with sharing class ActionItemEmailSendController {
	public ApexPages.StandardSetController standardSetController;
	public String htmlTemplate = '';
	public String emailTemplateBody {get; set;}
	public String subject {get; set;}
	public String emailTo {get; set;}
	public String emailCc {get; set;}
	public String emailBcc {get; set;}    
    public Integer selectedListCount {get; set;}
    public String sendEmailMessage {get; set;}

	public ActionItemEmailSendController(ApexPages.StandardSetController standardSetController) {        
        this.standardSetController = standardSetController; 
    }
    
    public PageReference actionItemRecord()    
    {        
        List<ActionItem__c> selectedListViewRecords =
            (List<ActionItem__c>) standardSetController.getSelected();

        selectedListCount = selectedListViewRecords.size();
        if(selectedListCount == 0)
        {
            return null;
        }        
        
        List<ActionItem__c> actionItemSelectedData = new List<ActionItem__c>();
        actionItemSelectedData = [SELECT Name, 
        								 Description__c, 
        								 Ticket_User__r.Name,
        								 Status__c,
        								 Due_Date__c,
        								 Efforts_In_Days__c,
        								 Effort_Estimation_In_Hours__c
        						  FROM ActionItem__c 
        						  WHERE ActionItem__c.id IN: selectedListViewRecords];        

        String todayDate = Datetime.now().format('MM-dd-yyyy');

        for(ActionItem__c er:actionItemSelectedData)
        {
            String dueDate = '';
            if(er.Due_Date__c != null)
            {
                dueDate = er.Due_Date__c.format('MM-dd-yyyy');
            }  

            String estimateHours = '';
            if(er.Effort_Estimation_In_Hours__c != null)
            {
                estimateHours = String.valueOf(er.Effort_Estimation_In_Hours__c);
            }
        	
        	htmlTemplate = htmlTemplate+'<tr align="center">' 
        				 + '<td style="border:1px solid black;">' + er.Name + '</td>' + 
        				 + '<td style="border:1px solid black;">' + er.Description__c + '</td>' + 
        				 + '<td style="border:1px solid black;">' + er.Status__c + '</td>' + 
        				 + '<td style="border:1px solid black;">' + dueDate + '</td>' + 
        				 + '<td style="border:1px solid black;">' + er.Ticket_User__r.Name + '</td>' + 
        				 + '<td style="border:1px solid black; text-align:center;">' + estimateHours + '</td>' ;
        	htmlTemplate += +'</tr>';
        }

        EmailTemplate emailTemplate = [SELECT Id,
                                              HtmlValue,
                                              Name,
                                              Subject 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = 'ActionItem_Selected_Task_Email'];

        emailTemplateBody = emailTemplate.HtmlValue;
        subject = emailTemplate.Subject;
        subject = subject.replace('{todayDate}',todayDate);
        emailTemplateBody = emailTemplateBody.replace('{tableDynamicData}',htmlTemplate);
        return null;
    }

    public PageReference sendMail()
    {   
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody(emailTemplateBody);        
        
        list<String> sendingTo = new list<String>();
        if(emailTo != null  && emailTo != '')
        {
            sendingTo = emailTo.split(',');         
            mail.setToAddresses(sendingTo);
        }
        if(emailCc != null && emailCc != '')
        {
            list<String> sendCc = new list<String>();
            sendCc = emailCc.split(',');
            mail.setCcAddresses(sendCc);
        }
        if(emailBcc != null && emailBcc != '')
        {
            list<String> sendBcc = new list<String>();
            sendBcc = emailBcc.split(',');
            mail.setBccAddresses(sendBcc);
        }

        //Email subject to be changed
        mail.setSubject(subject);
        
        if(sendingTo != null && !sendingTo.isEmpty())
        {  
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            sendEmailMessage = 'Email successfully send.';
            PageReference backPageUrl = standardSetController.cancel();
            return backPageUrl;
        }
        else
        {
            sendEmailMessage = 'Please add atleaset one Email id.';
        }
        return null;
    }

    public PageReference backPage()
    {
        PageReference cancel = standardSetController.cancel();
        return cancel;
    }
}