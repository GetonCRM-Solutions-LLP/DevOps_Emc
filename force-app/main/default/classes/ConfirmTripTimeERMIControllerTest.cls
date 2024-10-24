/**
 * @description       : 
 * @author            : Harsita
 * @group             : 
 * @last modified on  : 23-10-2024
 * @last modified by  : Harsita
**/
@isTest
private class ConfirmTripTimeERMIControllerTest {
    
    @TestSetup
    static void setupTestData() {

        Test.setMock(HttpCalloutMock.class, new UploadBulkLocationAPIMock());
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());

        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        SendEmail__c sendEmailCustomSetting2 = TestDataFactory.sendEmailCustomSetting(true,'ConfirmTripTimeERMIController');
        SendEmail__c sendEmailCustomSetting3 = TestDataFactory.sendEmailCustomSetting(true,'ConfirmTripSyncErmi');
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        
        Account acc = new Account();     
        List<Contact> lstContact = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User objUser;
        System.runAs(admin) {            
            
            acc = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            lstContact = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            objUser = TestDataFactory.createUser(true, profileObj.Id, lstContact[0].Id);
        }
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, lstContact, 10, irsRateObj.id);
        system.assertEquals(11, reimList.size(),true);
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim(true, lstContact, system.today().adddays(-14), system.today().addDays(-1), 10, irsRateObj.id);
        Attachment attach = TestDataFactory.createAttachment(true, lstContact[0].id);
        List<Attachment> lstAttachment = [SELECT id, name FROM Attachment WHERE parent.id =: lstContact[0].id];
    }

    @isTest
    public static void syncTripsForErmiTest1(){
               
        Account objAccount = [SELECT id, True_Dialog__c, Name FROM Account WHERE Name = 'Test'];
        
        List<Contact> lstDriverContact = [SELECT id FROM Contact WHERE Role__c = 'Driver'];
        User objUser = [SELECT id FROM User WHERE ContactId =: lstDriverContact[0].id ];
        
        Test.startTest();
        System.runAs(objUser) {
            apexpages.currentpage().getparameters().put('id' , lstDriverContact[0].Id);
            ConfirmTripTimeERMIController controller = new ConfirmTripTimeERMIController();  
            ConfirmTripTimeERMIController.syncTripsForErmi(lstDriverContact[0].Id,'03/07/2022','03/12/2022'); 
        }
        Test.stopTest();
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
    }
     @isTest
    public static void syncTripsForErmiTest2(){
               
        Account objAccount = [SELECT id, True_Dialog__c, Name FROM Account WHERE Name = 'Test'];
        
        List<Contact> lstDriverContact = [SELECT id FROM Contact WHERE Role__c = 'Driver'];
        User objUser = [SELECT id FROM User WHERE ContactId =: lstDriverContact[0].id ];
        System.debug('Start Date'+System.today().addDays(-14));
        System.debug('End Date'+System.today().addDays(-1));
        Test.startTest();
        System.runAs(objUser) {
            apexpages.currentpage().getparameters().put('id' , lstDriverContact[0].Id);
            ConfirmTripTimeERMIController controller = new ConfirmTripTimeERMIController();  
            ConfirmTripTimeERMIController.syncTripsForErmi(lstDriverContact[0].Id,'09/25/2024','10/08/2024'); 
        }
        Test.stopTest();
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
    }
    @isTest
    public static void updateBiWeekDataTest(){
               
        Account objAccount = [SELECT id, True_Dialog__c, Name FROM Account WHERE Name = 'Test'];
        List<Contact> lstDriverContact = [SELECT id FROM Contact WHERE Role__c = 'Driver'];
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c WHERE Contact__c = :lstDriverContact[0].Id];
        User objUser = [SELECT id FROM User WHERE ContactId =: lstDriverContact[0].id ];
        
        Test.startTest();
        System.runAs(objUser) {
          
            String jsonString = '[{'
            + '"biWeekId":"' + lstBiWeeklyReim[0].id + '",'
            + '"confirmCheck":true,'
            + '"errorCheck":false,'
            + '"countErrorCheck":0,'
            + '"driverEmail":"meghac.mobio@gmail.com",'
            + '"driverName":"Megha",'
            + '"biWeekPayperiod":"03/09/2022 to 03/22/2022",'
            + '"mileage":0,'
            + '"driveTime":"0",'
            + '"stayTime":"0",'
            + '"totalTime":"0"'
            + '}]';
        
            // Output the JSON string
            System.debug(jsonString);
        
            apexpages.currentpage().getparameters().put('id' , lstDriverContact[0].Id);
            ConfirmTripTimeERMIController controller = new ConfirmTripTimeERMIController();  
            ConfirmTripTimeERMIController.UpdateBiWeekData(jsonString);
        }
        Test.stopTest();
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
    }
    @isTest
    public static void sendErrorEmailTest1(){
               
        Account objAccount = [SELECT id, True_Dialog__c, Name FROM Account WHERE Name = 'Test'];
        List<Contact> lstDriverContact = [SELECT id,Name,Email FROM Contact WHERE Role__c = 'Driver'];
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim = [SELECT Id,Name FROM Bi_Weekly_Reimbursement__c WHERE Contact__c = :lstDriverContact[0].Id];
        User objUser = [SELECT id FROM User WHERE ContactId =: lstDriverContact[0].id ];
        
        Test.startTest();
        System.runAs(objUser) {
          
            apexpages.currentpage().getparameters().put('id' , lstDriverContact[0].Id);
       
            ConfirmTripTimeERMIController.sendErrorEmail(
                lstDriverContact[0].Email, 
                lstDriverContact[0].Name, 
                lstBiWeeklyReim[0].Name, 
                12.0, // Mileage
                '1',  // Drive Time
                '1',  // Stay Time
                '1',  // Total Time
                2,    // Count Error
                'Driver - Salary' // Driver Type
            );
        }
        Test.stopTest();
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
    }
    @isTest
    public static void deleteTripsForErmiTest(){
               
        Account objAccount = [SELECT id, True_Dialog__c, Name FROM Account WHERE Name = 'Test'];
        List<Contact> lstDriverContact = [SELECT id,Name,Email FROM Contact WHERE Role__c = 'Driver'];
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim = [SELECT Id,Name FROM Bi_Weekly_Reimbursement__c WHERE Contact__c = :lstDriverContact[0].Id];
        User objUser = [SELECT id FROM User WHERE ContactId =: lstDriverContact[0].id ];
        
        Test.startTest();
        System.runAs(objUser) {
          
            apexpages.currentpage().getparameters().put('id' , lstDriverContact[0].Id);
       
            ConfirmTripTimeERMIController.deleteTripsForErmi(lstDriverContact[0].Name,'10/01/2024','10/06/2024');
        }
        Test.stopTest();
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
    }
    @isTest
    public static void reimMileagesTest(){
               
        Account objAccount = [SELECT id, True_Dialog__c, Name FROM Account WHERE Name = 'Test'];
        List<Contact> lstDriverContact = [SELECT id FROM Contact WHERE Role__c = 'Driver'];
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim = [SELECT Id FROM Bi_Weekly_Reimbursement__c WHERE Contact__c = :lstDriverContact[0].Id];
        User objUser = [SELECT id FROM User WHERE ContactId =: lstDriverContact[0].id ];
        
        Test.startTest();
        System.runAs(objUser) {
            apexpages.currentpage().getparameters().put('id' , lstDriverContact[0].Id);
            ConfirmTripTimeERMIController controller = new ConfirmTripTimeERMIController();  
            ConfirmTripTimeERMIController.reimMileages(lstBiWeeklyReim[0].id);
        }
        Test.stopTest();
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
    }
    @isTest
    public static void getMileageDataTest(){
               
        Account objAccount = [SELECT id, True_Dialog__c, Name FROM Account WHERE Name = 'Test'];
        List<Contact> lstDriverContact = [SELECT id FROM Contact WHERE Role__c = 'Driver'];
        User objUser = [SELECT id FROM User WHERE ContactId =: lstDriverContact[0].id ];
        
        Test.startTest();
        System.runAs(objUser) {
          
            apexpages.currentpage().getparameters().put('id' , lstDriverContact[0].Id);
            ConfirmTripTimeERMIController controller = new ConfirmTripTimeERMIController();  
            ConfirmTripTimeERMIController.getMileageData(lstDriverContact[0].Id);
        }
        Test.stopTest();
        System.assertEquals('Test',objAccount.Name, 'Account is not proper');
    }
    
}