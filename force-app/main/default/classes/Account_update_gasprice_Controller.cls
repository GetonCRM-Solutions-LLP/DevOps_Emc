public with sharing class Account_update_gasprice_Controller
{
    Public Account acct {get;set;}
    public String urltoredirect {get;set;}
    public List<Contact> obj_contact_list{get;set;}
    public Account_update_gasprice_Controller()
    {
    }
    public Account_update_gasprice_Controller(ApexPages.StandardController controller)
    {
        obj_contact_list= new List<contact>();
        
       acct = (Account)controller.getRecord();
       urltoredirect ='https://'+ URL.getSalesforceBaseUrl().getHost()+'/'+ acct.id; 
       
    } 
    public pagereference updategasprice()
    {
        List<Employee_Reimbursement__c> obj_reimbersment_list = new List<Employee_Reimbursement__c>();
        
        obj_contact_list = [SELECT Id, Name, External_Email__c,Email, AccountId, Account.Triplog_API__c FROM Contact WHERE AccountId =:acct.id AND isCommunityUser__c =:true AND (Deactivated_Date__c = NULL) AND (Role__c = 'Driver' OR Role__c =: StaticValues.roleAdminDriver OR Role__c = 'Driver/Manager')];
        System.debug('obj_contact_list'+obj_contact_list);
        obj_reimbersment_list=[SELECT Id, Name, Month__c, City_State__c, Fixed_Amount__c,Fuel_Price__c, Contact_Id__c,Contact_Id__r.Fixed_Amount__c,Contact_Id__r.MailingState,Contact_Id__r.MailingCity FROM Employee_Reimbursement__c where Fuel_Price__c=:null and Contact_Id__c =:obj_contact_list];
         System.debug('obj_reimbersment_list'+obj_reimbersment_list);
        if(obj_reimbersment_list.size()>0)
        {
            System.debug('obj_reimbersment_list');
            
            UpdateReimbersment_fuelprice_batch_Class batchMileage = new UpdateReimbersment_fuelprice_batch_Class(obj_reimbersment_list);
             Database.executeBatch(batchMileage, 1);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Updation in Progress.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            // call the gas price batch
            obj_reimbersment_list=[SELECT Id, Name, Month__c, City_State__c, Fixed_Amount__c,Fuel_Price__c, Contact_Id__c,Contact_Id__r.Fixed_Amount__c,Contact_Id__r.MailingState,Contact_Id__r.MailingCity FROM Employee_Reimbursement__c where Contact_Id__c =:obj_contact_list];
            List<String> obj_reimersementid_list = new List<String>();
            for(Employee_Reimbursement__c obj_Employee_Reimbursement :obj_reimbersment_list)
            {
                obj_reimersementid_list.add(obj_Employee_Reimbursement.id);
            }
            List<Employee_Mileage__c> obj_Employee_Mileage_list = new List<Employee_Mileage__c>();
            
            obj_Employee_Mileage_list =[SELECT id, Name, Fuel_price__c, EmployeeReimbursement__c, EmployeeReimbursement__r.Fuel_Price__c FROM Employee_Mileage__c WHERE Fuel_price__c =: null AND EmployeeReimbursement__c =: obj_reimersementid_list];
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
     
        return null;
    } 
    public pagereference backtoAccount()
    {
        pagereference pg = new pagereference(urltoredirect);
        return pg;
    } 
}