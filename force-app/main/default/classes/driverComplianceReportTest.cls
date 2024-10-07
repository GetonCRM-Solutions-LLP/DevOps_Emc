@isTest
private class driverComplianceReportTest{
    @isTest
    public static void newdriverComplianceReportTest() {
        NewDashboardMessage__c newMsgCustomSetting = TestDataFactory.newMsgCustomSetting(True);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(True, 'ConfirmTripTimeERMIController');
        SendEmail__c sendEmailSetting = TestDataFactory.sendEmailCustomSetting(True, 'Send Email For Compliance');
        NewDashboardVideoLink__c videoCustomSetting  = TestDataFactory.NewDashboardVideoLink(true);
        Account accData;
        List<Contact> conList;
        List<String> complianceCalculationList ;
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        
         System.runAs(admin) {

            accData = TestDataFactory.createAccount(False, 'Test Account', False);
            accData.Bodily_Injury__c = '100,000/300,000';
            accData.Property_Damage__c = 50000;
            accData.Collision__c = 1000;
            accData.Comprehensive__c = 1000;
            Insert accData;
            
            conList = TestDataFactory.createDriverContact(False, accData.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 1);
            conList[0].IsCreatedFromCommunity__c = false;
            conList[0].Compliance_Mileage__c = 15000;
            Insert conList[0];
            TestDataFactory.createUser(true, profileObj.Id, conList[0].Id );
            system.assertEquals(1, conList.size(), true);
        }
        
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(false, conList, 1, irsRateObj.id);
        reimList[0].Approved_Date__c = System.today()-2;
        Integer year = Date.today().year() - 1;
        reimList[0].Month__c = '01-'+ String.valueOf(year);
        //reimList[0].Month__c = '01-2022';
        reimList[0].Status__c = 'Approved';
        insert reimList[0];
        
        List<Employee_Reimbursement__c> reimList1 = TestDataFactory.createPendingReimbursement(false, conList, 1, irsRateObj.id);
        reimList1[0].Approved_Date__c = System.today()-2;
        reimList[0].Month__c = '03-'+ String.valueOf(year);
        //reimList1[0].Month__c = '03-2022';
        reimList1[0].Status__c = 'Approved';
        insert reimList1[0];
        
        List<Employee_Reimbursement__c> reimList2 = TestDataFactory.createPendingReimbursement(false, conList, 1, irsRateObj.id);
        reimList2[0].Approved_Date__c = System.today()-2;
        reimList[0].Month__c = '06-'+ String.valueOf(year);
        //reimList2[0].Month__c = '06-2022';
        reimList2[0].Status__c = 'Approved';
        insert reimList2[0];
        
        List<Employee_Reimbursement__c> reimList3 = TestDataFactory.createPendingReimbursement(false, conList, 1, irsRateObj.id);
        reimList3[0].Approved_Date__c = System.today()-2;
        reimList[0].Month__c = '10-'+ String.valueOf(year);
        //reimList3[0].Month__c = '10-2022';
        reimList3[0].Status__c = 'Approved';
        insert reimList3[0];
        
        driverComplianceReport.wrapperTaxReport wrapper = new driverComplianceReport.wrapperTaxReport();
        wrapper.drivername = 'Test Wrapper';
        wrapper.employeeid = '123485';
        wrapper.emailid = 'Paras.dhanani@getoncrm.com';
        wrapper.approvedmileages = 45.10;
        wrapper.totalreim = 123.54;
        wrapper.iRSallowable = 435.05;
        wrapper.imputedincome = 46.10;
        wrapper.month = 09;
        wrapper.year = '2022';
        
        List<id> insertedContactIDList = new List<id>();
		insertedContactIDList.add(conList[0].id);
        
        Test.StartTest();
        PageReference pageRef = Page.AnnualComplianceReport;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accId', String.valueOf(accData.Id));
        driverComplianceReport drivertest = new driverComplianceReport();
        drivertest.TotalActualReimbursements  = 10.10;
        drivertest.currentdate  = System.today();
        drivertest.MaximumAllowable = 10.25;
        drivertest.AnnualTaxLiability = 25.10;
        drivertest.totalmileages  =29.10;
        
        complianceCalculationList = new List<String>();
        //complianceCalculationList.addAll(WrapperUtils.getComplianceCalculation(conList[0].Id, '2022'));
        
        String summaryData = 'drivername : Sanket Goswami';
        Map<Id,String> mapOfResult = new Map<Id,String>();
        mapOfResult.put(conList[0].Id,summaryData);
            
        Map<String,List<Employee_Reimbursement__c>> obj_map_Employee_Reimbursement = new Map<String,List<Employee_Reimbursement__c>>();
        obj_map_Employee_Reimbursement.put(conList[0].Id, reimList3);
        driverComplianceReport.downloadAnnualComplianceReport(JSON.serialize(insertedContactIDList),'2022');
        
    }
}