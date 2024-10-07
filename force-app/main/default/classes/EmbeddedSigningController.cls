/**
 * @description       : this class contains the method which will send the document for the signing when initiated
 * @author            : Khuman Singh Bhadoriya
 * @last modified on  : 11-15-2023
 * @last modified by  : Khuman Singh Bhadoriya
**/
public class EmbeddedSigningController {
  @AuraEnabled
  public static String getEmbeddedSigningUrl(String envId, String url) {
      Url mySigningUrl = dfsle.SigningService.getEmbeddedSigningUrl(dfsle.UUID.parse(envId),new URL(url));
      return mySigningUrl.toExternalForm();
  }
  @AuraEnabled
  public static String sendEnvelope(Id recordId) {
    Id mySourceId = recordId; // The ID of the initiating Salesforce object
    List<Contact> contactList = [Select id,Role__c,AccountId,Name,email,Hello_Sign_Request_Id__c,Hello_Sign_Status__c, Admin__c,Admin__r.Name,Admin__r.Email,Account.Admin_Contact__r.Name,Birthdate, Account.Admin_Contact__r.External_Email__c,Account.Admin_Contact__c,Account.Hello_Sign_Admin_Sign__c FROM contact WHERE Id =: mySourceId AND Role__c  in ('Driver','Driver/Manager','Driver/Admin') limit 1];
    List<dfsle__EnvelopeStatus__c> SentEnvelopeLst= new List<dfsle__EnvelopeStatus__c>() ;
    
    if(contactList[0].Hello_Sign_Request_Id__c != null && contactList[0].Hello_Sign_Request_Id__c.contains('-')){
          
      SentEnvelopeLst =[Select id ,dfsle__Status__c , dfsle__Contact__r.Name,dfsle__EmailSubject__c From dfsle__EnvelopeStatus__c Where dfsle__DocuSignId__c =: contactList[0].Hello_Sign_Request_Id__c And dfsle__Status__c!='Voided' limit 1];
      if(SentEnvelopeLst.size()>0){
        return String.valueOf(contactList[0].Hello_Sign_Request_Id__c);
      }
    }
    // Create an empty envelope and add a Salesforce Document and embedded signer  recipient
    // The embedded signer will be the current user with sequence and routing order 1 and role "Signer 1" by default
    dfsle.Envelope dsEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));

    List<dfsle.Recipient> recipientList = new List<dfsle.Recipient>() ;
    //merge field for tags to writeback in the salesforce
    dfsle.Tab.MergeField LicenseMergeField = new dfsle.Tab.MergeField ('Contact.Driver_License_Number__c',null,null,true,false);
    dfsle.Tab.MergeField StateMergeField = new dfsle.Tab.MergeField ('Contact.Driver_License_State__c',null,null,true,false);
    dfsle.Tab.MergeField DOB = new dfsle.Tab.MergeField ('Contact.Birthdate',null,null,true,false);
    
    //setting up tags for the pdf
    dfsle.Tab DriverLicense = new dfsle.TextTab().withMergeField(LicenseMergeField).withReadOnly(false).withRequired(true).withAnchor(new dfsle.Tab.Anchor('Driver’s License Number',false,false,'right',true, true,'pixels',0, -5)).withDataLabel('Driver License');
    dfsle.Tab EmployeeLicenceState = new dfsle.TextTab().withMergeField(StateMergeField).withReadOnly(false).withRequired(true).withAnchor(new dfsle.Tab.Anchor('Employee’s License State',false,false,'right',true, true,'pixels',0, -5)).withDataLabel('Driver State');
    dfsle.Tab DateOfBirth = new dfsle.DateTab().withMergeField(DOB).withReadOnly(false).withRequired(true).withAnchor(new dfsle.Tab.Anchor('Date of Birth',false,false,'right',true, true,'pixels',0, -5)).withDataLabel('BirthDate');
    dfsle.Tab employeeSignTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(new dfsle.Tab.Anchor('Employee’s Signature',false,false,'right',true,true,'pixels',20,0));
    dfsle.Tab employeeNameTab = new dfsle.FullNameTab().withFormatting(new dfsle.Tab.Formatting('default','default',12,false,false,false,false,false)).withAnchor(new dfsle.Tab.Anchor('Employee Name',false,false,'right',true,true,'pixels',15,-5));
    dfsle.Tab employeeSignedDateTab = new dfsle.DateSignedTab().withFormatting(new dfsle.Tab.Formatting('default','default',12,false,false,false,false,false)).withAnchor(new dfsle.Tab.Anchor('Employee Signed Date',false,false,'right',true,true,'pixels',15,-5));
    dfsle.Tab CompanySignTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(new dfsle.Tab.Anchor('Company Signature',false,false,'right',true,true,'pixels',20,0));
    dfsle.Tab comapnySignedDateTab = new dfsle.DateSignedTab().withFormatting(new dfsle.Tab.Formatting('default','default',12,false,false,false,false,false)).withAnchor(new dfsle.Tab.Anchor('Company Signed Date',false,false,'right',true,true,'pixels',15,-5));
    
    dfsle.Recipient myRecipient1 = dfsle.Recipient.newEmbeddedSigner().withTabs(new List<dfsle.Tab> {DateOfBirth,DriverLicense,EmployeeLicenceState,employeeSignedDateTab,employeeNameTab,employeeSignTab,DateOfBirth });
    recipientList.add(myRecipient1);
    //second admin reciepient
    String adminName;
    String adminEmail;
    String AdminId;
    Hello_Sign__c adminDetails = Hello_Sign__c.getValues(Constants.apiOwnerName);
    if(contactList[0].Admin__c != null){
        adminName = contactList[0].Admin__r?.Name;
        adminEmail = contactList[0].Admin__r?.Email;
        AdminId = contactList[0].Admin__c;
    } else if( contactList[0].Account.Admin_Contact__c != null){
        adminName = contactList[0].Account.Admin_Contact__r.Name != null ? contactList[0].Account.Admin_Contact__r.Name : null;
        adminEmail = contactList[0].Account.Admin_Contact__r.External_Email__c != null ? contactList[0].Account.Admin_Contact__r.External_Email__c : null;
        AdminId = contactList[0].Account.Admin_Contact__r.Id;
    } else {
        adminName  = adminDetails.Admin_Name__c;
        adminEmail = adminDetails.Admin_Email__c;
        adminId    = adminDetails.Id__c;
    }
    if(contactList[0].Account.Hello_Sign_Admin_Sign__c == true){

        dfsle.Recipient myRecipient2 = dfsle.Recipient.fromSource(adminName, adminEmail, null, 'Signer 2', new dfsle.Entity(adminId)).withTabs(new List<dfsle.Tab> {comapnySignedDateTab,CompanySignTab});
        recipientList.add(myRecipient2);
    }
    dsEnvelope = dsEnvelope.withRecipients(recipientList);
    //setting document
    ContentDocumentLink contentDocLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  =: mySourceId AND ContentDocument.LatestPublishedVersion.Title =: Constants.driverAgreement Order BY SystemModstamp  Desc limit 1];
    System.debug('inside SendEnvelope  '+contentDocLink);
    ContentVersion file = [SELECT Title ,VersionData,dfsle__GeneratedFileFormat__c, dfsle__GeneratedFileName__c, dfsle__GeneratedFileSuffix__c, dfsle__Rule__c, FileExtension, FileType,ContentDocumentId FROM ContentVersion WHERE IsLatest = TRUE  and ContentDocumentId=:contentDocLink.ContentDocumentId];
    dfsle.Document myDocument =dfsle.Document.fromFile(file);
    Set<Id> cvId = new Set<Id> {contentDocLink.ContentDocumentId };
    system.debug('contentdocument-->'+myDocument);

    // Add document to the Envelope
    dsEnvelope = dsEnvelope.withDocuments(new list<dfsle.Document>{myDocument});
    // Send the envelope.
    if(!Test.isRunningTest()){
      dsEnvelope = dfsle.EnvelopeService.sendEnvelope( dsEnvelope, true);
    }
    
    contactList[0].Hello_Sign_Request_Id__c=String.valueOf(dsEnvelope.docuSignId);
    contactList[0].Document_Sent_Date__c=System.today();
    if(!Test.isRunningTest()){
      update contactList;
    }
    // Return string value of DocuSign envelope ID
    return String.valueOf(dsEnvelope.docuSignId);
  }    
}