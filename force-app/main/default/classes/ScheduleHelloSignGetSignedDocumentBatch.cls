global class ScheduleHelloSignGetSignedDocumentBatch implements Schedulable  {
    public static final String JOB_NAME = 'HelloSign Document Batch';
    
    global void execute(SchedulableContext sc) {
        HelloSignGetSignedDocumentBatch helloSign = new HelloSignGetSignedDocumentBatch(); 
        database.executebatch(helloSign,1);
        System.abortJob(sc.getTriggerId());
        
        String CRONEXP = '0 59 * * * ?';
          
    System.schedule(JOB_NAME, CRONEXP, new ScheduleHelloSignGetSignedDocumentBatch() );
    }
}