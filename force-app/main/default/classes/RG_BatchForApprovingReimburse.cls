global class RG_BatchForApprovingReimburse implements Database.Batchable<sObject> 
{
    List<Employee_Reimbursement__c> updateReimbursement = new List<Employee_Reimbursement__c>();
    Map<String, List<String>> contactIdToReimbursements = new Map<String, List<String>>();
    public SendEmailonDeactivation__c customSettings;   
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        customSettings = SendEmailonDeactivation__c.getValues('RG_BatchForApprovingReimburse'); 
        List<String> obj_accountnames = new List<String>();
        List<String> obj_accountnames1 = new List<String>();
        String querybuilding ='';
        if(System.Label.BatchAccountName != null) {
            if(System.Label.BatchAccountName.contains(',')) {
                obj_accountnames= System.Label.BatchAccountName.split(',');
            }
            Integer i=0;    
            for(String s:obj_accountnames) {
                s = s.trim();
                if(s.contains(',')) {
                    s = s.replace(',','');
                }
                if(i==0) {
                    querybuilding = ' ( Contact_Id__r.Account.Name = \''+s+'\'';    
                } else {
                    querybuilding = querybuilding+ ' OR '+ 'Contact_Id__r.Account.Name = \''+s+'\'';
                }        
                i++;
            }
            querybuilding = querybuilding+' ) AND ';
        }
        system.debug('querybuilding==' + querybuilding);
        String lastMonth = WrapperUtils.getLastMonthValue(-1);        
        string query ;
        if(test.isRunningTest()){
            system.debug('Insert into test query');
             query = 'select id, Name, Contact_Id__r.Name, Contact_Id__r.FirstName,Contact_Id__r.External_Email__c, Contact_Id__r.Manager__r.External_Email__c, Contact_Id__r.Manager__r.FirstName, Contact_Id__r.Manager__c, Total_Mileage__c from Employee_Reimbursement__c ';
        }  else {
             system.debug('Insert into Non test query');
             query = 'select id, Name, Contact_Id__r.Name, Contact_Id__r.FirstName, Contact_Id__r.External_Email__c, Contact_Id__r.Manager__r.External_Email__c, Contact_Id__r.Manager__r.FirstName, Contact_Id__r.Manager__c, Total_Mileage__c from Employee_Reimbursement__c where (Contact_Id__r.Driver_Type__c != \'Driver - Part Time\' OR Contact_Id__r.Driver_Type__c != \'Driver - Full Time\') AND '+querybuilding+' month__c=\'' + lastMonth + '\'  and Approved_Date__c=null  and Total_Mileage__c > 0 Order by Contact_Id__r.name asc ';
        }     
        system.debug('query ==' + query );  
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Employee_Reimbursement__c> empReimList) 
    {        
        Map<String, List<String>> contactIdOfReimbursement = new Map<String, List<String>>();
        for(Employee_Reimbursement__c singleReimbursement : empReimList) {
                if(!contactIdOfReimbursement.containsKey(singleReimbursement.Contact_Id__r.Manager__r.External_Email__c+'#'+singleReimbursement.Contact_Id__r.Manager__r.FirstName)) {
                   contactIdOfReimbursement.put(singleReimbursement.Contact_Id__r.Manager__r.External_Email__c+'#'+singleReimbursement.Contact_Id__r.Manager__r.FirstName, new List<String>{String.valueOf(singleReimbursement.Total_Mileage__c)+'#'+singleReimbursement.Contact_Id__r.Name});
                } else {
                   contactIdOfReimbursement.get(singleReimbursement.Contact_Id__r.Manager__r.External_Email__c+'#'+singleReimbursement.Contact_Id__r.Manager__r.FirstName).add(String.valueOf(singleReimbursement.Total_Mileage__c)+'#'+singleReimbursement.Contact_Id__r.Name);
                }
        }
        system.debug('contactIdOfReimbursement**'+contactIdOfReimbursement);
        if(!contactIdOfReimbursement.isEmpty()) {
            OrgWideEmailAddress[] owea = [select Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [SELECT Id,HtmlValue,Name,Subject FROM EmailTemplate WHERE DeveloperName =:'Exceeding_Threshold_Template'];            
           // Added by paras on 31-10-2023 for change request by client 
           // EMC - EMC-3237 
            Integer year = date.today().year();
            Integer lastMonthValue = date.today().addMonths(-1).Month();
             if(lastMonthValue == 12){
                year = year - 1;                 
            } else if(lastMonthValue > 1 && lastMonthValue <= 9 ) {
                lastMonthValue = Integer.valueof(string.valueof('0' + lastMonthValue));
            } else if(lastMonthValue > 9 && lastMonthValue <= 12){
                lastMonthValue = lastMonthValue;
            }
            String lstMonth = Wrapperutils.getMonthNamefromno(lastMonthValue);
           
            String newSubject = emailTemplate.Subject;
            newSubject = newSubject.replace('{!Month}',lstMonth);
            newSubject = newSubject.replace('{!year}',string.valueof(year));
              // end modification of above
            List<String> emailsToSend = new List<String>();
            for(String singleId : contactIdOfReimbursement.keySet()) {
                String managerEmail = singleId.split('#')[0];
                String managerName  = singleId.split('#')[1];
                String newBody = emailTemplate.HtmlValue;
                newBody = newBody.replace('{!Contact.FirstName}',managerName);
                newBody = newBody.replace('{!Month}',lstMonth);
                newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                
                String html = '';
                for(String value : contactIdOfReimbursement.get(singleId)) {
                    Decimal totalMileage = Decimal.valueOf(value.split('#')[0]);
                    String driverName = value.split('#')[1];
                    html += '<tr align="center">'
                    +'<td style="border:2px solid black;">'+driverName+'</td>'
                    +'<td style="border:2px solid black;">'+totalMileage+'</td>';
                    html += + '</tr>';
                }
                newBody =  newBody.replace('{mileageThresholdTable}',html);
                messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
                String[] toAddresses = new String[] {managerEmail}; //managerEmail                
                mail.setToAddresses(toAddresses);              
                mail.setSubject(newSubject);
                mail.setHtmlBody(newBody);
                if(customSettings != null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && customSettings.BCCEmailaddresses__c.contains(',')) {
                    emailsToSend.add('driverservices@askemc.com');
                    //emailsToSend = customSettings.BCCEmailaddresses__c.split(',');
                } else if(customSettings!=null && String.isNotBlank(customSettings.BCCEmailaddresses__c) && (!customSettings.BCCEmailaddresses__c.contains(','))) {
                    emailsToSend.add('driverservices@askemc.com');
                    //emailsToSend.add(customSettings.BCCEmailaddresses__c);
                }
                if(emailsToSend.size() > 0) {
                    mail.setBCCAddresses(emailsToSend);   
                }                             
                mails.add(mail);
            }
            if(!mails.isEmpty() && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            }
        }  
    }
    global void finish(Database.BatchableContext BC) {}
}