/****************************************************************************************************
* Create By : Dhanraj Khatri
* Create Date : 06/07//2022
* Description :  Batch class for Post and Put Contact Record in TrueDialog.

* Modification Log:
*  -------------------------------------------------------------------------------------------------
*  * Developer                         Date                   Description
*  *------------------------------------------------------------------------------------------------
*  *   -                                -                         -
*****************************************************************************************************/



global  class  TrueDialogContactAPI implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    
    Set<Id> idSetBatch=new Set<Id>();
    
    public integer successRecordCount = 0;
    public integer totalRecordCount = 0;
    
    //Constructor for Batch class that initiliaze contact Id Set
    global TrueDialogContactAPI(Set<Id> contactIdSet){
        idSetBatch = contactIdSet;  
    }
    
    //Batchable Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id,email,MobilePhone, 
                                         phone,name,lastname,firstname,
                                         TrueDialog_Contact_Id__c ,TrueDialog_SMS_Enabled__c,
                                         TrueDialog_MMS_Enabled__c,Account.True_Dialog__c,Deactivated_Date__c
                                         FROM Contact 
                                         WHERE Id IN: idSetBatch and MobilePhone != null
                                         and Account.True_Dialog__c = true]);
    }
    
    //Batchable execute - 
    global  void execute(Database.BatchableContext BC, List<Contact> scope) {   
        totalRecordCount = scope.size();
        System.debug('Total record:'+totalRecordCount);
        List<Contact> contactToUpdateList = new List<Contact>();
        
        HttpResponse response = new HttpResponse();      
        String requestBody;
          
        try {
            for(Contact con:scope){
                requestBody = TrueDialogContact.generateTrueDialogContactReqBody(con);
                
                if(con.TrueDialog_Contact_Id__c!=null){
                    response = executeCallout('PUT','contact',requestBody,con.TrueDialog_Contact_Id__c);
                }else{
                    response = executeCallout('POST','contact',requestBody,'');
                }
                System.debug('***Response Body**'+response.getBody());
                System.debug('***Response Status Code**'+response.getStatusCode());
                
                if (response.getStatusCode() < 300) {           
                    if(con.TrueDialog_Contact_Id__c==null){    
                        
                        TrueDialogContact trueDialog = TrueDialogContact.parse(response.getBody());   
                        con.TrueDialog_Contact_Id__c = trueDialog.id;
                        
                        con.TrueDialog_SMS_Enabled__c = true;
                        con.TrueDialog_MMS_Enabled__c = true;
                        
                        contactToUpdateList.add(con);
                    }
                }else{
                    String trueDialogError =response.getBody() + ',' + response.getStatusCode() + ': ' + response.getStatus() + '\n'; 
                } 
                
            }
            System.debug('***contactToUpdateList**'+contactToUpdateList);
            
            Database.SaveResult[] myResult = Database.update(contactToUpdateList,false);
            
            for(Integer i=0; i < myResult.size(); i++) {
                if(myResult.get(i).isSuccess()) {
                    successRecordCount++;
                } 
                else{
                    Database.Error errors =  myResult.get(i).getErrors().get(0);
                    System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                    System.debug('Failure Record Ids While Updating'+myResult.get(i).Id);
                }
            }
            
        }catch(Exception e) {
            System.debug('Exception caught: ' + e.getMessage());       
        }  
    }
    
    global void finish(Database.BatchableContext BC){
        
        TrueDialog_Keys__c tdKeys =TrueDialog_Keys__c.getInstance('TrueDialogKeys');
        if(tdKeys.Contact_Insert_From_File__c){
            tdKeys.Contact_Insert_From_File__c = false;
            update tdKeys;
        }
        
        System.debug('Batch Email : '+tdKeys.Batch_Notification_Email__c);
        System.debug('***TrueDialogContactAPI Batch finished.');
        
        System.debug('Total record:'+totalRecordCount+' Success Recod:'+successRecordCount);
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, 
                          JobItemsProcessed,TotalJobItems, CreatedBy.Email  
                          FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String tempEMail = tdKeys.Batch_Notification_Email__c;
        String[] toAddresses = new String[] {tempEMail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('TrueDialog Batch Details');
        mail.setHtmlBody('<html><body>Hi,<br>'+'<br> Count Of Total Records Proceed In Batch:'+totalRecordCount + ',<br>Count Of Total Records Proceed Sucessfully:'+successRecordCount+ '<br><br><b>Thanks</b></body></html>'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
    }
    
    public static HttpResponse executeCallout(String method,String resourceName,String requestBody,STring resourceId) {
        
        Http http = new Http();
        HTTPResponse httpResponse = new HTTPResponse();
        HttpRequest httpRequest = new HttpRequest();
        
        TrueDialog_Keys__c tdKeys =TrueDialog_Keys__c.getValues('TrueDialogKeys');
        
        String username = tdKeys.Client_Id__c;//'1ab59fe33353401b8fd8da05716caaf5'
        String password = tdKeys.Client_Secret__c;  //   Jx8$z9*T/rY5
        String baseURL = tdKeys.Base_URL__c;   // https://api.truedialog.com/api/v2.1/account/
        String accountId = tdKeys.Account_Id__c;  // 18409
        
        String endpoint;
        if(method=='PUT' && resourceName=='contact'){     
            endpoint = baseURL+accountId+'/'+resourceName+'/'+resourceId+'?overrideSubscription=overrideSubscription'; 
        }else{
            endpoint = baseURL+accountId+'/'+resourceName;
        }
        
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(method);
        httpRequest.setHeader('Content-Type','application/json');
        
        if(String.isNotBlank(requestBody)){
            httpRequest.setBody(requestBody);
        }
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        
        httpRequest.setHeader('Authorization', authorizationHeader);
        
        httpResponse = http.send(httpRequest);
        
        return httpResponse;
        
    }
    public class TrueDialogApiException extends Exception {}
}