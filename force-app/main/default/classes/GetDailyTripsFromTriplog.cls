/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use for sync daily trips from triplog.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 17 Sept 2020 | Sanket Goswami
 * @description: 
 */
global class GetDailyTripsFromTriplog implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    public String query;
    public String TripStatus; 
    public List<Id> contactIds;  
    global Set<Id> reimbursementIds = new Set<Id>();
    global GetDailyTripsFromTriplog() {}
    global GetDailyTripsFromTriplog(String trips) {
        List<String> obj_accountnames = new List<String>();
        String querybuilding ='';
        if(System.Label.TripstobeLogged!=null) {
            if(System.Label.TripstobeLogged.contains(',')) {
                obj_accountnames= System.Label.TripstobeLogged.split(',');
            }
            Integer i=0;    
            for(String s:obj_accountnames) {
                s = s.trim();
                if(s.contains(',')) {
                    s = s.replace(',','');
                }
                if(i==0) {
                    querybuilding = ' ( Account.Name = \''+s+'\'';    
                } else {
                    querybuilding = querybuilding+ ' OR '+ 'Account.Name = \''+s+'\'';
                }        
                i++;
            }
            querybuilding = querybuilding+' ) AND ';
        }
        TripStatus = trips;
        if(Test.isRunningTest()) {
            query = 'SELECT Id, Name,Account.Name,Biweek_Reimbursement__c,Reimbursement_Frequency__c, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE External_Email__c = \'minkesh.patel1478@gmail.com\' LIMIT 1';
        } else {
            query = 'SELECT Id, Name,Account.Name,Biweek_Reimbursement__c,Reimbursement_Frequency__c, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE '+querybuilding+' (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:90) AND Account.isUsingTriplog__c = true AND Is_Driver_In_Triplog__c = true AND  (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\')';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<String,Employee_Reimbursement__c> contactEmployeeReimbursementMap= new Map<String,Employee_Reimbursement__c>();
        List<String> obj_monthformileagesCurrentMonth = new List<String>();
        String lastMonth='';
        String startMonthDate = String.valueOf(System.today()-1);
        //String startMonthDate = String.valueOf(Date.today().toStartOfMonth());
        String lastMonthDate = String.valueOf(System.today());
        //String startMonthDate = '2021-05-01';
        //String lastMonthDate = '2021-05-03';
        Boolean putCall = false;
        List<String> contactIdList = new List<String>();
        for(Contact currentContact : (List<Contact>) scope) {
            contactIdList.add(currentContact.id);
        }

        obj_monthformileagesCurrentMonth.add(Utils.fetchMonths(1, -1)[0]);  
        for(Employee_Reimbursement__c empReim : [SELECT Id,Contact_Id__c,Contact_Id__r.Reimbursement_Frequency__c , Total_Mileage_WithOut_Previous__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_price__c, MPG__c, Maintenance_and_Tires__c FROM Employee_Reimbursement__c WHERE month__c =: obj_monthformileagesCurrentMonth AND Contact_Id__c IN: contactIdList]) {
            contactEmployeeReimbursementMap.put(empReim.Contact_Email__c+'-'+empReim.Month__c,empReim);            
        }
        
        for(Contact con : (List<Contact>)Scope) {
            Double totalmileages=0;
            if(con.Account.Triplog_API__c != null && con.Account.Triplog_API__c != ''||Test.isRunningTest()) {
                if(contactEmployeeReimbursementMap.containsKey(con.External_Email__c+'-'+Utils.fetchMonths(1, -1)[0])) {
                    Employee_Reimbursement__c reim = contactEmployeeReimbursementMap.get(con.External_Email__c+'-'+Utils.fetchMonths(1, -1)[0]);
                   
                    String reimFuel = String.valueof(reim.Fuel_price__c) != null ? String.valueof(reim.Fuel_price__c):'';
                    String reimMPG = String.valueof(reim.MPG__c) != null ? String.valueof(reim.MPG__c):'';
                    String reimMAT = String.valueof(reim.Maintenance_and_Tires__c) != null ? String.valueof(reim.Maintenance_and_Tires__c):'';
                    Boolean checkBiweek = reim.Contact_Id__r.Reimbursement_Frequency__c != null && reim.Contact_Id__r.Reimbursement_Frequency__c == 'Monthly Reimbursement' ? false : true;
                    if(reim != null && con.Email != null) {
                        reimbursementIds.add(reim.id);
                        String result = GetTripCallout.GetTripCalloutForMileage(reim.id, con.Email,con.id,startMonthDate, lastMonthDate, reimFuel, reimMPG, reimMAT, con.Account.Triplog_API__c, TripStatus,putCall,checkBiweek,null);
                    }
                }
            }
        }
    }    
    global void finish(Database.BatchableContext BC) {
        /*if(!reimbursementIds.isEmpty()){
            Database.executeBatch(new LoadMileageLocationBatch(reimbursementIds, true ),50);
        }*/
    }
}