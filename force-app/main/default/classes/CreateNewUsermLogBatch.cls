Global class CreateNewUsermLogBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT FirstName,LastName,Phone,External_Email__c,Triplog_UserID__c,Driving_States__c,isCommunityUser__c,Account.Triplog_API__c  FROM Contact WHERE Deactivated_Date__c = null and Activation_Date__c =today and Triplog_UserID__c = null ';
        return Database.getQueryLocator(soqlQuery);
    }
    global void execute(Database.BatchableContext bc, List<Contact> scope){
        String MLOGACCOUNT = System.Label.Triplog_New_URL  + ',' + System.Label.Triplog_New_URL2;
        Http h;
        HttpRequest req;
        HttpResponse res;
        List<Contact> listToUpdate = new List<Contact>();
        for(contact newContact : scope){
           
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('firstName',newContact.FirstName != null ? newContact.FirstName : '' );
            gen.writeStringField('lastName', newContact.LastName);
            gen.writeStringField('email', newContact.External_Email__c);
            gen.writeStringField('phone', (newContact.Phone != null) ? newContact.Phone :'');
            gen.writeStringField('isDriver', 'true');
            if(newContact.Driving_States__c != null || newContact.Driving_States__c == '') {
                String x = newContact.Driving_States__c;
                x = x.replaceAll(';', ',');
                gen.writeStringField('territory', (x != null) ? x :'');
            }
            gen.writeEndObject();
            String jsonstringconvert = gen.getAsString();
            String baseURL;
            if(newContact.Account.Triplog_API__c!=null){
                baseURL = !MLOGACCOUNT.Contains(newContact.Account.Triplog_API__c) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
            }
            h = new Http();
            req = new HttpRequest();
            req.setEndpoint(baseURL + StaticValues.DEACTIVATE_USER_SUFFIX);
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setbody(jsonstringconvert);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'apikey '+ newContact.Account.Triplog_API__c);
            if(!Test.isRunningTest()){
                res = h.send(req);
            
                if(res.getStatusCode() == 200) {
                    TripLogJSONPost tripLogRes = TripLogJSONPost.parse(res.getBody());
                    newContact.isCommunityUser__c = true;
                    newContact.Triplog_UserID__c = String.valueOf(tripLogRes.user.id);
                    newContact.Is_Driver_In_Triplog__c = true;
                    listToUpdate.add(newContact);
                    
                } else {
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'User not create in Triplog');
                }
            }
        }
        if(!listToUpdate.isEmpty()){
            try{
                update listToUpdate;
            } catch (Exception e){
                
                
            }
        }
    }
    global void finish(Database.BatchableContext bc){   
    }
}