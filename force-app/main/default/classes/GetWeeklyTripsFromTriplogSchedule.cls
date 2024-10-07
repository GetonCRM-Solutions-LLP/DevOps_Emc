global class GetWeeklyTripsFromTriplogSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        String accName = System.Label.ERMIACCNAME;
      
        List<Employee_Mileage__c> milesForDelete = new List<Employee_Mileage__c>();
        Date startDate = System.today().addDays(-7);
        Date endDate = System.today().addDays(-1);

        for(Employee_Mileage__c miles : [Select Id,Name,Bi_Weekly_Reimbursement__r.End_Date__c,Bi_Weekly_Reimbursement__r.Contact__r.Id,Trip_Date__c,Trip_Status__c,Bi_Weekly_Reimbursement__r.Contact__r.Account.Name from Employee_Mileage__c where Trip_Status__c = 'Not Approved Yet' AND Bi_Weekly_Reimbursement__r.Contact__r.Account.Name =: accName AND Trip_Date__c >=: startDate AND Trip_Date__c <=: endDate]){
            milesForDelete.add(miles);
        }
        if(milesForDelete.size() > 0 ){
            delete milesForDelete;
        }
        GetWeeklyTripsFromTriplog reimbursementtobecreated = new GetWeeklyTripsFromTriplog('U'); 
        Database.executeBatch(reimbursementtobecreated, 1);
    }
}