public class UpdateTenthMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateTenthMessageBatch batch = new UpdateTenthMessageBatch();
        database.executebatch(batch);
    }
}