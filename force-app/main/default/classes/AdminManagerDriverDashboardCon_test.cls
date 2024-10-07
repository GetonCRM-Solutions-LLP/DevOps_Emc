@isTest
public class AdminManagerDriverDashboardCon_test {
    @isTest
    public static void adminManagerDriverDashboardTestMethod() {

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
        /*TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        customEmailSetting.ContactTriBiReimCreate__c  = true;
        insert customEmailSetting;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        //RecordUtilityClass.createRecordsAdminManagerDriverDashboardCon();
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Contact obj_admin_contact;
        Account obj_acc;
        List<Contact> obj_Manager_list;
        List<Contact> obj_driver_contact;
        System.runAs(admin) {
            obj_acc= new Account( Name = 'PL Marketing');
            obj_acc.Bi_Weekly_Pay_Period__c = true;
            obj_acc.Pay_Period_Days__c = 13;
            obj_acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            insert obj_acc;
           
            obj_admin_contact = RecordUtilityClass.buildAdminContact(obj_acc);
            insert obj_admin_contact;   
            
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_acc,obj_admin_contact);
            insert obj_Manager_list;
    
            obj_driver_contact = RecordUtilityClass.buildDriverContact(obj_acc,obj_Manager_list[0]);
            insert obj_driver_contact ;
            
            Contact contact_2 = new Contact(AccountId = obj_acc.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com');
            insert contact_2 ;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_2.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        */

        List<Employee_Reimbursement__c> objEmpReimList = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id);     
        List<Employee_Reimbursement__c> objEmpReimListApproved = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id); 
        objEmpReimListApproved[0].Approved_Date__c = System.today();
        objEmpReimListApproved[0].Status__c    = 'Approved';
        update objEmpReimListApproved[0]; 

        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim (True, objDriverContact, System.today().addDays(-13),System.today(), 1, objIRSMileageRate.Id);
        //List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List = RecordUtilityClass.getEmployee_Reimbursementandmileages(obj_driver_contact[0].id);
        //List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List);
        //List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
       
        Test.setCurrentPage(Page.adminmanagerdriverdashboard);
        String accId = ApexPages.currentPage().getParameters().put('accid',objAcc.Id);
        String conId = ApexPages.currentPage().getParameters().put('id',objDriverContact[0].Id);
        String adminid = ApexPages.currentPage().getParameters().put('adminid',objadminContact[0].Id);
        String manid = ApexPages.currentPage().getParameters().put('manid',objDriverContact[0].Manager__c);
        /*AdminManagerDriverDashboardController.getUnapprovedMileages(JSON.serialize(obj_list_mileages),obj_driver_contact[0].id);
        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list=RecordUtilityClass.getallEmployeeMileages(obj_list_mileages);
        if(obj_EmployeeMileages_list != null && obj_EmployeeMileages_list.size() > 0 ) {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list) {
                if(i==0) {
                    i++;
                    obj.isSelected=true; 
                } else {
                    i--;
                    obj.isChecked = true;
                }
                obj_EmployeeMileages_list1.add(obj);
            }
        }
        
        Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = system.today()-13 + ' to ' + system.today() ; 
            br.Contact__c = obj_driver_contact[0].Id;
            br.Start_Date__c = system.today()-13;
            br.End_Date__c = system.today() ;
            br.MPG__c = obj_driver_contact[0].MPG__c;
            br.Maintenance_and_Tires__c = obj_driver_contact[0].Maintenance_and_Tires__c;
            br.Fixed_Amount__c = obj_driver_contact[0].Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Fuel_Price__c = 0;
        Insert br;

        */
        Test.startTest();
        System.runAs(userObj) {
            AdminManagerDriverDashboardController mddc = new AdminManagerDriverDashboardController();
            AdminManagerDriverDashboardController.getAdminid();
            AdminManagerDriverDashboardController.getRedirected();
            AdminManagerDriverDashboardController.getLast2Years();
            AdminManagerDriverDashboardController.getReimbursementsList();
            AdminManagerDriverDashboardController.getDriverDetails();
            AdminManagerDriverDashboardController.getCompliance(objDriverContact[0].id);
            AdminManagerDriverDashboardController.getPacketandMeeting(objDriverContact[0].id);
            AdminManagerDriverDashboardController.getReimbursementsListClone(objDriverContact[0].id);
            AdminManagerDriverDashboardController.getMileages('April','2019',objDriverContact[0].id);
            AdminManagerDriverDashboardController.getAllReimbursements('2019',objDriverContact[0].id,objAcc.id);
            //AdminManagerDriverDashboardController.approveReimbursements(String.valueOf(Date.today().year()),obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c,JSON.serialize(empReimWrapList));
            //AdminManagerDriverDashboardController.approveReimbursements('2019',obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c,JSON.serialize(empReimWrapList));
            AdminManagerDriverDashboardController.getDriverGasPrice('New York','New York');
            DateTime dt = DateTime.now();
            String monthName = dt.format('MMMMMMM');
            AdminManagerDriverDashboardController.approveMileages(null,null,null,objDriverContact[0].Name,objDriverContact[0].Email);
            AdminManagerDriverDashboardController.TimeAttendance(objDriverContact[0].id,'2021');
            //AdminManagerDriverDashboardController.getMileages(monthName,obj_driver_contact.Id,obj_acc.Id,obj_driver_contact.Manager__c);
            AdminManagerDriverDashboardController.biweeklyMileage(objDriverContact[0].id,2021);
            AdminManagerDriverDashboardController.getBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
            AdminManagerDriverDashboardController.ApproveBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
            AdminManagerDriverDashboardController.UpdateReimbursementStatus(objEmpReimList[0].Id);
            
        }
        Test.stopTest();
    }
}