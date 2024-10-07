/******************************************************************************************************
 * this trigger is based on Address object 
 ******************************************************************************************************/

 /***************************************************************************************************************************************
 * this trigger instance is after update calling the setLatlongOnAddress class for updateing latitude and longitude on the address object  
 ****************************************************************************************************************************************/
trigger AddressTrigger on Address__c (after Update, after insert) {

    //checkRecursive.getting_SetLatLondAddressFlag() is here if you want to turn off the execution of setlatlongaddress 
    TriggerConfig__c customSetting = TriggerConfig__c.getInstance('Defaulttrigger');
    if(!customSetting.AddressTrigger__c) {
        System.debug('Bypassing trigger due to custom setting');
        return;
    }
    if(Trigger.isUpdate && Trigger.isAfter && checkRecursive.runOnce()  ){

        if(checkRecursive.getting_SetLatLondAddressFlag()){
            for(Address__c currentAddress :Trigger.New){
                System.debug('inside after update for loop');
                if(currentAddress.State__c!=Trigger.oldMap.get(currentAddress.id).State__c || currentAddress.City__c!=Trigger.oldMap.get(currentAddress.id).City__c || currentAddress.ZIP_Code__c!=Trigger.oldMap.get(currentAddress.id).ZIP_Code__c ){
                    System.debug('inside after update if condition');
                    SetLatLongOnAddress.fetchLatLong(currentAddress.City__c,currentAddress.State__c,currentAddress.ZIP_Code__c,currentAddress.Id); 
                }
            }
           
        }
        
    }

    if(Trigger.isAfter && Trigger.isInsert && checkRecursive.runOnce() ){
        
        if(checkRecursive.getting_SetLatLondAddressFlag()){
            for(Address__c currentAddress :Trigger.New){
                if(currentAddress.State__c!=null && currentAddress.City__c!= null && currentAddress.ZIP_Code__c!= null ){
                    SetLatLongOnAddress.fetchLatLong(currentAddress.City__c,currentAddress.State__c,currentAddress.ZIP_Code__c,currentAddress.Id);
                }
            }
        }
        
    }


}