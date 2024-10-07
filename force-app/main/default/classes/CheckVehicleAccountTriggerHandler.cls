/**
 * @File Name          : CheckVehicleAccountTriggerHandler.cls
 * @Description        : Handler class for checkVehicleAccountTrigger
 * @Author             : Minkesh Patel
**/
public with sharing class CheckVehicleAccountTriggerHandler {

    /*
        Method to verify the availablity of vehicle based on vehicle value 
        entered in Account records.
    */
    public static void ValidateVehicle (List<Account> accsList){
        List<String> vehicleNamesset = new List<String>();
        Map<String,String> urlMap = new Map<String,String>();
        for(Account accObj : accsList){
            if(accObj.Vehicle_Types__c != null){
                vehicleNamesset.addAll(accObj.Vehicle_Types__c.replace(' ','').toUpperCase().split(';'));
            }
        }

        for(Vehicle_URL_Mapping__c u : [SELECT Id, 
                                                Year__c, 
                                                Vehicle__c, 
                                                URL__c,
                                                Vehicle_Mapping__c 
                                            FROM Vehicle_URL_Mapping__c 
                                                WHERE Vehicle_Mapping__c In: vehicleNamesset ] ) {

            if(u.URL__c != null && u.URL__c != '')
                urlMap.put(u.Vehicle_Mapping__c, u.URL__c);
        }

        for(Account acc : accsList ){
            if( String.isNotBlank(acc.Vehicle_Types__c) ) {
                List<String> updatedaccList = new List<String>();
                updatedaccList.addAll(acc.Vehicle_Types__c.replace(' ','').toUpperCase().split(';'));
                
                if(!updatedaccList.isEmpty() ){
                    for(String accObj : updatedaccList){
                        if(!urlMap.containsKey(accObj)) {
                            acc.addError('Please Enter Valid Standard Vehicle Make Model and Year');
                        }
                    }
                }
            }
        }
    }
}