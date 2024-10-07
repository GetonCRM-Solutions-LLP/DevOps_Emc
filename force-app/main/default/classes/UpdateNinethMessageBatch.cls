public class UpdateNinethMessageBatch implements Database.Batchable<sObject>{
    public UpdateNinethMessageBatch() {}
    public List<Contact> start(Database.BatchableContext bc){
        List<Contact> conList = [SELECT Id,name,Role__c,Activation_Date__c
                                    FROM contact 
                                    WHERE Deactivated_Date__c = NULL 
                                        AND Account.isUsingTriplog__c = true
                                        AND Activation_Date__c != null
                                        AND Role__c = 'Manager'];
        return conList; 
    }
    public void execute(Database.BatchableContext bc, List<Contact> conList) {
        List<String> conIdList = new List<String>();
        List<Message__c> msgListUpdate = new List<Message__c>();
        for(Contact con: conList){
            conIdList.add(con.Id);
        }

        for(Message__c msgList : [Select Id,Contacts__c,Notification_Message__c,Unread__c from Message__c where Contacts__c IN: conIdList]){
            if(msgList.Notification_Message__c.contains('In 3 days, your team’s mileage will be ready for approval')){
                msgList.Unread__c = true;
                if(msgList != null){
                    msgListUpdate.add(msgList);
                }
            }
        }
        if(msgListUpdate.size() > 0){
            update msgListUpdate;
        }
    }
    public void finish(Database.BatchableContext bc){}
}