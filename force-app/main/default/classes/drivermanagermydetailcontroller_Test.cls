@isTest
Public class drivermanagermydetailcontroller_Test{
    public static testmethod void objMethod1(){
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsAdminDashboardController();
        Contact obj_admin_contact = RecordUtilityClass.getAdminContact();
        Account obj_acc = RecordUtilityClass.getAccount();
        Contact obj_driver_contact = RecordUtilityClass.getDriverContact();
        Attachment att = new Attachment();
        att.parentID = obj_admin_contact.Id;
        att.name = 'test';
        att.body = blob.valueOf('Test');
        insert att;
         
        Test.startTest();
        Test.setCurrentPage(Page.drivermanagermydetail);
        ApexPages.currentPage().getParameters().put('id',obj_admin_contact.Id);
        ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
        drivermanagermydetailcontroller objDriver = new drivermanagermydetailcontroller();
        drivermanagermydetailcontroller.contactDataAsString = 'test';
        drivermanagermydetailcontroller.getAccountid();
        drivermanagermydetailcontroller.getRedirected();
        drivermanagermydetailcontroller.getLast2Years();
        drivermanagermydetailcontroller.getAllReimbursements(String.valueOf(System.today().year()),obj_driver_contact.Id,obj_acc.Id);
        drivermanagermydetailcontroller.getReimbursementsList();
        drivermanagermydetailcontroller.getDriverDetailsClone(obj_admin_contact.Id);
        drivermanagermydetailcontroller.getMileages('June',String.valueOf(system.today().year()),obj_driver_contact.Id);
        drivermanagermydetailcontroller.getdriverInsurance(obj_driver_contact.Id,att.Id);
        drivermanagermydetailcontroller.getCompliance(obj_driver_contact.Id);
        drivermanagermydetailcontroller.getPacketandMeeting(obj_driver_contact.Id);
        drivermanagermydetailcontroller.readFromFileInchunk('test',att.Name,String.valueOf(att.Id),String.valueOf(obj_driver_contact.Id),String.valueOf(obj_acc.Id),null);
        drivermanagermydetailcontroller.TimeAttendance(obj_driver_contact.Id,'2021');
    
    }
    public static testmethod void objMethod2(){
    List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.createRecordsAdminDashboardController();
        Account obj_acc = RecordUtilityClass.getAccount();
        Contact obj_driver_contact = RecordUtilityClass.getDriverContact();
        drivermanagermydetailcontroller.getAllReimbursements(String.valueOf(1),obj_driver_contact.Id,obj_acc.Id);
        drivermanagermydetailcontroller.getAccountid();
        drivermanagermydetailcontroller.getContactid();
        drivermanagermydetailcontroller.getRedirected();
    }
}