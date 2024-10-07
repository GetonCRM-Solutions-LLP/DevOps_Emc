@isTest
public class DriverDashboardFromAdminManager_Test {
    public static testmethod void driverDashboardFromAdminManagertestMethod() {
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsforDriverDashboardFromAdminManager();
        Account obj_acc = RecordUtilityClass.getAccount(); // retriving the Accounts 
        Contact obj_admin_contact = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
        Contact obj_driver_contact = RecordUtilityClass.getDriverContact();
        
        Test.setCurrentPage(Page.driverdashboardfromadminmanager);
        String adminid = ApexPages.currentPage().getParameters().put('adminid',obj_admin_contact.Id);
        String conId = ApexPages.currentPage().getParameters().put('id',obj_driver_contact.Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
        DriverDashboardFromAdminManager obj_DriverDashboardFromAdminManager = new DriverDashboardFromAdminManager();
        DriverDashboardFromAdminManager.getAccountid();
        DriverDashboardFromAdminManager.getAdminid();
        DriverDashboardFromAdminManager.getDriverid();
        DriverDashboardFromAdminManager.getRedirected();
        //DriverDashboardFromAdminManager.getLast2Years();
        DriverDashboardFromAdminManager.getAllReimbursements('2019',obj_driver_contact.Id,obj_acc.Id);
        DriverDashboardFromAdminManager.getReimbursementsList();
        DriverDashboardFromAdminManager.getReimbursementsListClone(obj_driver_contact.Id);
        DriverDashboardFromAdminManager.getCompliance(obj_driver_contact.Id);
        DriverDashboardFromAdminManager.getPacketandMeeting(obj_driver_contact.Id);
        DriverDashboardFromAdminManager.getMileages('April','2019',obj_driver_contact.id);
        DriverDashboardFromAdminManager.getMileages('March','2019',obj_driver_contact.id);
        DriverDashboardFromAdminManager.getMileages('February','2019',obj_driver_contact.id);
        DriverDashboardFromAdminManager.TimeAttendance(obj_driver_contact.id,'2021');
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List = RecordUtilityClass.getDriverEmployee_Reimbursement(obj_driver_contact.id);
        List<EmployeeReimbursements> obj_list =  RecordUtilityClass.getEmployeeReimbursements(obj_Employee_Reimbursement_List);
        DriverDashboardFromAdminManager.approveReimbursements('2019',obj_driver_contact.Id,obj_acc.Id,JSON.serialize(obj_list));
        //DriverDashboardFromAdminManager.postExpenseReimbursement(obj_acc.Id,'04-2020','abc@gmail.com','222');
        DriverDashboardFromAdminManager.UpdateReimbursementStatus(obj_Employee_Reimbursement_List[0].id );
        String startDate = '2021-07-28';
        String endDate = '2021-08-11';
        DriverDashboardFromAdminManager.getBiweekMileages(startDate ,endDate ,obj_driver_contact.id);
        DriverDashboardFromAdminManager.ApproveBiweekMileages(startDate ,endDate ,obj_driver_contact.id);
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
       // DriverDashboardFromAdminManager.approveMileages(JSON.serialize(obj_EmployeeMileages_list1),'April',obj_driver_contact.id);
        
    }
}