public with sharing class UpdateNotesAndTagsInMlog {
    @InvocableMethod(label='Change Tags & notes ' description='Change Tags and notes on Mlog if tags and notes in salesforce are changed' category='Employee_Mileage__c')
    public static void changedNotesAndTags(List<String> ids){
        System.debug('ids: '+ ids);
        System.debug('Call Method from Flow');

        for(Employee_Mileage__c mileages : [Select Id,Name,Trip_Id__c,Tag__c,Notes__c,Bi_Weekly_Reimbursement__r.Contact__r.Driving_States__c,Bi_Weekly_Reimbursement__r.Contact__c from Employee_Mileage__c where Id In: ids]){
            System.debug('inside the for loop ');
            System.debug('Trip_Id__c '+mileages.Trip_Id__c);
            System.debug('Bi_Weekly_Reimbursement__r.Contact__c '+mileages.Bi_Weekly_Reimbursement__r.Contact__c);

            if(mileages.Trip_Id__c != null && mileages.Bi_Weekly_Reimbursement__r.Contact__c != null){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('tags',mileages.Tag__c);
                gen.writeStringField('notes',mileages.Notes__c);
                gen.writeEndObject();
                System.debug('JSON object: '+ gen.getAsString());
                putHTTPUpdateTriplogTagsNotes(String.valueOf(mileages.Trip_Id__c),mileages.Bi_Weekly_Reimbursement__r.Contact__c,gen.getAsString());
            }
            else{
                System.debug('Trip id is null or Related Contact not available so not able to callout to update in mlog');
            }
        }
    }

    @Future(callout = true)
    public static void putHTTPUpdateTriplogTagsNotes(String tripId, String conId,String Json) {
        System.debug('putHTTPEnableUserTriplog: '+ conId);
        System.debug('Json: '+ Json);

        Http h;
        HttpRequest req;
        HttpResponse res;
        String mLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
        for(Contact conObj : [SELECT id,Triplog_UserID__c,Email, Account.Triplog_API__c  FROM Contact WHERE id =: conId]) {
            if(conObj.Triplog_UserID__c != null && conObj.Account.Triplog_API__c != null ){
                String baseURL = !mLOGACCOUNT.Contains( conObj.Account.Triplog_API__c ) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                h = new Http();
                req = new HttpRequest();
                req.setEndpoint( baseURL + '/api/trips/' + tripId);
                String st=baseURL + '/api/trips/' + tripId;
                system.debug('st--->>'+st);
                req.setMethod('PUT');
                req.setTimeout(120000);
                req.setbody(Json);
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