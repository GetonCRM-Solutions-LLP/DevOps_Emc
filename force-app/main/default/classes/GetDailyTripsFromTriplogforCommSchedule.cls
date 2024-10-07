Global class GetDailyTripsFromTriplogforCommSchedule implements Schedulable {
 global void execute(SchedulableContext sc) {
        GetDailyTripsFromTriplogforCommuteTrips getComTrips = new GetDailyTripsFromTriplogforCommuteTrips('U'); 
        Database.executeBatch(getComTrips, 1);
    }
}