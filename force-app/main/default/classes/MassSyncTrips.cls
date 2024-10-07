global class MassSyncTrips implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    public string accid;
    public string startDate;
    public string endDate;
    public string lastMonth;
    public string tripStatus;
    public Boolean putcall;
    
    global Set<Id> reimbursementIds = new Set<Id>();
    public MassSyncTrips(String accountId,String minDate,String maxDate,String month,String status,Boolean putapi) {
         
        accid = accountId;
        startDate = minDate;
        endDate = maxDate;
        lastMonth = month;
        tripStatus = status;
        putcall = putapi;
        System.debug('startDate=='+startDate);
         System.debug('endDate'+endDate);
         System.debug('lastMonth'+lastMonth);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query;
        //String lastMonth = Utils.fetchMonths(1, 0)[0];
        if(!Test.isRunningTest()){
            query = 'SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Reimbursement_Frequency__c,Contact_Id__r.Account.Triplog_API__c,Contact_Id__r.Biweek_Reimbursement__c,Total_Mileage_WithOut_Previous__c,Status__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c FROM Employee_Reimbursement__c WHERE Status__c = \'Pending\' AND Month__c = \''+lastMonth+'\' AND Contact_Id__r.AccountId = \''+accid+'\' ';
        } else {
            query = 'SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Reimbursement_Frequency__c,Contact_Id__r.Account.Triplog_API__c,Contact_Id__r.Biweek_Reimbursement__c,Total_Mileage_WithOut_Previous__c,Status__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c FROM Employee_Reimbursement__c';
        }
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
         List<String> monthSpillted = new list<String>();
        if(lastMonth.contains('-')){
            monthSpillted = String.valueOf(lastMonth).split('-'); 
        }
        string startDate1 = monthSpillted[1] +'-'+ monthSpillted[0] +'-'+ '01';
        Integer numberOfDays = Date.daysInMonth(integer.valueof(monthSpillted[1]), integer.valueof(monthSpillted[0]));
        string endDate1 = monthSpillted[1] +'-'+ monthSpillted[0] +'-'+ numberOfDays ; 
        Boolean checkBiweek;
        for(Employee_Reimbursement__c reim : (List<Employee_Reimbursement__c>) scope)
        {
            checkBiweek = reim.Contact_Id__r.Reimbursement_Frequency__c != null && reim.Contact_Id__r.Reimbursement_Frequency__c == 'Monthly Reimbursement' ? false : true;
            system.debug('checkBiweek==' +checkBiweek);
            reimbursementIds.add(reim.id);
            if( !Test.IsRunningTest()){
                String result = GetTripCallout.GetTripCalloutForMileage(reim.id, reim.Contact_Id__r.External_Email__c, reim.Contact_Id__c, startDate1, endDate1, String.valueOf(reim.Fuel_Price__c), String.valueOf(reim.MPG__c), String.valueOf(reim.Maintenance_and_Tires__c), reim.Contact_Id__r.Account.Triplog_API__c, tripStatus ,putcall,checkBiweek,null);
            }
        }
    }
    

    global void finish(Database.BatchableContext BC) 
    {
        /*if(!reimbursementIds.isEmpty()){
            Database.executeBatch(new LoadMileageLocationBatch(reimbursementIds, true ),50);
        }*/
    }
}