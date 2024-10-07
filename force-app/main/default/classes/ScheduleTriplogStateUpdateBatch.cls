global class ScheduleTriplogStateUpdateBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        TriplogStateUpdateBatch objbatch = new TriplogStateUpdateBatch();
        Database.executeBatch(objbatch,200);
    }
  }