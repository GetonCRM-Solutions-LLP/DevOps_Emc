public class TrueDIalogVFPageController {

  public String currentRecordId {get;set;}
  public Integer contactCount {get;set;}
  public  List<Contact> lstContact{get;set;}
  public Account account{get;set;}
  

  public Boolean hideSubmitButton {get;set;}

  public TrueDIalogVFPageController(ApexPages.StandardController stdController) {
    
    currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
      System.debug('Account: '+currentRecordId);
    account = [Select id,True_Dialog__c from Account where Id =: currentRecordId LIMIT 1];
              System.debug('Account: '+account);
            
    lstContact = [Select id,Account.True_Dialog__c,MobilePhone,TrueDialog_Contact_Id__c FROM Contact
                        WHERE MobilePhone !=null and Account.True_Dialog__c=true and AccountId =:currentRecordId
                        and Deactivated_Date__c=null and TrueDialog_Contact_Id__c = null ];
    System.debug('List Contact '+lstContact);
    contactCount = lstContact.size();

    System.debug('currentRecordId:'+currentRecordId);
  }

  public String  getPageRecord() { 
      return '/'+currentRecordId;
  }

  public void onSubmit() {

    hideSubmitButton =true;
    
    Set<Id> conSetId = new Set<Id>();
    System.debug('Contact List:'+lstContact);
    
    for(Contact c : lstContact){
      conSetId.add(c.Id);
    }

    TrueDialogContactAPI tdContactApi = new TrueDialogContactAPI(conSetId);
    Database.executeBatch(tdContactApi,5);
    // Do it here
  }
  
}