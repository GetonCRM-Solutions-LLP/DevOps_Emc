@isTest
public class ManagerDriverDashboardControllertest {
    @isTest
    public static void managerDriverDashboardControllerTestMethod() {

        TriggerConfig__c triggerConfigCustomSetting = TestDataFactory.triggerConfigCustomSetting(True);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(True, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehType = TestDataFactory.createVehicleData(True, 3);
        IRS_Mileage_Rate__c objIRSMileageRate = TestDataFactory.createIRSRate(True, 3);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
       
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        
        List<Contact> objadminContact;
        Account objAcc;
        List<Contact> objManagerList;
        List<Contact> objDriverContact;
        System.runAs(admin) {
            objAcc = TestDataFactory.createAccount(True, 'PL Marketing', True);

            objadminContact = TestDataFactory.createDriverContact(True, objAcc.Id, 'Admin', vehType.Name, 'paras.dhanani', 1);
            objManagerList = TestDataFactory.createDriverContact(True, objAcc.Id, 'Manager', vehType.Name, 'paras.patel', 1);
            objDriverContact = TestDataFactory.createDriverContact(False, objAcc.Id, 'Driver', vehType.Name, 'parasm.patel', 1);
            objDriverContact[0].manager__C = String.valueOf(objManagerList[0].Id);
            objDriverContact[0].IsCreatedFromCommunity__c = false;
            objDriverContact[0].isCommunityUser__c = false;
            Insert objDriverContact[0];

            userObj = TestDataFactory.createUser(True, profileObj.Id, objDriverContact[0].Id);
            system.debug('objManagerList.size()==' + objManagerList.size());
            system.assertEquals(1, objManagerList.size(), True);
        }

        Test.setCurrentPage(Page.managerdriverdashboard);
        String conId = ApexPages.currentPage().getParameters().put('id',objDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',objAcc.Id);
        String manid = ApexPages.currentPage().getParameters().put('manid',objDriverContact[0].Manager__c);
        ManagerDriverDashboardController mddc = new ManagerDriverDashboardController();

        List<Employee_Reimbursement__c> objEmpReimList = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id);     
        List<Employee_Reimbursement__c> objEmpReimListApproved = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id); 
        objEmpReimListApproved[0].Approved_Date__c = System.today();
        objEmpReimListApproved[0].Status__c    = 'Approved';
        update objEmpReimListApproved[0]; 

        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim (True, objDriverContact, System.today().addDays(-13),System.today(), 1, objIRSMileageRate.Id);
        DateTime dt = DateTime.now();
        String monthName = dt.format('MMMMMMM');
        
        Test.startTest();
        System.runAs(userObj) {
        //ManagerDriverDashboardController.approveMileages(JSON.serialize(empMileageList),String.valueOf(Date.today().year()),obj_driver_contact.Id);
        ManagerDriverDashboardController.getRedirected();
        ManagerDriverDashboardController.getLast2Years();
        //ManagerDriverDashboardController.approveReimbursements('2019',objDriverContact[0].Id,objAcc.Id,JSON.serialize(objEmpReimList));
        ManagerDriverDashboardController.getReimbursementsList();
        ManagerDriverDashboardController.getDriverDetails();
        ManagerDriverDashboardController.getAllReimbursements('2019',objDriverContact[0].Id,objAcc.Id);
        ManagerDriverDashboardController.getReimbursementsListClone(objDriverContact[0].Id);
        ManagerDriverDashboardController.getPacketandMeeting(objDriverContact[0].Id);
        ManagerDriverDashboardController.getCompliance(objDriverContact[0].Id);
        ManagerDriverDashboardController.getMileages(monthName,'2019',objDriverContact[0].Id);
        ManagerDriverDashboardController.TimeAttendance(objDriverContact[0].Id,'2021');
        ManagerDriverDashboardController.getMileagesBasedTandAtt(String.valueOf(System.today()),String.valueOf(System.today()+1),string.valueOf(objDriverContact[0].Id));
        ManagerDriverDashboardController.biweeklyMileage(string.valueOf(objDriverContact[0].Id),2021);
        ManagerDriverDashboardController.getBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
        ManagerDriverDashboardController.ApproveBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
        ManagerDriverDashboardController.UpdateReimbursementStatus(objEmpReimList[0].Id);
        }
        Test.stopTest();
    }
}