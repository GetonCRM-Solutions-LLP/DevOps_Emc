global with sharing class GetTripsForAccount {
    public String urltoredirect {get;set;}
    Public Account acct {get;set;}
    public String apiToken {get; set;}
    public GetTripsForAccount()
    {
        
    }
  
    public GetTripsForAccount(ApexPages.StandardController controller)
    {
       acct = (Account)controller.getRecord();
       system.debug('acct---' + acct);
       urltoredirect ='https://'+ URL.getSalesforceBaseUrl().getHost()+'/'+ acct.id;
    }
    
    public pageReference getTTripCall() {
        
        Account acctRecord = [Select Id, Name, Triplog_API__c, Triplog_Status__c From Account where Id =: acct.Id];
        
        apiToken = acctRecord.Triplog_API__c;
        system.debug('apiToken---' + apiToken);
        if(apiToken != null && apiToken != '') { 
            GetTripsForAcc(acctRecord.Id , acctRecord.Triplog_Status__c);
        }
        return null;
    } 
    
    public void GetTripsForAcc(Id acc, String tripStatus) {
    System.debug('+++++++++++++++++++++++GetTripsForAcc');
    GetTripBatchClass getBtc = new GetTripBatchClass(acc, tripStatus);
            Database.executeBatch(getBtc,1);
       /* Batch_Configuration__c batchConfig = new Batch_Configuration__c();
        batchConfig = [Select Get_Trip_Batch_Class_for_Account__c From Batch_Configuration__c];
        if (batchConfig.Get_Trip_Batch_Class_for_Account__c == true ){
            batchConfig.Get_Trip_Batch_Class_for_Account__c = false;
            update batchConfig;
            GetTripBatchClass getBtc = new GetTripBatchClass(acc, tripStatus);
            Database.executeBatch(getBtc,1);
            
        }*/
    }
    
    public pagereference backtoAccount() {
        pagereference pg = new pagereference(urltoredirect);
        return pg;
    } 
}