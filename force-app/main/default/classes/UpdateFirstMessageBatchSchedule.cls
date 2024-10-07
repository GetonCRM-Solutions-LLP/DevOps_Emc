public class UpdateFirstMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateFirstMessageBatch batch = new UpdateFirstMessageBatch();
        database.executebatch(batch);
    }
}