@isTest
public class ManagerDashboardFromAdminController_test {
    public static testmethod void ManagerDashboardFromAdminTestMethod() {
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
       /* Account obj_Account = RecordUtilityClass.buildAccount();
        
            obj_Account.Pay_Period_Days__c = 13;
            obj_Account.Pay_Period_Start_Date__c = system.today().adddays(-30);
        insert obj_Account;
		*/
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        
        insert veh;
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        
        /*Account obj_Account = RecordUtilityClass.buildAccount();
        
            obj_Account.Pay_Period_Days__c = 13;
            obj_Account.Pay_Period_Start_Date__c = system.today().adddays(-30);
        insert obj_Account;
*/
       // Account obj_Account = new Account();
       	 Account obj_Account;
        Contact con = new Contact();
        contact obj_admincontact ;
        //contact obj_admincontact = new contact();
        
        System.runAs(admin) {
         /*   obj_Account.Name = 'Test Account';
            //acc.Pay_Period_Start_Date__c = system.today();
            obj_Account.Bi_Weekly_Pay_Period__c = true;
            obj_Account.Pay_Period_Days__c = 13;
            obj_Account.Pay_Period_Start_Date__c = system.today().adddays(-130);
            obj_Account.Last_Reimbursement_Created__c = '12-2021';
            insert obj_Account;
           */
            obj_Account = RecordUtilityClass.buildAccount();
        
            obj_Account.Pay_Period_Days__c = 13;
            obj_Account.Pay_Period_Start_Date__c = system.today().adddays(-30);
        insert obj_Account;
            
            system.debug('obj_Account=='+ obj_Account);
            Contact contact_1 = new Contact(AccountId = obj_Account.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com');
            insert contact_1;
            
            con.LastName = 'TestContact';
            con.Role__c = 'Driver';
            con.Car_Image__c = veh.URL__c;
            con.Vehicle_Type__c = veh.Year__c +' '+veh.vehicle__c;
            con.AccountId = obj_Account.Id;
            con.Activation_Date__c = system.today();
            con.Deactivated_Date__c = system.today().addDays(-2);
            con.External_Email__c = 'test@email.com';
            con.Fixed_Amount__c = 371.28;
            con.MailingCity = 'Abilene';
            con.MailingState = 'TX';
            con.Time_Zone__c = 'US/Mountain' ;
            con.Driving_States__c = 'TX';
            con.Fixed_Amount__c = 322.00;
            con.Maintenance_and_Tires__c = 1.2;
            con.MPG__c= 10.00;
            con.Monthly_Mileage_Limit__c = 100.00;
            con.Deactivated_Date__c = null;
            insert con;
            
              obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
        insert obj_admincontact;
            
           /* 
            obj_admincontact.LastName = 'TestContact';
            obj_admincontact.Role__c = 'Admin';
            obj_admincontact.Car_Image__c = veh.URL__c;
            obj_admincontact.Vehicle_Type__c = veh.Year__c +' '+veh.vehicle__c;
            obj_admincontact.AccountId = obj_Account.Id;
            obj_admincontact.Activation_Date__c = system.today();
            obj_admincontact.Deactivated_Date__c = system.today().addDays(-2);
            obj_admincontact.External_Email__c = 'test@email1.com';
            obj_admincontact.Fixed_Amount__c = 371.28;
            obj_admincontact.MailingCity = 'Abilene';
            obj_admincontact.MailingState = 'TX';
            obj_admincontact.Time_Zone__c = 'US/Mountain' ;
            obj_admincontact.Driving_States__c = 'TX';
            obj_admincontact.Fixed_Amount__c = 322.00;
            obj_admincontact.Maintenance_and_Tires__c = 1.2;
            obj_admincontact.MPG__c= 10.00;
            obj_admincontact.Monthly_Mileage_Limit__c = 100.00;
            obj_admincontact.Deactivated_Date__c = null;
            insert obj_admincontact;
          */  
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        
        
       /* Contact obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
        insert obj_admincontact;
*/
        List<Contact> obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
        insert obj_Manager_list;
        List<Contact> obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
        insert obj_Driver_list;
        List<Employee_Reimbursement__c> listEmp = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        //listEmp[0].Contact_Id__c = obj_Account.Id;
        insert listEmp;
        list<Bi_Weekly_Reimbursement__c> empBIweekReim = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
            insert empBIweekReim;
        List<Employee_Mileage__c> listMileage_obj = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(listEmp, empBIweekReim[0].Id);
        insert listMileage_obj;
        List<String> reimbursementIdList = new List<String>();
        reimbursementIdList.add(listEmp[0].id);
        Test.startTest();
        Test.setCurrentPage(Page.managerdashboardfromadmin);
        String driverId = ApexPages.currentPage().getParameters().put('id', obj_admincontact.Id);
        String managerid = ApexPages.currentPage().getParameters().put('managerid', obj_Manager_list[0].Id);
        String accId = ApexPages.currentPage().getParameters().put('accid',obj_Account.Id);
        ManagerDashboardFromAdminController mddc = new ManagerDashboardFromAdminController();
        ManagerDashboardFromAdminController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(obj_Manager_list[0].Id,obj_Account.Id,'false');
        ManagerDashboardFromAdminController.getAdminid();
        ManagerDashboardFromAdminController.totalmileages='';
        ManagerDashboardFromAdminController.totalvariableamount='';
        ManagerDashboardFromAdminController.nameofEmployee='';
        ManagerDashboardFromAdminController.showTeamRecord = false;
        ManagerDashboardFromAdminController.getRedirected();
        ManagerDashboardFromAdminController.getAccountid();
        ManagerDashboardFromAdminController.getContactid();
        ManagerDashboardFromAdminController.getChartData();
       // ManagerDashboardFromAdminController.getChartLabels();
        ManagerDashboardFromAdminController.getAllDriversLastMonthReimbursements();
        ManagerDashboardFromAdminController.getAllDriversLastMonthUpdatedReimbursements(managerid, obj_Account.Id,'false');
        ManagerDashboardFromAdminController.getAllDriversLastMonthUnapprovedReimbursementsclone();
        ManagerDashboardFromAdminController.getAllDriversLastMonthUpdatedUnapprovedReimburseClone(obj_Manager_list[0].Id,obj_Account.Id,'false');
        AsyncApexJob batch = ManagerDashboardFromAdminController.approveReimbursements(JSON.serialize(reimbursementIdList),obj_admincontact.Id,obj_Account.Id,'false');
        ManagerDashboardFromAdminController.approveMileagesClone(JSON.serialize(reimbursementIdList),obj_admincontact.Id,obj_Account.Id,'false');
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List = RecordUtilityClass.getEmployee_Reimbursement(obj_Account.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
       // ManagerDashboardFromAdminController.approveMileagesClone(JSON.serialize(obj_Employee_Reimbursement_List),obj_Manager_list[0].Id,obj_Account.Id);
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
       //ManagerDashboardFromAdminController.approveMileages(JSON.serialize(obj_EmployeeMileages_list1),'','','test','test@gmail.com');
       // ManagerDashboardFromAdminController.getUnapprovedMileages(JSON.serialize(obj_list_mileages),obj_Driver_list[0].Id); // obj_list_mileages
       ManagerDashboardFromAdminController.CheckBatchStatus(batch.id);
        ManagerDashboardFromAdminController.UpdatedReimList(obj_Manager_list[0].Id,obj_Account.Id, 'true');
        Test.stopTest();
    }
    public static testmethod void ManagerDashboardFromAdminTestMethod2(){
        ManagerDashboardFromAdminController mddc = new ManagerDashboardFromAdminController();
        ManagerDashboardFromAdminController.getAccountid();
        ManagerDashboardFromAdminController.getAdminid();
        ManagerDashboardFromAdminController.getContactid();
        ManagerDashboardFromAdminController.getRedirected();
        //ManagerDashboardFromAdminController.approveReimbursements(JSON.serialize(listEmp), managerid, obj_Account.Id);
        //test Comment
    }
}