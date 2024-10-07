@istest
public class TransferMileagesBatchTest {
    public static testmethod void testMethod1(){
        TriggerConfig__c customEmailSetting = TestDataFactory.triggerConfigCustomSetting(true);
        TrueDialog_Keys__c trueDialogCustom = TestDataFactory.createTrueDialog(true);
        
        daylight_saving_time_config__c customSetting2 =  new daylight_saving_time_config__c();
        customSetting2.Name = '2023';
        customSetting2.Start_Date__c = System.today();
        customSetting2.End_Date__c = System.today() + 60;
        insert customSetting2;

        Vehicle_URL_Mapping__c veh = TestDataFactory.createVehicleData(false, 3);
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

        UserRole uRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(uRole.Id);
        User userObj;
        
        Account acc;
        Contact con1 = new Contact();
        
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Name = 'Test Accounts';
            acc.isUsingTriplog__c = true;
            insert acc;

            con1.FirstName = 'Priyanka';
            con1.LastName = 'Gajera';
            con1.AccountId = acc.Id;
            //con1.Account.name = 'PL Marketing';
            con1.External_Email__c = 'minkesjhh.patel1478@gmail.com';
            con1.Deactivated_Date__c = Null;
            con1.Role__c = 'Driver';
            con1.Insurance_Attachment_Id__c = Null;
            con1.Vehicle_Type__c = '2019 Full-Size Sedan';
            con1.MailingCity = 'Atlanta';
            con1.MailingState = 'GJ';
            con1.Employee_ID__c = '234343456';
            con1.Time_Zone__c = 'US/Mountain';
            
            insert con1;
        }

        String monthName = '04-2023';
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con1.Id;
        er.Name = con1.Name + ':' + monthName;
        er.Month__c = monthName;
        er.Fuel_Price__c = 6.78;
        er.MPG__c = 14.00;
        er.Status__c = 'Approved';
        er.Approved_Date__c = System.today();
        er.Prev_Approved_Date_Value__c = er.Approved_Date__c;
        er.Prev_Status_Value__c = er.Status__c;
        er.Mileage_Lock_Date__c = null;
        insert er;
        
        Bi_Weekly_Reimbursement__c biReim = new Bi_Weekly_Reimbursement__c();
        bireim.Approved_Date__c = system.today().addDays(-1);
        bireim.Status__c = 'Pending';
        bireim.Name = '04/02/2023 to 04/08/2023';
        bireim.Start_Date__c = Date.parse('04/02/2023');
        bireim.End_Date__c = Date.parse('04/08/2023');
        bireim.Contact__c = con1.Id;
        insert bireim;
        
        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp1.EmployeeReimbursement__c = er.id;
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
        
        TransferMileagesBatch last = new TransferMileagesBatch(1);
        Database.executeBatch(last, 1);
    } 
    /*public static testmethod void testMethod2(){
      TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;

        Account acc = TestUtilityClass.getTestSingleAccount();
        Contact con = TestUtilityClass.getTestSingleContact(acc);
        Employee_Reimbursement__c emp = TestUtilityClass.getTestEmployeeReimbursement(con);
        emp.Month__c = '04-2020';
        update emp;
        Contact cont = TestUtilityClass.getTestSingleContact2(acc);
         Employee_Reimbursement__c empr = TestUtilityClass.getTestEmployeeReimbursement3(cont);
        Employee_Mileage__c empMil = TestUtilityClass.getTestEmployeeMileage(emp);
        Batch_Setup__c batc = TestUtilityClass.getTestBatchSetup();
        TransferMileagesBatch last = new TransferMileagesBatch(1);
        Database.executeBatch(last, 1);
    } */
}