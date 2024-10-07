@isTest
public with sharing class ScheduledReimbursementStatementBatchTest {
   public static testmethod void method1(){
        Test.startTest();
        ScheduledReimbursementStatementBatch schBt  = new ScheduledReimbursementStatementBatch();
        String sch = '0 0 0 18 * ?';
        system.schedule('Test schedule',sch,schBt );
        Test.stopTest();
   }
}