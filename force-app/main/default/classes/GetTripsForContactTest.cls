@istest
public with sharing class GetTripsForContactTest {
	public static testMethod void GetTripsForContactTestMethod() {
		List<Id> conId = new List<Id>();
        
        SendEmail__c  objSendEmail = new SendEmail__c();
        objSendEmail.Name = 'Send Email For Compliance';
		objSendEmail.Send_email_from_code__c = true;
		insert objSendEmail;

        Account a = new Account();
        a.Name = 'Test';
        a.Triplog_API__c = '123456789';
        a.Triplog_Status__c = 'U';
        insert a;

        Contact con = new Contact();
        con.Firstname = 'Test';
        con.Lastname = 'Test';
        con.Account = a;
        con.External_Email__c = 'test@gmail.com';
        insert con;
        conId.add(con.Id);
        
        Test.StartTest();
        PageReference pageRef = Page.GetTripsFromTripLogForContact;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        GetTripsForContact obj_GetTripsForContact = new GetTripsForContact(sc);
        obj_GetTripsForContact.GetTripsForContact(conId, con.Account.Triplog_Status__c);
        obj_GetTripsForContact.getTTripCall();
        obj_GetTripsForContact.backtoContact();
        Test.StopTest();
    }
}