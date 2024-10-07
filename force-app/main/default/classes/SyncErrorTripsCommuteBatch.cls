public class SyncErrorTripsCommuteBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Boolean serverQuery;
    public String stDate;
    public String endDate;
    public Set<Id> reimbursementIds = new Set<Id>();
    //Send true for run mlog error records and false for run salesforce side error
    public SyncErrorTripsCommuteBatch(Boolean serverErrorQuery,String date1,String date2) {
        serverQuery = serverErrorQuery;
        stDate = date1;
        endDate = date2;
    }

    public List<Tripslog__c> start(Database.BatchableContext bc){
        General_Query__mdt customMetaData = General_Query__mdt.getInstance('SyncErrorTripsCommuteBatch');
        // List<General_Query__mdt> metaValue = [SELECT id,Sync_Trips_Error__c,Sync_Trips_Failed__c FROM General_Query__mdt];

        String endPoint = 'https://triplogmileage.com/web/api/tripStatus';
        String responseVal = '%200%';
        if(serverQuery){
            String query = customMetaData.savePrevMonthVal__c;
            query += ' WHERE  CreatedDate >= ' + stDate + '';
            query += ' AND  CreatedDate <  ' + endDate + '';
            query += ' AND Endpoint__c != \''+ endPoint + '\'';
            query += ' AND (NOT(Response__c LIKE \''+ responseVal +  '\' ))';
            //Here in savePrevMonthVal__c store Query for if error happen from mLog side
            System.debug('2 query:222 '+query);
            // List<Tripslog__c> tripsList = Database.query(customMetaData.savePrevMonthVal__c);
            List<Tripslog__c> tripsList = Database.query(query);
            System.debug('tripsList222: '+tripsList.size());
            return tripsList;
        } else {
            String query = customMetaData.revertReimVal__c;
            query += ' AND  CreatedDate >= ' + stDate + '';
            query += ' AND  CreatedDate <  ' + endDate + '';
            query += ' AND Endpoint__c != \''+ endPoint + '\'';
            query += ' AND Response__c LIKE \''+ responseVal + '\'';
            //Here in revertReimVal__c store Query for if record not insert in salesforce
            System.debug('1 query:111 '+query);
            // List<Tripslog__c> tripsList = Database.query(customMetaData.revertReimVal__c);
            List<Tripslog__c> tripsList = Database.query(query);
            System.debug('tripsList111: '+tripsList.size());
            return tripsList;
        }
    }

    public void execute(Database.BatchableContext bc, List<Tripslog__c> tripsList) {
        Map<String,Employee_Reimbursement__c> contactEmployeeReimbursementMap= new Map<String,Employee_Reimbursement__c>();
        List<String> obj_monthformileagesCurrentMonth = new List<String>();
        List<String> contactIdList = new List<String>();
        for(Tripslog__c currentTrips : (List<Tripslog__c>) tripsList) {
            contactIdList.add(currentTrips.Contact__c );
        }

        obj_monthformileagesCurrentMonth.add(Utils.fetchMonths(1, -1)[0]);  
        for(Employee_Reimbursement__c empReim : [SELECT Id,Contact_Id__c,Contact_Id__r.Biweek_Reimbursement__c,Total_Mileage_WithOut_Previous__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_price__c, MPG__c, Maintenance_and_Tires__c FROM Employee_Reimbursement__c WHERE month__c =: obj_monthformileagesCurrentMonth AND Contact_Id__c IN: contactIdList]) {
            contactEmployeeReimbursementMap.put(empReim.Contact_Email__c+'-'+empReim.Month__c,empReim);            
        }

        for(Tripslog__c trips : (List<Tripslog__c>)tripsList) {
            Double totalmileages=0;
            if(trips.Contact__r.Account.Triplog_API__c != null && trips.Contact__r.Account.Triplog_API__c != '') {
                if(contactEmployeeReimbursementMap.containsKey(trips.Contact__r.External_Email__c+'-'+Utils.fetchMonths(1, -1)[0])) {

                    String str = trips.Endpoint__c;
                    String firstSplit = str.substringBefore('&'); 
                    String startMonthDate = firstSplit.substringAfter('='); 
                    System.debug('startMonthDate: '+startMonthDate);

                    String lastSplits = str.substringAfter('endDate=');
                    String lastMonthDate = lastSplits.substringBefore('&');
                    System.debug('lastMonthDate: '+lastMonthDate);

                    Employee_Reimbursement__c reim = contactEmployeeReimbursementMap.get(trips.Contact__r.External_Email__c+'-'+Utils.fetchMonths(1, -1)[0]);
                   
                    String reimFuel = String.valueof(reim.Fuel_price__c) != null ? String.valueof(reim.Fuel_price__c):'';
                    String reimMPG = String.valueof(reim.MPG__c) != null ? String.valueof(reim.MPG__c):'';
                    String reimMAT = String.valueof(reim.Maintenance_and_Tires__c) != null ? String.valueof(reim.Maintenance_and_Tires__c):'';
                    Boolean checkBiweek = reim.Contact_Id__r.Biweek_Reimbursement__c != null ? reim.Contact_Id__r.Biweek_Reimbursement__c : false;
                    //String biweekReimId = MappingGasPriceTriggerHelper.getBiweekReimId(con.Id,con.Account.Pay_Period_Start_Date__c,Integer.valueOf(con.Account.Pay_Period_Days__c),System.today()-1);
                    if(reim != null && trips.Contact__r.Email != null && !Test.IsRunningTest()) {
                        reimbursementIds.add(reim.id);
                       GetTripCalloutforCommute.GetTripCalloutForCommuteMileage(reim.id, trips.Contact__r.Email,trips.id,startMonthDate, lastMonthDate, reimFuel, reimMPG, reimMAT, trips.Contact__r.Account.Triplog_API__c, '',false,'Business',checkBiweek,null);
                    }
                }
            }
        }
    }
    public void finish(Database.BatchableContext bc){}
    
}