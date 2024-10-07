/**
 * @File Name          : CustomReportTrigger.trigger
 * @Description        : Custom Report Trigger
 * @Author             : GetOnCRM Solutions LLP
**/
trigger CustomReportTrigger on Custom_Report__c (before insert, before update) {
    if(Trigger.isInsert && Trigger.isBefore || Trigger.isUpdate && Trigger.isBefore){
        CustomReportTriggerHandler.ValidateCustomReoport(Trigger.new);
    }
}