@isTest
Public class DriverManagerDriverControllerTest{
    @isTest
    Public static void objMethod1(){

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
       
      List<Employee_Reimbursement__c> objEmpReimList = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id);     
      List<Employee_Reimbursement__c> objEmpReimListApproved = TestDataFactory.createPendingReimbursement(True, objDriverContact, 1, objIRSMileageRate.Id); 
      objEmpReimListApproved[0].Approved_Date__c = System.today();
      objEmpReimListApproved[0].Status__c    = 'Approved';
      update objEmpReimListApproved[0]; 

      List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim (True, objDriverContact, System.today().addDays(-13),System.today(), 1, objIRSMileageRate.Id);
      Attachment att = TestDataFactory.createAttachment(True, objDriverContact[0].Id);
       
        Test.setCurrentPage(Page.drivermanagerdriverdetails);
        ApexPages.currentPage().getParameters().put('id',objadminContact[0].Id);
        ApexPages.currentPage().getParameters().put('accid',objAcc.Id);
        ApexPages.currentPage().getParameters().put('manid',objManagerList[0].Id);
        Test.startTest();
        System.runAs(userObj) {
            DriverManagerDriverDetailsController controllerObj = new DriverManagerDriverDetailsController();
            DriverManagerDriverDetailsController.totalmileages = '10';
            DriverManagerDriverDetailsController.totalvariableamount = '10';
            DriverManagerDriverDetailsController.contactDataAsString  = 'test';
            DriverManagerDriverDetailsController.getAccountid();
            DriverManagerDriverDetailsController.getDriverid();
            DriverManagerDriverDetailsController.getManagerid();
            DriverManagerDriverDetailsController.getRedirected();
            DriverManagerDriverDetailsController.getLast2Years();
            DriverManagerDriverDetailsController.getAllReimbursements(String.valueOf(System.today().year()),objDriverContact[0].Id,objAcc.Id);
            DriverManagerDriverDetailsController.getReimbursementsList();
            //DriverManagerDriverDetailsController.getMileages(String.valueOf(System.today().month()),String.valueOf(System.today().year()),obj_driver_contact.Id,obj_acc.Id);
            DriverManagerDriverDetailsController.getReimbursementsListClone(objDriverContact[0].Id);
            DriverManagerDriverDetailsController.getCompliance(objDriverContact[0].Id);
            DriverManagerDriverDetailsController.getPacketandMeeting(objDriverContact[0].Id);
            DriverManagerDriverDetailsController.TimeAttendance(objDriverContact[0].Id,'2021');
            //DriverManagerDriverDetailsController.approveReimbursements('2019',obj_driver_contact.Id,obj_acc.Id,JSON.serialize(obj_list_mileages));
            //DriverManagerDriverDetailsController.getMileages('08','2021',obj_driver_contact.id);
            DriverManagerDriverDetailsController.getMileagesBasedTandAtt(string.valueof(system.today()), string.valueof(system.today()+1), objDriverContact[0].Id);
             DriverManagerDriverDetailsController.biweeklyMileage(String.valueof(objDriverContact[0].Id), 2021);  
            DriverManagerDriverDetailsController.getBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
            DriverManagerDriverDetailsController.ApproveBiweekMileages(string.valueOf(biWeeklyReimList[0].Id));
            DriverManagerDriverDetailsController.UpdateReimbursementStatus(objEmpReimList[0].Id);
           // DriverManagerDriverDetailsController.approveMileages(null,null,null,obj_driver_contact.Name,obj_driver_contact.Email);
           
            }
        Test.stopTest();
    }
    @isTest
    Public static void objMethod2(){
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        system.assertEquals('Defaulttrigger', customEmailSetting.Name, True);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
     
        DriverManagerDriverDetailsController.getAccountid();
        DriverManagerDriverDetailsController.getDriverid();
        DriverManagerDriverDetailsController.getManagerid();
        DriverManagerDriverDetailsController.getRedirected();
    }
}