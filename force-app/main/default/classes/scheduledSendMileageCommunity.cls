global class scheduledSendMileageCommunity implements Schedulable {
   global void execute(SchedulableContext sc) { 
      SendMonthlyMileageReminder sendBatch = new SendMonthlyMileageReminder();       
      database.executebatch(sendBatch,1);
   }
}