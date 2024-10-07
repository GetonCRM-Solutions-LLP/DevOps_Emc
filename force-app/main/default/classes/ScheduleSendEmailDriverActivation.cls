global class ScheduleSendEmailDriverActivation implements Schedulable {
    global void execute(SchedulableContext sc) { 
        SendActivaitonEmailToDriver sendBatch = new SendActivaitonEmailToDriver();       
        database.executebatch(sendBatch,1);
     }
}