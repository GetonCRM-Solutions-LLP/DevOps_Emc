global class ReviewAndApproveMileageForDelta implements Database.Batchable<sObject>, Database.Stateful
{
    List<EmailTemplate> emailTemplate;
    public OrgWideEmailAddress[] owea;
    public Map<String,Employee_Reimbursement__c> obj_Contact_Employee_Reimbursement_map {get;set;}
    public ReviewAndApproveMileageForDelta()
    {
       emailTemplate = [SELECT Id, Body, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'ReviewAndApproveMileageForDelta_Notification'];
       owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address =:'driverservices@mburse.com'];
       RG_InsertLastMonthReimbursement obj_RG_InsertLastMonthReimbursement = new RG_InsertLastMonthReimbursement();
       String lastmonth = obj_RG_InsertLastMonthReimbursement.getLastMonthValue(-1);
       obj_Contact_Employee_Reimbursement_map = new Map<String,Employee_Reimbursement__c>();
       for(Employee_Reimbursement__c obj_current_reimbersment :[Select id,Month__c,Contact_Id__c,Total_Mileage__c from Employee_Reimbursement__c where Contact_Id__c!=null and month__c=:lastmonth and Approved_Date__c=null])
       {
           if(obj_current_reimbersment.Contact_Id__c!=null)
           {
                obj_Contact_Employee_Reimbursement_map.put(obj_current_reimbersment.Contact_Id__c,obj_current_reimbersment);
           }
       }
    }
    global List<Contact> start(Database.BatchableContext BC) 
    {
        Date todayDate = System.today();
        if(!Test.isRunningTest()) {
            return [SELECT id,FirstName,Lastname,Role__c,External_Email__c,Manager__c,Monthly_Mileage_Limit__c,name,(SELECT FirstName,Lastname,Role__c,External_Email__c,id,name,Manager__c,Monthly_Mileage_Limit__c FROM drivers__r) FROM contact WHERE accountid != null and (Deactivated_Date__c=null OR Deactivated_Date__c >:todayDate) AND Role__c ='Manager' and Account.name='Delta'];
        } else {
            return [SELECT id,FirstName,Lastname,Role__c,External_Email__c,Manager__c,Monthly_Mileage_Limit__c,name,(SELECT Role__c,External_Email__c,id,name,Manager__c,Monthly_Mileage_Limit__c FROM drivers__r) FROM contact WHERE accountid != null and (Deactivated_Date__c=null OR Deactivated_Date__c >:todayDate) AND Role__c ='Manager' and Account.name='Delta'];
        }
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope) 
    {
        if((scope!=null)&&(scope.size()>0))
        {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Contact obj_currentcontact:(List<Contact>)scope)
            {
                //managers for loop add email addresses of managers email address
                String htmlbody = 'Hi '+obj_currentcontact.FirstName+',<br/> <p style="align:justify">Please review your employee\'s mileage for '+getMonth()+'. To approve the mileage without logging into the mBursement system, you can reply "I approve the mileage" by responding to this email.</p><br/><table style="border:3px solid black; border-collapse:collapse;"><tr  bgcolor="#d4d4d4"><th style="border:2px solid black;" width="5%">Drivers Name</th> <th style="border:2px solid black;" width="5%">Monthly Mileage Limit</th> <th style="border:2px solid black;" width="5%">Submitted Mileage</th></tr>'; 
                if((obj_currentcontact.drivers__r!=null)&&(obj_currentcontact.drivers__r.size()>0))
                {
                    Boolean flag=false;
                    for(Contact obj_currentDriver_Contact : obj_currentcontact.drivers__r)
                    {
                        // have drivers Build HTML here
                        if(obj_Contact_Employee_Reimbursement_map.containsKey(obj_currentDriver_Contact.Id))
                        {
                             flag=true;
                            string driverFirstName = obj_currentDriver_Contact.FirstName;
                            string monthlyMileageLimit = String.valueof(obj_currentDriver_Contact.Monthly_Mileage_Limit__c);
                            if(monthlyMileageLimit==null)
                            {
                                monthlyMileageLimit=' ';
                            }
                            string totalMileage = String.valueOf(obj_Contact_Employee_Reimbursement_map.get(obj_currentDriver_Contact.Id).Total_Mileage__c);
                            htmlbody += '<tr><td style="border:2px solid black;" width="5%">' + driverFirstName + '</td><td style="border:2px solid black;" width="5%">' + monthlyMileageLimit + '</td><td style="border:2px solid black;" width="5%">' + totalMileage + '</td></tr>' ;
                        } 
                          
                    }
                    // Build Email Message class here.
                    if(flag==true)
                    {
                        htmlbody += '</table><br/><br/><p style="align:justify">If you see that you are <b><u>NOT</u></b> logged into your account select "Forgot Password?" and follow the prompts to sign in.</p>';
                        String htmlEmail = emailTemplate[0].HTMLValue;
                        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        // String[] toAddresses = new String[] {managerEmail}; //managerEmail
                        String[] toAddresses = new String[] {obj_currentcontact.External_Email__c}; //managerEmail
                        mail.setToAddresses(toAddresses);
                        mail.setBCCAddresses(new string[]{'minkesh.patel@getoncrm.com','natavar.goc@gmail.com'});
                        // htmlEmail = htmlEmail.replace('{!Contact.FirstName}',obj_currentcontact.FirstName);
                        htmlEmail = htmlEmail.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                        //htmlbody = htmlbody.replace('{!Month}', mon);
                        htmlEmail = htmlEmail.replace('{Table}', htmlbody);
                        mail.setSubject(emailTemplate[0].subject);
                        mail.setPlainTextBody(htmlEmail);
                        mail.setHtmlBody(htmlEmail);
                        mails.add(mail);
                    }
                    else
                    {
                        htmlbody ='';
                        htmlbody ='Hi ' + obj_currentcontact.FirstName + ',' +'</br><p>Your employees did not report mileage this month and there is no mileage to review and approve.</p>';                   
                        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        // String[] toAddresses = new String[] {managerEmail}; //managerEmail
                        String[] toAddresses = new String[] {obj_currentcontact.External_Email__c}; //managerEmail
                        mail.setToAddresses(toAddresses);
                        mail.setBCCAddresses(new string[]{'minkesh.patel@getoncrm.com','natavar.goc@gmail.com'});
                        mail.setSubject('Monthly mileage approval');
                        String newBody = emailTemplate[0].HTMLValue;
                        newBody =  newBody.replace('{Table}',htmlbody);
                        newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                        mail.setPlainTextBody(newBody);
                        mail.setHtmlBody(newBody);
                        mails.add(mail);
                    } 
                     
                }
                
            }
            // send  email Here.
            if(!mails.isEmpty()) 
            {
                Messaging.sendEmail(mails);   
            }
        }
    }
     public String getMonth()
    {
        String valueofmonth = String.valueOf(System.Date.today());
        if(valueofmonth.contains('-'))
        {
            
            String[] monthYear = valueofmonth.split('-');
            String mon = monthYear[1];
            return (mon=='01'?'January':(mon=='02'?'February':(mon=='03'?'March':(mon=='04'?'April':(mon=='05'?'May':(mon=='06'?'June':(mon=='07'?'July':(mon=='08'?'August':(mon=='09'?'September':(mon=='10'?'October':(mon=='11'?'November':(mon=='12'?'December':(mon==''?' ':(mon==null?' ':' '))))))))))))));
            
        }
        else
        {
            return '';
        }
        
    }
    global void finish(Database.BatchableContext BC) 
    {
        /*RG_BatchForApprovingReimburse status = new RG_BatchForApprovingReimburse();
        if(!Test.isRunningTest()) 
        {
            Database.executeBatch(status, 200);
        }*/
    }
}