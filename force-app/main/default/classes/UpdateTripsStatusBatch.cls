global class UpdateTripsStatusBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public String query;
    private static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    
    global UpdateTripsStatusBatch (String empReimId) {
        if(Test.isRunningTest()) {
            query = 'SELECT Id, Trip_Status__c, Trip_Id__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c limit 1'; 
        } else {
            query = 'SELECT Id, Trip_Status__c, Trip_Id__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c ' + 
                    ' WHERE Trip_Status__c = \'Rejected\' AND Trip_Id__c != null AND ' +
                    ' ( EmployeeReimbursement__c = \'' + empReimId + '\' OR Id = \'' + empReimId  + '\' )  limit 9999';
        }
        
    }
    
    global UpdateTripsStatusBatch (List<String> mileageIds) {
        String mileageQuery = ' ( ';
        for(String mId : mileageIds) {
            mileageQuery += '\'' + mId + '\' , '; 
        }
        
        mileageQuery = mileageQuery.removeEnd(', ') + ' ) ';
        
        if(Test.isRunningTest()) {
            query = 'SELECT Id, Trip_Status__c, Trip_Id__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c limit 1'; 
        } else {
            query = 'SELECT Id, Trip_Status__c, Trip_Id__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c ' + 
                    ' WHERE Trip_Status__c = \'Rejected\' AND Trip_Id__c != null AND ' +
                    ' Id In ' +  mileageQuery  + '  limit 9999';
        }
        
    }

    global UpdateTripsStatusBatch (List<String> months , String accountId) {
        String monthQuery = ' ( ';
        for(String month : months ) {
            monthQuery += 'EmployeeReimbursement__r.Month__c = \'' + month + '\' OR '; 
        }
        
        monthQuery = monthQuery.removeEnd('OR ') + ' ) ';
        
        if(Test.isRunningTest()) {
            query = 'SELECT Id, Trip_Status__c, Trip_Id__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c limit 1';
        } else {
            query = 'SELECT Id, Trip_Status__c, Trip_Id__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c ' + 
                    ' WHERE Trip_Status__c = \'Rejected\' AND Trip_Id__c != null AND ' +  monthQuery  + 
                    ' AND EmployeeReimbursement__r.Contact_Id__r.AccountId = \'' + accountId + '\'' ;
                   
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        String apiToken = '';
        Set<Integer> tripIds = new Set<Integer>();
        for ( Employee_Mileage__c  em : ( List<Employee_Mileage__c>) scope ) {
            tripIds.add(Integer.valueOf(em.Trip_Id__c));
            
            if(apiToken == '')
                apiToken = em.EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c;
        }
        
        if(!tripIds.isEmpty())
            RejectTrips( apiToken, tripIds );
    }
    
    global void finish(Database.BatchableContext BC) {}

    public void RejectTrips(String apiToken, Set<Integer> tripIds) {
        
        String baseURL = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        List<Tripslog__c> tripslogList = new List<Tripslog__c>();
        String part = '';
        String endPoint = StaticValues.STATUS_SUFFIX;
        String body = '{"status":"Rejected","ids":[';
        
        for (Integer i : tripIds) {
            part = part + String.valueof(i) +',';
        }
        
        part = part.removeEnd(',');
        body = body + part +']}';
        HttpResponse putRes = new HttpResponse();
        /*HttpRequest putReq = new HttpRequest();
        Http putHTTP = new Http();
        HttpResponse putRes = new HttpResponse();
        putReq.setEndpoint( baseURL + StaticValues.STATUS_SUFFIX);
        putReq.setMethod('PUT');                 
        putReq.setBody(body);
        putReq.setTimeout(120000);
        putReq.setHeader('Authorization', 'apikey ' + apiToken);
        putRes = putHTTP.send(putReq);*/
        try {
            if(!Test.isRunningTest()) {
                putRes = ApiCalloutUtility.executeCallout(apiToken,'PUT',endPoint,'',body);
                system.debug('res'+putRes);
            }
        } catch(CalloutException er) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, er.getMessage());
        }

        Tripslog__c obj = new Tripslog__c();
        obj.Body__c = body;
        obj.Endpoint__c =  baseURL + StaticValues.STATUS_SUFFIX;
        
        if(!Test.IsRunningTest())
        {
             obj.Response__c = String.valueOf(putRes.getStatusCode())+' ######## ' +putRes.getStatus();
        }
       
        obj.Total_Trips__c= 0;
        obj.Total_Mileages__c = 0;
        
        obj.Status__c = putRes.getStatusCode() == 200 ? 'Success' : 'Fail' ;
        
        tripslogList.add(obj);
        
        if(!tripslogList.isEmpty())
        {
            insert tripslogList ;
        }
        
        System.debug('putRes.getBody(): '+putRes.getBody());
        
    }
}