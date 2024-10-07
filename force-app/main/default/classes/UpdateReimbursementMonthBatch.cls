global class UpdateReimbursementMonthBatch Implements Database.Batchable<sObject> {
    
    public string CurrentMonthyear;
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('select id,AccountId,Account.Name,Last_Reimbursement_Created__c from contact where Deactivated_Date__c = null and Account.isUsingTriplog__c= true');
    }
    
    global void execute(Database.BatchableContext bc,List<contact> scope){
        try {
                Date myDate = Date.today();               
                if(myDate.month() == 01){
                    CurrentMonthyear = '12 -'+ (myDate.year() - 1);
                } else {
                    CurrentMonthyear = myDate.Month() > 9 ?  (myDate.Month() -1)+'-'+myDate.year() : '0'+(myDate.Month() -1)+'-'+myDate.year();
                }               
                List<Account> accountListToUpdate = new List<Account>();
                Map<ID,String> accmap = new  Map<ID,String>();
                List<contact> conList = new List<contact>();
                 for(contact con : (List<contact>)scope) {
                    accmap.put(con.AccountId,con.Account.Name);
                    con.Last_Reimbursement_Created__c = CurrentMonthyear;
                    conList.add(con);
                }
                if(conList.size() > 0) {
                    update conList;                
                }
                if(accmap.size () > 0){
                    for(String mapkey : accmap.keySet()){
                        Account acc = new Account();
                        acc.id = mapkey;
                        acc.Last_Reimbursement_Created__c = CurrentMonthyear;
                        accountListToUpdate.add(acc);
                    }            
                    if(accountListToUpdate.size() > 0) {
                        update accountListToUpdate;                    
                    } 
                }                         
        }catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
    } 
    public void finish(Database.BatchableContext bc){ }
}