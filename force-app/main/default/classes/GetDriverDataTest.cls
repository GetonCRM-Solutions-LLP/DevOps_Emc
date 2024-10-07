@isTest
public with sharing class GetDriverDataTest {
    public static testmethod void method1() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true, 'ChangeTripStatusinTripLogBatch');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 2);
        TriplogPutCall__c customPut = new TriplogPutCall__c();
        customPut.name = 'GetDriverData';
        customPut.TriplogPut__c = true;
        insert customPut;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();       
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;

        Account acc;
        List<Contact> contact;
        List<Contact> contact2;
        List<Contact> contact3;
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True,'Delta account',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            Acc.Triplog_Status__c = 'U';
            acc.Pay_Period_Days__c = 13;
            Update acc;
            Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            contact = TestDataFactory.createDriverContact(true,acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            contact2 = TestDataFactory.createDriverContact(true,acc.Id, 'Manager', vehicleType.Name, 'niraj.sahedani',  1);
            contact3 = TestDataFactory.createDriverContact(true,acc.Id, 'Admin', vehicleType.Name, 'niraj.sahedani12',  1);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contact[0].Id);
        }
                
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, contact, 2, irsRateObj.id);
        system.assertEquals(3, reimList.size(),true);

        List<Bi_Weekly_Reimbursement__c> biweeklyReimList = TestDataFactory.createBiweeklyReim(true, contact,  date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 2, irsRateObj.id);
        system.debug('biweeklyReimList== '+biweeklyReimList );
        List<Employee_Mileage__c> mileageList = TestDataFactory.getEmpMileage(true, 1, reimList, biweeklyReimList);
        
        String json = '[{\"Id\":\"'+mileageList[0].id+'\",\"employeeEmailId\":\"testManagr101@gmail.com\"}]';
        String monthStr = WrapperUtils.getMonthNamefromno(System.today().month()-1);
    
        Test.startTest();

        GetDriverData.fetchLookUpValues(acc.Id,contact[0].Id,'AccountId',contact[0].Id, 'Id', '', 'id', 'contact','Name',true);
        GetDriverData.fetchMileages(acc.Id,contact[0].id,1,2);
        GetDriverData.fetchMileagesSize(acc.Id,contact[0].id);
        GetDriverData.buildDateforactivation(System.today());
        GetDriverData.approveMileages(true,json,false,false);
        GetDriverData.approveMileages(false,json,false,true);
        GetDriverData.getMilegesData(acc.Id,contact[0].id,contact[0].Id,System.today(),System.today()+1,'denverstreet','Denver',true,'10','50','Approved','MagicTrip','magic','abc','Business',1,2,monthStr,'All Types');
        GetDriverData.getMilegesData(acc.Id,contact2[0].id,contact2[0].Id,System.today(),System.today()+1,'denverstreet','Denver',true,'10','50','Approved','MagicTrip','magic','abc','Business',1,2,monthStr,'High Risk');

        GetDriverData.fetchWayPointPostAPI(1234555,'apikey');
        GetDriverData.getMilegesDataSize(acc.Id,contact[0].id,contact[0].Id,System.today(),System.today()+1,'denverstreet','Denver',true,'10','50','Approved','MagicTrip','magic','abc','Business',monthStr,'All Types');
		GetDriverData.getMilegesDataSize(acc.Id,contact2[0].id,contact2[0].Id,System.today(),System.today()+1,'denverstreet','Denver',true,'10','50','Approved','MagicTrip','magic','abc','Business',monthStr,'Weekend Trips');
        
        GetDriverData.updateMileages(mileageList[0].id,'magic','Business','test',5);
        String jsondata = '[{\"id\":"'+mileageList[0].id+'",\"adminId\":"'+contact[0].Id+'",\"tripdate\":\"2021-08-17\",\"conName\":\"NIkita Patel\",\"conEmail\":\"nikita.patel@kiwiqa.com\",\"oldActivity\":\"Business\",\"mileage\":\"100\",\"actualMileage\":\"100\",\"tripId\":2000669507,\"accApi\":\"28beeea973f34daf89050a9b6a3b1a71\"}]';

        GetDriverData.massUpdateActivityEmail('Commute',jsondata);

        GetDriverData.updateMileagesEmail(contact[0].id,System.today(),contact[0].FirstName+' '+ contact[0].LastName,contact[0].External_Email__c,'Commute','Business','10','20',1234576,acc.Triplog_API__c);

        GetDriverData.deleteMileages(json);
        GetDriverData.mileageListData(acc.Id,contact2[0].Id,System.today(),System.today()+10);
        GetDriverData.mileageListData(acc.Id,contact3[0].Id,System.today(),System.today()+10);
        GetDriverData.deleteTrips(acc.Id,'05-2021');
        GetDriverData.deleteTripsForIndividualDriver(contact[0].id,'[{"label":"03-2024","value":"03-2024"},{"label":"04-2024","value":"04-2024"}]');
        GetDriverData.syncTripsIndividualDriver(contact[0].id,'03-2024');
        GetDriverData.getInsuranceStatus(contact[0].id);
        GetDriverData.fetchMileageslwc(acc.Id,contact[0].Id,25,2);
        
        //GetDriverData.MassSyncTrips(acc.Id,String.valueOf(System.today()-1),String.valueOf(System.today()),monthVal,'Pending','Business');
        GetDriverData.getDriverName(acc.Id,contact2[0].Id,'Manager');
        GetDriverData.getAccountId();
        GetDriverData.getContactid();
        GetDriverData gdd= new  GetDriverData();
       // GetDriverData.setEmployeeName();
        
        //GetDriverData.getDriverName(acc.Id,contact3[0].Id,'Admin');
        //GetDriverData.accountMonthList(acc.Id);
        // GetDriverData.highRiskMileages(acc.Id,contact[0].Id,2,2);
        // GetDriverData.highRiskMileages(acc.Id,contact3[0].Id,25,2);
        

        //GetDriverData.setEmployeeName();
        Test.stopTest();
    
    }

    public static testmethod void method2() {
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true, 'ChangeTripStatusinTripLogBatch');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 2);
        TriplogPutCall__c customPut = new TriplogPutCall__c();
        customPut.name = 'GetDriverData';
        customPut.TriplogPut__c = true;
        insert customPut;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();       
        
        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;

        Account acc;
        List<Contact> contact;
        List<Contact> contact2;
        List<Contact> contact3;
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True,'Delta account',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            Acc.Triplog_Status__c = 'U';
            acc.Pay_Period_Days__c = 13;
            Update acc;
            Contact contactObj = TestDataFactory.createCICDContact(true,acc.Id);
            contact = TestDataFactory.createDriverContact(true,acc.Id, 'Driver', vehicleType.Name, 'paras.patel',  1);
            contact2 = TestDataFactory.createDriverContact(true,acc.Id, 'Manager', vehicleType.Name, 'niraj.sahedani',  1);
            contact3 = TestDataFactory.createDriverContact(true,acc.Id, 'Admin', vehicleType.Name, 'niraj.sahedani12',  1);
            userObj = TestDataFactory.createUser(True, profileObj.Id, contact[0].Id);
        }
                
        List<Employee_Reimbursement__c> reimList = TestDataFactory.createPendingReimbursement(true, contact, 2, irsRateObj.id);
        system.assertEquals(3, reimList.size(),true);

        List<Bi_Weekly_Reimbursement__c> biweeklyReimList = TestDataFactory.createBiweeklyReim(true, contact,  date.valueof(system.today().adddays(-14)),date.valueof(system.today().addDays(-1)), 2, irsRateObj.id);
        system.debug('biweeklyReimList== '+biweeklyReimList );
        List<Employee_Mileage__c> mileageList = TestDataFactory.getEmpMileage(true, 1, reimList, biweeklyReimList);
        
        String json = '[{\"Id\":\"'+mileageList[0].id+'\",\"employeeEmailId\":\"testManagr101@gmail.com\"}]';
        String monthStr = WrapperUtils.getMonthNamefromno(System.today().month()-1);
    
        Test.startTest();
        
        // GetDriverData.MassSyncTrips(acc.Id,String.valueOf(System.today()-1),String.valueOf(System.today()),monthVal,'Pending','Business');
        //GetDriverData.getDriverName(acc.Id,contact3[0].Id,'Admin');
        GetDriverData.accountMonthList(acc.Id);
        GetDriverData.highRiskMileages(acc.Id,contact[0].Id,2,2);
        GetDriverData.highRiskMileages(acc.Id,contact3[0].Id,25,2);
        GetDriverData.approveMileages(false,json,false,true);
        

        //GetDriverData.setEmployeeName();
        Test.stopTest();
    
    }
}