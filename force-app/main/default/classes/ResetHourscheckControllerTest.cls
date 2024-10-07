@isTest
public class ResetHourscheckControllerTest {
    
    @TestSetup
    static void makeData(){
        
        UserRole objUserRole = TestDataFactory.getUserRole();
        Profile objProfile = TestDataFactory.getUserProfile();
        User objAdmin = TestDataFactory.getSystemAdminUser(objUserRole.Id);
        User objGenUser;
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10,12345);
        
        Vehicle_URL_Mapping__c objVehicleUrlMap = TestDataFactory.createVehicleData(false, 0);
        objVehicleUrlMap.Name = String.valueof(System.today().year())+ ' Full-Size Sedan';
        objVehicleUrlMap.vehicle__c = 'Full-Size Sedan';
        Insert objVehicleUrlMap;
        System.debug('vehicle url--@'+objVehicleUrlMap);
        
        Vehicle_URL_Mapping__c objVehicleUrlMap1 = [select Id,Name, Year__c, Vehicle__c, URL__c,Vehicle_Mapping__c from Vehicle_URL_Mapping__c];
        System.debug('vehicle url1--@'+objVehicleUrlMap1);
        
        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Atlanta';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().addmonths(-1).tostartofmonth();
        gasprice.State__c = 'AK';
        insert gasprice;

        Account objAccount2;
        List<Vehicle_Value__c> lstVehicleValue;
        
        System.runAs(objAdmin) {
           
            objAccount2 = TestDataFactory.createAccount(true,'Test',true);
            objAccount2.Pay_Period_Start_Date__c = System.today().addDays(-100);
            objAccount2.Vehicle_Types__c = String.valueof(System.today().year())+ ' Full-Size Sedan';
            update objAccount2;
            
            lstVehicleValue = TestDataFactory.createVehicleValue(true, objAccount2.Id, objVehicleUrlMap1.Id);
            
            List<Contact> lstContact =TestDataFactory.createDriverContact(true, objAccount2.Id, 'Driver', objVehicleUrlMap.Name, 'testContact1', 1);
            List<Employee_Reimbursement__c> lstEmpReim =TestDataFactory.createPendingReimbursement(true,lstContact, 1, irsRateObj.Id);
            List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim =TestDataFactory.createBiweeklyReim(true, lstContact, System.TODAY(), System.TODAY().addDays(7), 1, irsRateObj.Id);
            List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 1, lstEmpReim, lstBiWeeklyReim);
        }

    }
 
    @isTest
    static void testResetFields() {
        // Retrieve the test data created in @testSetup
        Bi_Weekly_Reimbursement__c objBiWeeklyReim = [SELECT Id, Confirm_Hours__c, Error_Hours__c, Count_Error_Check__c FROM Bi_Weekly_Reimbursement__c LIMIT 1];
        
        Test.startTest();
        
        // Create the standard controller and custom controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(objBiWeeklyReim);
        ResetHourscheckController controller = new ResetHourscheckController(stdController);
        
        // Call the resetFields method
        controller.resetFields();
        
        Test.stopTest();
        // Retrieve the updated record
        objBiWeeklyReim = [SELECT Id, Confirm_Hours__c, Error_Hours__c, Count_Error_Check__c FROM Bi_Weekly_Reimbursement__c WHERE Id = :objBiWeeklyReim.Id];
        
        // Assert that the fields were reset
        System.assertEquals(false, objBiWeeklyReim.Confirm_Hours__c, 'Confirm_Hours__c should be false');
        System.assertEquals(false, objBiWeeklyReim.Error_Hours__c, 'Error_Hours__c should be false');
        System.assertEquals(0, objBiWeeklyReim.Count_Error_Check__c, 'Count_Error_Check__c should be 0');
        
        // Assert that the refreshPage property is set to true
        System.assertEquals(true, controller.refreshPage, 'refreshPage should be true');
    }
}