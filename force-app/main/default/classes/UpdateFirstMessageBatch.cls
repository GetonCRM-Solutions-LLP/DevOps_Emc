/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This Batch is use for add 1st Message if not in record else active those message record for display in new UI.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 31 January 2023 | Niraj Sahedani
 */
public  class UpdateFirstMessageBatch implements Database.Batchable<sObject>, Database.Stateful{
    
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

        DateTime dtLastMonth = System.today().addMonths(-1);
        DateTime dtCurrentMonth = System.today();
        // System.debug(dt.format('MMMM'));
        String lastMonth = String.valueOf(dtLastMonth.format('MMMM'));
        String currentMonth = String.valueOf(dtCurrentMonth.format('MMMM'));

        for(Message__c msgList : [SELECT Id,
                                        Contacts__c,Notification_Message__c,Unread__c 
                                    FROM Message__c 
                                    WHERE Contacts__c 
                                        IN: conIdList 
                                        AND Notification_Message__c Like '%Mileage will be automatically synced%']){
                msgList.Unread__c = true;
                if(System.today().day() > 23 ){
                    msgList.Notification_Message__c = 'Mileage will be automatically synced '+currentMonth+' 3 at 11:59 PM PST.';
                }else{
                    msgList.Notification_Message__c = 'Mileage will be automatically synced '+lastMonth+' 3 at 11:59 PM PST.';
                }
                if(msgList != null){
                    msgListUpdate.add(msgList);
                }
        }
        if(msgListUpdate.size() > 0){
            update msgListUpdate;
        }
    }
    public void finish(Database.BatchableContext bc){}
}