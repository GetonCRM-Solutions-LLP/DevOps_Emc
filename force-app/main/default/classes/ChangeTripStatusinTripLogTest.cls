@isTest
public with sharing class ChangeTripStatusinTripLogTest {
    
    public static testmethod void method1() {
        
        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'ChangeTripStatusinTripLog';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        RecordUtilityClass.createRecordsAdminDashboardController();
        
        Account currentAccount; 
        Contact currentAdmin;
        Contact selectedDriver;
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_2;
        System.runAs(admin) {
            Test.setMock(HttpCalloutMock.class, new ChangeTripStatusinTripLogTestMock());
            currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
            currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
            selectedDriver = RecordUtilityClass.getDriverContact();
        }
        
        List<String> approvedIdList = new List<String>();
        List<String> rejectedIdList = new List<String>();   
        List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
        List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(empReimbursementList);
        List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
        driverMileagesList[0].Trip_Id__c = 104976448;
        update driverMileagesList;
        system.debug('selected List'+selectedReimList);
        approvedIdList.add(driverMileagesList[0].id);    
        
        Database.executeBatch(new ChangeTripStatusinTripLog(approvedIdList ,rejectedIdList,'test','test@gmail.com') );
    }
    public static testmethod void method2() {
        
        SendEmailToMe__c sendemailme = new SendEmailToMe__c();
        sendemailme.name = 'ChangeTripStatusinTripLog';
        sendemailme.Send_email_to_me__c = true;
        insert sendemailme;
        
        SendEmailonDeactivation__c sendemailme1 = new SendEmailonDeactivation__c();
        sendemailme1.name = 'mileageprocess';
        sendemailme1.Send_to_me__c = true;
        sendemailme1.BCCEmailaddresses__c = 'abc@gmail.com';
        sendemailme1.Send_to_Admin__c = true;
        sendemailme1.Send_to_Manager__c = true;
        insert sendemailme1;
        
        RecordUtilityClass.createRecordsAdminDashboardController();
        Account currentAccount; 
        Contact currentAdmin;
        Contact selectedDriver;
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_2;
        System.runAs(admin) {
            Test.setMock(HttpCalloutMock.class, new ChangeTripStatusinTripLogTestMock());
            currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
            currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
            selectedDriver = RecordUtilityClass.getDriverContact();
            
        }  
        List<String> approvedIdList = new List<String>();
        List<String> rejectedIdList = new List<String>();   
        List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);
        List<EmployeeReimbursementDetailsAdmin> selectedReimList = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(empReimbursementList);
        List<Employee_Mileage__c> driverMileagesList =  RecordUtilityClass.getMileagesList();
        driverMileagesList[0].Trip_Id__c = 104976448;
        driverMileagesList[0].Trip_Date__c = system.today().toStartOfMonth().addDays(-1);
        driverMileagesList[1].Trip_Id__c = 104976442;
        update driverMileagesList;
        approvedIdList.add(driverMileagesList[0].id);
        approvedIdList.add(driverMileagesList[1].id);
        system.debug('selected List'+selectedReimList);
        rejectedIdList.add(driverMileagesList[0].id);
        
        ChangeTripStatusinTripLog obj = new ChangeTripStatusinTripLog(approvedIdList ,rejectedIdList,'test','test@gmail.com');
        obj.UpdateMileages(approvedIdList,'Approved');
        ChangeTripStatusinTripLog.BuildBody('Approved',approvedIdList);
        obj.callPutApi('asdfghjytrew56789jhgfd', '', selectedDriver.id, empReimbursementList[0].id, 10);
        
        Database.executeBatch(new ChangeTripStatusinTripLog(approvedIdList ,rejectedIdList,'test','test@gmail.com') );
    }
}