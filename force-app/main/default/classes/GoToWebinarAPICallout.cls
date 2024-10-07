/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description :  Method contains for calling GoToWebinar API   
                1)executeCallout method take request body,method,resourceName and call the API return Response
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/



public with sharing class GoToWebinarAPICallout {

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

    public static HttpResponse executeCallout(String method,String resourceName,String requestBody,STring resourceId) {

        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));
       
        String endpoint;
        System.debug('Body:'+requestBody);

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        if(resourceName == 'webinars'){
            if(method == 'POST'){
                endpoint =goToWebinar.Endpoint__c +'organizers/'+ goToWebinar.Organizer_Key__c +'/webinars';
            }else{
                endpoint =goToWebinar.Endpoint__c +'organizers/'+ goToWebinar.Organizer_Key__c +'/webinars/'+resourceId;
            }
        }else if(resourceName == 'performance' && method == 'GET'){
            GoTo_Session__c gtos =  [Select id ,GoTo_Webinar__c, Start_Time__c, End_Time__c,
                                    GoTo_Webinar__r.Webinar_Key__c ,Session_Key__c,Webinar_Key__c
                                    FROM GoTo_Session__c 
                                    WHERE  Session_Key__c =:resourceId LIMIT 1];
            endpoint  = goToWebinar.Endpoint__c +'organizers/'+goToWebinar.Organizer_Key__c+'/webinars/'+ gtos.Webinar_Key__c +'/sessions/'+ resourceId +'/performance';
        }else if(resourceName == 'questions' && method == 'GET'){
            GoTo_Session__c gtos =  [Select id ,GoTo_Webinar__c, Start_Time__c, End_Time__c,
                                    GoTo_Webinar__r.Webinar_Key__c ,Session_Key__c,Webinar_Key__c
                                    FROM GoTo_Session__c 
                                    WHERE  Session_Key__c =:resourceId LIMIT 1];
            endpoint = goToWebinar.Endpoint__c +'organizers/'+goToWebinar.Organizer_Key__c+'/webinars/'+ gtos.Webinar_Key__c +'/sessions/'+ resourceId +'/questions';
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
}