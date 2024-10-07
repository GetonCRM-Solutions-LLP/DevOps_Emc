global class ScheduledReimbursementStatementBatch implements Schedulable {
  global void execute(SchedulableContext sc) {
    ReimbursementStatementBatch objbatch = new ReimbursementStatementBatch();
    Database.executeBatch(objbatch,1);
  }
}