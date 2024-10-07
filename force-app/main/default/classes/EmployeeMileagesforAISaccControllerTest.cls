@isTest
public class EmployeeMileagesforAISaccControllerTest {
    public EmployeeMileagesforAISaccControllerTest() {
    }
    @isTest
    public static void testMethod1(){

        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
         SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        Account acc = new Account();
        acc.Name = 'Advanced Inventory Solutions';
        insert acc;
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName = 'testsdfsdfs';
        con1.compliancestatus__c = 'Yes';
        con1.Vehicle_Type__c = '2019 Mileage Rate';
        con1.External_Email__c = 'test.patel143478@gmail.com';
        con1.IsDeactivated__c = false;
        insert con1;  

        Employee_Reimbursement__c reim = new Employee_Reimbursement__c();
        reim.Contact_Id__c = con1.id;
        reim.Driver_Email__c = 'test@gmail.com';
        reim.Month__c = '01-2021';
        reim.Fixed_Amount__c = 134.45;
        reim.MPG__c = 2.1;
        reim.Fuel_Price__c = 1.5;
        reim.Maintenance_and_Tires__c = 2.5;
        insert reim;        
        

        Employee_Mileage__c mil = new Employee_Mileage__c();    
        mil.EmployeeReimbursement__c = reim.Id;
        mil.Contact_Email_Id__c = con1.External_Email__c;
        mil.Mileage__c = 20.21;
        mil.Trip_Date__c = system.today()-3;
        mil.EmployeeReimbursement__c = reim.id; 
        mil.Trip_Status__c = 'Approved';
        mil.Approved_Date__c = system.today();
        insert mil;
    
        Test.startTest();
        Test.setCurrentPage(Page.MileagesforAISAccountReport);
        String startDate = ApexPages.currentPage().getParameters().put('startDate','2021-02-20');
        String endDate = ApexPages.currentPage().getParameters().put('endDate','2021-03-23');
        Decimal monthlyVariableAmount = 0.2;
           EmployeeMileagesforAISaccController newObjClass = new EmployeeMileagesforAISaccController(); 
        Test.stopTest();
        
    }
}