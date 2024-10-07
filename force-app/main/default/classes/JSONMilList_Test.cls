@IsTest
public class JSONMilList_Test {
	
	static testMethod void testParse() {
		String json = '[{\"Trip_Date\":\"08/31/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Trip_Status\":\"rejected\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"33\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"},{\"Trip_Date\":\"08/30/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Trip_Status\":\"Approved\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"22\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"},{\"Trip_Date\":\"08/30/2021\",\"Trip_Origin\":\"6810 Chimney Hill Rd, Crestwood, KY  40014\",\"Trip_Destination\":\"1610 Deer Run Dr, Burlington, KY 41005\",\"Approved_Date\":\"09/30/2021\",\"Actual_Mileage\":\"26\",\"Activity\":\"Business\",\"Contact_Email\":\"jayshah3796@gmail.com\",\"EmployeeId\":\"223344\"}]';
		List<JSONMilList> obj = JSONMilList.parse(json);
		System.assert(obj != null);
	}
}