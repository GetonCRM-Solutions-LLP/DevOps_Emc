@isTest
public with sharing class ReimbuApproveDateUpdaBatchSchTest {
   public static testmethod void method1(){
        Test.startTest();
        ReimbursementApproveDateUpdateBatchSch schBt  = new ReimbursementApproveDateUpdateBatchSch();
        String sch = '0 0 0 18 * ?';
        system.schedule('Test schedule',sch,schBt );
        Test.stopTest();
   }
}