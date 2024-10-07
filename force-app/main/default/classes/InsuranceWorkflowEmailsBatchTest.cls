@isTest
public class InsuranceWorkflowEmailsBatchTest {
		@testSetup 
    static void setupData(){
		TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRate = TestDataFactory.createIRSRate(true,0);

        UserRole uRole = TestDataFactory.getUserRole();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        
			System.runAs(admin){
            Account acc = TestDataFactory.createAccount(true,'Test',true);

            List<Contact> con = TestDataFactory.createDriverContact(false,acc.id,'Driver/Admin',veh.Name,'testmail',10);
            for(Integer i = 0; i < con.size(); i++) {
                if(Math.mod(i, 2) == 0) { // Math.mod is used instead of % for modulus operation
                    con[i].Expiration_Date__c = Date.today();
                } else {
                    con[i].Expiration_Date__c = Date.today().addMonths(1);
                }
            }
            insert con;
    	}
	}
    
    @isTest
    static void EmailsBatchTest(){
        List<Account> acc = [SELECT Name FROM ACCOUNT];
        List<String> accNames = new List<String>();
        for(Account a : acc){
            accNames.add(a.Name);
        }
		Test.startTest();
        InsuranceWorkflowEmailsBatch job1 = new InsuranceWorkflowEmailsBatch(accNames);
       	Database.executeBatch( job1 );
        Test.stopTest();
    }
                              
	@isTest
    static void NoAccNameEmailsBatchTest(){
		Test.startTest();
        InsuranceWorkflowEmailsBatch job2 = new InsuranceWorkflowEmailsBatch();
       	Database.executeBatch( job2 );
        Test.stopTest();
    }

    @isTest
    static void ScheduleEmailsBatchTest(){
		Test.startTest();
		InsuranceWorkflowEmailsBatch schedulable = new InsuranceWorkflowEmailsBatch();
        schedulable.execute(null);
        Test.stopTest();
    }
}