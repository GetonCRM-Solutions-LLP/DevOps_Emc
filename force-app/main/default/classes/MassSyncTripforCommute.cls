global class MassSyncTripforCommute implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    public string accid;
    public string startDate;
    public string endDate;
    public string startDateNew;
    public string endDateNew;
    public string lastMonth;
    public string tripStatus;
    public Boolean putcall;
    public String activity;
    public Set<String> reimIdsnew = new Set<String>();
    global Set<Id> reimbursementIds = new Set<Id>();
    Map<String,String> biweekReim = new Map<String,String>();
    public MassSyncTripforCommute(String accountId,String minDate,String maxDate,String month,String status,Boolean putapi, String activityStatus) {
        
        accid = accountId; 
        lastMonth = month;
        tripStatus = status;
        putcall = putapi;
        activity = activityStatus;
        List<String> monthSpillted = new list<String>();
        if(lastMonth.contains('-')){
            monthSpillted = String.valueOf(lastMonth).split('-'); 
        }
        startDate = monthSpillted[1] +'-'+ monthSpillted[0] +'-'+ '01';
        Integer numberOfDays = Date.daysInMonth(integer.valueof(monthSpillted[1]), integer.valueof(monthSpillted[0]));
        endDate = monthSpillted[1] +'-'+ monthSpillted[0] +'-'+ numberOfDays ; 
    }
    public MassSyncTripforCommute(List<String> reimIds){ 
        System.debug(reimIds.size());
        //reimIdsnew = new Set<String>();
        reimIdsnew.addAll(reimIds);
        System.debug('reimIdsnew : ' + reimIdsnew);
    }
    public MassSyncTripforCommute(String biWeek,String accID){         
        List<EmployeeMileagesForCalculation> biWeekData = new List<EmployeeMileagesForCalculation>();
        biWeekData = (List<EmployeeMileagesForCalculation>) System.JSON.deserialize(biWeek, List<EmployeeMileagesForCalculation>.class);        
        for(EmployeeMileagesForCalculation reims: biWeekData ){
            if(reims.originalReimbursementid != null){
                biweekReim.put(reims.originalReimbursementid,reims.reimbursementid);
                reimIdsnew.add(reims.originalReimbursementid);
            }          
        }
        String payPeriodName = BiWeeklyWrapperUtils.getPayPeriodDates(accID);
        
        startDateNew = payPeriodName.SubStringBefore(' to');
        endDateNew = payPeriodName.SubStringAfter('to ');
        List<String> startDateSplitted = new List<String>();
        if((String.valueOf(startDateNew).contains('/'))) {
                startDateSplitted = String.valueOf(startDateNew).split('/');
        }
        startDateNew = String.valueOf(Date.newInstance(Integer.valueOf(startDateSplitted [2]), Integer.valueOf(startDateSplitted [0]), Integer.valueOf(startDateSplitted [1])));
        
        List<String> endDateSplitted = new List<String>();
        if((String.valueOf(endDateNew ).contains('/'))) {
                endDateSplitted = String.valueOf(endDateNew ).split('/');
        }
        endDateNew = String.valueOf(Date.newInstance(Integer.valueOf(endDateSplitted [2]), Integer.valueOf(endDateSplitted [0]), Integer.valueOf(endDateSplitted [1]))); 
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query;
        //String lastMonth = Utils.fetchMonths(1, 0)[0];
        if(!Test.isRunningTest() && reimIdsnew.size() == 0){
        System.debug('reimIdsnew **: ' + reimIdsnew);
            query = 'SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Id__r.Biweek_Reimbursement__c,Total_Mileage_WithOut_Previous__c,Status__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Reimbursement_Month__c,Year__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c WHERE Status__c = \'Pending\' AND Month__c = \''+lastMonth+'\' AND Contact_Id__r.AccountId = \''+accid+'\' ';
        } else if(!Test.isRunningTest() && reimIdsnew.size() > 0){
            System.debug('Inside else if ');
            query = 'SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Id__r.Biweek_Reimbursement__c,Total_Mileage_WithOut_Previous__c,Status__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Reimbursement_Month__c,Year__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c WHERE Status__c = \'Pending\' AND Id In: reimIdsnew ';
        } else {
            query = 'SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Id__r.Biweek_Reimbursement__c,Total_Mileage_WithOut_Previous__c,Status__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Reimbursement_Month__c,Year__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c';
        }
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        for(Employee_Reimbursement__c reim : (List<Employee_Reimbursement__c>) scope) {
            reimbursementIds.add(reim.id);
            System.debug('reim: ' + reim);
            Boolean biWeekVal = reim.Contact_Id__r.Reimbursement_Frequency__c != null && reim.Contact_Id__r.Reimbursement_Frequency__c == 'Bi-Weekly Reimbursement' ? true : false;
               System.debug('reimIdsnew==' + reimIdsnew);
                if(reimIdsnew.size() > 0 && biweekReim.size() == 0) {
                    Integer numberOfDays = Date.daysInMonth(Integer.Valueof(reim.Year__c), Integer.Valueof(reim.Reimbursement_Month__c));
                    Date lastDayOfMonth = Date.newInstance(Integer.Valueof(reim.Year__c), Integer.Valueof(reim.Reimbursement_Month__c), numberOfDays);
                    Date firstDayOfMonth = Date.newInstance(Integer.Valueof(reim.Year__c), Integer.Valueof(reim.Reimbursement_Month__c), 1);

                    //string startDate1 = String.valueOf(reim.Month_Field__c);
                    string startDate1 = String.valueOf(firstDayOfMonth);
                    string endDate1 = String.valueOf(lastDayOfMonth);
                    string tripStatus1 = 'U';
                    Boolean putcall1 = false;
                    String activity1 ='Business';
                        if( !Test.IsRunningTest()){
                            System.debug('reim.id: '+reim.id+' reim.Contact_Id__r.External_Email__c: '+reim.Contact_Id__r.External_Email__c+' reim.Contact_Id__c: '+reim.Contact_Id__c+' startDate: '+startDate+' endDate: '+endDate+' reim.Fuel_Price__c: '+String.valueOf(reim.Fuel_Price__c)+' reim.MPG__c: '+String.valueOf(reim.MPG__c)+' reim.Maintenance_and_Tires__c: '+String.valueOf(reim.Maintenance_and_Tires__c)+' reim.Contact_Id__r.Account.Triplog_API__c: '+reim.Contact_Id__r.Account.Triplog_API__c+' reim.Contact_Id__r.Biweek_Reimbursement__c: '+reim.Contact_Id__r.Biweek_Reimbursement__c);
                            GetTripCalloutforCommute.GetTripCalloutForCommuteMileage(reim.id, reim.Contact_Id__r.External_Email__c, reim.Contact_Id__c, startDate1, endDate1, String.valueOf(reim.Fuel_Price__c), String.valueOf(reim.MPG__c), String.valueOf(reim.Maintenance_and_Tires__c), reim.Contact_Id__r.Account.Triplog_API__c, tripStatus1 ,putcall1, activity1,biWeekVal,null);
                        } 
                    
                    }
                    else if(biweekReim.size() > 0 ){
                        if( !Test.IsRunningTest()){
                        system.debug('****'+biweekReim.get(reim.id));
                            System.debug('reim.id: '+reim.id+' reim.Contact_Id__r.External_Email__c: '+reim.Contact_Id__r.External_Email__c+' reim.Contact_Id__c: '+reim.Contact_Id__c+' startDateNew: '+startDateNew+' endDateNew: '+endDateNew+' reim.Fuel_Price__c: '+String.valueOf(reim.Fuel_Price__c)+' reim.MPG__c: '+String.valueOf(reim.MPG__c)+' reim.Maintenance_and_Tires__c: '+String.valueOf(reim.Maintenance_and_Tires__c)+' reim.Contact_Id__r.Account.Triplog_API__c: '+reim.Contact_Id__r.Account.Triplog_API__c+' reim.Contact_Id__r.Biweek_Reimbursement__c: '+reim.Contact_Id__r.Biweek_Reimbursement__c);
                            GetTripCalloutforCommute.GetTripCalloutForCommuteMileage(reim.id, reim.Contact_Id__r.External_Email__c, reim.Contact_Id__c, startDateNew, endDateNew, String.valueOf(reim.Fuel_Price__c), String.valueOf(reim.MPG__c), String.valueOf(reim.Maintenance_and_Tires__c), reim.Contact_Id__r.Account.Triplog_API__c, 'U',false, 'Business',true,biweekReim.get(reim.id));
                        } 
                    }
                    else {
                        System.debug('Inside else ');
                        if( !Test.IsRunningTest()){
                            GetTripCalloutforCommute.GetTripCalloutForCommuteMileage(reim.id, reim.Contact_Id__r.External_Email__c, reim.Contact_Id__c, startDate, endDate, String.valueOf(reim.Fuel_Price__c), String.valueOf(reim.MPG__c), String.valueOf(reim.Maintenance_and_Tires__c), reim.Contact_Id__r.Account.Triplog_API__c, tripStatus ,putcall, activity,biWeekVal,null);
                        }
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