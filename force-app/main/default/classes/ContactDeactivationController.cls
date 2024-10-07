public with sharing class ContactDeactivationController
{
    Public Contact obj_contact {get;set;}
    public String urltoredirect {get;set;}
    public ContactDeactivationController()
    {
    }
    public ContactDeactivationController(ApexPages.StandardController controller)
    {
       obj_contact = (Contact)controller.getRecord();
       urltoredirect ='https://'+ URL.getSalesforceBaseUrl().getHost()+'/'+ obj_contact.id;
    }
    public pagereference calldeactivebatch()
    {
        DeActivatedUserBatch batchMileage = new DeActivatedUserBatch(obj_contact.id);
        Database.executeBatch(batchMileage, 1);
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Deactivation in Progress.');
        ApexPages.addMessage(myMsg);
        
        return null;
    }
    public pagereference backtocontact()
    {
        pagereference pg = new pagereference(urltoredirect);
        return pg;
    }
}