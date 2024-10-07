/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : Wrapper class for TrueDialogContact.
                1)generateTrueDialogContactReqBody accept the Salesforce Contact object as parameter and 
                 return response body in JSON format
               2) parse method take JSON string and return as a TrueDialogContact Wrapper Object.
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/

public with sharing class TrueDialogContact {
    

    public String phoneNumber;
    public String email;
    public List<Subscriptions> subscriptions;
    public List<Attributes> attributes;
    public String id;

	public class Subscriptions {
		public Integer subscriptionId;
		public Boolean smsEnabled;
		public Boolean mmsEnabled;
		public Boolean emailEnabled;
		public Boolean voiceEnabled;
	}

	public class Attributes {
		public Integer id;
		public String name;
		public String value;
	}
  
    /** 
    * ********************************************************
    * This method is test data for create IRS_Mileage_Rate__c.
    * ********************************************************
    */
    public static string generateTrueDialogContactReqBody(Contact cont){
        
        String contactName='';
        if(cont.firstName!=null){
            contactName = contactName+cont.firstName;    
        }
        if(cont.lastName!=null){
            contactName = contactName+' '+cont.lastName; 
        }

        TrueDialog_Keys__c tdKeys = TrueDialog_Keys__c.getValues('TrueDialogKeys');

        TrueDialogContact trueDialogContact = new TrueDialogContact();

        List<TrueDialogContact.Subscriptions> subscriptionList = new   List<TrueDialogContact.Subscriptions>();  
        TrueDialogContact.Subscriptions subscription = new TrueDialogContact.Subscriptions();
        subscription.subscriptionId = Integer.valueOf(tdKeys.Subscription_Id__c); //22639 
        
        subscription.emailEnabled = false;
        subscription.voiceEnabled = false;
       
        if(cont.TrueDialog_Contact_Id__c!=null){  
            if(cont.Deactivated_Date__c == null){
                subscription.smsEnabled = cont.TrueDialog_SMS_Enabled__c;
                subscription.mmsEnabled = cont.TrueDialog_MMS_Enabled__c;
            }else{
                subscription.smsEnabled = false;
                subscription.mmsEnabled = false;
            }
          
        }else{
            subscription.smsEnabled = true;
            subscription.mmsEnabled = true;         
        }
        subscriptionList.add(subscription);

        List<TrueDialogContact.Attributes> attributeList = new   List<TrueDialogContact.Attributes>();
        TrueDialogContact.Attributes attribute = new TrueDialogContact.Attributes();
        attribute.id = 1;      
        attribute.name = contactName;
        attribute.value = contactName;
        attributeList.add(attribute);
         
        trueDialogContact.phoneNumber = '+1'+cont.MobilePhone;
        trueDialogContact.email = cont.Email;
        trueDialogContact.subscriptions = subscriptionList;
        trueDialogContact.attributes = attributeList;

        return JSON.serialize(trueDialogContact);
       
    }

       /** 
    * ********************************************************
    * Parse JSON Response  to TrueDialogCOntact 
    * ********************************************************
    */
    public static TrueDialogContact parse(String json){
		return (TrueDialogContact) System.JSON.deserialize(json, TrueDialogContact.class);
	}
 
}