/**
* @File Name          : CheckVehicleAccountTrigger.trigger
* @Description        : Verify the availablity of vehicle based on vehicle value entered in Account records.
* @Author             : Minkesh Patel
**/
trigger CheckVehicleAccountTrigger on Account(before insert,before update) {
    if(Trigger.isInsert && Trigger.isBefore || Trigger.isUpdate && Trigger.isBefore) {
        CheckVehicleAccountTriggerHandler.ValidateVehicle(Trigger.new);
        
    }

////////////////////////////////////////////////////////////////////////////////////////////////
//	Jira Ticket 		: EMC-06															  //
//	@Description        : Replace previous Year vehicle when updating the new year vehicle in //
//						  Vehicle_Types__c(multiselect Picklist) of account object			  //
//	@Author             : Paras Dhanani	   													  //
//																							  //
////////////////////////////////////////////////////////////////////////////////////////////////
    
    if(Trigger.isUpdate || Trigger.isInsert){ 
        for(Account acc : trigger.new) {
            if(acc.Vehicle_Types__c != null ) {
                Integer Year;
                String name,Vehicalvalue;
                set<string> newlstVehicleType = new set<string>();
                if(acc.Vehicle_Types__c.contains(';')){
                    newlstVehicleType.addAll(acc.Vehicle_Types__c.split(';'));
                } else {
                    newlstVehicleType.add(acc.Vehicle_Types__c);
                }
                List<String> setvehicalTypeString = new List<String>();
                Map<String, Integer> mapOFNameVsYear  = new Map<String, Integer>();
                for(String obj : newlstVehicleType){   
                    Year = Integer.valueOf(obj.substring(0, 4));
                    name = obj.substringAfter(' ');
                    if(mapOFNameVsYear.containsKey(name)){
                        if(mapOFNameVsYear.get(name) < Year){         
                            Year = Year;
                            mapOFNameVsYear.put(name, Year); 
                        }
                    } else {
                        mapOFNameVsYear.put(name, Year); 
                    }  
                }
                for(String obj : mapOFNameVsYear.keySet()){  
                    Vehicalvalue = String.valueof(mapOFNameVsYear.get(obj)) + ' ' + obj;
                    setvehicalTypeString.add(Vehicalvalue);   
                }
                acc.Vehicle_Types__c = String.join(setvehicalTypeString,';');   
            }
        }
    }
}