public with sharing class ChangeDrivingStateInMlog {
    @InvocableMethod(label='Change Driving State ' description='Change Driving State in Mlog When ever there is the change in the Driving State Value of contact ' category='Contact')
    public Static Void UpdateDrivingStateInMlog(List<String> ids) {
        System.debug('ids: '+ids);
        System.debug('Call Method from Flow');
        for(String Id :  ids){
                putHTTPUpdateTriplogDrivingState(Id);
        }
    }
    @Future(callout = true)
    public static void putHTTPUpdateTriplogDrivingState(String conId ) {
        System.debug('putHTTPEnableUserTriplog: '+ conId);
        Http h;
        HttpRequest req;
        HttpResponse res;
        String mLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2; 
        for(Contact conObj : [SELECT id,Driving_States__c,Triplog_UserID__c,Email, Account.Triplog_API__c  FROM Contact WHERE id =: conId]) {
            if(conObj.Triplog_UserID__c != null && conObj.Account.Triplog_API__c != null && conObj.Driving_States__c != null){
                String baseURL = !mLOGACCOUNT.Contains( conObj.Account.Triplog_API__c ) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('territory',conObj.Driving_States__c);
                gen.writeEndObject();
                system.debug('object body to be sent --->>'+gen.getAsString()); 

                h = new Http();
                req = new HttpRequest();
                req.setEndpoint( baseURL + '/api/users/' + conObj.Triplog_UserID__c);
                req.setMethod('PUT');
                req.setTimeout(120000);
                req.setbody(gen.getAsString());
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'apikey '+ conObj.Account.Triplog_API__c);
                if(!Test.isRunningTest())
                {
                    res = h.send(req);
                    system.debug('response--->>> '+res.getbody());          

                }
            }
        }
    }
}