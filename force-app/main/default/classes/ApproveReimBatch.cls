/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use for approve reimbursement from dashboard pages.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 12 June 2021 | Sanket Goswami
 * @description: 
 */
global class ApproveReimBatch implements Database.Batchable<String> {
    public string reimbursements;
    public boolean biWeeklyAcc;
    public List<Employee_Reimbursement__c> reimbursementList;
    public List<Bi_Weekly_Reimbursement__c> biWeekreimbursementList;
    public ApproveReimBatch(String reim,Boolean biweekaccount) {
        reimbursements = reim;
        biWeeklyAcc = biweekaccount;
    }
    global Iterable<String> start(Database.BatchableContext bc) {
        List<String> employeeReimbursementList = new List<String>();
        reimbursementList = new List<Employee_Reimbursement__c>();
        biWeekreimbursementList = new List<Bi_Weekly_Reimbursement__c>();
        if(reimbursements!=null && reimbursements!='')
        {
            employeeReimbursementList = (List<String>)Json.deserialize(reimbursements,List<String>.class);
            if(biWeeklyAcc == true){
                for(String currentReimbursement : employeeReimbursementList)
                {
                    Bi_Weekly_Reimbursement__c currentReim = new Bi_Weekly_Reimbursement__c();
                    currentReim.id= currentReimbursement;
                    currentReim.Reimbursement_Approval__c = true;
                    biWeekreimbursementList.add(currentReim);
                }
                if(!biWeekreimbursementList.isEmpty()) {
                    update biWeekreimbursementList;
                }
            } else {
                for(String currentReimbursement : employeeReimbursementList)
                {
                    Employee_Reimbursement__c currentReim = new Employee_Reimbursement__c();
                    currentReim.id= currentReimbursement;
                    currentReim.Reimbursement_Approval__c = true;       
                    reimbursementList.add(currentReim);
                }
                if(!reimbursementList.isEmpty()) {
                    update reimbursementList;
                }
            }
        }
        return employeeReimbursementList;
    }
    global void execute(Database.BatchableContext bc, List<String> employeeReimbursementList){       
        reimbursementList = new List<Employee_Reimbursement__c>();
        biWeekreimbursementList = new List<Bi_Weekly_Reimbursement__c>();
        if(biWeeklyAcc == true){
            for(String currentReimbursement : employeeReimbursementList) {
                Bi_Weekly_Reimbursement__c currentReim = new Bi_Weekly_Reimbursement__c();
                currentReim.id= currentReimbursement;
                currentReim.Status__c = 'Approved';
                currentReim.Approved_Date__c = system.today();
                currentReim.Reimbursement_Approval__c = false; 
                biWeekreimbursementList.add(currentReim);
            }
            if(!biWeekreimbursementList.isEmpty()) {              
                update biWeekreimbursementList ;
            }
        } else {
            for(String currentReimbursement : employeeReimbursementList) {
                Employee_Reimbursement__c currentReim = new Employee_Reimbursement__c();
                currentReim.id= currentReimbursement;
                currentReim.Status__c = 'Approved';
                currentReim.Approved_Date__c = system.today();
                currentReim.Reimbursement_Approval__c = false; 
                currentReim.Reimbursement_Approval_Time__c = DateTime.now();            
                reimbursementList.add(currentReim);
            }
            if(!reimbursementList.isEmpty()) {
                update reimbursementList;
            }            
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}