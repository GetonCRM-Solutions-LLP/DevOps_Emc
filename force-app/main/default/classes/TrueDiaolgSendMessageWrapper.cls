/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description :  Wrapper for SendMessage Response Body.Method Contains for:
                1)generateSendMessageReqBody - Accepting contact Id and Message as a parameter and 
                                                return request body in JSON. 
                2)parse - Accepting ResponseBody in JSON as parameter and return TrueDiaolgSendMessageWrapper Object.
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/

public with sharing class TrueDiaolgSendMessageWrapper {

    public string id;
    public String[] channels;
	public String[] targets;
	public String message;
	public boolean execute;
    public String mediaId;

    /** 
    * ********************************************************
    * Return Send Message Body
    * ********************************************************
    */
    public static string generateSendMessageReqBody(String contactId,String message){

        TrueDialog_Keys__c tdKeys =TrueDialog_Keys__c.getValues('TrueDialogKeys');

        TrueDiaolgSendMessageWrapper trueDialogSendMessage = new TrueDiaolgSendMessageWrapper();
        trueDialogSendMessage.message = message;
        trueDialogSendMessage.execute = true;

        List<String> lstContactId = new List<String>();
        
        Contact contact = [Select Id,TrueDialog_Contact_Id__c From Contact Where Id=:contactId];
        lstContactId.add(contact.TrueDialog_Contact_Id__c);
        
        trueDialogSendMessage.targets = lstContactId;

        List<String> lstChannels = new List<String>();
        lstChannels.add(tdKeys.Channel_Id__c);
        trueDialogSendMessage.channels = lstChannels;

        return JSON.serialize(trueDialogSendMessage);

    }

    /** 
    * ********************************************************
    * Return Send Message Body
    * ********************************************************
    */
    public static string generateBulkSendMessageReqBody(List<String> trueDialogContactId,String message){

        TrueDialog_Keys__c tdKeys =TrueDialog_Keys__c.getValues('TrueDialogKeys');

        TrueDiaolgSendMessageWrapper trueDialogSendMessage = new TrueDiaolgSendMessageWrapper();
        trueDialogSendMessage.message = message;
        trueDialogSendMessage.execute = true;     
        trueDialogSendMessage.targets = trueDialogContactId;

        List<String> lstChannels = new List<String>();
        lstChannels.add(tdKeys.Channel_Id__c);
        trueDialogSendMessage.channels = lstChannels;

        return JSON.serialize(trueDialogSendMessage);

    }

        /** 
    * ********************************************************
    * Parse Json Response in TrueDialogSendMessage
    * ********************************************************
    */

	public static TrueDiaolgSendMessageWrapper parse(String json){
		return (TrueDiaolgSendMessageWrapper) System.JSON.deserialize(json, TrueDiaolgSendMessageWrapper.class);
	}
}