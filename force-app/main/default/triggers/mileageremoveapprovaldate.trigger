trigger mileageremoveapprovaldate on Employee_Mileage__c (before insert , before update, after insert, after delete) {
    
    if(Trigger.isbefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            TriggerConfig__c customSetting = TriggerConfig__c.getInstance('Defaulttrigger');
            if(customSetting.mileageremoveapprovaldate__c == true){
                set<Id> reimbursementApprovalStatusSet = new set<Id>();
                for(Employee_Mileage__c empmilege : Trigger.new) {
                    if(empmilege.Trip_Status__c == 'Not Approved Yet'){
                        reimbursementApprovalStatusSet.add(empmilege.EmployeeReimbursement__c);
                    }
                }
                if(reimbursementApprovalStatusSet.size() > 0){
                    MileageTriggerHandler.MileageRemoveApprovalDateHandler(reimbursementApprovalStatusSet);
                }
                
            }
        }
    }
    // EMC - 339
    if(Trigger.isInsert && Trigger.isAfter) {
        system.debug('Insert into after insert trigger.');
        TriggerConfig__c trigConfig = TriggerConfig__c.getInstance('Defaulttrigger');
        if(trigConfig.updateWorkingDays__c == true) {
            MileageTriggerHandler.updateWorkingDays(Trigger.new);
           
            MileageTriggerHandler.WorkingDaysforBiweeklyDrivers(Trigger.new); // EMC-560 28/09/2022 author : paras dhanani
        }
    }
    if(Trigger.isafter && Trigger.isdelete) {
        TriggerConfig__c trigConfig = TriggerConfig__c.getInstance('Defaulttrigger');
        if(trigConfig.updateWorkingDays__c == true && Trigger.old != null) {
            MileageTriggerHandler.updateWorkingDays(Trigger.old); 
            MileageTriggerHandler.WorkingDaysforBiweeklyDrivers(Trigger.old); // EMC-560 28/09/2022 author : paras dhanani
        }
    }
}