public class reimbursementRevertMonthDetailsBatch implements Database.Batchable<sObject>{
    public List<String> months;
    // public Boolean savePrevMonth;

    public reimbursementRevertMonthDetailsBatch(List<String> monthsLst) {
        months = monthsLst;
    }

    public static String lblValue = system.Label.TripstobeLogged;
    public static List<String> lstLblValue = lblValue.split(',');

    public List<Employee_Reimbursement__c> start(Database.BatchableContext bc){
        List<General_Query__mdt> metaValue = [SELECT id,Test_Query__c,savePrevMonthVal__c,revertReimVal__c FROM General_Query__mdt];
        List<Employee_Reimbursement__c> reimList = Database.query(metaValue[0].revertReimVal__c);

        return reimList;
    }

    public void execute(Database.BatchableContext bc, List<Employee_Reimbursement__c> reimList) {
        List<Employee_Reimbursement__c> reimListToUpdate = new List<Employee_Reimbursement__c>();
        System.debug('reimList: '+reimList);
        System.debug('reimList size: '+reimList.size());

        // Run for revert approve date and status value on original fields

        // if(savePrevMonth == true){
            
            // Here We Add Dynamic Query from General_Query__mdt metadata and query value store in revertReimVal__c field
            // for(Employee_Reimbursement__c reimList : [Select id,Name,Month__c,Status__c,Prev_Approved_Date_Value__c,Prev_Status_Value__c, Approved_Date__c,Mileage_Lock_Date__c,Contact_Id__r.Account.isUsingTriplog__c  from Employee_Reimbursement__c where Month__c IN: months and Contact_Id__r.Account.isUsingTriplog__c = true and Contact_Id__r.Account.Name IN : lstLblValue and (Status__c = 'Approved' OR Mileage_Lock_Date__c != null)]){
            for(Employee_Reimbursement__c reims : reimList){
                // System.debug('reimList: '+reimList);
                
                reims.Approved_Date__c = reims.Prev_Approved_Date_Value__c;
                reims.Status__c = reims.Prev_Status_Value__c;
                reims.Prev_Approved_Date_Value__c = null;
                reims.Prev_Status_Value__c = null;
                reimListToUpdate.add(reims);
            }
            if(!reimListToUpdate.isEmpty()){
                update reimListToUpdate;
            } 
        // }
    }
    public void finish(Database.BatchableContext bc){}
}