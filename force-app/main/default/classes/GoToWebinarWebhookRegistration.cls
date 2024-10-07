/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description :  
 * Class for registering 'registrant.joined' and 'registrant.added' webhook event
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/

public with sharing class GoToWebinarWebhookRegistration {

    public static GoToWebinar__mdt goToWebinar = [Select id,MasterLabel, Access_Token__c,Account_Key__c,
                                                        DeveloperName, Organizer_Key__c, QualifiedApiName, Refresh_Token__c, 
                                                        Token_Created_Time__c, Token_Expire_Time__c,Client_Id__c,
                                                        Client_Secret__c,Authentication_Endpoint__c, 
                                                        Endpoint__c,Redirect_URL__c,Site_URL__c,Webhook_Key_Added__c,Webhook_Key_Joined__c
                                                    FROM GoToWebinar__mdt
                                                    WHERE MasterLabel ='G2W oAuth' LIMIT 1];  

    /** 
    * ********************************************************
    * Method for create and register webhook
    * Call From CustomMetaDataUtil class.
    * This process will be done only one time when authorization button will be clicked
    * ********************************************************
    */

    @future(callout = true)
    public static void updateWebhookURL() {


        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        WebhookWrapper wb = new WebhookWrapper();
        String requestBody = wb.generateWebookRequestBody();
        System.debug('request body:'+requestBody);

        // API for creating webhooks
        httpReq.setMethod('PUT');
        httpReq.setEndPoint(goToWebinar.Endpoint__c + 'webhooks');
        if(String.isNotBlank(requestBody)){
            httpReq.setBody(requestBody);
        }
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);
        httpRes = http.send(httpReq);

        if(httpRes.getStatusCode()>300){
            System.debug('Webhook Registration update failed:' + httpRes.getBody());
        }
    }

    public class WebhookWrapper {

        public String callbackUrl;
        public String eventName;
        public String eventVersion;
        public String product;
        public String webhookKey;
        
        
        public  String generateWebookRequestBody(){
            List<WebhookWrapper> lstWebhookWrapper = new List<WebhookWrapper>();
            WebhookWrapper wbJoined = new WebhookWrapper();
            wbJoined.callbackUrl = goToWebinar.Site_URL__c + 'GoToWebinar/services/apexrest/gotowebinar/webhook';
            wbJoined.webhookKey = goToWebinar.Webhook_Key_Joined__c;

            lstWebhookWrapper.add(wbJoined);
            WebhookWrapper wbAdded = new WebhookWrapper();
            wbAdded.callbackUrl = goToWebinar.Site_URL__c + 'GoToWebinar/services/apexrest/gotowebinar/webhook';
            wbAdded.webhookKey = goToWebinar.Webhook_Key_Added__c;

            lstWebhookWrapper.add(wbAdded);
           
            return JSON.serialize(lstWebhookWrapper);
        }
    }
}