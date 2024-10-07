public with sharing class UpdateFuelPriceController {
    public Account acc { get; set; }
    public UpdateFuelPriceController()  { }

    public UpdateFuelPriceController(ApexPages.StandardController controller) {
        acc = (Account) controller.getRecord();
    } 
    public pagereference updategasprice() {
        List<Contact> contactList = [SELECT Id, 
                                        Name, 
                                        External_Email__c,
                                        Email, 
                                        AccountId, 
                                        Account.Triplog_API__c 
                                    FROM Contact 
                                        WHERE AccountId =: acc.id 
                                        AND isCommunityUser__c = true 
                                        AND Deactivated_Date__c = null 
                                        AND (Role__c =: StaticValues.ROLE_DRIVER OR Role__c =: StaticValues.roleAdminDriver OR Role__c =: StaticValues.ROLE_DRIVERMANAGER)];
        
        List<Employee_Reimbursement__c> reimbersmentList = [SELECT Id, 
                                                                    Name, 
                                                                    Month__c,
                                                                    City_State__c, 
                                                                    Fixed_Amount__c,
                                                                    Fuel_Price__c, 
                                                                    Contact_Id__c,
                                                                    Contact_Id__r.Fixed_Amount__c,
                                                                    Contact_Id__r.MailingState,
                                                                    Contact_Id__r.MailingCity 
                                                                FROM Employee_Reimbursement__c 
                                                                    WHERE Fuel_Price__c = null 
                                                                    AND Contact_Id__c =: contactList];
        
        if(!reimbersmentList.isEmpty()) {
            
            UpdateReimbersment_fuelprice_batch_Class batchMileage = new UpdateReimbersment_fuelprice_batch_Class(reimbersmentList);
            Database.executeBatch(batchMileage, 1);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Updation in Progress.');
            ApexPages.addMessage(myMsg);
        } else  {
            // call the gas price batch
            List<Employee_Mileage__c> mileageList = [SELECT Id, 
                                                            Name, 
                                                            Fuel_price__c, 
                                                            EmployeeReimbursement__c, 
                                                            EmployeeReimbursement__r.Fuel_Price__c 
                                                        FROM Employee_Mileage__c 
                                                            WHERE Fuel_price__c = null 
                                                            AND EmployeeReimbursement__r.Contact_Id__c =: contactList];
            if(!mileageList.isEmpty()) {
                UpdateMilege_fuelprice_batch_Class batchMileage = new UpdateMilege_fuelprice_batch_Class(mileageList );
                Database.executeBatch(batchMileage, 1);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Updation in Progress.');
                ApexPages.addMessage(myMsg);

            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No records to Update');
                ApexPages.addMessage(myMsg);
            }
        }
     
        return null;
    } 
    public pagereference backtoAccount()  {
        return new pagereference('/' + acc.Id);
    } 
}