global class scheduledMileageNotificationForDrivers implements Schedulable {
   global void execute(SchedulableContext sc) { 
      MileageNotificationForDrivers sendBatch = new MileageNotificationForDrivers();       
      database.executebatch(sendBatch,1);
   }
}