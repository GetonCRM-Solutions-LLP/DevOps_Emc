/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description :  Method contains for calling TrueDialog API   
                1)executeCallout method take request body,method,resourceName and call the API return Response
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/



public with sharing class TrueDialogAPICallout {

        /** 
    * ********************************************************
    *  Method for truedialog callout
    * ********************************************************
    */

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
        }else if(method == 'GET' && resourceName=='media'){
            endpoint = 'https://api.truedialog.com/api/v2.1/media/'+requestBody;

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
}