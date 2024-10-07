@isTest
class SendReimbursementEmailTest {
    public static testMethod Void sendReimbursementEmailTestMethod() {
        Reimbursement_Email_Period__c rep = new Reimbursement_Email_Period__c();
        rep.name = 'Reimbursement Period';
        Date fromDate = date.newinstance(2017, 2, 17);
        Date toDate = date.newinstance(2017, 12, 17);
        rep.From_Date__c = fromDate;
        rep.To_Date__c = toDate;
        insert rep;
        
        Account account = new Account();
        account.name = 'Test Account';
        insert account;
        
        
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test@test.com';
        insert contact;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        er.month__c = '04-2017';
        er.Fuel_Price__c = 1.12;
        er.Fixed_Amount__c = 10.10;
        insert er;
        
        SendReimbursementEmail.sendEmail(account.Id);
    }
}