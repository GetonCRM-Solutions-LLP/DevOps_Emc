@isTest
public class SendEmailToUploadonJulyTest {
	public static testmethod void test1(){

      Test.startTest();
        RecordUtilityClass.vehicleUrlMapping();

        account acc = new account();
        acc.Name = 'TestAccount';
        insert acc;
        List<Contact> conList = new List<Contact>();
        for(integer i=1;i<200;i++){
            Contact con = new Contact();
            con.LastName = 'Test' +i;
            con.External_Email__c = 'vishal.sqs'+i+'@gmail.com';
            con.AccountId = acc.Id;
            con.Role__c = 'Driver';
            con.Vehicle_Type__c = '2019 Full-Size Sedan';
            con.Active__c = True ; 
            conList.add(con);
        }
        insert conList;
        SendEmailToUploadonJuly schedule = new SendEmailToUploadonJuly();
        String chron = '0 58 15 * * ?';        
        system.schedule('Test Schedule', chron,Schedule );
        Schedule.flag=True;
        Schedule.sendMail();
    }
}