global class GetDailyTripsFromTriplogSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        GetDailyTripsFromTriplog reimbursementtobecreated = new GetDailyTripsFromTriplog('U'); 
        Database.executeBatch(reimbursementtobecreated, 1);
    }
}