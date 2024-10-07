global class TriplogStateUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL  + ',' + System.Label.Triplog_New_URL2;
    public TriplogStateUpdateBatch() {
    }

    global List<Account> start(Database.BatchableContext BC) {  
        return [ SELECT id,
                        Name,
                        Triplog_API__c 
                    FROM Account 
                    WHERE isUsingTriplog__c = true 
                        AND Triplog_API__c != null ];
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<Id> accountIds = new Set<Id>();
        for(Account accountObj : (List<Account>) scope){
            accountIds.add(accountObj.Id);
        }

        for(Contact currentContact : [SELECT id,
                                            Triplog_UserID__c,
                                            Deactivated_Date__c,
                                            Driving_States__c,
                                            Account.Triplog_API__c
                                        FROM Contact 
                                        WHERE AccountId IN: accountIds 
                                            AND Deactivated_Date__c = null
                                            AND ( Role__c =: StaticValues.ROLE_DRIVER 
                                                  OR Role__c =: StaticValues.ROLE_DRIVERMANAGER 
                                                  OR Role__c =: StaticValues.roleAdminDriver )])
        {
            String baseURL = !MLOGACCOUNT.Contains(currentContact.Account.Triplog_API__c) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
            baseURL = baseURL + '/api/users/' +currentContact.Triplog_UserID__c;
            String body;
            if(currentContact.Driving_States__c != null && currentContact.Driving_States__c.contains(';')){
                body = '{"territory":'+ currentContact.Driving_States__c.replace(';',',') +'}';
            }
            else{
                body = '{"territory":'+ currentContact.Driving_States__c+'}';
            }

            TriplogPutCall__c objTriplog = TriplogPutCall__c.getValues('TriplogStateUpdateBatch');

            try {
                if(!Test.isRunningTest() && objTriplog.TriplogPut__c == true) {
                    HttpResponse res = ApiCalloutUtility.executeCallout(currentContact.Account.Triplog_API__c,'PUT',baseURL,'',body);
                    system.debug('res'+res);
                }
            } catch(System.CalloutException er) {
    
            }
        }
    }

    global void finish(Database.BatchableContext bc){
        
    }

}