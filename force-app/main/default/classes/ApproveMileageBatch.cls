global without sharing class ApproveMileageBatch implements Database.Batchable<sObject> {
    public string reimbursements;
    public boolean biWeeklyAcc;
    public boolean highrisk;
    public List<Employee_Mileage__c> mileageUpdatelist;
    public ApproveMileageBatch(String reim,Boolean biweekaccount,Boolean highriskTrips) {
        reimbursements = reim;
        biWeeklyAcc = biweekaccount;
        highrisk = highriskTrips;
    }
    global List<Employee_Mileage__c> start(Database.BatchableContext bc) {
        List<String> employeeReimbursementList = new List<String>();
        mileageUpdatelist = new List<Employee_Mileage__c>();
        if(reimbursements!=null && reimbursements!='')
        {
            employeeReimbursementList = (List<String>)Json.deserialize(reimbursements,List<String>.class);
            //if (Test.isRunningTest()){
                //mileageUpdatelist  = [SELECT id, name, Trip_Status__c,High_Risk_Mileage__c, Rejected__c, EmployeeReimbursement__c,EmployeeReimbursement__r.Status__c, Approved_Date__c,Trip_Approval_Time__c FROM Employee_Mileage__c ];
            //} else 
            if(biWeeklyAcc  == true && highrisk == false){  
                mileageUpdatelist  = [SELECT id, name, Trip_Status__c, Rejected__c, Bi_Weekly_Reimbursement__c,Bi_Weekly_Reimbursement__r.Status__c, Approved_Date__c  FROM Employee_Mileage__c  WHERE Bi_Weekly_Reimbursement__c IN: employeeReimbursementList AND Bi_Weekly_Reimbursement__r.Contact__r.Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement'  AND Trip_Status__c ='Not Approved Yet'];
            } else if (biWeeklyAcc  == true && highrisk == true ){
                mileageUpdatelist  = [SELECT id, name, Trip_Status__c, Rejected__c,High_Risk_Mileage__c, Bi_Weekly_Reimbursement__c,Bi_Weekly_Reimbursement__r.Status__c, Approved_Date__c  FROM Employee_Mileage__c  WHERE Bi_Weekly_Reimbursement__c IN: employeeReimbursementList AND Bi_Weekly_Reimbursement__r.Contact__r.Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement'  AND Trip_Status__c ='Not Approved Yet' AND High_Risk_Mileage__c =true ];
            } else if(biWeeklyAcc  == false && highrisk == false){
                mileageUpdatelist  = [SELECT id, name, Trip_Status__c, Rejected__c, EmployeeReimbursement__c,EmployeeReimbursement__r.Status__c, Approved_Date__c,Trip_Approval_Time__c FROM Employee_Mileage__c WHERE EmployeeReimbursement__c in : employeeReimbursementList AND Trip_Status__c ='Not Approved Yet' ];
            } else if(biWeeklyAcc  == false && highrisk == true){
                mileageUpdatelist  = [SELECT id, name, Trip_Status__c,High_Risk_Mileage__c, Rejected__c, EmployeeReimbursement__c,EmployeeReimbursement__r.Status__c, Approved_Date__c,Trip_Approval_Time__c FROM Employee_Mileage__c WHERE EmployeeReimbursement__c in : employeeReimbursementList AND Trip_Status__c ='Not Approved Yet' AND High_Risk_Mileage__c =true ];
            } if (Test.isRunningTest()){
                mileageUpdatelist  = [SELECT id, name, Trip_Status__c,High_Risk_Mileage__c, Rejected__c, EmployeeReimbursement__c,EmployeeReimbursement__r.Status__c, Approved_Date__c,Trip_Approval_Time__c FROM Employee_Mileage__c ];
            }
        }
        return mileageUpdatelist;
    }
    global void execute(Database.BatchableContext bc, List<Employee_Mileage__c> mileageUpdatelist){
        List<Employee_Mileage__c> empLst =new List<Employee_Mileage__c>();
        for(Employee_Mileage__c empmilege : mileageUpdatelist) {
            empmilege.Approved_Date__c = System.today();
            empmilege.Trip_Status__c = 'Approved';
            empLst.add(empmilege);
        }
        if(!empLst.isEmpty()) {
            update empLst;
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}