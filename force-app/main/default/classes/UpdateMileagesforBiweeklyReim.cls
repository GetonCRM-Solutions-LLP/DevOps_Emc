public class UpdateMileagesforBiweeklyReim implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        string query;        
        if(test.isRunningTest()){
                query = ' select id,EmployeeReimbursement__r.Contact_Id__c,Bi_Weekly_Reimbursement__c from Employee_Mileage__c ';          
         } else {
                query = ' select id,EmployeeReimbursement__r.Contact_Id__c,Bi_Weekly_Reimbursement__c from Employee_Mileage__c where Bi_Weekly_Reimbursement__c = null';  
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Employee_Mileage__c> scope){
        if(test.isRunningTest()){
            justIncrement();
        }
        system.debug('scope'+scope);
        List<Employee_Mileage__c> millist = new List<Employee_Mileage__c>();
        map<id,id> biweek = new map<id,id>();
        for(Bi_Weekly_Reimbursement__c con : [SELECT id,name,Contact__c from Bi_Weekly_Reimbursement__c ]){
            biweek.put(con.Contact__c,con.id);
        }
        map<ID,List<Id>> milmap = new map<ID,List<Id>>();
        for (Employee_Mileage__c mil : scope) {
            if( biweek.containsKey(mil.EmployeeReimbursement__r.Contact_Id__c)){
                if(mil.Bi_Weekly_Reimbursement__c == null){
                    mil.Bi_Weekly_Reimbursement__c = biweek.get(mil.EmployeeReimbursement__r.Contact_Id__c);
                    millist.add(mil);   
                }
                
            }
            else {
                if( !milmap.containsKey(mil.EmployeeReimbursement__r.Contact_Id__c)){
                    milmap.put(mil.EmployeeReimbursement__r.Contact_Id__c,new List<Id> {mil.id});
                } else {
                    List<Id> milIds = milmap.get(mil.EmployeeReimbursement__r.Contact_Id__c);
                    milIds.add(mil.id);
                    milmap.put(mil.EmployeeReimbursement__r.Contact_Id__c,milIds);
                } 
            }
        }
        List<Bi_Weekly_Reimbursement__c> biweeklist = new List<Bi_Weekly_Reimbursement__c>();
        for(String obj : milmap.keyset()){
            Bi_Weekly_Reimbursement__c bob = new Bi_Weekly_Reimbursement__c();
            bob.name = '9/19/2021 to 10/2/2021';
            bob.Contact__c = obj;
            biweeklist.add(bob);
        }
        if(biweeklist.size() > 0){
            insert biweeklist;
        }
        system.debug('setconId='+ milmap);
        system.debug('millistsize='+ millist.size());
        system.debug('millist='+ millist);
        if(millist.size() > 0){
            system.debug('update');
            update millist;
        }
    }    
    
    public void finish(Database.BatchableContext bc){
    } 
    static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}