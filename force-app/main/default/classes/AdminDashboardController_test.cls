@isTest
public class AdminDashboardController_test {
    public static testmethod void AdminDashboardControllerTestMethod() {
        RecordUtilityClass.createRecordsAdminDashboardController();
        
        Account currentAccount = RecordUtilityClass.getAccount();
        system.debug('currentAccount='+ currentAccount);
        
       Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
        
        Contact selectedDriver = RecordUtilityClass.getDriverContact();
        List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
        List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(empReimbursementList);
       
        
        List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
       // Test.startTest();
       
        ApexPages.currentPage().getParameters().put('id',currentAdmin.Id);
        ApexPages.currentPage().getParameters().put('accid',currentAccount.Id);
        AdminDashboardController adbc = new AdminDashboardController();
        AdminDashboardController.getAccountid();
        AdminDashboardController.getContactid();
        AdminDashboardController.getRedirected();
        AdminDashboardController.getChartData();
        String reimbursement = RecordUtilityClass.getUnapprovedReimbursements(currentAdmin.id,currentAccount.id,true,'Admin');        
        List<EmployeeMileagesForCalculation> employeereimbursementList = new List<EmployeeMileagesForCalculation>();
        employeereimbursementList = (List<EmployeeMileagesForCalculation>)JSON.deserialize(reimbursement,List<EmployeeMileagesForCalculation>.Class);
        system.debug('employeereimbursementList=='+ employeereimbursementList);
        
        if(employeereimbursementList.size() > 0)    {
        AdminDashboardController.getUnapprovedMileages(JSON.serialize(employeereimbursementList[0]),currentAccount.id );
        }
        AdminDashboardController.setEmployeeName();
        AdminDashboardController.getAllDriversLastMonthReimbursements();
        AdminDashboardController.getAllDriversLastMonthUnapprovedReimbursementsClone();
        AdminDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(currentAdmin.id, currentAccount.Id, 'true');
        AdminDashboardController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(currentAdmin.id, currentAccount.Id, 'false');
        AdminDashboardController.getManager(currentAdmin.id,currentAccount.id);
        List<String> reimbursementIdList = new List<String>();
        
        if(employeereimbursementList.size() > 0)    {
        reimbursementIdList.add(selectedReimList[0].id);
        }
        updateThresholdWrapper currentupdateThresholdWrapper = new updateThresholdWrapper();
        List<updateThresholdWrapper> updateThresholdWrapperList = new List<updateThresholdWrapper>();
        currentupdateThresholdWrapper.contactid = selectedDriver.id;
        currentupdateThresholdWrapper.threshold = '20';
        updateThresholdWrapperList.add(currentupdateThresholdWrapper);
        AsyncApexJob batch = AdminDashboardController.approveReimbursements(JSON.serialize(reimbursementIdList),currentAdmin.id,currentAccount.id,'false',JSON.serialize(updateThresholdWrapperList));
        AsyncApexJob batch1 = AdminDashboardController.approveReimbursementsLWC(JSON.serialize(reimbursementIdList),currentAdmin.id,currentAccount.id,'false',JSON.serialize(updateThresholdWrapperList));
        AdminDashboardController.approveMileagesClone(JSON.serialize(reimbursementIdList),currentAdmin.id,currentAccount.Id,'true');
        System.debug('employeereimbursementList'+employeereimbursementList);
        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list2=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list=RecordUtilityClass.getallEmployeeMileages(driverMileagesList);
        System.debug('obj_EmployeeMileages_list'+obj_EmployeeMileages_list);
        if(obj_EmployeeMileages_list!=null && obj_EmployeeMileages_list.size()>0)
        {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list)
            {   
                System.debug('obj_EmployeeMileages_listdata=========='+obj);
                if(i==0)
                {
                    i++;
                    obj.isSelected=true;
                    obj_EmployeeMileages_list2.add(obj);
                }
                else
                {
                    i--;
                    obj.isChecked = true;
                    obj_EmployeeMileages_list1.add(obj);
                }
                
            }
        }
        System.debug('obj_EmployeeMileages_list1'+obj_EmployeeMileages_list1);
        System.debug('obj_EmployeeMileages_list2'+obj_EmployeeMileages_list2);
        // AdminDashboardController.approveMileages(null,null,selectedDriver.Name,selectedDriver.Email);
        Test.setMock(HttpCalloutMock.class, new TriplogUserIdUpdateBatchTestMock());
        AdminDashboardController.approveMileages(null,null,null,JSON.serialize(obj_EmployeeMileages_list1),JSON.serialize(obj_EmployeeMileages_list2));
        AdminDashboardController.CheckBatchStatus(batch.id);
        AdminDashboardController.CheckBatchStatusLWC(batch.id);
        AdminDashboardController.UpdatedReimList(currentAdmin.id, currentAccount.Id, 'true');
        //AdminDashboardController.UpdatedReimListLWC(currentAdmin.id, currentAccount.Id, 'true');
        AdminDashboardController.approveMileagesCloneLWC(JSON.serialize(reimbursementIdList), currentAdmin.id,currentAccount.id, 'true');
        AdminDashboardController.UpdateTimezonAppVer(currentAccount.ID);
       // Test.stopTest();
    }
}