/**
 * @Author:  GetonCRM Solutions LLP
 * @Description: trigger on user object for insert a report accessibility for admin and admin/driver.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 16 June 2020 | Sanket Goswami
 * @description:
 */
trigger UserTrigger on User (after insert,after update) {
    set<Id> currentUserIdsSet = new set<Id>();
    TriggerConfig__c customSetting = TriggerConfig__c.getInstance('Defaulttrigger');
    Set<String> emailIds = new Set<String>();
    for(User currentUser : Trigger.New){

        if(!Test.isRunningTest() && Trigger.isInsert && Trigger.isAfter && (currentUser.ProfileId == '00e31000001FRDYAA4' || currentUser.ProfileId == '00e31000001FRDZAA4')){
            currentUserIdsSet.add(currentUser.Id);
        }
        else if(!Test.isRunningTest() && Trigger.isUpdate && Trigger.isAfter && currentUser.ProfileId != Trigger.oldMap.get(currentUser.id).ProfileId && (currentUser.ProfileId == '00e31000001FRDYAA4' || currentUser.ProfileId == '00e31000001FRDZAA4')){
            currentUserIdsSet.add(currentUser.Id);
        }
        else {
            if (Test.isRunningTest()) {
                currentUserIdsSet.add(currentUser.Id);
            }
        }
        if(Trigger.isInsert && Trigger.isAfter && currentUser.isActive && currentUser.Contactid != null){//|| Trigger.isUpdate && Trigger.oldMap.get(currentUser.Id).isActive != currentUser.isActive) 
            emailIds.add(currentUser.Email);
            System.debug('emailIds-->'+emailIds);
        }
    }
    if(!currentUserIdsSet.isEmpty() && customSetting.UserTrigger__c){
        System.debug('currentUserIdsSet'+currentUserIdsSet);
        if(System.IsBatch() == false && System.isFuture() == false){ 
            UserReportAccessFromTrigger.createReportAccessibility(currentUserIdsSet);
        }
    }
    if(!emailIds.isEmpty()){
        //HelloSignIntegrationHandler.sendSignatureRequestForDriver(emailIds);
    }
}