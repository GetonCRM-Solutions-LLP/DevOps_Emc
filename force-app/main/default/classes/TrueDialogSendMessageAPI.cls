/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description :  Methods contains for 
                1) sendMessageToContact - Calling SendMessageApi and inserting message in salesforce,
                2) getAllMessageByContact -  Returning all message realted to contact in LWC
                3) getContactPicture - Returning contact picture.
            
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/


public without sharing class TrueDialogSendMessageAPI {
    
    @AuraEnabled
    public static String sendMessageToContact(String contactId,String message){
        System.debug('**In sendMessageToContact***');
        String result;
        try {
        
            Message__c messageRecord = new Message__c();
            HttpResponse response = new HttpResponse();
            String requestBody = TrueDiaolgSendMessageWrapper.generateSendMessageReqBody(contactId,message);
    
            response = TrueDialogAPICallout.executeCallout('POST','action-pushCampaign',requestBody,null);
            
            if(response.getStatusCode() < 300) {
            
                TrueDiaolgSendMessageWrapper trueDialogWrapper = TrueDiaolgSendMessageWrapper.parse(response.getBody());
                messageRecord.Contacts__c = contactId;
                messageRecord.Action_Id__c = trueDialogWrapper.id;
                messageRecord.Message__c = message;

            }else{
  
                String trueDialogError = response.getBody() + ',' + response.getStatusCode() + ': ' + response.getStatus() + '\n';               
                throw new TrueDialogApiException(trueDialogError);
            } 
                  
            Database.SaveResult saveResultList = Database.insert(messageRecord, false);

            if (saveResultList.isSuccess()) {   
                result = 'success';
            }else {                 
                result = 'failed';
            }

        }catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage()); 
        }
        return result;
            
    }
    
    @AuraEnabled 
    public static String getAllMessageByContact(String contactId){
       
        List<Message__c> lstMessage = [Select id, Message__c,Unread__c, Incoming_Message__c, Contacts__r.Time_Zone__c,CreatedDate,Media_Link__c
                                        FROM Message__c
                                        WHERE Contacts__c =:contactId order by CreatedDate asc];

        return JSON.serialize(lstMessage);
    }
    
    @AuraEnabled
    public static string getContactPicture(String contactId){
      
       List<Contact> conList = [SELECT id,Contact_Picture__c
                                    FROM Contact 
                                    WHERE id =: contactId];

        String json = JSON.serialize(conList);
        return json;
    }

  

    @AuraEnabled
    public static String sendImage(String contactId,String attachmentBody, String attachmentName,String message){

        TrueDialog_Keys__c tdKeys = TrueDialog_Keys__c.getValues('TrueDialogKeys');
        String result;
        Contact con =[Select id,TrueDialog_Contact_Id__c from Contact where id = :contactId];
        

        List<String> lstTrueDialogId = new List<String>();

        lstTrueDialogId.add(con.TrueDialog_Contact_Id__c);

        String trueDialogContactIdList = JSON.serialize(lstTrueDialogId);
        HttpResponse res = TrueDialogSendMessageAPI.postImageToTrueDialog(trueDialogContactIdList,attachmentBody,attachmentName,message);

        if(res.getStatusCode() < 300) {

            Message__c messageRecord = new Message__c();
            messageRecord.Contacts__c = contactId;
            if(message!=null)
            messageRecord.Message__c = message;
            insert messageRecord;
            
        
            ContentVersion cv = new ContentVersion();
            cv.Title = attachmentName;
            cv.PathOnClient = attachmentName;
            cv.VersionData = EncodingUtil.base64Decode(attachmentBody);
            cv.IsMajorVersion = true;
            Insert cv;	

            System.debug('****Content Version  type in send Image'+cv.FileType);
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;  
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = messageRecord.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl; 

            List<Folder> mmsFolder = [SELECT Id,name FROM Folder where name ='MMS Image' Limit 1];
            
            Document myDocument = new Document();
           
            if(mmsFolder.size()>0){
                
                myDocument.FolderId = mmsFolder[0].Id;
                myDocument.Body = cv.versionData;
                myDocument.Name = attachmentName;
                myDocument.ispublic = true;
                insert myDocument;
            }

            System.debug('***MyDocument**'+myDocument);
        

            // String imageURL = 'https://mburse--partialdev--c.documentforce.com/servlet/servlet.ImageServer?id='+myDocument.id+'&oid='+UserInfo.getOrganizationId();      
            // List<String> domain = URL.getSalesforceBaseUrl().toExternalForm().split('.my');
            // String imageURL = domain[0]+'--c.documentforce.com/servlet/servlet.ImageServer?id='+myDocument.id+'&oid='+UserInfo.getOrganizationId();

            String imageURL = tdKeys.Document_URL__c+myDocument.id+'&oid='+UserInfo.getOrganizationId();
            
            messageRecord.Media_Link__c = imageURL;
            update messageRecord;   

            result='success';
        }else{
            result = 'failed';
        }  

        return result;
    }

    public static HTTPResponse postImageToTrueDialog(String trueDialogContactIdList,String attachmentBody, String attachmentName,String message){
       
            String boundary='webkit1234567';

            String header = '--' + boundary + '\r\n' +
                                + 'Content-Type: image/jpg\r\n'+
                                + 'Content-Disposition: form-data; name=\"media\"; filename=\"' + attachmentName +'\"';
                            

            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));

            String footer = '--' + boundary + '--';

            while(headerEncoded.endsWith('='))
            {
                header += ' ';
                headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
            }

            String bodyEncoded = EncodingUtil.base64Encode(EncodingUtil.base64Decode(attachmentBody));

            Blob bodyBlob = null;

            String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
            
            System.debug('----->last4Bytes: '  + last4Bytes );

            if(last4Bytes.endsWith('==')) {
                last4Bytes = last4Bytes.substring(0,2) + '0K';
                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                // We have appended the \r\n to the Blob, so leave footer as it is.
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            } else if(last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0,3) + 'N';
                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
                footer = '\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);            
            } else{
                // Prepend the CR LF to the footer
                footer = '\r\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            }

            System.debug('---> Body: ' + bodyBlob);

            HttpRequest req = new HttpRequest();
            
            TrueDialog_Keys__c tdKeys =TrueDialog_Keys__c.getValues('TrueDialogKeys');
            String username = tdKeys.Client_Id__c;//'1ab59fe33353401b8fd8da05716caaf5'
            String password = tdKeys.Client_Secret__c;  //   Jx8$z9*T/rY5
            String baseURL = tdKeys.Base_URL__c;   // https://api.truedialog.com/api/v2.1/account/
            String accountId = tdKeys.Account_Id__c;


            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);

            String endpoint = baseURL+accountId+'/image';
            req.setEndpoint(endPoint);
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            req.setMethod('POST');
            req.setBodyAsBlob(bodyBlob);
            req.setHeader('Content-Length', String.valueof(req.getBodyAsBlob().size()));
            req.setHeader('Authorization', authorizationHeader);
            req.setTimeout(60000);

            Http http = new Http();
            HTTPResponse res = http.send(req);

            System.debug(res);
            System.debug('--' +res.getBody());
        
            List<Object> lstObject = (List<Object>)JSON.deserializeUntyped(res.getBody());

            Map<String,Object> resultMap = (Map<String,Object>)lstObject[0];
            System.debug(resultMap.get('id'));
            String mediaId = String.valueOf(resultMap.get('id'));  
            String reqBody ='{"message":"'+message+'","channels": ['+tdKeys.Channel_Id__c+'],"targets": '+ trueDialogContactIdList +',"MediaId":"'+mediaId+'","execute": true}';
            SYstem.debug('****reqBody:'+reqBody);

        
            endpoint = baseURL+accountId+'/action-pushcampaign';
            req.setEndpoint(endPoint);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            if(message!=null){
                 req.setBody('{"message":"'+message+'","channels": ['+tdKeys.Channel_Id__c+'],"targets": '+ trueDialogContactIdList +',"MediaId":"'+mediaId+'","execute": true}');
            }else{
                req.setBody('{"channels": ['+tdKeys.Channel_Id__c+'],"targets": '+ trueDialogContactIdList +',"MediaId":"'+mediaId+'","execute": true}');
            }
            res = http.send(req);   

            return res;

        
    }

    public class TrueDialogApiException extends Exception {}
}