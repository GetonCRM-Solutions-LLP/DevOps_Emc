global class UpdateBiweeklyRem_FuelPrice_Batch_Class implements Database.Batchable<SObject>,Database.Stateful {
    
    public List<Bi_Weekly_Reimbursement__c> obj_list_Biweekly_Rembersment {get;set;}
    public List<Employee_Mileage__c> obj_Employee_Mileage {get;set;}
    public List<Employee_Mileage__c> obj_mileage_list {get;set;}
    Map<String,Double> BiweeklyFuelPrice = new Map<String,Double>();
    public UpdateBiweeklyRem_FuelPrice_Batch_Class(List<Bi_Weekly_Reimbursement__c> obj_list_Biweekly_Rembersment1)
    { 
        obj_list_Biweekly_Rembersment = obj_list_Biweekly_Rembersment1;
        obj_mileage_list = new List<Employee_Mileage__c>();	
    }
    global List<Bi_Weekly_Reimbursement__c> Start(Database.BatchableContext BC){
        return obj_list_Biweekly_Rembersment;
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{  
            for(Bi_Weekly_Reimbursement__c obj_current_reimbersment : (List<Bi_Weekly_Reimbursement__c>)scope) {   
                if(obj_current_reimbersment.Fuel_Price__c!=null && obj_current_reimbersment.Fuel_Price__c !=0 ) { 
                	BiweeklyFuelPrice.put(obj_current_reimbersment.Id, obj_current_reimbersment.Fuel_Price__c);
                }
            }     
            obj_Employee_Mileage = new List<Employee_Mileage__c>();
            for(Employee_Mileage__c mileage : [SELECT Id,Fuel_price__c,
                                                        Bi_Weekly_Reimbursement__c  
                                                    FROM Employee_Mileage__c 
                                                    WHERE Bi_Weekly_Reimbursement__c 
                                                    IN : BiweeklyFuelPrice.keyset()]) {    
                if(BiweeklyFuelPrice.get(mileage.Bi_Weekly_Reimbursement__c) != mileage.Fuel_price__c){
                    mileage.Fuel_price__c = BiweeklyFuelPrice.get(mileage.Bi_Weekly_Reimbursement__c);
                    obj_Employee_Mileage.add(mileage);
                } 
            }  
            if(obj_Employee_Mileage.size() > 0 ) {
                update obj_Employee_Mileage;   
            } 
        } catch(Exception ex) {
            system.debug('Error:'+ex.getMessage()+',Error at Line Number'+ex.getLineNumber());
        }
    }
    global void finish(Database.BatchableContext BC) { }
}