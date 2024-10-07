@isTest
public with sharing class ScheduleTriplogAppVersionUpdateBatchTest {
   public static testmethod void method1(){
        Test.startTest();
        ScheduleTriplogAppVersionUpdateBatch schBt  = new ScheduleTriplogAppVersionUpdateBatch();
        String sch = '0 0 0 18 * ?';
        system.schedule('Test schedule',sch,schBt );
        Test.stopTest();
   }
}