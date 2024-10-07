@isTest
public class GetTripCalloutforCommmiteTripTest {
    public static testMethod Void GetTripCalloutForMileageTestMethod() {
        
        String fuelPrice, mpg, mat, priMin, priMax;
        TriggerConfig__c customSetting = TestDataFactory.triggerConfigCustomSetting(true);      
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);

        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);     
        
        SendEmail__c customSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        
        SendEmailToMe__c objSendEmailToMe = TestDataFactory.sendEmailToMeCustomSetting(true, 'GetTripCallOutApprovePutCall');
        daylight_saving_time_config__c customSetting2 =  TestDataFactory.dayLightCustomSetting(true,'2022',System.today(),System.today() + 60);        
        IRS_Mileage_Rate__c irs = TestDataFactory.createIRSRate(true,0);        
        UserRole userRole_1 = TestDataFactory.getUserRole();
        Profile profile_1 = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole_1.Id);
     
        User user_1;
        Account account;
        List<Contact> currentContact;
        System.runAs(admin) {
            account = TestDataFactory.createAccount(true,'Test',true);
            account.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            account.Pay_Period_Start_Date__c = System.today().addDays(-100);
            account.Pay_Period_Days__c = 13;
            update account;
            Contact contactObj = TestDataFactory.createCICDContact(true,account.Id);
            currentContact = TestDataFactory.createDriverContact(true, account.Id, 'Manager',  null, 'minkesh.patel', 1);
            currentContact[0].Vehicle_Type__c  = '2019 Mileage Rate';  
            currentContact[0].Role__c = 'Driver';  
            currentContact[0].Time_Zone__c = 'US/Eastern';
            currentContact[0].Monthly_Reimbursement__c = true;
            currentContact[0].Biweek_Reimbursement__c=false;
            update currentContact[0];
            
            Contact contact_1 = new Contact(AccountId = account.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com',Activation_Date__c=System.today(),Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;
           
            user_1 = TestDataFactory.createUser(true, profile_1.Id, contact_1.Id);           
        }        
        
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(true,currentContact,2,irs.id);     

        List<Employee_Reimbursement__c> er1 = TestDataFactory.createPendingReimbursement(false,currentContact,2,irs.id);
        er1[0].Approved_Date__c = system.today();
        er1[0].Status__c = 'Approved';
        insert er1;
        
        List<Bi_Weekly_Reimbursement__c> bob = TestDataFactory.createBiweeklyReim(true, currentContact, system.today().adddays(-14), system.today().addDays(-1), 10, irs.id);        
        
        List<Employee_Mileage__c> emp = TestDataFactory.getEmpMileage(true,1,er, bob);     

        /*List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage(false,1,er, bob);     
         emp1[0].Trip_Status__c = 'Approved';
        insert emp1;
        List<Employee_Mileage__c> emp2 = TestDataFactory.getEmpMileage(false,1,er, bob);       
        emp2[0].StartTime__c = null;
        insert emp2;

        List<Employee_Mileage__c> emp3 = TestDataFactory.getEmpMileage(false,1,er, bob);      
        emp3[0].EndTime__c = null;
        insert emp3;*/
        
        priMin = '2021-12-01';
        priMax = '2022-12-01';
        fuelPrice = '1.0';       
        mpg = String.valueof(er[0].MPG__c);
        mat = '1.0';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetTripCalloutMock());
        // GetTripCalloutforCommute.GetTripCalloutForCommuteMileage(er[0].id, currentContact[0].External_Email__c,currentContact[0].id, priMin, priMax, fuelPrice, mpg, mat, account.Triplog_API__c, er[0].Triplog_Status__c,true,'Business',false,'');
        GetTripCalloutforCommute.GetTripCalloutForCommuteMileage(er[0].id, currentContact[0].External_Email__c,currentContact[0].id, priMin, priMax, fuelPrice, mpg, mat, account.Triplog_API__c, er[0].Triplog_Status__c,true,'Business',false,'');
        GetTripCalloutforCommute.getBiWeekReimId(String.valueOf(currentContact[0]));
        String body = 'test';
        String apiToken = 'test';
        String finalstr = 'test';       
        Test.stopTest();
    }
    public static testMethod Void GetTripCalloutForMileageTestMethod2() {
        TriggerConfig__c customSetting = TestDataFactory.triggerConfigCustomSetting(true);      
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true); 

        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);        
        daylight_saving_time_config__c customSetting2 =  TestDataFactory.dayLightCustomSetting(true,'2022',System.today(),System.today() + 60);        
        SendEmail__c customSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');     
        IRS_Mileage_Rate__c irs = TestDataFactory.createIRSRate(true,0);      
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
            
            currentContact = TestDataFactory.createDriverContact(true, account.Id, 'Manager',  null, 'minkesh.patel', 1);
            currentContact[0].Vehicle_Type__c  = '2019 Mileage Rate';  
            currentContact[0].Role__c = 'Driver';
            currentContact[0].Time_Zone__c = 'US/Eastern';  
            update currentContact[0];
            
            Contact contact_1 = new Contact(AccountId = account.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com',Activation_Date__c=System.today(),Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;           
            
            user_1 = TestDataFactory.createUser(true, profile_1.Id, contact_1.Id);           
        }
        
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(true,currentContact,2,irs.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetTripCalloutMock());
        String apiToken = 'test';
        Set<Integer> tripSet = new Set<Integer>();
        tripSet.add(1242);
        //GetTripCallout.trip_IDs = tripSet;
        GetTripCalloutforCommute.putHTTP(apiToken,currentContact[0].Id,er[0].Id,tripSet ); 
        GetTripCalloutforCommute.ConvertToDateTime('2024-09-02T16:32:00.000Z');
        Test.stopTest();
    }
}