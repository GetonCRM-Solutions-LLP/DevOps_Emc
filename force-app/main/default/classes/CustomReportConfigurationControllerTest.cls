@isTest
private class CustomReportConfigurationControllerTest {
    @isTest static void myUnitTest() {
        //Insert Custom setting data
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        TriggerConfig__c customSetting2 = new TriggerConfig__c( Name = 'Defaulttrigger');
        customSetting2.ContactTriggersendEmailForNewContact__c = false;
        insert customSetting2;

        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'TriplogUserIdUpdateBatch';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        //Insert Account data Using Utility class
        Account acc = new Account();
        
        acc.Name = 'Delta';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'abc';        
        acc.Enable_Email_For_Managers__c = True;
        insert acc;
       
        //Insert Contact data 
        Contact con = new Contact();
        con.FirstName = 'Test1';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'USA';
        con.Phone = '1232434445';
        con.External_Email__c = 'test@gmail.com';
        con.Deactivated_Date__c = null;
        con.Triplog_UserID__c = null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Driver';
        con.Monthly_Mileage_Limit__c = 100;
        con.IsCreatedFromCommunity__c = true; 
        con.Vehicle_Type__c  = '2019 Full-Size Sedan';
        checkRecursive.runOnce();
        insert con;

        PageReference pageRef = Page.CustomReportConfiguration;
        Test.setCurrentPage(pageRef);
        CustomReportConfigurationController cntrl = new CustomReportConfigurationController();
        cntrl.GetAccountOptions();
        cntrl.selectedAccountId = acc.Id;
        cntrl.LoadContacts();
        cntrl.GetReportCategories();
        cntrl.GetReportTypes();
        cntrl.selectedContacts = new List<SelectOption>();
        cntrl.selectedContacts.add(new SelectOption(UserInfo.getUserId(), 'test'));
        cntrl.NextStep();
        cntrl.selectedRecordType = 'Mileages';
        cntrl.GetObjectFields();
        cntrl.selectedField = 'EmployeeReimbursement__c >';
        cntrl.OnChangeField();
        cntrl.GetObjectFields_1();
        cntrl.selectedField_1 = 'Contact_Id__c >';
        cntrl.OnChangeField();
        cntrl.GetObjectFields_2();
        cntrl.selectedField_2 = 'AccountId >';
        cntrl.OnChangeField();
        cntrl.GetObjectFields_3();
        cntrl.selectedField_3 = 'BillingCity';
        cntrl.OnChangeField();
        ApexPages.currentPage().getParameters().put('fieldName','EmployeeReimbursement__r.Contact_Id__r.AccountId');
        ApexPages.currentPage().getParameters().put('idx','1');
        cntrl.addAdvCriteriaRow();
        cntrl.SaveCustomReport();
        cntrl.PreviousStep();
        cntrl.findFieldType();
        cntrl.GetavailableFields();
		cntrl.RemoveSelectField();
        cntrl.LoadFieldSelection();
        cntrl.SaveFieldSelection();
    }
}