global class ScheduleBiWeeklyReimCreateForErmi implements Schedulable	{
    public static final String JOB_NAME = 'Ermi Weekly Payperiod created';
    
    global void execute(SchedulableContext sc) {
        BiweeklyReimCreateForErmi biWeeklyreim = new BiweeklyReimCreateForErmi(); 
        Database.executeBatch(biWeeklyreim, 1);
        
        System.abortJob(sc.getTriggerId());
        
        Datetime workTime = System.now().addDays(7);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()
            			+ ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
        
        System.schedule(JOB_NAME, CRONEXP, new ScheduleBiWeeklyReimCreateForErmi());
    }
}