global class WiserServiceEmailBatch implements Database.Batchable<sObject>, Database.Stateful {    
    global List<Messaging.SingleEmailMessage> mails;
    global String htmlTemplate = '';
    global List<Employee_Reimbursement__c> empQuery;

    global WiserServiceEmailBatch() {

        String ReqMonth =  getLastMonthValue(-1);        
        empQuery = new List<Employee_Reimbursement__c>();
        
        empQuery = [Select id, 
                      name,
                      Contact_Id__c,
                      Contact_Id__r.Name, 
                      Contact_Id__r.External_Email__c,                                          
                      Status__c,
                      Total_Mileage__c 
                      from Employee_Reimbursement__c 
                      where Month__c =:ReqMonth  and Contact_Id__r.Account.Name = 'Weiser Security Services'
                                                 and (Contact_Id__r.Role__c = 'Driver' or Contact_Id__r.Role__c = 'Driver/Manager' or Contact_Id__r.Role__c =: StaticValues.roleAdminDriver)];         
    }
    
    global List<Employee_Reimbursement__c> start(Database.BatchableContext BC) {        
        return empQuery;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(Employee_Reimbursement__c er :(List<Employee_Reimbursement__c>) scope) {
            htmlTemplate = htmlTemplate + '<tr align="center">' + '<td style="border:2px solid black;">' 
                        + er.Contact_Id__r.Name + '</td>' + '<td style="border:2px solid black;">' 
                        + DateTime.now().format('MMM') + '-' + System.Today().year() 
                        + '</td><td style="border:2px solid black;">'+ er.Total_Mileage__c 
                        + '</td><td style="border:2px solid black;">' + er.status__c + '</td>';                 
            htmlTemplate += +'</tr>';
        } 
    }
    
    global void finish(Database.BatchableContext BC) {
        list<string> contNameEmail = new List<string>();
        List<Contact> contactQuery = new List<Contact>();        
        contactQuery = [SELECT Id, 
                          Name, 
                          Email,
                          FirstName 
                          FROM Contact 
                          where (Role__c = 'Admin' OR Role__c =: StaticValues.roleAdminDriver)  and Account.Name = 'Weiser Security Services']; 

                
        for(Contact co : contactQuery)
        {
           contNameEmail.add(co.FirstName + '_' + co.Email); 
        }
        
        EmailTemplate emailTemplate = [SELECT Id,
                                          HtmlValue,
                                          Name,
                                          Subject 
                                          FROM EmailTemplate 
                                          WHERE DeveloperName = 'Auto_Approval_Template_With_Weiser_Security_Services'];        

        String newBody = emailTemplate.HtmlValue;
        newBody = newBody.replace('{account.Approval_Template_Message__c}','');
        newBody = newBody.replace('{reportToTR}','');         
        String monthName = DateTime.now().format('MMMMM');
        newBody = newBody.replace('{CurrentMonth}', monthName);           
        newBody = newBody.replace('{tableDynamicData}',htmlTemplate);       
        newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);

        //Map of email with htmlbody string
        Map <string, string> emailMap = new Map<string, string>();
        for(string con: contNameEmail)
        {          
           String[] contArray = con.split('_');
           string contactName = contArray[0];
           string contactEmail = contArray[1];
           string htmlBody = newBody.replace('{ContactName}', contactName);
           emailMap.put(contactEmail, htmlBody);
        }

        //Body of email
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();        
        for (string em : emailMap.keyset())
        {
          List<String> emailaddressofsending = new List<String>();
         
          messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
          mail.setHtmlBody(emailMap.get(em));
          emailaddressofsending.add(em);
          mail.setToAddresses(emailaddressofsending);
          //Email subject to be changed
          mail.setSubject(monthName +' mileage status');
          mails.add(mail);
        } 

        if(!mails.isEmpty() && !Test.isRunningTest()) 
        {           
            Messaging.sendEmail(mails);
        }
        
    }
    global String getLastMonthValue(Integer value) {
        String tempDate = date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }
        return lastMonth;
    }
    
}