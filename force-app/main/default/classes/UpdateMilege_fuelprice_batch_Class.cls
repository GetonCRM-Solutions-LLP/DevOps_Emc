global class UpdateMilege_fuelprice_batch_Class implements Database.Batchable<sObject>,Database.Stateful
{
   
   
   public List<Employee_Mileage__c> obj_list_mileges_toupdate{get;set;}
    public List<Employee_Mileage__c> obj_Employee_Mileage_list{get;set;}
    public UpdateMilege_fuelprice_batch_Class(List<Employee_Mileage__c> obj_Employee_Mileage_list1)
    {
        
        obj_list_mileges_toupdate = new List<Employee_Mileage__c>();
        obj_Employee_Mileage_list = obj_Employee_Mileage_list1;
    }
    global List<Employee_Mileage__c> start(Database.BatchableContext BC) 
    {
        
        return obj_Employee_Mileage_list;
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        try
        {
            if(scope.size()>0)
            {
                List<Employee_Mileage__c> obj_list_milege =  scope;
                for(Employee_Mileage__c obj_current_milege : obj_list_milege)
                {
                    obj_current_milege.Fuel_Price__c = obj_current_milege.EmployeeReimbursement__r.Fuel_Price__c;
                    obj_list_mileges_toupdate.add(obj_current_milege);
                }
                if(obj_list_mileges_toupdate.size()>0)
                {
                   update obj_list_mileges_toupdate;
                  
                   
                   
                }
            }
             
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
       
    }
    global void finish(Database.BatchableContext BC) 
    {
        
        
        
    }
}