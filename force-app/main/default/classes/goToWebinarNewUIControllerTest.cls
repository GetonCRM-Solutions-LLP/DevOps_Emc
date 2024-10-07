@isTest
public class goToWebinarNewUIControllerTest {
    @isTest
    public static void goToWebinarControllerTestMethod(){
         Test.setMock(HttpCalloutMock.class, new GoToWebinarMockCallout());
        TriggerConfig__c triggerConfigCustomSetting = TestDataFactory.triggerConfigCustomSetting(True);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(True, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehType = TestDataFactory.createVehicleData(True, 3);
        IRS_Mileage_Rate__c objIRSMileageRate = TestDataFactory.createIRSRate(True, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
       
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        
        List<Contact> objadminContact;
        Account objAcc;
        List<Contact> objManagerList;
        List<Contact> objDriverContact;
        System.runAs(admin) {
            objAcc = TestDataFactory.createAccount(True, 'PL Marketing', True);
            objDriverContact = TestDataFactory.createDriverContact(true, objAcc.Id, 'Driver', vehType.Name, 'parasm.patel', 1);
            
            userObj = TestDataFactory.createUser(True, profileObj.Id, objDriverContact[0].Id);
        }
        
        Test.startTest();
        goToWebinarNewUIController.registerWebinar(objDriverContact[0].firstName, objDriverContact[0].lastName, objDriverContact[0].External_Email__c);
        goToWebinarNewUIController.registerWebinarCallout(objDriverContact[0].firstName, objDriverContact[0].lastName, objDriverContact[0].External_Email__c, objAcc.Id);
        goToWebinarNewUIController.recordingURL(objAcc.Id);
        goToWebinarNewUIController.getWebinarName(objAcc.Id);
        goToWebinarNewUIController.urlMaking('Testing Webinar5','2022-11-16','2022-11-16','America/Denver','0x55b22763','0x55b22763',null,'1652420166782966283');
        goToWebinarNewUIController.urlMakingforOutlook('Testing Webinar5','America/Denver','0x55b22763','0x55b22763',null,'1652420166782966283','2022 11 16','2022 11 16');
        goToWebinarNewUIController.dates('2022-11-16');
        Test.stopTest();
            
    }

}