public class UpdateFifthMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateFifthMessageBatch batch = new UpdateFifthMessageBatch();
        database.executebatch(batch);
    }
}