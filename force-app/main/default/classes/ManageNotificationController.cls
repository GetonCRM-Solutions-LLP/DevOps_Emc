/**
* @description       : 
* @author            : Vatsal Bhalani
* @group             : 
* @last modified on  : 10-21-2024
* @last modified by  : Vatsal Bhalani
**/
public without sharing class ManageNotificationController {
    public static String accId;
    public static String adminId;
    public static String query;
    private static string conWrapper {get; set;} 
    public static Boolean checkTrueDialog {get; set;} 
    
    /** 
* ********************************************************
Developer Name : Dhanraj Khatri
* sendMessageToMultipleContacts - Method for Sending Message to multiple contacts
*Parameters:
trueDialogContactIdList : JSON of List Of TrueCaller Contact Id
message : message
Note : 1.ActionId will be same for all the message that will send in bulk.
* ********************************************************
*/
    
    @AuraEnabled
    public static String sendMessageToMultipleContacts(String trueDialogContactIdList,String message){   
        //System.debug('**in  sendMessageToMultipleContacts**');
        //System.debug('**trueDialogContactIdList**'+trueDialogContactIdList);
        //System.debug('**message**'+message);
        
        List<String> trueDialogContactIdListArray = (List<String>)System.JSON.deserialize(trueDialogContactIdList, List<String>.class);
        String result;
        try {
            HttpResponse response = new HttpResponse();
            
            String requestBody = TrueDiaolgSendMessageWrapper.generateBulkSendMessageReqBody(trueDialogContactIdListArray,message);
            response = TrueDialogAPICallout.executeCallout('POST','action-pushCampaign',requestBody,null);   
            
            List<Message__c> lstMessage = new List<Message__c>();
            
            Database.SaveResult[] saveResultList ;
            
            if (response.getStatusCode() < 300) {               
                TrueDiaolgSendMessageWrapper trueDialogWrapper = TrueDiaolgSendMessageWrapper.parse(response.getBody());                
                for(Contact con : [Select Id,TrueDialog_Contact_Id__c FROM Contact 
                                   WHERE TrueDialog_Contact_Id__c IN: trueDialogContactIdListArray]){
                                       
                                       Message__c objMsg = new Message__c();
                                       objMsg.Contacts__c = con.Id;
                                       objMsg.Action_Id__c = trueDialogWrapper.id;
                                       objMsg.Message__c = message;
                                       lstMessage.add(objMsg);
                                   }
                saveResultList = Database.insert(lstMessage, false);
            } else {  
                String trueDialogError = response.getBody() + ',' + response.getStatusCode() + ': ' + response.getStatus() + '\n';
                result = 'failed';
                //System.debug(trueDialogError);     
            }
            
            for(Integer i=0;i<saveResultList.size();i++){
                if (saveResultList[i].isSuccess()) {
                    //System.debug('Successfully inserted message. Message ID: ' + saveResultList[0].getId());
                    result = 'success';
                }else {                 
                    result = 'failed';
                    break;
                }
            }     
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }       
        return result;            
    }    
    
    
    /**
* @description 
* This method sends an image to multiple contacts via the TrueDialog API, stores the image in Salesforce as a content version and document, links it to the messages, and updates each message with the image URL.
* @author Vatsal Bhalani | 10-21-2024 
* @param trueDialogContactIdList 
* @param attachmentBody 
* @param attachmentName 
* @param message 
* @return String 
**/
    @AuraEnabled
    public static String sendImageToMultipleContacts(String trueDialogContactIdList,String attachmentBody, String attachmentName,String message){
        
        TrueDialog_Keys__c tdKeys = TrueDialog_Keys__c.getValues('TrueDialogKeys');
        List<String> trueDialogContactIdListArray = (List<String>)System.JSON.deserialize(trueDialogContactIdList, List<String>.class);
        String result;
        
        HttpResponse res = TrueDialogSendMessageAPI.postImageToTrueDialog(trueDialogContactIdList,attachmentBody,attachmentName,message);
        
        Database.SaveResult[] saveResultList ;
        
        if(res.getStatusCode() < 300) {
            
            List<Message__c> lstMessage = new List<Message__c>();
            for(Contact objContact : [SELECT Id FROM Contact 
                                      WHERE TrueDialog_Contact_Id__c IN: trueDialogContactIdListArray]){
                                          
                                          Message__c messageRecord = new Message__c();
                                          messageRecord.Contacts__c = objContact.Id;
                                          messageRecord.Message__c = message;
                                          lstMessage.add(messageRecord);
                                      }
            saveResultList = Database.insert(lstMessage, false);
            
            ContentVersion objCV = new ContentVersion();
            objCV.Title = attachmentName;
            objCV.PathOnClient = attachmentName;
            objCV.VersionData = EncodingUtil.base64Decode(attachmentBody);
            objCV.IsMajorVersion = true;
            Insert objCV;  
            
            //System.debug('Content Version'+objCV);
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCV.Id].ContentDocumentId;  
            
            List<ContentDocumentLink> cdlList = New List<ContentDocumentLink>();
            for(Message__c messageRecord : lstMessage){
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = messageRecord.Id;
                cdl.ContentDocumentId = conDocId;
                cdl.shareType = 'V';
                cdlList.add(cdl) ;
            }
            
            List<Folder> lstMMSImageFolder = [SELECT Id,name FROM Folder where name ='MMS Image' Limit 1];
            
            //System.debug('**Size***'+lstMMSImageFolder.size());
            //System.debug('***lstMMSImageFolder***'+lstMMSImageFolder);
            
            Document objDocument = new Document();
            
            if(lstMMSImageFolder.size()>0){
                
                objDocument.FolderId = lstMMSImageFolder[0].Id;
                objDocument.Body = objCV.versionData;
                objDocument.Name = attachmentName;
                objDocument.ispublic = true;
                insert objDocument;
            }
            
            //System.debug('***objDocument**'+objDocument);
            
            
            // List<String> domain = URL.getSalesforceBaseUrl().toExternalForm().split('.my');
            // String imageURL = domain[0]+'--c.documentforce.com/servlet/servlet.ImageServer?id='+objDocument.id+'&oid='+UserInfo.getOrganizationId();
            
            String imageURL = tdKeys.Document_URL__c+objDocument.id+'&oid='+UserInfo.getOrganizationId();
            
            for(Message__c messageRecord : lstMessage){
                messageRecord.Media_Link__c = imageURL;
            }
            
            update lstMessage;    
            
            result='success';
        }else{
            result = 'failed';
        }  
        
        return result;
        
    }  
    
    // Not in use
    // public static String getUnreadMessageCount(){} 
    
    
    // Not in use
    // public static String UpdateUnreadMessageStatus(String contactId){}
    
    
    // This method manages notifications by checking if an account has a TrueDialog setup, and retrieves employee data using the account and admin ID.
    @AuraEnabled
    public static String manageNotificationController(String accId,String adminId) {    
        if(accId != null){
            Account objAccount = [SELECT id,True_Dialog__c FROM Account WHERE id =: accId];
            checkTrueDialog = objAccount.True_Dialog__c != null ? objAccount.True_Dialog__c : false;
            conWrapper = NewEmployeeData(accId,adminId );
        }
        //System.debug('conWrapper: ' +conWrapper);
        return conWrapper;
    }
    
    // Not in use
    // public static String NewConData(String accountId){}
    
    // This method retrieves and constructs a list of `ContactWrapper` objects for contacts associated with a given account ID, based on the role of the provided admin contact ID. It returns the serialized list of contact wrappers, excluding admin contacts and considering the admin's managerial hierarchy if applicable.
    @RemoteAction
    public static string NewEmployeeData(String accountId, String adminId) {
        List<Contact> lstContacts = [
            SELECT Role__c
            FROM Contact
            WHERE Id = :adminId
        ];
        
        // Early exit if no contact is found
        if (lstContacts.isEmpty()) {
            return JSON.serialize(new List<ContactWrapper>());
        }
        
        String role = lstContacts[0].Role__c;
        
        List<ContactWrapper> lstContactWrap = new List<ContactWrapper>();
        Boolean isAdmin = (role == StaticValues.ROLE_ADMIN || role == StaticValues.roleAdminDriver);
        
        // Build the query for contacts
        String query = 'SELECT Id, FirstName, LastName, toLabel(Insurance__c), Expiration_Date__c, '
            + 'Notification_Message__c, External_Email__c, Triplog_UserID__c, TrueDialog_Contact_Id__c, '
            + 'Insurance_Attachment_Id__c, Notification_Date__c, Unread_Message_Count__c, Contact_Picture__c, Role__c '
            + 'FROM Contact WHERE AccountId = :accountId AND Role__c != \'Admin\' AND Deactivated_Date__c = null ';
        
        // Add additional conditions based on the role
        if (!isAdmin) {
            query += 'AND (Manager__c = :adminId OR Manager__r.Manager__c = :adminId OR Manager__r.Manager__r.Manager__c = :adminId OR Manager__r.Manager__r.Manager__r.Manager__c = :adminId) ';
        }
        
        query += 'ORDER BY FirstName';
        
        // Execute the query
        List<Contact> contacts = Database.query(query);
        
        // Process each contact and create a wrapper
        for (Contact con : contacts) {
            ContactWrapper conWrap = createContactWrapper(con);
            lstContactWrap.add(conWrap);
        }
        
        return JSON.serialize(lstContactWrap);
    }
    
    
    // * @description 
    // * This method updates employee notification details, logs messages, and sends emails based on the input employee data. 
    // * It uses OrgWideEmailAddress and EmailTemplate, handles bulk updates for contacts, and sends notification emails.
    @AuraEnabled
    public static string editInlineNewEmployee(String listofemployee, String adminId) {
        //System.debug('listofemployee=' + listofemployee);
        
        // Query admin contact only once
        Contact objAdminContact = [SELECT Name FROM Contact WHERE Id =: adminId LIMIT 1];
        
        // Query OrgWideEmailAddress once
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'driverservices@mburse.com' LIMIT 1];
        
        // Query EmailTemplate once
        EmailTemplate emailTemplate = [SELECT Id, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'New_Notification_For_Driver' LIMIT 1];
        
        List<Contact> lstEmployeeUpdate = new List<Contact>();
        List<Message__c> msgList = new List<Message__c>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        if (listofemployee != null) {
            // Deserialize JSON only once
            List<ContactWrapper> lstConWrapUpdate = (List<ContactWrapper>) Json.deserialize(listofemployee, List<ContactWrapper>.class);
            
            // Prepare email template outside loop
            String templateSubject = emailTemplate.Subject;
            String templateHtmlBody = emailTemplate.HTMLValue;
            
            // Process each ContactWrapper
            for (ContactWrapper objContactWrap : lstConWrapUpdate) {
                Contact currentContact = new Contact(
                    Id = objContactWrap.contactId,
                    Notification_Message__c = objContactWrap.notiMessage,
                    Notification_Date__c = System.today()
                );
                
                Message__c objMsg = new Message__c(
                    Notification_Message__c = objContactWrap.notiMessage,
                    Contacts__c = objContactWrap.contactId,
                    Unread__c = true
                );
                
                lstEmployeeUpdate.add(currentContact);
                msgList.add(objMsg);
                
                // Prepare email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(owea.Id);
                mail.setToAddresses(new List<String>{objContactWrap.contactEmail});
                mail.setSubject(templateSubject);
                
                // Replace placeholders in email body
                String htmlbody = templateHtmlBody;
                if (objContactWrap.name != null) {
                    htmlbody = htmlbody.replace('{!Contact.Name}', objContactWrap.name);
                }
                htmlbody = htmlbody.replace('{!AdminName}', objAdminContact.Name);
                htmlbody = htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                
                mail.setHtmlBody(htmlbody);
                mail.setPlainTextBody(htmlbody);
                mail.setBccAddresses(new List<String>{'driverservices@mburse.com'});
                
                mailList.add(mail);
            }
        }
        
        // Bulk update and insert outside loops
        if (!lstEmployeeUpdate.isEmpty()) {
            update lstEmployeeUpdate;
        }
        if (!msgList.isEmpty()) {
            insert msgList;
        }
        
        // Send emails in bulk
        SendEmail__c sendEmailObj = SendEmail__c.getValues('SendMileageReminderforDelta');
        if (sendEmailObj != null && sendEmailObj.Send_email_from_code__c && !mailList.isEmpty()) {
            Messaging.sendEmail(mailList);
        }
        
        return 'Success';
    }
    
    //This method sends insurance declaration emails to a list of employees. It retrieves an email template, sets up email details, and sends mass emails through the OrgWideEmailAddress.
    @AuraEnabled
    public static string sendAllInsuranceEmail(String listofemployee,String adminId) {
        
        Contact objContact = [SELECT name 
                              FROM Contact 
                              WHERE id =:adminId
                              LIMIT 1];
        
        //System.debug('objContact'+objContact);
        
        EmailTemplate templateId = [SELECT Subject,HtmlValue FROM EmailTemplate WHERE developerName = 'Insurance_Declaration_Noti' Limit 1];
        
        OrgWideEmailAddress[] owea = [SELECT Id,Address FROM OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        
        Messaging.SingleEmailMessage objMail;
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        
        if(listofemployee!=null)
        {
            List<ContactWrapper> conWrapUpdateList = new List<ContactWrapper>();
            conWrapUpdateList = (List<ContactWrapper>)Json.deserialize(listofemployee,List<ContactWrapper>.class);
            for(ContactWrapper conwrap : conWrapUpdateList){ 
                if(conwrap.massEmail = true){
                    
                    List<String> sendingTo = new List<String>();
                    sendingTo.add(conwrap.contactEmail);
                    
                    string htmlbody = templateId.HTMLValue;
                    if(conwrap.name != null){
                        htmlbody = htmlbody.replace('{!Contact.Name}',conwrap.name);
                    }
                    if(objContact.name != null){
                        htmlbody = htmlbody.replace('{!AdminName}',objContact.name);
                    }                    
                    
                    List<String> bccaddress = new list<String>();
                    bccaddress.add('driverservices@mburse.com');
                    
                    objMail = new Messaging.SingleEmailMessage();
                    if (owea.size() > 0) {
                        objMail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    objMail.setPlainTextBody(htmlbody);
                    objMail.setToAddresses(sendingTo);
                    objMail.setSubject(templateId.Subject);
                    objMail.setBccAddresses(bccaddress);
                    objMail.setHtmlBody(htmlbody);
                    lstMails.add(objMail);
                }
            }
        }
        SendEmail__c sendEmailObj = SendEmail__c.getValues('SendMileageReminderforDelta');
        if((sendEmailObj != null) && sendEmailObj.Send_email_from_code__c == true && lstMails.size() > 0)
        {	
            try{
                Messaging.sendEmail(lstMails);  
            }catch(Exception e){
                System.debug('sendAllInsuranceEmail Exception');
            }
        } 
        return 'Success';
    }
    
    
    @AuraEnabled(cacheable=false)
    public static String readFromFileInchunk(String attachmentBody, String attachmentName, String attachmentId,String did,String accid,String contactattachementid){
        return  WrapperUtils.readFromFileInchunk(attachmentBody,attachmentName,attachmentId,did,accid,contactattachementid);   
    }
    
    // Not in use
    // public static string getdriverInsurance(string attachmentid){}
    
    //This method uploads location data in chunks of 100 records to an external Triplog or MLOG API based on the account's Triplog API token. It handles up to 2000 location records and divides them into manageable parts for upload.
    @AuraEnabled
    public static String UploadLocation(string location,string  accId) { 
        //System.debug('UploadLocation@@--');  
        //System.debug('location@@--'+location);  
        String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;   
        
        String body, apiToken;
        List<Account> lstAccounts = [SELECT Triplog_API__c  
                                     FROM Account 
                                     WHERE Triplog_API__c != null 
                                     AND Id =: accId];
        apiToken = lstAccounts[0].Triplog_API__c;
        String baseURL = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL; 
        baseURL = (baseURL + '/api/locations');
        //system.debug('baseURL@--'+baseURL);
        
        List<JSONLocation> LocationJson = JSONLocation.parse(location);
        //System.debug('LocationJson@@--'+LocationJson);  
        if(LocationJson.size() > 2000){
            throw new AuraHandledException('You cann\'t upload more than 2000 records at once.');
        }
        Map<Integer, List<String>> map100ChunksByKey = new Map<Integer, List<String>>();
        Integer i = 100;
        Integer j = 0;
        
        for(JSONLocation objLocation : LocationJson ){
            //system.debug(objLocation);
            body = JSON.serialize(objLocation);
            //system.debug('=='+body );
            if(i==100){
                i=0; 
                j=j+1;
                map100ChunksByKey.put(j,new List<String>());
            }
            map100ChunksByKey.get(j).add(body);
            i=i+1;
        }
        //System.debug('map100ChunksByKey@@-'+map100ChunksByKey.keyset());
        for(Integer Key: map100ChunksByKey.keyset())
        {           
            //HttpResponse res = ApiCalloutUtility.executeCallout(apiToken,'POST',baseURL,'',body);
            UploadBulkLocationAPI(apiToken,baseURL,map100ChunksByKey.get(Key));         
        }           
        return null;
    }
    
    @Future(callout=true)
    public static void UploadLocationAPI (String apiToken,string baseURL,String body){
        HttpResponse res = ApiCalloutUtility.executeCallout(apiToken,'POST',baseURL,'',body);
    }
    
    @Future(callout=true)
    public static void UploadBulkLocationAPI (String apiToken,string baseURL,List<String> lstBodies){
        //System.debug('UploadBulkLocationAPI@@-');
        for(String body:lstBodies){
            HttpResponse res = ApiCalloutUtility.executeCallout(apiToken,'POST',baseURL,'',body);
            //System.debug('res@@-'+res);
        }        
    }
    
    // Not in use
    // public static String UploadMileage(string mileage,string  accId,String adminId,String startdate,String enddate) { }
    
    // Not in use
    // public static String UploadLOA(string LOAData,string  accId,String startdate,String enddate) { }
    
    // Not in use
    // public static String DeleteTrips(string  conId) { }
    
    // Not in use
    // public static String TrueDialogContact (String accountId,String adminId) {}
    
    @AuraEnabled(cacheable=true)
    public static void sendInsuranceEmail (String Id,String Name,String email){
        BiWeeklyWrapperUtils.sendInsuranceEmail(Id, Name, email);
    }
    
    //This method retrieves mileage reimbursement data for a given account and the current month, wraps it into a list of MileageWrapper objects, and returns the serialized JSON.
    @AuraEnabled(cacheable=true)
    public static String ImportMileage(String accountId) {
        String currentMonth = Utils.fetchMonths(1, 0)[0];
        //system.debug('currentMonth : ' + currentMonth);
        List<MileageWrapper> lstMilWrap = new List<MileageWrapper>();
        for(Employee_Reimbursement__c objEmpReim : [SELECT Contact_Id__r.name,Total_Mileage__c,Fuel_Price__c,MPG__c,
                                                    Maintenance_and_Tires__c,Contact_Email__c 
                                                    FROM Employee_Reimbursement__c 
                                                    WHERE Contact_Id__r.AccountId =: accountId 
                                                    AND Month__c =: currentMonth 
                                                    ORDER BY Contact_Id__r.name ASC]){
                                                        MileageWrapper objWrap = new MileageWrapper();
                                                        objWrap.contactId = objEmpReim.Contact_Id__c;
                                                        objWrap.driverName = objEmpReim.Contact_Id__r.name;
                                                        objWrap.totalMileage = String.valueOf(objEmpReim.Total_Mileage__c);
                                                        objWrap.reimbursementId = objEmpReim.Id; 
                                                        objWrap.iseditable = false;
                                                        objWrap.mpg = !CheckNull(String.ValueOf(objEmpReim.MPG__c)) ?  objEmpReim.MPG__c: null;
                                                        objWrap.maintaincetyre = !CheckNull(String.ValueOf(objEmpReim.Maintenance_and_Tires__c)) ?  objEmpReim.Maintenance_and_Tires__c : null;           
                                                        objWrap.fuelprice = !CheckNull(String.ValueOf(objEmpReim.Fuel_Price__c)) ?  objEmpReim.Fuel_Price__c: null;
                                                        objWrap.contactEmail = objEmpReim.Contact_Email__c;
                                                        lstMilWrap.add(objWrap);
                                                    }
        String wrapjson = JSON.serialize(lstMilWrap);
        //System.debug('wrapjson =='+wrapjson );
        return wrapjson;
    }
    
    //This method processes mileage data from the provided JSON response, deletes existing mileage records, and inserts new ones based on the data. It ensures valid reimbursements and biweekly mappings before creating new Employee Mileage records.
    @AuraEnabled
    public static String UpdateImportMileage(String responseData) {
        if (responseData == null) {
            return 'No data provided';
        }
        
        // Deserialize response data into a list of wrappers
        List<MileageWrapper> lstMileWrap = (List<MileageWrapper>) Json.deserialize(responseData, List<MileageWrapper>.class);
        
        if (lstMileWrap.isEmpty()) {
            return 'No mileage data to process';
        }
        
        Set<Id> setReimIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        Map<Id, Id> biweekContactIdMap = new Map<Id, Id>();
        List<Employee_Mileage__c> lstEmpMileage = new List<Employee_Mileage__c>();
        
        // Collect reimbursement and contact Ids from wrapper list
        for (MileageWrapper wrapObj : lstMileWrap) {
            if (wrapObj.reimbursementId != null) {
                setReimIds.add(wrapObj.reimbursementId);
            }
            if (wrapObj.contactId != null) {
                setContactIds.add(wrapObj.contactId);
            }
        }
        
        // Delete existing Employee Mileage records based on reimbursement IDs
        if (!setReimIds.isEmpty()) {
            delete [SELECT Id FROM Employee_Mileage__c WHERE EmployeeReimbursement__c IN :setReimIds];
        }
        
        // Query Bi-Weekly Reimbursements based on contact IDs
        if (!setContactIds.isEmpty()) {
            for (Bi_Weekly_Reimbursement__c objBiWeekReim : [
                SELECT Id, Contact__c 
                FROM Bi_Weekly_Reimbursement__c 
                WHERE Contact__c IN :setContactIds
            ]) {
                biweekContactIdMap.put(objBiWeekReim.Contact__c, objBiWeekReim.Id);
            }
        }
        
        // Create new Employee Mileage records
        Integer index = 0;
        for (MileageWrapper wrapObj : lstMileWrap) {
            if (wrapObj.reimbursementId != null) {
                Employee_Mileage__c objMileage = new Employee_Mileage__c();
                objMileage.Name = !CheckNull(String.ValueOf(wrapObj.reimbursementId)) ? String.valueOf(wrapObj.reimbursementId).substring(0, 15) : null;
                objMileage.Trip_Status__c = 'Approved';
                objMileage.EMP_Mileage__c = Decimal.valueOf(wrapObj.totalMileage);
                objMileage.Activity__c = 'Business';
                objMileage.EmployeeReimbursement__c = wrapObj.reimbursementId;
                objMileage.StartTime__c = System.today();
                objMileage.Day_Of_Week__c = DateTime.now().format('EEEE');
                objMileage.EndTime__c = System.today();
                objMileage.Fuel_price__c = wrapObj.fuelprice;
                objMileage.MPG__c = wrapObj.mpg;
                objMileage.Maintenance_and_Tires__c = wrapObj.maintaincetyre;
                objMileage.Contact_Email_Id__c = wrapObj.contactEmail;
                objMileage.Trip_Date__c = Date.today();
                objMileage.TimeZone__c = 'US/Mountain';
                
                if (biweekContactIdMap.containsKey(wrapObj.contactId)) {
                    objMileage.Bi_Weekly_Reimbursement__c = biweekContactIdMap.get(wrapObj.contactId);
                }
                
                // Only add to list if valid reimbursement and biweekly info are present
                if (objMileage.EmployeeReimbursement__c != null && objMileage.Bi_Weekly_Reimbursement__c != null) {
                    lstEmpMileage.add(objMileage);
                    index++;
                }
            }
        }
        
        // Insert new Employee Mileage records
        if (!lstEmpMileage.isEmpty()) {
            insert lstEmpMileage;
        }
        
        //System.debug('Processed reimbursement IDs: ' + setReimIds);
        return 'success';
    }
    
    // Simplified CheckNull method
    public static Boolean CheckNull(String param1) {
        return String.isBlank(param1);
    }
    
    //This method clears notification messages and dates for active contacts associated with a given account ID. 
    //It updates the contacts by setting their notification fields to null if they are not already deactivated.
    @AuraEnabled
    public static void clearMassNotification(String accID) {
        // Query contacts that have notifications to clear and are not deactivated
        List<Contact> lstContacts = [
            SELECT Notification_Message__c, Notification_Date__c
            FROM Contact
            WHERE AccountId = :accID 
            AND Deactivated_Date__c = NULL
        ];
        
        // If there are any contacts with notifications, clear and update them
        if (!lstContacts.isEmpty()) {
            for (Contact con : lstContacts) {
                if(con.Notification_Message__c != NULL || con.Notification_Date__c != NULL){
                    con.Notification_Message__c = null;
                    con.Notification_Date__c = null;
                }
            }
            update lstContacts;
        }
    }
    
    //This method clears notification messages and dates for a specific active contact identified by the contact ID, updating the contact by setting its notification fields to null if they are not already deactivated.
    @AuraEnabled
    public static String clearNotification(String contactID) {
        // Query the contact with notification details
        Contact objContact = [
            SELECT Notification_Message__c, Notification_Date__c
            FROM Contact
            WHERE Id = :contactID AND Deactivated_Date__c = NULL
            LIMIT 1
        ];
        
        // Check if the contact has notifications to clear
        if (objContact != null && (objContact.Notification_Message__c != null || objContact.Notification_Date__c != null)) {
            objContact.Notification_Message__c = null;
            objContact.Notification_Date__c = null;
            update objContact;
        }
        
        return 'Success';
    }
    
    // Helper method to create a ContactWrapper from a Contact
    private static ContactWrapper createContactWrapper(Contact objContact) {
        ContactWrapper objConWrap = new ContactWrapper();
        objConWrap.contactId = objContact.Id;
        objConWrap.triploguserid = String.valueOf(objContact.Triplog_UserID__c);
        objConWrap.name = objContact.FirstName != null ? objContact.FirstName : '';
        objConWrap.lastname = objContact.LastName;
        objConWrap.fullname = objConWrap.name != '' ? objConWrap.name + ' ' + objConWrap.lastname : objConWrap.lastname;
        objConWrap.insurance = objContact.Insurance__c;
        objConWrap.role = objContact.Role__c;
        objConWrap.isEditable = false;
        objConWrap.massEmail = false;
        objConWrap.massText = false; // Added by Megha
        objConWrap.contactEmail = objContact.External_Email__c;
        objConWrap.expirationDate = objContact.Expiration_Date__c != null ? objContact.Expiration_Date__c : null;
        objConWrap.notiMessage = objContact.Notification_Message__c;
        objConWrap.insuranceId = objContact.Insurance_Attachment_Id__c;
        objConWrap.notificationDate = objContact.Notification_Date__c;
        objConWrap.unReadMessageCount = String.valueOf(objContact.Unread_Message_Count__c);
        objConWrap.contactPicture = objContact.Contact_Picture__c;
        objConWrap.trueDialogId = objContact.TrueDialog_Contact_Id__c;
        objConWrap.massNotiText = false;
        objConWrap.insuranceFile = false;
        objConWrap.locationFile = false;
        objConWrap.messageHolder = false;
        
        return objConWrap;
    }
    
    public class ContactWrapper {
        public string contactId { get; set; }
        public string triploguserid{ get; set; }
        public string name { get; set; }
        public string lastname { get; set; }
        public string role { get; set; }
        public string fullname { get; set; }
        public string insurance { get; set; }
        public string contactEmail { get; set; }
        public string notiMessage { get; set; }
        public string insuranceId { get; set; }
        public string unReadMessageCount { get; set; }
        public Boolean isEditable { get; set; }
        public Boolean massEmail { get; set; }
        public Boolean massText { get; set; } /*Added by Megha*/
        public date expirationDate { get; set; }
        public date notificationDate { get; set; }
        public string contactPicture { get; set; }
        public string trueDialogId{ get; set; }
        public Boolean massNotiText { get; set; }
        public Boolean insuranceFile { get; set; }
        public Boolean locationFile { get; set; }
        public Boolean messageHolder { get; set; }
    }
    //public class LOAWrapper {
    //  public string employeeId { get; set; }
    // public string proratedAmount{ get; set; }
    //public string name { get; set; }
    //public string loaStart { get; set; }
    //public string loaEnd { get; set; }
    //public string conDeactivation { get; set; }
    //}
    public class MileageWrapper {
        public string contactId{ get; set; }
        public string contactEmail{ get; set; }
        public string driverName{ get; set; }
        public string reimbursementId{ get; set; }
        public string totalMileage{ get; set; }
        public Boolean iseditable { get; set; }
        public Decimal mpg { get; set; }
        public Decimal maintaincetyre { get; set; }
        public Decimal fuelprice { get; set; }
    }
    public class TrueDialogApiException extends Exception {}
}