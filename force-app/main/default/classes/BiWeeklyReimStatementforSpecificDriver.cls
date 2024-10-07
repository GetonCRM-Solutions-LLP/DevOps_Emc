global class BiWeeklyReimStatementforSpecificDriver implements Database.Batchable<SObject>, Database.Stateful
{
    public List<String> accountNamesList;
    public List<EmailTemplate> emailTemplateList;
    public List<String> emailsToSend;
    public List<String> endDate;
    public SendEmailonDeactivation__c customSettings;	 
    
    global BiWeeklyReimStatementforSpecificDriver() 
    {
        String accountName = Label.BiWeeklyReimbursementStatementBatch;
        accountNamesList = new List<String>();
        emailsToSend = new List<String>();
        if(accountName != null) 
        {
            accountNamesList = accountName.split(',');
        }
        emailTemplateList = new List<EmailTemplate>([SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Driver_BiweeklyReimStatement']);        
        customSettings = SendEmailonDeactivation__c.getValues('YearToDateReimbursementStatement');       
        if(customSettings!=null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && customSettings.BCCEmailaddresses__c.contains(','))
        {
            emailsToSend = customSettings.BCCEmailaddresses__c.split(',');
        }
        else if(customSettings!=null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && (!customSettings.BCCEmailaddresses__c.contains(',')))
        {
            emailsToSend.add(customSettings.BCCEmailaddresses__c);
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String  query = 'Select Id,External_Email__c,FirstName FROM Contact WHERE Account.Name IN: accountNamesList  AND ReimbursementStatement__c = true ';       
        return Database.getQueryLocator(query);  
        //system.debug('query==' + Database.getQueryLocator(query) );
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) 
    {
        system.debug('query=='+ scope);
        Set<String> contactIdList = new Set<String>();
        Map<String,String> driverEmailMap = new Map<String,String>();
        Map<String,Decimal> driverMileageMap = new Map<String,Decimal>();
        Map<String,Decimal> driverVariableAmountMap = new Map<String,Decimal>();
        Map<String,Decimal> driverFixedAmountMap = new Map<String,Decimal>();
        Map<String,Decimal> driverMonthlyReimbursementMap = new Map<String,Decimal>();
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        
        for(Contact currentContact : (List<Contact>)scope)
        {
            contactIdList.add(currentContact.id);
        }
        system.debug('contactIdList=='+ contactIdList);
        date dt = date.valueof('2022-01-23');
        system.debug('dt==' + dt);
        for(Bi_Weekly_Reimbursement__c currentReimbursement : [SELECT id,
                                                                   Name,
                                                                   Total_Approved__c,
                                                                   Fuel_Variable_Rate__c,
                                                                   Total_Monthly_Approved_Variable__c,
                                                                   Half_Fixed_Amount__c,
                                                                   Total_Monthly_Reimbursement__c ,
                                                                   Contact__c,
                                                                   Start_date__c,
                                                                   End_date__c
                                                               FROM Bi_Weekly_Reimbursement__c
                                                               WHERE Contact__c IN : contactIdList 
                                                                   AND End_date__c = THIS_YEAR
                                                                   AND End_Date__c <=: dt  ORDER bY Start_date__c DESC  ])
        {
            system.debug('driverEmailMap.size==' + driverEmailMap.size());
            String htmlTemplate='';
            if(driverEmailMap.size()>0 && driverEmailMap.containsKey(currentReimbursement.Contact__c))
            {
                htmlTemplate = driverEmailMap.get(currentReimbursement.Contact__c);
                
                Decimal mileage =(currentReimbursement.Total_Approved__c!=null)?currentReimbursement.Total_Approved__c:0;
                mileage = mileage + driverMileageMap.get(currentReimbursement.Contact__c);
                
                driverMileageMap.put(currentReimbursement.Contact__c,mileage);
                system.debug('mileage=='+ mileage);
                
                Decimal variableAmout = (currentReimbursement.Total_Monthly_Approved_Variable__c!=null)?currentReimbursement.Total_Monthly_Approved_Variable__c.setScale(2) :0;
                variableAmout = variableAmout + driverVariableAmountMap.get(currentReimbursement.Contact__c);
                driverVariableAmountMap.put(currentReimbursement.Contact__c,variableAmout);
                
                Decimal fixedAmount = (currentReimbursement.Half_Fixed_Amount__c!=null)?currentReimbursement.Half_Fixed_Amount__c:0;
                fixedAmount = fixedAmount + driverFixedAmountMap.get(currentReimbursement.Contact__c);
                driverFixedAmountMap.put(currentReimbursement.Contact__c,fixedAmount);
                
                Decimal monthlyReimbursement = (currentReimbursement.Total_Monthly_Reimbursement__c!=null)?currentReimbursement.Total_Monthly_Reimbursement__c:0;
                monthlyReimbursement = monthlyReimbursement + driverMonthlyReimbursementMap.get(currentReimbursement.Contact__c);
                driverMonthlyReimbursementMap.put(currentReimbursement.Contact__c,monthlyReimbursement);
                
                htmlTemplate = htmlTemplate + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                    + currentReimbursement.Name +'</td><td style="border:2px solid black;">'
                    + currentReimbursement.Total_Approved__c+'</td><td style="border:2px solid black;">'+'$' 
                   /* + currentReimbursement.Fuel_Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' */
                    + currentReimbursement.Total_Monthly_Approved_Variable__c.setScale(2) +'</td><td style="border:2px solid black;">' +'$' 
                    + currentReimbursement.Half_Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                    + currentReimbursement.Total_Monthly_Reimbursement__c +'</td>' 
                    +'</tr>';
            }
            else
            {
                driverMileageMap.put(currentReimbursement.Contact__c,((currentReimbursement.Total_Approved__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Total_Approved__c)))?currentReimbursement.Total_Approved__c:0));
                driverVariableAmountMap.put(currentReimbursement.Contact__c,((currentReimbursement.Total_Monthly_Approved_Variable__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Total_Monthly_Approved_Variable__c.setScale(2))))?currentReimbursement.Total_Monthly_Approved_Variable__c.setScale(2):0));
                driverFixedAmountMap.put(currentReimbursement.Contact__c,((currentReimbursement.Half_Fixed_Amount__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Half_Fixed_Amount__c)))?currentReimbursement.Half_Fixed_Amount__c:0));
                driverMonthlyReimbursementMap.put(currentReimbursement.Contact__c,((currentReimbursement.Total_Monthly_Reimbursement__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Total_Monthly_Reimbursement__c)))?currentReimbursement.Total_Monthly_Reimbursement__c:0));
                
                htmlTemplate='<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                    + currentReimbursement.Name +'</td><td style="border:2px solid black;">' 
                    + currentReimbursement.Total_Approved__c +'</td><td style="border:2px solid black;">'+'$' 
                  /*  + currentReimbursement.Fuel_Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' */ 
                    + currentReimbursement.Total_Monthly_Approved_Variable__c.setScale(2) +'</td><td style="border:2px solid black;">' +'$' 
                    + currentReimbursement.Half_Fixed_Amount__c +'</td><td style="border:2px solid black;">'+'$' 
                    + currentReimbursement.Total_Monthly_Reimbursement__c +'</td>' 
                    +'</tr>';
               }
            driverEmailMap.put(currentReimbursement.Contact__c ,htmlTemplate);
        }
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];         
        for(Contact currentContact : (List<Contact>)scope)
        {
            String htmlTemplate = '';
            if(driverEmailMap.containsKey(currentContact.id))
            {
                htmlTemplate = driverEmailMap.get(currentContact.id);  
                htmlTemplate = htmlTemplate + '<tr align="center" style="border:2px solid black;"><td style="border:2px solid black;"><b> Total </b></td> <td style="border:2px solid black;"><b>'+String.valueOf(driverMileageMap.get(currentContact.id))+ '</b></td> <td style="border:2px solid black;"><b>'+'$'+ String.valueOf(driverVariableAmountMap.get(currentContact.id))+'</b></td> <td style="border:2px solid black;"><b>'+'$'+String.valueOf(driverFixedAmountMap.get(currentContact.id))+ '</b></td> <td style="border:2px solid black;"><b>'+'$'+String.valueOf(driverMonthlyReimbursementMap.get(currentContact.id))+'</b></td> </tr>';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String newBody = emailTemplateList[0].HtmlValue;
                newBody = newBody.replace('{tableDynamicData}',htmlTemplate);
                newBody = newBody.replace('{!Bi_Weekly_Reimbursement__c.Contact_Id_Name__c}',currentContact.FirstName);
                newBody = newBody.replace('{!Bi_Weekly_Reimbursement__c.Contact_Id_External_Email__c}',currentContact.External_Email__c);
                
                newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                mail.setSubject(emailTemplateList[0].Subject);
                mail.setHtmlBody(newBody);
                List<String> toAddress = new List<String>();
                if(customSettings.Send_to_Driver__c == true) 
                {
                    toAddress.add(currentContact.External_Email__c);
                    //toAddress.add('paras.dhanani@getoncrm.com');
                    mail.setToAddresses(toAddress);
                    if(emailsToSend.size()>0)
                    {
                        mail.setBccAddresses(emailsToSend);
                    }                   
                }
                else if(emailsToSend.size()>0)
                {
                    mail.setToAddresses(emailsToSend);
                }
                mail.setOrgWideEmailAddressId(owea.get(0).Id);    
                singleEmailMessageList.add(mail);                 
            }
        }
        
        if(singleEmailMessageList.size()>0 && !Test.IsRunningTest()) 
        {
            Messaging.sendEmail(singleEmailMessageList);  
        }
    }
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}