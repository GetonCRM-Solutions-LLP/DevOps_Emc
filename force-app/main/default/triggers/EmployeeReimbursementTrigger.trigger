trigger EmployeeReimbursementTrigger on Employee_Reimbursement__c (after update, after insert,before insert) {
    SendEmail__c sendCustomSet = SendEmail__c.getValues('EmployeeReimbursementTrigger');
    TriggerConfig__c triggerCustomSetting = TriggerConfig__c.getValues('Defaulttrigger');
    if(Trigger.isUpdate && (checkRecursive.runOnce() || Test.isRunningTest())) {       
        if(sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true){
            //EmployeeReimbursementTriggerHandler.mileagefieldupdate(Trigger.New, Trigger.oldMap, Trigger.newMap);        
        }        
        //AI-000436 start
        Map<Id,Employee_Reimbursement__c> sendMailReimbursMap = new Map<Id,Employee_Reimbursement__c>();
        Set<Id> reimIdsLst = new Set<Id>();
        for(Employee_Reimbursement__c reimb:Trigger.New){
            reimIdsLst.add(reimb.ID);
            if(reimb.Status__c != Trigger.oldMap.get(reimb.Id).Status__c && reimb.Status__c == 'Approved'){
                sendMailReimbursMap.put(reimb.Id,reimb);
            }
        }        
        if(sendMailReimbursMap.size() > 0 && sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true){
            EmployeeReimbursementTriggerHandler.updateStatusMail(sendMailReimbursMap);
        }
        if(!reimIdsLst.isEmpty() && triggerCustomSetting.IRSVehicleCHeck__c != null && triggerCustomSetting.IRSVehicleCHeck__c == true && !Test.isRunningTest()){
            // EMC - 271
            // Whenever Reimbursement is created or updated at that time this is check the value of Contct's Vehicle types 
            // if vehicle type is 'IRS Mileage Rate' than the mpg and fuel price is set to 0 for the reimbursement and 
            // Maintanace and tires are set as the IRS Mileage Rate of that year which is in IRS Mileage rate.
            EmployeeReimbursementTriggerHandler.IRSVehicleCHeck(reimIdsLst);
        }

    }

    if(Trigger.isInsert && Trigger.isAfter && sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true){
        Map<Id,Employee_Reimbursement__c>  sendMailEmpReimbursMap = new  Map<Id,Employee_Reimbursement__c>();
        Set<Id> reimIds = new Set<Id>();
        for(Employee_Reimbursement__c reimb : Trigger.New){
            reimIds.add(reimb.ID);
            if(reimb.Status__c == 'Approved'){
                sendMailEmpReimbursMap.put(reimb.Id,reimb);
            }
        }
        if(sendMailEmpReimbursMap.size() > 0){
            EmployeeReimbursementTriggerHandler.updateStatusMail(sendMailEmpReimbursMap);
        }
        if(!reimIds.isEmpty() && triggerCustomSetting.IRSVehicleCHeck__c != null && triggerCustomSetting.IRSVehicleCHeck__c == true) {
           //EMC - 271
           EmployeeReimbursementTriggerHandler.IRSVehicleCHeck(reimIds);
        }
    } //AI-000436 end    
    //AI-000459 Start
    //If contact is deactivated then no user can manually create a reimbursement record for that contact.
    if(Trigger.isInsert && Trigger.isBefore) {
        EmployeeReimbursementTriggerHandler.checkDeactivatedContact(Trigger.New);
    }
    // @Date : 20/05/2024 || Vatsal Bhalani
    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('Inside message Update trigger Logic');
        EmployeeReimbursementTriggerHandler.updateFifthMessage(Trigger.oldMap, Trigger.newMap);
        EmployeeReimbursementTriggerHandler.updateSixthSeventhMessage(Trigger.oldMap, Trigger.newMap);
            //EmployeeReimbursementTriggerHandler.updateSeventhMessage(Trigger.oldMap, Trigger.newMap);
    }
}