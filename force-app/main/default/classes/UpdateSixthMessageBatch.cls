public class UpdateSixthMessageBatch implements Database.Batchable<sObject>{
    public UpdateSixthMessageBatch() {}
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
        String lastMonth = String.valueOf(dtLastMonth.format('MM-yyyy'));
        String lastMonthval = String.valueOf(dtLastMonth.format('MMMM'));
        System.debug(lastMonth);

        DateTime dtCurrentMonth = System.today();
        String currentMonth = String.valueOf(dtCurrentMonth.format('MMMM'));

        Map<String, Employee_Reimbursement__c> reimValLst = new Map<String, Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c reimValue : [SELECT Id,Name,Contact_Id__c,Total_Pending__c,Total_Rejected__c,Mileage_Lock_Date__c from Employee_Reimbursement__c where Contact_Id__c IN: conIdList and Month__c =: lastMonth]){
            reimValLst.put(reimValue.Contact_Id__c, reimValue);
        }

        for(Message__c msgList : [Select Id,Contacts__c,Notification_Message__c,Unread__c from Message__c Where Notification_Message__c like 'flagged miles' and Contacts__c IN: conIdList]){
            if(msgList.Notification_Message__c.contains('flagged miles')){
                //Employee_Reimbursement__c reimVal = [SELECT Id,Name,Contact_Id__c,Total_Pending__c,Total_Rejected__c,Mileage_Lock_Date__c from Employee_Reimbursement__c where Contact_Id__c =: msgList.Contacts__c and Month__c =: lastMonth];
                //if(reimVal != null){
                if(reimValLst.containsKey(msgList.Contacts__c)){
                    if(reimValLst.get(msgList.Contacts__c).Mileage_Lock_Date__c != null){
                    //if(reimVal.Mileage_Lock_Date__c != null){
                        msgList.Unread__c = true;
                    }else{
                        msgList.Unread__c = false;
                    }
                    msgList.Notification_Message__c = 'For '+lastMonthval+' you had '+reimValLst.get(msgList.Contacts__c).Total_Rejected__c+' flagged miles';
                }
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