@isTest
class DriversMileageReportClassTest {
    public static testMethod Void driversMileageReportClassTestMethod() {
     TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Account account = new Account();
        account.Name = 'Delta';
        insert account;
        
        Contact con = new Contact(); 
        con.AccountId= account.Id;
        con.External_Email__c= 'abcd123@gmail.com';
        con.LastName = 'Solanki';
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Name = 'Virn:04-2016';
        er.Contact_Id__c = con.id; 
        er.Month__c = '04-2017';
        insert er;
        
        Employee_Mileage__c em = new Employee_Mileage__c();
        em.Name = 'MileageNameone';
        em.EmployeeReimbursement__c =  er.id;
        em.Contact_Email_Id__c = 'abcd123@gmail.com';
        em.Mileage__c = 20.5;
        insert em;    
        
        DriversMileageReportClass obj = new DriversMileageReportClass();
        DriversMileageReportClass.DriverWrp wrapper= new DriversMileageReportClass.DriverWrp('Test Contact','Test Account','test@test.com',23);        
        
        obj.startDate = System.today().addMonths(-10);
        obj.endDate = System.today();
        obj.minMileage = 100;
        obj.accounts = 'Delta';        
        obj.getDrivers();
    }    
}