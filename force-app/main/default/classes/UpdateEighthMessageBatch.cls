public class UpdateEighthMessageBatch implements Database.Batchable<sObject>{
    public UpdateEighthMessageBatch() {}
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
        System.debug('conList: '+conList);
        List<String> conIdList = new List<String>();
        List<Message__c> msgListUpdate = new List<Message__c>();
        for(Contact con: conList){
            conIdList.add(con.Id);
        }

        for(Message__c msgList : [Select Id,Contacts__c,Notification_Message__c,Unread__c from Message__c where Contacts__c IN: conIdList AND Notification_Message__c LIKE '%Thanks for uploading your insurance, we will evaluate your insurance shortly%']){
            // if(msgList.Notification_Message__c.contains('miles that were not yet approved')){
                msgList.Unread__c = false;
                msgList.Notification_Message__c = 'Thanks for uploading your insurance, we will evaluate your insurance shortly.';
                if(msgList != null){
                    msgListUpdate.add(msgList);
                }
            // }
        }
        if(msgListUpdate.size() > 0){
            update msgListUpdate;
        }
    }
    public void finish(Database.BatchableContext bc){}
}