global with sharing class DeleteTripsBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = '';
        if(!Test.isRunningTest())
        {  
            query = 'select id,EmployeeReimbursement__r.name,EmployeeReimbursement__r.Contact_Id__r.Account.Name,Trip_Status__c from Employee_Mileage__c where Trip_Date__c =LAST_MONTH  and EmployeeReimbursement__r.Contact_Id__r.Account.isUsingTriplog__c = true and EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null and Trip_Status__c = \'Not Approved Yet\' and Trip_Id__c != null ';
        }
        else
        {
            query = 'select id,EmployeeReimbursement__r.name,EmployeeReimbursement__r.Contact_Id__r.Account.Name,Trip_Status__c from Employee_Mileage__c  limit 1'; 
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        System.debug(scope.size());
        Delete Scope;
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('deletion completed');
    }
}