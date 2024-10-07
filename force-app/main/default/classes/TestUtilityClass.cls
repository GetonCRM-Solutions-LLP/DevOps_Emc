public class TestUtilityClass{
    
    public static Account getTestSingleAccount(){

       
        Account acc = new Account();
        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'a';
        acc.Enable_Email_For_Managers__c = True;
        
        insert acc;
        return acc;
    }
     public static Account getTestSingleAccount2(){
        Account acc = new Account();
        
        acc.Name = 'Excelligence Learning Corporation';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'abc123';
        acc.Enable_Email_For_Managers__c = True;
        
        insert acc;
        return acc;
     }   
      public static Contact getTestSingleContact(Account acc) {
      
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
        con.External_Email__c = 'minkesh.patel14232378@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c = 0;
        
        insert con;
        return con;
    }
     public static Contact getTestSingleContact2(Account acc) {
        
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
        con.External_Email__c = 'test@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.Monthly_Mileage_Limit__c=1;
        insert con;
        return con;
    }
     public static Contact getTestSingleContact3(Account acc) {
       
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
        con.External_Email__c = 'minkesh.patel14534er478@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Manager';
        con.Monthly_Mileage_Limit__c=1;
        insert con;
        return con;
     }
     public static Contact getTestSingleContact4(Account acc,Contact c) {
        
        // Vehicle_URL_Mapping__c veh5 = new Vehicle_URL_Mapping__c();
        // veh5.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093359.jpg';
        // veh5.vehicle__c =  'Full-Size Sedan';
        // veh5.Year__c = '2019';
        // insert veh5;
        
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
        con.External_Email__c = 'test45@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';
        con.Manager__c = c.id;
        con.Monthly_Mileage_Limit__c=1;
        insert con;
        return con;
    }
      public static List<Account> getTestMultipleAccount(){
        List<Account> accList = new List<Account>();
        
        for(integer i=0;i<=10;i++){
            account acc = new account();
            
            acc.Name = 'Test'+i+'Account';
            acc.BillingStreet = 'Test Street';
            acc.BillingCity = 'Test City';
            acc.BillingState = 'ON';
            acc.BillingPostalCode = '123';
            acc.BillingCountry = 'CA';
            acc.Type='Analyst';
            accList.add(acc);
        }
        insert accList;
        return accList;
    }
    public static List<Contact> getTestMultipleContact(Account acc){
       
        List<Contact> conList = new List<Contact>();
        
        for(integer i=0;i<=10;i++){
            Contact con = new Contact();
            
            con.FirstName = 'Test';
            con.LastName =  'Contact '+ i;
            con.AccountId = acc.Id;
            con.MailingStreet = 'Test Street';
            con.MailingCity = 'Test City';
            con.MailingState = 'ON';
            con.MailingPostalCode = '123';
            con.MailingCountry = 'CA';
            con.Phone = '1232434445';
            con.Vehicle_Type__c = '2019 Full-Size Sedan';
            con.External_Email__c = 'Test'+ i + '@gmail.com';
            conList.add(con);
        }
        insert conList;
        return conList;
    }
    public static Batch_Configuration__c getTestBatchConfig(){
        Batch_Configuration__c csObj = new Batch_Configuration__c();
        
        csObj.Name = 'Test Config';
        csObj.Deactivate_Contacts_For_Account__c = True;
        csObj.Deactivate_Contacts_For_Contact__c = True;
        csObj.Demo_Batch__c= True;
        csObj.Emp_Mileage_Update_For_Emp_Mileage__c= True;
        csObj.Emp_reim_update_gasprice_for_Contact__c= True;
        csObj.Get_Trip_Batch_Class_for_Account__c = True;
        csObj.RG_Contact_Batch_Email_for_Emp_Mileage__c = True;
        csObj.Update_Reim_fuel_price_for_Account__c = True;
        
        insert csObj;
        return csObj;
    }
    public static Batch_Setup__c getTestBatchSetup(){
        Batch_Setup__c bsSet = new Batch_Setup__c();
        
        bsSet.Name = 'Test Batch';
        bsSet.AutoApprovedEmail__c = True;
        bsSet.BatchForApprovingReimburse__c = True;
        bsSet.GetTripBatch__c = True;
        bsSet.InsertLastMonthReimbursement__c = True;
        bsSet.UpdateLastToLastMonthMileagesBatch__c = True;
        
        insert bsSet;
        return bsSet;
    }
    public static Employee_Reimbursement__c getTestEmployeeReimbursement(Contact con){
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
        IRS_Mileage_Rate__c irsRate = new IRS_Mileage_Rate__c();
        irsRate.year__c = '2020';
        irsRate.IRS_Rate__c = 2.05;
        insert irsRate;

         RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
         
        empReim.Contact_Id__c = con.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 1234;
        empReim.MPG__c = 4567;
        empReim.Month__c =  ilmr.getLastMonthValue(-3);
        empReim.Maintenance_and_Tires__c =10;
        empReim.IRS_Mileage_Rate__c = irsRate.Id;
        insert empReim;
        return empReim;
    }
    public static Employee_Reimbursement__c getTestEmployeeReimbursement2(Contact con){
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
        IRS_Mileage_Rate__c irsRate = new IRS_Mileage_Rate__c();
        irsRate.year__c = '2020';
        irsRate.IRS_Rate__c = 2.05;
        insert irsRate; 

        Employee_Reimbursement__c empReimb = new Employee_Reimbursement__c();
        empReimb.Contact_Id__c = con.id;
        empReimb.Name = 'Test';
        empReimb.Fuel_Price__c = 134;
        empReimb.MPG__c = 47;
        empReimb.Fixed_Amount__c = 50;
        empReimb.Month__c = Utils.fetchMonths(1, 0)[0];
        empReimb.Monthly_Mileage__c = 50;
        empReim.IRS_Mileage_Rate__c = irsRate.Id;
        empReimb.Approved_Date__c = System.today() - 10;
        empReimb.Maintenance_and_Tires__c =10;
        empReimb.Status__c='Approved';
        
        insert empReimb;
        return empReimb;
    }
    public static Employee_Reimbursement__c getTestEmployeeReimbursement3(Contact con){
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
         RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        
        empReim.Contact_Id__c = con.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 12;
        empReim.MPG__c = 45;
        empReim.Month__c =  ilmr.getLastMonthValue(-1);
        empReim.Approved_Date__c = null;
        empReim.Monthly_Mileage__c = 50;
        empReim.Maintenance_and_Tires__c =10;
        insert empReim;
        return empReim;
    }

    public static Employee_Reimbursement__c getTestEmployeeReimbursement4(Contact con){
        Employee_Reimbursement__c empReimb = new Employee_Reimbursement__c();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        
        empReimb.Contact_Id__c = con.id;
        empReimb.Name = 'Test';
        empReimb.Fuel_Price__c = 12;
        empReimb.MPG__c = 45;
        empReimb.Month__c =  ilmr.getLastMonthValue(-4);
        empReimb.Monthly_Mileage__c = 50;
        empReimb.Maintenance_and_Tires__c =10;
        insert empReimb;
        return empReimb;
    }
    public static Employee_Reimbursement__c getTestEmployeeReimbursement5(Contact con){
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
         RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        
        empReim.Contact_Id__c = con.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 34;
        empReim.MPG__c = 45;
        empReim.Approved_Date__c = null;
        empReim.Status__c='Pending';
        empReim.Monthly_Mileage__c = 50;
        empReim.Maintenance_and_Tires__c =10;
        insert empReim;
        return empReim;
    }
    public static Employee_Mileage__c getTestEmployeeMileage(Employee_Reimbursement__c emp){
        Employee_Mileage__c empMile  = new Employee_Mileage__c();
        
        empMile.Name = 'Test';
        empMile.EmployeeReimbursement__c = emp.id;
        empMile.Contact_Email_Id__c = 'test@gmail.com';
        empMile.Mileage__c = 0;
        empMile.Approved_Date__c = Null;
        empMile.Trip_Status__c = StaticValues.noApprovedYet;
        empMile.Rejected__c = False;
        
        insert empMile;
        return empMile;
    }
    public static Employee_Mileage__c getTestEmployeeMileage2(Employee_Reimbursement__c emp){
        Employee_Mileage__c empMil  = new Employee_Mileage__c();
        
        empMil.Name = 'Test';
        empMil.EmployeeReimbursement__c = emp.id;
        empMil.Contact_Email_Id__c = 'test@gmail.com';
        empMil.Mileage__c = 1;
        empMil.Approved_Date__c = Null;
        empMil.Trip_Status__c = StaticValues.noApprovedYet;
        empMil.Rejected__c = False;
        
        insert empMil;
        return empMil;
    }
    public static Employee_Mileage__c getTestEmployeeMileage3(Employee_Reimbursement__c emp){
        Employee_Mileage__c empMil  = new Employee_Mileage__c();
        
        empMil.Name = 'Test';
        empMil.EmployeeReimbursement__c = emp.id;
        empMil.Contact_Email_Id__c = 'test@gmail.com';
        empMil.Mileage__c = 510;
        empMil.Approved_Date__c = System.today();
        empMil.Trip_Status__c = 'Approved';
        empMil.Rejected__c = False;
        
        insert empMil;
        return empMil;
    }
    public static Gas_Prices__c getTestGasPrices(){
        Gas_Prices__c gasPr = new Gas_Prices__c();
        
        gasPr.Fuel_Price__c = 123 ;
        gasPr.Month_Year__c = date.newInstance(2019,04,01);
        gasPr.State__c = 'Ts';
        
        insert gasPr;
        return gasPr;
    }
    public static List<Employee_Reimbursement__c> getTestMultipleEmployeeReimbursement(Contact con){
        List<Employee_Reimbursement__c> empList = new List<Employee_Reimbursement__c>();
        
        for(Integer i=0;i<=10;i++){
            Employee_Reimbursement__c empRe = new Employee_Reimbursement__c();
            empRe.Contact_Id__c = con.id;
            empRe.Name = 'Test '+ i;
            empRe.Fuel_Price__c = 1234;
            empRe.MPG__c = 4567;
            empList.add(empRe);
        }
        insert empList;
        return empList;
    }
}