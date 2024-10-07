@isTest
public class DailyStatusEmailSendController_Test {
	
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
		for(integer i=0; i<10; i++)
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

		List<DailyStatus__c> dailyStatusList = new List<DailyStatus__c>();
		for(integer i=0; i<10; i++)
		{
			DailyStatus__c dailyStatus = new DailyStatus__c();
			dailyStatus.Working_Hours__c = i;
			dailyStatus.Task_Description__c = 'Test DailyStatus Description of class'+i;
			dailyStatus.ActionItem__c = actionItemList[i].id;
			dailyStatus.Ticket_User__c = ticketUser.id;
			insert dailyStatus;
			dailyStatusList.add(dailyStatus);
		}

		PageReference pageRef = Page.DailyStatusEmailSendPage;	
		
		pageRef.getParameters().put('Id',String.valueOf(dailyStatusList[0].Id)); 
		Test.setCurrentPage(pageRef);
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(dailyStatusList);
		stdSetController.setSelected(dailyStatusList);
		DailyStatusEmailSendController dses = new DailyStatusEmailSendController(stdSetController);
		dses.sendMail();
		dses.dailyStatusRecord();
		dses.backPage();
		Test.stopTest();

	}
}