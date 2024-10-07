public class UpdateCompliancemileageBatch implements Database.Batchable<sObject>, Database.Stateful{

    public UpdateCompliancemileageBatch() {}
    public List<Contact> start(Database.BatchableContext bc){
        List<Contact> conList = [SELECT Id,name,Role__c,Activation_Date__c
                                    FROM contact 
                                    WHERE Role__c != 'Admin' 
                                        AND Role__c != 'Manager' 
                                        AND Deactivated_Date__c = NULL 
                                        AND Account.isUsingTriplog__c = true
                                        AND Activation_Date__c != null];
        return conList; 
    }
    public void execute(Database.BatchableContext bc, List<Contact> conList) {
        List<Contact> conListtoUpdate = new List<Contact>();
        for (Contact con : conList) {
            if((con.Activation_Date__c).year() ==  system.today().year()) {
                if(system.today().month() == 12){
                    con.Compliance_Mileage__c = 5000;
                    conListtoUpdate.add(con);
                }
            }
        }
        if(conListtoUpdate.size() > 0 ){
            Update conListtoUpdate;
        }
    }
    public void finish(Database.BatchableContext bc){}
}