global class ScheduleWeeklyTimesheetForAlexis implements schedulable {
    global void execute(SchedulableContext sc) { 
        WeeklyTimesheetForAlexis sendBatch = new WeeklyTimesheetForAlexis();       
        database.executebatch(sendBatch,10);
     }
}