Public class SendEmailForSubmittedMileage implements Database.Batchable<sObject>, Database.Stateful
{
    List<EmailTemplate> emailTemplate; 
    public List<Contact> objContactList;
    public Map<Id, Employee_Reimbursement__c> contactToEmpReimMap;
    public OrgWideEmailAddress[] owea;

    public SendEmailForSubmittedMileage() {
        List<String> lstAccountNames = new List<String>();
        
        
        if(System.Label.BatchAccountName!=null)
        {
            if(System.Label.BatchAccountName.contains(','))
            {
                lstAccountNames= System.Label.BatchAccountName.split(',');
            }              
        }
        objContactList = new List<Contact>();
        Set<Id> conIds = new Set<Id>();
        contactToEmpReimMap = new Map<Id, Employee_Reimbursement__c>();
        emailTemplate = [SELECT Id, Body, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Notification_for_total_mileage'];
        String strOWEEmail= System.Label.Driver_Service_OWE;
        owea = [select Id ,Address from OrgWideEmailAddress where Address =:strOWEEmail];
        Date todayDate = System.today();
        if(!Test.isRunningTest()) {
            objContactList = [SELECT Id, Role__c, Deactivated_Date__c,
                                        External_Email__c, FirstName 
                                    FROM Contact 
                                    WHERE (Role__c ='Driver' 
                                            OR Role__c = 'Driver/Manager' 
                                            OR Role__c =: StaticValues.roleAdminDriver) 
                                        AND ( Deactivated_Date__c >:todayDate 
                                            OR Deactivated_Date__c =:Null) 
                                        AND (Account.name IN: lstAccountNames) 
                                        AND Send_Email_For_Submitted_Mileage__c=:true 
                                        AND (Driver_Type__c !='Driver - Full Time' 
                                        OR Driver_Type__c != 'Driver - Part Time') ];
        } else {
            objContactList = [SELECT Id, Role__c, Deactivated_Date__c,
                                        External_Email__c, FirstName 
                                    FROM Contact WHERE Role__c ='Driver'                                  
                                        /*AND (Account.name IN: lstAccountNames)*/ LIMIT 1];
        }
        for(Contact c : objContactList) {
            conIds.add(c.Id);
        }
        
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        List<Employee_Reimbursement__c> empReimList;
        if(!Test.isRunningTest()) {
        empReimList = [SELECT Id, Name, Month__c, Contact_Id__c, Total_Mileage__c 
                                                            FROM Employee_Reimbursement__c 
                                                            WHERE Month__c =: lastMonth AND Contact_Id__c IN: conIds AND Total_Mileage__c > 0];
        } else {
            empReimList = [SELECT Id, Name, Month__c, Contact_Id__c, Total_Mileage__c 
                                                            FROM Employee_Reimbursement__c ];
        }
        system.debug('empReimList=='+empReimList);
        for(Employee_Reimbursement__c empReim : empReimList) {
            contactToEmpReimMap.put(empReim.Contact_Id__c, empReim);
        }
    }

    Public List<Contact> start(Database.BatchableContext bc) {
        return objContactList;
    }

    Public void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        String htmlbody = '';
        String htmlSubject = '';
        Messaging.SingleEmailMessage mail;
        for(Contact c : scope) {
            if(contactToEmpReimMap.containsKey(c.id)) {
                String[] monthYear = contactToEmpReimMap.get(c.id).Month__c.split('-');
                String mon = monthYear[0];
                if(mon == '01'){ mon = 'January';}
                else if (mon == '02'){ mon = 'February';}
                else if (mon == '03'){ mon = 'March';}
                else if (mon == '04'){ mon = 'April';}
                else if (mon == '05'){ mon = 'May';}
                else if (mon == '06'){ mon = 'June';}
                else if (mon == '07'){ mon = 'July';}
                else if (mon == '08'){ mon = 'August';}
                else if (mon == '09'){ mon = 'September';}
                else if (mon == '10'){ mon = 'October';}
                else if (mon == '11'){ mon = 'November';}
                else if (mon == '12'){ mon = 'December';}
                // Send Mail Functionality
                mail = new Messaging.SingleEmailMessage();
                SendEmailToMe__c  objSendEmailToMe = SendEmailToMe__c.getValues('SendEmailForSubmittedMileage');
                List<String> address = new List<String>();
                if(objSendEmailToMe.Send_email_to_me__c == true)
                {
                    address.add('minkeshp@askemc.com');
                    mail.setBCCAddresses(new string[]{'driverservices@mburse.com'});                    
                }
                else
                {
                    address.add(c.External_Email__c);
                    mail.setBCCAddresses(new string[]{'driverservices@mburse.com'});
                }                
                
                mail.setToAddresses(address);
                mail.setSubject(mon + ' Submitted mileage');
                htmlbody = emailTemplate[0].HTMLValue;
                if(owea.size()>0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                htmlbody = htmlbody.replace('{!Contact.FirstName}',c.FirstName);
                htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                htmlbody = htmlbody.replace('{!Month}', mon);
                htmlbody = htmlbody.replace('{!Year}', monthYear[1]);
                htmlbody = htmlbody.replace('{!Total_Mileage}', String.valueOf(contactToEmpReimMap.get(c.Id).Total_Mileage__c));
                mail.setPlainTextBody(htmlbody);
                mail.setHtmlBody(htmlbody);
                mailList.add(mail);
            }
        }
        SendEmail__c  objSendEmail = SendEmail__c.getValues('SendEmailForSubmittedMileage');
        if(!mailList.isEmpty()  &&(objSendEmail!=null) && (objSendEmail.Send_email_from_code__c==true) && !Test.isRunningTest())  {
            Messaging.sendEmail(mailList);   
        }
    }

    Public void finish(Database.BatchableContext bc) {
        System.debug('sendemailforsubmittedmileage batch is completed');
    }
}