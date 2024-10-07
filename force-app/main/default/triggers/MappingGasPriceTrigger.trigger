Trigger MappingGasPriceTrigger on Employee_Mileage__c (before insert, before update, after insert,after update) {
    
    TriggerConfig__c customSetting = TriggerConfig__c.getInstance('Defaulttrigger');
    
    if( Trigger.isInsert && Trigger.isBefore && customSetting.MappingGasPriceTrigger__c )
    {
        Set<String> reimIds = new Set<String>();
        Set<String> reimbursementIds = new Set<String>();
        Map<String,Decimal> reimbursementWiseFuelMap = new Map<String,Decimal>();
        Map<String,Decimal> gasPriceFuelMap = new Map<String,Decimal>();
        Map<String,String> reimbursementWiseMonthMap = new Map<String,String>();
        Map<String,String> reimWiseStateCityMap = new Map<String,String>();
        for(Employee_Mileage__c mil : Trigger.New)
        { 
           
            reimIds.add(mil.EmployeeReimbursement__c);                    
        }
        
        if(!reimIds.isEmpty()) {
            for(Employee_Reimbursement__c reim : [SELECT Id, Month__c, Fuel_Price__c, Contact_Id__r.MailingState, Contact_Id__r.MailingCity, Contact_Id__r.Vehicle_Type__c, Contact_Id__r.AccountId  FROM Employee_Reimbursement__c  WHERE Id In: reimIds]) {
                if( reim.Month__c.contains('-')  && ( String.isNotBlank(reim.Contact_Id__r.MailingCity) || String.isNotBlank(reim.Contact_Id__r.MailingState) ) ) 
                {
                    reimWiseStateCityMap.put( reim.id, reim.Contact_Id__r.MailingCity + '' + reim.Contact_Id__r.MailingState.toUpperCase() );    
                }
                if(reim.Fuel_Price__c != null && reim.Fuel_Price__c > 0 )
                    reimbursementWiseFuelMap.put(reim.id, reim.Fuel_Price__c);
                
                if(String.isNotBlank(reim.Month__c))
                    reimbursementWiseMonthMap.put(reim.Id, reim.Month__c );
                
                if(System.label.FuelPriceAccId.contains(reim.Contact_Id__r.AccountId) || (reim.Contact_Id__r.Vehicle_Type__c != null && reim.Contact_Id__r.Vehicle_Type__c.contains('Mileage Rate'))){
                    reimbursementIds.add(reim.Id);
                }
            }
            
            Set<String> cityStateDate = new Set<String>();
            for(Employee_Mileage__c mil : Trigger.New) {
                if( mil.Trip_Date__c != null ) {
                    String month = ( mil.Trip_Date__c.month() < 10 ? '0' : '') + mil.Trip_Date__c.month() + '-' + mil.Trip_Date__c.Year();
                    
                    if( reimbursementWiseMonthMap.containsKey(mil.EmployeeReimbursement__c)  && ( month == reimbursementWiseMonthMap.get(mil.EmployeeReimbursement__c))  && reimbursementWiseFuelMap.containsKey(mil.EmployeeReimbursement__c))
                    {
                        mil.Fuel_Price__c = reimbursementWiseFuelMap.get(mil.EmployeeReimbursement__c);
                    }
                    else if(reimWiseStateCityMap.containsKey(mil.EmployeeReimbursement__c) )
                    {
                        String stateCity = reimWiseStateCityMap.get(mil.EmployeeReimbursement__c);
                        stateCity += mil.Trip_Date__c.Month() + '' + mil.Trip_Date__c.Year();
                        cityStateDate.add(stateCity);
                    }
                }
                if(!reimbursementIds.isEmpty() && reimbursementIds.contains(mil.EmployeeReimbursement__c)){
                    mil.Fuel_Price__c = 0;
                    mil.MPG__c = 0;
                }
            }
            if(!cityStateDate.isEmpty())
            {
                for(Gas_Prices__c gs : [Select Id, Fuel_Price__c, Month_State_City__c  FROM Gas_Prices__c  WHERE Month_State_City__c IN: cityStateDate])
                {
                    gasPriceFuelMap.put( gs.Month_State_City__c, gs.Fuel_Price__c);
                }
                
                if(!gasPriceFuelMap.isEmpty()) {
                    for(Employee_Mileage__c mil : Trigger.New) {
                        if( mil.Trip_Date__c != null && reimWiseStateCityMap.containsKey(mil.EmployeeReimbursement__c)) {
                            String statecity = reimWiseStateCityMap.get(mil.EmployeeReimbursement__c);
                            statecity += mil.Trip_Date__c.Month() + '' + mil.Trip_Date__c.Year();
                            if( gasPriceFuelMap.containsKey(statecity) ) {
                                mil.Fuel_Price__c = gasPriceFuelMap.get(statecity);
                            }
                        }
                        if(!reimbursementIds.isEmpty() && reimbursementIds.contains(mil.EmployeeReimbursement__c)){
                            mil.Fuel_Price__c = 0;
                            mil.MPG__c = 0;
                        }
                    }
                }
            }
        }
        
    }
    if(customSetting.MappingGasPriceTriggerUpdateConvertedDat__c){
        if(Trigger.isInsert && Trigger.isBefore) {
            MappingGasPriceTriggerHelper.updateConvertedDates(Trigger.new);
        }
        else if(Trigger.isBefore && Trigger.isUpdate){
            List<Employee_Mileage__c> updateMileagesList = new List<Employee_Mileage__c>();
            for(Employee_Mileage__c mil : Trigger.New)
            {
                if(mil.TimeZone__c != Trigger.oldMap.get(mil.id).TimeZone__c  || mil.StartTime__c != Trigger.oldMap.get(mil.id).StartTime__c  || mil.EndTime__c != Trigger.oldMap.get(mil.id).EndTime__c || mil.Trip_Date__c != Trigger.oldMap.get(mil.id).Trip_Date__c )
                {
                    updateMileagesList.add(mil);
                }
                 if(mil.Stay_Time__c != 0 && (mil.Tag__c == 'Admin' || mil.Tag__c == 'admin')){
                    mil.Stay_Time__c = 0;
                }
                if(mil.Stay_Time__c != 0 && mil.Origin_Name__c != null && mil.Destination_Name__c != null && ((mil.Origin_Name__c).toUppercase() == 'HOME' && (mil.Destination_Name__c).toUppercase() == 'HOME' )){
                    mil.Stay_Time__c = 0;
                }
                if(customSetting.MapTriAppReje__c){
                    if( (mil.EMP_Mileage__c == Trigger.oldMap.get(mil.id).EMP_Mileage__c) && (mil.Name.contains('EMP')) && (Trigger.oldMap.get(mil.id).Trip_Status__c == 'Not Approved Yet') && (mil.Trip_Status__c == 'Approved')) {
                        mil.Mileage_Difference__c = 0;
                    } 
                    else if((Trigger.oldMap.get(mil.id).Trip_Status__c == 'Approved') && (mil.Trip_Status__c == 'Rejected')) {
                        mil.Trip_Status__c = mil.Trip_Status__c;
                        if((mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c == null) || (mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c != null)){
                            mil.Approved_Date__c = mil.Approved_Date__c;
                        }
                    }
                    else if((Trigger.oldMap.get(mil.id).Trip_Status__c == 'Rejected') && (mil.Trip_Status__c == 'Approved')) {
                        mil.Trip_Status__c = mil.Trip_Status__c;
                        if((mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c == null) || (mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c != null)){
                            mil.Approved_Date__c = mil.Approved_Date__c;
                        }
                    }
                    else if( (mil.EMP_Mileage__c == Trigger.oldMap.get(mil.id).EMP_Mileage__c) && (mil.Name.contains('EMP')) && (Trigger.oldMap.get(mil.id).Trip_Status__c == 'Approved')) {
                        mil.Mileage_Difference__c = 0;                        
                        mil.Trip_Status__c = Trigger.oldMap.get(mil.id).Trip_Status__c;
                        if((mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c == null) || (mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c != null)){
                            mil.Approved_Date__c = mil.Approved_Date__c;
                        } else if (Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = System.today();
                        } else {
                            mil.Approved_Date__c = Trigger.oldMap.get(mil.Id).Approved_Date__c;
                        }                       
                    }
                    else if( (mil.EMP_Mileage__c != Trigger.oldMap.get(mil.id).EMP_Mileage__c) && (mil.Name.contains('EMP')) && (Trigger.oldMap.get(mil.id).Trip_Status__c == 'Approved')){
                       if(Trigger.oldMap.get(mil.id).EMP_Mileage__c != null){
                            mil.Mileage_Difference__c = mil.EMP_Mileage__c - Trigger.oldMap.get(mil.id).EMP_Mileage__c;
                       }                       
                        mil.Trip_Status__c = Trigger.oldMap.get(mil.id).Trip_Status__c;
                        if(mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = mil.Approved_Date__c;
                        } else if (Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = System.today();
                        } else {
                            mil.Approved_Date__c = Trigger.oldMap.get(mil.Id).Approved_Date__c;
                        }                        
                    }
                    else if( (mil.EMP_Mileage__c == Trigger.oldMap.get(mil.id).EMP_Mileage__c) && (mil.Name.contains('EMP')) && (Trigger.oldMap.get(mil.id).Trip_Status__c == 'Rejected')) {
                        mil.Mileage_Difference__c = 0;
                        
                        mil.Trip_Status__c = Trigger.oldMap.get(mil.id).Trip_Status__c;
                        if((mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c == null) || (mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c != null)){
                            mil.Approved_Date__c = mil.Approved_Date__c;
                        } else if (Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = System.today();
                        } else {
                            mil.Approved_Date__c = Trigger.oldMap.get(mil.Id).Approved_Date__c;
                        }                        
                    }
                    else if( (mil.EMP_Mileage__c != Trigger.oldMap.get(mil.id).EMP_Mileage__c) && (mil.Name.contains('EMP')) && (Trigger.oldMap.get(mil.id).Trip_Status__c == 'Rejected')){
                        if(Trigger.oldMap.get(mil.id).EMP_Mileage__c != null){
                            mil.Mileage_Difference__c = mil.EMP_Mileage__c - Trigger.oldMap.get(mil.id).EMP_Mileage__c;
                       }             
                        mil.Trip_Status__c = Trigger.oldMap.get(mil.id).Trip_Status__c;
                        if(mil.Approved_Date__c != null && Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = mil.Approved_Date__c;
                        } else if (Trigger.oldMap.get(mil.Id).Approved_Date__c == null){
                            mil.Approved_Date__c = System.today();
                        } else {
                            mil.Approved_Date__c = Trigger.oldMap.get(mil.Id).Approved_Date__c;
                        }                        
                    }
                }
                if(customSetting.MappingMileage__c){
                    if(mil.Activity__c == 'Commute' && mil.EMP_Mileage__c >= 30){
                     mil.Mileage__c = mil.EMP_Mileage__c - 30;
                    } else if(mil.Activity__c == 'Commute'){
                        mil.Mileage__c = 0;
                    } else if (mil.Activity__c == 'Business'){
                         mil.Mileage__c = mil.EMP_Mileage__c;
                    }
                }  
            }        
            
            if(!updateMileagesList.isEmpty())
                MappingGasPriceTriggerHelper.updateConvertedDates(updateMileagesList);
        }
    }
    if(Trigger.isafter && Trigger.isUpdate ){
        if(customSetting.CanadianDriverMileage__c && checkRecursive.ConvertedFlag()){
            Set<String> milIdList = new Set<String>();
            for(Employee_Mileage__c mil : Trigger.New){
                if((mil.EMP_Mileage__c).setScale(2) != (Trigger.oldMap.get(mil.id).EMP_Mileage__c).setScale(2) || mil.Map_Country__c != Trigger.oldMap.get(mil.id).Map_Country__c  ){
                    milIdList.add(mil.Id);
                }
            }
            if(milIdList.size() > 0 ){
                MappingGasPriceTriggerHelper.updateCanadianMileage(milIdList);
            }
        }
        if(customSetting.TrackHistory__c && checkRecursive.runOnce()||Test.isRunningTest()){
            //MappingGasPriceTriggerHelper.TrackHistory(Trigger.oldMap,Trigger.new);
            String serializedRecords = JSON.serialize(Trigger.new);
            String serializedOldMap = JSON.serialize(Trigger.oldMap);
            System.debug('Serialized Trigger.new: ' + serializedRecords);
            System.debug('Serialized Trigger.oldMap: ' + serializedOldMap);
            MappingGasPriceTriggerHelper.UpdateTrackHistory(serializedRecords,serializedOldMap);
        }
        
    }
     if(Trigger.isAfter  && Trigger.isInsert && customSetting.CanadianDriverMileage__c ){
         system.debug('Insert into after insert');
         Set<String> milIdList = new Set<String>();
         for(Employee_Mileage__c mil : Trigger.New){
            milIdList.add(mil.Id);
         }
         if(milIdList.size() > 0 && checkRecursive.ConvertedFlag()  ){
            MappingGasPriceTriggerHelper.updateCanadianMileage(milIdList);
         }
     }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && customSetting.MappingGasStayTime__c){
        set<Id> reimbursementIdsSet = new set<Id>();
        List<datetime> tripList = new List<datetime>();
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c empmilege : Trigger.new) {
            reimbursementIdsSet.add(empmilege.EmployeeReimbursement__c) ;
        }
        if(!reimbursementIdsSet.isEmpty() && StaticValues.isFirstTime){
            StaticValues.isFirstTime = false;
            for(AggregateResult objMileage : [SELECT MIN(ConvertedStartTime__c) FROM Employee_Mileage__c WHERE EmployeeReimbursement__c In : reimbursementIdsSet GROUP BY Trip_Date__c ]){
                tripList.add((Datetime)objMileage.get('expr0'));
            }
            for(Employee_Mileage__c objMil : [SELECT id,ConvertedStartTime__c,Stay_Time__c FROM Employee_Mileage__c WHERE (ConvertedStartTime__c In :tripList OR Mileage__c = 0) AND EmployeeReimbursement__c In : reimbursementIdsSet ORDER BY Stay_Time__c]){
                objMil.Stay_Time__c = 0;
                mileageList.add(objMil);
            }
            
            If(!mileageList.isEmpty()){
                update mileageList;
            }
        }
    }
    
    // if(Trigger.isUpdate && Trigger.isAfter && checkRecursive.runOnce() && customSetting.TrackHistory__c) {
    //     String serializedRecords = JSON.serialize(Trigger.new);
    //     String serializedOldMap = JSON.serialize(Trigger.oldMap);
    //     System.debug('Serialized Trigger.new: ' + serializedRecords);
    //     System.debug('Serialized Trigger.oldMap: ' + serializedOldMap);
    //     MappingGasPriceTriggerHelper.UpdateTrackHistory(serializedRecords,serializedOldMap);
    // }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // AI-000570                                                                                                         //
    // Mileage update after the lock date                                                                                //
    //When ANY modifications are made to mileage after the lock date:                                                    //
    //The mileage needs to move to the next reimbursement period as soon as the modification happens after the lock date.//
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if(Trigger.isUpdate && Trigger.isAfter && customSetting.Mileage_Lockdate__c && !Test.isRunningTest()){                
            MappingGasPriceTriggerHelper.updateMileagesLockDate(Trigger.New);        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Ticket No :    EMC-1431                                                                                           //
    // Author : PARAS DHANANI                                                                                            //
    // Created Date : 22/03/202                                                                                          //
    // Mileage update after the lock date                                                                                //
    //When ANY modifications are made to mileage after the lock date:                                                    //
    //The mileage needs to move to the next BiWeekly reimbursement whose start date is current biWeekly reimbursement's  //
    //End Date + 1 as soon as the modification happens after the lock date.                                              //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // if(Trigger.isUpdate && Trigger.isAfter && customSetting.Mileage_Lockdate__c && !Test.isRunningTest()){
    //     //MappingGasPriceTriggerHelper.updateMilLockDateBWReim(Trigger.new);
    // }
    
    /*
    if(Trigger.isAfter && Trigger.isUpdate && customSetting.MappingMileage__c){
       //MappingGasPriceTriggerHelper.updateMileages(Trigger.new);
    }
     if(Trigger.isAfter && Trigger.isInsert && customSetting.MappingMileage__c){
         //MappingGasPriceTriggerHelper.updateMileages(Trigger.new);
     }*/
}