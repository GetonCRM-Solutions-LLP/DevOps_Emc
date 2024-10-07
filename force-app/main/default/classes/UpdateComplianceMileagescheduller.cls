public with sharing class UpdateComplianceMileagescheduller implements Schedulable{
    public UpdateComplianceMileagescheduller() {}
    public static final String JOB_NAME = 'Compliance Mileage update on every 1st january';
    
    public void execute(SchedulableContext sc) {
        UpdateCompliancemileageBatch updateComplianceMil = new UpdateCompliancemileageBatch(); 
        Database.executeBatch(updateComplianceMil, 1);
        
        System.abortJob(sc.getTriggerId());
        String CRONEXP = '0 0 0 1 1 ?';
        System.schedule(JOB_NAME, CRONEXP, new UpdateComplianceMileagescheduller());
    }
}