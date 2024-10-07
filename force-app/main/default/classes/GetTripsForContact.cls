public with sharing class GetTripsForContact {
    public String urltoredirect {get;set;}
    public Contact cont {get;set;}
    public String apiToken {get; set;}
    public List<Id> contactList;
    public GetTripsForContact(ApexPages.StandardController controller) {
        cont = (Contact)controller.getRecord();
        contactList = new List<Id>();
        system.debug('cont---' + cont);
        urltoredirect ='https://'+ URL.getSalesforceBaseUrl().getHost()+'/'+ cont.id;
    }
    public pageReference getTTripCall() {
        
        List<Contact> conRecord = [Select Id, Name, Triplog_Status__c,Account.Triplog_API__c, Account.Triplog_Status__c From Contact where Id =: cont.Id];
        
        apiToken = conRecord[0].Account.Triplog_API__c;
        system.debug('apiToken---' + apiToken);

        for(Contact con : conRecord){
            contactList.add(con.Id);
        }
        System.debug('contactList:---'+contactList.size()+'---'+contactList);
        if(apiToken != null && apiToken != '') { 
            System.debug('conRecord:---'+conRecord[0].Account.Triplog_Status__c);
            GetTripsForContact(contactList , conRecord[0].Account.Triplog_Status__c);
        }
        return null;
    } 
    
    public void GetTripsForContact(List<Id> con, String tripStatus) {
        System.debug('+++++++++++++++++++++++GetTripsForAcc'+con+'---'+tripStatus);
        GetTripBatchClass getBtc = new GetTripBatchClass(con, tripStatus);
        Database.executeBatch(getBtc,1);
    }
    
    public pagereference backtoContact() {
        pagereference pg = new pagereference(urltoredirect);
        return pg;
    } 
}