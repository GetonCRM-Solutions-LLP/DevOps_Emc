@isTest
public class reimbursementPrevMonthDetailsBatchTest {
    @isTest
    public static void prevMonthDetailsTest(){
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);

        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(false, 3);
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Denver';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-1);
        gasprice.State__c = 'CA';
        insert gasprice;

        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;
        Contact con1 = new Contact();
        
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Name = 'Test Accounts';
            acc.isUsingTriplog__c = true;
            insert acc;

            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = acc.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2019 Full-Size Sedan';
            con1.MailingCity = 'Atlanta';
            con1.MailingState = 'GJ';
            con1.Employee_ID__c = '234343456';
            
            insert con1;
        }

        String monthName = '01-2023';
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con1.Id;
        er.Name = con1.Name + ':' + monthName;
        er.Month__c = monthName;
        er.Fuel_Price__c = 6.78;
        er.MPG__c = 14.00;
        er.Status__c = 'Approved';
        er.Approved_Date__c = System.today();
        er.Prev_Approved_Date_Value__c = er.Approved_Date__c;
        er.Prev_Status_Value__c = er.Status__c;
        er.Mileage_Lock_Date__c = null;
        insert er;

        Test.startTest();
        List<String> monthLst = new List<String>{'01-2023'};
        reimbursementPrevMonthDetailsBatch batch = new reimbursementPrevMonthDetailsBatch(monthLst);
        database.executebatch(batch);
        Test.stopTest();
    }
}