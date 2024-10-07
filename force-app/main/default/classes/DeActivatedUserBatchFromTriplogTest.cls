@isTest
public class  DeActivatedUserBatchFromTriplogTest {
    public static testmethod void test() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
    	TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        SendEmail__c setting = new SendEmail__c(Send_email_from_code__c = false, Name = 'Send Email For Compliance');
        insert setting;
        SendEmail__c setting1 = new SendEmail__c(Send_email_from_code__c = true, Name = 'DeActivatedUserBatchFromTriplog');
        insert setting1;
        
        Account accs = new Account();
        accs.Name = 'test';
        accs.Triplog_API__c = 'test1';
        accs.isUsingTriplog__c = true;
        insert accs;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.Triplog_UserID__c = 'test';
        con.Deactivated_Date__c =  system.now();
        con.isCommunityUser__c = true;
        con.External_Email__c = 'test.patel1478@gmail.com';
        con.IsDeactivated__c = false;
        con.AccountId = accs.Id;
        con.Role__c = 'Driver';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        insert con;
        
        List<String> contactIds=new List<String>();
        contactIds.add(con.id);
        
        Test.startTest();
            Test.SetMock(HttpCalloutMock.class, new DeActivatedUserBatchCalloutMock());
            DeActivatedUserBatchFromTriplog batchobj = new DeActivatedUserBatchFromTriplog();
            DataBase.executeBatch(batchobj, 1);
        
        	DeActivatedUserBatchFromTriplog batchobjacc = new DeActivatedUserBatchFromTriplog(accs.id);
            DataBase.executeBatch(batchobjacc, 1);
        	
        	DeActivatedUserBatchFromTriplog batchobjcon = new DeActivatedUserBatchFromTriplog(contactIds);
            DataBase.executeBatch(batchobjcon, 1);
        
        Test.stopTest();
    }
}