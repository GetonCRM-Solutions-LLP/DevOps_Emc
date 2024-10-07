@isTest
public class ReportDetailsController_test {
    public static boolean flag {get;set;}
     public static testmethod void TestMethod1() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(false);
        triggerCustomSetting.ContactTriCommunityReimCreate__c = false;
        insert triggerCustomSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        flag= false;
         IRS_Mileage_Rate__c irsRate = TestDataFactory.createIRSRate(true,2023);
         Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        List<Contact> driverlist;
        Account obj_account;
         Account obj_account2;
         Account obj_account3;
        Contact obj_admin;
        Contact obj_manager;
         List<Contact> driverContactList;
        System.runAs(admin) {
            driverlist = insertrecords();
            // insertReimbursements(driverlist);            
            obj_account = new Account( Name = 'Community',Pay_Period_Days__c = 13,  Pay_Period_Start_Date__c = system.today().adddays(-30),Triplog_API__c = '75b59c50cefa4f8f9c3b5e824944ffe5');
            insert obj_account ;
            obj_account2 = new Account( Name = 'Test',Pay_Period_Days__c = 13,  Pay_Period_Start_Date__c = system.today().adddays(-30),Triplog_API__c = '75b59c50cefa4f8f9c3b5e824944ffe5');
            insert obj_account2 ;
            obj_account3 = new Account( Name = 'Test2', Trip_Status_Lock__c = system.today(), Pay_Period_Days__c = 13,  Pay_Period_Start_Date__c = system.today().adddays(-30),Triplog_API__c = '75b59c50cefa4f8f9c3b5e824944ffe5');
            insert obj_account3 ;
            Test.setCreatedDate(obj_account2.Id, Datetime.now().addDays(-1));
            system.debug('obj_account2==' );
            obj_admin =RecordUtilityClass.getAdminContact();
            obj_manager =RecordUtilityClass.getManagerContact();
            Contact contactObj = TestDataFactory.createCICDContact(true,obj_account.Id);
            driverContactList = TestDataFactory.createDriverContact(true,obj_account.Id,'Driver',veh.Name,'niraj',2);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contactObj.Id);
            IRS_Mileage_Rate__c objIRSMileageRate = TestDataFactory.createIRSRate(True, 3);
            List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, driverContactList, 1, objIRSMileageRate.Id);
            // reimList[0].Month__c = String.valueOf(System.now().format('MM-YYYY'));
            // reimList[0].Name = driverContactList[0].Name + ':' + String.valueOf(System.now().format('MM-YYYY'));
            reimList[0].Approved_Date__c = System.today();
            reimList[0].Status__c = 'Approved';
            update reimList;

            driverContactList[0].Deactivated_Date__c = driverContactList[0].Activation_Date__c.addDays(2);
            update driverContactList;
        }

        Custom_Report__c rep = createReport('Select id from Contact','Contact Created Between 2 Dates');
        insert rep;
        Test.startTest();
        System.runAs(userObj) {
            Test.setCurrentPage(Page.reportdetail);
            String reportid = ApexPages.currentPage().getParameters().put('reportid',rep.Id);
            String accId = ApexPages.currentPage().getParameters().put('accid',obj_account.Id);
            String conid = ApexPages.currentPage().getParameters().put('id',obj_admin.Id);
            
            ReportDetailsController obj_ReportDetailsController = new ReportDetailsController();
            ReportDetailsController.getAllReportHeaders(rep.id);
            ReportDetailsController.getRedirected();
            ReportDetailsController.gerAccountStatus(obj_account2.Id);
            ReportDetailsController.gerAccountStatus(obj_account3.Id);
            ReportDetailsController.getAllManagers(obj_account.Id,'Driver');
            ReportDetailsController.getAllManagers(obj_account.Id,'Manager');
             ReportDetailsController.getPayPeriodDates(driverlist[0].Id, 2023);
             ReportDetailsController.accountMonthList(obj_account.Id);
             ReportDetailsController.monthList(obj_account.Id);
            ReportDetailsController.monthList(obj_account2.Id);
            ReportDetailsController.getAllDrivers(obj_account.Id);
            ReportDetailsController.getCompliance(driverlist[0].Id, '2022');

            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep.Id),'Driver','',1);

            Custom_Report__c rep1 = createReport('Select id from Contact','Contact Activation Between 2 Dates');
            insert rep1;
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep1.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep1.Id),'Driver','',1);

            Custom_Report__c rep2 = createReport('Select id from Contact','Contact Deactivation Between 2 Dates');
            insert rep2;
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep2.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep2.Id),'Driver','',1);

            Custom_Report__c rep3 =createReport('Select id from Contact','Without Date Range');
            insert rep3;
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,'','','',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep3.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,obj_manager.id,'','',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep3.Id),'Driver','',1);

            Custom_Report__c rep4 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Created Between 2 Dates');
            insert rep4;
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep4.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep4.Id),'Driver','',1);

            Custom_Report__c rep5 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Between 2 Deactivation Dates');
            insert rep5;
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep5.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep5.Id),'Driver','',1);

            Custom_Report__c birep4 =createReport('select id from Bi_Weekly_Reimbursement__c','BiWeek Reimbursement Start and EndDate');
            insert birep4 ;
            //ReportDetailsController.getAllReportSoql(birep4.Report_Soql__c,birep4.Report_Type__c,'','12/12/2018','1/12/2019',obj_admin.Id,obj_account.Id,birep4.Id,'Driver','06-2023');
            //ReportDetailsController.getAllReportSoql(birep4.Report_Soql__c,birep4.Report_Type__c,obj_manager.id,'12/12/2018','1/12/2019',obj_admin.Id,obj_account.Id,birep4.Id,'Driver','06-2023');
            
            Custom_Report__c rep6 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Between 2 Dates For Month Range');
            insert rep6;
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,'','12/12/18','1/12/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep6.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep6.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep6.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,obj_manager.id,'12/12/18','1/12/19','',string.valueof(obj_account.Id),string.valueof(rep6.Id),'Driver','',1);
            
            Custom_Report__c rep7 =createReport('Select id from Employee_Reimbursement__c','Without Date Range');
            insert rep7;
            ReportDetailsController.getAllReportSoql(rep7.Report_Soql__c,rep7.Report_Type__c,'','12/12/18','1/12/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep7.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep7.Report_Soql__c,rep7.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep7.Id),'Driver','06-2023',1);
    
            Custom_Report__c rep8 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Between 2 Dates For Month Range');
            insert rep8;
            ReportDetailsController.getAllReportSoql(rep8.Report_Soql__c,rep8.Report_Type__c,'','01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep8.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep8.Report_Soql__c,rep8.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep8.Id),'Driver','06-2023',1);
    
            Custom_Report__c rep9 =createReport('Select id from Employee_Reimbursement__c','Without Date Range');
            insert rep9;
            ReportDetailsController.getAllReportSoql(rep9.Report_Soql__c,rep9.Report_Type__c,'','01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep9.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep9.Report_Soql__c,rep9.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep9.Id),'Driver','06-2023',1);
    
            Custom_Report__c rep10 =createReport('Select id from Employee_Mileage__c','Without Date Range');
            insert rep10;
            ReportDetailsController.getAllReportSoql(rep10.Report_Soql__c,rep10.Report_Type__c,'','01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep10.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep10.Report_Soql__c,rep10.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep10.Id),'Driver','06-2023',1);
            
            Custom_Report__c rep11 =createReport('Select id from Employee_Mileage__c','Mileages Created Between 2 Dates');
            insert rep11;
            ReportDetailsController.getAllReportSoql(rep11.Report_Soql__c,rep11.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep11.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep11.Report_Soql__c,rep11.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep11.Id,'Driver','06-2023',1);
    
            Custom_Report__c rep12 =createReport('Select id from Employee_Mileage__c','Mileages Between 2 Deactivation Dates');
            insert rep12;
            ReportDetailsController.getAllReportSoql(rep12.Report_Soql__c,rep12.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep12.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep12.Report_Soql__c,rep12.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep12.Id,'Driver','06-2023',1);
    
            Custom_Report__c rep13 =createReport('Select id from Employee_Mileage__c','Mileages Between 2 Dates for Month Range');
            insert rep13;
            ReportDetailsController.getAllReportSoql(rep13.Report_Soql__c,rep13.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep13.Report_Soql__c,rep13.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Driver','06-2023',1);
            //ReportDetailsController.getAllReportSoqlForDriver(obj_account.Id,obj_manager.id,rep13.Id);
            
            Custom_Report__c rep15 =createReport('Select id from Employee_Mileage__c','Mileages Between 2 Trip Dates');
            insert rep15;
            ReportDetailsController.getDriverManagerList(obj_account.Id,obj_admin.Id,rep15.Id);
            ReportDetailsController.getAllReportSoql(rep15.Report_Soql__c,rep15.Report_Type__c,'','01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep13.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep15.Report_Soql__c,rep15.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep13.Id),'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoqlForDriver(obj_account.Id,obj_admin.Id,rep15.Id);
    
            Contact drivercontact = RecordUtilityClass.getDriverContact();
            drivercontact.Deactivated_Date__c = System.today();
            update drivercontact;
            Custom_Report__c rep14 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Between 2 Deactivation Dates');
            insert rep14;
            ReportDetailsController.getAllReportSoql(rep14.Report_Soql__c,rep14.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep14.Id),'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep14.Report_Soql__c,rep14.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep14.Id),'Driver','',1);
            ReportDetailsController.builTripsDate('7/1/2021');
            ReportDetailsController.getAllReportSoqlForManager(obj_account.Id,obj_manager.id,rep14.Id);     
            ReportDetailsController.postTotalReimbursementForAllUser(obj_account.Id);
           
        }
        Test.stopTest(); 
        
     }
     public static testmethod void TestMethod2() {      
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(false);
        triggerCustomSetting.ContactTriCommunityReimCreate__c = false;
        insert triggerCustomSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        flag= true;  
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        List<Contact> driverlist;
        Account obj_account;
        Contact obj_admin;
        Contact obj_manager;
        List<Contact> driverContactList;
        System.runAs(admin) {
            driverlist = insertrecords();
            // insertReimbursements(driverlist);            
            obj_account = new Account( Name = 'Community',Pay_Period_Days__c = 13, Triplog_API__c = 'ghjfkghdf56456445',  Pay_Period_Start_Date__c = system.today().adddays(-30));
            insert obj_account ;
            obj_admin =RecordUtilityClass.getAdminContact();
            obj_manager =RecordUtilityClass.getManagerContact();
            Contact contactObj = TestDataFactory.createCICDContact(true,obj_account.Id);
            driverContactList = TestDataFactory.createDriverContact(true,obj_account.Id,'Manager',veh.Name,'niraj',2);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contactObj.Id);
            IRS_Mileage_Rate__c objIRSMileageRate = TestDataFactory.createIRSRate(True, 3);
            List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, driverContactList, 1, objIRSMileageRate.Id);
            // reimList[0].Month__c = String.valueOf(System.now().format('MM-YYYY'));
            // reimList[0].Name = driverContactList[0].Name + ':' + String.valueOf(System.now().format('MM-YYYY'));
            reimList[0].Approved_Date__c = System.today();
            reimList[0].Status__c = 'Approved';
            update reimList;

            driverContactList[0].Deactivated_Date__c = driverContactList[0].Activation_Date__c.addDays(2);
            update driverContactList;
        }

        Custom_Report__c rep = createReport('Select id from Contact','Contact Created Between 2 Dates');
        insert rep;

        Test.startTest();
        System.runAs(userObj) {
            Test.setCurrentPage(Page.reportdetail);
            String reportid = ApexPages.currentPage().getParameters().put('reportid',rep.Id);
            String accId = ApexPages.currentPage().getParameters().put('accid',obj_account.Id);
            String conid = ApexPages.currentPage().getParameters().put('id',obj_admin.Id);
            ReportDetailsController obj_ReportDetailsController = new ReportDetailsController();
            ReportDetailsController.getAllReportHeaders(rep.id);
            ReportDetailsController.getRedirected();
            ReportDetailsController.getAllManagers(obj_account.ID,'Driver');
            ReportDetailsController.getAllManagers(obj_account.ID,'Manager');

            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),string.valueof(obj_admin.Id),string.valueof(obj_account.Id),string.valueof(rep.Id),'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep.Id,'Manager','',1);

            Custom_Report__c rep1 = createReport('Select id from Contact','Contact Activation Between 2 Dates');
            insert rep1;
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep1.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep1.Id,'Manager','',1);

            Custom_Report__c rep2 = createReport('Select id from Contact','Contact Deactivation Between 2 Dates');
            insert rep2;
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep2.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep2.Id,'Manager','',1);

            Custom_Report__c rep3 =createReport('Select id from Contact','Without Date Range');
            insert rep3;
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,'','','',obj_admin.Id,obj_account.Id,rep3.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,obj_manager.id,'','',obj_admin.Id,obj_account.Id,rep3.Id,'Manager','',1);

            Custom_Report__c rep4 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Created Between 2 Dates');
            insert rep4;
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep4.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep4.Id,'Manager','',1);

            Custom_Report__c rep5 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Between 2 Deactivation Dates');
            insert rep5;
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep5.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep5.Id,'Manager','',1);

            Custom_Report__c rep6 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Between 2 Dates For Month Range');
            insert rep6;
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,'','12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep6.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep6.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep6.Id,'Manager','06-2023',1);

            Custom_Report__c rep7 =createReport('Select id from Employee_Reimbursement__c','Without Date Range');
            insert rep7;
            ReportDetailsController.getAllReportSoql(rep7.Report_Soql__c,rep7.Report_Type__c,'','12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep7.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep7.Report_Soql__c,rep7.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep7.Id,'Manager','06-2023',1);
    
            Custom_Report__c rep8 =createReport('Select id from Employee_Reimbursement__c','Reimbursements Between 2 Dates For Month Range');
            insert rep8;
            ReportDetailsController.getAllReportSoql(rep8.Report_Soql__c,rep8.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep8.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep8.Report_Soql__c,rep8.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep8.Id,'Manager','06-2023',1);
    
            Custom_Report__c rep9 =createReport('Select id from Employee_Reimbursement__c','Without Date Range');
            insert rep9;
            ReportDetailsController.getAllReportSoql(rep9.Report_Soql__c,rep9.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep9.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep9.Report_Soql__c,rep9.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep9.Id,'Manager','06-2023',1);
    
            Custom_Report__c rep10 =createReport('Select id from Employee_Mileage__c','Without Date Range');
            insert rep10;
            ReportDetailsController.getAllReportSoql(rep10.Report_Soql__c,rep10.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep10.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep10.Report_Soql__c,rep10.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep10.Id,'Manager','06-2023',1);
            
            Custom_Report__c rep11 =createReport('Select id from Employee_Mileage__c','Mileages Created Between 2 Dates');
            insert rep11;
            ReportDetailsController.getAllReportSoql(rep11.Report_Soql__c,rep11.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep11.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep11.Report_Soql__c,rep11.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep11.Id,'Manager','06-2023',1);
    
            Custom_Report__c rep12 =createReport('Select id from Employee_Mileage__c','Mileages Between 2 Deactivation Dates');
            insert rep12;
            ReportDetailsController.getAllReportSoql(rep12.Report_Soql__c,rep12.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep12.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep12.Report_Soql__c,rep12.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep12.Id,'Manager','06-2023',1);
              
            Custom_Report__c rep13 =createReport('Select id from Employee_Mileage__c','Mileages Between 2 Dates for Month Range');
            insert rep13;
            
            Custom_Report__c rep15 = createReport('Select id from Employee_Mileage__c','Mileages Between 2 Trip Dates');
            insert rep15;
            ReportDetailsController.getDriverManagerList(obj_account.Id,obj_admin.Id,rep15.Id);
            ReportDetailsController.getAllReportSoql(rep15.Report_Soql__c,rep15.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep15.Report_Soql__c,rep15.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoqlForDriver(obj_account.Id,driverlist[0].Id,rep15.Id);
            
            ReportDetailsController.getAllReportSoql(rep13.Report_Soql__c,rep13.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep13.Report_Soql__c,rep13.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoqlForDriver(obj_account.Id,driverlist[0].Id,rep13.Id);
            ReportDetailsController.buildDateforTripDate('9/1/2020');
            ReportDetailsController.buildDateforBiweek('9/1/2020');
            ReportDetailsController.builTripsDate('7/1/2021');
            ReportDetailsController.getAllReportSoqlForManager(obj_account.Id,obj_manager.id,rep13.Id);
           
            Custom_Report__c rep14 =createReport('Select id from Employee_Reimbursement__c','Reimbursement Month');
            insert rep14;
            
            ReportDetailsController.getAllReportSoql1(rep14.Report_Soql__c,rep14.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql1(rep14.Report_Soql__c,rep14.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Manager','06-2023',1);
            ReportDetailsController.getAllReportSoql1(rep14.Report_Soql__c,rep14.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Driver','06-2023',1);
            
        }
        Test.stopTest();
     }
     public static testmethod void TestMethod5() {        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(false);
        triggerCustomSetting.ContactTriCommunityReimCreate__c = false;
        insert triggerCustomSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
         flag= false;
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        List<Contact> driverlist;
        Account obj_account;
        Contact obj_admin;
        Contact obj_manager;
        List<Contact> driverContactList;
        System.runAs(admin) {
            driverlist = insertrecords();
            // insertReimbursements(driverlist);
            obj_account = new Account( Name = 'Community',Pay_Period_Days__c = 13, Triplog_API__c = 'ghjfkghdf56456445546', Pay_Period_Start_Date__c = system.today().adddays(-30));
            insert obj_account ;
            obj_admin =RecordUtilityClass.getAdminContact();
            obj_manager =RecordUtilityClass.getManagerContact();
            Contact contactObj = TestDataFactory.createCICDContact(true,obj_account.Id);
            driverContactList = TestDataFactory.createDriverContact(true,obj_account.Id,'Driver',veh.Name,'niraj',2);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contactObj.Id);
            IRS_Mileage_Rate__c objIRSMileageRate = TestDataFactory.createIRSRate(True, 3);
            List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, driverContactList, 1, objIRSMileageRate.Id);
            // reimList[0].Month__c = String.valueOf(System.now().format('MM-YYYY'));
            // reimList[0].Name = driverContactList[0].Name + ':' + String.valueOf(System.now().format('MM-YYYY'));
            reimList[0].Approved_Date__c = System.today();
            reimList[0].Status__c = 'Approved';
            update reimList;

            driverContactList[0].Deactivated_Date__c = driverContactList[0].Activation_Date__c.addDays(2);
            update driverContactList;
        }

        Custom_Report__c rep = createReport('Select id from Contact where compliancestatus__c = \'Yes\'','Contact Created Between 2 Dates');
        insert rep;

        Test.startTest();
        System.runAs(userObj ) {
            Test.setCurrentPage(Page.reportdetail);
            String reportid = ApexPages.currentPage().getParameters().put('reportid',rep.Id);
            String accId = ApexPages.currentPage().getParameters().put('accid',obj_account.Id);
            String conid = ApexPages.currentPage().getParameters().put('id',obj_admin.Id);
            ReportDetailsController obj_ReportDetailsController = new ReportDetailsController();
            ReportDetailsController.getAllReportHeaders(rep.id);
            ReportDetailsController.getRedirected();
            ReportDetailsController.getAllManagers(obj_account.ID,'Driver');
            ReportDetailsController.getAllManagers(obj_account.ID,'Manager');

            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep.Report_Soql__c,rep.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep.Id,'Manager','',1);

            Custom_Report__c rep1 = createReport('Select id from Contact where Accountid=\''+obj_account.Id+'\'','Contact Activation Between 2 Dates');
            insert rep1;
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep1.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep1.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep1.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep1.Report_Soql__c,rep1.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep1.Id,'Manager','',1);

            Custom_Report__c rep2 = createReport('Select id from Contact where Accountid=\''+obj_account.Id+'\'','Contact Deactivation Between 2 Dates');
            insert rep2;
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep2.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep2.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep2.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep2.Report_Soql__c,rep2.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep2.Id,'Manager','',1);

            Custom_Report__c rep3 =createReport('Select id from Contact where Accountid=\''+obj_account.Id+'\'','Without Date Range');
            insert rep3;
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,'','','',obj_admin.Id,obj_account.Id,rep3.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,obj_manager.id,'','',obj_admin.Id,obj_account.Id,rep3.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,'','','',obj_admin.Id,obj_account.Id,rep3.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep3.Report_Soql__c,rep3.Report_Type__c,obj_manager.id,'','',obj_admin.Id,obj_account.Id,rep3.Id,'Manager','',1);

            Custom_Report__c rep4 =createReport('Select id from Employee_Reimbursement__c where Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Reimbursements Created Between 2 Dates');
            insert rep4;
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep4.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep4.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep4.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep4.Report_Soql__c,rep4.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep4.Id,'Manager','',1);

            Custom_Report__c rep5 =createReport('Select id from Employee_Reimbursement__c where Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Reimbursements Between 2 Deactivation Dates');
            insert rep5;
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep5.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep5.Id,'Driver','',1);
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,'',System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep5.Id,'Manager','',1);
            ReportDetailsController.getAllReportSoql(rep5.Report_Soql__c,rep5.Report_Type__c,obj_manager.id,System.now().addDays(-5).format('MM/dd/YY'),System.now().addDays(5).format('MM/dd/YY'),obj_admin.Id,obj_account.Id,rep5.Id,'Manager','',1);

            Custom_Report__c rep6 =createReport('Select id from Employee_Reimbursement__c where Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Reimbursements Between 2 Dates For Month Range');
            insert rep6;
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,'','12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep6.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep6.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep6.Report_Soql__c,rep6.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep6.Id,'Driver',null,1);

            Custom_Report__c rep7 =createReport('Select id from Employee_Reimbursement__c where Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Without Date Range');
            insert rep7;
            ReportDetailsController.getAllReportSoql(rep7.Report_Soql__c,rep7.Report_Type__c,'','12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep7.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep7.Report_Soql__c,rep7.Report_Type__c,obj_manager.id,'12/12/18','1/12/19',obj_admin.Id,obj_account.Id,rep7.Id,'Driver','06-2023',1);
    
            Custom_Report__c rep8 =createReport('Select id from Employee_Reimbursement__c where Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Reimbursements Between 2 Dates For Month Range');
            insert rep8;
            ReportDetailsController.getAllReportSoql(rep8.Report_Soql__c,rep8.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep8.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep8.Report_Soql__c,rep8.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep8.Id,'Driver','06-2023',1);
    
            Custom_Report__c rep9 =createReport('Select id from Employee_Reimbursement__c where Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Without Date Range');
            insert rep9;
            ReportDetailsController.getAllReportSoql(rep9.Report_Soql__c,rep9.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep9.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep9.Report_Soql__c,rep9.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep9.Id,'Driver','06-2023',1);
    
            Custom_Report__c rep10 =createReport('Select id from Employee_Mileage__c where EmployeeReimbursement__r.Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Without Date Range');
            insert rep10;
            ReportDetailsController.getAllReportSoql(rep10.Report_Soql__c,rep10.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep10.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep10.Report_Soql__c,rep10.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep10.Id,'Driver','06-2023',1);
            
            Custom_Report__c rep11 =createReport('Select id from Employee_Mileage__c where EmployeeReimbursement__r.Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Mileages Created Between 2 Dates');
            insert rep11;
            ReportDetailsController.getAllReportSoql(rep11.Report_Soql__c,rep11.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep11.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep11.Report_Soql__c,rep11.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep11.Id,'Driver','06-2023',1);
    
            Custom_Report__c rep12 =createReport('Select id from Employee_Mileage__c where EmployeeReimbursement__r.Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Mileages Between 2 Deactivation Dates');
            insert rep12;
            ReportDetailsController.getAllReportSoql(rep12.Report_Soql__c,rep12.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep12.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep12.Report_Soql__c,rep12.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep12.Id,'Driver','06-2023',1);
    
            Custom_Report__c rep13 =createReport('Select id from Employee_Mileage__c where EmployeeReimbursement__r.Contact_Id__r.Accountid=\''+obj_account.Id+'\'','Mileages Between 2 Dates for Month Range');
            insert rep13;
            ReportDetailsController.getDriverManagerList(obj_account.Id,obj_admin.Id,rep13.Id);
            ReportDetailsController.getAllReportSoql(rep13.Report_Soql__c,rep13.Report_Type__c,'','01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoql(rep13.Report_Soql__c,rep13.Report_Type__c,obj_manager.id,'01/08/19','01/09/19',obj_admin.Id,obj_account.Id,rep13.Id,'Driver','06-2023',1);
            ReportDetailsController.getAllReportSoqlForDriver(obj_account.Id,driverlist[0].Id,rep13.Id);
            
        }
        Test.stopTest();     
     }
     public static List<Contact> insertrecords() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(false);
        triggerCustomSetting.ContactTriCommunityReimCreate__c = false;
        insert triggerCustomSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        RecordUtilityClass.vehicleUrlMapping();
        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Manager_list1 = new List<Contact>();
        List<Contact> obj_Driver_list;
        List<Contact> obj_Driver_list1 = new List<Contact>();
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',Pay_Period_Days__c = 13,  Pay_Period_Start_Date__c = system.today().adddays(-30));
            insert account_1;
            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            obj_admincontact.Activation_Date__c = System.today();
            insert obj_admincontact;
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            for(Contact obj:obj_Manager_list) {
                obj.Activation_Date__c = System.today();
                obj_Manager_list1.add(obj);
            }
            insert obj_Manager_list1;
            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            for(Contact obj:obj_Driver_list) {
                obj.Activation_Date__c = System.today();
                obj_Driver_list1.add(obj);
            }
            insert obj_Driver_list1;
        }
        return obj_Driver_list1;
       
     }
     public static void insertReimbursements(List<Contact> driverList) {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(false);
        triggerCustomSetting.ContactTriCommunityReimCreate__c = false;
        insert triggerCustomSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        list<Gas_Prices__c> gaslist = RecordUtilityClass.buildGasPrice();
        insert gaslist;
        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = RecordUtilityClass.buildPendingEmployee_Reimbursement(driverList);
        insert obj_Employee_Reimbursement_list;
        list<Bi_Weekly_Reimbursement__c> obj_Employee_BiReimbursement_list = RecordUtilityClass.buildPendingBiReimbursement(driverList);
        insert obj_Employee_BiReimbursement_list;
        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list,obj_Employee_BiReimbursement_list[0].Id);
        insert obj_Employee_Mileage_list;
        
     }
     public static Custom_Report__c createReport(String reportsoql,String reporttype) {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(false);
        triggerCustomSetting.ContactTriCommunityReimCreate__c = false;
        insert triggerCustomSetting;
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Custom_Report__c rep = new Custom_Report__c();
        rep.Name = 'Test Productivity Report';
        rep.Report_Category__c = 'My Custom Reports';
        rep.Report_For__c = '';
        if(flag==false) {
            rep.Use_Manager_List__c = true;
            flag=true;
        } else {
        
            rep.Use_Driver_List__c = true;
             flag=false;
        }        
        rep.Report_Soql__c = reportsoql;
        rep.Report_Type__c = reporttype;
        rep.Sort_By__c = 'asc';
        rep.Sort_From__c = '2';
        rep.Filter_By__c  = 'Biweek Reimbursement';
        return rep;
     }
     @isTest
    static void fakeTest(){
     ReportDetailsController.fakeMethod(); 
     }
}