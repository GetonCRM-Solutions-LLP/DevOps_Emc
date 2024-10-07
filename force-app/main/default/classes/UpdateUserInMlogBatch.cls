global class UpdateUserInMlogBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable{
    global UpdateUserInMlogBatch() {}
    public static void putHTTPUpdateTriplogDrivingState(List<Contact> conlst ) {
        // System.debug('putHTTPEnableUserTriplog: '+ conlst);
        Http h;
        HttpRequest req;
        HttpResponse res;
        String mLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
        for(Contact conObj : conlst) {
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
    // Start Method
    global List<contact> start(Database.BatchableContext BC) {
        // list<String> conIdLst = new list<String>{'0030Z00003NFLRoQAP','0030Z00003NFLTfQAP','0030Z00003NFLUOQA5','0030Z00003RBqVsQAL','0030Z00003RCZ7kQAH','0030Z00003RI514QAD','0030Z00003RI524QAD','0030Z00003RKFUYQA5','0033r00003d3dorAAA','0033r00003e54UtAAI','003E1000008EG1tIAG'};
        String AccountNameLabel = System.label.TripstobeLogged; 
        List<String> AccountList = AccountNameLabel.split(','); 
        System.debug(AccountList);
        List<contact> conlst = [SELECT id,Driving_States__c,Triplog_UserID__c,Email, Account.Triplog_API__c  FROM Contact WHERE  Triplog_UserID__c != null AND Deactivated_Date__c =null AND Account.isUsingTriplog__c =true AND Account.Name IN :AccountList];
        if(Test.isRunningTest()){
            conlst = [SELECT id,Driving_States__c,Triplog_UserID__c,Email, Account.Triplog_API__c  FROM Contact WHERE  Triplog_UserID__c != null AND Deactivated_Date__c =null AND Account.isUsingTriplog__c =true];
        }
        System.debug('ConList-->'+conlst);
        //List<contact> conlst = [SELECT id,Driving_States__c,Triplog_UserID__c,Email, Account.Triplog_API__c  FROM Contact WHERE id = '003Nq00000A1KdG'];
        return conlst;
    }
    
    //Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        putHTTPUpdateTriplogDrivingState(scope);
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    global void execute(SchedulableContext sc){
        UpdateUserInMlogBatch batch =new UpdateUserInMlogBatch();
        Database.executeBatch(batch, 50);
    }
}