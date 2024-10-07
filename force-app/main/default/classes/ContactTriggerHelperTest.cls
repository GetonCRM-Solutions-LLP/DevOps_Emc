/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 07-25-2024
 * @last modified by  : VatsalBhalani
**/
@isTest
public class ContactTriggerHelperTest {
    
    @TestSetup
    static void setupTestData() {
        
        UserRole objUserRole = TestDataFactory.getUserRole();
        Profile objProfile = TestDataFactory.getUserProfile();
        User objAdmin = TestDataFactory.getSystemAdminUser(objUserRole.Id);
        User objGenUser;
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10,12345);
        
        Vehicle_URL_Mapping__c objVehicleUrlMap = TestDataFactory.createVehicleData(false, 0);
        objVehicleUrlMap.Name = String.valueof(System.today().year())+ ' Full-Size Sedan';
        objVehicleUrlMap.vehicle__c = 'Full-Size Sedan';
        Insert objVehicleUrlMap;
        //System.debug('vehicle url--@'+objVehicleUrlMap);
        List<Contact> lstcontact = new List<Contact>();
        Account objAccount = TestDataFactory.createAccount(true,'Test123',true);
        Vehicle_URL_Mapping__c objVehicleUrlMap1 = [select Id,Name, Year__c, Vehicle__c, URL__c,Vehicle_Mapping__c from Vehicle_URL_Mapping__c];
        //System.debug('vehicle url1--@'+objVehicleUrlMap1);
        Contact objContact = TestDataFactory.createDriverContacts(false, objAccount.Id, 'Driver', objVehicleUrlMap1.Name, 'Test.patel','Yes');
        objContact.Expiration_Date__c= System.today();
        lstcontact.add(objContact);
        
        Contact objContact1  = TestDataFactory.createDriverContacts(false, objAccount.Id, 'Driver/Manager', objVehicleUrlMap1.Name, 'Test1.patel', 'No - Mileage');
        objContact1.Expiration_Date__c= null;
        lstcontact.add(objContact1);
        
        Insert lstcontact;
        
        Account objAccount1;
        Account objAccount2;
        List<Vehicle_Value__c> lstVehicleValue;
        List<Contact> lstContact2;
        Contact objContact3;
        
        System.runAs(objAdmin) {
            objAccount1 = TestDataFactory.createAccount(true,'General Test User',true);
            
            objAccount2 = TestDataFactory.createAccount(true,'Test',true);
            objAccount2.Pay_Period_Start_Date__c = System.today().addDays(-100);
            objAccount2.Vehicle_Types__c = String.valueof(System.today().year())+ ' Full-Size Sedan';
            update objAccount2;
            
            lstVehicleValue = TestDataFactory.createVehicleValue(true, objAccount2.Id, objVehicleUrlMap1.Id);
            
            List<Contact> lstContact1 = TestDataFactory.createDriverContact(false, objAccount2.Id, 'Driver', objVehicleUrlMap1.Name, 'paras.patel',  1);
            lstContact1[0].monthly_compliance_status__c = 'No – Vehicle Age';
            lstContact1[0].Deactivated_Date__c = system.today();
            lstContact1[0].Vehicle_Type__c = String.valueof(System.today().year())+ 'Full-Size Sedan';
            lstContact1[0].Vehicle_Value__c = lstVehicleValue[0].Value__c;
            lstContact1[0].Activation_Date__c = system.today();
            lstContact1[0].Email = 'Testn@mailinator.com';
            lstContact1[0].MailingPostalCode='99501';
            lstContact1[0].Map_Country__c = 'USA';
            lstContact1[0].Insurance_Attachment_Id__c = '1111111';
            Insert lstContact1[0];
            
            lstContact1[0].Deactivated_Date__c =null;   
            lstContact1[0].Email = 'Testn@mailinator.com';
            lstContact1[0].Activation_Date__c = system.today().adddays(-20);
            lstContact1[0].MailingPostalCode='38038';
            lstContact1[0].Insurance_Attachment_Id__c = '11';
            update lstContact1[0];
            
            lstContact2 = TestDataFactory.createDriverContact(false, objAccount2.Id, 'Driver', objVehicleUrlMap1.Name, 'paras.dhanani',  1);
            lstContact2[0].Deactivated_Date__c = system.today();
            lstContact2[0].Vehicle_Value__c = lstVehicleValue[0].Value__c;
            lstContact2[0].Vehicle_Type__c = String.valueof(System.today().year())+ 'Full-Size Sedan';
            lstContact2[0].Activation_Date__c = system.today().adddays(-9);
            Insert lstContact2[0];
            //System.debug('lstContact2--@'+lstContact2[0].Email);
            objContact3 = TestDataFactory.createCICDContact(true,objAccount1.Id);
            
            objGenUser = TestDataFactory.createUser(True, objProfile.Id, objContact3.Id);

            // List<Contact> lstContact4 =TestDataFactory.createDriverContact(true, objAccount2.Id, 'Driver', objVehicleUrlMap.Name, 'testContact1', 1);
            // List<Employee_Reimbursement__c> lstEmpReim =TestDataFactory.createPendingReimbursement(true,lstContact4, 1, irsRateObj.Id);
            // List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReim =TestDataFactory.createBiweeklyReim(true, lstContact4, System.TODAY(), System.TODAY().addDays(7), 1, irsRateObj.Id);
            // List<Employee_Mileage__c> lstEmpMil = TestDataFactory.getEmpMileage(true, 1, lstEmpReim, lstBiWeeklyReim);
        }
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Driver Agreement',
            PathOnClient   = 'Driver Agreement.docx',
            VersionData    = Blob.valueOf('Test Content'),
            FirstPublishLocationId = objAccount.Id,
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id =: objAccount.Id];
        if(!documents.isEmpty()){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstcontact[0].ID;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
    }
    @isTest
    static void sendEmailOnDriverCreateTest() {
        //StaticValues.disableContactTrigger=true;
        Account objAccount;
        Contact objContact1;
        Vehicle_URL_Mapping__c objVehicleUrlMap = [select Id,Name, Year__c, Vehicle__c, URL__c,Vehicle_Mapping__c from Vehicle_URL_Mapping__c];
        User objAdmin = [select id from user where Profile.Name = 'System Administrator' limit 1];
        User objGenUser = [select id,IsActive from user where Profile.Name = 'Customer Community Login User - Driver' and IsActive= true  limit 1];
        //System.debug('objGenUser@@-'+objGenUser);
        System.runAs(objAdmin) {
            objAccount = [Select id,Vehicle_Types__c,Bi_Weekly_Pay_Period__c,Pay_Period_Days__c,Pay_Period_Start_Date__c,Triplog_API__c,Triplog_Status__c,isUsingTriplog__c,Cell_Phone__c,Reimbursement_Frequency__c from Account where name = 'Test' limit 1];           
            objContact1 = [select id,Triplog_UserID__c,Phone,Role__c,External_Email__c,monthly_compliance_status__c,Deactivated_Date__c,AccountId,Vehicle_Type__c,Vehicle_Value__c,Activation_Date__c,Email,MailingPostalCode,Map_Country__c,Insurance_Attachment_Id__c,Monthly_Reimbursement__c,MailingState,Fixed_Amount__c,Maintenance_and_Tires__c,MPG__c,Name__c,MailingStreet,MailingCity,MailingCountry from contact where Email = 'Testn@mailinator.com' limit 1];
        }
        //StaticValues.disableContactTrigger=False;
        Test.startTest();
        
        System.runAs(objGenUser) {
            Map<String,String> contactInfo = new Map<String,String>();
            Map<String,String> accountInfo = new Map<String,String>();
            contactInfo.put(objContact1.Triplog_UserID__c, objContact1.Phone);
            accountInfo.put(objContact1.Triplog_UserID__c, objAccount.Triplog_API__c);
            ContactTriggerHelper.putHTTPEnableUserTriplog(objContact1.Id,false);
            ContactTriggerHelper.putHTTPUpdateUserPhoneTriplog(contactInfo,accountInfo);
            List<Contact> newCon = new List<Contact>();
            newCon.add(objContact1);
            Map<ID, Contact> conOldMap = new Map<ID, Contact>();
            Map<ID, Contact> connewMap = new Map<ID, Contact>();
            conOldMap.put(objContact1.Id,objContact1);
            connewMap.put(objContact1.Id,objContact1);
            ContactTriggerHelper.createReimRecord(newCon ,conOldMap );
            objContact1.Role__c='Manager';
            update objContact1;
            
            
            List<Contact> lstContact = new List<Contact>();
            lstContact.add(objContact1);           
            
            
            checkRecursive.setting_run(true);
            objContact1.Role__c='Driver/Manager';
            objContact1.External_Email__c='Testn123@mailinator.com';
            update objContact1;
            
            Map<ID, Contact> conOldMap1 = new Map<ID, Contact>();
            conOldMap1.put(objContact1.Id,objContact1);
            
            ContactTriggerHelper.creatuserreimbermentrecrds(lstContact,conOldMap1);
            //ContactTriggerHelper.updtcanadianmil(lstContact,conOldMap1);
            ContactTriggerHelper.updateUser(String.valueOf(objContact1.Id),'Driver');
            ContactTriggerHelper.updateUserInMlog(objContact1.Id);
            System.assertEquals(1, lstContact.size(), 'One record need to be created');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateMessageNotification() {
        
        List<Contact> lstcontact = new List<Contact>();
        Set<Id> setContact = new Set<Id>();
        User objAdmin = [select id from user where Profile.Name = 'System Administrator' limit 1];
        User objGenUser = [select id,IsActive from user where Profile.Name = 'Customer Community Login User - Driver' and IsActive= true  limit 1];
        Test.startTest();
        System.runAs(objAdmin) {
            
            Account objAccount = [select Id from Account Where Name ='Test123'];
            objAccount.Bodily_Injury__c = '100000/300000';
            objAccount.Comprehensive__c = decimal.valueOf('1000');
            objAccount.Property_Damage__c = decimal.valueOf('50000');
            objAccount.Collision__c = decimal.valueOf('1000');
            objAccount.Uninsured_Motorist__c = '100000/300000';
            Update objAccount;
            List<Compliance_Status_Message__mdt> complianceMessages = new List<Compliance_Status_Message__mdt>();
            complianceMessages.add(new Compliance_Status_Message__mdt(
                MasterLabel = 'Expired Insurance',
                Notification_Message__c = 'Your status is ##MM/DD/YY##',
                IsActive__c = true
            ));
            complianceMessages.add(new Compliance_Status_Message__mdt(
                MasterLabel = 'Yes',
                Notification_Message__c = 'Thank you for submitting your insurance. You are currently compliant.',
                IsActive__c = true
            ));     
                        
            // Retrieve the initial contacts to simulate the old map
            List<Contact> initialContacts = [SELECT Id, Role__c, monthly_compliance_status__c, MailingState,Expiration_Date__c FROM Contact where AccountId =: ObjAccount.Id];
            Map<Id, Contact> conOldMap = new Map<Id, Contact>(initialContacts);
            //system.debug('initialContacts@@'+initialContacts);            
            
            // Update contacts to trigger the notification logic
            List<Contact> updatedContacts = new List<Contact>();
            for (Contact con : initialContacts) {
                setContact.add(con.Id);
                //system.debug('Role@@-'+ con.Role__c);
                if (con.Role__c == 'Driver') {
                    con.monthly_compliance_status__c = 'Expired Insurance';
                } else if (con.Role__c == 'Driver/Manager') {
                    con.monthly_compliance_status__c = 'Yes';
                }
                updatedContacts.add(con);
            }
            Update updatedContacts;
            
            //ContactTriggerHelper.updateMessageNotification(updatedContacts,conOldMap);
        }
        // Verify that Message__c records are created
        List<Message__c> messages = [SELECT Id, Contacts__c, Notification_Message__c FROM Message__c where Contacts__c =:setContact and Notification_Message__c !=null and Unread__c = true];
        System.assertEquals(2, messages.size(), 'Two messages should be created.');
        Test.stopTest();
    }
    /*@isTest
    static void complainceStatusmethodTest() {
        
        List<Contact> lstcontact = new List<Contact>();
        Set<Id> setContact = new Set<Id>();
        User objAdmin = [select id from user where Profile.Name = 'System Administrator' limit 1];
        User objGenUser = [select id,IsActive from user where Profile.Name = 'Customer Community Login User - Driver' and IsActive= true  limit 1];
        
        Account objAccount = [select Id from Account Where Name ='Test123'];
        Test.startTest();  
        System.runAs(objAdmin) {            
            
            // Retrieve the initial contacts to simulate the old map
            List<Contact> initialContacts = [SELECT Id, Role__c, monthly_compliance_status__c,MailingState, Expiration_Date__c FROM Contact where AccountId =: ObjAccount.Id];
            Map<Id, Contact> conOldMap = new Map<Id, Contact>(initialContacts);
            //system.debug('initialContacts@@'+initialContacts);
            
            // Update contacts to trigger the notification logic
            List<Contact> updatedContacts = new List<Contact>();
            for (Contact con : initialContacts) {
                //system.debug('Role@@-'+ con.Role__c);
                setContact.add(con.Id);
                if (con.Role__c == 'Driver') {
                    con.monthly_compliance_status__c = 'No - Missing Coverage Dates';
                } else if (con.Role__c == 'Driver/Manager') {
                    con.monthly_compliance_status__c = 'No - Insurance Not Provided';
                }
                updatedContacts.add(con);
            }
            Update updatedContacts;
        }        
        Test.stopTest();
        
        // Verify that Message__c records are created
        List<Message__c> messages = [SELECT Id, Contacts__c, Notification_Message__c FROM Message__c where Contacts__c =:setContact and Unread__c = true];
        System.assertEquals(2, messages.size(), 'Two messages should be created.');
    }*/
    
    @isTest
    static void sendEmailOnDriverCreateTest1() {
        
        User objAdmin = [select id from user where Profile.Name = 'System Administrator' limit 1];
        User objGenUser = [select id,IsActive from user where Profile.Name = 'Customer Community Login User - Driver' and IsActive= true  limit 1];
        Account objAccount;
        Contact objContact1;
        Contact objContact2;
        List<Contact> lstContact = new List<Contact>();
        Set<String> setAccountId = new Set<String>();
        Set<String> setContactId = new Set<String>();
        //StaticValues.disableContactTrigger=true;
        
        Vehicle_URL_Mapping__c objVehicleUrlMap = [select Id, Name, Year__c, Vehicle__c, URL__c,Vehicle_Mapping__c from Vehicle_URL_Mapping__c];
        
        System.runAs(objAdmin) {
            objAccount = [Select id,Vehicle_Types__c,Bi_Weekly_Pay_Period__c,Pay_Period_Days__c,Pay_Period_Start_Date__c,Triplog_API__c,Triplog_Status__c,isUsingTriplog__c,Cell_Phone__c,Reimbursement_Frequency__c from Account where name = 'Test' limit 1];
            setAccountId.add(objAccount.Id);
            objContact1 = [select id,Triplog_UserID__c,Phone,Role__c,External_Email__c, monthly_compliance_status__c,Deactivated_Date__c,Vehicle_Type__c,Vehicle_Value__c,Activation_Date__c,Email,MailingPostalCode,Map_Country__c,Insurance_Attachment_Id__c,Monthly_Reimbursement__c,MailingState,Fixed_Amount__c from contact where Email = 'Testn@mailinator.com' limit 1 ];
            
            objContact2 = [select id,Triplog_UserID__c,Phone,Role__c,External_Email__c, monthly_compliance_status__c,Deactivated_Date__c,Vehicle_Type__c,Vehicle_Value__c,Activation_Date__c,Email,MailingPostalCode,Map_Country__c,Insurance_Attachment_Id__c,Monthly_Reimbursement__c,MailingState,Fixed_Amount__c from contact where Email Like '%paras.dhanani%' limit 1 ];
            setContactId.add(objContact2.Id);
        }
        //StaticValues.disableContactTrigger=False;
        Test.startTest();
        
        System.runAs(objGenUser) {
            Map<String,String> contactInfo = new Map<String,String>();
            Map<String,String> accountInfo = new Map<String,String>();
            contactInfo.put(objContact1.Triplog_UserID__c, objContact1.Phone);
            accountInfo.put(objContact1.Triplog_UserID__c, objAccount.Triplog_API__c);
            ContactTriggerHelper.putHTTPEnableUserTriplog(objContact1.Id,false);
            ContactTriggerHelper.putHTTPUpdateUserPhoneTriplog(contactInfo,accountInfo);
            
            lstContact.add(objContact1);
            Map<ID, Contact> conOldMap = new Map<ID, Contact>();
            Map<ID, Contact> connewMap = new Map<ID, Contact>();
            conOldMap.put(objContact1.Id,objContact1);
            connewMap.put(objContact1.Id,objContact1);
            ContactTriggerHelper.insertDriverAggrementFile (connewMap);
            ContactTriggerHelper.updatePlanParameter(setContactId, setAccountId);
            ContactTriggerHelper.updateMapCountry(lstContact);
            ContactTriggerHelper.updtcanadianmil(new set<Id>{objContact2.Id});
            ContactTriggerHelper.roleChange(new List<String>{objContact2.Id});
            ContactTriggerHelper.bulkPutHTTP(new List<String>{objContact2.Id});
            ContactTriggerHelper.putHTTP(objContact1.Id, objContact1.External_Email__c);
            
        }
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'One record need to be created');
    }
    
    @isTest
    static void sendEmailOnDriverCreateTest2() {
        
       User objAdmin = [select id from user where Profile.Name = 'System Administrator' limit 1];
        User objGenUser = [select id,IsActive from user where Profile.Name = 'Customer Community Login User - Driver' and IsActive= true  limit 1];
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User - Driver' Limit 1];
        
        
        Account objAccount;
        Contact objContact1;        
        List<Contact> lstContact = new List<Contact>();
        
        //StaticValues.disableContactTrigger=true;
        
        Vehicle_URL_Mapping__c objVehicleUrlMap = [select Id, Name, Year__c, Vehicle__c, URL__c,Vehicle_Mapping__c from Vehicle_URL_Mapping__c];
        
        System.runAs(objAdmin) {
            objAccount = [Select id,Vehicle_Types__c,Bi_Weekly_Pay_Period__c,Pay_Period_Days__c,Pay_Period_Start_Date__c,Triplog_API__c,Triplog_Status__c,isUsingTriplog__c,Cell_Phone__c,Reimbursement_Frequency__c from Account where name = 'Test' limit 1];           
            objContact1 = [select id,Triplog_UserID__c,Phone,Role__c, External_Email__c,monthly_compliance_status__c,Deactivated_Date__c,Vehicle_Type__c,Vehicle_Value__c,Activation_Date__c,Email,MailingPostalCode,Map_Country__c,Insurance_Attachment_Id__c,Monthly_Reimbursement__c,MailingState,Fixed_Amount__c,Maintenance_and_Tires__c,Vehicle1Odometer__c,Vehicle2Odometer__c,MailingStreet,MailingCity,MailingCountry,MPG__c,Manager__c,FirstName,LastName from contact where Email = 'Testn@mailinator.com' limit 1];
        }
        //StaticValues.disableContactTrigger=False;
        Test.startTest();
        
        System.runAs(objGenUser) {
            Map<String,String> contactInfo = new Map<String,String>();
            Map<String,String> accountInfo = new Map<String,String>();
            contactInfo.put(objContact1.Triplog_UserID__c, objContact1.Phone);
            accountInfo.put(objContact1.Triplog_UserID__c, objAccount.Triplog_API__c);
            ContactTriggerHelper.putHTTPEnableUserTriplog(objContact1.Id,false);
            ContactTriggerHelper.putHTTPUpdateUserPhoneTriplog(contactInfo,accountInfo);
            
            lstContact.add(objContact1);
            Map<ID, Contact> conOldMap = new Map<ID, Contact>();
            Map<ID, Contact> connewMap = new Map<ID, Contact>();
            conOldMap.put(objContact1.Id,objContact1);
            connewMap.put(objContact1.Id,objContact1);
            ContactTriggerHelper.createReimRecord(lstContact ,conOldMap );            
            ContactTriggerHelper.TrackHistory(conOldMap,lstContact ,accountInfo );
            ContactTriggerHelper.CreateUserFromCommunity (lstContact[0], objProfile.ID);
        }
        Test.stopTest();
        System.assertEquals(1, lstContact.size(), 'One record need to be created');
    }

    // @isTest
    // static void updtcanadianmilTest(){
    //     List<Contact> lstContactId = [SELECT Id FROM Contact WHERE Email LIKE '%testContact1%' LIMIT 1];
    //     Set<Id> setContactId = new Set<Id>();
    //     for(Contact objContact : lstContactId){
    //         setContactId.add(objContact.Id);
    //     }
    //     Test.startTest();
    //     ContactTriggerHelper.updtcanadianmil(setContactId);
    //     Test.stopTest();
    //     System.assertEquals(1, setContactId.size(), 'One record need to be created');
    // }
}