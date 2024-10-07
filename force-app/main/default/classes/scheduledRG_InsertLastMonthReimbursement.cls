global class scheduledRG_InsertLastMonthReimbursement implements Schedulable{
    global void execute(SchedulableContext sc) {

        String monthYear = date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        RG_InsertLastMonthReimbursement reimbursementtobecreated = new RG_InsertLastMonthReimbursement(monthYear); 
        Database.executeBatch(reimbursementtobecreated, 200);
   }
}