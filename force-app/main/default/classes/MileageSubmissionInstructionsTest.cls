@isTest
public class MileageSubmissionInstructionsTest {
	@isTest
    public static void mileageSubmissionTestMethod() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'SendEmailForSubmittedMileage');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account acc ;
        List<Contact> conList;
       
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test Accounts',true);
           
            conList = TestDataFactory.createDriverContact(false, accountObj.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].External_Email__c = 'minkesh.patel1478@gmail.com';
            conList[0].Mileage_submission_instructions__c  = true;
            insert conList[0];
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
         //List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-7),System.today().addDays(-1), 1, createIRSRate.Id);
        
        Test.startTest();
        
        MileageSubmissionInstructions b = new MileageSubmissionInstructions();
		database.executeBatch(b);
        
      	Test.stopTest();
    }
}