@isTest
private class ConfirmTripTimeERMIControllerTest {
    @isTest
    static void utilMethod1() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        SendEmail__c sendEmailCustomSetting2 = TestDataFactory.sendEmailCustomSetting(true,'ConfirmTripTimeERMIController');
        SendEmail__c sendEmailCustomSetting3 = TestDataFactory.sendEmailCustomSetting(true,'ConfirmTripSyncErmi');
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {            
            
            acc = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, conList, 10, irsRateObj.id);
        system.assertEquals(11, reimList.size(),true);
        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim(true, conList, system.today().adddays(-14), system.today().addDays(-1), 10, irsRateObj.id);
        Attachment attach = TestDataFactory.createAttachment(true, conList[0].id);
        List<Attachment> attachments = [select id, name from Attachment where parent.id =: conList[0].id];
        
        Test.startTest();
        System.runAs(userObj) {
            string conId =  conList[0].id;
            String json = '[{\"biWeekId\":\"'+biWeeklyReimList[0].id + '\",\"confirmCheck\":true,\"errorCheck\":false,\"countErrorCheck\":0,\"driverEmail\":\"meghac.mobio@gmail.com\",\"driverName\":\"Megha\",\"biWeekPayperiod\":\"03/09/2022 to 03/22/2022\",\"mileage\":0,\"driveTime\":\"0\",\"stayTime\":\"0\",\"totalTime\":\"0\"}]';
            apexpages.currentpage().getparameters().put('id' , conId);
            ConfirmTripTimeERMIController controller = new ConfirmTripTimeERMIController();  
            ConfirmTripTimeERMIController.syncTripsForErmi (conId,'03/07/2022','03/12/2022'); 
            ConfirmTripTimeERMIController.UpdateBiWeekData(json );    
             ConfirmTripTimeERMIController.getMileageData(conId);  
            ConfirmTripTimeERMIController.reimMileages(biWeeklyReimList[0].id);  
        }
        Test.stopTest();
    }
    
}