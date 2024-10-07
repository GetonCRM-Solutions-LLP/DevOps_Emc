@isTest
public class UpdateMileageControllerTest {
    public static testMethod Void UpdateMileageConTestMethod() {
        
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        IRS_Mileage_Rate__c irs = new IRS_Mileage_Rate__c();
         irs.year__c = String.valueof(system.today().year());
         irs.IRS_Rate__c = 0.85;
         insert irs;
         
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Vehicle';
        veh.Year__c = '2019';
        insert veh;
        
        Account account = new Account();
        account.name = 'Test Account';
        account.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
        account.Pay_Period_Start_Date__c = System.today().addDays(-100);
        account.Pay_Period_Days__c = 6;
        insert account;
           
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test@test.com';
        contact.Fixed_Amount__c = 0.0;
        contact.Role__c = 'Driver/Admin';
        contact.Driver_Type__c = 'Driver - Salary';
        contact.Vehicle_Type__c = '2019 Full-Size Vehicle';
        contact.MailingState = 'CA';
        contact.compliancestatus__c = 'Yes';
        contact.MailingCity = 'Canyon';
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
        
        Bi_Weekly_Reimbursement__c bob = new Bi_Weekly_Reimbursement__c();
        bob.name = '9/19/2021 to 10/2/2021';
        bob.Contact__c = contact.id;
        insert bob;
        
        Employee_Mileage__c empMileageRec = new Employee_Mileage__c();
        empMileageRec.Contact_Email_Id__c = 'test1@test1.gmail.com';
        empMileageRec.Name = 'Test Mileage Record';
        empMileageRec.EmployeeReimbursement__c = erRec.id;
        empMileageRec.Fuel_price__c = erRec.Fuel_Price__c;
        empMileageRec.Trip_Status__c = 'Approved';
        empMileageRec.Trip_Id__c = 15445445;
        empMileageRec.Approved_Date__c = system.today() - 1;
        empMileageRec.Bi_Weekly_Reimbursement__c = bob.Id;
        insert empMileageRec;
        
        Test.startTest();
        PageReference pageRef = Page.Update_Mileages;
        pageRef.getParameters().put('Id',erRec.id);
        Test.setCurrentPage(pageRef);
        UpdateMileageController controller = new UpdateMileageController();
        controller.getMileagesList();
        for(UpdateMileageController.MileageWrapper wrapper : controller.mileageWrapper) {
            wrapper.isSelected = true;
        }
        controller.updateMileages();
        controller.putHTTP();
        controller.setCookie();
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.End();
        controller.getDisablePrevious();
        controller.getDisableNext();
        controller.getTotal_size();
        controller.getPageNumber();
        controller.getTotalPages();
        Test.stopTest();
    }
}