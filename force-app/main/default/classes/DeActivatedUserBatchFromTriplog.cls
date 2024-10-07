global class DeActivatedUserBatchFromTriplog implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    String query;
    private static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    private static Http uHttp;
    private static HttpRequest uRequest;
    private static HttpResponse uResponse;
    private static String endPoint;
    public List<String> deActivatedConIds;
    public integer decider=0;
    public String userid='';
    global DeActivatedUserBatchFromTriplog(List<String> passeddeActivatedConIds) 
    {   deActivatedConIds = new List<String>();     
        deActivatedConIds = passeddeActivatedConIds;
        decider = 1; 
        String editedquery = '( ';
        for(String currentMonthName : deActivatedConIds)
        {
            editedquery = editedquery + '\''+currentMonthName+ '\','; 
        }
        if(editedquery.endsWith(','))
        {
            editedquery = editedquery.removeEnd(',');
        }
        editedquery = editedquery+' )';

        if(!Test.isRunningTest()){
       
           query = 'SELECT Id, Triplog_UserID__c, isCommunityUser__c, Deactivated_Date__c, External_Email__c, IsDeactivated__c, Account.Triplog_API__c FROM Contact WHERE Account.isUsingTriplog__c = true AND Id IN '+editedquery;
        }
        else
        {
             query = 'SELECT Id, Triplog_UserID__c, isCommunityUser__c, Deactivated_Date__c, External_Email__c, IsDeactivated__c, Account.Triplog_API__c FROM Contact WHERE IsDeactivated__c = false AND Deactivated_Date__c = Today AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\') LIMIT 1';
        }
        System.debug('query :- '+ query);
    }
    global DeActivatedUserBatchFromTriplog() {
        decider =0;
        if(!Test.isRunningTest())
            query = 'SELECT Id, Triplog_UserID__c, isCommunityUser__c, Deactivated_Date__c, External_Email__c, IsDeactivated__c, Account.Triplog_API__c FROM Contact WHERE IsDeactivated__c = false AND Deactivated_Date__c = Today AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\')';
        else
            query = 'SELECT Id, Triplog_UserID__c, isCommunityUser__c, Deactivated_Date__c, External_Email__c, IsDeactivated__c, Account.Triplog_API__c FROM Contact WHERE IsDeactivated__c = false AND Deactivated_Date__c = Today AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\') LIMIT 1';
        System.debug(query);
    }
    global DeActivatedUserBatchFromTriplog(String passeduserid) {
        decider =2;
        userid = passeduserid;
        String identifier = passeduserid.left(3);
        if(identifier == '001'&& (!Test.isRunningTest())) {
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE AccountId =\''+passeduserid+'\' ';   
        }
        else if(!Test.isRunningTest()){
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE Id =\''+passeduserid+'\' ';
        } 
        else {
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE Id =\''+passeduserid+'\' Limit 1';
        }
    }   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        SendEmail__c  objSendEmail = SendEmail__c.getValues('DeActivatedUserBatchFromTriplog');
        if(objSendEmail.Send_email_from_code__c==true)
        {
            for(Contact con :(List<Contact>)scope) 
            {
                deactivateUserTriplog(con.Account.Triplog_API__c, con);
            }
        }
    }

    webservice static void deactivateUserTriplog(String apiToken, Contact contactRecord) {
        try {
            String dbody = '{"disabled": true}';
            String baseURL = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
            if(contactRecord.Triplog_UserID__c != null && contactRecord.IsDeactivated__c == false) {
                uHttp = new Http();
                uRequest = new HttpRequest();
                uResponse = new HttpResponse();
                uRequest.setEndpoint(baseURL + StaticValues.DEACTIVATE_USER_SUFFIX +  '/' + contactRecord.Triplog_UserID__c);
                uRequest.setMethod('PUT');     
                uRequest.setBody(dbody);
                uRequest.setTimeout(120000);
                uRequest.setHeader('Authorization', 'apikey ' + apiToken);                
                if(!Test.isRunningTest()) {
                    uResponse = uHttp.send(uRequest);
                    system.debug(uResponse);
                }
                if(uResponse.getStatusCode() == 200){
                    contactRecord.IsDeactivated__c = true;
                    update contactRecord;    
                }
            }
        } catch(System.CalloutException er) {
            System.debug('PUT Error: '+er.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        if(!Test.isRunningTest() && decider==0) 
        {
            DeActivatedUserEmailBatch deActivatedUserEmailBatch = new DeActivatedUserEmailBatch();
            Database.executeBatch(deActivatedUserEmailBatch, 1);
        }
        else if(!Test.isRunningTest() && decider==1) 
        {
            DeActivatedUserEmailBatch deActivatedUserEmailBatch = new DeActivatedUserEmailBatch(deActivatedConIds);
            Database.executeBatch(deActivatedUserEmailBatch, 1);
        }
        else if(!Test.isRunningTest() && decider==2) 
        {
            DeActivatedUserEmailBatch deActivatedUserEmailBatch = new DeActivatedUserEmailBatch(userid);
            Database.executeBatch(deActivatedUserEmailBatch, 1);
        }
    }
    
}