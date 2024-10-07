@istest
public class ReviewAndApproveMileageTest {
	
    public static testmethod void testMethod8(){
        Account acc = TestUtilityClass.getTestSingleAccount2();
        Contact con = TestUtilityClass.getTestSingleContact3(acc);
        Contact cont = TestUtilityClass.getTestSingleContact4(acc,con);
        Employee_Reimbursement__c emp = TestUtilityClass.getTestEmployeeReimbursement3(con);
        
        ReviewAndApproveMileage app = new ReviewAndApproveMileage();
        Database.executeBatch(app, 1);
    }
}