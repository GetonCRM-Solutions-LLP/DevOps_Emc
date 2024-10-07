@isTest
class PopulateFuelPriceonMileageTest {
    
    public static testMethod Void populateFuelPriceonMileageTestMethod() {
    
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'last name';
        contact.External_Email__c = 'test@test.com';
        contact.MailingCity = 'New York';
        contact.MailingState = 'NY';        
        insert contact;
        
        Employee_Reimbursement__c reimburse = new Employee_Reimbursement__c();
        reimburse.Contact_Id__c = contact.Id;
        reimburse.name = 'test reimburse';
        reimburse.Month__c = '11-2017';
        insert reimburse;
        
        Employee_Mileage__c mileage = new Employee_Mileage__c();
        mileage.EmployeeReimbursement__c = reimburse.Id;
        mileage.Contact_Email_Id__c = 'test@test.com';
        mileage.Name = 'test mileage';
        insert mileage;
        
        PopulateFuelPriceonMileage.setFuelPrice(account.Id);
    }
}