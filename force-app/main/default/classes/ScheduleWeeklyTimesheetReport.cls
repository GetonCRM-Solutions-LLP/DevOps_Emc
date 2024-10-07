global class ScheduleWeeklyTimesheetReport implements schedulable {
    global void execute(SchedulableContext sc) { 
        WeeklyTimesheetReportBatch sendBatch = new WeeklyTimesheetReportBatch();       
        database.executebatch(sendBatch,10);
     }
}