@isTest
public class AdminManagerDriverDashboardContest {
    public static testmethod void AdminManagerDriverDashboardTestMethod() {
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
       List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsAdminManagerDriverDashboardCon();
        Account obj_acc = RecordUtilityClass.getAccount(); // retriving the Accounts 
        Contact obj_admin_contact = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
        Contact obj_driver_contact = RecordUtilityClass.getDriverContact();
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List = RecordUtilityClass.getEmployee_Reimbursementandmileages(obj_driver_contact.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
        Test.startTest();
        Test.setCurrentPage(Page.adminmanagerdriverdashboard);
        String accId = ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
        String conId = ApexPages.currentPage().getParameters().put('id',obj_driver_contact.Id);
        String adminid = ApexPages.currentPage().getParameters().put('adminid',obj_admin_contact.Id);
        String manid = ApexPages.currentPage().getParameters().put('manid',obj_driver_contact.Manager__c);
        AdminManagerDriverDashboardController mddc = new AdminManagerDriverDashboardController();
        AdminManagerDriverDashboardController.getAdminid();
        AdminManagerDriverDashboardController.getRedirected();
        AdminManagerDriverDashboardController.getLast2Years();
        AdminManagerDriverDashboardController.getReimbursementsList();
        AdminManagerDriverDashboardController.getDriverDetails();
        AdminManagerDriverDashboardController.getCompliance(obj_driver_contact.id);
        AdminManagerDriverDashboardController.getPacketandMeeting(obj_driver_contact.id);
        //AdminManagerDriverDashboardController.getUnapprovedMileages(JSON.serialize(obj_list_mileages),obj_driver_contact.id);
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
        AdminManagerDriverDashboardController.getReimbursementsListClone(obj_driver_contact.id);
        AdminManagerDriverDashboardController.getMileages('April','2019',obj_driver_contact.id);
        AdminManagerDriverDashboardController.getAllReimbursements('2019',obj_driver_contact.id,obj_acc.id);
       // AdminManagerDriverDashboardController.approveReimbursements(String.valueOf(Date.today().year()),obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c,JSON.serialize(empReimWrapList));
      //  AdminManagerDriverDashboardController.approveReimbursements('2019',obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c,JSON.serialize(empReimWrapList));
        AdminManagerDriverDashboardController.getDriverGasPrice('New York','New York');
        DateTime dt = DateTime.now();
        String monthName = dt.format('MMMMMMM');
       AdminManagerDriverDashboardController.approveMileages(null,null,null,obj_driver_contact.Name,obj_driver_contact.Email);
       AdminManagerDriverDashboardController.TimeAttendance(obj_driver_contact.id,'2021');
        AdminManagerDriverDashboardController.getMileagesBasedTandAtt(string.valueof(system.today()), string.valueof(system.today()+1), obj_driver_contact.Id);
        AdminManagerDriverDashboardController.biweeklyMileage(String.valueof(obj_driver_contact.Id), 2021);
      //  AdminManagerDriverDashboardController.getMileages(monthName,obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c);
        Test.stopTest();
    }
}