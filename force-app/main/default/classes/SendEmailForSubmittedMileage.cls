global class SendEmailForSubmittedMileage implements Database.Batchable<sObject>, Database.Stateful
{
    List<EmailTemplate> emailTemplate; 
    public List<Contact> obj_contact_list;
    public Map<Id, Employee_Reimbursement__c> contactToEmpReimMap;
    public OrgWideEmailAddress[] owea;

    public SendEmailForSubmittedMileage() {
        List<String> obj_accountnames = new List<String>();
        
        
        if(System.Label.BatchAccountName!=null)
        {
            if(System.Label.BatchAccountName.contains(','))
            {
                obj_accountnames= System.Label.BatchAccountName.split(',');
            }              
        }
        obj_contact_list = new List<Contact>();
        Set<Id> conIds = new Set<Id>();
        contactToEmpReimMap = new Map<Id, Employee_Reimbursement__c>();
        emailTemplate = [SELECT Id, Body, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Notification_for_total_mileage'];
        owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address =:'driverservices@mburse.com'];
        Date todayDate = System.today();
        if(!Test.isRunningTest()) {
            obj_contact_list = [SELECT Id, Role__c, Deactivated_Date__c,
                                        External_Email__c, FirstName 
                                    FROM Contact 
                                    WHERE (Role__c ='Driver' 
                                            OR Role__c = 'Driver/Manager' 
                                            OR Role__c =: StaticValues.roleAdminDriver) 
                                        AND ( Deactivated_Date__c >:todayDate 
                                            OR Deactivated_Date__c =:Null) 
                                        AND (Account.name IN: obj_accountnames) 
                                        AND Send_Email_For_Submitted_Mileage__c=:true 
                                        AND (Driver_Type__c !='Driver - Full Time' 
                                        OR Driver_Type__c != 'Driver - Part Time') ];
        } else {
            obj_contact_list = [SELECT Id, Role__c, Deactivated_Date__c,
                                        External_Email__c, FirstName 
                                    FROM Contact WHERE Role__c ='Driver'                                  
                                        /*AND (Account.name IN: obj_accountnames)*/ LIMIT 1];
        }
        for(Contact c : obj_contact_list) {
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

    global List<Contact> start(Database.BatchableContext BC) {
        return obj_contact_list;
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
        String htmlbody = '', htmlSubject = '';
        Messaging.SingleEmailMessage mail;
        for(Contact c : scope) {
            if(contactToEmpReimMap.containsKey(c.id)) {
                String[] monthYear = contactToEmpReimMap.get(c.id).Month__c.split('-');
                String mon = monthYear[0];
                if(mon == '01') mon = 'January';
                else if (mon == '02') mon = 'February';
                else if (mon == '03') mon = 'March';
                else if (mon == '04') mon = 'April';
                else if (mon == '05') mon = 'May';
                else if (mon == '06') mon = 'June';
                else if (mon == '07') mon = 'July';
                else if (mon == '08') mon = 'August';
                else if (mon == '09') mon = 'September';
                else if (mon == '10') mon = 'October';
                else if (mon == '11') mon = 'November';
                else if (mon == '12') mon = 'December';
                // Send Mail Functionality
                mail = new Messaging.SingleEmailMessage();
                SendEmailToMe__c  objSendEmailToMe = SendEmailToMe__c.getValues('SendEmailForSubmittedMileage');
                List<String> address = new List<String>();
                if(objSendEmailToMe.Send_email_to_me__c == true)
                {
                    address.add('minkeshp@askemc.com');
                    mail.setBCCAddresses(new string[]{'driverservices@askemc.com'});                    
                }
                else
                {
                    address.add(c.External_Email__c);
                    mail.setBCCAddresses(new string[]{'driverservices@askemc.com'});
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
                mail_list.add(mail);
            }
        }
        SendEmail__c  objSendEmail = SendEmail__c.getValues('SendEmailForSubmittedMileage');
        if(!mail_list.isEmpty()  &&(objSendEmail!=null) && (objSendEmail.Send_email_from_code__c==true) && !Test.isRunningTest())  {
            Messaging.sendEmail(mail_list);   
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}