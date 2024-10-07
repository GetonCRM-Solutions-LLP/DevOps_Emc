@isTest
public class ActionItemEmailSendController_Test {

	public static testMethod void method1() {

		Test.startTest();

		Ticket_User__c ticketUser = new Ticket_User__c();
		ticketUser.Name = 'TestUser';
		ticketUser.Role__c = 'Admin';
		insert ticketUser;

		Project__c project = new Project__c();
		project.Name = 'Test Project';
		insert project;

		DateTime now = DateTime.now();
		List<ActionItem__c> actionItemList = new List<ActionItem__c>();
		for(integer i=1; i<10; i++)
		{
			ActionItem__c actionItem = new ActionItem__c();		
			actionItem.Project__c = project.id;
			actionItem.Ticket_User__c = ticketUser.id;
			actionItem.Description__c = 'Test Description of class'+i;
			actionItem.Status__c = 'Not Started';
			actionItem.Due_Date__c = now+i;
			actionItem.Effort_Estimation_In_Hours__c = 20+i;
			insert actionItem;
			actionItemList.add(actionItem);			
		}

		PageReference pageRef = Page.ActionItemEmailSendPage;	
		
		pageRef.getParameters().put('Id',String.valueOf(actionItemList[0].Id)); 
		Test.setCurrentPage(pageRef);
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(actionItemList);
		stdSetController.setSelected(actionItemList);
		ActionItemEmailSendController aisc = new ActionItemEmailSendController(stdSetController);
		aisc.sendMail();
		aisc.actionItemRecord();
		aisc.backPage();
		Test.stopTest();
	}

}