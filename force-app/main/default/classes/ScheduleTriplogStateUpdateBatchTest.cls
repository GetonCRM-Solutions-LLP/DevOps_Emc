@isTest
public with sharing class ScheduleTriplogStateUpdateBatchTest {
   public static testmethod void method1(){
        Test.startTest();
        ScheduleTriplogStateUpdateBatch schBt  = new ScheduleTriplogStateUpdateBatch();
        String sch = '0 0 0 18 * ?';
        system.schedule('Test schedule',sch,schBt );
        Test.stopTest();
   }
}