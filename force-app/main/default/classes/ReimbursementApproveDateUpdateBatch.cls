//AI-000363
global class ReimbursementApproveDateUpdateBatch implements Database.Batchable<sObject>
{

    public String query = '';
    global ReimbursementApproveDateUpdateBatch() 
    {
        //query = 'Select id,Status__c,Approved_Date__c From Employee_Reimbursement__c Where Status__c = \'Pending\'';
        query = 'Select id,Status__c,Approved_Date__c,Total_Approved_Pending_Mileage__c,Contact_Id__r.Deactivated_Date__c From Employee_Reimbursement__c Where Status__c = \'Pending\' and Total_Approved_Pending_Mileage__c = 0 and Contact_Id__r.Deactivated_Date__c = LAST_MONTH';
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Employee_Reimbursement__c> reimburseList = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c reimb : (List<Employee_Reimbursement__c>)scope) 
        {
            Employee_Reimbursement__c empRem = new Employee_Reimbursement__c();
            empRem.id = reimb.id;
            empRem.Approved_Date__c = Date.today();
            empRem.Status__c = 'Approved';
            reimburseList.add(empRem);
            system.debug(reimburseList);
        }
        update reimburseList;

    }    
    global void finish(Database.BatchableContext bc){
       
    }    
}