@istest
public class ReviewAndApproveMileageForDeltaTest {
	
    public static testmethod void testMethod9(){
         Account acc = TestUtilityClass.getTestSingleAccount();
        Contact con = TestUtilityClass.getTestSingleContact3(acc);
        Contact cont = TestUtilityClass.getTestSingleContact4(acc,con);
        Employee_Reimbursement__c emp = TestUtilityClass.getTestEmployeeReimbursement3(con);
        
        ReviewAndApproveMileageForDelta rev = new ReviewAndApproveMileageForDelta();
        Database.executeBatch(rev, 1);
    }
}