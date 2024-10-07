@isTest
public class RG_CommunityCustomControllerClone_Test {
	
	public static testmethod void RG_CommunityCustomControllerClone_TestMethod() {
		test.startTest();
		PageReference pageRef = Page.adminlogin;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('param1','True');

   		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

        RG_CommunityCustomLoginControllerClone customLogin = new RG_CommunityCustomLoginControllerClone();
        RG_CommunityCustomLoginControllerClone.login();
        
	}
}