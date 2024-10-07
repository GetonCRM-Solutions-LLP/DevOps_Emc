@isTest
public class  DeActivatedUserBatchTest {
    public static testmethod void DeActivatedUserBatchTestMethod1() {
        SendEmail__c  objSendEmail = new SendEmail__c();
        objSendEmail.Name = 'Send Email For Compliance';
        objSendEmail.Send_email_from_code__c = false;
        insert objSendEmail;
		
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        Account ac = new Account();
        ac.Name = 'test2';
        ac.Triplog_API__c = 'test2';
        ac.isUsingTriplog__c = true;
        insert ac;
        
        Gas_Prices__c g = new Gas_Prices__c();
        g.Fuel_Price__c = 2.20;
        g.Month_Year__c = Date.valueof('2018-10-01');
        g.State__c = 'GJ';
        g.City__c = 'AHM';
        insert g;
        
        Gas_prices__c g1=new Gas_prices__c();
        g1.Fuel_Price__c = 2.20;
        g1.Month_Year__c = Date.today().addMonths(-1).tostartofmonth();
        g1.State__c = 'GJ';
        g1.City__c = 'AHM';
        insert g1;
        
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Contact c = new Contact();
        c.LastName = 'test';
        c.Triplog_UserID__c = 'test';
        c.Deactivated_Date__c =  system.now();
        c.isCommunityUser__c = true;
        c.External_Email__c = 'test.patel1478@gmail.com';
        c.IsDeactivated__c = false;
        c.AccountId = ac.Id;
        c.Role__c = 'Driver';
        c.Maintenance_and_Tires__c = 40.00;
        c.MPG__c = 50.00;
        c.Mailingcity = 'AHM';
        c.MailingState = 'GJ';
        c.Vehicle_Type__c = '2019 Full-Size Sedan';
        insert c;
        
        Contact c2=[SELECT name FROM Contact WHERE id=:c.id];
        
        Employee_Reimbursement__c e=new Employee_Reimbursement__c();
        e.name=c2.Name+':12-2019';
        e.Contact_Id__c=c.id;
        e.Fuel_Price__c=2.22;
        e.Month__c='12-2019';
        insert e;
          
        List<String> contactIds=new List<String>();
        contactIds.add(c.id);
        
        Test.startTest();
            DeActivatedUserBatch batchcon = new DeActivatedUserBatch(contactIds);
            DataBase.executeBatch(batchcon, 1);
            DeActivatedUserBatch batchac = new DeActivatedUserBatch(ac.id);
            DataBase.executeBatch(batchac, 1);
            DeActivatedUserBatch batch = new DeActivatedUserBatch();
            DataBase.executeBatch(batch, 1);
        Test.stopTest();
    }
}