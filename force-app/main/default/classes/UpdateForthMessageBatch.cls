/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This Batch is use for add 4th Message if not in record else active those message record for display in new UI.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 31 January 2023 | Niraj Sahedani
 */
public class UpdateForthMessageBatch implements Database.Batchable<sObject>{
    public List<Contact> start(Database.BatchableContext bc){
        List<Contact> conList = [SELECT Id,name,Role__c,Activation_Date__c
                                    FROM contact 
                                    WHERE Deactivated_Date__c = NULL 
                                        AND Account.isUsingTriplog__c = true
                                        AND Activation_Date__c != null
                                        AND (Role__c = 'Driver' or Role__c = 'Driver/Manager' or Role__c = 'Driver/Admin')];
        return conList; 
    }

    public void execute(Database.BatchableContext bc, List<Contact> conList) {
        List<String> conIdList = new List<String>();
        List<Message__c> msgListUpdate = new List<Message__c>();
        
        for(Contact con: conList){
            conIdList.add(con.Id);
        }

        for(Message__c msgList : [SELECT Id,
                                        Contacts__c,Notification_Message__c,Unread__c 
                                    FROM Message__c 
                                    WHERE Contacts__c 
                                        IN: conIdList 
                                        AND Notification_Message__c Like '%you could forfeit your fixed amount unless you upload your insurance%' 
                                    WITH SECURITY_ENFORCED]){
                msgList.Unread__c = true;
        }
        if(Schema.sObjectType.Message__c.fields.Unread__c.isUpdateable() && msgListUpdate.size() > 0){
            update msgListUpdate;
        }
    }
    public void finish(Database.BatchableContext bc){}
}