global class scheduledIntMntBatch implements Schedulable {
   global void execute(SchedulableContext sc) { 
      RG_InsertLastMonthReimbursement insMntBt = new RG_InsertLastMonthReimbursement();       
      database.executebatch(insMntBt,1);
   }
}