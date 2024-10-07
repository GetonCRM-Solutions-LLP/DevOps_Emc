@istest
public class NewAccountDriverControllerTest {
     
    @TestSetup
    static void CreateTestData()
    {
        NewDashboardMessage__c newMsgCustomSetting = TestDataFactory.newMsgCustomSetting(True);
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(True, 'ConfirmTripTimeERMIController');
        SendEmail__c sendEmailSetting = TestDataFactory.sendEmailCustomSetting(True, 'Send Email For Compliance');
        NewDashboardVideoLink__c videoCustomSetting  = TestDataFactory.NewDashboardVideoLink(true);
        List<Account> lstAccounts = new List<Account>();
        Account objAccount;
        Account objAccount1;
        Account objAccount2;

        List<Contact> lstContact = new List<Contact>();
        List<Contact> lstContact1 = new List<Contact>();
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
            
            objAccount = TestDataFactory.createAccount(False, 'Test Account', False);
            objAccount.Bodily_Injury__c = '100,000/300,000';
            objAccount.Property_Damage__c = 50000;
            objAccount.Collision__c = 1000;
            objAccount.Comprehensive__c = 1000;
            objAccount.MburseDashboardRedirect__c=true;
            objAccount.Pay_Period_Days__c = 12;
            lstAccounts.add(objAccount);
            
            objAccount1 = TestDataFactory.createAccount(False, 'Test1 Account1', False);
            objAccount1.Bodily_Injury__c = '100,000/300,000';
            objAccount1.Property_Damage__c = 50000;
            objAccount1.Collision__c = 1000;
            objAccount1.Comprehensive__c = 1000;
            objAccount1.MburseDashboardRedirect__c=false;
            objAccount.Pay_Period_Days__c = 12;
            lstAccounts.add(objAccount1);
            
			objAccount2 = TestDataFactory.createAccount(False, 'Test2 Account2', False);
            objAccount2.Bodily_Injury__c = '100,000/300,000';
            objAccount2.Property_Damage__c = 50000;
            objAccount2.Collision__c = 1000;
            objAccount2.Comprehensive__c = 1000;
            objAccount2.MburseDashboardRedirect__c=true;
            objAccount.Pay_Period_Days__c = 12;
            lstAccounts.add(objAccount2);
			insert lstAccounts;
            lstContact = TestDataFactory.createDriverContact(False, objAccount.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 1);
            lstContact[0].FirstName = 'Paras';
            lstContact[0].LastName = 'Patel';
            lstContact[0].Email = 'Paras.Patel'+'@gmail.com';
            lstContact[0].External_Email__c = 'Paras.Patel'+'@gmail.com';
            lstContact[0].IsCreatedFromCommunity__c = false;
            lstContact[0].Driver_Packet_Status__c='Uploaded';
            lstContact[0].Insurance_Declaration_Status__c='Uploaded';
            lstContact[0].App__c='x1';
            Insert lstContact[0];
            User objUser= TestDataFactory.createUser(false, profileObj.Id, lstContact[0].Id );
            objUser.UserName='Paras.Patel@gmail.com';
            insert objUser;

            lstContact1  = TestDataFactory.createDriverContact(False, objAccount.Id, 'Driver/Manager', vehicleType.Name, 'xxx1xxx1', 1);
            lstContact1[0].FirstName = 'xxx1';
            lstContact1[0].LastName = 'xxx1';
            lstContact1[0].Email = 'xxx1xxx1'+'@gmail.com';
            lstContact1[0].External_Email__c = 'xxx1xxx1'+'@gmail.com';
            lstContact1[0].IsCreatedFromCommunity__c = false;
            lstContact1[0].Driver_Packet_Status__c='Uploaded';
            lstContact1[0].Insurance_Declaration_Status__c='Uploaded';
            lstContact1[0].App__c='x1';
            Insert lstContact1[0];
            User objUser1= TestDataFactory.createUser(false, profileObj.Id, lstContact1[0].Id );
            objUser1.UserName='xxx1xxx1@gmail.com';
            insert objUser1;

        }

        List<Bi_Weekly_Reimbursement__c> biWeeklyReimList = TestDataFactory.createBiweeklyReim(true, lstContact, system.today().adddays(-15), system.today().addDays(-2), 2, irsRateObj.id);
        system.debug('biWeeklyReimList== ' + biWeeklyReimList);      
        
        Attachment objAttachment = TestDataFactory.createAttachment(true, lstContact[0].id);
    }
    
    @isTest
    static void updateContactDetailTest(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        List<Attachment> lstAttactment = [select id, name from Attachment where parent.id =: lstContact[0].id];
        List<NewAccountDriverController.ContactWrapper> lstContactWrap = new List<NewAccountDriverController.ContactWrapper>();
        NewAccountDriverController.ContactWrapper objContactWrap = new NewAccountDriverController.ContactWrapper();
        objContactWrap.contactId = string.valueOf(lstContact[0].Id);
        objContactWrap.contactName = lstContact[0].Name;
        objContactWrap.insuranceId = lstAttactment[0].Id;
        objContactWrap.contactEmail = lstContact[0].External_Email__c;
        objContactWrap.cellPhone = string.valueOf(lstContact[0].Phone);
        objContactWrap.accountStatus = 'New Account';
        objContactWrap.insuranceStatus = 'Uploaded';
        objContactWrap.driverPacketStatus = 'Uploaded'; 
        objContactWrap.scheduleLink = 'www.gmeetSchedule.com';
        objContactWrap.bodilyInjury = '100,000/300,000';
        objContactWrap.unInsuranceMotorist = '1000';
        objContactWrap.propertyDamage = 50000;
        objContactWrap.comprehensive = 1000;
        objContactWrap.collision = 1000;
        objContactWrap.umbrella = 1000;
        objContactWrap.mlogApp = true;
        objContactWrap.checkActivationDate = true;
        objContactWrap.daysBetweenActivation = 30;
        objContactWrap.planPreview = true;
        lstContactWrap.add(objContactWrap);

        Test.startTest();
        NewAccountDriverController.updateContactDetail(JSON.serialize(lstContactWrap),false);
        Test.stopTest();
    }

    @isTest
    static void getContactDetailTest(){

        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.getContactDetail(string.valueOf(lstContact[0].Id));
        Test.stopTest();
    }

    @isTest
    static void getDriverDetailsCloneTest(){

        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.getDriverDetailsClone(string.valueOf(lstContact[0].Id));
        Test.stopTest();
    }

    @isTest
    static void LoginRedirectionTest(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    @isTest
    static void LoginRedirectionTest1(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReimburse = [select id from Bi_Weekly_Reimbursement__c where Contact__c =:lstContact[0].Id];
        for(Bi_Weekly_Reimbursement__c objBiWeeklyReimburse :lstBiWeeklyReimburse){
        objBiWeeklyReimburse.Confirm_Hours__c = true;
        objBiWeeklyReimburse.Count_Error_Check__c = 3;
        }
        
        Test.startTest();
        Update lstBiWeeklyReimburse;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    @isTest
    static void LoginRedirectionTest2(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        lstContact[0].Role__c = 'Driver';
        
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    
    @isTest
    static void LoginRedirectionTest3(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        lstContact[0].Role__c = 'Driver/Manager';
        
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    @isTest
    static void LoginRedirectionTest4(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        lstContact[0].Role__c = 'Driver/Manager';
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReimburse = [select id from Bi_Weekly_Reimbursement__c where Contact__c =:lstContact[0].Id];
        for(Bi_Weekly_Reimbursement__c objBiWeeklyReimburse :lstBiWeeklyReimburse){
        objBiWeeklyReimburse.Confirm_Hours__c = true;
        objBiWeeklyReimburse.Count_Error_Check__c = 3;
        }
        Test.startTest();
        Update lstBiWeeklyReimburse;
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    @isTest
    static void LoginRedirectionTest5(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        lstContact[0].Role__c = 'Driver/Manager';
        
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }

    @isTest
    static void LoginRedirectionTest6(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        lstContact[0].Role__c = 'Driver/Admin';
        
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    @isTest
    static void LoginRedirectionTest7(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        lstContact[0].Role__c = 'Driver/Admin';
        List<Bi_Weekly_Reimbursement__c> lstBiWeeklyReimburse = [select id from Bi_Weekly_Reimbursement__c where Contact__c =:lstContact[0].Id];
        for(Bi_Weekly_Reimbursement__c objBiWeeklyReimburse :lstBiWeeklyReimburse){
        objBiWeeklyReimburse.Confirm_Hours__c = true;
        objBiWeeklyReimburse.Count_Error_Check__c = 3;
        }
        Test.startTest();
        Update lstBiWeeklyReimburse;
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    @isTest
    static void LoginRedirectionTest8(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        lstContact[0].Role__c = 'Driver/Admin';
        
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    
      @isTest
    static void LoginRedirectionTest9(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        lstContact[0].Role__c = 'Manager';
        lstContact[0].Check_OnBoarding__c = true;
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    
     @isTest
    static void LoginRedirectionTest10(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        lstContact[0].Role__c = 'Manager';
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
      @isTest
    static void LoginRedirectionTest11(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        lstContact[0].Role__c = 'Admin';
        lstContact[0].Check_OnBoarding__c = true;
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    
      @isTest
    static void LoginRedirectionTest12(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        lstContact[0].Role__c = 'Admin';
        lstContact[0].Check_OnBoarding__c = false;
        Test.startTest();
        Update lstContact;
        NewAccountDriverController.loginRedirection(string.valueOf(lstContact[0].Id));      
        Test.stopTest();
    }
    
    @isTest
    static void loginRedirectionADMDTest(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        Test.startTest();

        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);
        
        Test.stopTest();

    }
	
    @isTest
    static void loginRedirectionADMDTest1(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c,Activation_Date__c,Watch_Meeting__c,Packet__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        lstContact[0].Activation_Date__c= Date.today().addMonths(-1).toStartOfMonth().addDays(1);
        lstContact[0].Role__c = 'Driver/Admin';
        lstContact[0].Watch_Meeting__c = true;
        lstContact[0].Packet__c = 'Driver Signed';
        
        Test.startTest();
		Update lstContact;
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);        
        Test.stopTest();

    }

    @isTest
    static void loginRedirectionADMDTest2(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c,Activation_Date__c,Watch_Meeting__c,Packet__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        lstContact[0].Activation_Date__c= Date.today().addMonths(-1).toStartOfMonth().addDays(1);
        lstContact[0].Role__c = 'Driver/Admin';
        lstContact[0].Watch_Meeting__c = true;
        lstContact[0].Packet__c = 'Driver Signed';
        lstContact[0].Check_OnBoarding__c = true;
        lstContact[0].Insurance_Declaration_Status__c = 'Uploaded';
        lstContact[0].Driver_Packet_Status__c= 'Sent';
        Test.startTest();
		Update lstContact;
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);        
        Test.stopTest();

    }
    @isTest
    static void loginRedirectionADMDTest3(){

       List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c,Activation_Date__c,Watch_Meeting__c,Packet__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        
        lstContact[0].Role__c = 'Driver/Admin';
        lstContact[0].Watch_Meeting__c = true;
        lstContact[0].Packet__c = 'Driver Signed';
        lstContact[0].Check_OnBoarding__c = true;
        lstContact[0].Insurance_Declaration_Status__c = 'Uploaded';
        lstContact[0].Driver_Packet_Status__c= 'Sent';
        Test.startTest();
		Update lstContact;
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);        
        Test.stopTest();

    }
    @isTest
    static void loginRedirectionADMDTest4(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c,Activation_Date__c,Watch_Meeting__c,Packet__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];
        
        lstContact[0].Role__c = 'Driver/Admin';
        lstContact[0].Watch_Meeting__c = true;
        lstContact[0].Packet__c = 'Driver Signed';
        lstContact[0].Insurance_Attachment_Id__c = null;
        Test.startTest();
		Update lstContact;
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);        
        Test.stopTest();

    }
    
    @isTest
    static void setEmployeeNameTest2(){

         List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c,Activation_Date__c,Watch_Meeting__c,Packet__c FROM Contact where Email = 'xxx1xxx1@gmail.com'];

        //User objUser = [SELECT id FROM User WHERE ContactId = :lstDriverContact[0].id];

        Test.startTest();
        
            String conId = ApexPages.currentPage().getParameters().put('id',lstContact[0].Id);
            //String accId = ApexPages.currentPage().getParameters().put('accid',lstAccounts[0].Id);
            NewAccountDriverController.setEmployeeName();
        
        Test.stopTest();

        System.assertEquals(1, lstContact.size(), 'One Contact Must be Created.');

    }
    
    @isTest
    static void loginRedirectionADMDTest5(){
		List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c,Activation_Date__c,Watch_Meeting__c,Packet__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        lstContact[0].Activation_Date__c= Date.today().addMonths(-1).toStartOfMonth().addDays(1);
        lstContact[0].Role__c = 'Driver/Manager';
        lstContact[0].Watch_Meeting__c = true;
        lstContact[0].Packet__c = 'Driver Signed';
        lstContact[0].Insurance_Declaration_Status__c = 'Uploaded';
        lstContact[0].Driver_Packet_Status__c= 'Sent';        
        Test.startTest();
		Update lstContact;
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);        
        Test.stopTest();

    }/*
    @isTest
    static void loginRedirectionADMDTest6(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx5xxx5@gmail.com'];
        Test.startTest();

        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);

        
        Test.stopTest();

    }
    @isTest
    static void loginRedirectionADMDTest7(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'xxx6xxx6@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),true);
        NewAccountDriverController.loginRedirectionADMD(string.valueOf(lstContact[0].Id),false);
        Test.stopTest();

    }*/


    @isTest
    static void SendEmailTest1(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        List<Attachment> lstAttactment = [select id, name from Attachment where parent.id =: lstContact[0].id];
        List<NewAccountDriverController.ContactWrapper> lstContactWrap = new List<NewAccountDriverController.ContactWrapper>();
        NewAccountDriverController.ContactWrapper objContactWrap = new NewAccountDriverController.ContactWrapper();
        objContactWrap.contactId = string.valueOf(lstContact[0].Id);
        objContactWrap.contactName = lstContact[0].Name;
        objContactWrap.insuranceId = lstAttactment[0].Id;
        objContactWrap.contactEmail = lstContact[0].External_Email__c;
        objContactWrap.cellPhone = string.valueOf(lstContact[0].Phone);
        objContactWrap.accountStatus = 'New Account';
        objContactWrap.insuranceStatus = 'Uploaded';
        objContactWrap.driverPacketStatus = 'Uploaded'; 
        objContactWrap.scheduleLink = 'www.gmeetSchedule.com';
        objContactWrap.bodilyInjury = '100,000/300,000';
        objContactWrap.unInsuranceMotorist = '1000';
        objContactWrap.propertyDamage = 50000;
        objContactWrap.comprehensive = 1000;
        objContactWrap.collision = 1000;
        objContactWrap.umbrella = 1000;
        objContactWrap.mlogApp = true;
        objContactWrap.checkActivationDate = true;
        objContactWrap.daysBetweenActivation = 30;
        objContactWrap.planPreview = true;
        lstContactWrap.add(objContactWrap);

        Test.startTest();        
        NewAccountDriverController.sendEmailToDriver( JSON.serialize(lstContactWrap) , 'Test', string.valueOf(lstContact[0].Id));
        Test.stopTest();

    }
    
    @isTest
    static void SendEmailTest2(){

        List<Contact> lstContact = [SELECT Id, Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        List<Attachment> lstAttactment = [select id, name from Attachment where parent.id =: lstContact[0].id];
        List<NewAccountDriverController.ContactWrapper> lstContactWrap = new List<NewAccountDriverController.ContactWrapper>();
        NewAccountDriverController.ContactWrapper objContactWrap = new NewAccountDriverController.ContactWrapper();
        objContactWrap.contactId = string.valueOf(lstContact[0].Id);
        objContactWrap.contactName = lstContact[0].Name;
        objContactWrap.insuranceId = lstAttactment[0].Id;
        objContactWrap.contactEmail = lstContact[0].External_Email__c;
        objContactWrap.cellPhone = string.valueOf(lstContact[0].Phone);
        objContactWrap.accountStatus = 'New Account';
        objContactWrap.insuranceStatus = 'Uploaded';
        objContactWrap.driverPacketStatus = 'Uploaded'; 
        objContactWrap.scheduleLink = 'www.gmeetSchedule.com';
        objContactWrap.bodilyInjury = '100,000/300,000';
        objContactWrap.unInsuranceMotorist = '1000';
        objContactWrap.propertyDamage = 50000;
        objContactWrap.comprehensive = 1000;
        objContactWrap.collision = 1000;
        objContactWrap.umbrella = 1000;
        objContactWrap.mlogApp = true;
        objContactWrap.checkActivationDate = true;
        objContactWrap.daysBetweenActivation = 30;
        objContactWrap.planPreview = true;
        lstContactWrap.add(objContactWrap);

        Test.startTest();        
        NewAccountDriverController.sendEmailToDriver( JSON.serialize(lstContactWrap) , 'Test', null);
        Test.stopTest();

    }


    @isTest
    static void getCustomSettingsTest(){
        Test.startTest();
        NewAccountDriverController.getCustomSettings();
        Test.stopTest();
    }

    @isTest
    static void getCustomSettingsForMessageTest(){
        Test.startTest();
        NewAccountDriverController.getCustomSettingsForMessage();
        Test.stopTest();
    }

    @isTest
    static void sendWelcomeEmailTest(){

        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.sendWelcomeEmail(lstContact[0].AccountId, lstContact[0].External_Email__c);
        Test.stopTest();
    }
    
    @isTest
    static void readFromFileInchunkTest1(){

        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.readFromFileInchunk(null, null,null,null,null,null);
        Test.stopTest();
    }

    @isTest
    static void sendInsuranceEmailTest(){

        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.sendInsuranceEmail(string.valueOf(lstContact[0].Id),'Test', 'test.account@gmail.com' );
        Test.stopTest();
    }

    

    @isTest
    static void updateContactInsuranceFieldTest(){

        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];

        Test.startTest();        
        NewAccountDriverController.updateContactInsuranceField(string.valueOf(lstContact[0].Id),'Paras.Patel');
        Test.stopTest();

    }

    @isTest
    static void getRoleTest(){

        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        NewAccountDriverController.getRole(string.valueOf(lstContact[0].Id));
        Test.stopTest();
    }
    @isTest
    static void setEmployeeNameTest(){
        List<Contact> lstContact = [SELECT Id, AccountId,Name, Phone, External_Email__c FROM Contact where Email = 'Paras.Patel@gmail.com'];
        
        Test.startTest();
        /*PageReference objPageRef = Page.MyTestPage; // Replace with your actual Visualforce page name
        Test.setCurrentPage(objPageRef);
        testPage.getParameters().put('id', lstContact[0].Id);
        NewAccountDriverController.setEmployeeName();*/
        Test.stopTest();
    }
}