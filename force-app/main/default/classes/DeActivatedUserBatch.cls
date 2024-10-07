global class DeActivatedUserBatch implements Database.Batchable<sObject>,Database.Stateful
{
    public String query = '';
    public List<Id> contactIds;
    public List<String> deActivatedConIds;
    public List<Employee_Reimbursement__c> reimbursementList;
    public List<Employee_Reimbursement__c> reimbursementListtoUpdate;
    public Map<string,Decimal> fuelpriceMap;
    public Map<String,Employee_Reimbursement__c> existingReimbursementMap;
    public List<String> listofMonths;
    public Integer decider;
    public String userid;
    global DeActivatedUserBatch() 
    {
        deActivated();
        decider = 0;
        if(!Test.isRunningTest())
        {
            query = 'SELECT Id,Name,Deactivated_Date__c,External_Email__c,Account.Triplog_API__c,Maintenance_and_Tires__c,MPG__c,Mailingcity,MailingState,Fixed_Amount__c FROM Contact WHERE Deactivated_Date__c = Today and IsDeactivated__c = false';//+Datetime.now().addDays(-20).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
        }
        else
        {
            query = 'SELECT Id,Name,Deactivated_Date__c,External_Email__c,Account.Triplog_API__c,Maintenance_and_Tires__c,MPG__c,Mailingcity,MailingState,Fixed_Amount__c FROM Contact WHERE Deactivated_Date__c = Today and IsDeactivated__c=false LIMIT 1';//+Datetime.now().addDays(-20).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
        }
    }
    global DeActivatedUserBatch(List<String> passeddeActivatedConIds) 
    {
        deActivatedConIds = passeddeActivatedConIds;
        deActivated();
        decider = 1; 
        String editedquery = '( ';
        for(String currentContactid : deActivatedConIds)
        {
            editedquery = editedquery + '\''+currentContactid+ '\','; 
        }
        if(editedquery.endsWith(','))
        {
            editedquery = editedquery.removeEnd(',');
        }
        editedquery = editedquery+' )';

        if(!Test.isRunningTest())
        {
           query = 'SELECT Id,Name,Deactivated_Date__c,External_Email__c,Account.Triplog_API__c,Maintenance_and_Tires__c,MPG__c,Mailingcity,MailingState,Fixed_Amount__c FROM Contact WHERE Id IN '+editedquery +' and IsDeactivated__c = false';//+Datetime.now().addDays(-20).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
        }
        else
        {
            query = 'SELECT Id,Name,Deactivated_Date__c,External_Email__c,Account.Triplog_API__c,Maintenance_and_Tires__c,MPG__c,Mailingcity,MailingState,Fixed_Amount__c FROM Contact WHERE Id IN '+ editedquery+' and IsDeactivated__c = false LIMIT 1';//+Datetime.now().addDays(-20).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
        }
    }

    
    global DeActivatedUserBatch(String passeduserid)
    {
        deActivated();
        userid = passeduserid;
        decider = 2;
        String identifier = userid.left(3);
        if(identifier == '001' && (!Test.isRunningTest())){
            query = 'SELECT Id,Name,Deactivated_Date__c,External_Email__c,Account.Triplog_API__c,Maintenance_and_Tires__c,MPG__c,Mailingcity,MailingState,Fixed_Amount__c FROM Contact WHERE AccountId =\''+userid+'\' and IsDeactivated__c=false';
        }
        else if(!Test.isRunningTest()) {
            query = 'SELECT Id,Name,Deactivated_Date__c,External_Email__c,Account.Triplog_API__c,Maintenance_and_Tires__c,MPG__c,Mailingcity,MailingState,Fixed_Amount__c FROM Contact WHERE Id =\''+userid+'\' and IsDeactivated__c=false';
        }
        else {
            query = 'SELECT Id,Name,Deactivated_Date__c,External_Email__c,Account.Triplog_API__c,Maintenance_and_Tires__c,MPG__c,Mailingcity,MailingState,Fixed_Amount__c FROM Contact WHERE Id =\''+userid+'\' and IsDeactivated__c=false LIMIT 1';            
        }
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {   
        if(deActivatedConIds != null && deActivatedConIds.size() > 0)
        {
            contactIds.addAll(deActivatedConIds);
        }
        else 
        {
            for(Contact contactId : (List<Contact>)scope) 
            {
                system.debug('before for'+contactId);
                contactIds.add(contactId.Id);
            }  
        }
        
        for(Employee_Reimbursement__c currentReimbursment:[SELECT id, Name, Contact_Id__c,Status__c,Fuel_Price__c,Month__c,Maintenance_and_Tires__c,MPG__c,Approved_Date__c FROM Employee_Reimbursement__c WHERE Contact_Id__c IN: contactIds and Month__c IN: listofMonths])
        {
            existingReimbursementMap.put(currentReimbursment.name,currentReimbursment);
        }
        System.debug(listofMonths);
        for(Contact currentContact:(List<Contact>) scope)
        {
            system.debug('currentContact'+currentContact);
            Decimal fuelPrice = 0;
            if(fuelpriceMap.containsKey((currentContact.Mailingcity + '-' + currentContact.MailingState).touppercase()))
            {
                fuelPrice = fuelpriceMap.get((currentContact.Mailingcity + '-' + currentContact.MailingState).touppercase());
            }
            if(listofMonths.size()>0 && (!existingReimbursementMap.containsKey(currentContact.Name+':' + currentMonth(-1))))
            {
                // create New Reimbursement of last month.                               
                reimbursementList.add(getReimbursement(currentContact,-1,fuelPrice,''));
                System.debug('reimbursementList'+reimbursementList);
            }
            else if((existingReimbursementMap.containsKey(currentContact.Name+':' + currentMonth(-1))))
            {
                reimbursementListtoUpdate.add(getReimbursement(currentContact,-1,fuelPrice,existingReimbursementMap.get(currentContact.Name+':' + currentMonth(-1)).id));
            }
            if(!existingReimbursementMap.containsKey(currentContact.Name+':' +currentMonth(0)))
            {
                // Need to change here for Createing 2 months of reimbursements if user don't have previous month reimbursements.
                reimbursementList.add(getReimbursement(currentContact,0,fuelPrice,''));
                System.debug('reimbursementListnot'+reimbursementList);
            }
            else if((existingReimbursementMap.containsKey(currentContact.Name+':' + currentMonth(0))))
            {
                //if current month reimbursement available then get it and update
                reimbursementListtoUpdate.add(getReimbursement(currentContact,0,fuelPrice,existingReimbursementMap.get(currentContact.Name+':' + currentMonth(0)).id));
            }
        }
    }
    global void finish(Database.BatchableContext BC) 
    {
        if(reimbursementList.size()>0)
        {   
            System.debug('reimbursementListbeforeinsert'+reimbursementList);
            insert reimbursementList;
        }
        if(reimbursementListtoUpdate.size()>0)
        {
            update reimbursementListtoUpdate;
        }
        System.debug('decider is :- '+ decider);
        if(!Test.isRunningTest() && decider==0) 
        {
            DeActivatedUserBatchMileage batchMileage = new DeActivatedUserBatchMileage();
            Database.executeBatch(batchMileage, 1);
        }
        else if(!Test.isRunningTest() && decider==1) 
        {
            DeActivatedUserBatchMileage batchMileage = new DeActivatedUserBatchMileage(deActivatedConIds);
            Database.executeBatch(batchMileage, 1);
        }
        else if(!Test.isRunningTest() && decider==2) 
        {
            DeActivatedUserBatchMileage batchMileage = new DeActivatedUserBatchMileage(userid);
            Database.executeBatch(batchMileage, 1);
        }
    }
    global static String currentMonth(Integer integerValue) 
    {
        String tempDate = date.today().addMonths(integerValue).Month() + '-' + date.today().addMonths(integerValue).Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }        
        return lastMonth;
    }
    public Employee_Reimbursement__c getReimbursement(Contact currentContact,Integer monthValue,Decimal fuelPrice,String reimId)
    {
        Employee_Reimbursement__c currentReimbursement = new Employee_Reimbursement__c();
        if(reimId!='')
        {
            currentReimbursement.id =reimId;
        }
        
        currentReimbursement.Contact_Id__c = currentContact.Id;       
        currentReimbursement.Fuel_Price__c = fuelPrice;
        currentReimbursement.Status__c = 'Pending';
        currentReimbursement.Name = currentContact.Name + ':' + currentMonth(monthValue);
        currentReimbursement.Month__c = currentMonth(monthValue);
        currentReimbursement.Maintenance_and_Tires__c = currentContact.Maintenance_and_Tires__c;
        currentReimbursement.MPG__c = currentContact.MPG__c;
        currentReimbursement.Fixed_Amount__c = currentContact.Fixed_Amount__c; 
        currentReimbursement.Approved_Date__c = null;
        if(monthValue ==0)
        {
            //current Month
            
        }
        else
        {
            // past Month
            currentReimbursement.Fixed_Amount__c = currentContact.Fixed_Amount__c; 
            
        }
        return currentReimbursement;
    }
    public void deActivated(){

        fuelpriceMap = new Map<string,Decimal>();
        listofMonths = new List<String>();
        
        if(System.today().month() == 1)
        {
            listofMonths.add('12-'+String.valueOf(System.today().year()-1));
            listofMonths.add('0'+String.valueOf(System.today().month())+'-'+String.valueOf(System.today().year()));
        }       
        else
        {
            if(System.today().month()<10)
            {
                listofMonths.add('0'+String.valueOf(System.today().month())+'-'+String.valueOf(System.today().year()));
                listofMonths.add('0'+String.valueOf(System.today().month()-1)+'-'+String.valueOf(System.today().year()));  
            }
            else if(System.today().month() == 10)
            {
                listofMonths.add(String.valueOf(System.today().month())+'-'+String.valueOf(System.today().year()));
                listofMonths.add('0'+String.valueOf(System.today().month()-1)+'-'+String.valueOf(System.today().year()));  
            }
            else if(System.today().month() == 11 || System.today().month() == 12)
            {
                listofMonths.add(String.valueOf(System.today().month())+'-'+String.valueOf(System.today().year()));
                listofMonths.add(String.valueOf(System.today().month()-1)+'-'+String.valueOf(System.today().year()));  
            }
                              
        }
        System.debug(listofMonths);
        existingReimbursementMap = new Map<String,Employee_Reimbursement__c>();
        reimbursementList = new List<Employee_Reimbursement__c>();  
        reimbursementListtoUpdate = new List<Employee_Reimbursement__c>();
        contactIds = new List<Id>(); 
       
        for(Gas_Prices__c currentGasprice : [SELECT Fuel_Price__c, Month_State_City__c, Month_Year__c, State__c, City__c FROM Gas_Prices__c WHERE Month_Year__c = : Date.today().addMonths(-1).tostartofmonth()]) 
        {            
            fuelpriceMap.put((currentGasprice.City__c + '-' + currentGasprice.State__c).touppercase(), currentGasprice.Fuel_Price__c);
        } 
    }
}