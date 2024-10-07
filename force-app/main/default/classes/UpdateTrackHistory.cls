public class UpdateTrackHistory implements Database.Batchable<SObject> {
    public Map<ID,Employee_Mileage__c> mileageOld;
    public List<Employee_Mileage__c> mileageNew;
    public UpdateTrackHistory(Map<ID,Employee_Mileage__c> oldMileage,List<Employee_Mileage__c> newMileage){
        mileageOld = new Map<ID,Employee_Mileage__c>();
        mileageNew = new List<Employee_Mileage__c>();
        mileageOld = oldMileage;
        mileageNew = newMileage;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        list<AuditTrail__c> newAuditTrialCreate = new list<AuditTrail__c>();
        for(Employee_Mileage__c objMil : mileageNew) {
            if(objMil.id == mileageOld.get(objMil.id).id) {
                if(objMil.Trip_Status__c != mileageOld.get(objMil.id).Trip_Status__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Trip Status',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.Valueof(objMil.Trip_Status__c),OldValue__c=String.Valueof(mileageOld.get(objMil.id).Trip_Status__c),Employee_Mileage__c = objMil.id));
                if(objMil.Approved_Date__c != mileageOld.get(objMil.Id).Approved_Date__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Approval Date',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.valueOf(objMil.Approved_Date__c),OldValue__c=String.valueOf(mileageOld.get(objMil.id).Approved_Date__c),Employee_Mileage__c=objMil.id));
            }
         
        }
        if(newAuditTrialCreate.Size() > 0)
            upsert newAuditTrialCreate; 
        return Database.getQueryLocator([select Id from Account order by Name limit 5]);
    }

    public void execute(Database.BatchableContext context, List<Sobject> scope) {
    }

    public void finish(Database.BatchableContext context) {
    }
}