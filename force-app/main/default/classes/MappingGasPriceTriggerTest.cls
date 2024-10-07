@isTest
public Class MappingGasPriceTriggerTest{
	
    public static testmethod void test1(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.Mileage_Lockdate__c = true;
        customSetting.MappingMileage__c = true;
        customSetting.MapTriAppReje__c = true;
        customSetting.TrackHistory__c = true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        daylight_saving_time_config__c customSetting2 =  new daylight_saving_time_config__c();
        customSetting2.Name = '2021';
        customSetting2.Start_Date__c = System.today();
        customSetting2.End_Date__c = System.today() + 60;
        insert customSetting2;
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account acc; 
        Contact con;
        Contact con1;
       
        System.runAs(admin) {
			acc = new Account();
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
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            acc.Timezone__c = 'US/Eastern';
            insert acc;
            Contact contact_1 = new Contact(AccountId = acc.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com', Activation_Date__c = system.today());
            insert contact_1;

            con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.Id;
            con.Fixed_Amount__c = 10;
            con.MailingStreet = 'Test Street';
            con.MailingCity = 'Test City';
            con.MailingState = 'AL';
            con.Triplog_UserID__c = '23rcdssf';
            con.MailingPostalCode = '36310';
            con.MailingCountry = 'CA';
            con.Phone = '1232434445';
            con.External_Email__c = 'minkesh.patel14232378@gmail.com';
            //con.Deactivated_Date__c = system.today();
            con.isCommunityUser__c = True;
            con.Role__c = 'Driver';
            con.Monthly_Mileage_Limit__c = 0;
            con.IsCreatedFromCommunity__c = true; 
            con.Vehicle_Type__c  = '2019 Mileage Rate';
            con.compliancestatus__c = 'Yes';
            con.Time_Zone__c = 'US/Eastern';
            con.Biweek_Reimbursement__c = true;
            con.Map_Country__c = 'CANADA';
            con.Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement';
             con.Activation_Date__c = system.today();
            insert con;
            
          /*  con1 = new Contact();
            con1.FirstName = 'Test';
            con1.LastName = 'Contact';
            con1.AccountId = acc.Id;
            con1.Fixed_Amount__c = 10;
            con1.MailingState = 'AL';
            con1.Triplog_UserID__c = '23rcdssf';
            con1.MailingPostalCode = '36310';
            con1.MailingCountry = 'CA';
            con1.Phone = '1232434445';
            con1.External_Email__c = 'minkesh.patel14232@gmail.com';
            con1.isCommunityUser__c = True;
            con1.Role__c = 'Driver';
            con1.Monthly_Mileage_Limit__c = 0;
            con1.IsCreatedFromCommunity__c = true; 
            con1.Vehicle_Type__c  = '2019 Mileage Rate';
            con1.compliancestatus__c = 'Yes';
            con1.Time_Zone__c = 'US/Eastern';
            con1.Biweek_Reimbursement__c = true;
            con1.Map_Country__c = 'USA';
            insert con1;
			*/
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
        
        Gas_Prices__c gprice = new Gas_Prices__c();
        gprice.City__c = 'Test City';
        gprice.Fuel_Price__c = 65;
        gprice.State__c = 'AL';
        gprice.Month_Year__c = date.today().adddays(-1);
        DateTime dtLastMonth = System.today().adddays(-1);
        String dayval = String.valueOf(dtLastMonth.format('d'));
        String yearval = String.valueOf(dtLastMonth.format('yyyy'));
        gprice.Month_State_City__c = gprice.City__c+''+gprice.State__c+''+dayval+''+yearval;
        insert gprice;
        
        Employee_Reimbursement__c er5 = new Employee_Reimbursement__c();
        er5.Contact_Id__c = con.Id;
        er5.Name = 'Reimbersment Test';
        er5.Month__c = '10-2017';
        er5.Status__c = 'Pending';
        er5.Fuel_Price__c = 10.00;
        insert er5;
        
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
        bireim.Contact__c = con.Id;
        bireim.Status__c = 'Approved';
        bireim.Name = dateRange[0];
        bireim.Start_Date__c = Date.parse('10/03/2021');
        bireim.End_Date__c = Date.parse('10/16/2021');
        bireim.Contact__c = con.id;
        //bireim.Mileage_Lock_Date__c = system.today().adddays(-1);
        bireim.Mileage_Lock_Date__c = system.today();
        insert bireim;

        list<Employee_Mileage__c> emplist =new list<Employee_Mileage__c>();
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.EmployeeReimbursement__c = er5.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'EMP-Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = date.today().adddays(-1);
        emp.Bi_Weekly_Reimbursement__c = bireim.Id;
        // insert 
        emplist.add(emp);
        
        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = con.Id;
        er1.Name = 'Reimbersment Test';
        er1.Month__c = '08-2017';
        er1.Status__c = 'Pending';
        //er1.Mileage_Lock_Date__c = system.today();
        insert er1;
        
        er1.Mileage_Lock_Date__c = system.today();
        update er1;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Name = 'Reimbersment Test';
        er.Month__c = '09-2017';
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00;
        insert er;
        
        /* Employee_Reimbursement__c er10 = new Employee_Reimbursement__c();
        er10.Contact_Id__c = con1.Id;
        er10.Name = 'Reimbersment Test';
        er10.Month__c = '09-2023';
        er10.Status__c = 'Pending';
        er10.Fuel_Price__c = 10.00;
        insert er10;
        */
        set<String> milIdList = new set<String>();
        Map<Id, Employee_Mileage__c> milOldMap = new Map<Id, Employee_Mileage__c>();

        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.EmployeeReimbursement__c = er1.id;
        emp1.Contact_Email_Id__c = con.External_Email__c;
        emp1.Name = 'EMP-Test Mileage Record';
        emp1.Trip_Status__c = 'Approved';
        emp1.Approved_Date__c = system.today();
        emp1.Mileage__c = 10.00;
        emp1.TimeZone__c = 'US/Mountain' ;
        emp1.StartTime__c = system.now();
        emp1.EndTime__c =  system.now();
        emp1.Trip_Date__c =date.today().adddays(-1);
        emp1.Bi_Weekly_Reimbursement__c = bireim.Id;
        // insert emp1;
        emplist.add(emp1);
        milIdList.add(emp1.Id);
        milOldMap.put(emp1.Id,emp1);
        
        
        Employee_Mileage__c emp2 = new Employee_Mileage__c();
        emp2.EmployeeReimbursement__c = er1.id;
        emp2.Contact_Email_Id__c = con.External_Email__c;
        emp2.Name = 'EMP-Test Mileage Record';
        emp2.Trip_Status__c = 'Approved';
        emp2.Approved_Date__c = system.today();
        emp2.Mileage__c = 10.00;
        emp2.TimeZone__c = 'US/Mountain' ;
        emp2.StartTime__c = system.now();
        emp2.EndTime__c =  system.now();
        emp2.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp2.Trip_Date__c =date.today().adddays(-1);
        // insert emp2;
        emplist.add(emp2);
        milIdList.add(emp2.Id); 
        milOldMap.put(emp2.Id,emp2);

       
        
        Employee_Mileage__c emp3 = new Employee_Mileage__c();
        emp3.EmployeeReimbursement__c = er1.id;
        emp3.Contact_Email_Id__c = con.External_Email__c;
        emp3.Name = 'EMP-Test Mileage Record';
        emp3.Trip_Status__c = 'Rejected';
        emp3.Approved_Date__c = system.today();
        emp3.Mileage__c = 10.00;
        emp3.TimeZone__c = 'US/Mountain' ;
        emp3.StartTime__c = system.now();
        emp3.EndTime__c =  system.now();
        emp3.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp3.Trip_Date__c =date.today().adddays(-1);
        // insert emp3;
        emplist.add(emp3);
        milIdList.add(emp3.Id);
        milOldMap.put(emp3.Id,emp3);
       
        
        Employee_Mileage__c emp4 = new Employee_Mileage__c();
        emp4.EmployeeReimbursement__c = er1.id;
        emp4.Contact_Email_Id__c = con.External_Email__c;
        emp4.Name = 'Test Mileage Record';
        emp4.Trip_Status__c = 'Rejected';
        emp4.Approved_Date__c = system.today();
        emp4.Mileage__c = 10.00;
        emp4.TimeZone__c = 'US/Mountain' ;
        emp4.StartTime__c = system.now();
        emp4.EndTime__c =  system.now();
        emp4.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp4.Trip_Date__c =date.today().adddays(-1);
        emp4.Map_Country__c = 'CANADA';
        // insert emp4;
        emplist.add(emp4);
        milIdList.add(emp4.Id);
        milOldMap.put(emp4.Id,emp4);

        Employee_Mileage__c emp5 = new Employee_Mileage__c();
        emp5.EmployeeReimbursement__c = er1.id;
        emp5.Contact_Email_Id__c = con.External_Email__c;
        emp5.Name = 'EMP-Test Mileage Record5';
        emp5.Trip_Status__c = 'Not Approved Yet';
        emp5.Activity__c = 'Business';
        emp5.Approved_Date__c = null;
        emp5.Mileage__c = 10.00;
        emp5.TimeZone__c = 'US/Mountain' ;
        emp5.StartTime__c = system.now();
        emp5.EndTime__c =  system.now();
        emp5.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp5.Trip_Date__c =date.today().adddays(-1);
        emp5.Map_Country__c = 'CANADA';
        emp5.EMP_Mileage__c=10.00;
        // insert emp5;
        emplist.add(emp5);
        milOldMap.put(emp5.Id,emp5);
        insert emplist;

        milIdList.add(emp5.Id);
        emp1.Trip_Status__c = 'Rejected';
        update emp1;

        emp1.Trip_Status__c = 'Approved';
        update emp1;
        
        emp1.StartTime__c = emp1.StartTime__c.addSeconds(4);
        emp1.Trip_Status__c = 'Rejected';
        update emp1;

        emp2.Mileage__c = 10.00;
        update emp2;
        
        
        emp3.Trip_Status__c = 'Rejected';
        update emp3;

        emp3.Trip_Status__c = 'Approved';
       
        update emp3;

        emp5.Trip_Status__c='Approved';
        update emp5;

        emp5.EMP_Mileage__c=89.00;
        update emp5;
       /* Employee_Mileage__c emp6 = new Employee_Mileage__c();
        emp6.EmployeeReimbursement__c = er10.id;
        emp6.Contact_Email_Id__c = con.External_Email__c;
        emp6.Name = 'Test Mileage Record';
        emp6.Trip_Status__c = 'Not Approved Yet';
         emp6.Activity__c = 'Business';
        emp6.Approved_Date__c = null;
        emp6.Mileage__c = 10.00;
        emp6.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp6.Trip_Date__c =date.today().adddays(-1);
        emp6.Map_Country__c = 'USA';
        insert emp6;
        Map<ID, Employee_Mileage__c> milOldMap = new Map<ID, Employee_Mileage__c>();
        
        emp6.Mileage__c = 10.00;
        Update emp6;
        milOldMap.put(emp6.Id, emp6);
*/
        emp4.Trip_Status__c = 'Rejected';
        update emp4;
        //Map<ID, Employee_Mileage__c> milOldMap = new Map<ID, Employee_Mileage__c>();
        emp4.Trip_Status__c = 'Approved';
        emp4.Map_Country__c = 'CANADA';
        update emp4;

        
        


        Test.startTest();
        Map<ID,Employee_Mileage__c> milMap = new Map<ID,Employee_Mileage__c>();
        milMap.put(emp1.id,emp1);
        List<Employee_Mileage__c> mileageNew = new List<Employee_Mileage__c> ();
        mileageNew.add(emp1);
        MappingGasPriceTriggerHelper.TrackHistory(milMap,mileageNew);
        MappingGasPriceTriggerHelper.updateMileagesLockDate(mileageNew);
        MappingGasPriceTriggerHelper.updateMileages(mileageNew);
        MappingGasPriceTriggerHelper.updateBiweekReimId(mileageNew);
         MappingGasPriceTriggerHelper.updateMilLockDateBWReim(emplist);
        //MappingGasPriceTriggerHelper.updateCanadianMileage(mileageNew);
        MappingGasPriceTriggerHelper.updateCanadianMileage(milIdList);
       Test.StopTest();
    }   
}