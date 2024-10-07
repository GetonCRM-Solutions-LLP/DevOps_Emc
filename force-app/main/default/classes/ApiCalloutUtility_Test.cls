@isTest
public class ApiCalloutUtility_Test {
	@isTest static void test_method_one() {
		ApiCalloutUtility acu = new ApiCalloutUtility();
		Test.startTest();
		Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
		ApiCalloutUtility.executeCallout('abc123','GET','triplog.com','12345','Body');
	}
}