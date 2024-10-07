@isTest
public class scheduledMileageSubmissionBatchTest {
	@isTest
    public static void mileageSubmissionBatchTest(){
        
        Test.startTest();
        scheduledMileageSubmissionBatch sh1 = new scheduledMileageSubmissionBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
}