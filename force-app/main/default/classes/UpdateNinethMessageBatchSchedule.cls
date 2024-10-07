public class UpdateNinethMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateNinethMessageBatch batch = new UpdateNinethMessageBatch();
        database.executebatch(batch);
    }
}