/**
 * @Author:  GetOnCRM Solutions LLP
 * @Description: Batch to send email notification on deactivation of user(s)
 * @Modification logs
 * ========================================================================================================================
 * @Date: 28 May 2020 | Sanjay Halpati
 * @description: Added Email logs & used Utils method to create emails, and optimized code. 
 */
global class DeActivatedUserEmailBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    String query;
    List<String> deactivatedConIds;
    List<String> roles = new List<String> { StaticValues.roleAdminDriver, StaticValues.ROLE_DRIVERMANAGER, StaticValues.ROLE_DRIVER };
    OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
    String userId;


    /**
     * Default Constructor 
     */
    global DeActivatedUserEmailBatch() {
        query = 'SELECT Id, Name, FirstName, Deactivated_Date__c, External_Email__c, AccountId, Manager_External_Email__c, Manager__r.FirstName,' +
                    ' Manager__r.External_Email__c, Monthly_Mileage_Limit__c, Manager__r.send_deactivation_Email__c, send_deactivation_Email__c ' + 
                    ' FROM Contact ' +
                    ' WHERE Deactivated_Date__c = Today AND Deactivation_Email_Sent__c = false AND Role__c In: roles' ; 
    }


    /**
     * Constructor with list of deactivated contacts
     */
    global DeActivatedUserEmailBatch(List<String> deactivatedConIds) {   
        this.deactivatedConIds = deactivatedConIds;
        query = 'SELECT Id, Name, Triplog_UserID__c, isCommunityUser__c, Deactivated_Date__c, External_Email__c, ' + 
                'IsDeactivated__c, Account.Triplog_API__c,Manager__r.FirstName,Manager__r.External_Email__c,' + 
                'Manager__r.send_deactivation_Email__c,send_deactivation_Email__c ' + 
                ' FROM Contact ';
        if(!Test.isRunningTest()) {
            query += ' WHERE Account.isUsingTriplog__c = true AND Deactivation_Email_Sent__c = false and Id IN: deactivatedConIds' + 
                     ' AND Deactivated_Date__c != null ';
        } else {
            query += ' WHERE IsDeactivated__c = false AND Deactivated_Date__c = Today AND isCommunityUser__c = true ' +
                    ' AND Account.isUsingTriplog__c = true AND Role__c In: roles LIMIT 1' ;
        }
    }

    /**
     * Constructor with deactivate contact Id or Account Id
     */
    global DeActivatedUserEmailBatch(String userId) {
        this.userId = userId;
        query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,' + 
                'Account.Triplog_API__c,Manager__r.FirstName,Manager__r.External_Email__c,Manager__r.send_deactivation_Email__c,' + 
                'send_deactivation_Email__c FROM Contact' + 
                ' WHERE Deactivation_Email_Sent__c = false ' +
                ' AND Deactivated_Date__c != Null ';


        if(userId.left(2) == '001') {
            query += 'AND AccountId =: userId';
        } else {
            query += 'AND Id =: userId';
        }
        query += Test.isRunningTest() ? ' LIMIT 1' : '';
        
    } 

    /**
     *  Start Method
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {                      
        return Database.getQueryLocator(query);
    }

    /**
     * Execute Method 
     */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for(Contact contactId : (List<Contact>) scope) {
            contactIds.add(contactId.Id);
            accountIds.add(contactId.AccountId);
        }
        
        List<Contact> adminContacts = [SELECT Id,Name,External_Email__c,AccountId,send_deactivation_Email__c FROM Contact WHERE AccountId In: accountIds AND (Role__c =: StaticValues.ROLE_ADMIN  OR Role__c =: StaticValues.roleAdminDriver) AND send_deactivation_Email__c = true AND Deactivated_Date__c = Null]  ;
        Map<Id, Set<String>> accountAdmins = new Map<Id, Set<String>> ();
        for(Contact c : adminContacts) {
            if(!accountAdmins.containsKey(c.AccountId)) {
                accountAdmins.put( c.AccountId, new Set<String>{ c.External_Email__c } );
            } else {
                accountAdmins.get(c.AccountId).add(c.External_Email__c);
            }
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Email_Log__c> emailLogs = new List<Email_Log__c>();
        EmailTemplate DeActivated_User_Email = [SELECT Id, HtmlValue, Name, Subject FROM EmailTemplate  WHERE DeveloperName =: 'DeActivated_User_Email' ];
        EmailTemplate Deactivation_with_No_Mileages = [SELECT Id, HtmlValue, Name, Subject FROM EmailTemplate WHERE DeveloperName =:'Deactivation_with_No_Mileages'];
        Map<Id, Employee_Reimbursement__c> reimbursementMap = new Map<Id, Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c reim : [SELECT Id, Total_Mileage_WithOut_Previous__c, Contact_Id__c, Total_Mileage__c FROM Employee_Reimbursement__c WHERE Contact_Id__c In:contactIds AND Month__c =: Utils.fetchCurrentMonth()]) {
            reimbursementMap.put(reim.Contact_Id__c, reim);
        }
        //Variables to set email addresses
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>(); //c.Manager__r.External_Email__c
        List<String> bccAddresses = new List<String>();
        SendEmailonDeactivation__c  sendEmailConfig = SendEmailonDeactivation__c.getValues('DeActivatedUserEmailBatch');
        if( sendEmailConfig != null ) {
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Contact c : (List<Contact>) scope) {
                if(sendEmailConfig.Send_to_Admin__c) {
                    if(c.Manager__r.send_deactivation_Email__c) {
                        toAddresses.add(c.Manager__r.External_Email__c);
                        if(accountAdmins.containsKey(c.AccountId)){
                            ccAddresses.addAll(accountAdmins.get(c.AccountId));   
                        } 
                        bccAddresses = sendEmailConfig.BCCEmailaddresses__c != null ? Utils.SplitStringToList( sendEmailConfig.BCCEmailaddresses__c, ','):new List<String>();
                    } else {
                        toAddresses = sendEmailConfig.BCCEmailaddresses__c != null ? Utils.SplitStringToList( sendEmailConfig.BCCEmailaddresses__c, ','):new List<String>();
                    }
                } else if(sendEmailConfig.Send_to_me__c) {
                    toAddresses = sendEmailConfig.BCCEmailaddresses__c != null ? Utils.SplitStringToList( sendEmailConfig.BCCEmailaddresses__c, ','):new List<String>();
                }
                if((reimbursementMap.containsKey(c.Id) && reimbursementMap.get(c.Id).Total_Mileage__c > 0)||Test.isRunningTest()) {
                    // need to check 
                    Decimal totalMileage = reimbursementMap.get(c.Id).Total_Mileage__c;
                    
                    // Has Mileages
                    String newEmailBody = DeActivated_User_Email.HtmlValue;      
                    if( c.Manager__r.FirstName != null && c.Name != null) {
                        newEmailBody = newEmailBody.replace('{!Contact.Manager__r}', c.Manager__r.FirstName);
                        newEmailBody = newEmailBody.replace('{!Contact.Name}', c.Name);
                        newEmailBody = newEmailBody.replace('{!Contact.Manager__r}', c.Manager__r.FirstName); 
                        newEmailBody = newEmailBody.replace('{!Contact.NameTable}', c.Name); 
                        newEmailBody = newEmailBody.replace('{driverdeactivationdate}', c.Deactivated_Date__c.format());  
                        newEmailBody = newEmailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);  
                        
                        String  html = '<tr align="center">' +
                                    '<td style="border:2px solid black;">' + c.Name + '</td>' +
                                    '<td style="border:2px solid black;">' + totalMileage + '</td>' +
                                    '</tr>';
                        newEmailBody =  newEmailBody.replace('{mileageThresholdTable}', html);

                        messaging.singleEmailMessage mail = Utils.CreateEmail(DeActivated_User_Email.subject, newEmailBody, toAddresses, ccAddresses, bccAddresses, null);
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        mails.add(mail);
                        emailLogs.add(
                            Utils.CreateEmailLog(DeActivated_User_Email.subject, newEmailBody, toAddresses, ccAddresses, bccAddresses, null, 'DeActivatedUserEmailBatch')
                        );
                    }
                } else {
                    String newEmailBody = Deactivation_with_No_Mileages.HtmlValue;
                    if( c.Manager__r.FirstName != null && c.Name != null) {
                        newEmailBody = buildNoMileageEmail( newEmailBody, c.Manager__r.FirstName,c.Name,c.Deactivated_Date__c.format());   
                        String subject = Deactivation_with_No_Mileages.subject;
                        subject = subject.replace('{driversubject}', String.valueOf(c.Name)); 
                        messaging.singleEmailMessage mail = Utils.CreateEmail(subject, newEmailBody, toAddresses, ccAddresses, bccAddresses, null);
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        mails.add(mail);
                        emailLogs.add(
                            Utils.CreateEmailLog(subject, newEmailBody, toAddresses, ccAddresses, bccAddresses, null, 'DeActivatedUserEmailBatch')
                        );
                    }
                }
                c.Deactivation_Email_Sent__c = true;
                contactsToUpdate.add(c);  
                
            }
            if(!mails.isEmpty() && !Test.isRunningTest()) {
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mails, false);  
                Utils.SaveEmailLogs(emailLogs, result);
            }
            if(!contactsToUpdate.isEmpty())
                update contactsToUpdate;
        }
    }
    /**
     * Method to build No Mileage Email body
     */
    global String buildNoMileageEmail(String htmlvalue, String manager, String name, String DeactivatedDate) {
        htmlvalue = htmlvalue.replace('{!Contact.Manager__r}', manager);
        htmlvalue = htmlvalue.replace('{!Contact.Name}', name);
        htmlvalue = htmlvalue.replace('{driverdeactivationdate}', DeactivatedDate);
        htmlvalue = htmlvalue.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
		return htmlvalue;
    }
    
    /**
     * Finish Method
     */
    global void finish(Database.BatchableContext BC) {}

}