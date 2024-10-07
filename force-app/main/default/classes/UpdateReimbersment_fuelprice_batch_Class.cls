global class UpdateReimbersment_fuelprice_batch_Class implements Database.Batchable<sObject>,Database.Stateful
{
   public String query;
   public List<Employee_Reimbursement__c> obj_list_Employee_Reimbursement {get;set;}
   public List<Employee_Reimbursement__c> obj_list_update_Employee_Reimbursement {get;set;}
   public List<String> obj_reimbersmentid_list  {get;set;} 
   public List<Employee_Mileage__c> obj_mileage_list {get;set;}
    public UpdateReimbersment_fuelprice_batch_Class(List<Employee_Reimbursement__c> obj_list_Employee_Reimbursement1)
    {
        obj_list_Employee_Reimbursement = obj_list_Employee_Reimbursement1;
        obj_reimbersmentid_list  = new List<String>();
        obj_mileage_list = new List<Employee_Mileage__c>();
        for(Employee_Reimbursement__c obj_current_reimebersment:obj_list_Employee_Reimbursement)
        {
            obj_reimbersmentid_list.add(obj_current_reimebersment.id);
        }
        obj_list_update_Employee_Reimbursement  =  new List<Employee_Reimbursement__c>();
       // obj_mileage_list =[select id,name,Fuel_price__c,EmployeeReimbursement__c,EmployeeReimbursement__r.Fuel_Price__c from Employee_Mileage__c where Fuel_price__c=:null and EmployeeReimbursement__c=:obj_reimbersmentid_list];
    }
    global List<Employee_Reimbursement__c> start(Database.BatchableContext BC) 
    {
        return obj_list_Employee_Reimbursement;
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        try
        {
            
            for(Employee_Reimbursement__c obj_current_reimbersment : (List<Employee_Reimbursement__c>)scope)
            {
                List<String> datemonth = new List<String>();
                
                if((String.valueOf(obj_current_reimbersment.Month__c)!=null)&&(String.valueOf(obj_current_reimbersment.Month__c).contains('-')))
                {
                    datemonth =String.valueOf(obj_current_reimbersment.Month__c).split('-');
                        System.debug('datemonth :- '+datemonth );
                    Date mydate = date.newInstance(Integer.valueOf(datemonth[1]), Integer.valueOf(datemonth[0]), 1);
                    System.debug('mydate :- '+mydate);
                    List<Gas_Prices__c> obj_list_GasPrice = new List<Gas_Prices__c>();
                    obj_list_GasPrice = [select id,name,City__c, State__c, Fuel_Price__c, Month_Year__c from Gas_Prices__c where City__c=:obj_current_reimbersment.Contact_Id__r.MailingCity and State__c=:obj_current_reimbersment.Contact_Id__r.MailingState and Month_Year__c=: mydate];
                    System.debug('obj_list_GasPrice  :-'+obj_list_GasPrice);
                    if(obj_list_GasPrice.size()>0)
                    {
                        obj_current_reimbersment.Fuel_Price__c= obj_list_GasPrice[0].Fuel_Price__c;
                        obj_list_update_Employee_Reimbursement.add(obj_current_reimbersment);
                    }
                }
                
            }
            if(obj_list_update_Employee_Reimbursement.size()>0)
            {
               update obj_list_update_Employee_Reimbursement;
               
            } 
             
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
       
    }
    global void finish(Database.BatchableContext BC) 
    {
         obj_mileage_list =[select id,name,Fuel_price__c,EmployeeReimbursement__c,EmployeeReimbursement__r.Fuel_Price__c from Employee_Mileage__c where Fuel_price__c=:null and EmployeeReimbursement__c=:obj_reimbersmentid_list];
        if(obj_mileage_list.size()>0)
        {
            UpdateMilege_fuelprice_batch_Class batchMileage = new UpdateMilege_fuelprice_batch_Class(obj_mileage_list );
            Database.executeBatch(batchMileage, 1);
        }
        
    }
}