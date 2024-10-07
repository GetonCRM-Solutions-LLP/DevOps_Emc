@isTest
private class ReportComplianceofDriver_Test {
    
    @isTest static void test_method_one() 
    {
        // Implement test code for ReportofDriverCompliance.page
        Test.startTest();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        Account obj_Account = RecordUtilityClass.buildAccount();
        insert obj_Account;

        
        Contact obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
        insert obj_admincontact;

        List<Contact> obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
        insert obj_Manager_list;

        List<Contact> obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
        insert obj_Driver_list;

        list<Gas_Prices__c> gaslist = RecordUtilityClass.buildGasPrice();
        insert gaslist;

        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        insert obj_Employee_Reimbursement_list;

        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list);
        insert obj_Employee_Mileage_list;

        
        Test.setCurrentPage(Page.ReportofDriverCompliance);
        ApexPages.currentPage().getParameters().put('id',obj_admincontact.Id);
        ApexPages.currentPage().getParameters().put('accid',obj_Account.Id); 
        ApexPages.currentPage().getParameters().put('reportid','compliancecalculationreport');  
        ReportComplianceofDriver obj = new ReportComplianceofDriver();
        ReportComplianceofDriver.getContactid();
        ReportComplianceofDriver.getReportid();
        ReportComplianceofDriver.getRedirected();
        ReportComplianceofDriver.getAllDrivers();
        ReportComplianceofDriver.getCompliance(obj_Driver_list[0].id,String.valueOf(System.Today().Month()));
        Test.stopTest();
    }   
    
    
}