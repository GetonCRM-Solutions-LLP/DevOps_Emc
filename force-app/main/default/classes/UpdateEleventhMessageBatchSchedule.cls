public class UpdateEleventhMessageBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateEleventhMessageBatch batch = new UpdateEleventhMessageBatch();
        database.executebatch(batch);
    }
}