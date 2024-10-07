@isTest
public class ImportLocationControllerTest {
    @isTest
    static void emailChangeNotificationTest1() {
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10, 0956);
        //List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 4);
        // vehicleType.Name = '2020 Full-Size Sedan';
        // vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;
        
        List<Contact> conList;
        List<Vehicle_Value__c> vehValue;
        
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            
            vehValue = TestDataFactory.createVehicleValue(true, acc.Id, vehicleType.Id);
            
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Deactivated_Date__c = system.today();
            conList[0].Vehicle_Value__c = vehValue[0].Value__c;
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].Activation_Date__c = system.today().adddays(-9);   
            conList[0].App__c = 'V-1.1';
            Insert conList[0];
            
        }
       
        schema.Location loc = new schema.Location();
        loc.Name = 'Test';
        loc.Driver__c = conList[0].Id;
        loc.Range__c = 300;
        loc.Location_Address__c = 'Test Address';
        insert loc;
        
        String jsonGen = ImportLocationController.getLocation(conList[0].Id);
        ImportLocationController.updateLocation(jsonGen,conList[0].Id,jsonGen);
        ImportLocationController.updateLocationMlog(jsonGen,conList[0].Id,jsonGen);
        ImportLocationController.jsonCollectionCommon(jsonGen,conList[0].Id);
    }
}