/**
 * @description       : 
 * @author            : Vatsal Bhalani
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : Vatsal Bhalani
**/
@isTest
public class updateTenthMsgBatchTest {

	@testSetup 
    static void setupData(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10,12345);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 0);
        vehicleType.Name = String.valueof(System.today().year())+ ' Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;   
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;
        List<Contact> conList1;
        List<Contact> conList2;
        List<Contact> conList3;
        List<Contact> conList4;
        List<Contact> lstContact = new List<Contact>();
         
        System.runAs(admin) {
			acc = TestDataFactory.createAccount(true,'TestAccount',true);

            conList1 = TestDataFactory.createDriverContact(true,acc.Id,'Driver/Admin', vehicleType.Name, 'Test', 1);
            lstContact.addAll(conList1);
            conList2 = TestDataFactory.createDriverContact(true,acc.Id,'Driver', vehicleType.Name, 'Test', 1);
            lstContact.addAll(conList2);
            conList3 = TestDataFactory.createDriverContact(true,acc.Id,'Driver/Manager', vehicleType.Name, 'Test', 1);
            lstContact.addAll(conList3);

            List<Employee_Reimbursement__c> lstEmpReim =TestDataFactory.createPendingReimbursement(true,lstContact, 4, irsRateObj.Id);
            List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim =TestDataFactory.createBiweeklyReim(true, lstContact, System.TODAY(), System.TODAY().addDays(7), 1, irsRateObj.Id);
            List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 1, lstEmpReim, lstBiWeeklyReim);
		}
        
    }
    
    @isTest
    static void testBatch(){
		Test.startTest();
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE role__c = 'Driver/Admin' LIMIT 1];
        updateTenthMsgBatch job = new updateTenthMsgBatch ( );
       	Database.executeBatch( job );
        System.assertEquals(1, lstContact.size(), 'Assert Error');
        Test.stopTest();
    }
    
}