@isTest
public class MassSyncTripforCommuteTest {
    public static testmethod void GetTriptest() {
        List<Id> contactids = new List<Id>();
        
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        Map<Id, Employee_Reimbursement__c> conReim = new Map<Id, Employee_Reimbursement__c>();
        
         Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmailToMe__c  objSendEmailToMe = new SendEmailToMe__c();
        objSendEmailToMe.Name = 'GetTripCallOutApprovePutCall';
        objSendEmailToMe.Send_email_to_me__c = true;
        insert objSendEmailToMe;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        IRS_Mileage_Rate__c irs = new IRS_Mileage_Rate__c();
        irs.year__c = '2021';
        irs.IRS_Rate__c = 0.85;     
        insert irs;
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account acc;
        Contact contact;
        Contact con ;
        Contact con2 ;
         List<Contact> conList = new List<Contact>();
        System.runAs(admin) {
            acc = new Account();           
            acc.Name = 'Delta account';
            acc.Triplog_API__c = '123456789';
            acc.Triplog_Status__c = 'U';
            acc.Bi_Weekly_Pay_Period__c = true;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-130);
            insert Acc;
            
           // acc = TestDataFactory.createAccount(true,'Test',true);
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', veh.Name, 'test.email', 1);
            
           // List<contact> conList = new List<Contact>();
            contact = new Contact();
            contact.lastname = 'Test Contact';
            contact.AccountId = Acc.Id;
            contact.External_Email__c = 'minkesh.patel1478@gmail.com';
            contact.Email = 'minkesh.patel1478@gmail.com';
            contact.isCommunityUser__c = true;
            contact.MailingCity='ahmedabad';
            contact.MailingState='GJ';
            contact.compliancestatus__c = 'No – Vehicle Age';
            contact.Vehicle_Type__c = '2019 Mileage Rate';
            contact.Cell_Phone__c='Company Provide';
            contact.Activation_Date__c=System.today();
            contact.Reimbursement_Frequency__c='Monthly Reimbursement';
            insert contact;
            contactids.add(contact.Id);
           // conList.add(contact);
            
            con = new Contact();
            con.lastname = 'Test Con';
            con.AccountId = Acc.Id;
            con.External_Email__c = 'minkesh.patel1357@gmail.com';
            con.Email = 'minkesh.patel1357@gmail.com';
            con.Triplog_Status__c = 'U';
            con.compliancestatus__c = 'No – Vehicle Age';
            con.isCommunityUser__c = true;
            con.Cell_Phone__c='Company Provide';
            con.Activation_Date__c=System.today();
            con.Reimbursement_Frequency__c='Monthly Reimbursement';
            insert con;
	
            con2 = new Contact();
            con2.lastname = 'Test Con';
            con2.AccountId = Acc.Id;
            con2.External_Email__c = 'minkesh.patel13@gmail.com';
            con2.Email = 'minkesh.patel13@gmail.com';
            con2.Triplog_Status__c = 'U';
            con2.compliancestatus__c = 'No – Vehicle Age';
            con2.isCommunityUser__c = true;
            con2.Role__c = 'Admin';
            con2.Cell_Phone__c='Company Provide';
            con2.Activation_Date__c=System.today();
            con2.Reimbursement_Frequency__c='Monthly Reimbursement';
            insert con2;
            
            contactids.add(con.Id);
            Contact contact_1 = new Contact(AccountId = acc.Id, LastName = 'xgeek',External_Email__c='newmail@gmail.com',Cell_Phone__c='Company Provide',Activation_Date__c=System.today(),Reimbursement_Frequency__c='Monthly Reimbursement');
            insert contact_1;
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
        List<String>  reimList = new List<String> ();
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = contact.Id;
        er.month__c = '09-2020';
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        conReim.put(con.Id,er);
        reimList.add(er.ID);
        
        Employee_Reimbursement__c er1 = new Employee_Reimbursement__c();
        er1.Contact_Id__c = contact.Id;
        er1.month__c = '09-2020';
        er1.Name = contact.lastname+':'+er.month__c;
        er1.Status__c = 'Pending';
        er1.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er1.MPG__c = 10.00;
        er1.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er1.Fuel_Price__c = 1;
        er1.MPG__c = 10;
        er1.Maintenance_and_Tires__c = 10;
        er1.Fixed_Amount__c = 10.10;
        er1.Triplog_Status__c = 'U';
        insert er1;
         reimList.add(er1.ID);
        
       // LIst<Employee_Reimbursement__c> reimIdList = TestDataFactory.createPendingReimbursement(True,conList,2,obj_IRS_Mileage_Rate.Id);
        
        Bi_Weekly_Reimbursement__c biReim = new Bi_Weekly_Reimbursement__c();
        bireim.Approved_Date__c = system.today().addDays(-1);
        bireim.Status__c = 'Pending';
        bireim.Name = '07/25/2021 to 08/07/2021';
        bireim.Start_Date__c = Date.parse('10/03/2021');
        bireim.End_Date__c = Date.parse('10/16/2021');
        bireim.Contact__c = con.id;
        insert bireim;
        
        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Contact_Email_Id__c = 'test@test.gmail.com';
        emp.Name = 'Test Mileage Record';
        emp.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp.EmployeeReimbursement__c = er.id;
        insert emp;
        
        Test.startTest();
        Test.SetMock(HttpCalloutMock.class, new GetTripCalloutMock());
        MassSyncTripforCommute obj = new MassSyncTripforCommute(Acc.Id,'2020-10-01','2020-10-31','09-2020','U',false, 'Business');
        DataBase.executeBatch(obj);
        MassSyncTripforCommute obj1 = new MassSyncTripforCommute(reimList);
        DataBase.executeBatch(obj1);
		String response = BiWeeklyWrapperUtils.getUnapprovedReimbursements(con2.Id,Acc.Id,True,'Admin');        
        /*string biWeekData = JSON.serialize(biReim);
        system.debug('biWeekData==' + biWeekData);*/
        system.debug('biReim==' + biReim);
        MassSyncTripforCommute obj2 = new MassSyncTripforCommute(response,Acc.Id);
        DataBase.executeBatch(obj2);
        Test.stopTest();
    }
}