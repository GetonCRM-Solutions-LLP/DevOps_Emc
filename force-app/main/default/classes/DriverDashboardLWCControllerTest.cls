@isTest
public with sharing class DriverDashboardLWCControllerTest {
    @isTest
    public static void driverDashboardTest(){
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        IRS_Mileage_Rate__c irsRate = TestDataFactory.createIRSRate(true,2023);

        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Atlanta';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-12);
        gasprice.State__c = 'AK';
        insert gasprice;
        
        Gas_Prices__c gasprice1 = new Gas_Prices__c();
        gasprice1.City__c = 'Atlantaa';
        gasprice1.Fuel_Price__c = 3;
        gasprice1.Month_Year__c = Date.today().adddays(-40);
        gasprice1.State__c = 'AK';
        insert gasprice1;

        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        User DriverUser;
                
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
            con1.Vehicle_Type__c = '2024 Mileage Rate';
            con1.Employee_ID__c = '234343456';

            con1.Time_Zone__c = 'US/Mountain';
            con1.Driver_Type__c = 'Driver - Full Time';
            con1.Deactivated_Date__c = null;
            con1.Insurance_Attachment_Id__c = Null; 
            con1.monthly_compliance_status__c = 'Yes';
            con1.ReimbursementStatementBatch__c = true;            
            con1.Manager__c = null;   
            con1.Monthly_Mileage_Limit__c = -1;  
            con1.MailingState = 'AK';
            con1.MailingCity = 'Atlanta';
            con1.Cell_Phone__c='Employee Provide';
            con1.Reimbursement_Frequency__c='Monthly Reimbursement';
            con1.Activation_Date__c=system.today();
            insert con1;
        }	
        list<contact> conList1=new list<contact>();
        conList1.add(con1);
        List<Employee_Reimbursement__c>reim =new List<Employee_Reimbursement__c>();
        List<Bi_Weekly_Reimbursement__c> biweek= new List<Bi_Weekly_Reimbursement__c>();
        reim = TestDataFactory.createPendingReimbursement(true,conList1,1,irsRate.id);
        
        biweek =TestDataFactory.createBiweeklyReim(true,conList1,system.today().addDays(-15),system.today(),1,irsRate.id);
        List<Employee_Mileage__c> emp =new List<Employee_Mileage__c>();
        emp=TestDataFactory.getEmpMileage(false,3,reim,biweek);
            emp[0].EMP_Mileage__c=1500;
            for(Employee_Mileage__c em :emp){
                em.Approved_Date__c = System.today();
				em.Trip_Status__c='Approved';
            }
            insert emp;
        DriverUser=  TestDataFactory.createUser(true,profileObj.id,con1.id);

        List<Contact> conList = TestDataFactory.createDriverContact(true,acc.Id,'Driver',veh.Name,'niraj',2);
        List<Employee_Reimbursement__c> reimbursement = TestDataFactory.createPendingReimbursement(true,conList,1,irsRate.Id);
        List<Bi_Weekly_Reimbursement__c> biReim = TestDataFactory.createBiweeklyReim(true,conList,Date.valueOf('2022-12-25'),Date.valueOf('2023-01-07'),1,irsRate.Id);
        List<Employee_Mileage__c> mileages = TestDataFactory.getEmpMileage(false,1,reimbursement,biReim);
        mileages[0].Trip_Status__c = 'Approved';
        mileages[0].Approved_Date__c = system.today();
        insert mileages[0] ;
        Test.startTest();
        DriverDashboardLWCController.getContactid();
        DriverDashboardLWCController.getDriverDetails(conList[0].Id);
        DriverDashboardLWCController.getDriverDetailsClone(conList[0].Id);
        DriverDashboardLWCController.getDrivingState(conList[0].Id);
        DriverDashboardLWCController.getCompanyLogoUrl(acc.Id);
        DriverDashboardLWCController.getMileages('01',String.valueOf(Date.today().year()),con1.Id);
        DriverDashboardLWCController.getMileagesData(Date.today().year(),con1.Id);
        DriverDashboardLWCController.getChartData(conList[0].Id);
        DriverDashboardLWCController.getAllReimbursements(String.valueOf(System.today().year()),conList[0].Id,acc.Id);
        DriverDashboardLWCController.getGasPriceandRate(con1.id);
        DriverDashboardLWCController.getLast2Years(conList[0].Id);
        DriverDashboardLWCController.TimeAttendance(conList[0].Id,'2023');
        DriverDashboardLWCController.getMileagesBasedTandAtt('2022-12-25','2023-01-07',conList[0].Id);
        DriverDashboardLWCController.biweeklyMileage(conList[0].Id,2023);
        DriverDashboardLWCController.getAllMileages('2022-12-25','2023-01-07',conList[0].Id);
        DriverDashboardLWCController.getCompliance(con1.id);
        DriverDashboardLWCController.getFuelVariableRate(con1.id);
        DriverDashboardLWCController.getReimbursementData(con1.id);
        DriverDashboardLWCController.getPacketandMeeting(con1.id);
        DriverDashboardLWCController.getCustomSettings();
        DriverDashboardLWCController.getPlanParameter(conList[0].Id);
        //DriverDashboardLWCController.getBiweekMileages(biReim[0].Id);
        //DriverDashboardLWCController.ApproveBiweekMileages(biReim[0].Id);
        DriverDashboardLWCController.countUserLogin(con1.id);
        DriverDashboardLWCController.getDrivingStates();
        DriverDashboardLWCController.sendDrivingStateEmail(String.valueOf(conList[0].Id),String.valueOf(conList[0].Driving_States__c));
        String drivingState=String.valueOf(conList[0].Driving_States__c);
        DriverDashboardLWCController.updateStateList(String.valueOf(conList[0].Id),String.valueOf(conList[0].Driving_States__c));
        DriverDashboardLWCController DLC= new DriverDashboardLWCController();
        
        DriverDashboardLWCController.planParameterWrap wrapObj = new DriverDashboardLWCController.planParameterWrap ();
        wrapObj.driverPacketId='xxxx';
        wrapObj.driverMVR='xxxx';
        wrapObj.obj_content_version='xxxx';
        
        Test.stopTest();
    }
    
}