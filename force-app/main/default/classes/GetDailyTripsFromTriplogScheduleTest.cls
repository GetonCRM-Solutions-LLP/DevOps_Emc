@istest
public class GetDailyTripsFromTriplogScheduleTest {
    public static testmethod void testMethod1(){

        String month = date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        GetDailyTripsFromTriplogSchedule m = new GetDailyTripsFromTriplogSchedule();
        String sch = '  0 0 6 2 1/1 ? *';        
        String jobID = system.schedule('Checking Missing Fuel Price for '+month, sch, m);
    }
}