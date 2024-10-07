/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This schedule class is use for update Mileage Lock Date field of report accessibility object and update Trip status lock date of account object
 * This class is schedule on 1st date of every month.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 23 December 2021 | Paras Dhanani
 * @description: 
 */
global class MileageLockDateUpdateController Implements Schedulable {
        global void execute(SchedulableContext sc) {
            updateLockdate();
        }
        public void updateLockdate() {
            List<Report_Accessibility__c> listreportacc = new List<Report_Accessibility__c>();    
            for(Report_Accessibility__c rptacc : [select id,name,Mileage_Lock_Date__c from Report_Accessibility__c where Mileage_Lock_Date__c != null]) {
                rptacc.Mileage_Lock_Date__c = null;
                listreportacc.add(rptacc);
            }
            if(listreportacc.size() > 0 ) {
               update listreportacc; 
            }
            
            List<Account> accList = new List<Account>();
            for(Account acc : [select id,name,Trip_Status_Lock__c from Account where Trip_Status_Lock__c != null ]) {
                acc.Trip_Status_Lock__c = null;
            }
            if(accList.size() >0) {
               update accList;  
            }
        }
    }