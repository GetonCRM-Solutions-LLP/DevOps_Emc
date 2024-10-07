@isTest
public with sharing class DocuSignTestClass {
    public DocuSignTestClass() {

    }
    @isTest
    public static void test() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        

        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,1);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Hello_Sign__c adminDetails =  new Hello_Sign__c();
        adminDetails.TestMode__c=true;
        adminDetails.Name='Hello_Sign';
        adminDetails.Id__c='0033r00003vph51';
        adminDetails.Admin_Name__c='Khuman singh';
        adminDetails.Admin_Email__c='khuman.bhadoriya@getoncrm.com';
        insert adminDetails;


        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        List<Contact> conList1 = new List<Contact>();
        List<Contact> adminConList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Vehicle_Types__c=vehicleObj.name;
            acc.True_Dialog__c = true;
            acc.Vehicle_Types__c = vehicleObj.Name;
            acc.Hello_Sign_Admin_Sign__c=true;
            Insert acc;
            Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            adminConList = TestDataFactory.createDriverContact(false, acc.Id, 'Admin', vehicleObj.Name, 'test1.email', 1);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            conList1 = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            conList1[0].Admin__c=adminConList[0].Id;
            conList1[0].Hello_Sign_Request_Id__c=String.valueOf(dfsle.UUID.randomUUID());
            insert conList1;
            //userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
       	dfsle__EnvelopeStatus__c envelopeStatusObj = new dfsle__EnvelopeStatus__c(dfsle__DocuSignId__c =conList1[0].Hello_Sign_Request_Id__c,dfsle__SenderName__c='vatsal bhalani',dfsle__SenderEmail__c='vatsal.bhalani@getoncrm.com',dfsle__EmailSubject__c='ocuments for your DocuSign Signature',dfsle__Status__c='Sent',dfsle__Contact__c=conList1[0].Id);
        insert envelopeStatusObj;
        ContentVersion versionObj = new ContentVersion();
        versionObj.versionData = Blob.valueOf('test document');
        versionObj.title = 'Driver Agreement';
        versionObj.pathOnClient ='Driver Agreement.pdf';
        versionObj.FirstPublishLocationId = conList[0].Id; 
        insert versionObj;
         ContentVersion versionObj1 = new ContentVersion();
         versionObj1.versionData = Blob.valueOf('test document');
         versionObj1.title = 'Driver Agreement';
         versionObj1.pathOnClient ='Driver Agreement.pdf';
         versionObj1.FirstPublishLocationId = conList1[0].Id; 
         insert versionObj1;
        System.runAs(dfsle.UserMock.createDocuSignSender()) {
         dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(conList[0].Id))
         .withDocuments(new List<dfsle.Document> { dfsle.Document.fromTemplate(dfsle.UUID.randomUUID(),'test template')})
         .withRecipients(new List<dfsle.Recipient> {dfsle.Recipient.fromSource(conList[0].FirstName + ' ' + conList[0].LastName,conList[0].Email,conList[0].Phone,'Signer 1',new dfsle.Entity(conList[0].Id))});

         System.debug('debug 101-->'+myEnvelope);
         //conlist[0].Hello_Sign_Request_Id__c=String.valueOf(myEnvelope.docuSignId);
		 //update conlist;
		List<Id> conListID =new List<Id>();
        conListID.add(conList1[0].Id);
        String JsonString=JSON.serialize(conListID);
            
        Test.startTest();
        DocuSignStatusTriggerHandler.handleOrderComplete(conList[0].Id);
        SendEnvelopeFromTriggerController.sendEnvelope(conList1[0].Id);
         EmbeddedSigningController.sendEnvelope(conList[0].Id);
         EmbeddedSigningController.sendEnvelope(conList1[0].Id);
         //EmbeddedSigningController.getEmbeddedSigningUrl(EmbeddedSigningController.sendEnvelope(conList1[0].Id),'https://developers.docusign.com');
         sendingBulkDriverPacket DocuSign = new sendingBulkDriverPacket(JsonString,adminConList[0].Id);
         System.enqueueJob(DocuSign);
         //sendingBulkDriverPacket.resendingTheEnvelope(myEnvelope.id,String.valueOf(dfsle.UUID.randomUUID()));
         
        Test.stopTest();
    }
    }
    
}