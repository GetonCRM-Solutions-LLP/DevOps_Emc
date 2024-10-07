global class DeActivatedUserScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		DeActivatedUserBatch deActive = new DeActivatedUserBatch();
		Database.executebatch(deActive,1);
	}
}