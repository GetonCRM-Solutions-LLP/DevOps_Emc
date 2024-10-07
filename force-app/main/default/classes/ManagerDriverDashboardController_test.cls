@isTest
public class ManagerDriverDashboardController_test {
    public static testmethod void ManagerDriverDashboardControllerTestMethod() {
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
       List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsforManagerDriverDashboardController();

        Account obj_acc = RecordUtilityClass.getAccount(); // retriving the Accounts 
        Contact obj_admin_contact = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
        Contact obj_driver_contact = RecordUtilityClass.getDriverContact();

        Test.startTest();
        Test.setCurrentPage(Page.managerdriverdashboard);
        String conId = ApexPages.currentPage().getParameters().put('id',obj_driver_contact.Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
        String manid = ApexPages.currentPage().getParameters().put('manid',obj_driver_contact.Manager__c);
        ManagerDriverDashboardController mddc = new ManagerDriverDashboardController();
        ManagerDriverDashboardController.getRedirected();
        ManagerDriverDashboardController.getLast2Years();
        ManagerDriverDashboardController.getReimbursementsList();
        ManagerDriverDashboardController.getDriverDetails();
        ManagerDriverDashboardController.getAllReimbursements('2019',obj_driver_contact.Id,obj_acc.Id);
        ManagerDriverDashboardController.getReimbursementsListClone(obj_driver_contact.Id);
        ManagerDriverDashboardController.getPacketandMeeting(obj_driver_contact.Id);
        ManagerDriverDashboardController.getCompliance(obj_driver_contact.Id);

        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List = RecordUtilityClass.getDriverEmployee_Reimbursement(obj_driver_contact.id);
        List<EmployeeReimbursements> obj_list =  RecordUtilityClass.getEmployeeReimbursements(obj_Employee_Reimbursement_List);
        ManagerDriverDashboardController.approveReimbursements('2019',obj_driver_contact.Id,obj_acc.Id,JSON.serialize(obj_list));
        
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list=RecordUtilityClass.getallEmployeeMileages(obj_list_mileages);
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
       // ManagerDriverDashboardController.approveMileages(JSON.serialize(obj_EmployeeMileages_list1),'April',obj_driver_contact.id);
        //ManagerDriverDashboardController.approveMileages();
        //ManagerDriverDashboardController.approveReimbursements();
        //ManagerDriverDashboardController.approveReimbursements(String.valueOf(Date.today().year()),obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c,JSON.serialize(empReimWrapList));
        //ManagerDriverDashboardController.approveReimbursements('2018',obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c,JSON.serialize(empReimWrapList));
        DateTime dt = DateTime.now();
        String monthName = dt.format('MMMMMMM');
        //ManagerDriverDashboardController.approveMileages(JSON.serialize(empMileageList),String.valueOf(Date.today().year()),obj_driver_contact.Id);
        ManagerDriverDashboardController.getMileages(monthName,'2019',obj_driver_contact.Id);
        ManagerDriverDashboardController.TimeAttendance(obj_driver_contact.Id,'2021');
        Test.stopTest();
    }
}