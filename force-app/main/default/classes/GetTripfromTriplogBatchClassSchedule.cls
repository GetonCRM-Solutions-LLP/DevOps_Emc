global class GetTripfromTriplogBatchClassSchedule implements Schedulable{

    global void execute(SchedulableContext sc) {
        GetTripfromTriplogBatchClass reimbursementtobecreated = new GetTripfromTriplogBatchClass('U'); 
        Database.executeBatch(reimbursementtobecreated, 1);
   }
}