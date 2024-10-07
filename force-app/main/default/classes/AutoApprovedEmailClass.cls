/**
 * @Author: GetonCRM Solutions LLP
 * @Description: Batch to send email notification for pending mileages to selected Account Managers
 * @Modification logs
 * ========================================================================================================================
 * @Date: 27 May 2020 | Sanjay Halpati
 * @description: Added Email logs & used Utils method to create emails, and optimized code.
 */
global class AutoApprovedEmailClass implements Database.Batchable<sObject>, Database.Stateful{
    global Map<Id, Employee_Reimbursement__c> conIdToReimMap;
    global Map<Id, list<contact>> manToDriverMap;
    global List<Contact> conlist;
    List<OrgWideEmailAddress> owea;
    EmailTemplate emailTemplate;
    SendEmailToMe__c  emailConfig = SendEmailToMe__c.getValues('AutoApprovedEmailClass');
            
    /*
        Constructor
    */ 
    global AutoApprovedEmailClass(){
        String query = 'SELECT Id, ' +
                ' Role__c, ' +
                ' account.Enable_Email_For_Managers__c, ' +
                ' Deactivated_Date__c, External_Email__c,' +
                ' Account.Approval_Template_Message__c, '+
                ' Monthly_Mileage_Limit__c,' +
                ' Name,' + 
                '( SELECT Role__c, Id, name, Monthly_Mileage_Limit__c FROM drivers__r ) ' +
                ' FROM contact ' + 
                ' WHERE AccountId != null ' +
                ' AND Account.Enable_Email_For_Managers__c = true' +
                ' AND Role__c != null ' + 
                ' AND (Driver_Type__c != \'Driver - Part Time\' OR Driver_Type__c != \'Driver - Full Time\')' +
                ' AND External_Email__c != null' ;

        Datetime currentDate = System.now();

        owea = [SELECT  Id, 
                        Address
                    FROM OrgWideEmailAddress
                    WHERE Address = 'driverservices@mburse.com' ];
        
        emailTemplate = [SELECT Id, 
                                HtmlValue, 
                                Name, 
                                Subject 
                            FROM EmailTemplate 
                                WHERE DeveloperName =: 'Auto_Approval_Template'];


        String lastMonth = Utils.fetchMonths(1, 0)[0]; // Fetch Last month in format MM-YYYY
        
        List<String> accountNames = new List<String>();

        if(Utils.CheckNulls(System.Label.TripstobeLogged)) {   
            accountNames = Utils.SplitStringToList( System.Label.TripstobeLogged, ',');  
        }   
        
        conIdToReimMap = new  Map<Id, Employee_Reimbursement__c> ();
        manToDriverMap = new Map<Id, list<Contact>> ();
        conlist = new List<Contact>();

        if(!accountNames.isEmpty()){
            
            List<Id> userContactIds = new  List<Id>();
            for(User u: [SELECT ContactId 
                                FROM user 
                                    WHERE IsActive = : true 
                                    AND ContactId != null 
                                    AND contact.accountid != null 
                                    AND contact.account.Enable_Email_For_Managers__c = true 
                                    AND contact.account.Name =: accountNames])  {
                userContactIds.add(u.ContactId);
            }
            query += ' AND Id In: userContactIds';

            if(!Test.isRunningTest()) {
                query += ' AND account.Name In: accountNames' +
                         ' AND (Deactivated_Date__c = NULL OR Deactivated_Date__c <=: currentDate)';
            } else {
                query += ' LIMIT 1';
            }

            conlist = Database.query(query);
            if(!conlist.isEmpty()){
                List<Id> driverIds = new  List<Id>();
                for(Contact c : conlist){
                    for(contact dr : c.Drivers__r) {
                        driverIds.add(dr.id);
                    }
                }

                for(Contact c : [SELECT Name,
                                        Manager__c, 
                                        (SELECT Id,  
                                                month__c, 
                                                status__c,
                                                Total_Mileage__c 
                                            FROM Employee_Reimbursements__r 
                                                WHERE month__c = : lastmonth ),  
                                        Monthly_Mileage_Limit__c
                                    FROM Contact 
                                        WHERE Manager__c in: driverIds]) {

                    if(manToDriverMap.Containskey(c.Manager__c)) {
                        manToDriverMap.get(c.Manager__c).add(c);
                    } else {
                        manToDriverMap.put(c.Manager__c, new List<Contact> { c });
                    }
                }         
                
                for(Employee_Reimbursement__c ri : [SELECT Id, 
                                                            Name, 
                                                            Month__c, 
                                                            status__c, 
                                                            Total_Mileage__c, 
                                                            Contact_id__c 
                                                        FROM Employee_Reimbursement__c 
                                                            WHERE Contact_id__c in: driverIds 
                                                            AND Month__c = : lastmonth]){
                    conIdToReimMap.put(ri.Contact_id__c, ri);
                }
            }
        }
    }

    /*
        Start Method
    */ 
    global list<contact> start(Database.BatchableContext BC){ 
        return conlist;
    }
    
    /*
        Execute Method
    */ 
    global void execute(Database.BatchableContext BC, list<contact> conlist) {

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Email_Log__c> emailLogs = new List<Email_Log__c>();

        String month = datetime.now().addMonths(-1).format('MMMM');
        String reportTo = '<th style="border:2px solid black;" width="5%">Report To</th>';
        Boolean isAdmin;
        for(Contact con: conlist) {
            String html = '';
            isAdmin = (con.role__c == 'Admin' || con.role__c == 'Driver/Admin');
            String newBody = emailTemplate.HtmlValue;
            if(!String.isBlank(con.Account.Approval_Template_Message__c)) {
                String accountMessage = con.Account.Approval_Template_Message__c.replace('{month}', month);
                newBody = newBody.replace('{account.Approval_Template_Message__c}', accountMessage);
            }else {
                newBody = newBody.replace('{account.Approval_Template_Message__c}','');
            }

            newBody = newBody.replace('{reportToTR}', isAdmin ? reportTo : '');

            for(Contact co: con.drivers__r) {
                if(conIdToReimMap.Containskey(co.id)) {
                    
                    Decimal monthlyLimit = co.Monthly_Mileage_Limit__c != null ? co.Monthly_Mileage_Limit__c : 0;
                    
                    if(conIdToReimMap.get(co.id).Total_Mileage__c != Null && conIdToReimMap.get(co.id).Total_Mileage__c > 0) {
                        html = CreateHtml(co, conIdToReimMap.get(co.id), monthlyLimit, isAdmin, co.Name);
                    }
                }

                if(manToDriverMap.Containskey(co.id)) {
                    for(contact c: manToDriverMap.get(co.id)) {
                        if(!c.Employee_Reimbursements__r.isEmpty()) {

                            Decimal monthlyLimit = c.Monthly_Mileage_Limit__c != null ? c.Monthly_Mileage_Limit__c : 0;
                            
                            if(c.Employee_Reimbursements__r[0].Total_Mileage__c != Null && c.Employee_Reimbursements__r[0].Total_Mileage__c > 0){ 
                                html += CreateHtml(c, c.Employee_Reimbursements__r[0], monthlyLimit, isAdmin, co.Name); 
                            }
                        }
                    }
                }

                system.debug(html);
                newBody = newBody.replace('{tableDynamicData}', html);
            }

            if(!con.drivers__r.isEmpty() && newBody.contains('</td>')) {

                String[] toAddresses = emailConfig.Send_email_to_me__c ? 
                                        new string[]{'sanket.goc@gmail.com'} :
                                        new string[]{con.External_Email__c};
                
                String[] bccAddresses = emailConfig.SetBccAddress__c ? 
                                        new string[]{'minkesh.patel@getoncrm.com'} :
                                        null;
                
                messaging.singleEmailMessage mail = Utils.CreateEmail(emailTemplate.Subject, newBody, toAddresses, null, bccAddresses, null);
                emailLogs.add(
                    Utils.CreateEmailLog(emailTemplate.Subject, newBody, toAddresses, null, bccAddresses, null, 'AutoApprovedEmailClass')
                );

                if(!owea.isEmpty())  {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                mails.add(mail);    
                
            }
        }

        SendEmail__c  objSendEmail = SendEmail__c.getValues('AutoApprovedEmailClass');
        if(!mails.isEmpty() && !Test.isRunningTest() && objSendEmail != null && objSendEmail.Send_email_from_code__c) {
            Messaging.SendEmailResult [] result = Messaging.sendEmail(mails, false);
            Utils.SaveEmailLogs(emailLogs, result);    
        }

    }

    /*
        Finish Method
    */ 
    global void finish(Database.BatchableContext BC){

    }

    /**
     * Method to create HTML body String
     */
    global String CreateHtml(Contact con, Employee_Reimbursement__c reim, Decimal monthlyLimit, Boolean isAdmin, String cName) {
        String conStr = '<tr align="center">' + 
                        '<td style="border:2px solid black;">' + con.Name + '</td>' + 
                        '<td style="border:2px solid black;">' + reim.Month__c + '</td>' +
                        '<td style="border:2px solid black;">' + monthlyLimit + '</td>' + 
                        '<td style="border:2px solid black;">' + reim.Total_Mileage__c + '</td>' + 
                        '<td style="border:2px solid black;">' + reim.status__c + '</td>';
        if(isAdmin) {
            conStr += '<td style="border:2px solid black;" width="5%">' + cName + '</td>';
        }
        conStr += '</tr>';

        return conStr;
    }
}