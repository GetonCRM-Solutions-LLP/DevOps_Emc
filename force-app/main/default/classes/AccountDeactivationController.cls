public with sharing class AccountDeactivationController
{
    Public Account acct {get;set;}
    public String urltoredirect {get;set;}
    public AccountDeactivationController()
    {
    }
    public AccountDeactivationController(ApexPages.StandardController controller)
    {
       acct = (Account)controller.getRecord();
       urltoredirect ='https://'+ URL.getSalesforceBaseUrl().getHost()+'/'+ acct.id;
    }
    public pagereference calldeactivebatch()
    {
         DeActivatedUserBatch batchMileage = new DeActivatedUserBatch(String.valueof(acct.id));
         Database.executeBatch(batchMileage, 1);
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Deactivation in Progress.');
        ApexPages.addMessage(myMsg);
        
        return null;
    }
     public pagereference backtoAccount()
    {
        pagereference pg = new pagereference(urltoredirect);
        return pg;
    }
}