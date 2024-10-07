/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : Schedule Class For Refreshing Access Token in Every 15 minute
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/


global class GoToWebinarGenerateTokenSchedule implements Schedulable, Database.AllowsCallouts{
            
    /** 
    * ********************************************************
    *  Execute Method called in every 15 minute
    * ********************************************************
    */
    global void execute(SchedulableContext sc) {
        refreshAccessToken(); 
    }

    /** 
    * ********************************************************
    *  Method for refresh Access Token in every 15 minute
    * ********************************************************
    */
    @future(callout=true)
    public static void refreshAccessToken(){

        GoToWebinar__mdt goToWebinar = [SELECT id,MasterLabel, Access_Token__c,Account_Key__c,
                                                DeveloperName, Organizer_Key__c, QualifiedApiName, Refresh_Token__c, 
                                                Token_Created_Time__c, Token_Expire_Time__c,Client_Id__c, Client_Secret__c, 
                                                Authentication_Endpoint__c, Endpoint__c,Redirect_URL__c  
                                            FROM GoToWebinar__mdt
                                            WHERE MasterLabel ='G2W oAuth'];

        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));
        String endPoint = goToWebinar.Authentication_Endpoint__c+'token?grant_type=refresh_token&refresh_token='+ goToWebinar.Refresh_Token__c;
        
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Authorization' , 'Basic '+ base64encodedString);
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');

        try{
            httpRes = http.send(httpReq);

            if(httpRes.getStatusCode() == 200){

                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                Map<String,Object> cMDfieldMap = new Map<String,Object>();

                cMDfieldMap.put('access_Token__c',string.valueof(result.get('access_token')));
                cMDfieldMap.put('Token_Created_Time__c', system.now());
                cMDfieldMap.put('Token_Expire_Time__c', system.now().addSeconds(Integer.valueof(result.get('expires_in'))));

                CustomMetaDataUtil.updateCustomMetadata('GoToWebinar__mdt','G2W_oAuth','G2W oAuth',cMDfieldMap);  
                  
            } else{
                System.debug('RefreshToken Invalid Response:'+httpRes.getBody());
            }
        }catch(System.Exception e){
            System.debug('Exception'+e.getMessage());
        }

    }
}