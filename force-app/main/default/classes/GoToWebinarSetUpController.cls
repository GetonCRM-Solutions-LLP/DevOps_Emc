public with sharing class GoToWebinarSetUpController {
    public static GoToWebinar__mdt goToWebinar = [SELECT id,MasterLabel, Access_Token__c,Account_Key__c,
                                                        DeveloperName, Organizer_Key__c, QualifiedApiName, Refresh_Token__c, 
                                                        Token_Created_Time__c, Token_Expire_Time__c,Client_Id__c,
                                                        Client_Secret__c,Authentication_Endpoint__c, 
                                                        Endpoint__c,Redirect_URL__c,Site_URL__c
                                                    FROM GoToWebinar__mdt
                                                    WHERE MasterLabel ='G2W oAuth' LIMIT 1];   

        /** 
    * ********************************************************
    *  Method for GoToWebinar API callout
    * ********************************************************
    */

    public static String getWebhookDetails(){

        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));

        String endpoint;

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        endpoint =goToWebinar.Endpoint__c +'webhooks?product=g2w';

        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        httpRes = http.send(httpReq);
        System.debug('httpRes.getBody()--------'+httpRes.getBody());
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        System.debug('result-------'+result);

        Map<String, Object> result2 = (Map<String, Object>)result.get('_embedded');
        System.debug('result2-------'+result2);

        List<Object> result3 = (List<Object>)result2.get('webhooks');

        String allWebhookKey ='';

        for(Object obj : result3){
            Map<String, Object> singleObject = (Map<String, Object>)obj; 
            System.debug('singleObject: '+singleObject);
            String webhookKey = String.valueOf(singleObject.get('webhookKey'));
            System.debug('webhook== : '+singleObject.get('webhookKey'));
            System.debug('webhookKey== : '+webhookKey);
            allWebhookKey = allWebhookKey + webhookKey +',';
        }

        allWebhookKey = allWebhookKey.Substring(0,allWebhookKey.length()-1);
        System.debug('allWebhookKey: '+allWebhookKey);
        return allWebhookKey;
    }

    public static String getUserSubscriptionDetails(){
        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));

        String endpoint;

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        endpoint =goToWebinar.Endpoint__c +'userSubscriptions?product=g2w';

        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        httpRes = http.send(httpReq);
        System.debug('httpRes.getBody()--------'+httpRes.getBody());

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        System.debug('result-------'+result);

        Map<String, Object> result2 = (Map<String, Object>)result.get('_embedded');
        System.debug('result2-------'+result2);

        List<Object> result3 = (List<Object>)result2.get('userSubscriptions');

        String allUserSubscriptionsKey ='';

        for(Object obj : result3){
            Map<String, Object> singleObject = (Map<String, Object>)obj; 
            System.debug('singleObject: '+singleObject);
            String userSubscriptionKey = String.valueOf(singleObject.get('userSubscriptionKey'));
            System.debug('webhook== : '+singleObject.get('userSubscriptionKey'));
            System.debug('webhookKey== : '+userSubscriptionKey);
            allUserSubscriptionsKey = allUserSubscriptionsKey + userSubscriptionKey +',';
        }

        allUserSubscriptionsKey = allUserSubscriptionsKey.Substring(0,allUserSubscriptionsKey.length()-1);
        System.debug('allUserSubscriptionsKey: '+allUserSubscriptionsKey);

        return allUserSubscriptionsKey;
    }

    public static void updateWebhookDetails(){
        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));

        String webhookKeys = getWebhookDetails();
        System.debug('webhookKeys: '+webhookKeys);

        String[] webhooks = webhookKeys.split(',');
        System.debug('webhooks size: '+webhooks.size());

        String bodyVal = '';

        for(Integer i=0; i < webhooks.size(); i++){
            bodyVal = bodyVal +webhookBody(goToWebinar.Site_URL__c,webhooks[i],'ACTIVE')+ ',';
        }

        bodyVal = bodyVal.Substring(0,bodyVal.length()-1);
        bodyVal = '[' + bodyVal + ']';

        System.debug('bodyVal: '+bodyVal);

        String endpoint;

        endpoint =goToWebinar.Endpoint__c +'webhooks?product=g2w';

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        httpReq.setMethod('PUT');
        httpReq.setEndPoint(endpoint);
        httpReq.setBody(bodyVal);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        httpRes = http.send(httpReq);
        System.debug('httpRes.getBody()--------'+httpRes.getBody());
        System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());

        updateUserSubscriptionDetails();
    }

    public static void updateUserSubscriptionDetails(){
        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));

        String userSubscriptionKeys = getUserSubscriptionDetails();
        System.debug('userSubscriptionKeys: '+userSubscriptionKeys);

        String[] keys = userSubscriptionKeys.split(',');
        System.debug('userSubscription Keys size: '+keys.size());

        String bodyVal = '';

        for(Integer i=0; i < keys.size(); i++){
            bodyVal = bodyVal +userSubscriptionBody(goToWebinar.Site_URL__c,keys[i])+ ',';
        }

        bodyVal = bodyVal.Substring(0,bodyVal.length()-1);
        bodyVal = '[' + bodyVal + ']';

        System.debug('bodyVal: '+bodyVal);

        String endpoint;

        endpoint =goToWebinar.Endpoint__c +'userSubscriptions?product=g2w';

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        httpReq.setMethod('PUT');
        httpReq.setEndPoint(endpoint);
        httpReq.setBody(bodyVal);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        httpRes = http.send(httpReq);
        System.debug('httpRes.getBody()--------'+httpRes.getBody());
        System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());
        
    }

    public static string webhookBody(String callbackUrl,String webhookKey,String state){
        goToWebhookWrapper wb = new goToWebhookWrapper();
        wb.callbackUrl = callbackUrl;
        wb.webhookKey = webhookKey;
        wb.state = state;

        return JSON.serialize(wb);
    }

    public static string userSubscriptionBody(String callbackUrl,String userSubscriptionKey){
        goToUserSubscriptionWrapper wb = new goToUserSubscriptionWrapper();
        wb.callbackUrl = callbackUrl;
        wb.userSubscriptionKey = userSubscriptionKey;

        return JSON.serialize(wb);
    }

    public class goToWebhookWrapper{
        public String callbackUrl;
        public String webhookKey;
        public String state;
    }

    public class goToUserSubscriptionWrapper{
        public String callbackUrl;
        public String userSubscriptionKey;
    }

}