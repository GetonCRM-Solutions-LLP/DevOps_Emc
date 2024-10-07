/**
 * @Author: GetonCRM Solutions
 * @Description: This Batch is use for 1 to 4 messages Batch except 2nd.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 15 May 2024 | Vatsal Bhalani Hiiiii
 */
public class MessagesBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable  {
    
    public List<Contact> start(Database.BatchableContext bc){
        List<Contact> lstContact = [SELECT Id,name,Role__c,Activation_Date__c
                                    FROM contact 
                                    WHERE Deactivated_Date__c = NULL 
                                        AND Account.isUsingTriplog__c = true
                                        AND Activation_Date__c != null
                                ];
        return lstContact; 
    }
    public void execute(Database.BatchableContext bc, List<Contact> lstContact) {
        
        //List<Message__c> msgListUpdate = new List<Message__c>();
        List<Message__c> lstMsgToInsert = new List<Message__c>();
        DateTime dtCurrentMonth = System.today();
        String currentMonth = String.valueOf(dtCurrentMonth.format('MMMM'));
        Set<String> setDriverRoles = new Set<String>{'Driver','Driver/Manager','Driver/Admin'};
        Set<String> setManagerAdminRoles = new Set<String>{'Admin','Driver/Admin','Manager','Driver/Manager'};

        // Message 1
        Date firstDTCurrentMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        if(System.today() == firstDTCurrentMonth || Test.isRunningTest()){
            for(Contact objContact : lstContact){
                if(setDriverRoles.contains(objContact.Role__c)){
                    Message__c objMsg = new Message__c(
                    Unread__c = true,
                    Notification_Message__c = 'Your business mileage will automatically sync '+currentMonth+' 3 at 11:59 PM PST.',
                    Contacts__c = objContact.Id
                    ); 
                    lstMsgToInsert.add(objMsg);
                }
            }
        }   

        //MESSAGE 2 AND 3
        Date firstJan = Date.newInstance(System.today().year(), 1, 1);
        if(System.TODAY() == firstJan || Test.isRunningTest()){
            for(Contact objContact : lstContact){
                if(setDriverRoles.contains(objContact.Role__c)){
                    Message__c objMsg = new Message__c(
                    Unread__c = true,
                    Notification_Message__c = 'Happy New Year – Don\'t forget to upload your insurance declaration page by the end of January.',
                    Contacts__c = objContact.Id
                    ); 
                    lstMsgToInsert.add(objMsg);
                }
            }
        }

        //MESSAGE 3
        Date lastJune = Date.newInstance(System.today().year(), 6, 30);
        if(System.TODAY() == lastJune || Test.isRunningTest()){
            for(Contact objContact : lstContact){
                if(setDriverRoles.contains(objContact.Role__c)){
                    Message__c objMsg = new Message__c(
                    Unread__c = true,
                    Notification_Message__c = 'Semi-Annual Insurance Review – Upload your insurance declaration page by the end of July.',
                    Contacts__c = objContact.Id
                    ); 
                    lstMsgToInsert.add(objMsg);
                }
            }
        }

        // MESSAGE 4 : runs on January 31 and July 31
        Date lastdtOfJan = Date.newInstance(System.today().year(), 1, 31);
        Date lastdtOfJuly = Date.newInstance(System.today().year(), 7, 31);
        if(System.today() == lastdtOfJan || System.today() == lastdtOfJuly || Test.isRunningTest()){
            for(Contact objContact : lstContact){
                if(setDriverRoles.contains(objContact.Role__c)){
                    Message__c objMsg = new Message__c(
                    Unread__c = true,
                    Notification_Message__c = 'You have not uploaded an updated insurance declaration page. In 5 days, you could forfeit your fixed amount unless you upload your insurance declaration page(s).',
                    Contacts__c = objContact.Id
                    ); 
                    lstMsgToInsert.add(objMsg);
                }
            }
        }
        
        // MESSAGE 9
        Date firstDtOfTheMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        if(System.today() == firstDtOfTheMonth || Test.isRunningTest()){
            for(Contact objContact : lstContact){
                if(setManagerAdminRoles.contains(objContact.Role__c)){
                    Message__c objMsg = new Message__c(
                    Unread__c = true,
                    Notification_Message__c = 'Your team’s mileage will be ready for approval on the 4th. You will receive an email notification once the mileage is ready for approval.',
                    Contacts__c = objContact.Id
                    ); 
                    lstMsgToInsert.add(objMsg);
                }
            }
        }
        //========== FINAL UPDATE OPERATION ================

        if(!lstMsgToInsert.isEmpty()){
            Database.insert(lstMsgToInsert, false);
        }
    }
    public void finish(Database.BatchableContext bc){
        return;
    }
    // Execute method for the scheduled batch
    public void execute(SchedulableContext sc) {
        MessagesBatch batch = new MessagesBatch();
        Database.executeBatch(batch, 20);
    }
}