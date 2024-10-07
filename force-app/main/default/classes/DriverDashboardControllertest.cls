@isTest
public class DriverDashboardControllertest {
    public static testmethod void DriverDashboardControllerTestMethod() {
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

        Test.setCurrentPage(Page.driverDashboardClone);
        String conId = ApexPages.currentPage().getParameters().put('id',obj_driver_contact.Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',obj_acc.Id);
        DriverDashboardController ddc = new DriverDashboardController();
        DriverDashboardController.getAccountid();
        DriverDashboardController.getContactid();
        DriverDashboardController.getLast2Years();
        DriverDashboardController.getRedirected();
        DriverDashboardController.getReimbursementsList();
        DriverDashboardController.getDriverDetails();
        DriverDashboardController.getAllReimbursements(String.valueOf(Date.today().year()),obj_driver_contact.Id,obj_acc.Id);
        DriverDashboardController.getAllReimbursements('2018',obj_driver_contact.Id,obj_acc.Id);
        DriverDashboardController.contactDataAsString = 'test';
        DateTime dt = DateTime.now();
        String monthName = dt.format('MMMMMMM');
        DriverDashboardController.getMileages(monthName,String.valueOf(System.today().year()),obj_driver_contact.Id);
        DriverDashboardController.TimeAttendance(obj_driver_contact.Id,'2021');
        //DriverDashboardController.readFromFile(String.valueof(documentObj.Body),driList[0].Id,acc.Id,documentObj.Name);
        DriverDashboardController.readFromFileInchunk('test',att.Name,String.valueOf(att.Id),String.valueOf(obj_driver_contact.Id),String.valueOf(obj_acc.Id),null);
        DriverDashboardController.getCompliance(String.valueOf(obj_driver_contact.Id));
        DriverDashboardController.getPacketandMeeting(String.valueOf(obj_driver_contact.Id));
        DriverDashboardController.getMileagesBasedTandAtt(String.valueOf(System.today()),String.valueOf(System.today()+1),string.valueOf(obj_driver_contact.Id));
        //DriverDashboardController.biweeklyMileage(string.valueOf(obj_driver_contact.Id),2021);
        DriverDashboardController.getBiweekMileages(String.valueOf(System.today()),String.valueOf(System.today()+1),string.valueOf(obj_driver_contact.Id));
    }
    
}