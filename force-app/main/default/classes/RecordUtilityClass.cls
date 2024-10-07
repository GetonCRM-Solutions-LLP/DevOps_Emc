public with sharing class RecordUtilityClass 
{
   
    public RecordUtilityClass() 
    {
        
    }
    public static List<IRS_Mileage_Rate__c> insertIrsRate()
    {
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate = new List<IRS_Mileage_Rate__c>();
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_1 = new IRS_Mileage_Rate__c();
        obj_IRS_Mileage_Rate_1.year__c= String.valueof(System.today().year());
        obj_IRS_Mileage_Rate_1.IRS_Rate__c =0.578;
        obj_IRS_Mileage_Rate.add(obj_IRS_Mileage_Rate_1);

        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_2 = new IRS_Mileage_Rate__c();
        obj_IRS_Mileage_Rate_2.year__c='2019';
        obj_IRS_Mileage_Rate_2.IRS_Rate__c =0.567;
        obj_IRS_Mileage_Rate.add(obj_IRS_Mileage_Rate_2);
        
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_3 = new IRS_Mileage_Rate__c();
        obj_IRS_Mileage_Rate_3.year__c='2020';
        obj_IRS_Mileage_Rate_3.IRS_Rate__c =0.567;
        obj_IRS_Mileage_Rate.add(obj_IRS_Mileage_Rate_3);
        insert obj_IRS_Mileage_Rate;
        return obj_IRS_Mileage_Rate;
    }
    public static void exceptionEmail()
    {
        
        List<EmailExceptionMessages__c> exceptionList = new List<EmailExceptionMessages__c>();
        EmailExceptionMessages__c customSetting1 =  new EmailExceptionMessages__c();
        customSetting1.Name = '1';
        customSetting1.ExceptionType__c= 'TypeException';
        customSetting1.ExeptionMessage__c= 'Invalid decimal: .';
        customSetting1.Message__c= 'Invalid decimal';
        exceptionList.add(customSetting1);

        EmailExceptionMessages__c customSetting2 =  new EmailExceptionMessages__c();
        customSetting2.Name = '2';
        customSetting2.ExceptionType__c= 'TypeException';
        customSetting2.ExeptionMessage__c= 'Invalid decimal: .';
        customSetting2.Message__c= 'Invalid decimal';
        exceptionList.add(customSetting2);

        EmailExceptionMessages__c customSetting3 =  new EmailExceptionMessages__c();
        customSetting3.Name = '3';
        customSetting3.ExceptionType__c= 'TypeException';
        customSetting3.ExeptionMessage__c= 'Invalid decimal: .';
        customSetting3.Message__c= 'Invalid decimal';
        exceptionList.add(customSetting3);

        EmailExceptionMessages__c customSetting4 =  new EmailExceptionMessages__c();
        customSetting4.Name = '4';
        customSetting4.ExceptionType__c= 'TypeException';
        customSetting4.ExeptionMessage__c= 'Invalid decimal: .';
        customSetting4.Message__c= 'Invalid decimal';
        exceptionList.add(customSetting4);
        insert exceptionList;
    }
    public static void sendEmailforCompliance()
    {
        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
    }
    public static void enableMappingGasPriceTrigger()
    {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
    }
    public static void vehicleUrlMapping() 
    {   
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093359.jpg';
        veh.vehicle__c =  'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
    }
    public static void generalPendingRecords()
    {
        sendEmailforCompliance();
        enableMappingGasPriceTrigger();
        vehicleUrlMapping();
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
		List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate = insertIrsRate();
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;

        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',Pay_Period_Start_Date__c = System.today().addDays(-130),Pay_Period_Days__c = 13,Triplog_API__c = 'khdkfhsld34khdlf4545');
            insert account_1;
            
            /*Account account_1 = new Account( Name = 'Community');
            insert account_1;*/
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com',MobilePhone = '9087654323',Activation_Date__c=system.today());
            insert contact_1;

            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
    
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;       
    
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            insert obj_Manager_list;
    
            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            insert obj_Driver_list;
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
        Test.startTest();
        System.runAs(user_1) {
            list<Gas_Prices__c> gaslist = buildGasPrice();
            insert gaslist;
            
            System.debug('first===');
            list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = buildPendingEmployee_Reimbursement(obj_Driver_list);
            System.debug('second==='+obj_Employee_Reimbursement_list);
            insert obj_Employee_Reimbursement_list;
            System.debug('third==='+obj_Employee_Reimbursement_list);
            
            list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList1 = buildPendingBiReimbursement(obj_Driver_list);
            insert empBIweekReimbursementList1;
            
            List<Employee_Mileage__c> obj_Employee_Mileage_list = buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list,empBIweekReimbursementList1[0].Id);
            insert obj_Employee_Mileage_list;
        }
        Test.stopTest(); 
    }
    public static void createRecordsAdminManagerDriverDashboardCon()
    {
        generalPendingRecords();
    }
    public static void createRecordsAdminDashboardController()
    {
        generalPendingRecords();
    }
    public static void createRecordsforManagerDashboard()
    {
        generalPendingRecords();
    }
    public static void createRecordsforDriverDashboardFromAdminManager()
    {
        generalPendingRecords();
    }
    public static void createRecordsforManagerDriverDashboardController()
    {
        generalPendingRecords();
    }
    public static Account getAccount()
    {
        return [Select id,name,Pay_Period_Start_Date__c, Pay_Period_Days__c,Triplog_API__c from Account limit 1];
    }
    public static Contact getAdminContact()
    {
        return [Select id,Name,Manager__c from Contact where Role__c='Admin' limit 1];
    }
    public static Contact getManagerContactbyid(String idofmanager)
    {
        return [Select id,Name,Manager__c from Contact where id=:idofmanager limit 1];
    }
    public static Contact getManagerContact()
    {
        return [Select id,Name,Manager__c,External_Email__c from Contact where Role__c='Manager' limit 1];
    }
    public static Contact getDriverManagerContact()
    {
        return [Select id,Name,Manager__c from Contact where Role__c='Driver/Manager' limit 1];
    }
    public static Contact getDriverContact()
    {
        return [Select id,Name,Manager__c,FirstName,LastName,Email,MailingAddress,MailingPostalCode,MailingCity,MailingState,Activation_Date__c,Employee_ID__c,Role__c,Manager__r.name,Vehicle_Type__c,Driving_States__c,Deactivated_Date__c,Last_Pay_Date__c,AccountId,Monthly_Mileage_Limit__c from Contact where Role__c='Driver' limit 1];
    
    }
    public static List<Contact> getManagersContactList()
    {
        return [Select id,Name,Manager__c from Contact where Role__c='Manager'];
    }
    
    public static List<Employee_Reimbursement__c> getEmployee_Reimbursement(String accid)
    {
        system.debug('getEmployee_Reimbursement==' + accid);
        return [select id,Name, Month__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,(select id,Name,Trip_Status__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c from Employees_Mileage__r where Trip_Status__c =: StaticValues.noApprovedYet and Approved_Date__c = null) from Employee_Reimbursement__c where Contact_Id__r.Accountid =: accid and (Contact_Id__r.Deactivated_Date__c = null OR Contact_Id__r.Deactivated_Date__c > TODAY) and Status__c = 'Pending' and Approved_Date__c = null];
    }
    public static List<Employee_Reimbursement__c> getDriverEmployee_Reimbursement(String drivercontactid)
    {
        return [select id,Name, Month__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,Fuel_Price__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Monthly_Variable_Amount__c from Employee_Reimbursement__c where Contact_Id__c =: drivercontactid and (Contact_Id__r.Deactivated_Date__c = null OR Contact_Id__r.Deactivated_Date__c > TODAY) and Status__c = 'Pending' and Approved_Date__c = null];
    }
    public static List<Employee_Reimbursement__c> getEmployee_Reimbursementandmileages(String drivercontactid)
    {
        return [select id,Name, Month__c,Fuel_Price__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Monthly_Variable_Amount__c,(select id,Name,Trip_Status__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c from Employees_Mileage__r where Trip_Status__c =: StaticValues.noApprovedYet and Approved_Date__c = null) from Employee_Reimbursement__c where Contact_Id__c =: drivercontactid and (Contact_Id__r.Deactivated_Date__c = null OR Contact_Id__r.Deactivated_Date__c > TODAY) and Status__c = 'Pending' and Approved_Date__c = null];
    } 
    public static list<Gas_Prices__c> buildGasPrice()
    {
        list<Gas_Prices__c> gaslist = new  list<Gas_Prices__c>();
        Date dt =  date.newinstance(system.today().year(), system.today().month()-1, 1);

        for(integer i = 0; i < 1; i++) 
        {
            gaslist.add(new  Gas_Prices__c(City__c = 'ON', Fuel_Price__c = 65, State__c = 'CA', Month_Year__c= dt));
        }
        Date myDate = date.newinstance(system.today().year(), system.today().month()-2, 1);
        for(integer i = 0; i < 1; i++) 
        {
            gaslist.add(new  Gas_Prices__c(City__c = 'ON', Fuel_Price__c = 65, State__c = 'CA', Month_Year__c= myDate));
        }
        return gaslist;
    }
    public static List<Employee_Mileage__c> buildNoApprovedYetEmployeeMileages(List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list,Id biweekly)
    {
        
        List<Employee_Mileage__c> obj_Employee_Mileage_list = new List<Employee_Mileage__c>();
        for(Employee_Reimbursement__c obj:obj_Employee_Reimbursement_list)
        {
            for(Integer i=0;i<3;i++)
            {
                System.debug(obj.Contact_Id__r.External_Email__c);
                Employee_Mileage__c empMil = new Employee_Mileage__c();
                empMil.Name = 'DelToMumbai';
                empMil.Contact_Email_Id__c = 'test'+i+'@gmail.com';
                empMil.Trip_Date__c = Date.today().addDays(-15);
                empMil.Trip_Origin__c = 'Delhi';
                empMil.Trip_Destination__c = 'Mumbai';
                empMil.Mileage__c = 3000+i;
                empMil.EmployeeReimbursement__c = obj.Id;
                empMil.MPG__c = 12;
                empMil.Maintenance_and_Tires__c = 12;
                empMil.Trip_Status__c = StaticValues.noApprovedYet;
                empMil.Approved_Date__c = null;
                empMil.Origin_Name__c ='';
                empMil.Tracing_Style__c ='';
                empMil.StartTime__c =null;
                empMil.EndTime__c =null;
                empMil.Day_Of_Week__c ='';
                empMil.Destination_Name__c='';
                empMil.Activity__c = 'Business';
                empMil.StartTime__c = system.today().addDays(-15);
                empMil.EndTime__c = system.today().addDays(-15);
                empMil.Bi_Weekly_Reimbursement__c = biweekly;
                obj_Employee_Mileage_list.add(empMil);
            }
        }
        return obj_Employee_Mileage_list;
    }
    public static List<Employee_Reimbursement__c> buildPendingEmployee_Reimbursement(List<Contact> obj_Driver_list)
    {
        System.debug('seco');
        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = new list<Employee_Reimbursement__c>();
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate = new List<IRS_Mileage_Rate__c>();
        
        obj_IRS_Mileage_Rate = insertIrsRate();
        for(Contact obj_current_Contact:obj_Driver_list)
        {
            for(Integer i=1;i<=12;i++)
            {
                Employee_Reimbursement__c obj_Employee_Reimbursement = new Employee_Reimbursement__c();
                obj_Employee_Reimbursement.Name = obj_current_Contact.name+':'+getLastMonthValue(-i);               
                obj_Employee_Reimbursement.Month__c = getLastMonthValue(-i);               
                obj_Employee_Reimbursement.Contact_Id__c = obj_current_Contact.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending'; 
                obj_Employee_Reimbursement.IRS_Mileage_Rate__c =obj_IRS_Mileage_Rate[2].id;
                obj_Employee_Reimbursement.Fixed_Amount__c  = 121;
                obj_Employee_Reimbursement.Monthly_Fixed_Amount__c = 123;
                obj_Employee_Reimbursement.Approved_Date__c = Date.today();     
                obj_Employee_Reimbursement.Number_of_Pay_Period__c = i;
                obj_Employee_Reimbursement_list.add(obj_Employee_Reimbursement);
            }
        }
        System.debug('obj_Employee_Reimbursement_list: '+obj_Employee_Reimbursement_list);
        return obj_Employee_Reimbursement_list;
    }

    public static List<Bi_Weekly_Reimbursement__c> buildPendingBiReimbursement(List<Contact> obj_Driver_list)
    {
        
        list<Bi_Weekly_Reimbursement__c> obj_Employee_Reimbursement_list = new list<Bi_Weekly_Reimbursement__c>();
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate = new List<IRS_Mileage_Rate__c>();
        
        obj_IRS_Mileage_Rate = insertIrsRate();
        for(Contact obj_current_Contact:obj_Driver_list)
        {
            for(Integer i=1;i<=12;i++)
            {
                Bi_Weekly_Reimbursement__c obj_Employee_Reimbursement = new Bi_Weekly_Reimbursement__c();
                obj_Employee_Reimbursement.Name = obj_current_Contact.name+':'+getLastMonthValue(-i);               
                obj_Employee_Reimbursement.Month__c = getLastMonthValue(-i);               
                obj_Employee_Reimbursement.Contact__c = obj_current_Contact.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending'; 
                obj_Employee_Reimbursement.Fixed_Amount__c  = 121;
                obj_Employee_Reimbursement.Monthly_Fixed_Amount__c = 123;
                obj_Employee_Reimbursement.Approved_Date__c = Date.today();     
                obj_Employee_Reimbursement.Number_of_Pay_Period__c = i;
                obj_Employee_Reimbursement_list.add(obj_Employee_Reimbursement);
            }
        }
        return obj_Employee_Reimbursement_list;
    }
    public static Account buildAccount()
    {
        Account obj_Account = new Account();
        obj_Account.name='test Account';
        obj_Account.isUsingTriplog__c =  true;
        obj_Account.Triplog_API__c = 'Test';
        obj_Account.Pay_Period_Start_Date__c = system.today().adddays(-30);
        obj_Account.Pay_Period_Days__c = 13;
        obj_Account.Cell_Phone__c='Both';
        obj_Account.Reimbursement_Frequency__c='Both';
        obj_Account.Triplog_API__c = 'khdkfhsld34khdlf4545';
        if(System.Today().Month()<10)
        {
            obj_Account.Last_Reimbursement_Created__c = '0'+System.Today().Month()+'-'+System.Today().Year();
        }
        else
        {
            obj_Account.Last_Reimbursement_Created__c = System.Today().Month()+'-'+System.Today().Year();
        }
        return obj_Account;
    }
    public static List<Contact> buildDriverContact(Account newAccount,Contact managerContact)
    {
        // Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        // veh2.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        // veh2.vehicle__c = 'Full-Size Vehicle';
        // veh2.Year__c = '2018';
        // insert veh2;
        //vehicleUrlMapping();
        List<Contact> obj_Driver_list = new List<Contact>();
        for(Integer i=7;i<12;i++)
        {
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'ContactDri'+i;
            c.AccountId = newAccount.Id;
            c.MailingStreet = 'Test Street';
            c.MailingCity = 'Test City';
            c.MailingState = 'ON';
            c.Driving_States__c = 'NY';
            c.MailingPostalCode = '123';
            c.MailingCountry = 'CA';            
            c.External_Email__c = 'min01'+i+'@gmail.com';
            c.Deactivated_Date__c = null;
            c.IsCommunityUser__c = true;
            c.IsCreatedFromCommunity__c = true;
            c.compliancestatus__c ='Yes';
            c.Role__c = 'Driver';
            c.email='min01'+i+'@gmail.com';
            c.Monthly_Mileage_Limit__c = 210;
            c.MPG__c = 18;
            c.Fixed_Amount__c = 18;
            c.Maintenance_and_Tires__c = 12;
            c.Manager__c = managerContact.Id;
            c.Added_Date__c = System.today();
            c.Phone ='1213';
            c.Monthly__c =12;
            c.Sage_100_ID__c ='12';
            c.Activation_Date__c = System.today();
            c.GL_Code__c = 'sed';
            c.Territory__c = 'sed';
            c.Freeze__c = System.today();
            c.Vehicle_Type__c = '2019 Mileage Rate';
            c.Monthly_Reimbursement__c = true;
            c.Time_Zone__c = 'US/Arizona';
            c.App_Settings__c = 'iOS v1.1.11. Auto start:MagicTrip. Business hours: Business. After hours:Personal.';
            c.Cell_Phone__c='Employee Provide';
            c.Reimbursement_Frequency__c='Monthly Reimbursement';
            c.Activation_Date__c=system.today();
            obj_Driver_list.add(c);
        }
        return obj_Driver_list;
    }
    public static List<Contact> buildManagerContact(Account newAccount,Contact adminContact)
    {
        // Vehicle_URL_Mapping__c veh1 = new Vehicle_URL_Mapping__c();
        // veh1.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/Honda-Civic.png';
        // veh1.vehicle__c = 'Toyota Camry';
        // veh1.Year__c = '2017';
        // insert veh1;
        //vehicleUrlMapping();
        List<Contact> obj_Manager_list = new List<Contact>();
        for(Integer i=0;i<5;i++)
        {
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact Manager'+i;
            c.AccountId = newAccount.Id;
            c.MailingStreet = 'Test Street';
            c.MailingCity = 'Abbeville';
            c.MailingState = 'AL';
            c.MailingPostalCode = '30304';
            c.MailingCountry = 'USA';  
            c.External_Email__c = 'minkesh.pateldriver01'+i+'@gmail.com';
            c.Deactivated_Date__c = null;
            c.IsCommunityUser__c = true;
            c.Role__c = 'Manager';
            c.Vehicle_Type__c = '2021 Mileage Rate';
            c.email='minkesh.pateldriver01'+i+'@gmail.com';
            c.Monthly_Mileage_Limit__c = 210;
            c.Manager__c = adminContact.Id;
            c.Added_Date__c = System.today();
            c.Activation_Date__c = System.today();
            c.Monthly_Reimbursement__c = true;
            c.Company__C = 'Park';
            c.App_Settings__c = 'iOS v1.1.11. Auto start:MagicTrip. Business hours: Business. After hours:Personal.';
            c.Cell_Phone__c='Employee Provide';
            c.Reimbursement_Frequency__c='Monthly Reimbursement';
            c.Activation_Date__c=system.today();

            obj_Manager_list.add(c);
        }
        return obj_Manager_list;
    }
    public static List<Contact> buildDriverManagerContact(Account newAccount,Contact adminContact)
    {
         Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.Name = '2021 Test Ford';
         veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
         veh.vehicle__c = 'Test Ford';
         veh.Year__c = '2021';
         insert veh;

        List<Contact> obj_Manager_list = new List<Contact>();
        for(Integer i=12;i<18;i++)
        {
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact Driver Manager'+i;
            c.AccountId = newAccount.Id;
            c.MailingStreet = 'Test Street';
            c.MailingCity = 'Abbeville';
            c.MailingState = 'AL';
            c.MailingPostalCode = '30304';
            c.MailingCountry = 'USA';        
            c.External_Email__c = 'minkesh.pateldriver01'+i+'@gmail.com';
            c.Deactivated_Date__c = null;
            c.IsCommunityUser__c = true;
            c.Role__c = 'Driver/Manager';
            c.email='minkesh.pateldriver01'+i+'@gmail.com';
            c.Monthly_Mileage_Limit__c = 210;
            c.Manager__c = adminContact.Id;
            c.Vehicle_Type__c = '2021 Test Ford';
            c.App_Settings__c = 'iOS v1.1.11. Auto start:MagicTrip. Business hours: Business. After hours:Personal.';
            c.Cell_Phone__c='Employee Provide';
            c.Reimbursement_Frequency__c='Monthly Reimbursement';
            c.Activation_Date__c=system.today();

            obj_Manager_list.add(c);
        }
        return obj_Manager_list;
    }
    public static Contact buildAdminContact(Account newAccount)
    {
        // Vehicle_URL_Mapping__c veh3 = new Vehicle_URL_Mapping__c();
        // veh3.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        // veh3.vehicle__c = 'Full-Size Vehicle2';
        // veh3.Year__c = '2019';
        // insert veh3;
        //vehicleUrlMapping();
        Contact co = new Contact();
        co.FirstName = 'Test';
        co.LastName = 'Contact Admin';
        co.AccountId = newAccount.Id;
        co.MailingStreet = 'Test Street';
        co.MailingCity = 'Abbeville';
        co.MailingState = 'AL';
        co.MailingPostalCode = '30304';
        co.MailingCountry = 'USA';
        co.Phone = '1232434445';
        co.External_Email__c = 'minkesh.patelmanager01@gmail.com';
        co.Deactivated_Date__c = null;
        co.IsCommunityUser__c = true;  
        co.IsCreatedFromCommunity__c = true;      
        co.Role__c = 'Admin';
        co.Monthly_Mileage_Limit__c = 210;
        co.Monthly_Reimbursement__c = true;
        co.App_Settings__c = 'iOS v1.1.11. Auto start:MagicTrip. Business hours: Business. After hours:Personal.';
        co.Cell_Phone__c='Employee Provide';
        co.Reimbursement_Frequency__c='Monthly Reimbursement';
        co.Activation_Date__c=system.today();

        return co;       
    }
    public static EmployeeReimbursementDetailsAdmin getEmployeeReimbursementDetails(Employee_Reimbursement__c obj_current_Employee_Reimbursement)
    {   
        Double totalrejected =0;    
        EmployeeReimbursementDetailsAdmin obj_EmployeeReimbursements = new EmployeeReimbursementDetailsAdmin();
        obj_EmployeeReimbursements.id= obj_current_Employee_Reimbursement.id;
        obj_EmployeeReimbursements.contactid=obj_current_Employee_Reimbursement.Contact_Id__c;
        obj_EmployeeReimbursements.name = obj_current_Employee_Reimbursement.Contact_Id__r.Name;
        obj_EmployeeReimbursements.month = obj_current_Employee_Reimbursement.Month__c;
        obj_EmployeeReimbursements.threshold =String.valueOf( obj_current_Employee_Reimbursement.Contact_Id__r.Monthly_Mileage_Limit__c);
        obj_EmployeeReimbursements.totalMileages = String.valueOf(obj_current_Employee_Reimbursement.Total_Mileage__c);
        obj_EmployeeReimbursements.approvedMileages = String.valueOf(obj_current_Employee_Reimbursement.Total_Approved__c);
        obj_EmployeeReimbursements.status = obj_current_Employee_Reimbursement.Status__c;
        if(obj_current_Employee_Reimbursement.Approved_Date__c!=null)
        {
            // 2019-03-28
            if(String.valueOf(obj_current_Employee_Reimbursement.Approved_Date__c).contains('-'))
            {
                List<String> obj_list = new List<String>();
                obj_list = String.valueOf(obj_current_Employee_Reimbursement.Approved_Date__c).split('-');
                obj_EmployeeReimbursements.approvedDate = obj_list[1]+'/'+obj_list[2]+'/'+obj_list[0].substring(2,4);
            }
            
        }
        else
        {
            obj_EmployeeReimbursements.approvedDate = '';
        }
        for(Employee_Mileage__c obj:obj_current_Employee_Reimbursement.Employees_Mileage__r)
        {
            totalrejected  = totalrejected+ Double.valueOf(obj.Mileage__c);             
        }
        obj_EmployeeReimbursements.rejectedMileages = String.valueOf(totalrejected);
        obj_EmployeeReimbursements.isSelected = false;
        return obj_EmployeeReimbursements;
    }
    public static string getUnapprovedReimbursements(String contactId, String accountId,boolean showteam,String role) 
    {
       // its replacement of getAllDriversLastMonthUpdatedUnapprovedReimburseClone and getAllDriversLastMonthUnapprovedReimbursementsClone
       Map<String,EmployeeMileagesForCalculation> employeeReimbursementMap = new Map<String,EmployeeMileagesForCalculation>();
        
        List<Employee_Reimbursement__c> employeeReimbursementList = new List<Employee_Reimbursement__c>();
        if(showteam!=null && showteam == true && (role=='Admin' || role == StaticValues.roleAdminDriver))
        {
            employeeReimbursementList =[select id,Name, Month__c, Total_Rejected__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,Total_Pending__c from Employee_Reimbursement__c where Approved_Date__c = null and Contact_Id__r.Accountid =: accountId];
            //employeeReimbursementList =[select id,Name, Month__c, Total_Rejected__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,(select id,Name,Trip_Status__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Total_Pending__c,EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Variable_Rate__c from Employees_Mileage__r where Trip_Status__c =: StaticValues.noApprovedYet and Approved_Date__c = null) from Employee_Reimbursement__c where Approved_Date__c = null and Contact_Id__r.Accountid =: accountId];
        }
        else if(showteam!=null && showteam == false && (role=='Admin' || role == StaticValues.roleAdminDriver))
        {
            employeeReimbursementList =[select id,Name, Month__c, Total_Rejected__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,Total_Pending__c from Employee_Reimbursement__c where Approved_Date__c = null and Contact_Id__r.Accountid =: accountId and ((Contact_Id__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
           // employeeReimbursementList =[select id,Name, Month__c, Total_Rejected__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,(select id,Name,Trip_Status__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Total_Pending__c,EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Variable_Rate__c from Employees_Mileage__r where Trip_Status__c =: StaticValues.noApprovedYet and Approved_Date__c = null) from Employee_Reimbursement__c where Approved_Date__c = null and Contact_Id__r.Accountid =: accountId and ((Contact_Id__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
        }
        else if(showteam!=null && showteam == true && (role=='Manager' || role=='Driver/Manager'))
        {
            employeeReimbursementList =[select id,Name, Month__c, Total_Rejected__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,Total_Pending__c from Employee_Reimbursement__c where Approved_Date__c = null and Contact_Id__r.Accountid =: accountId and ((Contact_Id__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
            //employeeReimbursementList =[select id,Name, Month__c, Total_Rejected__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,(select id,Name,Trip_Status__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Total_Pending__c,EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Variable_Rate__c from Employees_Mileage__r where Trip_Status__c =: StaticValues.noApprovedYet and Approved_Date__c = null) from Employee_Reimbursement__c where Approved_Date__c = null and Contact_Id__r.Accountid =: accountId and ((Contact_Id__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
        }
        else if(showteam!=null && showteam == false && (role=='Manager' || role=='Driver/Manager'))
        {
            employeeReimbursementList =[select id,Name, Month__c, Total_Rejected__c, Approved_Date__c,Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c,Total_Pending__c from Employee_Reimbursement__c where Approved_Date__c = null and Contact_Id__r.Accountid =: accountId and (Contact_Id__r.Manager__c =:contactId)];
        }       
        for(Employee_Reimbursement__c currentReimbursement : employeeReimbursementList)
        {
            EmployeeMileagesForCalculation reimbursement = new EmployeeMileagesForCalculation();
            if(employeeReimbursementMap.containsKey(currentReimbursement.Contact_Id__c))
            {
                if(employeeReimbursementMap.get(currentReimbursement.Contact_Id__c).reimbursementIdList != null && employeeReimbursementMap.get(currentReimbursement.Contact_Id__c).reimbursementIdList.size() > 0)
                {                    
                    reimbursement = employeeReimbursementMap.get(currentReimbursement.Contact_Id__c);
                    reimbursement.totalMileages =(currentReimbursement.Total_Pending__c!=null) ? String.valueOf(double.valueOf((reimbursement.totalMileages!=null) ? reimbursement.totalMileages : '0')+double.valueOf(currentReimbursement.Total_Pending__c)):'0';                    
                    if(reimbursement.reimbursementIdList != null && reimbursement.reimbursementIdList.size() >0)
                    {                        
                       List<String> reimbursementIdList = new List<String>();
                       reimbursementIdList = reimbursement.reimbursementIdList;
                       reimbursementIdList.add(currentReimbursement.id);
                       reimbursement.reimbursementIdList = reimbursementIdList; 
                    }
                    employeeReimbursementMap.put(currentReimbursement.Contact_Id__c,reimbursement);
                }                
            }
            else
            {
                reimbursement.contactid = currentReimbursement.Contact_Id__c;
                reimbursement.reimbursementid = currentReimbursement.Id;
                reimbursement.name = currentReimbursement.Contact_Id__r.Name;
                reimbursement.month = currentReimbursement.Month__c;
                reimbursement.threshold = String.valueOf(currentReimbursement.Contact_Id__r.Monthly_Mileage_Limit__c);
                reimbursement.totalMileages = (currentReimbursement.Total_Pending__c!=null) ? String.valueOf(currentReimbursement.Total_Pending__c) : '0';
                reimbursement.approvedMileages = String.valueOf(currentReimbursement.Total_Approved__c);             
                reimbursement.isSelected = false;
                List<String> reimbursementIdList = new List<String>();
                reimbursementIdList.add(currentReimbursement.Id);
                reimbursement.reimbursementIdList = reimbursementIdList;
                employeeReimbursementMap.put(currentReimbursement.Contact_Id__c,reimbursement);                   
                                    
            }
            
        }   
        System.debug(employeeReimbursementMap); 
        return JSON.serialize((List<EmployeeMileagesForCalculation>)employeeReimbursementMap.values()).unescapeHtml4();
    }
    public static List<EmployeeReimbursements> getEmployeeReimbursements(List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list)
    {
        List<EmployeeReimbursements> obj_list1 = new List<EmployeeReimbursements>();
        for(Employee_Reimbursement__c obj_current_Employee_Reimbursement:obj_Employee_Reimbursement_list)
        {
            EmployeeReimbursements obj_EmployeeReimbursements = new EmployeeReimbursements();
            obj_EmployeeReimbursements.employeeReimbursementId = obj_current_Employee_Reimbursement.id;
            if(obj_current_Employee_Reimbursement.Approved_Date__c!=null)
            {
                if(String.valueOf(obj_current_Employee_Reimbursement.Approved_Date__c).contains('-'))
                {
                    List<String> obj_list = new List<String>();
                    obj_list = String.valueOf(obj_current_Employee_Reimbursement.Approved_Date__c).split('-');
                    obj_EmployeeReimbursements.approveddate  = obj_list[1]+'/'+obj_list[2]+'/'+obj_list[0].substring(2,4);
                }            
            }
            if(obj_current_Employee_Reimbursement.Status__c!=null)
            {
                obj_EmployeeReimbursements.status = obj_current_Employee_Reimbursement.Status__c; 
            }
            obj_EmployeeReimbursements.isSelected = false;       
            obj_EmployeeReimbursements.variableRate  = String.valueOf(obj_current_Employee_Reimbursement.Total_Variable_Rate__c);
            obj_EmployeeReimbursements.month  = getMonthName(obj_current_Employee_Reimbursement.Month__c);
            obj_EmployeeReimbursements.fuel  =String.valueOf(obj_current_Employee_Reimbursement.Fuel_Price__c);
            obj_EmployeeReimbursements.mileage  =String.valueOf(obj_current_Employee_Reimbursement.Total_Mileage__c);
            String fixedandvariable ='';
            if(obj_current_Employee_Reimbursement.Fixed_Amount__c!=null)
            {
                fixedandvariable = '$' + String.valueOf(obj_current_Employee_Reimbursement.Fixed_Amount__c)+' + ';
            }
            else
            {
                fixedandvariable = '$0 + ';
            }
            if(obj_current_Employee_Reimbursement.Monthly_Variable_Amount__c!=null)
            {
                fixedandvariable = fixedandvariable+ ' $' + String.valueOf(obj_current_Employee_Reimbursement.Monthly_Variable_Amount__c);
            }
            else
            {
                fixedandvariable  = fixedandvariable + '$0';
            }
            
            obj_EmployeeReimbursements.varibleAndFixedReimbursements  =fixedandvariable;
            obj_EmployeeReimbursements.totalReimbursements  =String.valueOf(obj_current_Employee_Reimbursement.Total_Monthly_Reimbursement__c);
            obj_list1.add(obj_EmployeeReimbursements);    
        }
        return obj_list1;
    }
    public static List<EmployeeReimbursementDetailsAdmin> getListofEmployeeReimbursementDetailsAdmin(List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list)
    {
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = new List<EmployeeReimbursementDetailsAdmin>();
        for(Employee_Reimbursement__c obj:obj_Employee_Reimbursement_list)
        {
            obj_EmployeeReimbursementDetailsAdmin_List.add(getEmployeeReimbursementDetails(obj));
        }

        return obj_EmployeeReimbursementDetailsAdmin_List;
    }
    public static List<Employee_Mileage__c> getMileagesList()
    {
        return [SELECT id,Name,Trip_Date__c,ConvertedEndTime__c,EmployeeReimbursement__r.Mileage_Lock_Date__c,
                    Trip_Origin__c,Fuel_price__c,EmployeeReimbursement__r.Total_Variable_Rate__c,
                    Maintenance_and_Tires__c,Origin_Name__c,Tracing_Style__c,StartTime__c,Approval_Name__c,
                    EndTime__c,Day_Of_Week__c,Destination_Name__c,Trip_Destination__c,Mileage__c,
                    Variable__c,Trip_Status__c,Approved_Date__c,EmployeeReimbursement__c,Variable_Rate__c,
                    EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,
                    EmployeeReimbursement__r.Total_Pending__c,EmployeeReimbursement__r.Monthly_Variable_Amount__c,
                    EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Total_Rejected__c,
                    EmployeeReimbursement__r.Total_Mileage__c,Notes__c,ConvertedStartTime__c,Stay_Time__c,Original_Destination_Name__c,
                    Driving_Time__c,Total_Time__c,Tag__c,Activity__c,Mileage_Lock_Date__c,Fuel_Variable_Rate__c,Original_Origin_Name__c,High_Risk_Mileage__c 
                FROM Employee_Mileage__c];
    } 
    public static List<EmployeeMileages> getallEmployeeMileages(List<Employee_Mileage__c> obj_list_Employee_Mileage)
    {
        List<EmployeeMileages> obj_list_EmployeeMileages = new List<EmployeeMileages>();
        for(Employee_Mileage__c obj:obj_list_Employee_Mileage)
        {
            obj_list_EmployeeMileages.add(getMileagesOfReimbursement(obj));
        }
        return obj_list_EmployeeMileages;
    }
    public static EmployeeMileages getMileagesOfReimbursement(Employee_Mileage__c obj_Employee_Mileage)
    {
        EmployeeMileages obj_current_Employee_Mileage = new EmployeeMileages();
        obj_current_Employee_Mileage.id=obj_Employee_Mileage.id;
        obj_current_Employee_Mileage.isSelected = false;
        obj_current_Employee_Mileage.isChecked = false;
        if(obj_Employee_Mileage.Trip_Status__c!=null)
        {
            obj_current_Employee_Mileage.status = obj_Employee_Mileage.Trip_Status__c;    
        } 
        if(obj_Employee_Mileage.Trip_Status__c!=null && obj_Employee_Mileage.Trip_Status__c=='Rejected')
        {
             obj_current_Employee_Mileage.isChecked = true;
        }        
        obj_current_Employee_Mileage.origin = obj_Employee_Mileage.Trip_Origin__c;
        obj_current_Employee_Mileage.destination = obj_Employee_Mileage.Trip_Destination__c;
        if(obj_Employee_Mileage.Trip_Date__c!=null)
        {
           
           if(String.valueOf(obj_Employee_Mileage.Trip_Date__c).contains('-'))
           {
                List<String> obj_list = new List<String>();
                obj_list = String.valueOf(obj_Employee_Mileage.Trip_Date__c).split('-');
                obj_current_Employee_Mileage.tripdate  = obj_list[1]+'/'+obj_list[2]+'/'+obj_list[0].substring(2,4);
           }
        }
         
        obj_current_Employee_Mileage.mileage  = String.valueOf(obj_Employee_Mileage.Mileage__c);

        if(obj_Employee_Mileage.Approved_Date__c!=null)
        {
            System.debug('obj_Employee_Mileage.Approved_Date__c:-- '+obj_Employee_Mileage.Approved_Date__c);
           if(String.valueOf(obj_Employee_Mileage.Approved_Date__c).contains('-'))
           {
                List<String> obj_list = new List<String>();
                obj_list = String.valueOf(obj_Employee_Mileage.Approved_Date__c).split('-');
                obj_current_Employee_Mileage.approveddate  = obj_list[1]+'/'+obj_list[2]+'/'+obj_list[0].substring(2,4);
           }
        }
        Date createddate = Date.valueOf(obj_Employee_Mileage.CreatedDate);
        System.debug('createddate:- '+String.valueOf(createddate));
        if(!Test.isRunningTest()) {
            if(String.valueOf(createddate).contains('-'))
            {
                List<String> obj_List = new List<String>();
                obj_List = String.valueOf(createddate).split('-');
                /*List<String> obj_dates = new List<String>();
                obj_dates = obj_List[0].split('-');*/
                obj_current_Employee_Mileage.submitteddate =  obj_List[1]+'/'+obj_List[2]+'/'+obj_List[0].substring(2,4);
            }
        }
        
        obj_current_Employee_Mileage.totalpending = String.valueOf(obj_Employee_Mileage.EmployeeReimbursement__r.Total_Pending__c);
        obj_current_Employee_Mileage.variableamount  = String.valueOf(obj_Employee_Mileage.Variable__c);
        obj_current_Employee_Mileage.month  = obj_Employee_Mileage.EmployeeReimbursement__r.month__c;
        obj_current_Employee_Mileage.reimbursementid  = obj_Employee_Mileage.EmployeeReimbursement__c;
        obj_current_Employee_Mileage.driverid = obj_Employee_Mileage.EmployeeReimbursement__r.Contact_Id__c;

        return obj_current_Employee_Mileage;
    }
    public static String getLastMonthValue(Integer value) {
        String tempDate = date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }
        System.debug('lastMonth:-'+lastMonth);
        return lastMonth;
    }
    public static String getMonthName(String monthname)
    {
        Map<Integer,String> monthNameMap=new Map<Integer, String>{01 =>'January', 02=>'February', 03=>'March', 04=>'April', 05=>'May',
                                                                    06=>'June', 07=>'July', 08=>'August', 09=>'September',10=>'October',
                                                                    11=>'November', 12=>'December'};
        if(monthname.contains('-'))
        {
           return monthNameMap.get(Integer.valueOf((monthname.split('-')[0]))); 
        }
        return '';
    }
  
}