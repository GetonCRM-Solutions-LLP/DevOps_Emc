trigger BiWeekReimTrigger  on Bi_Weekly_Reimbursement__c (after update, after insert,before insert, before update) {
    TriggerConfig__c customSetting = TriggerConfig__c.getInstance('Defaulttrigger');
    public static boolean testflag = true;    
    boolean testflag1=true;
    
    if(Trigger.isAfter && Trigger.isUpdate && (checkRecursive.runOnce() ||(test.isRunningTest() && testflag))) {
        testflag = false;
        //BiWeekEmployeeReimbTriggerHandler.mileagefieldupdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
        BiWeekEmployeeReimbTriggerHandler.updateConfirmFields(Trigger.New, Trigger.oldMap, Trigger.newMap);
        
        Set<Id> ReimIdsLst = new Set<Id>();
        for(Bi_Weekly_Reimbursement__c reimb : Trigger.New){
            ReimIdsLst.add(reimb.ID);
        }
        system.debug('ReimIdsLst==' + ReimIdsLst);
        if(!reimIdsLst.isEmpty()  && customSetting.IRSVehicleCHeck__c == true && !Test.isRunningTest()){
            system.debug('Insert==');
            BiWeekEmployeeReimbTriggerHandler.IRSVehicleCHeck(reimIdsLst);
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert && (checkRecursive.runSecondFlag() || (test.isRunningTest() && testflag1)  )) {
        testflag1 = false;
        Set<Id> ReimIdsLst = new Set<Id>();
        for(Bi_Weekly_Reimbursement__c reimb : Trigger.New){
            ReimIdsLst.add(reimb.ID);
        }
        system.debug('ReimIdsLst==' + ReimIdsLst);
        if(!reimIdsLst.isEmpty()  && customSetting.IRSVehicleCHeck__c == true && !Test.isRunningTest()){
            BiWeekEmployeeReimbTriggerHandler.IRSVehicleCHeck(reimIdsLst);
        }
    }
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate){
            
            if((customSetting !=null) && customSetting.BiWeeklyReimbursementTrigger__c == true)
            {
                BiWeekEmployeeReimbTriggerHandler.updateCountErrorHoursField(Trigger.New);
            }     
        }
        if(Trigger.isInsert || Trigger.isUpdate){
            if(customSetting.Mileage_Lock_date_on_Reimbursement__c == true) {
                // BiWeekEmployeeReimbTriggerHandler.checkStartAndEndDate(Trigger.New);
            }
        }
    }
}