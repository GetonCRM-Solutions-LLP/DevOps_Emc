/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : 
1.Controller for - GoToWebinarAuthorization VF Page
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/

public class GoToWebinarVFController {
    
    public static String authCode;
    public static Boolean gotAuthCode;
    public static Boolean returnValue {get;set;}

    public static GoToWebinar__mdt goToWebinar = [Select id,MasterLabel, Access_Token__c,Account_Key__c,
                                                        DeveloperName, Organizer_Key__c, QualifiedApiName, Refresh_Token__c, 
                                                        Token_Created_Time__c, Token_Expire_Time__c,Client_Id__c, Client_Secret__c, 
                                                        Authentication_Endpoint__c, Endpoint__c,Redirect_URL__c  
                                                    FROM GoToWebinar__mdt
                                                    WHERE MasterLabel ='G2W oAuth'];
                
    
    /** 
    * ********************************************************
    *  getAccessToken-
    1.Called from GoToWebinarAuthorization vf page on Load
    2.Update Access Token in Custom MetaData
    * ********************************************************
    */

    public static void getAccessToken(){
       
        if(!ApexPages.currentPage().getParameters().containskey('code')){
            gotAuthCode = false;
            return;
        }else{
            gotAuthCode = true;
            authCode = ApexPages.currentPage().getParameters().get('code');
        }
          
        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(goToWebinar.Client_Id__c +':'+ goToWebinar.Client_Secret__c));
        String redirectUri = goToWebinar.Redirect_URL__c;
     
        String endpoint = goToWebinar.Authentication_Endpoint__c + 'token?grant_type=authorization_code&code='+authCode+'&redirect_uri='+ redirectUri ;
        
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Authorization' , 'Basic '+ base64encodedString);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        
        try{
            httpRes = http.send(httpReq);

            System.debug('Access Token Status code :'+httpRes.getStatusCode());
            System.debug('Access Token Response Body:'+httpRes.getBody());

            if(httpRes.getStatusCode() == 200){
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                Map<String,Object> cMDfieldMap = new Map<String,Object>();

                cMDfieldMap.put('Access_Token__c',string.valueof(result.get('access_token')));
                cMDfieldMap.put('Account_Key__c', string.valueof(result.get('account_key')));
                cMDfieldMap.put('Refresh_Token__c', string.valueof(result.get('refresh_token')));
                cMDfieldMap.put('Token_Created_Time__c', system.now());
                cMDfieldMap.put('Token_Expire_Time__c', system.now().addSeconds(Integer.valueof(result.get('expires_in'))));

                CustomMetaDataUtil.updateCustomMetadata('GoToWebinar__mdt','G2W_oAuth','G2W oAuth',cMDfieldMap);
            } else{
                System.debug('Invalid Response:'+httpRes.getBody());
            }
        }catch(System.Exception e){
            System.debug('Exception : '+e.getMessage());
        }
    }

      /** 
    * ********************************************************
    *  getAuthCode - 
    * Get Auth Code By redirecting VfPage to GoToWebinar Endpoint
    * ********************************************************
    */
    public Pagereference getAuthCode(){

        String endPoint = goToWebinar.Authentication_Endpoint__c+'authorize?client_id='
                            + goToWebinar.Client_Id__c +'&response_type=code&redirect_uri='+ 
                                goToWebinar.Redirect_URL__c ;
        
        Pagereference url4AuthCode = new Pagereference(endPoint);
        return url4AuthCode.setRedirect(True);
    }

    public static void updateWebhookDetails(){
        try{
            GoToWebinarSetUpController.updateWebhookDetails();
            returnValue = true;
        }
        catch(Exception e){
            returnValue = false;
        }
    }

}