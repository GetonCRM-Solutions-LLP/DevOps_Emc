@IsTest
public class triplogerrorcontrollertest {
	public static testMethod Void test1() {
		Account account = new Account();
        account.Name = 'Delta';
        insert account;
        
        Contact con = new Contact(); 
        con.AccountId= account.Id;
        con.FirstName = 'test FirstName';
        con.LastName = 'test LastName';
        con.External_Email__c= 'abcd123@gmail.com';
        con.LastName = 'Solanki';
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Name = 'Virn:04-2016';
        er.Contact_Id__c = con.id; 
        er.Month__c = '04-2017';
        insert er;

		Tripslog__c triplog = new Tripslog__c();
		triplog.Employee_Reimbursement__c = er.Id;
		triplog.Contact__c = con.id;
		insert triplog;

		triplogerrorcontroller triplogObject = new triplogerrorcontroller();
		triplogObject.getresettableForMonth();
		triplogObject.resetfilter();
		triplogObject.Selected_month = '07-2018';
		triplogObject.resetfilter();
		
	}
	
}