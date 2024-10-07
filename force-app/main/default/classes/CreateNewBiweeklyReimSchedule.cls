/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This Batch run after every 14 days for ermi account and those account id pass from custom label
 * @Modification logs
 * ========================================================================================================================
 * @Date: 27 Octomber 2022 | Niraj Sahedani
 * @description: 
 */
global class CreateNewBiweeklyReimSchedule implements Schedulable {
    public static final String JOB_NAME = 'BiWeekly PayPeriod Created for Contact based on Account PayPeriod';
    
    global void execute(SchedulableContext sc) {
        String AccId = System.Label.Create_New_BiWeekly_Reim;
        CreateBiweeklyReim biWeeklyreimbursement = new CreateBiweeklyReim(AccId); 
        Database.executeBatch(biWeeklyreimbursement, 1);
        
        System.abortJob(sc.getTriggerId());

        Datetime workTime = System.now().addDays(14);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()
                + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();

        System.schedule(JOB_NAME, CRONEXP, new CreateNewBiweeklyReimSchedule());
    }
}