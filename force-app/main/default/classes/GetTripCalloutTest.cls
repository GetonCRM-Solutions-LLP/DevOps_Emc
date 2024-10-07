@isTest
public class GetTripCalloutTest {
    @istest
    public static Void GetTripCalloutForMileageTestMethod() {
        
        String fuelPrice, mpg, mat, priMin, priMax;
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting1 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmailToMe__c objSendEmailToMe = TestDataFactory.sendEmailToMeCustomSetting(true, 'GetTripCallOutApprovePutCall');
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irs = TestDataFactory.createIRSRate(false,0);
        irs.year__c = String.valueof(system.today().year());
        irs.IRS_Rate__c = 0.85;
        insert irs;
        
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(false, 3);
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        UserRole userRole_1 = TestDataFactory.getUserRole();
        Profile profile_1 = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole_1.Id);
        User user_1;
        
        Account account;
        List<Contact> currentContact;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            account = TestDataFactory.createAccount(true,'Test',true);
            account.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            account.Pay_Period_Start_Date__c = System.today().addDays(-100);
            account.Pay_Period_Days__c = 13;
            update account;
            
            currentContact = TestDataFactory.createDriverContact(false, account.Id, 'Manager',  null, 'minkesh.patel', 1);
            currentContact[0].Vehicle_Type__c  = '2019 Mileage Rate';  
            currentContact[0].Role__c = 'Driver';  
            insert currentContact[0];
            
            Contact contact_1 = new Contact(AccountId = account.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com',MobilePhone='3434566778',Cell_Phone__c='Company Provide',Activation_Date__c=system.today());
            insert contact_1;
            user_1 = TestDataFactory.createUser(True, profile_1.Id, contact_1.Id);
        }       
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(true,currentContact,2,irs.id);
        List<Bi_Weekly_Reimbursement__c> bob = TestDataFactory.createBiweeklyReim(true,currentContact,system.today().adddays(-7),system.today(), 1,irs.id);
        
        //List<Employee_Mileage__c> emp = TestDataFactory.getEmpMileage(true,0,er, bob);
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (false, 0, er, bob);
        emp1[0].Trip_Date__c =  date.today().adddays(-1);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].StartTime__c = System.now();
        emp1[0].EndTime__c = System.now();
        emp1[0].Approved_Date__c = system.today();
        insert emp1;
        /*Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.EmployeeReimbursement__c = er[0].id;
        emp.Bi_Weekly_Reimbursement__c = bob[0].id;
        insert emp;*/
        
        priMin = '2016-12-01';
        priMax = '2017-12-01';
        fuelPrice = '1.0';       
        mpg = String.valueof(er[0].MPG__c);
        mat = '1.0';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetTripCalloutMock());
        //GetTripCallout.GetTripCalloutForMileage(er[0].id, currentContact[0].External_Email__c,currentContact[0].id, priMin, priMax, fuelPrice, mpg, mat, account.Triplog_API__c, er[0].Triplog_Status__c,true,false,'');
        String result = GetTripCallout.GetTripCalloutForMileage(er[0].id, currentContact[0].External_Email__c,currentContact[0].id, priMin, priMax, fuelPrice, mpg, mat, account.Triplog_API__c, er[0].Triplog_Status__c,true,true,'');
        GetTripCallout.getBiWeekReimId(String.valueOf(currentContact[0]));
        String body = 'test';
        String apiToken = 'test';
        String finalstr = 'test';       
        Test.stopTest();
    }
}