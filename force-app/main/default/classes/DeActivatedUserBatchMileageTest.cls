@isTest
public class DeActivatedUserBatchMileageTest {
    @isTest
    public static void mileageTest() {

        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2020 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;
        Set<String> accIdList = new Set<String>();
        Set<String> conIdList = new Set<String>();
        List<Contact> conList;
        List<Vehicle_Value__c> vehValue;
         
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            update acc;
            accIdList.add(acc.Id);           
            vehValue = TestDataFactory.createVehicleValue(true, acc.Id, vehicleType.Id);
            
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Vehicle_Value__c = vehValue[0].Value__c;
            conList[0].Deactivated_Date__c = system.now();
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].Activation_Date__c = system.today().adddays(-9);   
            Insert conList[0];
            conIdList.add(conList[0].Id);
            
            conList[0].compliancestatus__c = 'No – Vehicle Age';
            update conList[0];
            
            system.assertEquals(1, conList.size(), true);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contactObj.Id);
        } 

        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Denver';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-1);
        gasprice.State__c = 'CA';
        insert gasprice;

        String lastMonth = Utils.fetchMonths(1, 0)[0];
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, conList, 1, irsRateObj.Id);
        er[0].Approved_Date__c = system.today()-4;
        er[0].Month__c = lastMonth;
        er[0].Status__c = 'Pending';
        Insert er[0];        

         List<String> contactIds=new List<String>();
        contactIds.add(conList[0].id);
        

        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new DeActivatedUserBatchCalloutMock());
        DeActivatedUserBatchMileage batchmileageobj = new DeActivatedUserBatchMileage();
        DataBase.executeBatch(batchmileageobj,1); 
        
        DeActivatedUserBatchMileage batchmileageacc = new DeActivatedUserBatchMileage(acc.id);
        DataBase.executeBatch(batchmileageacc,1);
        
        DeActivatedUserBatchMileage batchmileagecon = new DeActivatedUserBatchMileage(contactIds);
        DataBase.executeBatch(batchmileagecon,1);
        
        Test.stopTest();
    }
}