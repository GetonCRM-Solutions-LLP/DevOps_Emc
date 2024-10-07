public with sharing class UpdateActivityStatusInMlog {
    @InvocableMethod(label='Check Activity Status' description='Change Activity Status on Mlog if Driving State on Contact not contain state Value' category='Employee_Mileage__c')
    public static void changedActivityStatus(List<String> ids){
        System.debug('Call Method from Flow');

        for(Employee_Mileage__c mileages : [Select Id,Name,Trip_Id__c,Trip_Origin_State__c, Trip_Destination_State__c, Bi_Weekly_Reimbursement__r.Contact__r.Driving_States__c,Bi_Weekly_Reimbursement__r.Contact__c from Employee_Mileage__c where Id In: ids]){
            // Employee_Mileage__c mileages = [Select Id,Name,Trip_Id__c,Trip_Origin_State__c, Trip_Destination_State__c, Bi_Weekly_Reimbursement__r.Contact__r.Driving_States__c,Bi_Weekly_Reimbursement__r.Contact__c from Employee_Mileage__c where Id =: ids[0]];
            if(mileages.Trip_Id__c != null && mileages.Bi_Weekly_Reimbursement__r.Contact__c != null){
                putHTTPUpdateTriplogActivity(String.valueOf(mileages.Trip_Id__c),mileages.Bi_Weekly_Reimbursement__r.Contact__c);
            } else {
                System.debug('Trip id is null or Related Contact not available so not able to callout to update in mlog');
            }
        }
        
    }

    @Future(callout = true)
    public static void putHTTPUpdateTriplogActivity(String tripId, String conId) {
        System.debug('putHTTPUpdateTriplogActivity: '+ conId+ ' '+ tripId);
        Http h;
        HttpRequest req;
        HttpResponse res;
        String mLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2; 
        for(Contact conObj : [SELECT id,Triplog_UserID__c,Email, Account.Triplog_API__c  FROM Contact WHERE id =: conId]) {
            if(conObj.Triplog_UserID__c != null && conObj.Account.Triplog_API__c != null){
                try{
                System.debug('enter in loop');
                String baseURL = !mLOGACCOUNT.Contains( conObj.Account.Triplog_API__c ) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('activity','Uncategorized');
                gen.writeEndObject();
                h = new Http();
                req = new HttpRequest();
                req.setEndpoint( baseURL + '/api/trips/' + tripId);
                req.setMethod('PUT');
                req.setTimeout(120000);
                req.setbody(gen.getAsString());
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'apikey '+ conObj.Account.Triplog_API__c);
                if(!Test.isRunningTest())
                {
                    res = h.send(req);            
                }
                }
                catch(Exception e){
                    System.debug(e.getmessage());
                    System.debug(e.getLinenumber());
                }
            }
        }
    }    
}