public with sharing class DailyStatusEmailSendController {
    public ApexPages.StandardSetController standardSetController;
    public String htmlTemplate = '';
    public String emailTemplateBody {get; set;}
    public String subject {get; set;}
    public String emailTo {get; set;}
    public String emailCc {get; set;}
    public String emailBcc {get; set;}
    public Integer selectedListCount {get; set;}
    public String sendEmailMessage {get; set;}

    public DailyStatusEmailSendController(ApexPages.StandardSetController standardSetController) {
        this.standardSetController = standardSetController;       
    }

    public PageReference dailyStatusRecord()    
    { 
        List<DailyStatus__c> selectedListViewRecords =
            (List<DailyStatus__c>) standardSetController.getSelected(); 

        selectedListCount = selectedListViewRecords.size();
        if(selectedListCount == 0)
        {
            return null;
        } 
       
        List<DailyStatus__c> dailyStatusSelectedData = new List<DailyStatus__c>();
        dailyStatusSelectedData = [SELECT Name, 
                                          Task_Description__c,                                        
                                          Working_Hours__c,
                                          ActionItem__c,
                                          ActionItem__r.Name,
                                          ActionItem__r.Description__c,
                                          ActionItem__r.Due_Date__c,
                                          ActionItem__r.Effort_Estimation_In_Hours__c,
                                          Ticket_User__r.Name                                                                 
                                  FROM DailyStatus__c 
                                  WHERE DailyStatus__c.id IN: selectedListViewRecords
                                  ORDER BY ActionItem__r.Name ASC];
       
        Map<String, Integer> actionCount = new Map<String, Integer>();
        Map<String, Decimal> daiyHoursSum = new Map<String, Decimal>();
       
        Integer a = 0;
        Decimal sumDailyHours = 0;
        String actionItemNameData = '';
        for(DailyStatus__c ds:dailyStatusSelectedData)
        {
            a++;
            sumDailyHours = sumDailyHours + ds.Working_Hours__c;
            if(ds.ActionItem__r.Name != actionItemNameData && actionItemNameData != '')
            {
                a = 1;                 
                sumDailyHours = ds.Working_Hours__c;  
            }
            actionCount.put(ds.ActionItem__r.Name, a); 
            daiyHoursSum.put(ds.ActionItem__r.Name, sumDailyHours);
            actionItemNameData = ds.ActionItem__r.Name;           
        }

        String todayDate = Datetime.now().format('MM-dd-yyyy');

        string tableHearder1 = '<tr bgcolor="#002266">'
                                + '<th style="border:1px solid black;">ActionItem No</th>'
                                + '<th style="border:1px solid black;">ActionItem Description </th>'
                                + '<th style="border:1px solid black;">Due Date</th>'
                                + '<th style="border:1px solid black;">Estimate Hours</th>'
                                + '</tr>';
        string tableHearder2 = '<tr bgcolor="#D3D3D3">'    
                                + '<th style="border:1px solid black; color:black; font-weight: bold;">Ticket User</th>'                                
                                + '<th style="border:1px solid black; color:black; font-weight: bold;">DailyStatus Description</th>'
                                + '<th style="border:1px solid black; color:black; font-weight: bold;">Working Hours</th>'  
                                + '<th style="border:1px solid black; color:black; font-weight: bold;">Total Hours</th>'
                                + '</tr>';
        
        String actionItemName = '';
        String totalHours = '';
        for(DailyStatus__c ds:dailyStatusSelectedData)
        {           
            String dueDate = '';
            if(ds.ActionItem__r.Due_Date__c != null)
            {
                dueDate = ds.ActionItem__r.Due_Date__c.format('MM-dd-yyyy');
            }

            String actionItemEstimate = '';
            if(ds.ActionItem__r.Effort_Estimation_In_Hours__c != null)
            {
                actionItemEstimate = String.valueOf(ds.ActionItem__r.Effort_Estimation_In_Hours__c);
            }

            if(actionItemName == '' || ds.ActionItem__r.Name != actionItemName ) 
            {
                htmlTemplate = htmlTemplate + tableHearder1+'<tr align="center">' 
                         + '<td style="border:1px solid black;">' + ds.ActionItem__r.Name + '</td>' +
                         + '<td style="border:1px solid black;">' + ds.ActionItem__r.Description__c + '</td>' +
                         + '<td style="border:1px solid black; text-align:center;">' + dueDate + '</td>' +
                         + '<td style="border:1px solid black; text-align:center;">' + actionItemEstimate + '</td>' ;
                htmlTemplate += +'</tr>' + tableHearder2;                           
            }

            if(ds.ActionItem__r.Name != actionItemName)
            {
               totalHours = '<td style="border:1px solid black; text-align:center;" rowspan='+actionCount.get(ds.ActionItem__r.Name)+'>' + daiyHoursSum.get(ds.ActionItem__r.Name) + '</td>'; 
            }
            else
            {
                totalHours = '';
            }

            htmlTemplate =  htmlTemplate+'<tr align="center" text-align:center;>' 
                            + '<td style="border:1px solid black;" >' + ds.Ticket_User__r.Name   + '</td>' + 
                            + '<td style="border:1px solid black;">' + ds.Task_Description__c + '</td>' +                       
                            + '<td style="border:1px solid black; text-align:center;">' + ds.Working_Hours__c + '</td>' +
                            + totalHours;
            htmlTemplate += +'</tr>';

            actionItemName = ds.ActionItem__r.Name;
        }

        EmailTemplate emailTemplate = [SELECT Id,
                                              HtmlValue,
                                              Name,
                                              Subject 
                                      FROM EmailTemplate 
                                      WHERE DeveloperName = 'Daily_Status_Selected_Email_Template2'];

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

        if(emailTo != null && emailTo != '')
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
            PageReference backPage = standardSetController.cancel();
            return backPage;
        }
        else
        {
            sendEmailMessage = 'Please add atleaset one Email id.';
        }
        return null;
    }

    public PageReference backPage()
    {
        PageReference backPageUrl = standardSetController.cancel();
        return backPageUrl;
    }
}