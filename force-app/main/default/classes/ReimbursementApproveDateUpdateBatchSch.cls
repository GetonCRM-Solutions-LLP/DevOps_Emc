global class ReimbursementApproveDateUpdateBatchSch implements Schedulable {
    global void execute(SchedulableContext sc) {
        ReimbursementApproveDateUpdateBatch objbatch = new ReimbursementApproveDateUpdateBatch();
        Database.executeBatch(objbatch,1);
    }
}