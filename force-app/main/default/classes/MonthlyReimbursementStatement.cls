global class MonthlyReimbursementStatement implements Database.Batchable<sObject>
{    
    
    public OrgWideEmailAddress[] owea{get;set;}    
    string accountId;
    public String query;
    
    string finalMonth;
    
    public MonthlyReimbursementStatement()
    {
        owea = [select Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];   
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   
        
        DateTime dateTimeFormat = datetime.now();
        Datetime StartDateandTime = datetime.now();
        
        String StartDateandTime1= StartDateandTime.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String orcondition='';
        if(dateTimeFormat.month()!=1)
        {            
            orcondition='( ';
            for(Integer i=1;i<dateTimeFormat.Month();i++)
            {
                if(i==12 || i== (Integer.valueOf(dateTimeFormat.Month()))-1)
                {
                    if(i<10)
                    {
                        orcondition = orcondition+'Month__c='+'\'0'+String.valueOf(i)+'-'+String.valueOf(dateTimeFormat.year())+'\' )';
                    }
                    else
                    {
                        orcondition = orcondition+'Month__c= \''+String.valueOf(i)+'-'+String.valueOf(dateTimeFormat.year())+'\' )';
                    }
                    system.debug('orcondition--' + orcondition);
                }
                else
                {
                    if(i<10)
                    {
                        orcondition = orcondition+'Month__c='+'\'0'+String.valueOf(i)+'-'+String.valueOf(dateTimeFormat.year())+'\' OR '; 
                    }
                    else
                    {
                        orcondition = orcondition+'Month__c= \''+String.valueOf(i)+'-'+String.valueOf(dateTimeFormat.year())+'\' OR '; 
                    } 
                    system.debug('orcondition1--' + orcondition);
                }            
            }            
        }
        else
        {
            orcondition='( ';
            orcondition= orcondition +'Month__c='+'\''+String.valueOf('01')+'-'+String.valueOf(dateTimeFormat.year())+'\' OR '; 
            orcondition = orcondition+'Month__c= \''+String.valueOf('12')+'-'+String.valueOf(dateTimeFormat.addYears(-1).year())+'\' )'; 
            
        }
         
        if(Test.isRunningTest())
        {
           
             query='SELECT id,FirstName,Lastname,Role__c,External_Email__c,Manager__c,Monthly_Mileage_Limit__c,name,(Select id, Month__c, Contact_Id__c, Monthly_Mileage__c, Fixed_Amount__c, Monthly_Variable_Amount__c, Monthly_Total_Reimbursement__c from Employee_Reimbursements__r where '+orcondition+') FROM contact  WHERE External_Email__c = \'minkesh.patel1478@gmail.com\' LIMIT 1';
        }
        else
        {
            accountId = Label.AccIdForMonthlyReimStatements;
            query='SELECT id,FirstName,Lastname,Role__c,External_Email__c,Manager__c,Monthly_Mileage_Limit__c,name,(Select id, Month__c, Contact_Id__c, Monthly_Mileage__c, Fixed_Amount__c, Monthly_Variable_Amount__c, Monthly_Total_Reimbursement__c from Employee_Reimbursements__r where '+orcondition+') FROM contact WHERE (Deactivated_Date__c = null OR Deactivated_Date__c >= '+StartDateandTime1+') AND (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\') AND account.Id ='+'\''+accountId+'\'' ;
           
      }
        
    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) 
    {   
        if((scope!=null)&&(scope.size()>0)){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            for(Contact currentContact:(List<Contact>)scope)
            {
                Integer monthfortemp=0;
                 system.debug('currentContact.Employee_Reimbursements__r'+currentContact.Employee_Reimbursements__r);
                if(currentContact.Employee_Reimbursements__r != Null)
                {
                    String htmlbody = 'Hi ' + currentContact.FirstName + ',' + '</br><p> Your mileage has been approved and in the reimbursement process. </p> <table style="border:3px solid black; border-collapse:collapse;"><tr  bgcolor="#d4d4d4"><th style="border:2px solid black;" align="left" width="5%">Month</th> <th style="border:2px solid black;"  align="left" width="5%">Monthly Mileage</th> <th style="border:2px solid black;" align="left" width="5%">Fixed Amount</th> <th style="border:2px solid black;" align="left" width="5%">Variable Amount</th> <th style="border:2px solid black;" align="left" width="5%">Total Reimbursement</th></tr>'; 
                    system.debug('currentContact.Employee_Reimbursements__r'+currentContact.Employee_Reimbursements__r);
                    Map<Integer,String> obj_map_month = new Map<Integer,String>();
                    for(Employee_Reimbursement__c empReimObj:currentContact.Employee_Reimbursements__r)
                    {     
                        system.debug('empReimObj---' + empReimObj);  
                          
                        if(empReimObj.Contact_Id__c != null)
                        { 
                            
                            string valueofmonth = String.valueof(empReimObj.Month__c);
                            
                            String mon='';
                            if(valueofmonth.contains('-'))
                            {
                                
                                String[] monthYear = valueofmonth.split('-');
                                mon = monthYear[0];
                                
                                finalMonth = (mon=='01'?'Jan':(mon=='02'?'Feb':(mon=='03'?'Mar':(mon=='04'?'Apr':(mon=='05'?'May':(mon=='06'?'Jun':(mon=='07'?'Jul':(mon=='08'?'Aug':(mon=='09'?'Sep':(mon=='10'?'Oct':(mon=='11'?'Nov':(mon=='12'?'Dec':(mon==''?' ':(mon==null?' ':' ')))))))))))))) + '-' + monthYear[1];
                                
                            }
                            else
                            {
                                finalMonth = '';
                            }
                            string monthlyMileage;  
                            if(empReimObj.Monthly_Mileage__c != null)
                            { 
                                monthlyMileage = String.valueof(empReimObj.Monthly_Mileage__c);
                            }
                            else{
                                monthlyMileage = '';
                            }
                            string fixedAmount;    
                            if(empReimObj.Fixed_Amount__c != null)
                            {
                                fixedAmount = String.valueof(empReimObj.Fixed_Amount__c);
                            }
                            else{
                                fixedAmount = '';
                            }
                            string variableAmount = String.valueof(empReimObj.Monthly_Variable_Amount__c);
                            string totalReimbursement = String.valueof(empReimObj.Monthly_Total_Reimbursement__c);
                            String temphtml= '<tr><td style="border:2px solid black;" width="5%" align="left">' + finalMonth + '</td> <td style="border:2px solid black;" width="5%" align="left">' + monthlyMileage + '</td> <td style="border:2px solid black;" width="5%" align="left">' + fixedAmount + '</td> <td style="border:2px solid black;" width="5%" align="left">' + variableAmount + '</td> <td style="border:2px solid black;" width="5%" align="left">' + totalReimbursement + '</td></tr>' ; 
                            
                            if((!obj_map_month.containsKey(Integer.valueOf(mon)))&&(mon!=null))
                            {
                                obj_map_month.put(Integer.valueOf(mon),temphtml);
                            }
                        }
                        
                        
                    }
                    if(obj_map_month.size()>0)
                    {
                        List<Integer> obj_monthkey = new List<Integer>();
                        obj_monthkey.addAll(obj_map_month.keyset());
                        obj_monthkey.sort();
                        for(Integer j=0;j<=obj_monthkey.size()-1;j++)
                        {
                            Integer k=obj_monthkey[j];
                            htmlbody = htmlbody +obj_map_month.get(k);
                        }
                        System.debug('-------------------------->>>>>>>>>>>>>>>>'+obj_map_month);                           
                    }
                    htmlbody += '</table>';
                    htmlbody += '<br>Thank you,<br/>Driver Services<br/><img src="https://mburse--fullcopy--c.cs65.content.force.com/servlet/servlet.ImageServer?id=0150m000000Fh9F&oid=00D0m000000CvzC&lastMod=1531909765000"/><br/><br/><h6><p style="align:justify">This email message, including any attachments are for the sole use of the intended recipient(s) and may contain confidential and privileged information. Any unauthorized review, use disclosure or distribution is prohibited. If you are not the intended recipient, please contact the sender by reply e-mail and destroy all copies of the original message.</p></h6>';
                    messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    String[] toAddresses = new String[] {currentContact.External_Email__c}; 
                    mail.setToAddresses(toAddresses);
                   // String[] toAddresses = new String[] {'natavar.goc@gmail.com'};
                   // mail.setToAddresses(toAddresses); 
                    mail.setBCCAddresses(new string[]{'natavar.goc@gmail.com','minkesh.patel@getoncrm.com','sanket.goc@gmail.com'});
                    mail.setSubject('Monthly reimbursement statement');
                    mail.setHtmlBody(htmlbody);
                    mail.setPlainTextBody(htmlbody);
                    mails.add(mail);
                }
                
               
            } 
            if(!mails.isEmpty() && !Test.isRunningTest()) 
            {
               Messaging.sendEmail(mails);   
            }   
        }
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {
    
    }
    
    
    
     
}