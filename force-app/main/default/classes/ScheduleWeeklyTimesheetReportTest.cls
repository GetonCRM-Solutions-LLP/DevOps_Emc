@istest
public with sharing class ScheduleWeeklyTimesheetReportTest {
    public static testMethod void ScheduleWeeklyTimesheetReportTestTestMethod() {
        Test.startTest();
        ScheduleWeeklyTimesheetReport schMailDelta = new ScheduleWeeklyTimesheetReport();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schMailDelta);
        Test.stopTest();
    }
}