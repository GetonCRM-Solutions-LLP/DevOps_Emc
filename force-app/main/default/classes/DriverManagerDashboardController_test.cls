@isTest
public class DriverManagerDashboardController_test {
    public static testmethod void DriverManagerDashboardControllerTestMethod() {
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        RecordUtilityClass.vehicleUrlMapping();
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(false);
        triggerCustomSetting.mileageremoveapprovaldate__c = false;
        triggerCustomSetting.MappingGasPriceTriggerUpdateConvertedDat__c = false;
        triggerCustomSetting.updateWorkingDays__c = false;
        insert triggerCustomSetting;
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        Account currentAccount = new Account();     
        List<Contact> conList = new List<Contact>();
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);        
        User user_1;
        Contact currentAdmin;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            currentAccount = TestDataFactory.createAccount(true,'Test',false);
            currentAdmin = RecordUtilityClass.buildAdminContact(currentAccount);
            insert currentAdmin;
            conList = TestDataFactory.createDriverContact(true, currentAccount.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            user_1 = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }        
        
        List<Contact> obj_Manager_list = RecordUtilityClass.buildManagerContact(currentAccount,currentAdmin);
        insert obj_Manager_list;
        List<Contact> obj_driverManager_list = RecordUtilityClass.buildDriverManagerContact(currentAccount,obj_Manager_list[0]);
        insert obj_driverManager_list;
        List<Contact> obj_Driver_list = RecordUtilityClass.buildDriverContact(currentAccount,obj_driverManager_list[0]);
        insert obj_Driver_list;

        list<Gas_Prices__c> gaslist = RecordUtilityClass.buildGasPrice();
        insert gaslist;

        list<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        insert empReimbursementList;

        list<Bi_Weekly_Reimbursement__c> empBIweeReimbursementList1 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweeReimbursementList1;

        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(empReimbursementList, empBIweeReimbursementList1[0].id);
        insert obj_Employee_Mileage_list;

        list<Employee_Reimbursement__c> empReimbursementList1 = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_driverManager_list);
        insert empReimbursementList1;

        list<Bi_Weekly_Reimbursement__c> empBIReimbursementList1 = RecordUtilityClass.buildPendingBiReimbursement(obj_driverManager_list);
        insert empBIReimbursementList1;

        List<Employee_Mileage__c> obj_Employee_Mileage_list1 = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(empReimbursementList1,empBIReimbursementList1[0].id );
        insert obj_Employee_Mileage_list1;

        //file
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Document Text');
        documentObj.ContentType = 'application/vnd.ms-excel';
        documentObj.DeveloperName = 'Inserted_Contact_File_Test';
        documentObj.IsPublic = true;
        documentObj.Name = 'Inserted Contact File';
        documentObj.FolderId = [SELECT Id FROM folder WHERE Name = 'Shared Documents'].Id;
        insert documentObj;

        Test.startTest();
        Test.setCurrentPage(Page.drivermanagerdashboard);
        String conId = ApexPages.currentPage().getParameters().put('id',obj_driverManager_list[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',currentAccount.Id);
        DriverManagerDashboardController dmdc = new DriverManagerDashboardController();
        DriverManagerDashboardController.getAccountid();
        DriverManagerDashboardController.getContactid();
        DriverManagerDashboardController.getRedirected();
        DriverManagerDashboardController.getChartData();
        DriverManagerDashboardController.getAllDriversLastMonthReimbursements();       
       
        DriverManagerDashboardController.getAllDriversLastMonthUnapprovedReimbursementsclone();
        DriverManagerDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone(obj_driverManager_list[0].Id,currentAccount.Id,'true');
        DriverManagerDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(obj_driverManager_list[0].Id,currentAccount.Id,'true');
        DriverManagerDashboardController.getAllDriversLastMonthUpdatedReimbursements(obj_driverManager_list[0].Id,currentAccount.Id,'true');
        //DriverManagerDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburse(obj_driverManager_list[0].Id,currentAccount.Id);
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List2 = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
        List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List2);

        Contact selectedDriver = RecordUtilityClass.getDriverContact();
        updateThresholdWrapper currentupdateThresholdWrapper = new updateThresholdWrapper();
        List<updateThresholdWrapper> updateThresholdWrapperList = new List<updateThresholdWrapper>();
        
        currentupdateThresholdWrapper.contactid = selectedDriver.id;
        currentupdateThresholdWrapper.threshold = '20';
        updateThresholdWrapperList.add(currentupdateThresholdWrapper);

        List<String> reimbursementIdList = new List<String>();
        reimbursementIdList.add(selectedReimList[0].id);
        
        AsyncApexJob batch = DriverManagerDashboardController.approveReimbursements(JSON.serialize(reimbursementIdList),obj_driverManager_list[0].Id,currentAccount.id,'true',JSON.serialize(updateThresholdWrapperList));
        List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
        DriverManagerDashboardController.CheckBatchStatus(batch.id);
        DriverManagerDashboardController.UpdatedReimList(obj_driverManager_list[0].Id, currentAccount.Id, 'true');
        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list=RecordUtilityClass.getallEmployeeMileages(driverMileagesList);
        if(obj_EmployeeMileages_list!=null && obj_EmployeeMileages_list.size()>0)
        {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list)
            {
                if(i==0)
                {
                    i++;
                    obj.isSelected=true;
    

                }
                else
                {
                    i--;
                    obj.isChecked = true;
                }
                obj_EmployeeMileages_list1.add(obj);
            }
        }
        DriverManagerDashboardController.approveMileagesClone(JSON.serialize(reimbursementIdList),obj_driverManager_list[0].Id,currentAccount.id,'true');

        String reimbursement = RecordUtilityClass.getUnapprovedReimbursements(currentAdmin.id,currentAccount.id,false,'Admin');    
        List<EmployeeMileagesForCalculation> employeereimbursementList = new List<EmployeeMileagesForCalculation>();
        employeereimbursementList = (List<EmployeeMileagesForCalculation>)JSON.deserialize(reimbursement,List<EmployeeMileagesForCalculation>.Class);
         DriverManagerDashboardController.getUnapprovedMileages(JSON.serialize(employeereimbursementList[0]),currentAccount.id);
      
       DriverManagerDashboardController.totalmileages='';
       DriverManagerDashboardController.totalvariableamount='';
       DriverManagerDashboardController.setEmployeeName();
        DriverManagerDashboardController.showTeamRecord=true;
        DriverManagerDashboardController.insurancePage=true;
        PageReference pageRef = Page.DriverManagerDashboard; // Add your VF page Name here
        pageRef.getParameters().put('showteam', 'showteam' );
        DriverManagerDashboardController.getAccountid();
        DriverManagerDashboardController.getContactid();
        DriverManagerDashboardController.getRedirected();           
        Test.stopTest();
    }
   public static testmethod void DriverManagerDashboardControllerTestMethod1() {
        DriverManagerDashboardController.getAccountid();
        DriverManagerDashboardController.getContactid();
        DriverManagerDashboardController.getRedirected();       
    }
    
}