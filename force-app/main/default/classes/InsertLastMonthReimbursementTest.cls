@istest
public class InsertLastMonthReimbursementTest {
    
    public static testmethod void testMethod1(){
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'Defaulttrigger');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Account acc ;
        List<Contact> con ;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True, 'Ermi', False);
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-14);
            update acc;

            con = TestDataFactory.createDriverContact(False, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
            con[0].Driver_Type__c = 'Driver - Salary';
            con[0].isCommunityUser__c = true;
            Insert con;

            userObj = TestDataFactory.createUser(True, profileObj.Id, con[0].Id);
        }
        Batch_Configuration__c bat = TestUtilityClass.getTestBatchConfig();
        Batch_Setup__c batc = TestUtilityClass.getTestBatchSetup();
        Gas_Prices__c gas = TestUtilityClass.getTestGasPrices();
        RG_InsertLastMonthReimbursement Ins = new RG_InsertLastMonthReimbursement();
        Database.executeBatch(Ins, 200);
    }

     public static testmethod void testMethod2(){
      
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'Defaulttrigger');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Account acc ;
        List<Contact> con ;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True, 'Ermi', False);
            acc.isUsingTriplog__c = True;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-14);
            Update acc;

            con = TestDataFactory.createDriverContact(True, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
            con[0].IsCreatedFromCommunity__c = false;
            Update con;

            userObj = TestDataFactory.createUser(True, profileObj.Id, con[0].Id);
        }
        
        Batch_Configuration__c bat = TestUtilityClass.getTestBatchConfig();
        Batch_Setup__c batc = TestUtilityClass.getTestBatchSetup();
        Gas_Prices__c gas = TestUtilityClass.getTestGasPrices();
        String month;
        if(date.today().addMonths(-1).month() <= 9){
             month = '0'+ date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        }   else {
             month = date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        }
        
        system.System.debug('month== ' + month);
        RG_InsertLastMonthReimbursement Ins = new RG_InsertLastMonthReimbursement(month);
        Database.executeBatch(Ins, 200);
    }

    public static testmethod void testMethod3(){
     
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'Defaulttrigger');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Account acc ;
        List<Contact> con ;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True, 'Ermi', False);
            acc.isUsingTriplog__c = True;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-14);
            Update acc;

            con = TestDataFactory.createDriverContact(True, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
            con[0].IsCreatedFromCommunity__c = false;
            Update con;

            userObj = TestDataFactory.createUser(True, profileObj.Id, con[0].Id);
        }
        
        Batch_Configuration__c bat = TestUtilityClass.getTestBatchConfig();
        Batch_Setup__c batc = TestUtilityClass.getTestBatchSetup();
        Gas_Prices__c gas = TestUtilityClass.getTestGasPrices();
        String month;
        if(date.today().addMonths(-1).month() <= 9){
             month = '0'+ date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        }   else {
             month = date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        }
        RG_InsertLastMonthReimbursement Ins = new RG_InsertLastMonthReimbursement(month,'test123@gmail.com,test23@gmail.com');
        Database.executeBatch(Ins, 200);
    }

    public static testmethod void testMethod4(){
       
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        SendEmail__c customSetting3 = TestDataFactory.sendEmailCustomSetting(true, 'EmployeeReimbursementTrigger');
        SendEmailToMe__c customSetMail = TestDataFactory.sendEmailToMeCustomSetting(true, 'Defaulttrigger');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Account acc ;
        List<Contact> con ;

        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;

        System.runAs(admin) {
            acc = TestDataFactory.createAccount(True, 'Ermi', False);
            acc.isUsingTriplog__c = True;
            acc.Pay_Period_Days__c = 13;
            acc.Pay_Period_Start_Date__c = system.today().adddays(-14);
            Update acc;

            con = TestDataFactory.createDriverContact(True, acc.Id, 'Driver', vehicleType.Name, 'Paras.Patel', 2);
            con[0].IsCreatedFromCommunity__c = false;
            Update con;

            userObj = TestDataFactory.createUser(True, profileObj.Id, con[0].Id);
        }
        
        Batch_Configuration__c bat = TestUtilityClass.getTestBatchConfig();
        Batch_Setup__c batc = TestUtilityClass.getTestBatchSetup();
        Gas_Prices__c gas = TestUtilityClass.getTestGasPrices();
        String month;
        if(date.today().addMonths(-1).month() <= 9){
             month = '0'+ date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        }   else {
             month = date.today().addMonths(-1).month() + '-'+ date.today().addMonths(-1).year();
        }
        RG_InsertLastMonthReimbursement Ins = new RG_InsertLastMonthReimbursement(month,'test123@gmail.com');
        Database.executeBatch(Ins, 200);

        scheduledRG_InsertLastMonthReimbursement m = new scheduledRG_InsertLastMonthReimbursement();
        String sch = '  0 0 6 2 1/1 ? *';        
        String jobID = system.schedule('Checking Missing Fuel Price for '+month, sch, m);
    }
    
}