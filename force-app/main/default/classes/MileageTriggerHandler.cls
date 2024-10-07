// new Update code without error

public class MileageTriggerHandler {
    Public Static string accId;
    Public static List<String> accIdList;
    
    public static void mileageRemoveApprovalDateHandler(set<Id> reimbursementApprovalStatusSet) {
        List<Employee_Reimbursement__c> reimbursementlist = new List<Employee_Reimbursement__c>();       
        for(Employee_Reimbursement__c emp : [SELECT Id,
                                             Status__c,
                                             Approved_Date__c,
                                             Mileage_Lock_Date__c 
                                             FROM Employee_Reimbursement__c 
                                             WHERE Id IN:  reimbursementApprovalStatusSet
                                             AND (Status__c = 'Approved' OR Status__c = 'Rejected') AND Mileage_Lock_Date__c = null ]){                                                
                                                     emp.status__c = 'Pending';
                                                     emp.Approved_Date__c = null;
                                                     Reimbursementlist.add(emp);
                                             }
        if(Reimbursementlist.size() > 0){
            update Reimbursementlist;
        }
    }
    /* EMC - 339
* Method is used to update Driver's Working hours field located on Employee reimbursement Object
* based on the number of unique trip date for the month. means if there are 20 trips of driver for the 
* month and 15 trips are unique trip date and 5 trips are in sme day trips at that time it is count 5 trips 
* as only one date and onther trips are count individual so the total working days are 15 + 1 = 16.   
*/   
    Public static void updateWorkingDays(List<Employee_Mileage__c> empMileageList) {
        system.debug('empMileageList==' + empMileageList);
        accId = System.Label.MonthlyReimWorkingDAys;
        system.debug('accId==' + accId);
        accIdList = new List<String>();
        accIdList = accId.split(',');
        system.debug('accIdList==' + accIdList);
        
        Set<Id> reimIdList = new Set<Id>();
        Set<string> monthYearList = new Set<string>();
        List<Employee_Reimbursement__c> reimList = new List<Employee_Reimbursement__c>();
        
        Map<id, String> mapOfmilagevsDate = new Map<Id, String>();
        Map<ID, String> mapofIdvsMonth = new Map<ID, String>();
        Map<ID, Integer> mapEmpvsMil = new Map<ID, Integer>();
        
        for(Employee_Mileage__c objem: empMileageList){
            reimIdList.add(objem.EmployeeReimbursement__c); 
            monthYearList.add(objem.Monthyear__c);
        }
        for(Employee_Reimbursement__c objReim: [SELECT id,Working_Days__c,Month__c 
                                                FROM Employee_Reimbursement__c 
                                                WHERE id in: reimIdList
                                                AND Contact_Id__r.Account.Name IN: accIdList]){
                                                   
                                                   string splitd = string.valueOf(objReim.Month__c);
                                                   string[] dateSplit = splitd.split('-');
                                                   mapofIdvsMonth.put(objReim.id, objReim.Month__c);  
                                                   //mapofIdvsMonth.put(objReim.id, Integer.valueof(dateSplit[0]));  
                                               }              
        if(mapofIdvsMonth != null && mapofIdvsMonth.size() > 0){                                        
            for(Employee_Mileage__c objem: empMileageList){
                System.debug('month field on the mileage->'+objem.Monthyear__c);
                if((objem.Monthyear__c == mapofIdvsMonth.get(objem.EmployeeReimbursement__c) && !mapOfmilagevsDate.containsKey(objem.EmployeeReimbursement__c))){
                    mapOfmilagevsDate.put(objem.EmployeeReimbursement__c, objem.Monthyear__c);
                }
            }
        }                                   
        for(AggregateResult arobj: [SELECT EmployeeReimbursement__c, COUNT_DISTINCT(Trip_Date__c) myCount 
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__c in: reimIdList
                                    AND EmployeeReimbursement__r.Contact_Id__r.Account.Name IN: accIdList 
                                    AND  Monthyear__c IN: monthYearList GROUP by EmployeeReimbursement__c]) { 
                                        if(mapofIdvsMonth.ContainsKey((ID)arobj.get('EmployeeReimbursement__c')) && mapOfmilagevsDate.ContainsKey((ID)arobj.get('EmployeeReimbursement__c'))){
                                            if(mapOfmilagevsDate.get((ID)arobj.get('EmployeeReimbursement__c')) == mapofIdvsMonth.get((ID)arobj.get('EmployeeReimbursement__c'))){
                                                mapEmpvsMil.put((ID)arobj.get('EmployeeReimbursement__c'), (Integer)arobj.get('myCount'));
                                            }
                                        }
                                    }  
        
        if(mapEmpvsMil != null && mapEmpvsMil.size() > 0) {
            
            for( Employee_Reimbursement__c objReim : [SELECT id,Working_Days__c 
                                                      FROM Employee_Reimbursement__c 
                                                      WHERE id in: reimIdList 
                                                      AND  Month__c IN: monthYearList
                                                      AND Contact_Id__r.Account.Name IN: accIdList]){
                                                          objReim.Working_Days__c = mapEmpvsMil.get(objReim.id);
                                                          reimList.add(objReim);
                                                      }
        } else {
            for( Employee_Reimbursement__c objReim: [SELECT id,Working_Days__c 
                                                     FROM Employee_Reimbursement__c 
                                                     WHERE id in: reimIdList 
                                                     AND Contact_Id__r.Account.Name IN: accIdList
                                                     AND  Month__c IN: monthYearList]){
                                                         objreim.Working_Days__c = 0;
                                                         reimList.add(objreim);
                                                     }
        }   
        
        if(reimList != null && reimList.size() > 0) {
            Update reimList;
        }        
    }

    Public static void workingDaysforBiweeklyDrivers(List<Employee_Mileage__c> empMileageList) {
         accId = System.Label.BiWeekWorkingDay;
        system.debug('accId==' + accId);
        accIdList = new List<String>();
        accIdList = accId.split(',');
        system.debug('accIdList==' + accIdList);
        
        set<Id> biWeeklyRem = new set<Id>();
        for(Employee_Mileage__c em : empMileageList){
            biWeeklyRem.add(em.Bi_Weekly_Reimbursement__c);
        }
        set<date> uniqueDates = new set<date>();
        Map<Id,Integer> biweeklyWorkingDaysMap = new map<Id,Integer>();
        for(Employee_Mileage__c em : [SELECT id,Bi_Weekly_Reimbursement__c,Bi_Weekly_Reimbursement__r.Start_Date__c,Bi_Weekly_Reimbursement__r.End_Date__c,EmployeeReimbursement__r.Contact_Id__r.Reimbursement_Frequency__c,Trip_Date__c 
                                      FROM Employee_Mileage__c 
                                      WHERE EmployeeReimbursement__r.Contact_Id__r.Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement'
                                      AND Bi_Weekly_Reimbursement__r.Contact__r.Account.Name IN: accIdList
                                            AND Bi_Weekly_Reimbursement__c IN : biWeeklyRem ]){
                                          
                                          if(em.Bi_Weekly_Reimbursement__r.Start_Date__c <= em.Trip_Date__c &&
                                             em.Bi_Weekly_Reimbursement__r.End_Date__c >= em.Trip_Date__c && 
                                             !uniqueDates.contains(em.Trip_Date__c)){
                                                 
                                                 if(!biweeklyWorkingDaysMap.containsKey(em.Bi_Weekly_Reimbursement__c))
                                                     biweeklyWorkingDaysMap.put(em.Bi_Weekly_Reimbursement__c,0);
                                                 biweeklyWorkingDaysMap.put(em.Bi_Weekly_Reimbursement__c,biweeklyWorkingDaysMap.get(em.Bi_Weekly_Reimbursement__c)+1);
                                                 uniqueDates.add(em.Trip_Date__c);
                                             }
                                      }
        
        if(biweeklyWorkingDaysMap.keySet().size()>0){
            List<Bi_Weekly_Reimbursement__c> workingDayUpdateLST = new List<Bi_Weekly_Reimbursement__c>();
            for(Id i : biweeklyWorkingDaysMap.keySet()){
                workingDayUpdateLST.add(new Bi_Weekly_Reimbursement__c(Id = i, Working_Days__c = biweeklyWorkingDaysMap.get(i)));
            }
            if(workingDayUpdateLST.size()>0){
                update workingDayUpdateLST;
            }
        }      
    }
}