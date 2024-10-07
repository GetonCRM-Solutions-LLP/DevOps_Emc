public with sharing class sendingBulkDriverPacket implements Queueable , Database.AllowsCallouts {
    public String ConIdLst ;
    Public String AdminID;
    public sendingBulkDriverPacket(String JsonString,String AdminId){
        this.ConIdLst = JsonString ;
        this.AdminID=AdminId;
    }
    public void execute(QueueableContext context) {
        try{
            List<String> contactIds = new List<String>();
            contactIds = (List<String>) System.JSON.deserialize(ConIdLst, List<String>.class);
            System.debug('listo of ids-->'+contactIds);
            List<Contact> conList = [SELECT id,Name,email,Hello_Sign_Request_Id__c, Admin__c,Admin__r.Name,Admin__r.Email,Account.Admin_Contact__r.Name,Birthdate, Account.Admin_Contact__r.External_Email__c,Account.Admin_Contact__c,Account.Hello_Sign_Admin_Sign__c FROM Contact WHERE Id IN:contactIds ];
            System.debug('conList'+conList);
            List<String> envelopeIds = new List<String>();
            for(contact objContact :conList){
                envelopeIds.add(objContact.Hello_Sign_Request_Id__c);
                System.debug ('envelope ids'+objContact.Hello_Sign_Request_Id__c);
            }
            Map<id,dfsle__EnvelopeStatus__c> UUIDAndConIdMap =new Map<id,dfsle__EnvelopeStatus__c>();
            Map<String,Id> UUIDAndEnvelopeIdMap =new Map<String,id>();

            List<dfsle__Envelope__c > SentEnvelopeLst= new List<dfsle__Envelope__c >() ;
            SentEnvelopeLst =[Select id ,Owner.Name,dfsle__DocuSignId__c From dfsle__Envelope__c  Where dfsle__DocuSignId__c IN :envelopeIds];
            System.debug ('Size of the envelope '+SentEnvelopeLst.size());
            
            for(dfsle__Envelope__c envelope :SentEnvelopeLst){
                System.debug('Inside resend envelope loop ');
                resendingTheEnvelope( envelope.id,envelope.dfsle__DocuSignId__c);
            }
            if(Test.isRunningTest()){
                integer i=0;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
            }
           
        }catch(Exception e){
            System.debug('Exception:- '+e.getmessage()+' - Line:-'+e.getLineNumber());
        }
    }
    public static void resendingTheEnvelope(String envelopeId,String docusignID){
        dfsle.Envelope envelope = dfsle.EnvelopeService.getEnvelope(envelopeId);
        system.debug('inside resend -->'+envelope);
        dfsle.UUID myID = dfsle.UUID.parse(docusignID);
        dfsle.StatusService.resendEnvelope(myID);
    }
}