global class scheduledMileageSubmissionBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
      MileageSubmissionInstructions sendMileageInstruction = new MileageSubmissionInstructions(); 
      database.executebatch(sendMileageInstruction,1);
   }
}