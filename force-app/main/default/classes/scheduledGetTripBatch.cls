global class scheduledGetTripBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      GetTripBatchClass getTripBt = new GetTripBatchClass(); 
      database.executebatch(getTripBt,1);
   }
}