@isTest
public class PayDateReportControllerTest {
    @isTest
    public Static void biWeeklyTest(){
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
            acc = TestDataFactory.createAccount(true,'Test',true);

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

        Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = '12/25/2022 to 01/07/2023'; 
            br.Contact__c = con1.Id;
            br.Start_Date__c = Date.valueOf('2022-12-25');
            br.End_Date__c = Date.valueOf('2023-01-07') ;
            br.MPG__c = con1.MPG__c;
            br.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
            br.Fixed_Amount__c = con1.Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Fuel_Price__c = gasprice.Fuel_Price__c;
        Insert br;

        Test.startTest();
        Test.setCurrentPage(Page.PayDateReport);
        String accId = ApexPages.currentPage().getParameters().put('id',acc.Id);
        String startDate = ApexPages.currentPage().getParameters().put('startDate','2022-12-25');
        String endDate = ApexPages.currentPage().getParameters().put('endDate','2023-01-07');
        PayDateReportController objClass = new PayDateReportController();
        Test.stopTest();
    }
}