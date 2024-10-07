@isTest
public class RG_ChartingTest {
    public static testmethod void Testmethod1() {

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account account = TestUtilityClass.getTestSingleAccount();
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.showTeamRecord__c = true;
        con.FirstName = 'Test1';
        con.LastName = 'Contact1';
        con.AccountId = account.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '12362434445';
        con.External_Email__c = 'test1@gmail.com';
        con.Deactivated_Date__c = null;
        con.isCommunityUser__c = true;
        con.Role__c = 'Admin';
        con.Monthly_Mileage_Limit__c = 1;
        //insert con;
        conList.add(con);


        Contact con2 = new Contact();
        con2.showTeamRecord__c = true;
        con2.FirstName = 'Tes12';
        con2.LastName = 'Contac4t1';
        con2.AccountId = account.Id;
        con2.MailingStreet = 'Test Street';
        con2.MailingCity = 'Test City';
        con2.MailingState = 'ON';
        con2.MailingPostalCode = '123';
        con2.MailingCountry = 'CA';
        con2.Phone = '12362434445';
        con2.External_Email__c = 'tes31@gmail.com';
        con2.Deactivated_Date__c = null;
        con2.isCommunityUser__c = true;
        con2.Role__c = 'Manager';
        con2.Manager__c = con.Id;
        con2.Monthly_Mileage_Limit__c = 1;
        conList.add(con2);

        Contact con3 = new Contact();
        con3.showTeamRecord__c = true;
        con3.FirstName = 'Test4';
        con3.LastName = 'Contact4';
        con3.AccountId = account.Id;
        con3.MailingStreet = 'Test Street';
        con3.MailingCity = 'Test City';
        con3.MailingState = 'ON';
        con3.MailingPostalCode = '123';
        con3.MailingCountry = 'CA';
        con3.Phone = '12362434445';
        con3.External_Email__c = 'test3@gmail.com';
        con3.Deactivated_Date__c = null;
        con3.isCommunityUser__c = true;
        con3.Role__c = 'Driver';
        con3.Monthly_Mileage_Limit__c = 1;
        con3.Manager__c = con2.Id;
        conList.add(con3);
        insert conList;
        System.debug('ContactList==='+conList);
        ApexPages.currentPage().getParameters().put('id', con.id);
        ApexPages.currentPage().getParameters().put('un', con.id);
        
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();

        empReim.Contact_Id__c = con.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 1234;
        empReim.MPG__c = 4567;
        empReim.Month__c =  ilmr.getLastMonthValue(-1);
        empReim.Approved_Date__c = null;

        insert empReim;
        System.debug('reimbursement==='+empReim);
        Employee_Mileage__c empMile  = new Employee_Mileage__c();

        empMile.Name = 'Test';
        empMile.EmployeeReimbursement__c = empReim.id;
        empMile.Contact_Email_Id__c = 'test@gmail.com';
        empMile.Mileage__c = 12;
        empMile.Approved_Date__c = null;
        empMile.Trip_Status__c = StaticValues.noApprovedYet;
        empMile.Rejected__c = false;

        insert empMile; 
        System.debug('mileage==='+empMile);
        RG_Charting charting = new RG_Charting();
        String month = RG_Charting.getMonthName('9-');
        month = RG_Charting.getMonthName('01');
        month = RG_Charting.getMonthName('02');
        month = RG_Charting.getMonthName('03');
        month = RG_Charting.getMonthName('04');
        month = RG_Charting.getMonthName('05');
        month = RG_Charting.getMonthName('06');
        month = RG_Charting.getMonthName('07');
        month = RG_Charting.getMonthName('08');
        month = RG_Charting.getMonthName('09');
        month = RG_Charting.getMonthName('10');
        month = RG_Charting.getMonthName('11');
        month = RG_Charting.getMonthName('12');
    }
    /* public static testmethod void Testmethod2() {

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account account = TestUtilityClass.getTestSingleAccount();
        Contact con = new Contact();

        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = account.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'test@gmail.com';
        con.Deactivated_Date__c = null;
        con.isCommunityUser__c = true;
        con.Role__c = 'Admin';
        con.Monthly_Mileage_Limit__c = 1;
        insert con;
        ApexPages.currentPage().getParameters().put('id', con2.id);
        Employee_Reimbursement__c reimbursement = TestUtilityClass.getTestEmployeeReimbursement(con2);
        Employee_Mileage__c mileage = TestUtilityClass.getTestEmployeeMileage(reimbursement);
        RG_Charting charting = new RG_Charting();
    } */
    public static testmethod void Testmethod3() {

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account account = TestUtilityClass.getTestSingleAccount();
        Contact con = new Contact();

        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = account.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'test@gmail.com';
        con.Deactivated_Date__c = null;
        con.isCommunityUser__c = true;
        con.Role__c = 'Admin';
        con.Monthly_Mileage_Limit__c = 1;
        insert con;
        ApexPages.currentPage().getParameters().put('id', con.id);
        //ApexPages.currentPage().getParameters().put('un', con.id);
        Employee_Reimbursement__c reimbursement = TestUtilityClass.getTestEmployeeReimbursement(con);
        Employee_Mileage__c mileage = TestUtilityClass.getTestEmployeeMileage(reimbursement);
        RG_Charting charting = new RG_Charting();
    }
}