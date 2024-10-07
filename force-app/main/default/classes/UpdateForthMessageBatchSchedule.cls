public class UpdateForthMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateForthMessageBatch batch = new UpdateForthMessageBatch();
        database.executebatch(batch);
    }
}