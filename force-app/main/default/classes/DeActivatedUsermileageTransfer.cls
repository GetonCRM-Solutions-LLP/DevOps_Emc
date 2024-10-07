global class DeActivatedUsermileageTransfer implements Database.Batchable<sObject>,Database.Stateful 
{   String query;
    global List<String> deActivatedConIds;
    public Integer decider;
    public String userid;
    public List<Employee_Reimbursement__c> lastMonthReimbursement;
    public Set<String> reimbursementIdSet;
    global DeActivatedUsermileageTransfer() 
    {   deActivatedConIds = new List<String>();
        lastMonthReimbursement = new List<Employee_Reimbursement__c>();
       
        reimbursementIdSet = new Set<String>();
        decider = 0;
        if(!Test.isRunningTest()){
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE IsDeactivated__c = false AND Deactivated_Date__c = Today AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND (Role__c = \'Driver\' OR Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver/Manager\')';
        }
        else
        {
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE IsDeactivated__c = false AND Deactivated_Date__c = Today AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND (Role__c = \'Driver\' OR Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver/Manager\') Limit 1';
        }
        
    }   
    global DeActivatedUsermileageTransfer(List<String> passeddeActivatedConIds) 
    {   deActivatedConIds = new List<String>();     
        lastMonthReimbursement = new List<Employee_Reimbursement__c>();
        
        deActivatedConIds = passeddeActivatedConIds;
        reimbursementIdSet = new Set<String>();
        decider = 1; 
        String editedquery = '( ';
        for(String currentMonthName : deActivatedConIds)
        {
            editedquery = editedquery + '\''+currentMonthName+ '\','; 
        }
        if(editedquery.endsWith(','))
        {
            editedquery = editedquery.removeEnd(',');
        }
        editedquery = editedquery+' )';

        if(!Test.isRunningTest()){
       
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE Id IN '+editedquery;
        }
        else
        {
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE Id IN '+ editedquery + 'LIMIT 1';
        }
        System.debug('query :- '+ query);
    }   
    global DeActivatedUsermileageTransfer(String passeduserid) 
    {  
        deActivatedConIds = new List<String>(); 
        lastMonthReimbursement = new List<Employee_Reimbursement__c>();    
        userid = passeduserid;
        reimbursementIdSet = new Set<String>();
        decider = 2;
        String identifier = userid.left(3);
        if(identifier == '001'&& (!Test.isRunningTest())) {
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE AccountId =\''+userid+'\' ';   
        }
        else if(!Test.isRunningTest()){
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE Id =\''+userid+'\' ';
        } 
        else {
            query = 'Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE Id =\''+userid+'\' Limit 1';
        }
       
    }   
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('query :- '+ query);
        return Database.getQueryLocator(query);
        //return [Select id,Name,Triplog_UserID__c,isCommunityUser__c,Deactivated_Date__c,External_Email__c,IsDeactivated__c,Account.Triplog_API__c FROM Contact WHERE IsDeactivated__c = false AND Deactivated_Date__c = Today AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND (Role__c = 'Driver' OR Role__c = 'Driver/Manager')];
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug('List<sObject> scope'+scope);
        list<Employee_Mileage__c> mileageList = new list<Employee_Mileage__c>();
        List<id> contactids = new List<id>();
        for(Contact con :(List<Contact>)scope)
        {
            contactids.add(con.id);
            system.debug('con.name'+con.name);
        }
        System.debug('contactids'+contactids);
        if(contactids.size() > 0 ){
            system.debug('inside if contactids'+DeActivatedUserBatch.currentMonth(0));
            lastMonthReimbursement = [Select id from Employee_Reimbursement__c where contact_Id__c=:contactids and Month__c=:DeActivatedUserBatch.currentMonth(0) limit 1];
            system.debug('inside if lastMonthReimbursement'+lastMonthReimbursement);
        }
        system.debug('inside if lastMonthReimbursement'+lastMonthReimbursement);
        
        
        map<id,List<Employee_Mileage__c>> reimbursementidMileageMap = new map<id,List<Employee_Mileage__c>>();
        
        System.debug('Label.Not_Approved_Yet_Mileage_Status=='+Label.Not_Approved_Yet_Mileage_Status);
        for(Employee_Mileage__c currentMileage:[SELECT id, EmployeeReimbursement__c, EmployeeReimbursement__r.Contact_Id__c, EmployeeReimbursement__r.month__c, 
                                                        Trip_Status__c, Approved_Date__c, Carry_Forward_Mileage__c 
                                                        FROM Employee_Mileage__c 
                                                        WHERE Approved_Date__c = null AND Trip_Status__c =: Label.Not_Approved_Yet_Mileage_Status AND EmployeeReimbursement__r.Contact_Id__c=:contactids])
        {
            if(reimbursementidMileageMap.containsKey(currentMileage.EmployeeReimbursement__c))
            {
                List<Employee_Mileage__c> mileageListofReimbursement = new List<Employee_Mileage__c>(); 
                mileageListofReimbursement = reimbursementidMileageMap.get(currentMileage.EmployeeReimbursement__c);
                reimbursementidMileageMap.remove(currentMileage.EmployeeReimbursement__c);
                mileageListofReimbursement.add(currentMileage);
                reimbursementidMileageMap.put(currentMileage.EmployeeReimbursement__c,mileageListofReimbursement);
            }
            else
            {
                List<Employee_Mileage__c> mileageListofReimbursement = new List<Employee_Mileage__c>(); 
                mileageListofReimbursement.add(currentMileage);
                reimbursementidMileageMap.put(currentMileage.EmployeeReimbursement__c,mileageListofReimbursement);
            }
            System.debug('DeActivatedUserBatch.currentMonth(0) :- '+DeActivatedUserBatch.currentMonth(0));
            
                            
            if(currentMileage.EmployeeReimbursement__r.month__c==DeActivatedUserBatch.currentMonth(0) && lastMonthReimbursement.size() > 0)
            {                    
                lastMonthReimbursement[0].id = currentMileage.EmployeeReimbursement__c;                                               
            }
                       
        }
        //System.debug('lastMonthReimbursement.id :- '+lastMonthReimbursement[0].id);
        if(lastMonthReimbursement.size() > 0 )
        {
            for(String currentReimbursmentId : reimbursementidMileageMap.keySet())
            {
                reimbursementIdSet.add(currentReimbursmentId); 
                if(lastMonthReimbursement[0].id != currentReimbursmentId)
                {
                    System.debug(lastMonthReimbursement[0].id+ ' Is Not equal to '+currentReimbursmentId);
                    for(Employee_Mileage__c currentMileage:reimbursementidMileageMap.get(currentReimbursmentId))
                    {
                        currentMileage.EmployeeReimbursement__c=lastMonthReimbursement[0].id;
                        currentMileage.Carry_Forward_Mileage__c = true;
                        mileageList.add(currentMileage);
                    }
                }
                else
                {
                    System.debug('Both are Same');
                }
            } 
        } 
        if(mileageList!=null && mileageList.size()>0)
        {
            update mileageList;
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        List<Employee_Reimbursement__c> reimbursementListtoUpdate = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c currentReimbursement : [Select id,Approved_Date__c,Status__c,Total_Pending__c from Employee_Reimbursement__c where id IN : reimbursementIdSet and Total_Pending__c=0])
        {
            currentReimbursement.Approved_Date__c = System.today();
            currentReimbursement.Status__c = 'Approved';
            reimbursementListtoUpdate.add(currentReimbursement);
        }
        System.debug('reimbursementListtoUpdate update 0 Mileage Reimbursement :- '+ reimbursementListtoUpdate);
        if(reimbursementListtoUpdate.size()>0)
        {
            update reimbursementListtoUpdate;
        }
        System.debug('decider is :- '+ decider);
        if(!Test.isRunningTest() && decider==0) 
        {
            DeActivatedUserBatchFromTriplog deActUserTriplog = new DeActivatedUserBatchFromTriplog();
            Database.executeBatch(deActUserTriplog, 1);
        }
        else if(!Test.isRunningTest() && decider==1) 
        {
            DeActivatedUserBatchFromTriplog deActUserTriplog = new DeActivatedUserBatchFromTriplog(deActivatedConIds);
            Database.executeBatch(deActUserTriplog, 1);
        }
        else if(!Test.isRunningTest() && decider==2) 
        {
            DeActivatedUserBatchFromTriplog deActUserTriplog = new DeActivatedUserBatchFromTriplog(userid);
            Database.executeBatch(deActUserTriplog, 1);
        }
    }
}