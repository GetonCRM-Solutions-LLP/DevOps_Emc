public with sharing class ActivateUserInMlog {
    
    @InvocableMethod(label='Activate User in Mlog ' description='Activating user in mlog when the user is activated in the salesforce  ' category='Contact')
    public Static Void ActivatingUser(List<String> ids) {
            System.debug('Call Method from Flow');
        for(String id :  ids){
            ActivatingUserinMlog(id);
        }
    }
    @future(Callout = true)
    public static void ActivatingUserinMlog(String conId ) {
        System.debug('ActivatingUserinMlog: '+ conId);
        Http h;
        HttpRequest req;
        HttpResponse res;
        String mLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2; 
        for(Contact conObj : [SELECT id,Driving_States__c,Triplog_UserID__c,Email, Account.Triplog_API__c  FROM Contact WHERE id =: conId]) {
            if(conObj.Triplog_UserID__c != null && conObj.Account.Triplog_API__c != null && conObj.Driving_States__c != null){
                String baseURL = !mLOGACCOUNT.Contains( conObj.Account.Triplog_API__c ) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeBooleanField('disabled',false);
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