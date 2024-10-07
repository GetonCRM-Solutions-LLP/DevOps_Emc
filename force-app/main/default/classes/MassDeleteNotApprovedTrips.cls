global  class MassDeleteNotApprovedTrips {
    webservice static void DeleteUnApprovedTrips( String AccId,String startDate,String endDate){ 
        system.debug('AccId=='+AccId);
        system.debug('startDate=='+startDate);
        system.debug('endDate=='+endDate);
        List<Employee_Mileage__c> empList = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c emp : [select id,name,Trip_Date__c
                                       from Employee_Mileage__c 
                                       where EmployeeReimbursement__r.Contact_Id__r.AccountId =: AccId 
                                       AND Trip_Date__c >= : Date.valueOf(startDate)
                                       AND Trip_Date__c <= : Date.valueOf(endDate)
                                       AND Trip_Status__c = 'Not Approved Yet'
                                       AND Approved_Date__c = null
                                       ]){
                                           system.debug('emp='+ emp);
                                           empList.add(emp);        
                                       } 
        system.debug('empListTest=='+empList);
       	if(empList.size() > 0 ){
            Delete empList;
        }
    }
}