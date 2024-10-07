@isTest
public class UpdateInsuranceDataController_Test {
    public Static testMethod void Method1(){
            
            TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
            customEmailSetting.Name = 'Defaulttrigger';
            customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
            customEmailSetting.ContactTriCommunityReimCreate__c = true;
            insert customEmailSetting;
            
            SendEmail__c customSetting1 =  new SendEmail__c();
            customSetting1.Name = 'Send Email For Compliance';
            customSetting1.Send_email_from_code__c= true;
            insert customSetting1;
        TrueDialog_Keys__c tdKeys =TestDataFactory.createTrueDialog(true);    
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(true,0);
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account acc = new Account();
        Contact con = new Contact();
        System.runAs(admin) {
           	acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Vehicle_Types__c=veh.name;
            acc.True_Dialog__c = true;
            acc.Vehicle_Types__c = veh.Name;
            Insert acc;
            List<Contact> contact_1 = testdatafactory.createDriverContact(true,acc.id,'Driver',veh.Name,'test.email',1);
            
            con.LastName = 'TestContact';
            con.Role__c = 'Driver';
            con.Car_Image__c = veh.URL__c;
            con.Vehicle_Type__c = veh.Year__c +' '+veh.vehicle__c;
            con.AccountId = acc.Id;
            con.Phone = '1234566787';
            con.MobilePhone = '1234566787';
            con.Deactivated_Date__c = null;
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
            con.Cell_Phone__c='Employee Provide';
            con.Reimbursement_Frequency__c='Monthly Reimbursement';
            con.Activation_Date__c=system.today();
            insert con;
            //added by megha
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1[0].Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
  
            Test.startTest();
           
            ApexPages.CurrentPage().getParameters().put('ID', acc.Id);
            UpdateInsuranceDataController testAccPlan = new UpdateInsuranceDataController();
        	UpdateInsuranceDataController.getComplianceStatus();
            
            list<UpdateInsuranceDataController.ContactWrapper> conWrap = new list<UpdateInsuranceDataController.ContactWrapper>();
           UpdateInsuranceDataController.ContactWrapper wrap = new UpdateInsuranceDataController.ContactWrapper();
            wrap.contactId = con.Id;
            wrap.currentLeval = con.Current_Level__c;
            wrap.expirationDate = String.valueOf(con.Expiration_Date__c);
            wrap.insurance = con.Insurance__c;
            wrap.isEditable = false;
            wrap.meetingMinimum = con.Meeting_Minimum__c;
            wrap.name = con.Name;
            //wrap.vehicleAge = con.Vehicle_Age__c;
            //wrap.vehicleValue = con.Vehicle_Value_Check__c;
            conWrap.add(wrap);
            UpdateInsuranceDataController.editInlineNewEmployee(Json.serialize(conWrap));
            Test.StopTest();
        }
}