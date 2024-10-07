public class UpdateTripIdController {
    public string accId {get;set;}
    public Account acc {get;set;}
    public string errorMessage {get;set;}
    public Map<String,Contact> contactMap{get;set;}
    public UpdateTripIdController(ApexPages.StandardController stdController) {     
        accId = ApexPages.currentPage().getParameters().get('id');
        if (!Test.isRunningTest()){
            stdController.addFields(new List<String>{'Triplog_API__c', 'isUsingTriplog__c'}); 
        }       
        acc = (Account)stdController.getRecord();
       
		if(acc.Triplog_API__c == null && acc.isUsingTriplog__c == false){
            errorMessage = System.label.UpdateTripIdError;
        
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errorMessage));
        }
    }

    public pagereference backMethod()
    {
        Pagereference pg =  new Pagereference('/'+accId);        
        pg.setRedirect(true);
        return pg;
    }

    public void tripUserUpdatebatch()
    {
        contactMap = new Map<String,Contact>();
        List<Contact> conList = new List<Contact>();
        for(Contact currentContact : [Select id,Name,Triplog_UserID__c,External_Email__c,Deactivated_Date__c From Contact Where Account.id =: accId and (Role__c = 'Driver' or Role__c = 'Driver/Manager'or Role__c =: StaticValues.roleAdminDriver )])
        {
            contactMap.put(currentContact.External_Email__c.toLowerCase(),currentContact);
        }

        if(acc.Triplog_API__c != null && acc.isUsingTriplog__c == true && contactMap.size()>0){            
            TriplogUserIdUpdateBatch tripUserUpdate = new TriplogUserIdUpdateBatch(accId,acc.Triplog_API__c,contactMap);
            database.executebatch(tripUserUpdate,1);                      
        }       
    }

    public void tripUserUpdatebatchNew(){
        // List<Id> accountId = new List<Id>();
        // Set<String> accIdForContact = new Set<String>();
       /* contactMap = new Map<String,Contact>();

        // List<Contact> conList = new List<Contact>();

        // for(Account acc : [select Id, name,isUsingTriplog__c from Account where isUsingTriplog__c = true ] ){
        //     accountId.add(acc.Id);
        // }

        for(Contact currentContact : [Select id,Name,Triplog_UserID__c,External_Email__c,Deactivated_Date__c,Account.id,Account.Triplog_API__c,Account.Name From Contact Where (Role__c = 'Driver' or Role__c = 'Driver/Manager'or Role__c =: StaticValues.roleAdminDriver ) and Account.Triplog_API__c != null and Account.isUsingTriplog__c = true])
        {
            contactMap.put(currentContact.External_Email__c.toLowerCase(),currentContact);
        }
        if(contactMap.size()>0){   
            System.debug(contactMap.size());         
            TriplogUserIdUpdateBatch tripUserUpdate = new TriplogUserIdUpdateBatch(accId,acc.Triplog_API__c,contactMap);
            database.executebatch(tripUserUpdate,1);                      
        }   */
        
        List<Account> accList = [Select Id,Name,Triplog_API__c,isUsingTriplog__c,(Select id,Name,Triplog_UserID__c,External_Email__c,Deactivated_Date__c From Contacts Where (Role__c = 'Driver' or Role__c = 'Driver/Manager'or Role__c =: StaticValues.roleAdminDriver ) and Deactivated_Date__c = null ) From Account where Triplog_API__c != null and isUsingTriplog__c = true];
        for(Account a : accList){
            contactMap = new Map<String,Contact>();
            for(Contact con : a.Contacts){  
                contactMap.put(con.External_Email__c.toLowerCase(),con);    
            }
            TriplogUserIdUpdateBatch tripUserUpdate = new TriplogUserIdUpdateBatch(a.Id,a.Triplog_API__c,contactMap);
            database.executebatch(tripUserUpdate);  
        }
    }
}