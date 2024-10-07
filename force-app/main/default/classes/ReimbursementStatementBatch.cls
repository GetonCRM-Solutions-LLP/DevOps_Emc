global with sharing class ReimbursementStatementBatch implements Database.Batchable<SObject>,Database.Stateful
{
    public List<String> accountNamesList;
    public List<EmailTemplate> emailTemplateList;
    public List<String> emailsToSend;
    public List<String> monthList;
    public SendEmailonDeactivation__c customSettings;
    public String  query;
    public ReimbursementStatementBatch() 
    {
        String accountName = Label.ReimbursementStatementBatch;
        accountNamesList = new List<String>();
        emailsToSend = new List<String>();
        monthList = new List<String>();
        if(accountName != null) {
            accountNamesList = accountName.split(',');
        }
        emailTemplateList = new List<EmailTemplate>([SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'year_to_date_reimbursement_statement_template']);        
        customSettings = SendEmailonDeactivation__c.getValues('YearToDateReimbursementStatement');       
        if(customSettings!=null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && customSettings.BCCEmailaddresses__c.contains(','))
        {
            emailsToSend = customSettings.BCCEmailaddresses__c.split(',');
        }
        else if(customSettings!=null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && (!customSettings.BCCEmailaddresses__c.contains(',')))
        {
            emailsToSend.add(customSettings.BCCEmailaddresses__c);
        }
        for(Integer i=1;i<=System.Today().Month();i++) {
            if(i<10) {
               monthList.add('0'+String.valueOf(i)+'-'+String.valueOf(System.Today().Year())); 
            }
            else {
               monthList.add(String.valueOf(i)+'-'+String.valueOf(System.Today().Year()));  
            }
        }        
      
        monthlist.remove(monthList.size()-1);

       query = 'Select Id,External_Email__c,FirstName FROM Contact WHERE Account.Name IN: accountNamesList AND (Role__c = \'Driver\' OR Role__c = \'Driver/Manager\' OR Role__c = \''+StaticValues.roleAdminDriver+'\') AND (Deactivated_Date__c = NULL OR Deactivated_Date__c >= TODAY)';
    }

    public ReimbursementStatementBatch(String listofMonth)  {
       
        MonthList = listofMonth.split(',');
        accountNamesList = new List<String>();
        emailsToSend = new List<String>();
        
        emailTemplateList = new List<EmailTemplate>([SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'year_to_date_reimbursement_statement_template']);        
        customSettings = SendEmailonDeactivation__c.getValues('YearToDateReimbursementStatement');       
        if(customSettings!=null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && customSettings.BCCEmailaddresses__c.contains(','))
        {
            emailsToSend = customSettings.BCCEmailaddresses__c.split(',');
        }
        else if(customSettings!=null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && (!customSettings.BCCEmailaddresses__c.contains(',')))
        {
            emailsToSend.add(customSettings.BCCEmailaddresses__c);
        }
       
        query = 'Select Id,External_Email__c,FirstName FROM Contact WHERE (Role__c = \'Driver\' OR Role__c = \'Driver/Manager\' OR Role__c = \''+StaticValues.roleAdminDriver+'\') AND (Deactivated_Date__c = NULL OR Deactivated_Date__c >= TODAY) AND ReimbursementStatementBatch__c = True';

    }
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {       
        List<String> contactIdList = new List<String>();       
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
        
        for(Employee_Reimbursement__c currentReimbursement : [SELECT id,Total_Mileage__c,Variable_Rate__c, Monthly_Variable_Amount__c,Total_Approved__c,
                                                                    Fixed_Amount__c,Total_Monthly_Reimbursement__c,Month__c,Contact_Id__c 
                                                                    FROM Employee_Reimbursement__c 
                                                                    WHERE Contact_Id__c IN : contactIdList
                                                                         AND Month__c IN : monthList ORDER BY Month__c DESC])
                {
                    
                    List<String> monthAndYear = new List<String>();
                    datetime monthValue = System.Now();
                    if(currentReimbursement.Month__c!=null && currentReimbursement.Month__c.contains('-'))
                    {
                        monthAndYear = currentReimbursement.Month__c.split('-');
                        monthValue = datetime.newInstance(Integer.valueOf(monthAndYear[1]), integer.valueOf(monthAndYear[0]), 1,00,00,00);
                    }
                    String monthName = monthValue.format('MMMMM'); 
                    String htmlTemplate='';
                    system.debug('driverEmailMap.size()==' +driverEmailMap.size());
                    system.debug('currentReimbursement.Contact_Id__c' + currentReimbursement.Contact_Id__c);
                     
                     system.debug('driverEmailMap.size()==' + driverEmailMap.size());
                    Decimal fixedAmountValue = (currentReimbursement.Fixed_Amount__c!=null)?currentReimbursement.Fixed_Amount__c:0;
                    
                     if(driverEmailMap.size()>0 && driverEmailMap.containsKey(currentReimbursement.Contact_Id__c))
                        {
                            htmlTemplate = driverEmailMap.get(currentReimbursement.Contact_Id__c);
                            
                            Decimal mileage =(currentReimbursement.Total_Approved__c!=null)?currentReimbursement.Total_Approved__c:0;
                            mileage = mileage + driverMileageMap.get(currentReimbursement.Contact_Id__c);
                            
                            driverMileageMap.put(currentReimbursement.Contact_Id__c,mileage);
                            system.debug('mileage=='+ mileage);
                            
                            Decimal variableAmout = (currentReimbursement.Monthly_Variable_Amount__c!=null)?currentReimbursement.Monthly_Variable_Amount__c:0;
                            variableAmout = variableAmout + driverVariableAmountMap.get(currentReimbursement.Contact_Id__c);
                            driverVariableAmountMap.put(currentReimbursement.Contact_Id__c,variableAmout);
                            
                            Decimal fixedAmount = (currentReimbursement.Fixed_Amount__c!=null)?currentReimbursement.Fixed_Amount__c:0;
                            fixedAmount = fixedAmount + driverFixedAmountMap.get(currentReimbursement.Contact_Id__c);
                            driverFixedAmountMap.put(currentReimbursement.Contact_Id__c,fixedAmount);
                            system.debug('fixedAmount ==' + fixedAmount );
                            system.debug('driverFixedAmountMap==' + driverFixedAmountMap);
                            
                            Decimal monthlyReimbursement = (currentReimbursement.Total_Monthly_Reimbursement__c!=null)?currentReimbursement.Total_Monthly_Reimbursement__c:0;
                            monthlyReimbursement = monthlyReimbursement + driverMonthlyReimbursementMap.get(currentReimbursement.Contact_Id__c);
                            driverMonthlyReimbursementMap.put(currentReimbursement.Contact_Id__c,monthlyReimbursement);
                            
                            htmlTemplate = htmlTemplate + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                + monthName +'</td><td style="border:2px solid black;">'
                                + currentReimbursement.Total_Approved__c+'</td><td style="border:2px solid black;">'+'$' 
                                + currentReimbursement.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                + currentReimbursement.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                               // + currentReimbursement.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                               + fixedAmountValue +'</td><td style="border:2px solid black;">' +'$' 
                                //+ '(currentReimbursement.Total_Monthly_Reimbursement__c!=null)?currentReimbursement.Total_Monthly_Reimbursement__c:0' + '</td><td style="border:2px solid black;">'+'$' 
                                + currentReimbursement.Total_Monthly_Reimbursement__c +'</td>' 
                                +'</tr>';
                        }
                        else
                        {
                            driverMileageMap.put(currentReimbursement.Contact_Id__c,((currentReimbursement.Total_Approved__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Total_Approved__c)))?currentReimbursement.Total_Approved__c:0));
                            driverVariableAmountMap.put(currentReimbursement.Contact_Id__c,((currentReimbursement.Monthly_Variable_Amount__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Monthly_Variable_Amount__c)))?currentReimbursement.Monthly_Variable_Amount__c:0));
                            driverFixedAmountMap.put(currentReimbursement.Contact_Id__c,((currentReimbursement.Fixed_Amount__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Fixed_Amount__c)))?currentReimbursement.Fixed_Amount__c:0));
                            driverMonthlyReimbursementMap.put(currentReimbursement.Contact_Id__c,((currentReimbursement.Total_Monthly_Reimbursement__c!=null && String.IsNotEmpty(String.valueOf(currentReimbursement.Total_Monthly_Reimbursement__c)))?currentReimbursement.Total_Monthly_Reimbursement__c:0));
                            system.debug('currentReimbursement.Fixed_Amount__c===' + currentReimbursement.Fixed_Amount__c);
                            htmlTemplate='<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                + monthName +'</td><td style="border:2px solid black;">' 
                                + currentReimbursement.Total_Approved__c +'</td><td style="border:2px solid black;">'+'$' 
                                + currentReimbursement.Variable_Rate__c +'</td><td style="border:2px solid black;">'+'$' 
                                + currentReimbursement.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                //+ currentReimbursement.Fixed_Amount__c +'</td><td style="border:2px solid black;">'+'$'
                                +   fixedAmountValue +'</td><td style="border:2px solid black;">'+'$' 
                                + currentReimbursement.Total_Monthly_Reimbursement__c +'</td>' 
                                +'</tr>';
                           }
                     
                     driverEmailMap.put(currentReimbursement.Contact_Id__c,htmlTemplate);
                     
                }
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];         
        for(Contact currentContact : (List<Contact>)scope)
        {
           String htmlTemplate = '';
           if(driverEmailMap.containsKey(currentContact.id))
           {
               system.debug('driverMileageMap.get(currentContact.id)==' + driverMileageMap.get(currentContact.id));
               htmlTemplate = driverEmailMap.get(currentContact.id);               
               htmlTemplate = htmlTemplate + '<tr align="center" style="border:2px solid black;"><td style="border:2px solid black;"><b> Total </b></td> <td style="border:2px solid black;"><b>'+String.valueOf(driverMileageMap.get(currentContact.id))+ '</b></td> <td style="border:2px solid black;"> </td> <td style="border:2px solid black;"><b>'+'$'+ String.valueOf(driverVariableAmountMap.get(currentContact.id))+'</b></td> <td style="border:2px solid black;"><b>'+'$'+String.valueOf(driverFixedAmountMap.get(currentContact.id))+ '</b></td> <td style="border:2px solid black;"><b>'+'$'+String.valueOf(driverMonthlyReimbursementMap.get(currentContact.id))+'</b></td> </tr>';
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               String newBody = emailTemplateList[0].HtmlValue;
               newBody = newBody.replace('{tableDynamicData}',htmlTemplate);
               newBody = newBody.replace('{!Employee_Reimbursement__c.Contact_Id_Name__c}',currentContact.FirstName);
               newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
               mail.setSubject(emailTemplateList[0].Subject);
               mail.setHtmlBody(newBody);
               List<String> toAddress = new List<String>();
               if(customSettings.Send_to_Driver__c == true) {
                   toAddress.add(currentContact.External_Email__c);
                   mail.setToAddresses(toAddress);
                   if(emailsToSend.size()>0){
                       mail.setBccAddresses(emailsToSend);
                   }                   
               }
               else if(emailsToSend.size()>0) {
                   mail.setToAddresses(emailsToSend);
               }
               mail.setOrgWideEmailAddressId(owea.get(0).Id);    
               singleEmailMessageList.add(mail);                 
           }
        }
        
        if(singleEmailMessageList.size()>0 && !Test.IsRunningTest()){
            Messaging.sendEmail(singleEmailMessageList);  
        }
        
    }
    global void finish(Database.BatchableContext bc){}
}