/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Schedule class for run a Batch class on every day.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 14 May 2020
 */
global class ScheduleTriplogAppVersionUpdateBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        TriplogAppVersionUpdateBatch objbatch = new TriplogAppVersionUpdateBatch();
        Database.executeBatch(objbatch,1);
    }
}