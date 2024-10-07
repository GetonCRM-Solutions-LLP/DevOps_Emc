public class UpdateThirdMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateThirdMessageBatch batch = new UpdateThirdMessageBatch();
        database.executebatch(batch);
    }
}