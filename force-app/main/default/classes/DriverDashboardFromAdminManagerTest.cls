@isTest
public class DriverDashboardFromAdminManagerTest {
    @isTest
    public static void driverDashboardFromAdminManagertestMethod() {

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
                
        Test.setCurrentPage(Page.driverdashboardfromadminmanager);
        String adminId = ApexPages.currentPage().getParameters().put('adminid',objadminContact[0].Id);
        String conId = ApexPages.currentPage().getParameters().put('id',objDriverContact[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',objAcc.Id);  
        List<Employee_Reimbursement__c> objEmpReimList = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id);     
        List<Employee_Reimbursement__c> objEmpReimListApproved = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id); 
        objEmpReimListApproved[0].Approved_Date__c = System.today();
        objEmpReimListApproved[0].Status__c    = 'Approved';
        update objEmpReimListApproved[0]; 

        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim (True, objDriverContact, System.today().addDays(-13),System.today(), 1, objIRSMileageRate.Id);
       // List<Employee_Mileage__c> obj_EmployeeMileages_list = TestDataFactory.getEmpMileage (True, 1, obj_Employee_Reimbursement_List, biWeeklyReimList);
       /* List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List = RecordUtilityClass.getDriverEmployee_Reimbursement(obj_driver_contact[0].id);
        List<EmployeeReimbursements> obj_list =  RecordUtilityClass.getEmployeeReimbursements(obj_Employee_Reimbursement_List);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
        List<EmployeeMileages> obj_EmployeeMileages_list1 = new List<EmployeeMileages>();
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
        */
            Test.startTest();
        System.runAs(userObj) {
            DriverDashboardFromAdminManager objDriverDashboardFromAdminManager = new DriverDashboardFromAdminManager();
            DriverDashboardFromAdminManager.getAccountid();
            DriverDashboardFromAdminManager.getAdminid();
            DriverDashboardFromAdminManager.getDriverid();
            DriverDashboardFromAdminManager.getRedirected();
            DriverDashboardFromAdminManager.getLast2Years();
            DriverDashboardFromAdminManager.getAllReimbursements('2019',objDriverContact[0].Id,objAcc.Id);
            DriverDashboardFromAdminManager.getReimbursementsList();
            DriverDashboardFromAdminManager.getReimbursementsListClone(objDriverContact[0].Id);
            DriverDashboardFromAdminManager.getCompliance(objDriverContact[0].Id);
            DriverDashboardFromAdminManager.getPacketandMeeting(objDriverContact[0].Id);
            DriverDashboardFromAdminManager.getMileages('April','2019',objDriverContact[0].id);
            DriverDashboardFromAdminManager.getMileages('March','2019',objDriverContact[0].id);
            DriverDashboardFromAdminManager.getMileages('February','2019',objDriverContact[0].id);
            DriverDashboardFromAdminManager.TimeAttendance(objDriverContact[0].id,'2021');
            //DriverDashboardFromAdminManager.approveReimbursements('2019', string.valueOf(obj_Employee_Reimbursement_List_approved[0].Id),String.valueOf(obj_acc.Id),JSON.serialize( obj_Employee_Reimbursement_List_approved));
            DriverDashboardFromAdminManager.postExpenseReimbursement(objAcc.Id,'04-2020','abc@gmail.com','222');
            DriverDashboardFromAdminManager.UpdateReimbursementStatus(objDriverContact[0].Id);
            DriverDashboardFromAdminManager.getMileagesBasedTandAtt(string.valueof(system.today()), string.valueof(system.today()+1), objDriverContact[0].Id);
            //DriverDashboardFromAdminManager.TimeAttendance(objDriverContact[0].Id,'2021');
            //DriverDashboardFromAdminManager.TripCallout(obj_driver_contact[0].Id, '09', '2021', 3.12,0.09, Json.serialize(obj_Employee_Reimbursement_List).Id, 16.50, 'Approved');
            DriverDashboardFromAdminManager.biweeklyMileage(String.valueof(objDriverContact[0].Id), 2021);
            //DriverDashboardFromAdminManager.getBiweekMileages('2021-11-12','2021-12-30',obj_driver_contact[0].id);
            DriverDashboardFromAdminManager.getBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
            //DriverDashboardFromAdminManager.ApproveBiweekMileages('2021-11-12','2021-12-30',obj_driver_contact[0].id);
            DriverDashboardFromAdminManager.ApproveBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
            //DriverDashboardFromAdminManager.getAllDriversLastMonthUnapprovedReimbursementsClone(String.valueof(obj_driver_contact[0].Id), String.valueOf(obj_acc.Id), True );
            
            //DriverDashboardFromAdminManager.biweeklyMileage(obj_driver_contact.Id[0],'2021');          
         }
        Test.stopTest();
           // DriverDashboardFromAdminManager.approveMileages(JSON.serialize(obj_EmployeeMileages_list1),'April',obj_driver_contact[0].id);
    }
}