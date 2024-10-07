public with sharing class GoToWebinarNewUICallout {
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

    public static HttpResponse executeCallout(String method,String resourceName,String requestBody,String webinarKey) {

        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));
       
        String endpoint;
        System.debug('Body:'+requestBody);

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        if(resourceName == 'registrants'){
            if(method == 'POST'){
                endpoint =goToWebinar.Endpoint__c +'organizers/'+ goToWebinar.Organizer_Key__c +'/webinars/'+webinarKey+'/registrants';
            }
        }
        httpReq.setMethod(method);
        httpReq.setEndPoint(endpoint);
        if(String.isNotBlank(requestBody)){
             httpReq.setBody(requestBody);
        }
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        httpRes = http.send(httpReq);

        return httpRes;
    }

    public static HttpResponse executeCalloutForName(String method,String webinarKey) {

        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));
       
        String endpoint;

        System.debug('method name: '+method);
        System.debug('webinarKey: '+webinarKey);

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        if(method == 'GET'){
            endpoint =goToWebinar.Endpoint__c +'organizers/'+ goToWebinar.Organizer_Key__c +'/webinars/'+webinarKey;
        }

        httpReq.setMethod(method);
        httpReq.setEndPoint(endpoint);

        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        httpRes = http.send(httpReq);

        return httpRes;
    }

    public static HttpResponse executeCalloutForRecordingURL(String method,String webinarKey) {

        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));
       
        String endpoint;

        System.debug('method name: '+method);
        System.debug('webinarKey: '+webinarKey);

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        if(method == 'GET'){
            endpoint =goToWebinar.Endpoint__c +'/webinars/'+webinarKey + '/recordingAssets';
        }

        httpReq.setMethod(method);
        httpReq.setEndPoint(endpoint);

        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        httpRes = http.send(httpReq);

        return httpRes;
    }
}