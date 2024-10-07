/**
* @Author:  GetonCRM SOlutions LLP
* @Description: Batch to Update trip Status in TripLog org & Send email notifications
* @Modification logs
* ========================================================================================================================
* @Date: 28 May 2020 | Sanjay Halpati
* @description: Added Email logs & used Utils method to create emails, and optimized code.
*/
global class ChangeTripStatusinTripLog implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    public Map<String,List<String>> approveReimwithTripIdMap;
    public Map<String,List<String>> rejectReimwithTripIdMap;
    public Map<String,List<String>> approveReimbursmentMap;
    public Map<String,List<String>> rejectReimbursmentMap;
    public List<EmailTemplate> eTemplateList;
    public String nameOfManager;
    public String emailAddressOfManager;
    public SendEmailToMe__c emailConfig = SendEmailToMe__c.getValues('ChangeTripStatusinTripLog');
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL;
    Set<Id> reimbursementIds;
    OrgWideEmailAddress[] owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'driverservices@mburse.com']; 
    
    /**
* Constructor
*/
    public ChangeTripStatusinTripLog(List<String> approvedIds, List<String> rejectedIds, String name, String emailaddress) {
        
        this.nameOfManager = name;
        this.emailAddressOfManager = emailaddress;
        approveReimwithTripIdMap = new Map<String, List<String>>();
        rejectReimwithTripIdMap = new Map<String,List<String>>();
        reimbursementIds = new Set<Id>();
        approveReimbursmentMap = new Map<String,List<String>>();
        rejectReimbursmentMap = new Map<String,List<String>>(); 
        
        // Email Template 
        eTemplateList = [SELECT Id, 
                         Subject,
                         HtmlValue, 
                         body 
                         FROM EmailTemplate 
                         WHERE developerName = 'flagmileageprocess']; 
        
        
        
        for(Employee_Mileage__c mil : [Select Id,
                                       EmployeeReimbursement__c,
                                       Trip_Id__c,
                                       EmployeeReimbursement__r.Contact_Id_Deactivated_Date__c,
                                       Trip_Date__c 
                                       FROM Employee_Mileage__c 
                                       WHERE Trip_Id__c !=null AND Id In: approvedIds]) {    
                                           
                                           if(approveReimbursmentMap.containsKey(mil.EmployeeReimbursement__c)) {
                                               approveReimbursmentMap.get(mil.EmployeeReimbursement__c).add(mil.Id);
                                               if(mil.EmployeeReimbursement__r.Contact_Id_Deactivated_Date__c == null && approveReimwithTripIdMap.containsKey(mil.EmployeeReimbursement__c) && mil.Trip_Date__c.month() != Date.Today().Month()){
                                                   approveReimwithTripIdMap.get(mil.EmployeeReimbursement__c).add( String.valueOf(mil.Trip_Id__c));                    
                                               }
                                               
                                           } else {
                                               approveReimbursmentMap.put(mil.EmployeeReimbursement__c, new List<String> {mil.Id});
                                               if(mil.EmployeeReimbursement__r.Contact_Id_Deactivated_Date__c == null && mil.Trip_Date__c.month() != Date.Today().Month()){
                                                   approveReimwithTripIdMap.put(mil.EmployeeReimbursement__c, new List<String> { String.valueOf(mil.Trip_Id__c)});
                                               }
                                               
                                           }
                                           reimbursementIds.add(mil.EmployeeReimbursement__c);
                                           
                                       }
        for(Employee_Mileage__c mil : [ Select Id,
                                       EmployeeReimbursement__c,
                                       Contact_Email_Id__c,
                                       EmployeeReimbursement__r.Contact_Id__r.Manager__r.FirstName,
                                       EmployeeReimbursement__r.Contact_Id_Name__c,
                                       Trip_Id__c,
                                       EmployeeReimbursement__r.Contact_Id_Deactivated_Date__c,
                                       Trip_Date__c 
                                       FROM Employee_Mileage__c 
                                       WHERE Trip_Id__c != null AND Id In: rejectedIds]) {    
                                           nameofmanager = mil.EmployeeReimbursement__r.Contact_Id__r.Manager__r.FirstName;
                                           
                                           if(rejectReimbursmentMap.containsKey(mil.EmployeeReimbursement__c)) {
                                               rejectReimbursmentMap.get(mil.EmployeeReimbursement__c).add(mil.Id);
                                               if(mil.EmployeeReimbursement__r.Contact_Id_Deactivated_Date__c == null && rejectReimwithTripIdMap.containsKey(mil.EmployeeReimbursement__c) && mil.Trip_Date__c.month() != Date.Today().Month()){
                                                   rejectReimwithTripIdMap.get(mil.EmployeeReimbursement__c).add(String.valueOf(mil.Trip_Id__c));
                                               }
                                               
                                           } else {
                                               rejectReimbursmentMap.put(mil.EmployeeReimbursement__c, new List<String> {mil.Id});
                                               if(mil.EmployeeReimbursement__r.Contact_Id_Deactivated_Date__c == null && mil.Trip_Date__c.month() != Date.Today().Month()){
                                                   rejectReimwithTripIdMap.put(mil.EmployeeReimbursement__c, new List<String> { String.valueOf(mil.Trip_Id__c)});
                                               }
                                           }
                                           reimbursementIds.add(mil.EmployeeReimbursement__c);
                                           
                                       }
        
    }    
    
    /**
* Start Method
*/
    global List<Employee_Reimbursement__c> start(Database.BatchableContext BC) {
        return [Select ID,
                Status__c,
                Contact_Id__c,
                Contact_Id__r.FirstName,
                Contact_Id__r.External_Email__c,
                Contact_Id__r.Manager__r.Name,
                Contact_Id__r.Manager__r.FirstName,                        
                Contact_Id__r.Account.Triplog_API__c,
                Month__c 
                FROM Employee_Reimbursement__c 
                WHERE Id In: reimbursementIds
                AND Contact_Id__r.Account.isUsingTriplog__c = true];
    }
    
    /**
* Execute Method
*/
    global void execute(Database.BatchableContext BC, List<Employee_Reimbursement__c> scope) {
        List<Tripslog__c> triplogsList = new List<Tripslog__c>();
        List<Employee_Mileage__c> mileagesList = new List<Employee_Mileage__c>(); 
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        List<Email_Log__c> emailLogs = new List<Email_Log__c>(); 
        
        for(Employee_Reimbursement__c reim : (List<Employee_Reimbursement__c>) scope) {
            String body ='';                       
            if(approveReimwithTripIdMap.containsKey(reim.id)) {
                
                if(emailConfig != null && emailConfig.Send_email_to_me__c ) {
                    body = BuildBody( 'Approved', approveReimwithTripIdMap.get(reim.id));
                    /*triplogsList.add(
callPutApi(
String.valueOf(reim.Contact_Id__r.Account.Triplog_API__c),
body,
reim.Contact_Id__c,
reim.id,
approveReimwithTripIdMap.get(reim.id).size()
)
);*/
                }
                
                List<Employee_Mileage__c> mileagesToUpdate = UpdateMileages(approveReimbursmentMap.get(reim.id),'Approved');
                if(!mileagesToUpdate.isEmpty()) {
                    mileagesList.addAll(mileagesToUpdate); 
                } 
                
            }
            
            if(rejectReimwithTripIdMap.containsKey(reim.id)) {
                if(emailConfig != null && emailConfig.Send_email_to_me__c){
                    body = BuildBody('Rejected',rejectReimwithTripidMap.get(reim.id));
                    //triplogsList.add(callPutApi(String.valueOf(reim.Contact_Id__r.Account.Triplog_API__c),body,reim.Contact_Id__c,reim.id,rejectReimwithTripIdMap.get(reim.id).size())); 
                }
                
                List<Employee_Mileage__c> mileagesToUpdate = UpdateMileages(rejectReimbursmentMap.get(reim.id), 'Rejected' );
                if(!mileagesToUpdate.isEmpty()) {
                    
                    SendEmailonDeactivation__c customFlagSettings = SendEmailonDeactivation__c.getValues('flagmileagesemaildriver');                   
                    
                    String newemailBody = eTemplateList[0].HtmlValue;
                    List<String> emailsToSent = new List<String>();
                    List<String> toAddress = new List<String>();
                    List<String> bccAddress = new List<String>();
                    List<String> months = new List<String>();
                    Map<Integer,String> monthNameMap = new Map<Integer, String>{
                        01 =>'January', 
                            02=>'February', 
                            03=>'March', 
                            04=>'April', 
                            05=>'May',
                            06=>'June', 
                            07=>'July', 
                            08=>'August', 
                            09=>'September',
                            10=>'October',
                            11=>'November', 
                            12=>'December'
                            };
                                
                                if(customFlagSettings != null) {
                                    if(Utils.CheckNulls(customFlagSettings.BCCEmailaddresses__c) && customFlagSettings.Send_to_me__c )   {
                                        bccAddress = Utils.SplitStringToList(customFlagSettings.BCCEmailaddresses__c, ',');
                                    }
                                    
                                    if(customFlagSettings.Send_to_Driver__c) {
                                        if(reim.Contact_Id__r.External_Email__c != null) {
                                            toAddress.add(reim.Contact_Id__r.External_Email__c);
                                        } else {
                                            toAddress = bccAddress;
                                        }
                                    } else if(customFlagSettings.Send_to_me__c) {
                                        toAddress.addAll(bccAddress);
                                        bccAddress.clear();
                                    }
                                }
                    
                    //AI-000422
                    if(reim.Month__c != null ){
                        months = reim.Month__c.split('-');
                    } 
                    newemailBody = newemailBody.replace('{Contact.Name}',reim.Contact_Id__r.FirstName);  
                    newemailBody = newemailBody.replace('{!Contact.Manager__c}',reim.Contact_Id__r.Manager__r.Name); 
                    newemailBody = newemailBody.replace('{!Contact.Manager__r}',reim.Contact_Id__r.Manager__r.FirstName);
                    newemailBody = newemailBody.replace('{!Month__c}',monthNameMap.get(Integer.valueOf(months[0]) ));  
                    newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                    
                    messaging.singleEmailMessage email = Utils.CreateEmail(
                        eTemplateList[0].Subject, 
                        newemailBody, 
                        toAddress, 
                        null, 
                        bccAddress, 
                        null
                    );       
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                    emailLogs.add(
                        Utils.CreateEmailLog( 
                            eTemplateList[0].Subject, 
                            newemailBody, 
                            toAddress, 
                            null, 
                            bccAddress, 
                            null,
                            'ChangeTripStatusinTripLog'
                        )
                    );
                    mails.add(email);
                    mileagesList.addAll(mileagesToUpdate); 
                }       
            }
        }
        
        if(!mails.isEmpty() && !Test.IsRunningTest()) {                        
            Messaging.SendEmailResult [] result = Messaging.sendEmail(mails, false);
            Utils.SaveEmailLogs(emailLogs, result); 
        }
        
        if(!triplogsList.isEmpty())
            insert triplogsList;
        
        if(!mileagesList.isEmpty()){
            //update mileagesList;
        }
        
    }
    
    /**
* Finish Method
*/
    global void finish(Database.BatchableContext BC) {
        
        List<Employee_Reimbursement__c> employeeReimbursementList = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c reim : [Select Id,
                                              Total_Pending__c 
                                              FROM Employee_Reimbursement__c 
                                              WHERE Id IN: reimbursementIds and Total_Pending__c = 0 ]) {
                                                  reim.Status__c = 'Approved';
                                                  reim.Approved_Date__c = System.Today();
                                                  employeeReimbursementList.add(reim);
                                              }
        
        if(!employeeReimbursementList.isEmpty()) {
            update employeeReimbursementList;
        }
        List<EmailTemplate> emailTemplateList = [SELECT Id, 
                                                 Subject,
                                                 HtmlValue, 
                                                 body 
                                                 FROM EmailTemplate 
                                                 WHERE developerName = 'mileageprocess']; 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Email_Log__c> emailLogs = new List<Email_Log__c>(); 
        String newBody = emailTemplateList[0].HtmlValue;
        SendEmailonDeactivation__c sendEmailConfig = SendEmailonDeactivation__c.getValues('mileageprocess');       
        List<String> bccAddresses = new List<String>();
        List<String> toAddresses = new List<String>();
        
        if(sendEmailConfig !=null) {
            if(Utils.CheckNulls(sendEmailConfig.BCCEmailaddresses__c) && sendEmailConfig.Send_to_me__c) {
                bccAddresses = Utils.SplitStringToList(sendEmailConfig.BCCEmailaddresses__c, ',');  
            }
            if(sendEmailConfig.Send_to_Admin__c || sendEmailConfig.Send_to_Manager__c) {
                toAddresses.add(emailAddressOfManager);
            }
            
            if(!toAddresses.isEmpty() || !bccAddresses.isEmpty()) {
                newBody = newBody.replace('{Contact.Name}', nameofmanager );    
                newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                
                Messaging.SingleEmailMessage email = Utils.CreateEmail(
                    emailTemplateList[0].Subject, 
                    newBody, 
                    !toAddresses.isEmpty() ? toAddresses : bccAddresses, 
                    null, 
                    !toAddresses.isEmpty() ? bccAddresses : null, 
                    null
                );           
                email.setOrgWideEmailAddressId(owea.get(0).Id);
                
                emailLogs.add(
                    Utils.CreateEmailLog( 
                        emailTemplateList[0].Subject, 
                        newBody, 
                        !toAddresses.isEmpty() ? toAddresses : bccAddresses, 
                        null, 
                        !toAddresses.isEmpty() ? bccAddresses : null, 
                        null,
                        'ChangeTripStatusinTripLog'
                    )
                );
                emails.add(email);
            }
            
            if(!emails.isEmpty() && !Test.IsRunningTest()) {                        
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emails, false);
                Utils.SaveEmailLogs(emailLogs, result); 
            }
        }
        // Send an email to Loggedin User that your request is Proccesed Successfully.
        /*send email to driver when mileage is flag by admin or manager */
        
    }
    
     /**
    * Method to update Mileages
    */
    public List<Employee_Mileage__c> UpdateMileages(List<String> mileageIds, String status) {
        List<Employee_Mileage__c> mileages = new List<Employee_Mileage__c>();
        for(String mileageId : mileageIds) {
            Employee_Mileage__c mil = new Employee_Mileage__c(
                Id = mileageId,
                Trip_Status__c = status,
                Approved_Date__c = System.Today(),
                Rejected__c = (status == 'Approved' ? false : true)
            );            
            mileages.add(mil);
        }
        return mileages;
    }   
    
    public Tripslog__c callPutApi(String ApiKey, String bodyOfReq, String contactId, String reimbursementId, Integer totalTrips) {
        String baseURL = !MLOGACCOUNT.Contains(ApiKey) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        Http putHTTP = new Http(); 
        HttpRequest putReq = new HttpRequest();               
        HttpResponse putRes = new HttpResponse();
        putReq.setEndpoint(baseURL + '/api/tripStatus');
        putReq.setMethod('PUT');                 
        putReq.setBody(bodyOfReq);
        putReq.setTimeout(120000);
        putReq.setHeader('Authorization', 'apikey ' + ApiKey);
        
        if(!Test.IsRunningTest()) {
            putRes = putHTTP.send(putReq);
        }
        
        Tripslog__c triplogobj = new Tripslog__c();
        triplogobj.Body__c = bodyOfReq;
        triplogobj.Contact__c = contactId;
        triplogobj.Employee_Reimbursement__c = reimbursementId;
        triplogobj.Endpoint__c = baseURL + '/api/tripStatus';
        if(!Test.IsRunningTest()) {
            triplogobj.Response__c = putRes.getStatusCode() + ' ######## ' + putRes.getStatus();
        }
        triplogobj.Total_Trips__c = totalTrips;
        triplogobj.Total_Mileages__c = 0;
        triplogobj.Status__c = !Test.IsRunningTest() && putRes.getStatusCode() == 200 ? 
            'Success' :
        'Fail';
        return triplogobj;
    }
     /*
    * Build Put call body
    */
    public static String BuildBody(String status, List<String> mileageIds) {
        return '{"status":' + status + ',"ids":[' + String.join(mileageIds, ',') + ']}';
    }  
}