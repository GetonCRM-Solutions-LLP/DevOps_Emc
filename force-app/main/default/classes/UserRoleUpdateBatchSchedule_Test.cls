@isTest
public with sharing class UserRoleUpdateBatchSchedule_Test {
	public static String CRON_EXP = '0 30 * ? * *';
	public UserRoleUpdateBatchSchedule_Test() 
	{ 

	}
	@isTest
	public static void test_method_one() 
	{
		SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
		Account obj_account = new Account();
		obj_account.Name='Test Account';
		Insert obj_account;

		Contact objcontact = new Contact();
		objcontact.FirstName='tt';
		objcontact.Lastname='testdsfsdfsdfdsfsfsdfsdfds';
		objcontact.email='test3242342@gmail.com';
		objcontact.External_Email__c='test3242342@gmail.com';
		objcontact.Role__c = 'Manager';
		objcontact.Accountid=obj_account.id;
		objcontact.compliancestatus__c ='Yes';
		objcontact.Deactivated_Date__c=null;
		Insert objcontact;

		objcontact.Role__c='Driver';
		update objcontact;

		

		UserRoleUpdateBatchSchedule obj_UserRoleUpdateBatchSchedule = new UserRoleUpdateBatchSchedule();
		String scheduledJobId = System.schedule('ScheduledApexTest',CRON_EXP, obj_UserRoleUpdateBatchSchedule);        
		UserRoleUpdateBatch obj_UserRoleUpdateBatch = new UserRoleUpdateBatch();
		Database.executebatch(obj_UserRoleUpdateBatch,1);
	} 
}