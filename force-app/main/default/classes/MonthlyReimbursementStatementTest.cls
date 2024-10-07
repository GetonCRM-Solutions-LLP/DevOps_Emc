@istest
public class MonthlyReimbursementStatementTest {
    
    public static testmethod void testMethod1(){

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        Account acc = TestUtilityClass.getTestSingleAccount();
        RecordUtilityClass.vehicleUrlMapping();

        // Contact con = RecordUtilityClass.buildAdminContact(acc);
        // insert con;

        Contact con = new Contact();
        
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'minkesh.patel1478@gmail.com';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c=1;
        insert con;

        con.External_Email__c ='minkesh.patel1478@gmail.com';        
        update con;
        //Employee_Reimbursement__c emp = TestUtilityClass.getTestEmployeeReimbursement(con);
        
        Employee_Reimbursement__c empReimb = new Employee_Reimbursement__c();
        //RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        empReimb.Contact_Id__c = con.id;
        empReimb.Name = 'Test';
        empReimb.Fuel_Price__c = 134;
        empReimb.MPG__c = 47;
        empReimb.Fixed_Amount__c = 50;
        //empReimb.Month__c = ilmr.getLastMonthValue(-1) ;
        empReimb.Month__c =  '01-2020';
        empReimb.Monthly_Mileage__c = 50;
        empReimb.Approved_Date__c = System.today() - 10;
        empReimb.Maintenance_and_Tires__c =10;
        empReimb.Status__c='Approved';
        insert empReimb;
        
        MonthlyReimbursementStatement mon = new MonthlyReimbursementStatement();
        Database.executeBatch(mon,1);
    }
}