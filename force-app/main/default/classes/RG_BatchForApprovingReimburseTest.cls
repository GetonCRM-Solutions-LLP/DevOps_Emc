@isTest
Public class RG_BatchForApprovingReimburseTest{
    public static testmethod void approvtest(){

        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account acc ;
        List<Contact> conList;
        List<Contact> managerconList;
       
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test Accounts',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            acc = TestDataFactory.createAccount(true,'Test Accounts',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            acc.Motor_Vehicle_Record_Check_Document__c = true;
            update acc;
           
            managerconList = TestDataFactory.createDriverContact(true, acc.Id, 'Manager', vehicleType.Name, 'paras.PAtel',  1);
            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].External_Email__c = 'paras.dhanani@gmail.com';
            conList[0].Manager__c = managerconList[0].Id;
            Insert conList[0];
           
            
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
        String lastMonth = WrapperUtils.getLastMonthValue(-1);

        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, conList, 0, createIRSRate.Id);
        er[0].Month__c = lastMonth;
        er[0].Status__c = 'Pending';
        er[0].Approved_Date__c = null;
        Insert er[0];

        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
        
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (False, 0, er, br);
        emp1[0].Mileage__c =  51.20;
        emp1[0].Trip_Status__c = 'Not Approved Yet';
        //emp1[0].Approved_Date__c = system.today();
        Insert emp1[0];
        Employee_Mileage__c empMile  = new Employee_Mileage__c();
        
        RG_BatchForApprovingReimburse batchobj = new RG_BatchForApprovingReimburse();
        DataBase.executeBatch(batchobj,200);

       
      }
      
     public static testmethod void approvtest1(){
      
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c customSetting2 = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(true, 3);
        IRS_Mileage_Rate__c createIRSRate = TestDataFactory.createIRSRate(true, 0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account acc ;
        List<Contact> conList;
       
        System.runAs(admin) {
            Account accountObj = TestDataFactory.createAccount(true,'Test Accounts',true);
            Contact contactObj = TestDataFactory.createCICDContact(true,accountObj.Id);

            acc = TestDataFactory.createAccount(true,'Test Accounts',true);
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            acc.Motor_Vehicle_Record_Check_Document__c = true;
            update acc;

            conList = TestDataFactory.createDriverContact(false, acc.Id, 'Driver', vehicleType.Name, 'paras.dhanani',  1);
            conList[0].Vehicle_Type__c = vehicleType.Name;
            conList[0].External_Email__c = 'minkesh.patel1478@gmail.com';
            conList[0].Monthly_Mileage_Limit__c = 0; 
            Insert conList;
           
            userObj = TestDataFactory.createUser(True, profileObj.Id, conList[0].Id);
        }
        String lastMonth = WrapperUtils.getLastMonthValue(-1);

        List<Employee_Reimbursement__c> er = TestDataFactory.createPendingReimbursement(False, conList, 0, createIRSRate.Id);
        er[0].Month__c = lastMonth;
        er[0].Status__c = 'Pending';
        er[0].Approved_Date__c = null;
        Insert er[0];

        List<Bi_Weekly_Reimbursement__c> br = TestDataFactory.createBiweeklyReim (true, conList, System.today().addDays(-26),System.today().addDays(-13), 1, createIRSRate.Id);
        
        List<Employee_Mileage__c> emp1 = TestDataFactory.getEmpMileage (False, 0, er, br);
        emp1[0].Trip_Status__c = 'Approved';
        emp1[0].Approved_Date__c = system.today();
        emp1[0].Mileage__c = 105;
        emp1[0].Approved_Date__c = Null;
        emp1[0].Trip_Status__c = StaticValues.noApprovedYet;
        emp1[0].Rejected__c = False;
        Insert emp1;
       
        RG_BatchForApprovingReimburse batchobj = new RG_BatchForApprovingReimburse();
        DataBase.executeBatch(batchobj, 200);
    } 
}