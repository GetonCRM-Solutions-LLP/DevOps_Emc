/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use to change the status of trips in mlog/triplog when admin can run a report fixed and variable report.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 02 July 2021 | Sanket Goswami
 * @description: 
 */
global class ChangeTripStatusByAdmin implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public Map<String,List<String>> approveReimwithTripIdMap;
    public Map<String,List<String>> rejectReimwithTripIdMap;
    public Map<String,List<String>> pendingReimwithTripIdMap;
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    public string accountId;
    public String lastMonth;
    TriplogPutCall__c emailConfig = TriplogPutCall__c.getValues('ChangeTripStatusByAdmin');
    public ChangeTripStatusByAdmin(String accId,String month) {
        accountId = accId;
        lastMonth = month;
    }
    global List<Employee_Reimbursement__c> start(Database.BatchableContext BC) {
        //String lastMonth = Utils.fetchMonths(1, 0)[0];
        List<Employee_Reimbursement__c> erm = [SELECT ID, Status__c,                      
                        Contact_Id__r.Account.Triplog_API__c,
                        Month__c 
                    FROM Employee_Reimbursement__c 
                    WHERE Month__c =: lastMonth
                        AND Contact_Id__r.Account.isUsingTriplog__c = true
                        AND Contact_Id__r.AccountId =:accountId];
        System.debug('erm list: '+erm);
        return [SELECT ID, Status__c,                      
                        Contact_Id__r.Account.Triplog_API__c,
                        Month__c 
                    FROM Employee_Reimbursement__c 
                    WHERE Month__c =: lastMonth
                        AND Contact_Id__r.Account.isUsingTriplog__c = true
                        AND Contact_Id__r.AccountId =:accountId];
    }
    global void execute(Database.BatchableContext BC, List<Employee_Reimbursement__c> scope) {
        Set<Id> reimId = new Set<Id>();
        List<Tripslog__c> triplogsList = new List<Tripslog__c>();
        approveReimwithTripIdMap = new Map<String, List<String>>();
        rejectReimwithTripIdMap = new Map<String,List<String>>();
        pendingReimwithTripIdMap = new Map<String,List<String>>();
        for(Employee_Reimbursement__c reim : (List<Employee_Reimbursement__c>) scope) {
            reimId.add(reim.Id);
        }
        for(Employee_Mileage__c mil : [SELECT Id,
                                            EmployeeReimbursement__c,
                                            Trip_Id__c,
                                            Trip_Status__c  
                                        FROM Employee_Mileage__c 
                                            WHERE Trip_Id__c != null AND EmployeeReimbursement__c In: reimId]){
            if(mil.Trip_Status__c == 'Approved'){
                if(approveReimwithTripIdMap.containsKey(mil.EmployeeReimbursement__c)) {
                    approveReimwithTripIdMap.get(mil.EmployeeReimbursement__c).add( String.valueOf(mil.Trip_Id__c));
                } else {
                    approveReimwithTripIdMap.put(mil.EmployeeReimbursement__c, new List<String> { String.valueOf(mil.Trip_Id__c)});
                }
            } else if(mil.Trip_Status__c == 'Rejected'){
                if(rejectReimwithTripIdMap.containsKey(mil.EmployeeReimbursement__c)) {
                    rejectReimwithTripIdMap.get(mil.EmployeeReimbursement__c).add(String.valueOf(mil.Trip_Id__c));
                } else {
                    rejectReimwithTripIdMap.put(mil.EmployeeReimbursement__c, new List<String> { String.valueOf(mil.Trip_Id__c)});
                }
            } else if(mil.Trip_Status__c == 'Not Approved Yet'){
                if(pendingReimwithTripIdMap.containsKey(mil.EmployeeReimbursement__c)) {
                    pendingReimwithTripIdMap.get(mil.EmployeeReimbursement__c).add(String.valueOf(mil.Trip_Id__c));
                } else {
                    pendingReimwithTripIdMap.put(mil.EmployeeReimbursement__c, new List<String> { String.valueOf(mil.Trip_Id__c)});
                }
            }
        }
        if(emailConfig != null && emailConfig.TriplogPut__c ) {
            for(Employee_Reimbursement__c reim : (List<Employee_Reimbursement__c>) scope) {
                String body ='';                       
                if(approveReimwithTripIdMap.containsKey(reim.id)) {
                    body = BuildBody( 'Approved', approveReimwithTripIdMap.get(reim.id));
                    triplogsList.add( callPutApi(
                        String.valueOf(reim.Contact_Id__r.Account.Triplog_API__c),
                        body,
                        reim.Contact_Id__c,
                        reim.id,
                        approveReimwithTripIdMap.get(reim.id).size()
                        )
                    );
                }
                if(rejectReimwithTripIdMap.containsKey(reim.id)) {
                    body = BuildBody( 'Rejected', rejectReimwithTripIdMap.get(reim.id));
                    triplogsList.add( callPutApi(
                        String.valueOf(reim.Contact_Id__r.Account.Triplog_API__c),
                        body,
                        reim.Contact_Id__c,
                        reim.id,
                        rejectReimwithTripIdMap.get(reim.id).size()
                        )
                    );
                }
                if(pendingReimwithTripIdMap.containsKey(reim.id)) {
                    body = BuildBody( 'Submitted', pendingReimwithTripIdMap.get(reim.id));
                    triplogsList.add( callPutApi(
                        String.valueOf(reim.Contact_Id__r.Account.Triplog_API__c),
                        body,
                        reim.Contact_Id__c,
                        reim.id,
                        pendingReimwithTripIdMap.get(reim.id).size()
                        )
                    );
                }
            }
        }
        if(!triplogsList.isEmpty())
            insert triplogsList;
    }
    global void finish(Database.BatchableContext BC) {

    }
    public Tripslog__c callPutApi(String ApiKey, String bodyOfReq, String contactId, String reimbursementId, Integer totalTrips) {
        String baseURL = !MLOGACCOUNT.Contains(ApiKey) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        Http putHTTP = new Http(); 
        HttpRequest putReq = new HttpRequest();               
        HttpResponse putRes = new HttpResponse();
        putReq.setEndpoint(baseURL + '/api/tripStatus');
        putReq.setMethod('PUT');                 
        putReq.setBody(bodyOfReq);
        putReq.setTimeout(120000);
        putReq.setHeader('Authorization', 'apikey ' + ApiKey);

        if(!Test.IsRunningTest()) {
            putRes = putHTTP.send(putReq);
        }

        Tripslog__c triplogobj = new Tripslog__c();
        triplogobj.Body__c = bodyOfReq;
        triplogobj.Contact__c = contactId;
        triplogobj.Employee_Reimbursement__c = reimbursementId;
        triplogobj.Endpoint__c = baseURL + '/api/tripStatus';
        if(!Test.IsRunningTest()) {
             triplogobj.Response__c = putRes.getStatusCode() + ' ######## ' + putRes.getStatus();
        }
        triplogobj.Total_Trips__c = totalTrips;
        triplogobj.Total_Mileages__c = 0;
        triplogobj.Status__c = !Test.IsRunningTest() && putRes.getStatusCode() == 200 ? 
                                'Success' :
                                'Fail';
        return triplogobj;
    }

    /**
     * Build Put call body
     */
    public static String BuildBody(String status, List<String> mileageIds) {
        return '{"status":' + status + ',"ids":[' + String.join(mileageIds, ',') + ']}';
    }
}