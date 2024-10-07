/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This Batch is used to add a 3rd Message if not present in the record or activate those message records for display in the new UI.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 31 January 2023 | Niraj Sahedani
 */
public class UpdateThirdMessageBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Role__c, Activation_Date__c
            FROM Contact
            WHERE Deactivated_Date__c = NULL 
                AND Account.isUsingTriplog__c = true
                AND Activation_Date__c != null
                AND (Role__c = 'Driver' or Role__c = 'Driver/Manager' or Role__c = 'Driver/Admin')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Contact> conList) {
        List<Message__c> msgListToCreate = new List<Message__c>();
        List<Id> conIdList = new List<Id>();
        
        for (Contact con : conList) {
            conIdList.add(con.Id);
        }

        List<Message__c> msgListDelete = [
            SELECT Id, Contacts__c, Notification_Message__c, Unread__c
            FROM Message__c
            WHERE Contacts__c IN :conIdList
                AND (Notification_Message__c LIKE '%forget to upload your insurance dec page next week%'
                OR Notification_Message__c LIKE '%Please upload your most recent insurance declaration%')
            WITH SECURITY_ENFORCED
        ];

        if (Schema.sObjectType.Message__c.isDeletable() && !msgListDelete.isEmpty()) {
            delete msgListDelete;
        }

        String currentMonth = DateTime.now().format('MMMM');

        for (Contact objContact : conList) {
            Message__c objMessage = new Message__c(
                Contacts__c = objContact.Id,
                Unread__c = true
            );

            if (currentMonth == 'January') {
                objMessage.Notification_Message__c = 'forget to upload your insurance dec page next week';
            } else if (currentMonth == 'June') {
                objMessage.Notification_Message__c = 'Please upload your most recent insurance declaration';
            } else {
                continue; // Skip if the current month is not January or June
            }

            msgListToCreate.add(objMessage);
        }

        if (!msgListToCreate.isEmpty()) {
            insert msgListToCreate;
        }
    }

    public void finish(Database.BatchableContext bc) {}
}