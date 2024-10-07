/****************************************************************************************************
* Create By : Dhanraj Khatri
* Create Date : 06/07//2022
* Description :  Test Class for Coverage Of All Related API Classes

* Modification Log:
*  -------------------------------------------------------------------------------------------------
*  * Developer                         Date                   Description
*  *------------------------------------------------------------------------------------------------
*  *   -                                -                         -
*****************************************************************************************************/

@isTest
public class TrueDialogCalloutTest {
    
    /** 
* ********************************************************
* test method for Sending Message API callout
* ********************************************************
*/
    
    @isTest
    public static void testSendMessageAPICallout(){
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'demo',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        
        Message__c message = new Message__c();
        message.Message__c = 'test contact id';
        message.Contacts__c = conList[0].id;
        insert message;
        
        List<Id> idList = new List<Id>();
        idList.add(conList[0].id);
        
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());   
       
        TrueDialogSendMessageAPI.getAllMessageByContact(conList[0].id);
        TrueDialogSendMessageAPI.sendMessageToContact(conList[0].id,'Hello');
        TrueDialogSendMessageAPI.getContactPicture(conList[0].id);
        
        

 
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=message.id;
        insert attach;
        
        Test.startTest();
		TrueDialogSendMessageAPI.sendImage(conList[0].id,'Unit Test Attachment Body','att.jpg','Test  Message');

        Test.stopTest();
        
    }
    
    /** 
* ********************************************************
* test method for PUT Contact API callout
* ********************************************************
*/
    @isTest
    public static void testContactPutAPICallout(){
        
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());   
        Test.startTest();
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'demo',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        
        Account a = TestDataFactory.createAccount(false, 'demo', false);
        a.True_Dialog__c = true;
        insert a;
        Contact c = TestDataFactory.createCICDContact(false, a.id);
        
        c.email = 'test@gmail.com';
        c.MobilePhone = '+13239638840';
        c.lastName = 'Veer';
        c.firstName = 'Sharma';
        c.External_Email__c = 'test@gmail.com';
        c.TrueDialog_Contact_Id__c = '111111';
        insert c;

        
        Set<Id> lstId = new Set<Id>();
        lstId.add(c.id);
        
        TrueDialogContactAPI tdContactApi = new TrueDialogContactAPI(lstId);
        Database.executeBatch(tdContactApi,1);
        
        Test.stopTest();
    }
    
    
    /** 
* ********************************************************
* test method for POST Contact API callout
* ********************************************************
*/
    @isTest
    public static void testContactPostAPICallout(){
        
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());   
        Test.startTest();	
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'demo',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);
            acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
            userObj = TestDataFactory.createUser(true, profileObj.Id, conList[0].Id);
        }
        
        Account a = TestDataFactory.createAccount(false, 'demo', false);
        a.True_Dialog__c = true;
        insert a;
        
        Contact c  = TestDataFactory.createCICDContact(false, a.id);
        
        c.email = 'test@gmail.com';
        c.MobilePhone = '+13239638840';
        c.lastName = 'Veer';
        c.firstName = 'Sharma';
        c.External_Email__c = 'test@gmail.com';
        
        insert c;
        
        
        Set<Id> lstId = new Set<Id>();
        lstId.add(c.id);
        
          TrueDialogContactAPI tdContactApi = new TrueDialogContactAPI(lstId);
          Database.executeBatch(tdContactApi,1);
        //  
        
        
        
        PageReference pageRef = Page.TrueDialog;
        Test.setCurrentPage(pageRef);// Add your VF page Name here
        ApexPages.currentPage().getParameters().put('id', String.valueOf(a.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        TrueDIalogVFPageController obj = new TrueDIalogVFPageController(sc);
        
        obj.getPageRecord();
        obj.onSubmit();
        
        
        
        
        Test.stopTest();
    }
    
    
    
    
}