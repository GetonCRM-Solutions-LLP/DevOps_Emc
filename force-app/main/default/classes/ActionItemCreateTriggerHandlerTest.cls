/**
 * @File Name          : ActionItemCreateTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 28/2/2020, 1:08:05 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public with sharing class ActionItemCreateTriggerHandlerTest {
    static testmethod void test1(){
		
		ActionItemCreateCustom__c objCustomSet = new ActionItemCreateCustom__c();
		objCustomSet.Name = 'CustomData';
		objCustomSet.Compare_Fields__c = 'Priority__c,Ticket_User__c';
		objCustomSet.InsertEmailTemplate__c = 'New_ActionItem_Record_create_Template';
		objCustomSet.UpdateEmailTemplate__c = 'Action_Item_Update_Email';
		objCustomSet.IsInsertExecution__c = True;
		objCustomSet.IsUpdateExecution__c = True;
		objCustomSet.NewActionItemEmailCc__c = 'testdataset@gmail.com';
		insert objCustomSet;

		List<Ticket_User__c> ticketUserList = new List<Ticket_User__c>();
		for(integer i=1; i<11; i++)
		{
			Ticket_User__c ticketUser = new Ticket_User__c();
			ticketUser.Name = 'TestUser '+i;
			ticketUser.Role__c = 'Admin';
			ticketUser.email__c = 'testData'+i+'@gmail.com';
			ticketUserList.add(ticketUser);
		}
		insert ticketUserList;

		Project__c project = new Project__c();
		project.Name = 'Test Project';
		insert project;

		DateTime now = DateTime.now();
		List<ActionItem__c> actionItemList = new List<ActionItem__c>();
		for(integer i=1; i<10; i++)
		{
			ActionItem__c actionItem = new ActionItem__c();            
			actionItem.Project__c = project.id;            
			actionItem.Ticket_User__c = ticketUserList[i].id;
			actionItem.Description__c = 'Test Description of class'+i;
			actionItem.Status__c = 'Not Started';
            actionItem.Priority__c = 'Medium';
            actionItem.Type__c = 'Change Request';
			actionItem.Due_Date__c = now+i;
			actionItem.Effort_Estimation_In_Hours__c = 20+i;           
			actionItemList.add(actionItem);			
		}
        insert actionItemList;        

        for(integer i=1; i<5; i++)
		{
            actionItemList[i].Priority__c = 'High';
			actionItemList[i].Ticket_User__c = ticketUserList[i].id;            
		}
		objCustomSet.IsUpdateExecution__c = True;
		update objCustomSet;
        update actionItemList;
    }
}