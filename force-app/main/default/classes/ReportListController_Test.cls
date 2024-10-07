@isTest
public class ReportListController_Test {
    public static testmethod void ReportListControllerTestMethod() {
     
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10,0965);
        //List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        vehicleType.Name = '2022 Ford F-150';
        vehicleType.vehicle__c = 'Ford F-150';
        vehicleType.Year__c = '2022';
        Update vehicleType;

        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;

        Account obj_acc;
        List<Contact> obj_admin_contact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_driver_contact;
        Contact contact_2;
        System.runAs(admin) {

            Account accountObj = TestDataFactory.createAccount(false,'Frampton Construction',true);
            insert accountObj;
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            obj_acc = TestDataFactory.createAccount(True,'Frampton Construction',true);
            obj_acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            obj_acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            obj_acc.Pay_Period_Days__c = 13;
            obj_acc.Vehicle_Types__c = vehicleType.Name;
            Update obj_acc;
           
            obj_admin_contact = TestDataFactory.createDriverContact(True, obj_acc.Id, 'Admin',  null, 'minkesh.patel', 1);
            obj_Manager_list = TestDataFactory.createDriverContact(True, obj_acc.Id, 'Manager',  null, 'minkesh.patel1', 1);
            obj_driver_contact = TestDataFactory.createDriverContact(true,obj_acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            /*obj_driver_contact[0].Vehicle_Type__c = '2022 Ford F-150';
            insert obj_driver_contact ;
            */
            userObj = TestDataFactory.createUser(True, profileObj.Id, obj_driver_contact[0].Id);
        }

        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, obj_driver_contact, 10, irsRateObj.id);
        system.assertEquals(11, reimList.size(),true);

        Custom_Report__c currentReport = new Custom_Report__c();
        currentReport.Name = 'Variable Reimbursement Report';
        currentReport.Sort_By__c = 'asc';
        currentReport.Report_For__c = 'Frank Saverino Accessibility';
        currentReport.Report_Category__c = 'Reimbursement Reports  ';
        currentReport.Report_Type__c = 'Reimbursements Between 2 Dates For Month Range';
        currentReport.Use_Manager_List__c = true;
        currentReport.Report_Header__c = 'Month,Employee ID,Name,E-mail,Monthly Approved Variable Amount';
        currentReport.Report_Soql__c = 'select Month__c,Contact_Id_Employee_ID__c,Contact_Id_Name__c,Contact_Id_External_Email__c,Monthly_Approved_Variable_Amount__c from Employee_Reimbursement__c where Contact_Id_Deactivated_Date__c =null';
        currentReport.Numeric_Fields__c = 'Monthly_Approved_Variable_Amount__c';
        currentReport.Date_Time_Fields__c = 'Contact_Id_Name__c';
        currentReport.Date_Fields__c = 'Contact_Id_External_Email__c';
        insert currentReport ; 
               
        Report_Accessibility__c repAcc = new Report_Accessibility__c();
        repAcc.Custom_Report__c = currentReport.Id;
        repAcc.User__c = userObj.Id;
        insert repAcc;
        
        Custom_Report__c currentReport2 = new Custom_Report__c();
        currentReport2.Name = 'Variable Reimbursement Report';
        currentReport2.Sort_By__c = 'asc';
        currentReport2.Report_For__c = 'Frank Saverino Accessibility';
        currentReport2.Report_Category__c = 'Reimbursement Reports  ';
        currentReport2.Report_Type__c = 'Reimbursements Between 2 Dates For Month Range';
        currentReport2.Use_Manager_List__c = true;
        currentReport2.Report_Header__c = 'Month,Employee ID,Name,E-mail,Monthly Approved Variable Amount';
        currentReport2.Report_Soql__c = 'select Month__c,Contact_Id_Employee_ID__c,Contact_Id_Name__c,Contact_Id_External_Email__c,Monthly_Approved_Variable_Amount__c from Employee_Reimbursement__c where Contact_Id_Deactivated_Date__c =null';
        currentReport2.Numeric_Fields__c = 'Monthly_Approved_Variable_Amount__c';
        currentReport2.Date_Time_Fields__c = 'Contact_Id_Name__c';
        currentReport2.Date_Fields__c = 'Contact_Id_External_Email__c';
        insert currentReport2 ; 
        Report_Accessibility__c repAcc1 = new Report_Accessibility__c();
        repAcc1.Custom_Report__c = currentReport2.Id;
        repAcc1.User__c = userObj.Id;
        insert repAcc1;
        
       Test.startTest();
        System.runAs(userObj) {
            Test.setCurrentPage(Page.reportlist);
            String accId = ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
            String conid = ApexPages.currentPage().getParameters().put('id',obj_driver_contact[0].Id);
            ReportListController mddc = new ReportListController();
            ReportListController.getAccountid();
            ReportListController.getContactid();
            ReportListController.getRedirected();
            ReportListController.getAllReports(obj_driver_contact[0].Id);
            ReportListController.getRole();
            ReportListController.reimbursementListModal(reimList[0].Id);
            ReportListController.contactListModal(obj_acc.Id);
            String startDate = '2020-01-01';
            String endDate = '2020-03-22';
            ReportListController.postTimeSheetImportAPI(startDate,endDate,obj_driver_contact[0].id);
            ReportListController.postVariablePaymentAPI(startDate,obj_driver_contact[0].id);
            ReportListController.postFixedAmountAPI(startDate,obj_driver_contact[0].id);
            ReportListController.postHalfFPFullDriverAPI(startDate,endDate,obj_driver_contact[0].id);
            ReportListController.CheckStatus(1234567654,'NetchexDeleteCallout');
            ReportListController.UpdateMileageLockDate(startDate,endDate);
            ReportListController.ErmiDriverList(startDate,endDate, string.valueof(obj_acc.Id));
            ReportListController.ChangeTripStatus(string.valueof('obj_acc[0].Id'));
            ReportListController.DeleteNetchexCallout(startDate,endDate);
            ReportListController.reimbursementWrapper wrapperList = new ReportListController.reimbursementWrapper();
            ReportListController.taxLiabilityReport(obj_acc.Id);
            ReportListController.payPeriodDateList(obj_acc.Id);
            ReportListController.TripDetailReport(startDate,endDate,string.valueof(obj_acc.Id));
            //ReportListController.updateLockDate(string.valueof(obj_acc.Id),obj_driver_contact[0].id);
            wrapperList.reimbId = obj_driver_contact[0].id;
            
            wrapperList.name = 'test';
         }
        Test.stopTest();
    }
}