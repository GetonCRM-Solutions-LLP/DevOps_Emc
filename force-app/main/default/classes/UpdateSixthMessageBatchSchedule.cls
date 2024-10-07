public class UpdateSixthMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateSixthMessageBatch batch = new UpdateSixthMessageBatch();
        database.executebatch(batch);
    }
}