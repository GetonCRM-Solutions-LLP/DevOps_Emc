public class UpdateMileageFuelPrice {
    public string redirecttourl{get;set;}
    static Bi_Weekly_Reimbursement__c BiWeeklyReimbersementId{get;set;}
    public string AccountId {get;set;}
    public Date StartDate {get;set;}
    public Date EndDate {get;set;}
    public Bi_Weekly_Reimbursement__c biweek {get;set;}
    public UpdateMileageFuelPrice()  { }
   
    public UpdateMileageFuelPrice(ApexPages.StandardController controller ){
        if (!Test.isRunningTest()){
            controller.addFields(new List<String>{'Start_Date__c', 'End_Date__c','Contact__r.AccountId'}); 
        }
        BiWeeklyReimbersementId = (Bi_Weekly_Reimbursement__c)controller.getRecord();
        biweek = (Bi_Weekly_Reimbursement__c)controller.getRecord();
        AccountId = biweek.Contact__r.AccountId;
        StartDate = biweek.Start_Date__c != null ? biweek.Start_Date__c : null;
        EndDate = biweek.End_Date__c != null ? biweek.End_Date__c : null;
        redirecttourl='https://'+URL.getSalesforceBaseURL().getHost()+'/'+BiWeeklyReimbersementId.Id;         
    }
    public pagereference UpdateMileageFuelPrices(){
        try {
            List<Bi_Weekly_Reimbursement__c> BiWeeklyreimbersmentList = [SELECT Id, 
                                                                                Name, 
                                                                                Start_Date__c,
                                                                                End_Date__c,
                                                                                Fuel_Price__c 
                                                                            FROM Bi_Weekly_Reimbursement__c 
                                                                            WHERE (Fuel_Price__c != null or Fuel_Price__c != 0) 
                                                                            AND (Contact__r.Role__c =: StaticValues.ROLE_DRIVER 
                                                                                    OR Contact__r.Role__c =: StaticValues.roleAdminDriver 
                                                                                    OR Contact__r.Role__c =: StaticValues.ROLE_DRIVERMANAGER )
                                                                            AND Start_Date__c >=: StartDate 
                                                                            AND End_Date__c <=: EndDate]; 
            if(!BiWeeklyreimbersmentList.isEmpty()){
                UpdateBiweeklyRem_FuelPrice_Batch_Class batchMileage = new UpdateBiweeklyRem_FuelPrice_Batch_Class(BiWeeklyreimbersmentList);
                Database.executeBatch(batchMileage, 100);
                System.debug('Success');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Fuel Price Updation Completed');
                ApexPages.addMessage(myMsg);
                PageReference pg = new PageReference(redirecttourl);                
                return pg; 
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No records to Updated');
                ApexPages.addMessage(myMsg);
            }
        } catch(Exception ex) {
            system.debug('Error:'+ex.getMessage()+',Error at Line Number'+ex.getLineNumber());
        }
        return null;
    }
    public pageReference BackToBiWeeklyReimbersment(){
        PageReference pg = new PageReference(redirecttourl);
        return pg;
    }
}