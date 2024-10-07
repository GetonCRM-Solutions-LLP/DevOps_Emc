/****************************************************************************************************
* Create By : Dhanraj Khatri
* Create Date : 06/07//2022
* Description : Web Service for Receieving message and inserting message in salesforce       
* Modification Log:
*  -------------------------------------------------------------------------------------------------
*  * Developer                         Date                   Description
*  *------------------------------------------------------------------------------------------------
*  *   -                                -                         -
*****************************************************************************************************/

@RestResource(urlMapping='/api/webhook/*')
global without sharing class TrueDialogReceiveMessage {
    
    public static RestRequest req = RestContext.request;
    public static RestResponse res = RestContext.response;
    public static Map<String, Object> fetchRequestBody = new  Map<String, Object>();


    @HttpPost
    global static void insertMessage() {
       
        System.debug('request body'+req.requestbody.tostring());
        TrueDialog_Keys__c tdKeys = TrueDialog_Keys__c.getValues('TrueDialogKeys');
       
        
        fetchRequestBody = (Map<String, Object>)JSON.deserializeUntyped(req.requestbody.tostring());
        
        
        Integer trueDialogContactId = (Integer)fetchRequestBody.get('ContactId');
        
        
        String trueDialogContactIdString = String.valueOf(trueDialogContactId);
        
        System.debug('***trueDialogContactIdString***'+trueDialogContactIdString);
        
        Contact contact=[Select id,TrueDialog_Contact_Id__c 
                         FROM Contact
                         WHERE TrueDialog_Contact_Id__c=:trueDialogContactIdString 
                         Limit 1];
        
        System.debug('***contact***'+contact);
        
        if(tdKeys.Callback_Token__c == String.valueOf(fetchRequestBody.get('CallbackToken'))){
            
            String messageContent = String.valueOf(fetchRequestBody.get('Message'));
            
            Message__c message = new Message__c();
            
            message.Action_Id__c = String.valueOf(fetchRequestBody.get('ActionId'));
            message.Unread__c = true;
            message.Incoming_Message__c = true;
            message.Contacts__c = contact.Id;
            message.Message_Id__c = (String) fetchRequestBody.get('MessageId');
            
            message.Message__c = String.valueOf(fetchRequestBody.get('Message'));
            
            insert message;
            
            if(messageContent.contains('</media>') && !messageContent.contains('</text>')){
                generateImageURL(messageContent,message.id);
            }
            if(messageContent.contains('</media>') && messageContent.contains('</text>')){
                generateImageURLWithText(messageContent,message.id);
			}
            
        }else{
            System.debug('TrueDialogReceiveMessage-CallBack Token is Invalid');
        }  
        
    } 
    
    
    @future (callout= true)
    public static void generateImageURL(String mediaInput,String messageId){
        TrueDialog_Keys__c tdKeys = TrueDialog_Keys__c.getValues('TrueDialogKeys');
        System.debug('***generateImageURL***');
        
        Message__c messageRecord = [Select id,Message__c, Action_Id__c, Contacts__c, Incoming_Message__c,Message_Id__c,Media_Link__c from Message__c where Id=:messageId ];
       
        String tempString = mediaInput.remove('</media>');
        String finalString = tempString.remove('<media type=\"image/jpg\">');
        
        System.debug(finalString);
        
        HttpResponse response = new HttpResponse();
        response = TrueDialogAPICallout.executeCallout('GET','media',finalString,null);
        
        SYstem.debug(response);
      
        if (response.getStatusCode() < 300) {
            
            Blob blobData = response.getBodyAsBlob(); 
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'MultiMediaMessage1';
            cv.PathOnClient = 'MultiMediaMessage1.jpg';
            cv.VersionData =blobData ;
            cv.IsMajorVersion = true;
            cv.FirstPublishLocationId  = messageRecord.id;   
            Insert cv;
             
            System.debug('**ContentVersion**'+cv);
            
            List<Folder> mmsFolder = [SELECT Id,name FROM Folder where name ='MMS Image' Limit 1];
            
            System.debug('**Size***'+mmsFolder.size());
            System.debug('***mmsFolder***'+mmsFolder);
            
            Document myDocument = new Document();
            
            if(mmsFolder.size()>0){
                
                myDocument.FolderId = mmsFolder[0].Id;
                myDocument.Body = cv.versionData;
                myDocument.Name =  'MultimediaMessage.jpg';
                myDocument.ispublic = true;
                insert myDocument;
            }
            
            String imageURL = tdKeys.Document_URL__c+myDocument.id+'&oid='+UserInfo.getOrganizationId();
          
        //    List<String> domain = URL.getSalesforceBaseUrl().toExternalForm().split('.my');
        //    String imageURL = domain[0]+'--c.documentforce.com/servlet/servlet.ImageServer?id='+myDocument.id+'&oid='+UserInfo.getOrganizationId();
           

           messageRecord.Message__c = '';
           messageRecord.Media_Link__c = imageURL;
            
            update messageRecord;  
            
        }
        
    }
    
    @future (callout= true)
    public static void generateImageURLWithText(String mediaInput,String messageId){
        TrueDialog_Keys__c tdKeys = TrueDialog_Keys__c.getValues('TrueDialogKeys');
        System.debug('***generateImageURLWithText***');
        Message__c messageRecord = [Select id,Message__c, Action_Id__c, Contacts__c, Incoming_Message__c,Message_Id__c,Media_Link__c from Message__c where Id=:messageId ];
       
        List<String> splitString = mediaInput.split('<text>');
        String mediaTag = splitString[0];
        String textTag = splitString[1];
        String txtMessage = textTag.remove('</text>');
        
        
        String tempString = mediaTag.remove('</media>');
        String finalString = tempString.remove('<media type=\"image/jpg\">');
        System.debug(finalString);
        
        
        HttpResponse response = new HttpResponse();
        response = TrueDialogAPICallout.executeCallout('GET','media',finalString,null);
        
        SYstem.debug(response);
        if (response.getStatusCode() < 300) {
            
            Blob blobData = response.getBodyAsBlob(); 
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'MultiMediaMessage1';
            cv.PathOnClient = 'MultiMediaMessage1.jpg';
            cv.VersionData =blobData ;
            cv.IsMajorVersion = true;
            cv.FirstPublishLocationId  = messageRecord.Id;
                        
            Insert cv;
            System.debug('**ContentVersion**'+cv);
            
            List<Folder> mmsFolder = [SELECT Id,name FROM Folder where name ='MMS Image' Limit 1];
            
            System.debug('**Size***'+mmsFolder.size());
            System.debug('***mmsFolder***'+mmsFolder);
            
            Document myDocument = new Document();
            if(mmsFolder.size()>0){
                
                myDocument.FolderId = mmsFolder[0].Id;
                myDocument.Body = cv.versionData;
                myDocument.Name =  'MultimediaMessage.jpg';
                myDocument.ispublic = true;
                insert myDocument;
            }
            
            String imageURL = tdKeys.Document_URL__c+myDocument.id+'&oid='+UserInfo.getOrganizationId();
            
            messageRecord.Message__c = txtMessage;
            messageRecord.Media_Link__c = imageURL;
            
            update messageRecord;  
            
        }
        
    }
}