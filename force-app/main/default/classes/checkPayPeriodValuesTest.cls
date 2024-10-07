@isTest
public class checkPayPeriodValuesTest {
    public static testMethod void testAccount() {
        Account accountObj = new Account();
        accountObj.Name = 'Test';
       // accountObj.Bi_Weekly_Pay_Period__c = checkByWeek;
        //accountObj.Pay_Period_Days__c = 13;
        //accountObj.Pay_Period_Start_Date__c = system.today().adddays(-14);
        accountObj.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
        accountObj.Triplog_Status__c = 'U';
        accountObj.isUsingTriplog__c = True;
        insert accountObj;
    }
}