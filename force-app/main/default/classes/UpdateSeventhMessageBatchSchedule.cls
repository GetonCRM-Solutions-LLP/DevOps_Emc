public class UpdateSeventhMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateSeventhMessageBatch batch = new UpdateSeventhMessageBatch();
        database.executebatch(batch);
    }
}