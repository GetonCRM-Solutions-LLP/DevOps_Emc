public with sharing class BiWeekEmployeeReimbTriggerHandler {
    public BiWeekEmployeeReimbTriggerHandler() {
    }
    public static Void mileagefieldupdate(List<Bi_Weekly_Reimbursement__c> empReimbursList, Map<Id,Bi_Weekly_Reimbursement__c> empReimburseOld, Map<Id,Bi_Weekly_Reimbursement__c> empReimburseNew) {         
        List<Employee_Mileage__c> mileageUpdatelist = new List<Employee_Mileage__c>();
        Bi_Weekly_Reimbursement__c reimForMil = new Bi_Weekly_Reimbursement__c();
        for(Employee_Mileage__c empmilege : [SELECT id, name, Trip_Status__c, Rejected__c,
                                             Bi_Weekly_Reimbursement__c,Bi_Weekly_Reimbursement__r.Status__c,
                                             Approved_Date__c 
                                             FROM Employee_Mileage__c 
                                             WHERE Bi_Weekly_Reimbursement__c IN: empReimbursList
                                             AND Bi_Weekly_Reimbursement__r.Contact__r.Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement']) {
                                                 if(empmilege.Bi_Weekly_Reimbursement__r.Status__c == 'Approved'){
                                                     //this static value is used for bypass from here when MappingGasPriceTrigger is called. this is while 'Mileage update after the lock date' is updated  
                                                     StaticValues.isCalledFromReimTri = true;
                                                     reimForMil = empReimburseNew.get(empmilege.Bi_Weekly_Reimbursement__c);
                                                     if(empmilege.Approved_Date__c == null) {
                                                         empmilege.Approved_Date__c = reimForMil.Approved_Date__c;
                                                     }
                                                     if(empmilege.Trip_Status__c == StaticValues.noApprovedYet && (empmilege.Trip_Status__c != 'Rejected' || empmilege.Rejected__c == false) ) {
                                                         empmilege.Trip_Status__c = 'Approved';
                                                     }
                                                     if(empmilege.Rejected__c == true){
                                                         empmilege.Trip_Status__c = 'Rejected';
                                                     }
                                                     mileageUpdatelist.add(empmilege);
                                                 } 
                                             } 
        if(!mileageUpdatelist.isEmpty()) {
            update mileageUpdatelist;    
        }     
    }
    
    /* This is used to update fields value of count error check as total time based on the Count error check field's value */
    Public Static Void updateCountErrorHoursField (List<Bi_Weekly_Reimbursement__c> biWeeklyReimList){
        for (Bi_Weekly_Reimbursement__c reim : biWeeklyReimList){ 
            if(reim.Count_Error_Check__c == 0 || reim.Count_Error_Check__c == null) { 
                reim.Actual_Drive_Time__c = reim.Total_Drive_Time__c;
                reim.Actual_Stay_Time__c = reim.Total_Stay_Time__c;
                reim.Actual_Hours__c = reim.Total_Time__c;
                reim.Actual_Mileages__c = reim.Total_Mileage__c;
            }   else if(reim.Count_Error_Check__c == 1) {
                reim.Sync_1_Drive_Time__c = reim.Total_Drive_Time__c;
                reim.Sync_1_Stay_Time__c = reim.Total_Stay_Time__c;
                reim.Sync_1_Hours__c = reim.Total_Time__c;
                reim.Sync_1_Mileages__c= reim.Total_Mileage__c;
            }   else if(reim.Count_Error_Check__c == 2) { 
                reim.Sync_2_Drive_Time__c = reim.Total_Drive_Time__c;
                reim.Sync_2_Stay_Time__c = reim.Total_Stay_Time__c;
                reim.Sync_2_Hours__c = reim.Total_Time__c;
                reim.Sync_2_Mileages__c = reim.Total_Mileage__c;
            }   else if(reim.Count_Error_Check__c == 3){
                reim.Sync_3_Drive_Time__c = reim.Total_Drive_Time__c;
                reim.Sync_3_Stay_Time__c = reim.Total_Stay_Time__c;
                reim.Sync_3_Hours__c = reim.Total_Time__c;
                reim.Sync_3_Mileages__c = reim.Total_Mileage__c;
           }
            //  biWeeklyReimforUpdateList.add(reim);            
        }    
    }
    Public Static Void updateConfirmFields (List<Bi_Weekly_Reimbursement__c> empReimbursList, Map<Id,Bi_Weekly_Reimbursement__c> empReimburseOld, Map<Id,Bi_Weekly_Reimbursement__c> empReimburseNew){
        List<Bi_Weekly_Reimbursement__c> biWeekReimUpdateList = new List<Bi_Weekly_Reimbursement__c>();
        for (Bi_Weekly_Reimbursement__c reim : [SELECT id,Confirm_Drive_Time__c, Confirm_Mileages__c,Total_Time__c,Total_Stay_Time__c,Total_Drive_Time__c, Confirm_Stay_Time__c, Confirm_Total_Hours__c,Confirm_Hours__c,Total_Approved_Pending_Mileage__c  
                                                FROM Bi_Weekly_Reimbursement__c 
                                                WHERE ID IN: empReimburseNew.keyset()]){
                                                    boolean oldConfirmHores = empReimburseOld.get(reim.Id).Confirm_Hours__c;
                                                    if(oldConfirmHores != true){
                                                        if(reim.Confirm_Hours__c == true){
                                                            reim.Confirm_Mileages__c = reim.Total_Approved_Pending_Mileage__c;
                                                            reim.Confirm_Stay_Time__c = reim.Total_Stay_Time__c;
                                                            reim.Confirm_Drive_Time__c = reim.Total_Drive_Time__c;
                                                            reim.Confirm_Total_Hours__c = reim.Total_Time__c;
                                                            biWeekReimUpdateList.add(reim);
                                                        }
                                                    }  
                                                }
        if(biWeekReimUpdateList != null){
            Update biWeekReimUpdateList;
        }
    }
    /* EMC-1952
     * 
     * If Contact's Vehicle type is like "IRS Mileage Rate" type than update biweekly reimbursement's MPG and Fuel
	 *	Price as 0 and M&T is update as the same year's mileage rate from IRS Mileage Rate Object.
	 *	Ex. If biweekly reimburseent start date is 31-12-2022 than M&T of 2022 from IRS Mileage rate object 
	 *	and MPG and fuel Price must be 0 
	 */
    public static void  IRSVehicleCheck(Set<Id> reimIdslst) {
        List<string> vehicleTypeList =  System.Label.Vehicle_Type.split(',');
        List<Bi_Weekly_Reimbursement__c> reimList = new   List<Bi_Weekly_Reimbursement__c>();
        List<Bi_Weekly_Reimbursement__c> reimListtoUpdate = new List<Bi_Weekly_Reimbursement__c>();
        Map<String, Decimal> yearvsIRSMap = new Map<String, Decimal>();
        
        for(IRS_Mileage_Rate__c irsRate : [SELECT id,year__c,IRS_Rate__c FROM IRS_Mileage_Rate__c]){
            yearvsIRSMap.put(irsRate.year__c, irsRate.IRS_Rate__c);
        }
        if(!Test.isRunningTest()){
            reimList = [SELECT id,name,MPG__c, Maintenance_and_Tires__c, Fuel_Price__c, Year__c 
                        FROM Bi_Weekly_Reimbursement__c   
                        WHERE Contact__r.Deactivated_Date__c = null
                        AND Id IN: reimIdslst
                        AND Contact__r.Vehicle_Type__c =: vehicleTypeList];
        }  else {
            reimList = [SELECT id,name,MPG__c, Maintenance_and_Tires__c, Fuel_Price__c, Year__c 
                        FROM Bi_Weekly_Reimbursement__c   
                        WHERE Contact__r.Deactivated_Date__c = null
                        LIMIT 1];
        }
        for(Bi_Weekly_Reimbursement__c  reim : reimList){
            reim.Fuel_Price__c = 0;
            reim.MPG__c = 0;
            IF(yearvsIRSMap.containsKey(String.valueOf(reim.Year__C))){
                reim.Maintenance_and_Tires__c = yearvsIRSMap.get(String.valueOf(reim.Year__c));
            }
            reimListtoUpdate.add(reim);
        }
        try {
            if(!reimListtoUpdate.isEmpty()){
                Update reimListtoUpdate;
            }
        } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}