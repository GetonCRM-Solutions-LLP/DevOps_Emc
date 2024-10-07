global class HelloSignIntegrationHandlerQueueable implements Queueable,Database.AllowsCallouts {

    public String emailId;
    public HelloSignIntegrationHandlerQueueable(String email){
        emailId = email;
    }
   
    global void execute(QueueableContext qc) {         
        String endpoint;
        Contact con = new Contact();
        if(!Test.isRunningTest()){
            con = [Select Id,Name,Hello_Sign_Error__c,Hello_Sign_Request_Id__c,Email from Contact where Email =: emailId];
        } else{
            con = [Select Id,Name,Hello_Sign_Error__c,Hello_Sign_Request_Id__c,Email from Contact LIMIT 1];
        }
        
        String helloSignReqId = con.Hello_Sign_Request_Id__c;
        String conId =con.Id;
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();

        Http http = new Http();
        httpReq.setMethod('GET');
        
        Blob headerValue = Blob.valueOf(System.label.HelloSignAuth + ':' + '');
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        httpReq.setHeader('Authorization', authorizationHeader);

        httpReq.setEndPoint('https://api.hellosign.com/v3/signature_request/'+helloSignReqId);

        httpRes = http.send(httpReq);
        String response = string.valueOf(httpRes);
        System.debug('response: '+httpRes.getBody());

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        Map<String, Object> result2 = (Map<String, Object>)result.get('signature_request');
        List<Object> newob = (List<Object>)result2.get('signatures');
        
        String str23;
        for(Object objNew : newob){
            Map<String,Object> rMap = (Map<String,Object>)objNew;
            if(rMap.get('error') != null){
                str23 = string.valueOf(rMap.get('error'));
            }
        }

        Contact conlst = [Select Id,Name,Hello_Sign_Error__c,Hello_Sign_Request_Id__c,Email from Contact where Id =: conId];
        if(str23 != null){
            conlst.Hello_Sign_Error__c = str23;
            update conlst;
        } else{
            conlst.Hello_Sign_Error__c = '';
            update conlst;
        }
    }   
}