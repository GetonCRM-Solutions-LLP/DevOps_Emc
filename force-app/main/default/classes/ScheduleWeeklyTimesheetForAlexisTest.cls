@istest
public with sharing class ScheduleWeeklyTimesheetForAlexisTest {
    public static testMethod void ScheduleWeeklyTimesheetForAlexisMethod() {
        Test.startTest();
        ScheduleWeeklyTimesheetForAlexis schMailDelta = new ScheduleWeeklyTimesheetForAlexis();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schMailDelta);
        Test.stopTest();
    }
}