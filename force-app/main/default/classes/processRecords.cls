public class processRecords implements Database.Batchable<sObject> {
    public List<sObject> myList;
    
    public processRecords(List<sObject> objList) {
        this.myList = objList;
    }
    public List<sObject> start(Database.BatchableContext context) {
        return this.myList;
    }
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        List<Employee_Reimbursement__c> erToUpdate = new List<Employee_Reimbursement__c>();
        List<Employee_Mileage__c> updateMileage = new List<Employee_Mileage__c>();
        List<Contact> updateContact = new List<Contact>();
        if(!scope.isEmpty()) {
            try{
                for(sObject singleObject : scope) {
                    if(singleObject.getSObjectType() == Schema.Employee_Reimbursement__c.getSObjectType()) {
                        //obj.put('Status__c','Approved');
                        erToUpdate.add((Employee_Reimbursement__c) singleObject);
                    }else if(singleObject.getSObjectType() == Schema.Employee_Mileage__c.getSObjectType()) {
                        updateMileage.add((Employee_Mileage__c) singleObject);
                    }else if(singleObject.getSObjectType() == Schema.Contact.getSObjectType()) {
                        updateContact.add((Contact) singleObject);
                    }
                }
                if(!erToUpdate.isEmpty()) {
                    update erToUpdate;
                }
                if(!updateMileage.isEmpty()) {
                    update updateMileage;
                }
                if(!updateContact.isEmpty()) {
                    update updateContact;
                }
            } catch(exception e) {
                System.debug('Exception Batch -->' + e);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {'willh@mburse.com'};
                message.optOutPolicy = 'FILTER';
                message.subject = 'Approval Status';
                message.plainTextBody = string.valueOf(e);
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                /*Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }*/
            }
        }
    }
    public void finish(Database.BatchableContext context) {
    
    }
}