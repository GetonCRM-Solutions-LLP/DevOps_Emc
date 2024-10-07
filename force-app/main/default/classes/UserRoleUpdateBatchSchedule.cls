global class UserRoleUpdateBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        UserRoleUpdateBatch userBatch = new UserRoleUpdateBatch();
        database.executebatch(userBatch, 200);
    }
}