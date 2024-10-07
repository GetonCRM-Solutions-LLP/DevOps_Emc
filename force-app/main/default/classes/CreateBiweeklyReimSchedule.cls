global class CreateBiweeklyReimSchedule implements Schedulable  {
    public static final String JOB_NAME = 'Create BiWeekly PayPeriod';
    
    global void execute(SchedulableContext sc) {
        CreateBiweeklyReim biWeeklyreimbursementtobecreated = new CreateBiweeklyReim(); 
        Database.executeBatch(biWeeklyreimbursementtobecreated, 1);
    }
}