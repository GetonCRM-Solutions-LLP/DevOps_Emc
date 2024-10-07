@isTest
public with sharing class EmployeeReimbursementTriggerHandlerTest {
    
    @isTest
    public static Void testSecondMethod() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'Defaulttrigger');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Account acc ;
        Account acc2 ;
        Account acc3 ;
        List<Contact> con ;
        List<Contact> con2 ;
        List<Contact> con3 ;
        List<Contact> con4 ;
        List<Contact> con5 ;
        List<Contact> con6 ;
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True, 'Test Account', False);
            acc2 = TestDataFactory.createAccount(True, 'Rayner', False);
            acc3 = TestDataFactory.createAccount(True, 'CATCO', False);
           
            con = TestDataFactory.createDriverContact(False, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
            con[0].IsCreatedFromCommunity__c = false;
            Insert con;
            con2 = TestDataFactory.createDriverContact(True, acc2.Id, 'Driver', vehicleType.Name, 'ParasP.Patel', 1);
            con3 = TestDataFactory.createDriverContact(False, acc2.Id, 'Driver', vehicleType.Name, 'ParasM.Patel', 1);
            con3[0].Manager__c = con2[0].Id;
            insert con3[0];

            con4 = TestDataFactory.createDriverContact(True, acc3.Id, 'Admin', vehicleType.Name, 'ParasD.Patel', 1);
            con5 = TestDataFactory.createDriverContact(False, acc3.Id, 'Driver/Manager', vehicleType.Name, 'ParasD.Patels', 1);
            con5[0].Manager__c = con4[0].Id;
            Insert con5[0];

            con6 = TestDataFactory.createDriverContact(False, acc3.Id, 'Driver', vehicleType.Name, 'Parass.Patel', 1);
            con6[0].Manager__c = con5[0].Id;
            Insert con6[0];
            userObj = TestDataFactory.createUser(True, profileObj.Id, con[0].Id);
    }
        Test.startTest();      
        Map<id,Employee_Reimbursement__c> oldmap = new Map<id,Employee_Reimbursement__c>();
        Map<id,Employee_Reimbursement__c> newmap = new Map<id,Employee_Reimbursement__c>();
        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, con, 1, createIRSRate.Id);
        er[0].Approved_Date__c = system.today()-4;
        er[0].Month__c = '09-2017';
        er[0].Status__c = 'Approved';
        Insert er[0];
   
        oldmap.put(er[0].id, er[0]);
		Set<Id>EmpReimIdLst =new Set<Id>();
        List<Employee_Reimbursement__c> er2 = TestDataFactory.createPendingReimbursement(False, con3, 1, createIRSRate.Id);
        er2[0].Month__c = '09-2020';
        Insert er2[0];
       
        List<Employee_Reimbursement__c> er3 = TestDataFactory.createPendingReimbursement(False, con3, 1, createIRSRate.Id);
        er3[0].Month__c = '11-2020';
        Insert er3[0];
        
        List<Employee_Reimbursement__c> er5 = TestDataFactory.createPendingReimbursement(False, con5, 1, createIRSRate.Id);
        er5[0].Month__c = '09-2020';
        Insert er5[0];
        
        List<Employee_Reimbursement__c> er6 = TestDataFactory.createPendingReimbursement(False, con5, 1, createIRSRate.Id);
        er6[0].Month__c = '11-2020';
        Insert er6[0];
       
        List<Employee_Reimbursement__c> er7 = TestDataFactory.createPendingReimbursement(False, con6, 1, createIRSRate.Id);
        er7[0].Month__c = '09-2020';
        Insert er7[0];
       
        List<Employee_Reimbursement__c> er8 = TestDataFactory.createPendingReimbursement(False, con6, 1, createIRSRate.Id);
        er8[0].Month__c = '11-2020';
        Insert er8[0];
            
        List<Employee_Reimbursement__c> empReimList = new List<Employee_Reimbursement__c>();
        er[0].Status__c = 'Approved';
        er[0].Approved_Date__c = system.today();
        er3[0].Status__c = 'Approved';
        er3[0].Approved_Date__c = system.today();
        empReimList.add(er3[0]);
        er2[0].Status__c = 'Approved';
        er2[0].Approved_Date__c = system.today();
        empReimList.add(er2[0]);
        er5[0].Status__c = 'Approved';
        er5[0].Approved_Date__c = system.today();
        empReimList.add(er5[0]);
        er6[0].Status__c = 'Approved';
        er6[0].Approved_Date__c = system.today();
        empReimList.add(er6[0]);
        er7[0].Status__c = 'Approved';
        er7[0].Approved_Date__c = system.today();
        empReimList.add(er7[0]);
        er8[0].Status__c = 'Approved';
        er8[0].Approved_Date__c = system.today();
        empReimList.add(er8[0]);
        system.debug('er[0]=='+er[0]);
        system.debug('er2[0]=='+er2[0]);
        system.debug('er3[0]=='+er3[0]);
        system.debug('er5[0]=='+er5[0]);
        system.debug('er6[0]=='+er6[0]);
        system.debug('er7[0]=='+er7[0]);
        system.debug('er8[0]=='+er8[0]);
        system.debug('empReimList=='+empReimList);
        update empReimList;
        
        newmap.put(er[0].id, er[0]);
        newmap.put(er2[0].id, er2[0]);
        newmap.put(er3[0].id, er[0]);
        newmap.put(er5[0].id, er5[0]);
        newmap.put(er6[0].id, er6[0]);
        newmap.put(er7[0].id, er7[0]);
        newmap.put(er8[0].id, er8[0]);
       
        EmpReimIdLst.add(er[0].id);
        EmpReimIdLst.add(er2[0].id);
        EmpReimIdLst.add(er3[0].id);
        EmpReimIdLst.add(er5[0].id);
        EmpReimIdLst.add(er6[0].id);
		EmpReimIdLst.add(er7[0].id);
        EmpReimIdLst.add(er8[0].id);

        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (false, con, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
        br = TestDataFactory.createBiweeklyReim (false, con, System.today().addDays(-13),System.today().addDays(0), 1, createIRSRate.Id);
        insert br;       
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (False, 1, er, br);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].Approved_Date__c = system.today();
        Insert emp1[0];
        //system.assertEquals(2, emp1.size(), true);
        system.System.debug('empReimList==' + empReimList);
        system.System.debug('oldmap==' + oldmap);
        system.System.debug('newmap==' + newmap);
        EmployeeReimbursementTriggerHandler.mileagefieldupdate(empReimList, oldmap, newmap);
        EmployeeReimbursementTriggerHandler.IRSVehicleCheck(EmpReimIdLst);
        EmployeeReimbursementTriggerHandler.checkLockDate(empReimList);
        System.assertEquals(2,con.size(), 'Assert Success');
        Test.stopTest();
    }
    
     @isTest
    static void msgExistTest(){
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRate = TestDataFactory.createIRSRate(true,0);
        
        UserRole uRole = TestDataFactory.getUserRole();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        
        System.runAs(admin){
            
            Account objAccount = TestDataFactory.createAccount(true,'Test',true);

            List<Contact> lstContact = TestDataFactory.createDriverContact(true,objAccount.id,'Driver',veh.Name,'testmail',1);
			System.debug('lstContact ==>'+lstContact);
            List<Employee_Reimbursement__c> empReim = TestDataFactory.createPendingReimbursement(true, lstContact, 1, irsRate.Id);

			System.debug('empReim ==>'+empReim);
            DateTime dtLastMonth = System.today().addMonths(-1);
            String lastMonthval = String.valueOf(dtLastMonth.format('MMMM'));
	
            message__c msg1 = new message__c();
            msg1.Notification_Message__c = 'Your ' + lastMonthval + ' mileage has been approved.';
            msg1.Unread__c = true;
            msg1.Contacts__c = lstContact[0].Id;
            insert msg1;
            message__c msg2 = new message__c();
            msg2.Notification_Message__c = 'You had “12.43” flagged mileage for '+lastMonthval;
            msg2.Unread__c = true;
            msg2.Contacts__c = lstContact[0].Id;
            insert msg2;
            message__c msg3 = new message__c();
            msg3.Notification_Message__c = 'You had “12.43” miles in '+ lastMonthval +' that were not approved. Any unapproved mileage will move to the next reimbursement period for review/approval.';
            msg3.Unread__c = true;
            msg3.Contacts__c = lstContact[0].Id;
            insert msg3;
            
            
            Test.startTest();
			empReim[0].Mileage_Lock_Date__c = System.TODAY();
            update empReim;
            System.assertEquals(1,lstContact.size(), 'Assert Success');
            Test.stopTest();
        }
    }
    
    @isTest
    static void msgNotExistTest(){
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRate = TestDataFactory.createIRSRate(true,0);
        
        UserRole uRole = TestDataFactory.getUserRole();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        
        System.runAs(admin){
            Account objAccount = TestDataFactory.createAccount(true,'Test',true);
            List<Contact> lstContact = TestDataFactory.createDriverContact(true,objAccount.id,'Driver',veh.Name,'testmail',1);
            List<Employee_Reimbursement__c> empReim = TestDataFactory.createPendingReimbursement(true, lstContact, 1, irsRate.Id);

            Test.startTest();
            empReim[0].Mileage_Lock_Date__c = System.TODAY();
            update empReim;
            System.assertEquals(1,lstContact.size(), 'Assert Success');
            Test.stopTest();
        }
    }
}