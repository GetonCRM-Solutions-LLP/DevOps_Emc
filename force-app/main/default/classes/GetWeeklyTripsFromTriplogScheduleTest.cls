@istest
public class GetWeeklyTripsFromTriplogScheduleTest {
    public static testmethod void testMethod1(){

        String month = date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        GetWeeklyTripsFromTriplogSchedule m = new GetWeeklyTripsFromTriplogSchedule();
        String sch = '  0 0 6 2 1/1 ? *';        
        String jobID = system.schedule('Weekly Trips from triplog '+month, sch, m);
    }
}