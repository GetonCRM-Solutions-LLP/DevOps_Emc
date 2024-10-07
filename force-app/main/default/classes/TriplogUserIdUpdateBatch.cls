global class TriplogUserIdUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {    
    global String accountID;
    global String apiKey;  
    global String htmlTemplate = ''; 
    global String htmlTemplate2 = '';     
    global String accName = '';   
    global String responseOfAPICall = '';
    public Map<String,Contact> contactMap;       
    public Map<String,String> appUpdateMap ;
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;

    global TriplogUserIdUpdateBatch(string passedId,String passedapiKey,Map<String,Contact> passedContactMap){
        accountID = passedId;        
        apiKey = passedapiKey;
        contactMap = passedContactMap;
        appUpdateMap = new Map<String,String>();
    }
    
    global List<Account> start(Database.BatchableContext BC){  
        return [Select id,Name,Triplog_API__c from Account Where id =: accountID and isUsingTriplog__c = true and Triplog_API__c!=null];         
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();        
        set<string> emailSet = new set<string>();
        List<String> appVersionList = new List<String>();
        List<Contact> contactToUpdateList = new List<Contact>();
        
        if(contactMap!=null && contactMap.size()>0 && scope.size()>0)
        {
            accName = scope[0].Name;    
           
            if (!Test.isRunningTest()) {
                responseOfAPICall = getTripIds(apiKey);
            }
            
            String appVersionName = '';
            appVersionName = Label.Latest_App_Versions_In_Triplog;
           
            if(!String.isBlank(appVersionName))
            {
                if(appVersionName.contains(','))
                {
                    appVersionList = appVersionName.split(',');                   
                }
                else {
                    appVersionList.add(appVersionName);
                } 
            }

            if(String.isNotBlank(responseOfAPICall)  && responseOfAPICall!='Error')
            {                
                TriplogJsonUserParse triplogRes = TriplogJsonUserParse.parse(responseOfAPICall);                
                if(triplogRes.user!=null && triplogRes.user.size()>0)
                {
                    for(TriplogJsonUserParse.Users currentUser : triplogRes.user)
                    {
                        if(String.isNotBlank(currentUser.email) && contactMap.containsKey(currentUser.email.toLowerCase()))
                        {                             
                            Contact currentContact = new Contact();
                            currentContact = contactMap.get(currentUser.email);
                            currentContact.Triplog_UserID__c = String.valueOf(currentUser.id);
                            currentContact.App__c = currentUser.appVersion;                            
                            currentContact.Is_Driver_In_Triplog__c = currentUser.driver;
                            /*if(!appVersionList.contains(currentUser.appVersion)){
                                appUpdateMap.put(currentUser.email,currentContact.Firstname);
                            }*/
                            System.debug('currentUser.timeZone: '+currentUser.timeZone);
                            if(currentUser.timeZone != null){
                                System.debug('currentUser.timeZone: '+currentUser.timeZone);
                                //List<String> resZone = currentUser.timeZone.split(',');                                
                                //currentContact.Time_Zone__c = resZone[0].substringAfter('=').replace('\"', '');
                                currentContact.Time_Zone__c = currentUser.timeZone;
                                System.debug('currentContact.Time_Zone__c: '+currentContact.Time_Zone__c);
                            }  
                            currentContact.Last_Synced__c = !GetTripCallout.CheckNull(currentUser.lastSynced) ? Utils.ConvertToDateAndTime(String.valueOf(currentUser.lastSynced)) : null;  
                            currentContact.App_Settings__c = currentUser.appSettings != null ? currentUser.appSettings : null;
                            contactToUpdateList.add(currentContact);
                            emailSet.add(currentUser.email.toLowerCase());
                            System.debug('currentContact.Last_Synced__c: '+currentContact.Last_Synced__c);
                        }
                    }
                }
                if(contactToUpdateList.size()>0)
                {
                    // Database method to update the records in List
                    List<Database.SaveResult> srList = Database.update(contactToUpdateList, false);
                    if(contactMap.size() != contactToUpdateList.size()){ 
                        for (Integer i = 0; i < contactToUpdateList.size(); i++) {
                            Database.SaveResult sr = srList[i];
                            Contact origRecord = contactToUpdateList[i];

                            if (!sr.isSuccess()) {
                                String DeactivateDate = String.valueOf(origRecord.Deactivated_Date__c);
                                if(DeactivateDate == null){
                                    DeactivateDate = '';
                                }
                                htmlTemplate2 = htmlTemplate2 + '<tr align="center">' 
                                                + '<td style="border:2px solid black;">' + '<a href="'+baseUrl+'/'+origRecord.Id+'">'+origRecord.Name+'</a>'+ '</td>'
                                                + '<td style="border:2px solid black;">' + origRecord.External_Email__c + '</td>'
                                                + '<td style="border:2px solid black;">' + DeactivateDate + '</td>';

                                Integer getErrorsSize = 1;
                                for(Database.Error objErr : srList[i].getErrors()) {
                                    if(getErrorsSize > 1){
                                        htmlTemplate2 = htmlTemplate2 + '</tr> <tr align="center"><td colspan="2" style="border:2px solid black"></td>'
                                                                      + '<td style="border:2px solid black;">' + objErr.getStatusCode() + ': ' + objErr.getMessage()+ '</td>' ;
                                    }
                                    else{
                                        htmlTemplate2 = htmlTemplate2 + '<td style="border:2px solid black;">' + objErr.getStatusCode() + ': ' + objErr.getMessage()+ '</td>' ;
                                    }
                                    getErrorsSize++;
                                }
                                htmlTemplate2 += +'</tr>';
                            } 
                        }         
                                    
                        for (Contact cont:contactMap.values()){                    
                            if(!emailSet.contains(cont.External_Email__c.toLowerCase())){
                                String DeactivateDate = String.valueOf(cont.Deactivated_Date__c);
                                if(DeactivateDate == null){
                                    DeactivateDate = '';
                                }
                                                     
                                htmlTemplate = htmlTemplate + '<tr align="center">' 
                                                + '<td style="border:2px solid black;">' + '<a href="'+baseUrl+'/'+cont.Id+'">'+cont.Name+'</a>'+ '</td>'                                         
                                                + '<td style="border:2px solid black;">' + cont.External_Email__c + '</td>'
                                                + '<td style="border:2px solid black;">' + DeactivateDate + '</td>';   
                                htmlTemplate += +'</tr>';
                            }
                        }                
                    }
                }
            }
        }
    } 
       
    global void finish(Database.BatchableContext bc){
        SendEmail__c  objSendEmail = SendEmail__c.getValues('TriplogUserIdUpdateBatch');
        if(htmlTemplate != ''){
            EmailTemplate emailTemplate = [SELECT Id,
                                                  HtmlValue,
                                                  Name,
                                                  Subject 
                                           FROM EmailTemplate 
                                           WHERE DeveloperName = 'Contact_external_email_not_found_in_triplog'];              
            String newBody = emailTemplate.HtmlValue;       
            newBody = newBody.replace('{tableDynamicData}',htmlTemplate);  
            newBody = newBody.replace('{tableDynamicData2}',htmlTemplate2);
            
            List<String> emailaddressofsending = new List<String>();     
            messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
            mail.setHtmlBody(newBody);
            mail.setSubject(accName+'\'s contacts list did not update triplog User id');            
            emailaddressofsending = System.Label.Email_To_Address.split(','); 
            System.debug('emailaddressofsending=='+emailaddressofsending);
            
            mail.setToAddresses(emailaddressofsending);            
            try{
                if(objSendEmail.Send_email_from_code__c){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                
            }catch(exception e){
                // apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
            }
        }      
        /*AI-000347 */
        /*
        if(appUpdateMap.size() > 0){
            EmailTemplate emailTemplate = [SELECT Id,
                                                  HtmlValue,
                                                  Name,
                                                  Subject 
                                           FROM EmailTemplate 
                                           WHERE DeveloperName = 'AndroidAndIOSAppVersion'];              
                 

            List<String> emailaddressofsending = new List<String>();  
            emailaddressofsending = System.Label.Email_To_Address.split(','); 
            List<messaging.singleEmailMessage> mialingList = new List<messaging.singleEmailMessage>();
            for(String currentemail : appUpdateMap.keySet())
            {
                messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
                String newBody = emailTemplate.HtmlValue;
                newBody = newBody.replace('{!Contact.FirstName}',appUpdateMap.get(currentemail));
                newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                //newBody = newBody.replace('{!$Label.AndroidAndIOSAppVersion}', System.Label.AndroidAndIOSAppVersion);
                //newBody = newBody.replace('{appVersion}', System.Label.Latest_App_Versions_In_Triplog);
                mail.setHtmlBody(newBody);
                mail.setSubject(emailTemplate.Subject);            
               
                List<String> emailaddressList = new List<String>();
                emailaddressList.add(currentemail); 
                mail.setToAddresses(emailaddressList);
                mail.setBccAddresses(emailaddressofsending);            
                mialingList.add(mail);
            }
            if(mialingList.size()>0 && !Test.isRunningTest() && objSendEmail.Send_email_from_code__c == true)
            {
                Messaging.sendEmail(mialingList);
            }

        }*/
    } 

    public static String getTripIds(String passedApikey)
    {
        String baseURL = !MLOGACCOUNT.Contains(passedApikey) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint( baseURL + '/api/users');
        request.setMethod('GET');
        request.setHeader('Authorization','apikey ' + passedApikey);
        HttpResponse response = http.send(request);
        System.debug('request :'+request);
        System.debug('response :'+response);
        return response.getStatusCode() == 200 ? response.getBody() : 'Error';
    }   
}