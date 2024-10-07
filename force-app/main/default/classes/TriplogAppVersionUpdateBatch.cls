/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Batch class to fetch App version of contacts from TripLog and update 
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 14 May 2020
 * @Description: Added MLOGACCOUNT to Identify new MLOG API accounts for fetching Trips
 */
global class TriplogAppVersionUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {

    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    global String responseOfAPICall = '';
    global TriplogAppVersionUpdateBatch() {}

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
        List<Contact> contactToUpdateList = new List<Contact>();
        Map<String,Contact> contactMap = new Map<String,Contact>();
        
        for(Account accountObj : (List<Account>) scope){
            accountIds.add(accountObj.Id);
        }

        for(Contact currentContact : [SELECT id,
                                            Name,
                                            Firstname,
                                            Triplog_UserID__c,
                                            External_Email__c,
                                            Deactivated_Date__c 
                                        FROM Contact 
                                        WHERE AccountId IN: accountIds 
                                            AND ( Role__c =: StaticValues.ROLE_DRIVER 
                                                  OR Role__c =: StaticValues.ROLE_DRIVERMANAGER 
                                                  OR Role__c =: StaticValues.roleAdminDriver )])
        {
            contactMap.put(currentContact.External_Email__c.toLowerCase(),currentContact);
        }

        for(Account accountObj : (List<Account>) scope){
            if (!Test.isRunningTest()) {
                responseOfAPICall = getTripIds(accountObj.Triplog_API__c);
            }
            if(String.isNotBlank(responseOfAPICall) && responseOfAPICall != 'Error' ) { 
                TriplogJsonUserParse triplogRes = TriplogJsonUserParse.parse(responseOfAPICall);                
                if(triplogRes.user !=null && !triplogRes.user.isEmpty()) {

                    for(TriplogJsonUserParse.Users currentUser : triplogRes.user) {
                        if(String.isNotBlank(currentUser.email) && contactMap.containsKey(currentUser.email.toLowerCase())) {                             
                            Contact currentContact = new Contact();
                            currentContact = contactMap.get(currentUser.email);
                            currentContact.Triplog_UserID__c = String.valueOf(currentUser.id);
                            currentContact.App__c = currentUser.appVersion;
                            if(currentUser.timeZone != null){
                                //List<String> resZone = currentUser.timeZone.split(',');                                
                                //currentContact.Time_Zone__c = resZone[0].substringAfter('=').replace('\"', '');
                                currentContact.Time_Zone__c = currentUser.timeZone;
                            }               
                            currentContact.Last_Synced__c = !GetTripCallout.CheckNull(currentUser.lastSynced) ? Utils.ConvertToDateAndTime(String.valueOf(currentUser.lastSynced)) : null;  
                            currentContact.App_Settings__c = currentUser.appSettings != null ? currentUser.appSettings : null;
                            contactToUpdateList.add(currentContact);
                        }
                    }
                }
                if(!contactToUpdateList.isEmpty()) {
                    List<Database.SaveResult> srList = Database.update(contactToUpdateList, false);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc){}

   
    public static String getTripIds(String passedApikey)
    {
        String baseURL = !MLOGACCOUNT.Contains(passedApikey) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint( baseURL + '/api/users');
        request.setMethod('GET');
        request.setHeader('Authorization','apikey ' + passedApikey);
        HttpResponse response = http.send(request);
        
        return response.getStatusCode() == 200 ? response.getBody() : 'Error';
    }
}