global class CreateNewUsermLogBatchSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
      CreateNewUsermLogBatch getTripBt = new CreateNewUsermLogBatch(); 
      database.executebatch(getTripBt,1);
   }
}