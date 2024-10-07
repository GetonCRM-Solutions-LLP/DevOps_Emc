@isTest
private class WrapperTaxReport_Test {
	
	@isTest static void test_method_one() {
		// Implement test code
		WrapperTaxReport wrp= new WrapperTaxReport();
		wrp.drivername = 'test';
		wrp.employeeid = '23234';
		wrp.emailid = 'dfed@gmail.com';
		wrp.approvedmileages = 23;
		wrp.totalreim = 21;
		wrp.iRSallowable = 212;
		wrp.imputedincome = 23;
		wrp.month = 2;
		wrp.year = '2019';
		wrp.monthyear = '02-2019';
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}