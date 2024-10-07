@isTest
Public class DriverManagerDriverController_Test{
    Public static testmethod void objMethod1(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
       List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsAdminDashboardController();
        Account obj_acc = RecordUtilityClass.getAccount();
        Contact obj_admin_contact = RecordUtilityClass.getAdminContact();
        Contact obj_driver_contact = RecordUtilityClass.getDriverContact();
        Contact managerCon = RecordUtilityClass.getManagerContact();
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List = RecordUtilityClass.getEmployee_Reimbursement(obj_acc.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
       
        Attachment att = new Attachment();
        att.parentID = obj_admin_contact.Id;
        att.name = 'test';
        att.body = blob.valueOf('Test');
        insert att;

        Test.startTest();
        Test.setCurrentPage(Page.drivermanagerdriverdetails);
        ApexPages.currentPage().getParameters().put('id',obj_admin_contact.Id);
        ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
        ApexPages.currentPage().getParameters().put('manid',managerCon.Id);
        DriverManagerDriverDetailsController controllerObj = new DriverManagerDriverDetailsController();
        DriverManagerDriverDetailsController.totalmileages = '10';
        DriverManagerDriverDetailsController.totalvariableamount = '10';
        DriverManagerDriverDetailsController.contactDataAsString  = 'test';
        DriverManagerDriverDetailsController.getAccountid();
        DriverManagerDriverDetailsController.getDriverid();
        DriverManagerDriverDetailsController.getManagerid();
        DriverManagerDriverDetailsController.getRedirected();
        DriverManagerDriverDetailsController.getLast2Years();
        DriverManagerDriverDetailsController.getAllReimbursements(String.valueOf(System.today().year()),obj_driver_contact.Id,obj_acc.Id);
        DriverManagerDriverDetailsController.getReimbursementsList();
        //DriverManagerDriverDetailsController.getMileages(String.valueOf(System.today().month()),String.valueOf(System.today().year()),obj_driver_contact.Id,obj_acc.Id);
        DriverManagerDriverDetailsController.getReimbursementsListClone(obj_driver_contact.Id);
        DriverManagerDriverDetailsController.getCompliance(obj_driver_contact.Id);
        DriverManagerDriverDetailsController.getPacketandMeeting(obj_driver_contact.Id);
        DriverManagerDriverDetailsController.TimeAttendance(obj_driver_contact.Id,'2021');

    }
    Public static testmethod void objMethod2(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
       List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsAdminDashboardController();
        DriverManagerDriverDetailsController.getAccountid();
        DriverManagerDriverDetailsController.getDriverid();
        DriverManagerDriverDetailsController.getManagerid();
        DriverManagerDriverDetailsController.getRedirected();
    }
}