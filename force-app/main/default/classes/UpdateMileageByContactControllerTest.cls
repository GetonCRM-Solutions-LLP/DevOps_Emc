@isTest
public class UpdateMileageByContactControllerTest {
    public static testMethod Void UpdateMilConTestMethod() {
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c =  'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Account account = new Account();
        account.name = 'Test Account';
        account.isUsingTriplog__c = true;
        insert account;
           
        Contact contact = new Contact();
        contact.lastname = 'Test Contact90';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test90@test.com';
        contact.Fixed_Amount__c = 0.0;
        contact.MailingState = 'CA';
        contact.MailingCity = 'Canyon';
        contact.Role__c = 'Driver';
        contact.Vehicle_Type__c  = '2019 Full-Size Sedan';  
        insert contact;
        
        Employee_Reimbursement__c erRec = new Employee_Reimbursement__c();
        erRec.Contact_Id__c = contact.Id;
        erRec.month__c = '01-2018';
        erRec.Name = contact.lastname+':'+erRec.month__c;
        erRec.Status__c = 'Pending';
        erRec.Fuel_Price__c = 2.22;
        erRec.Approved_Date__c = system.today() - 3;
        erRec.Fixed_Amount__c = 10.10;
        insert erRec;
        
        Employee_Mileage__c empMileageRec = new Employee_Mileage__c();
        empMileageRec.Contact_Email_Id__c = 'test1@test1.gmail.com';
        empMileageRec.Name = 'Test Mileage Record';
        empMileageRec.EmployeeReimbursement__c = erRec.id;
        empMileageRec.Fuel_price__c = erRec.Fuel_Price__c;
        empMileageRec.Trip_Status__c = 'Not Approved Yet';
        //empMileageRec.Approved_Date__c = system.today() - 1;
        insert empMileageRec;
        
        Test.StartTest();
        UpdateMileageByContactController updateMilTest = new UpdateMileageByContactController();
        updateMilTest.Selected_contact_id = contact.Id;
        updateMilTest.Selected_reimbersments = erRec.Id;
        updateMilTest.Transfer_reimbersment = erRec.Id;
        updateMilTest.getAccounts();
        updateMilTest.getReimbersments();
        updateMilTest.getMileages();
        updateMilTest.getIsPRSelected();
        updateMilTest.updateMileage();
        Test.StopTest();
    }
}