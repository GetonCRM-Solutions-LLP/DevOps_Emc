public with sharing class Empreim_update_gasprice_Controller
{
    Public Employee_Reimbursement__c EmployeeReimbursement{get;set;}
    public String urltoredirect {get;set;}
    public List<Contact> obj_contact_list{get;set;}
    public Empreim_update_gasprice_Controller()
    {
    }
    public Empreim_update_gasprice_Controller(ApexPages.StandardController controller)
    {
        
        
       EmployeeReimbursement = [SELECT Id, Name, Month__c, City_State__c, Fixed_Amount__c,Fuel_Price__c, Contact_Id__c,Contact_Id__r.Fixed_Amount__c,Contact_Id__r.MailingState,Contact_Id__r.MailingCity from Employee_Reimbursement__c where id=:Apexpages.currentpage().getparameters().get('id') limit 1];
       
       urltoredirect ='https://'+ URL.getSalesforceBaseUrl().getHost()+'/'+ EmployeeReimbursement.id;
       
    }
     public pagereference updategasprice()
    {
        List<Employee_Reimbursement__c> obj_reimbersment_list = new List<Employee_Reimbursement__c>();
        
       obj_reimbersment_list.add(EmployeeReimbursement);
        
        
        if(obj_reimbersment_list.size()>0)
        {
            
            if(obj_reimbersment_list[0].Fuel_Price__c==null)
            {
                 UpdateReimbersment_fuelprice_batch_Class batchMileage = new UpdateReimbersment_fuelprice_batch_Class(obj_reimbersment_list);
                 Database.executeBatch(batchMileage, 1);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Updation in Progress.');
                ApexPages.addMessage(myMsg);
            }
            else
            {
                List<String> obj_reimersementid_list = new List<String>();
                for(Employee_Reimbursement__c obj_Employee_Reimbursement :obj_reimbersment_list)
                {
                    obj_reimersementid_list.add(obj_Employee_Reimbursement.id);
                }
                List<Employee_Mileage__c> obj_Employee_Mileage_list = new List<Employee_Mileage__c>();
                
                obj_Employee_Mileage_list =[select id,name,Fuel_price__c,EmployeeReimbursement__c,EmployeeReimbursement__r.Fuel_Price__c from Employee_Mileage__c where Fuel_price__c=:null and EmployeeReimbursement__c=:obj_reimersementid_list];
                if(obj_Employee_Mileage_list.size()>0)
                {
                    UpdateMilege_fuelprice_batch_Class batchMileage = new UpdateMilege_fuelprice_batch_Class(obj_Employee_Mileage_list );
                    Database.executeBatch(batchMileage, 1);
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Updation in Progress.');
                    ApexPages.addMessage(myMsg);
    
                }
                else
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No records to Update');
                    ApexPages.addMessage(myMsg);
                }
            }
        }
       
     
        return null;
    } 
    public pagereference backtoAccount()
    {
        pagereference pg = new pagereference(urltoredirect);
        return pg;
    } 
    
}