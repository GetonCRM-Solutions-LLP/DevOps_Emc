public class UpdateEighthMessageBatchSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        UpdateEighthMessageBatch batch = new UpdateEighthMessageBatch();
        database.executebatch(batch);
    }
}