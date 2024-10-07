/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This class is use for checking driver was confirm or error biweekly reimbursement for ERMI account.Based on checkbox value we will redirect on paege.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 07 April 2022 | Sanket Goswami
 * @description: EMC-284
 */
public with sharing class NewAccountDriverController {
    public static string videoCustom {get;set;}
    public static String contactName {get;set;}
    public NewAccountDriverController() {
       setEmployeeName();
       NewDashboardVideoLink__c videoCustomSetting = NewDashboardVideoLink__c.getOrgDefaults();
       videoCustom = json.serialize(videoCustomSetting );
    }
    /*This method is used to get the data of current contact and his account details*/
    @AuraEnabled
    public static string getContactDetail(String contactId){
        List<ContactWrapper> contactWrapList = new List<ContactWrapper >();
        date currentDate = system.today();
        try{
                for(Contact contactobj : [SELECT Id,Name,Insurance_Attachment_Id__c,External_Email__c,FirstName,Account.Account_Status__c,Cell_Phone__c,MobilePhone,Check_OnBoarding__c,Insurance_Declaration_Status__c,Driver_Packet_Status__c,App__c,Meeting__c,Document_Sent_Date__c,Activation_Date__c,Hello_Sign_Status__c,Hello_Sign_Request_Id__c,Expiration_Date__c,Insurance_Dialogue_Remove__c,Plan_Preview__c,Mburse_Dashboard__c,Watch_Meeting__c,Account.Schedule_Goto_Meeting__c,Account.Bodily_Injury__c, Account.Uninsured_Motorist__c, Account.Property_Damage__c, Account.Comprehensive__c, Account.Collision__c,Account.Umbrella_Coverage__c,Account.MburseDashboardRedirect__c 
                                            FROM Contact  
                                            WHERE Id =: contactId
                                            //WITH SECURITY_ENFORCED
                                            ]){
                                                ContactWrapper contactWrapper = new ContactWrapper();                                        
                                                contactWrapper.contactId =  contactobj.Id;
                                                contactWrapper.contactEmail =  contactobj.External_Email__c;
                                                contactWrapper.contactName = contactobj.Name;
                                                contactWrapper.contactFirstName = contactobj.FirstName != null ? contactobj.FirstName : null;
                                                contactWrapper.insuranceId = contactobj.Insurance_Attachment_Id__c != null ? contactobj.Insurance_Attachment_Id__c : null;
                                                contactWrapper.cellPhone =  contactobj.Cell_Phone__c != null ? contactobj.Cell_Phone__c : null;
                                                contactWrapper.mobilePhone =  contactobj.MobilePhone != null ? contactobj.MobilePhone : null;
                                                contactWrapper.accountStatus =  contactobj.Account.Account_Status__c != null ? contactobj.Account.Account_Status__c : 'New Account';
                                                contactWrapper.insuranceStatus =  contactobj.Insurance_Declaration_Status__c != null ? contactobj.Insurance_Declaration_Status__c : null;
                                                contactWrapper.driverPacketStatus =  contactobj.Driver_Packet_Status__c != null ? contactobj.Driver_Packet_Status__c : null;
                                                contactWrapper.driverMeeting =  contactobj.Meeting__c != null ? contactobj.Meeting__c: null;                                                
                                                contactWrapper.scheduleLink =  contactobj.Account.Schedule_Goto_Meeting__c != null ? contactobj.Account.Schedule_Goto_Meeting__c : null;
                                                contactWrapper.bodilyInjury =  contactobj.Account.Bodily_Injury__c != null ? contactobj.Account.Bodily_Injury__c : null;
                                                contactWrapper.unInsuranceMotorist =  contactobj.Account.Uninsured_Motorist__c != null ? contactobj.Account.Uninsured_Motorist__c : null;
                                                contactWrapper.propertyDamage =  contactobj.Account.Property_Damage__c != null ? contactobj.Account.Property_Damage__c : null;
                                                contactWrapper.comprehensive =  contactobj.Account.Comprehensive__c != null ? contactobj.Account.Comprehensive__c : null;
                                                contactWrapper.collision =  contactobj.Account.Collision__c != null ? contactobj.Account.Collision__c : null;
                                                contactWrapper.umbrella =  contactobj.Account.Umbrella_Coverage__c != null ? contactobj.Account.Umbrella_Coverage__c : null;
                                                contactWrapper.helloSignDriverSign =  contactobj.Hello_Sign_Status__c != null ? contactobj.Hello_Sign_Status__c : null;                                                
                                                contactWrapper.mlogApp =  contactobj.App__c != null ? true : false;                                                
                                                contactWrapper.mburseDashboard =  contactobj.Account.MburseDashboardRedirect__c != null ? contactobj.Account.MburseDashboardRedirect__c : false;                                                
                                                date activationDate = contactobj.Activation_Date__c != null ? contactobj.Activation_Date__c : null;
                                                contactWrapper.addedActivationDate  = activationDate != null ? activationDate.addDays(30) : null ;
                                                contactWrapper.documentDate = contactobj.Document_Sent_Date__c != null ? contactobj.Document_Sent_Date__c : null;
                                                contactWrapper.insuranceExpirationDate = contactobj.Expiration_Date__c != null ? contactobj.Expiration_Date__c : null;
                                                contactWrapper.insuranceDialogueRemove = contactobj.Insurance_Dialogue_Remove__c != null ? contactobj.Insurance_Dialogue_Remove__c : null;
                                                //contactWrapper.daysBetweenActivation = activationDate != null ? currentDate.daysBetween(activationDate) : null;
                                                contactWrapper.daysBetweenActivation = activationDate != null ? activationDate.daysBetween(currentDate) : null;
                                                if(contactWrapper.daysBetweenActivation != null && contactWrapper.daysBetweenActivation <= 30){
                                                    contactWrapper.checkActivationDate = true;
                                                } else if(contactWrapper.daysBetweenActivation > 30 &&  contactWrapper.helloSignDriverSign != null && contactWrapper.helloSignDriverSign == 'signed' && contactWrapper.insuranceStatus != null && contactWrapper.insuranceStatus == 'Uploaded'){
                                                    contactWrapper.checkActivationDate = true;
                                                } else {
                                                    contactWrapper.checkActivationDate = false;
                                                }
                                                contactWrapper.helloSignId = contactobj.Hello_Sign_Request_Id__c != null ? contactobj.Hello_Sign_Request_Id__c : null;
                                                System.debug('contactWrapper.helloSignId: '+contactWrapper.helloSignId);
                                                contactWrapper.planPreviewOnBoarding =  contactobj.Plan_Preview__c == true ? true : false; 
                                                contactWrapper.mburseDashboardOnBoarding =  contactobj.Mburse_Dashboard__c == true ? true : false; 
                                                contactWrapper.watchMeetingOnBoarding =  contactobj.Watch_Meeting__c == true ? true : false; 
                                                if(contactobj.Plan_Preview__c == true || contactobj.Mburse_Dashboard__c == true || contactobj.Watch_Meeting__c == true){
                                                    contactWrapper.dontShowOnBoarding = true;
                                                } else{
                                                    contactWrapper.dontShowOnBoarding = false;
                                                }
                                                contactWrapper.checkOnBoarding =  contactobj.Check_OnBoarding__c == true ? true : false;                                                 
                                                contactWrapList.add(contactWrapper);                                              
                                            }
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        return JSON.serialize(contactWrapList);       
    }
    
    public static void setEmployeeName() {
        String id = ApexPages.currentPage().getParameters().get('id');
        Contact employee= [select Id,FirstName,showTeamRecord__c,External_Email__c from Contact where id =: id ];
        if(employee != null) {          
            contactName = employee.FirstName != null ? employee.FirstName : '';
        }              
    }
    
    /*This method is used to save current contact data */
    @AuraEnabled
    public static string updateContactDetail(String contactData,Boolean driverPacket){
        List<Contact> contactList = new List<Contact> ();
        try {
            if(contactData != null){
                List<ContactWrapper> contactWrapUpdateList = new List<ContactWrapper>();
                contactWrapUpdateList = (List<ContactWrapper>)Json.deserialize(contactData,List<ContactWrapper>.class);
                for(ContactWrapper conWrap : contactWrapUpdateList){
                    Contact conObj = new Contact();
                    conObj.Id = Id.valueOf(conWrap.contactId);
                    conObj.Cell_Phone__c = conWrap.cellPhone != null ? conWrap.cellPhone : null ;
                    conObj.Insurance_Declaration_Status__c = conWrap.insuranceStatus != null ? conWrap.insuranceStatus : null ;
                    conObj.Driver_Packet_Status__c = conWrap.driverPacketStatus != null ? conWrap.driverPacketStatus : null ;    
                    conObj.Insurance_Dialogue_Remove__c = conWrap.insuranceDialogueRemove != null ? conWrap.insuranceDialogueRemove : null ;   
                        conObj.Watch_Meeting__c = conWrap.watchMeetingOnBoarding == true ? true : false ;
                        conObj.Mburse_Dashboard__c = conWrap.mburseDashboardOnBoarding == true ? true : false ;
                        conObj.Plan_Preview__c = conWrap.planPreviewOnBoarding == true ? true : false ;
                        conObj.Check_OnBoarding__c = conWrap.checkOnBoarding == true ? true : false ;
                    if(conObj.Insurance_Declaration_Status__c == 'Skip' && (driverPacket != true)){
                        sendEmailToDriver(contactData,conWrap.contactFirstName,conWrap.contactId);
                    }
                    
                    contactList.add(conObj);
                }
            }
            if(contactList.size() > 0 && Schema.sObjectType.Contact.isUpdateable()){
                update contactList;
            }
        } catch (Exception ex){
            System.debug(ex.getMessage());
        }
        
        return 'Success';
    }
    /*This method is used to send a email to driver when driver skip insurance upload functionality. */
    @TestVisible 
    private static void sendEmailToDriver (String contactData,String driverName,String contactId) {
        String objDriverServiceAdd = Label.Driver_Service_OWE;
        OrgWideEmailAddress[] lstOWE = [SELECT Id, address FROM OrgWideEmailAddress WHERE Address = :objDriverServiceAdd];
        List<Messaging.SingleEmailMessage> emailist = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        EmailTemplate templateId;
        String newemailBody;
        try {
            if(contactId != null){
                templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Skip_Insurance_Upload' Limit 1];
            } else {
                templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Driver_Packet_Sign' Limit 1];
            }          
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        
        newemailBody = templateId.HtmlValue;
        if(contactData != null && contactId != null){
                List<ContactWrapper> contactWrapUpdateList = new List<ContactWrapper>();
                contactWrapUpdateList = (List<ContactWrapper>)Json.deserialize(contactData,List<ContactWrapper>.class);
                for(ContactWrapper conWrap : contactWrapUpdateList){
                    toAddress.add(conWrap.contactEmail);
                    newemailBody = newemailBody.replace('{!bodily}', String.valueOf(conWrap.bodilyInjury));
                    newemailBody = newemailBody.replace('{!uninsuredMotorist}', String.valueOf(conWrap.unInsuranceMotorist));
                    newemailBody = newemailBody.replace('{!property}', (conWrap.propertyDamage).format());
                    newemailBody = newemailBody.replace('{!collisionDeduct}', (conWrap.collision).format());
                    newemailBody = newemailBody.replace('{!compreDeduct}', (conWrap.comprehensive).format());
                }
        } else {
            toAddress.add(contactData);
        }
        newemailBody = newemailBody.replace('{!Driver.Name}', driverName);        
        newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        messaging.singleEmailMessage email;
        email = Utils.CreateEmail(templateId.Subject,newemailBody,toAddress,null,null,null);
        if(lstOWE.size()>0) {
            email.setOrgWideEmailAddressId(lstOWE.get(0).Id);
        }
        emailist.add(email);
        SendEmail__c  sendEmailObj = SendEmail__c.getValues('ConfirmTripTimeERMIController');
        if(emailist.size() > 0 && !Test.isRunningTest() && sendEmailObj.Send_email_from_code__c == true){
            Messaging.SendEmailResult [] lstSendEmailResult = Messaging.sendEmail(emailist, false);
            for (Messaging.SendEmailResult objSendMailreq : lstSendEmailResult) 
            {
                if (objSendMailreq.isSuccess()) {
                    System.debug('Email sent@--'); 
                }  else {
                    // Operation failed, so get all errors                
                    for(Messaging.SendEmailError objSendEmailError : objSendMailreq.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(objSendEmailError.getStatusCode() + ': ' + objSendEmailError.getMessage());
                        System.debug('fields that affected this error: ' + objSendEmailError.getFields());
                    }
                }
            }
        }        
    }
    /*This method is used to display data on page */
    @AuraEnabled
    public static String getDriverDetailsClone(String contactId) {            
        List<contact> driverDataList = new List<contact>();
        driverDataList = [SELECT id, Name, MailingPostalCode, MailingState, MailingCity,Driver_Type__c, 
                                        Fixed_Amount__c, monthly_compliance_status__c, Car_Image__c, Account.Name, Account.Logo_Document_Id__c, 
                                        Vehicle_Type__c,Insurance_Attachment_Id__c, Account.Triplog_API__c, Email,
                                        Maintenance__c,Tires__c, Insurance_Rate__c, License_Ragistration__c, Taxes__c,
                                        Depreciation__c, Total_Monthly_Costs__c, Business_Use__c,Fixed_Cost_Adjustment__c,
                                        Monthly_Reimbursement__c,Biweek_Reimbursement__c,Time_Attandance__c,Reimbursement_Frequency__c,
                                        Account.Bi_Weekly_Pay_Period__c
                                    FROM Contact 
                                    WHERE id =: contactId];
        return JSON.serialize(driverDataList ).unescapeHtml4();
    }
    
    /*Added by megha to return Role of contact*/
    @AuraEnabled
    public static String getRole(String contactId) {            
        List<contact> contactList = new List<contact>();
        contactList = [SELECT id, Role__c FROM Contact WHERE id =: contactId];
        return contactList[0].Role__c;
    }
    /*This method is used to send notification email to driver and it's admin*/
    @AuraEnabled
    public static void sendInsuranceEmail (String id,String name,String email){
        BiWeeklyWrapperUtils.sendInsuranceEmail(id, name, email);
    }
    /*This method is used to upload a attachment file*/
    @AuraEnabled
    public static String readFromFileInchunk(String attachmentBody, String attachmentName, String attachmentId,String contactId,String accountId,String contactattachementid) {
        return  WrapperUtils.readFromFileInchunk(attachmentBody,attachmentName,attachmentId,contactId,accountId,contactattachementid);   
    }
    //This method update the insurance related field after insurnace upload
    @AuraEnabled
    public static void updateContactInsuranceField (String contactId,String insuranceID){
        if(String.isNotBlank(contactId) && String.isNotBlank(insuranceID)) {
            contact currentDriver = new contact();
            currentDriver.id = contactId;
            currentDriver.Insurance_Attachment_Id__c = insuranceID;
            currentDriver.Insurance_Upload_Date__c = System.today();
            currentDriver.Insurance_Declaration_Status__c = 'Uploaded';
            currentDriver.Expiration_Date__c = null;
            currentDriver.Insurance__c = 'Under Review';
            currentDriver.monthly_compliance_status__c = 'Pending';
            Database.SaveResult[] srList = Database.update( new List<Contact>{currentDriver}, false);
            
                if (!srList[0].isSuccess()) {
                    for (Database.Error err : srList[0].getErrors()) {
                        System.debug('Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        System.debug('Fields: ' + err.getFields());
                    }
                } else {
                    System.debug('Compliance status updated successfully: ' + srList[0].getId());
                }
            AddOrUpdateInsuranceMessage updateMessage = new AddOrUpdateInsuranceMessage(contactId);
            sendEmailOnInsuranceIdUpdate(contactId, insuranceID);
        }
    }
    public Static void sendEmailOnInsuranceIdUpdate(String contactId,String insuranceID){
        System.debug('inside sendEmailOnInsuranceIdUpdate');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Contact con =[select id,FirstName,LastName from contact where id=:contactId limit 1];
        
        String objDriverServiceAdd = Label.Driver_Service_OWE;
        OrgWideEmailAddress[] owea = [SELECT Id, address FROM OrgWideEmailAddress WHERE Address = :objDriverServiceAdd];
        String body = 'Hi, Team <br><br>'+con.FirstName +' '+Con.LastName+'\'s Insurance is update. new insurance Attachment Id is '+ insuranceID+'. <br><br>      Thank you.';
        String subject = 'Driver Insurance Updated!';
        if (owea.size() > 0) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        SendEmailonDeactivation__c bccEmails =SendEmailonDeactivation__c.getValues('InsuranceIdUpdate');
        if(bccEmails.BCCEmailaddresses__c!=null){
            String emailAddresses = bccEmails.BCCEmailaddresses__c;
            String[] bccaddresses = emailAddresses.split(',');
            email.setBccAddresses(bccAddresses);
        }
        String objSupportEmail= label.supportAddress ;
        email.setToAddresses(new List<String>{objSupportEmail});
        email.setSubject(subject);
        email.setHTMLBody(body);
        
        
        if(bccEmails.Send_to_me__c==true && (!Test.isRunningTest())){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            //system.debug('email result '+r);
        }
    }
    /* This method is use to get custom setting value for display videos on mburse dashboard page */
    @AuraEnabled(cacheable=true) 
    public static NewDashboardVideoLink__c getCustomSettings(){
        return NewDashboardVideoLink__c.getOrgDefaults();
    }
    /* This method is use to get custom setting value for display messages on mburse dashboard page */
    @AuraEnabled(cacheable=true) 
    public static NewDashboardMessage__c getCustomSettingsForMessage(){
        return NewDashboardMessage__c.getOrgDefaults();
    }
    /*This method is use for Hello sign integration.It will send driver packet to Driver */
    // @AuraEnabled 
    // public static string sendSignatureRequestForDriver(String userEmail,String contactName,String helloSignId, String conId){
    //     try{
    //         DocuSignStatusTriggerHandler.handleOrderComplete(ConId);
    //         List<Contact> employee= [select Id,Document_Sent_Date__c from Contact where id =: conId ];
    //         employee[0].Document_Sent_Date__c=System.today();
    //         update employee;
    //         return 'Success' ;
    //     }
    //     catch(Exception e){
    //         System.debug('error: '+e.getMessage());
    //         System.debug('error: '+e.getLineNumber());
    //         return 'Failed';
    //     }
    // }
    /*This method is use to send community welcome email. */
    @AuraEnabled(cacheable = true) 
    public static string sendWelcomeEmail(String accountID,String empEmail){
        String response = RosterController.putHTTP(accountID,empEmail) ;
        return response;
    }
    /*This method is use to redirect contact on particular dashboard page. */
    @AuraEnabled
    public static String loginRedirection(String contactId){
        Contact  contactObj = new Contact ();
        List<Bi_Weekly_Reimbursement__c> biWeekList = new List<Bi_Weekly_Reimbursement__c>();
        contactObj = contactData(contactId);    
        if(contactObj.Accountid == System.label.ERMI_Account||Test.isRunningTest()){
            biWeekList = [SELECT id,name,Start_Date__c,
                                        End_Date__c,Confirm_Hours__c,
                                        Error_Hours__c,Count_Error_Check__c 
                                    FROM Bi_Weekly_Reimbursement__c 
                                    WHERE Contact__c =: contactId
                                    AND Start_Date__c != null 
                                    AND End_Date__c <= TODAY 
                                    Order By End_Date__c desc limit 1];
        }
       
        if(contactObj != null ){            
            String pageRef;
            date currentDate = system.today();
            integer daysBetweenActivation ;
            Boolean checkActivationDate;
            date activationDate = contactObj.Activation_Date__c != null ? contactObj.Activation_Date__c : null;                
            daysBetweenActivation = activationDate != null ? activationDate.daysBetween(currentDate) : null;
            if((daysBetweenActivation != null && daysBetweenActivation <= 30) || Test.isRunningTest()){
                checkActivationDate = true;
            } else if(daysBetweenActivation > 30 && contactObj.Packet__c != null && (contactObj.Packet__c == 'Driver Signed' || contactObj.Packet__c == 'Completed')&& contactObj.Watch_Meeting__c == true && contactObj.Insurance_Declaration_Status__c != null ){
                checkActivationDate = true;
            } else {
                checkActivationDate = false;
            }

            if(contactObj.Role__c == StaticValues.ROLE_DRIVER) {
                //AI-000414
                if(biWeekList.size() > 0){
                    if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 3){
                        pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId;
                    } else if((biWeekList[0].Confirm_Hours__c == true || (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 2)) ){
                        pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                    }
                } else {
                    pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                }
                return pageRef;
            } else if(contactObj.Role__c == StaticValues.ROLE_DRIVERMANAGER ) {
                if( checkActivationDate == true){
                    if(biWeekList.size() > 0 ){
                        if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 3 ){
                            pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&role=managerdriver';
                        } else if(biWeekList[0].Confirm_Hours__c == true ||  (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 2)){
                            pageRef = '/app/managerProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c);
                        }else if(contactObj.Insurance_Attachment_Id__c == null){
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;
                        }
                    } else {
                        
                        if(contactObj.Watch_Meeting__c = true || (contactObj.Account.Account_Status__c != null && contactObj.Account.Account_Status__c == 'Existing Account')){
                            pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if(contactObj.Insurance_Attachment_Id__c == null){
                            system.debug('**'+contactObj.Insurance_Attachment_Id__c);
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;
                        } else {
                            system.debug('***');
                            pageRef = '/app/managerProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c);
                        }
                    }
                    return pageRef;
                }
            } else if(contactObj.Role__c == StaticValues.roleAdminDriver  ) {
                if(checkActivationDate == true){
                    if(biWeekList.size() > 0 ){
                        if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 3 ){
                            pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if(biWeekList[0].Confirm_Hours__c == true ||  (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 2)){
                            pageRef = '/app/adminProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        }else if(contactObj.Insurance_Attachment_Id__c == null){
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                        }
                    } else {
                        if(contactObj.Watch_Meeting__c = true || (contactObj.Account.Account_Status__c != null && contactObj.Account.Account_Status__c == 'Existing Account')){
                            pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if(contactObj.Insurance_Attachment_Id__c == null){
                            system.debug('**'+contactObj.Insurance_Attachment_Id__c);
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                        } else {
                             system.debug('***');
                            pageRef = '/app/adminProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        }
                        return pageRef;
                    } 
                    return pageRef;
                }
            } else if(contactObj.Role__c == 'Manager'){
                if(contactObj.Check_OnBoarding__c == true ){
                    pageRef = '/app/managerProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&manager=true';                    
                } else {
                    pageRef = '/app/onBoardingProcess?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&manager=true';
                }
                return pageRef;
            } else if(contactObj.Role__c == 'Admin'){
                if(contactObj.Check_OnBoarding__c == true){
                    pageRef = '/app/adminProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c);
                } else {
                    pageRef = '/app/onBoardingProcess?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c);
                } 
                return pageRef;
            }
        }
        return 'success';
    }
    
    @AuraEnabled
    public static String loginRedirectionADMD(String contactId,Boolean adminTab){
        Contact  contactObj = contactData(contactId);   
        List<Bi_Weekly_Reimbursement__c> biWeekList = new List<Bi_Weekly_Reimbursement__c>();
        if(contactObj.AccountId == System.label.ERMI_Account || Test.isRunningTest()){
            biWeekList = [SELECT id,name,Start_Date__c,
            End_Date__c,Confirm_Hours__c,
            Error_Hours__c,Count_Error_Check__c 
                FROM Bi_Weekly_Reimbursement__c 
                WHERE Contact__c =: contactId
                AND Start_Date__c != null 
                AND End_Date__c <= TODAY 
                Order By End_Date__c desc limit 1];
        }
        String pageRef;
        if(contactObj.Account.MburseDashboardRedirect__c == true){
           system.debug('*inside first if****');
            date currentDate = system.today();
            integer daysBetweenActivation ;
            Boolean checkActivationDate;
            date activationDate = contactObj.Activation_Date__c != null ? contactObj.Activation_Date__c : null;                
            daysBetweenActivation = activationDate != null ? activationDate.daysBetween(currentDate) : null;
            if((daysBetweenActivation != null && daysBetweenActivation <= 30) || Test.isRunningTest()){
                checkActivationDate = true;
            } else if(daysBetweenActivation > 30 && contactObj.Packet__c != null && (contactObj.Packet__c == 'Driver Signed' || contactObj.Packet__c == 'Completed')&& contactObj.Watch_Meeting__c == true){
                checkActivationDate = true;
            } else {
                checkActivationDate = false;
            }

            if(contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.roleAdminDriver && adminTab == false){  
             system.debug('*inside 2nd if****');
                if(contactObj.Driver_Packet_Status__c != null && contactObj.Insurance_Declaration_Status__c != null && contactObj.Driver_Packet_Status__c != 'Skip' && contactObj.Insurance_Declaration_Status__c == 'Uploaded' && contactObj.App__c != null && checkActivationDate == true){
                     system.debug('*inside 3nd if****');
                    if(biWeekList.size() > 0){
                        if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 4 ){
                            pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if((biWeekList[0].Confirm_Hours__c == true ||  (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 3)) && contactObj.Insurance_Attachment_Id__c != null) {
                            pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if(contactObj.Insurance_Attachment_Id__c == null){
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                        } 
                        return pageRef;
                    } else {
                        // system.debug('*Insurance_Attachment_Id__c****'+contactObj.Insurance_Attachment_Id__c);
                        // system.debug('***Watch_Meeting__c **'+contactObj.Watch_Meeting__c );
                        if(contactObj.Watch_Meeting__c = true || (contactObj.Account.Account_Status__c != null && contactObj.Account.Account_Status__c == 'Existing Account')){
                            pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if(contactObj.Insurance_Attachment_Id__c == null){
                            system.debug('**'+contactObj.Insurance_Attachment_Id__c);
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                        } else {
                             system.debug('***');
                            pageRef = '/app/mBurseDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                        }
                        return pageRef;
                    }                    
                } else {
                    pageRef = '/app/mBurseDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                }
                return pageRef;
            } else if (contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.roleAdminDriver && adminTab == true){
                if(contactObj.Check_OnBoarding__c == true){                        
                   pageRef = '/app/adminProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';                                          
                } else {
                    pageRef = '/app/onBoardingProcess?accid='+contactObj.Accountid+'&id='+contactId;
                }        
                return pageRef;
            } else if(contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.ROLE_DRIVERMANAGER && adminTab == false){
                if(contactObj.Driver_Packet_Status__c != null && contactObj.Insurance_Declaration_Status__c != null && contactObj.Driver_Packet_Status__c != 'Skip' && contactObj.Insurance_Declaration_Status__c == 'Uploaded' && contactObj.App__c != null && checkActivationDate == true){
                    if(biWeekList.size() > 0){
                        if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 4 ){
                            pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if((biWeekList[0].Confirm_Hours__c == true ||  (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 3)) && contactObj.Insurance_Attachment_Id__c != null) {
                            pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                        } else if(contactObj.Insurance_Attachment_Id__c == null){
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                        }
                        
                    } else {
                        if(contactObj.Watch_Meeting__c = true || (contactObj.Account.Account_Status__c != null && contactObj.Account.Account_Status__c == 'Existing Account')){
                            pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&role=managerdriver';
                        } else if(contactObj.Insurance_Attachment_Id__c == null){
                            pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                        } else {
                            pageRef = '/app/mBurseDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                        }
                    }
                } else {
                    pageRef = '/app/mBurseDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                }
                return pageRef;
            } else if (contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.ROLE_DRIVERMANAGER && adminTab == true){
                if(contactObj.Check_OnBoarding__c == true){                        
                    pageRef = '/app/managerProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c);                                              
                } else {
                    pageRef = '/app/onBoardingProcess?accid='+contactObj.Accountid+'&id='+contactId ;
                } 
            } else if (contactObj.Role__c == StaticValues.ROLE_DRIVER){
                if(biWeekList.size() > 0){
                    if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 3){
                        pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId;
                    } else if((biWeekList[0].Confirm_Hours__c == true || (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 2)) ){
                        pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                    }
                } else {                                      
                        pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                }
                return pageRef;
            }
            return pageRef;
        } else {
            if(contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.roleAdminDriver && adminTab == false){
                system.debug('adminTab =='+adminTab );
                if(biWeekList.size() > 0){
                    if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 4 ){
                        pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                    } else if((biWeekList[0].Confirm_Hours__c == true ||  (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 3)) && contactObj.Insurance_Attachment_Id__c != null) {
                        pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                    } else if(contactObj.Insurance_Attachment_Id__c == null){
                        pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                    }                
                } 
                else if (contactObj.Insurance_Attachment_Id__c == null) {
                    pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;   
                } else {
                    pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                }
            } else if(contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.roleAdminDriver && adminTab == true){
                pageRef = '/app/adminProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';                                          
            }else if(contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.ROLE_DRIVERMANAGER && adminTab == false ){
                if(biWeekList.size() > 0){
                    if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 4 ){
                        pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                    } else if((biWeekList[0].Confirm_Hours__c == true ||  (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 3)) && contactObj.Insurance_Attachment_Id__c != null) {
                        pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&admindriver=true';
                    } else if(contactObj.Insurance_Attachment_Id__c == null){
                        pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;      
                    } 
                }  
                else if (contactObj.Insurance_Attachment_Id__c == null){
                    pageRef = '/app/uploadInsurance?accid='+contactObj.Accountid+'&id='+contactId;
                } else {
                    pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c)+'&role=managerdriver';
                }         
            } else if(contactObj != null &&contactObj.Role__c != null && contactObj.Role__c == StaticValues.ROLE_DRIVERMANAGER && adminTab == true){
                pageRef = '/app/managerProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId+'&showteam='+String.valueOf(contactObj.showTeamRecord__c);                                              
            } else if (contactObj.Role__c == StaticValues.ROLE_DRIVER){
                if(biWeekList.size() > 0){
                    if(biWeekList[0].Confirm_Hours__c == false && biWeekList[0].Count_Error_Check__c < 3){
                        pageRef = '/app/driverDashboardWeekly?accid='+contactObj.Accountid+'&id='+contactId;
                    } else if((biWeekList[0].Confirm_Hours__c == true || (biWeekList[0].Count_Error_Check__c != null && biWeekList[0].Count_Error_Check__c > 2)) ){
                        pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                    }
                } else {                                      
                        pageRef = '/app/driverProfileDashboard?accid='+contactObj.Accountid+'&id='+contactId;
                }
                return pageRef;
            }
            return pageRef;
        }
        //return 'success';
    }
    
    public static Contact contactData (String contactId){
        Contact  contactObj = new Contact ();
        if(contactId != null ){
            contactObj = [SELECT id,Check_OnBoarding__c,
                                Role__c,
                                showTeamRecord__c, 
                                AccountId, 
                                Insurance_Attachment_Id__c, 
                                Driver_Type__c, 
                                Driver_Packet_Status__c,
                                Packet__c, 
                                Insurance_Declaration_Status__c,
                                Plan_Preview__c,
                                Mburse_Dashboard__c,  
                                Watch_Meeting__c,
                                Activation_Date__c ,App__c,
                                Hello_Sign_Status__c,
                                Account.MburseDashboardRedirect__c,
                                Account.Account_Status__c                           
                            FROM Contact
                            WHERE Id =: contactId];
                            return contactObj;
        }        
        return null;
    }

    public class ContactWrapper {
        public string contactId { get; set; }
        public string contactName {get; set;}
        public string contactFirstName {get; set;}
        public string insuranceId {get; set;}
        public string contactEmail {get; set;}
        public string cellPhone { get; set; }
        public string mobilePhone { get; set; }
        public string accountStatus { get; set; }        
        public string insuranceStatus { get; set; }
        public string driverPacketStatus {get; set;}        
        public string scheduleLink {get; set;}
        public string driverMeeting {get; set;}
        public string bodilyInjury {get; set;}
        public string unInsuranceMotorist {get; set;}
        public Decimal propertyDamage {get; set;}
        public Decimal comprehensive {get; set;}
        public Decimal collision {get; set;}
        public Decimal umbrella {get; set;}
        public Boolean mlogApp {get; set;}        
        public Boolean checkActivationDate {get; set;}
        public Boolean mburseDashboard {get; set;}
        public Boolean  planPreview {get; set;}
        public integer daysBetweenActivation {get; set;}
        public string helloSignDriverSign{get; set;}
        public string helloSignId {get; set;}
        public Datetime documentDate {get; set;}
        public Date addedActivationDate {get; set;}  
        public Date insuranceExpirationDate {get; set;}  
        public Boolean insuranceDialogueRemove {get; set;}  
        public Boolean planPreviewOnBoarding {get; set;}
        public Boolean mburseDashboardOnBoarding {get; set;}
        public Boolean watchMeetingOnBoarding{get; set;} 
        public Boolean dontShowOnBoarding{get; set;}  
        public Boolean checkOnBoarding{get; set;}   
    }
}