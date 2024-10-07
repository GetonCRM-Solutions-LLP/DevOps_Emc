global class scheduledSendMileageDelta implements Schedulable {
   global void execute(SchedulableContext sc) { 
      SendMileageReminderforDelta sendBatch = new SendMileageReminderforDelta();       
      database.executebatch(sendBatch,1);
   }
}