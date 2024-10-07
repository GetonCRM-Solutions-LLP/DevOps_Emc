@istest
public class BiWeeklyWrapperUtilsTest {

    @testSetup static void setupmethod() {
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.Mileage_Lockdate__c = false;        
        insert customSetting;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        IRS_Mileage_Rate__c objIRSRate = new IRS_Mileage_Rate__c();
        objIRSRate.year__c = String.valueOf(System.today().year());
        objIRSRate.IRS_Rate__c= 12.0;
        insert objIRSRate;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        
        Account acc = new Account();
       
        Contact con = new Contact();
        Contact con1 = new Contact();
        System.runAs(admin) {
            acc.Name = 'Test Account';
            //acc.Pay_Period_Start_Date__c = system.today();
            acc.Bi_Weekly_Pay_Period__c = true;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            acc.Triplog_API__c = 'khdkfhsld34khdlf4545';
            acc.Last_Reimbursement_Created__c = '12-2021';
            insert acc;
                
                List<Account> acclist = new List<Account>();
            acclist.add(acc);
           
            Contact contact_1 = new Contact(AccountId = acc.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com',Activation_Date__c = system.today());
            insert contact_1;
            
            con1.LastName = 'TestContact';
            con1.Role__c = 'Manager';
            con1.Activation_Date__c = system.today();
            con1.Car_Image__c = veh.URL__c;
            con1.Vehicle_Type__c = veh.Year__c +' '+veh.vehicle__c;
            con1.AccountId = acc.Id;
            con1.Activation_Date__c = system.today();
            //con1.Deactivated_Date__c = system.today().addDays(-2);
            con1.External_Email__c = 'test123@email.com';
            con1.Fixed_Amount__c = 371.28;
            con1.MailingCity = 'Abilene';
            con1.MailingState = 'TX';
            con1.Time_Zone__c = 'US/Mountain' ;
            con1.Driving_States__c = 'TX';
            con1.Fixed_Amount__c = 322.00;
            con1.Maintenance_and_Tires__c = 1.2;
            con1.MPG__c= 10.00;
            con1.Monthly_Mileage_Limit__c = 100.00;
            //con1.Deactivated_Date__c = null;
            //con1.Manager__c = contact_1.id;
            insert con1;
            
            List<Contact> conlist = new List<Contact>();
            conlist.add(con1);
            
            con.LastName = 'TestContact';
            con.Role__c = 'Driver';
            con.Car_Image__c = veh.URL__c;
            con.Vehicle_Type__c = veh.Year__c +' '+veh.vehicle__c;
            con.AccountId = acc.Id;
            con.Activation_Date__c = system.today();
            //con.Deactivated_Date__c = system.today().addDays(-2);
            con.External_Email__c = 'test@email.com';
            con.Fixed_Amount__c = 371.28;
            con.MailingCity = 'Abilene';
            con.MailingState = 'TX';
            con.Time_Zone__c = 'US/Mountain' ;
            con.Driving_States__c = 'TX';
            con.Fixed_Amount__c = 322.00;
            con.Maintenance_and_Tires__c = 1.2;
            con.MPG__c= 10.00;
            con.Monthly_Mileage_Limit__c = 100.00;
            con.Deactivated_Date__c = null;
            con.Manager__c = con1.id;
            insert con;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }   

        Decimal days = acc.Pay_Period_Days__c;
        List<String> dateRange = new List<String>();
        String startDate = string.valueof(acc.Pay_Period_Start_Date__c);
        string[] splitsdate = startDate.split('-');
        string splitStartDate = splitsdate[1]+'/'+splitsdate[2]+'/'+splitsdate[0];
        String enddate = String.valueof(date.valueof(startDate).addDays(Integer.valueof(days)));
        string[] splitdate = enddate.split('-');
        string splitEndDate = splitdate[1]+'/'+splitdate[2]+'/'+splitdate[0];
        if(date.valueof(enddate) < date.today()){
            dateRange.add(splitStartDate+' to '+ splitEndDate);
        }        
        
        Bi_Weekly_Reimbursement__c biReim = new Bi_Weekly_Reimbursement__c();
        bireim.Approved_Date__c = system.today().addDays(-1);
        bireim.Status__c = 'Pending';
        bireim.Name = dateRange[0];
        bireim.Start_Date__c = Date.parse('10/03/2021');
        bireim.End_Date__c = Date.parse('10/16/2021');
        bireim.Contact__c = con.id;
        bireim.Mileage_Lock_Date__c = system.today();
        insert bireim;

        
        Bi_Weekly_Reimbursement__c biReim1 = new Bi_Weekly_Reimbursement__c();
        //biReim1.Approved_Date__c = system.today().addDays(-1);
        biReim1.Mileage_Lock_Date__c = System.today();
        biReim1.Approved_Date__c = null;
        biReim1.Status__c = 'Pending';
        biReim1.Name = dateRange[0];
        biReim1.Start_Date__c = Date.parse('10/03/2021');
        biReim1.End_Date__c = Date.parse('10/16/2021');
        biReim1.Contact__c = con1.id;
        insert biReim1;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Name = '11/21/2021 to 12/04/2021';
        er.Month__c = '03-2021';
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00; 
        er.Fixed_Amount__c = con.Fixed_Amount__c;
        er.Status__c = 'Pending';
        er.Maintenance_and_Tires__c = con.Maintenance_and_Tires__c;
        er.MPG__c = con.MPG__c;
        insert er;

        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = con1.Id;
        er1.Name = '11/21/2021 to 12/04/2021';
        er1.Month__c = '03-2021';
        er1.Status__c = 'Pending';
        er1.Fuel_Price__c = 10.00; 
        er1.Fixed_Amount__c = con1.Fixed_Amount__c;
        er1.Status__c = 'Pending';
        er1.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
        er1.MPG__c = con.MPG__c;
        insert er1;
                
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = date.today().adddays(-1);
        emp.Approved_Date__c = null;
        emp.Maintenance_and_Tires__c = 1.2;
        emp.Origin_Name__c = 'test';
        emp.Notes__c = 'test';
        emp.Tag__c = 'test';        
        emp.Destination_Name__c = 'test';        
 //       emp1.Mileage_Lock_Date__c = system.today();
        insert emp;
        
        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.Bi_Weekly_Reimbursement__c = bireim1.Id;
        emp1.EmployeeReimbursement__c = er1.id;
        emp1.Contact_Email_Id__c = con1.External_Email__c;
        emp1.Name = 'Test Mileage Record';
        emp1.Trip_Status__c = StaticValues.noApprovedYet;
        emp1.Mileage__c = 50.00;
        emp1.Fuel_price__c = 10.00;
        emp1.TimeZone__c = 'US/Mountain' ;
        emp1.StartTime__c = system.now().addDays(-2);
        emp1.EndTime__c =  system.now();
        emp1.Trip_Date__c = date.today().adddays(-1);
        emp1.Approved_Date__c = null;
        emp1.Maintenance_and_Tires__c = 1.2;
        emp1.Origin_Name__c = 'test';
        emp1.Notes__c = 'test';
        emp1.Tag__c = 'test';        
        emp1.Destination_Name__c = 'test';        
        emp1.Mileage_Lock_Date__c = system.today();
        insert emp1;
        
        con1.Deactivated_Date__c = system.today().addDays(-2);
        update con1;
        
    }

    @istest 
    public static void testMethod1() {
    
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        List<Account> acc = [select id from Account limit 1];
        List<Contact> con = [select id from Contact where accountId =: acc[0].Id limit 1];
        List<Bi_Weekly_Reimbursement__c> bireim = [select id,Name,Month__c,Total_Rejected__c,Approved_Date__c,Contact__r.AccountId,Contact__r.Manager__r.Name,
                                                    Contact__c,Contact__r.name,Contact__r.Monthly_Mileage_Limit__c,Total_Approved__c,Total_Mileage__c,Status__c,
                                                    Reimbursement_Approval__c  from Bi_Weekly_Reimbursement__c where Contact__c =: con[0].id limit 1];
        List<Employee_Reimbursement__c> er = [select id from Employee_Reimbursement__c where Contact_Id__c =: con[0].id limit 1];
        List<Employee_Mileage__c> emp = [select id,Name,Trip_Status__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Bi_Weekly_Reimbursement__c,
                                            Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,TimeZone__c,Tag__c,
                                            Bi_Weekly_Reimbursement__r.month__c,Bi_Weekly_Reimbursement__r.Total_Pending__c,Stay_Time__c,
                                            Bi_Weekly_Reimbursement__r.Total_Mileage__c,Bi_Weekly_Reimbursement__r.Contact__c,Driving_Time__c,Total_Time__c,
                                            CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Mileage_Lock_Date__c,
                                            Day_Of_Week__c,Destination_Name__c,Bi_Weekly_Reimbursement__r.Contact__r.External_Email__c,
                                            Maintenance_and_Tires__c,Fuel_price__c,Bi_Weekly_Reimbursement__r.Total_Variable_Rate__c,ConvertedStartTime__c,ConvertedEndTime__c, 
                                            Bi_Weekly_Reimbursement__r.Total_Rejected__c,Notes__c,Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c,Activity__c 
                                        from Employee_Mileage__c ];

        String reimbursement = BiWeeklyWrapperUtils.getUnapprovedReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id), true,'Admin');
        String reimbursement1 = BiWeeklyWrapperUtils.getUnapprovedReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id), false,'Admin');
        BiWeeklyWrapperUtils.getUnapprovedReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id), true,'Manager');
        BiWeeklyWrapperUtils.getUnapprovedReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id), false,'Manager');
        BiWeeklyWrapperUtils.getLastMonthReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id),false,'Driver/Admin');
      //  BiWeeklyWrapperUtils.getLastMonthReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id),true,'Manager');
        BiWeeklyWrapperUtils.sendInsuranceEmail (string.valueOf(con[0].Id),'TestContact','test123@email.com');
        
    }

    @istest 
    public static void testMethod2() {
    
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        List<Account> acc = [select id from Account limit 1];
        List<Contact> con = [select id from Contact where accountId =: acc[0].Id and Deactivated_Date__c != null limit 1];
        List<Bi_Weekly_Reimbursement__c> bireim = [select id,Name,Month__c,Total_Approved_Pending_Mileage__c,Total_Rejected__c,Approved_Date__c,Contact__r.AccountId,Contact__r.Manager__r.Name,
                                                    Contact__c,Contact__r.name,Contact__r.Monthly_Mileage_Limit__c,Total_Approved__c,Total_Mileage__c,Status__c,
                                                    Reimbursement_Approval__c,Mileage_Lock_Date__c  from Bi_Weekly_Reimbursement__c where Contact__c =: con[0].id limit 1];
        List<Employee_Reimbursement__c> er = [select id from Employee_Reimbursement__c where Contact_Id__c =: con[0].id limit 1];
        List<Employee_Mileage__c> emp = [select id,Name,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Status__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Bi_Weekly_Reimbursement__c,
                                            Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,TimeZone__c,Tag__c,
                                            Bi_Weekly_Reimbursement__r.month__c,Bi_Weekly_Reimbursement__r.Total_Pending__c,Stay_Time__c,
                                            Bi_Weekly_Reimbursement__r.Total_Mileage__c,Bi_Weekly_Reimbursement__r.Contact__c,Driving_Time__c,Total_Time__c,
                                            CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Mileage_Lock_Date__c,
                                            Day_Of_Week__c,Destination_Name__c,Bi_Weekly_Reimbursement__r.Contact__r.External_Email__c,Bi_Weekly_Reimbursement__r.Half_Fixed_Amount__c,
                                            Maintenance_and_Tires__c,Fuel_price__c,Bi_Weekly_Reimbursement__r.Total_Variable_Rate__c,ConvertedStartTime__c,ConvertedEndTime__c, 
                                            Bi_Weekly_Reimbursement__r.Total_Rejected__c,Notes__c,Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c,Activity__c,High_Risk_Mileage__c,EmployeeReimbursement__r.Contact_Id__r.Account.Bi_Weekly_Pay_Period__c 
                                        from Employee_Mileage__c where EmployeeReimbursement__c =: er[0].Id ];

        BiWeeklyWrapperUtils.getLastMonthReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id),true,'');
        String reimbursement = BiWeeklyWrapperUtils.getUnapprovedReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id), true,'Admin');
        BiWeeklyWrapperUtils.getPayPeriodDates(string.valueOf(acc[0].Id));
        BiWeeklyWrapperUtils.checkBiweekAccount(string.valueOf(acc[0].Id));
        BiWeeklyWrapperUtils.getLastMonthReimbursements(string.valueOf(con[0].Id), string.valueOf(acc[0].Id),true,'Driver/Admin');
        BiWeeklyWrapperUtils.getEmployeeReimbursementDetails(bireim[0]);
        BiWeeklyWrapperUtils.getMileagesOfReimbursement(emp[0]);
        emp[0].Approved_Date__c = date.today().adddays(-1);
        update emp;
        BiWeeklyWrapperUtils.getMileagesOfReimbursement(emp[0]);
        BiWeeklyWrapperUtils.getBiweekReimId(con[0].Id, system.today(),True);
        // BiWeeklyWrapperUtils.getUnapprovedMileages(string.valueOf(obj))
        // public static Map<String, Id> getBiweeklyReimMap (String contactId,Date minTripdate, Date maxTripDate, Boolean checkBiweekAcc)
        BiWeeklyWrapperUtils.getBiweeklyReimMap(string.valueOf(con[0].Id),system.today().addDays(-1),system.today(),true);
        BiWeeklyWrapperUtils.getBiweeklyReimMap(string.valueOf(con[0].Id),system.today().addDays(-1),system.today(),false);
    }
        
}