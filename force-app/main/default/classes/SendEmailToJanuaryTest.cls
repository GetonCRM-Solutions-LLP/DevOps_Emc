@isTest
public class SendEmailToJanuaryTest {
    public static testmethod void test1(){
        
        Test.startTest();
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        RecordUtilityClass.vehicleUrlMapping();

        account acc = new account();
        acc.Name = 'TestAccount';
        insert acc;
        List<Contact> conList = new List<Contact>();
        for(integer i=1;i<10;i++){
            Contact con = new Contact();
            con.FirstName = 'Demo';
            con.LastName = 'Test' +i;
            con.External_Email__c = 'vishal.sqs'+i+'@gmail.com';
            con.AccountId = acc.Id;
            con.Role__c = 'Driver';
            con.Vehicle_Type__c = '2019 Full-Size Sedan';
            con.Active__c = True ; 
            conList.add(con);
        }
        insert conList;
        SendEmailToJanuary obj = new SendEmailToJanuary();
        Database.executeBatch (obj,200);
    }
}