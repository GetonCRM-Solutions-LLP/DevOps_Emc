@isTest
public class BiweeklyPayPeriodTest {
    public BiweeklyPayPeriodTest() {
    }
    public static testmethod void test1(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        List<Contact> adminConList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account accountObj;
        System.runAs(admin) {
            accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            conList[0].Activation_Date__c = system.today();
            conList[0].Fixed_Amount__c = 371.28;
            conList[0].MailingCity = 'Abilene';
            conList[0].MailingState = 'TX';
            conList[0].Time_Zone__c = 'US/Mountain' ;
            conList[0].Driving_States__c = 'TX';
            conList[0].Fixed_Amount__c = 322.00;
            conList[0].Maintenance_and_Tires__c = 1.2;
            conList[0].MPG__c= 10.00;
            conList[0].Monthly_Mileage_Limit__c = 100.00;

            update conList;

            adminConList = TestDataFactory.createDriverContact(true, acc.Id, 'Admin', vehicleObj.Name, 'test1.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, conList, 1, irsRateObj.Id);
        er[0].Approved_Date__c = system.today()-4;
        er[0].Month__c = lastMonth;
        er[0].Status__c = 'Approved';
        Insert er[0];        

        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-26),System.today().addDays(-13), 1, irsRateObj.Id);
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (True, 0, er, br);
        emp1[0].Trip_Date__c =  date.today().adddays(-1);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].Approved_Date__c = system.today();
        Update emp1;

        /*List<Employee_Mileage__c> emp2 = TestDataFactory.getEmpMileage (True, 0, er, br);
        emp2[0].Trip_Date__c = date.today().adddays(-1);
        emp2[0].Trip_Status__c = 'Approved';
        emp2[0].Approved_Date__c = system.today();
        Update emp2;  */   
        
        Test.startTest();
        System.runAs(userObj) {
            integer i = 0;
        BiweeklyPayPeriod.getTimeAndAttendance(conList[0].Id, '2023');
        BiweeklyPayPeriod.getPayPeriodDates(conList[0].Id, 2022);
        BiweeklyPayPeriod.getBiweeklyMileage(conList[0].Id, 2022);
        BiweeklyPayPeriod.getMileages1(system.today()-1, system.today(), conList[0].Id);
        BiweeklyPayPeriod.getAllBiweekMileages1(system.today()-1, system.today(), conList[0].Id);
        BiweeklyPayPeriod.ApproveTrips(system.today()-1, system.today(), conList[0].Id);
        BiweeklyPayPeriod.calculateBiweekMil (String.valueof(system.today()-1),String.valueof(system.today()), conList[0].Id);
        BiweeklyPayPeriod.getBiweeklyReimbursement(String.valueOf(conList[0].Id) ,2023);
        BiweeklyPayPeriod.getBiweekMileages1(string.valueOf(br));
        BiweeklyPayPeriod.ApproveBiWeekTrips(string.valueOf(br));
        BiweeklyPayPeriod.payPeriodDateList(accountObj.Id);
      }
        Test.stopTest();
    }
}