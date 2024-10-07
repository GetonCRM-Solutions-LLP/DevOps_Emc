@isTest
public class updateHourstoActionItem_Test 
{
    @isTest static void testmethod1()
    {
        List<DailyStatus__c> listDailystatus = new List<DailyStatus__c>();
        List<ActionItem__c> listActionitems = new List<ActionItem__c>();
           
		for(Integer i=0;i<=10;i++)//for loop for Actionitem
		{   
			Project__c projectobj = new Project__c();//project new obj
			projectobj.Name = 'EMC'+ i;
			insert projectobj;
			
			Ticket_User__c ticketobj = new Ticket_User__c();//ticketuser new obj
			ticketobj.Name ='test'+ i;
			ticketobj.Role__c = 'Admin';
			insert ticketobj;
			
			ActionItem__c actionitemobj= new ActionItem__c();//new ationitemobj
			actionitemobj.Total_Working_Hours__c = 20 + i;
			actionitemobj.Project__c = projectobj.Id;
			actionitemobj.Ticket_User__c = ticketobj.Id;
			
			insert actionitemobj;
			listActionitems.add(actionitemobj);
		}
		for(Integer i=0;i<=10;i++)// loop for dailystatus 1
		
		{       
			DailyStatus__c dailystatusobj = new DailyStatus__c();//dailystatus obj
			dailystatusobj.ActionItem__c = listActionitems[i].id;
			dailystatusobj.Working_Hours__c = 10 + i;
			insert dailystatusobj;
			listDailystatus.add(dailystatusobj);	
		}
		for(Integer i=0;i<=10;i++)//loop for dailystatus 2
		{            
			DailyStatus__c dailystatusobj = new DailyStatus__c();//dailystatus obj
			dailystatusobj.ActionItem__c = listActionitems[i].id;
			dailystatusobj.Working_Hours__c = 10 + i;
			insert dailystatusobj;
			listDailystatus.add(dailystatusobj);
		}
			Integer hours=1;
		for(DailyStatus__c daily :listDailystatus)
		{	
			daily.Working_Hours__c = hours++; //working hours update
		}
			update listDailystatus;
				
		for(ActionItem__c act :listActionitems)
		{	
			act.Total_Working_Hours__c = hours++; //total working hours update
		}
		update listActionitems;
	}
    @isTest static void testmethod2()
    {
		List<DailyStatus__c> listDailystatus = new List<DailyStatus__c>(); //created actionitem again
		List<ActionItem__c> listActionitems = new List<ActionItem__c>();    
		Project__c projectobj = new Project__c();//project new obj
		projectobj.Name = 'EMC 1';
		insert projectobj;
	
		Ticket_User__c ticketobj = new Ticket_User__c();//ticketuser new obj
		ticketobj.Name = 'test1';
		ticketobj.Role__c ='Admin';
		insert ticketobj;
	
		ActionItem__c actionitemobj = new ActionItem__c();//new ationitemobj
		actionitemobj.Total_Working_Hours__c = 20;
		actionitemobj.Project__c = projectobj.Id;
		actionitemobj.Ticket_User__c = ticketobj.Id; 
		listActionitems.add(actionitemobj);

		ActionItem__c actionitemobj1 = new ActionItem__c();//new ationitemobj
		actionitemobj1.Total_Working_Hours__c = 20;
		actionitemobj1.Project__c = projectobj.Id;
		actionitemobj1.Ticket_User__c = ticketobj.Id;
		listActionitems.add(actionitemobj1);
		insert listActionitems;
			
		DailyStatus__c dailystatusobj = new DailyStatus__c();//dailystatus obj
		dailystatusobj.ActionItem__c = listActionitems[0].id;
		dailystatusobj.Working_Hours__c = 10;
		listDailystatus.add(dailystatusobj);
		DailyStatus__c dailystatusobj1 = new DailyStatus__c();//dailystatus obj
		dailystatusobj1.ActionItem__c = listActionitems[0].id;
		dailystatusobj1.Working_Hours__c = 10;
		listDailystatus.add(dailystatusobj1);
		insert listDailystatus;
	}
}