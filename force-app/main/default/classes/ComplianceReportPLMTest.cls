@isTest    
public class ComplianceReportPLMTest {
    @isTest    
    public static void reimburMethod1() {
        
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_1 = new IRS_Mileage_Rate__c();
        obj_IRS_Mileage_Rate_1.year__c='2021';
        obj_IRS_Mileage_Rate_1.IRS_Rate__c =0.578;
        insert obj_IRS_Mileage_Rate_1;
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        insert customEmailSetting;
        
        TaxLiablityPL__c taclibcustomsetting = new TaxLiablityPL__c();
        taclibcustomsetting.name = 'DefaulDates';
        taclibcustomsetting.Start_Date__c =date.parse('7/25/2021') ;
        taclibcustomsetting.End_Date__c = date.parse('12/30/2021') ;
        taclibcustomsetting.IRS_Year__c = '2021';
        insert taclibcustomsetting;
        
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Gas_Prices__c gasprice = new Gas_Prices__c();
        gasprice.City__c = 'Denver';
        gasprice.Fuel_Price__c = 3;
        gasprice.Month_Year__c = Date.today().adddays(-1);
        gasprice.State__c = 'CA';
        insert gasprice;
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact();    
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'PL Marketing');
            account_1.Bi_Weekly_Pay_Period__c = true;
            account_1.Pay_Period_Days__c = 13;
            account_1.Pay_Period_Start_Date__c = system.today().adddays(-130);
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c='abc@gmail.com');
            insert contact_1;
            
            acc.Name = 'PL Marketing';
            acc.Triplog_API__c = '123456789';
            Acc.Triplog_Status__c = 'U';
            acc.Bi_Weekly_Pay_Period__c = true;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            insert Acc;
            
            for(Integer i; i<=10; i++){
                
                Contact con = new Contact();        
                con.FirstName = 'Priyanka';
                con.LastName = 'Gajera';
                con.Employee_ID__c = '123456';
                con.compliancestatus__c ='Yes';
                con.AccountId = acc.Id;
                con.account.Name = acc.Name;
                con.External_Email__c = 'minkfesh.patel1478'+ i + '@gmail.com';
                con.compliancestatus__c ='Yes';
            	con.Role__c = StaticValues.roleAdminDriver;
                con.Deactivated_Date__c = Null;
                con.Insurance_Attachment_Id__c = Null;
                con.Vehicle_Type__c = '2019 Full-Size Sedan';  
                
                conList.add(con);
            }
            insert conList;
            
            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = acc.Id;
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.compliancestatus__c = 'No Compliance';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver/Manager';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2019 Full-Size Sedan';
            con1.Time_Zone__c = 'US/Eastern';
            insert con1;
            
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
        
        Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = '07/25/2021 to 08/08/2021'; 
            br.Contact__c = con1.Id;
            br.Start_Date__c = date.valueOf('2021-07-25');
            br.End_Date__c = date.valueOf('2021-08-08');
            br.MPG__c = con1.MPG__c;
            br.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
            br.Fixed_Amount__c = con1.Fixed_Amount__c;
            br.Status__c = 'Approved';
        	br.Approved_Date__c = system.today();
            br.Fuel_Price__c = 0;
        insert br;
        
        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = con1.Id;
        er1.Name = '11/21/2021 to 12/04/2021';
        er1.Month__c = '03-2021';
        er1.Status__c = 'Pending';
        er1.Fuel_Price__c = 10.00; 
        er1.Fixed_Amount__c = con1.Fixed_Amount__c;
        er1.Status__c = 'Pending';
        er1.Maintenance_and_Tires__c = con1.Maintenance_and_Tires__c;
        er1.MPG__c = con1.MPG__c;
        insert er1;
                
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Bi_Weekly_Reimbursement__c = br.Id;
        emp.EmployeeReimbursement__c = er1.id;
        emp.Contact_Email_Id__c = con1.External_Email__c;
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
        
        
        
        ComplianceReportPLM.wrapperTaxReport wrp= new ComplianceReportPLM.wrapperTaxReport();
        wrp.drivername = 'test';
        wrp.employeeid = '23234';
        wrp.emailid = 'dfed@gmail.com';
        wrp.approvedmileages = 23;
        wrp.totalreim = 21;
        wrp.iRSallowable = 212;
        wrp.imputedincome = 23;
        wrp.divison = '11';
        wrp.addedDate = string.valueOf(system.today());
        wrp.insurance = 'gjdgk123345';
        wrp.complianceStatus = 'Pending';
        wrp.expirationDate = string.valueOf(system.today()+31);
        wrp.vehicleValue = '3400';
        wrp.vehicleAge = '6';
        wrp.noOfBiweek = '8';
        wrp.complianceMileage = 1230;
        
        Test.startTest();
        apexpages.currentpage().getparameters().put('accid',acc.Id);
        ComplianceReportPLM comReport = new ComplianceReportPLM();
        Test.stopTest();
    }
}