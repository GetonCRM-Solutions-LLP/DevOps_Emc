global class CreateReimbursementSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        CreateReimbursement reimbursementtobecreated = new CreateReimbursement(); 
        Database.executeBatch(reimbursementtobecreated, 1);
    }
}