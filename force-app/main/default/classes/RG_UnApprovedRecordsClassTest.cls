@isTest
public class RG_UnApprovedRecordsClassTest {
    public static testmethod void Testmethod1() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Manager'];

        Account acc = TestUtilityClass.getTestSingleAccount();
        acc.Lock_date__c  = System.today();
        update acc;


        Contact cont = new contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acc.id, External_Email__c = 'test@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', showTeamRecord__c = true,Monthly_Mileage_Limit__c = 100);
        insert cont;
        Contact cont2 = new contact(FirstName='FirstName301',lastName = 'testAdmin401', accountid = acc.id, External_Email__c = 'test1@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100);
        insert cont2;
        User u1 = [select id from user where Email='test@gmail.com'];
        
           System.runAs(u1) {
              
      
        Employee_Reimbursement__c reimburse = TestUtilityClass.getTestEmployeeReimbursement3(cont);
        
        Employee_Mileage__c mileage = TestUtilityClass.getTestEmployeeMileage2(reimburse);
        mileage.Trip_Date__c  = System.today();
        mileage.approved_Date__c = null;
        mileage.Rejected__c = false;
        update mileage;
      
        Gas_Prices__c gasPrice = TestUtilityClass.getTestGasPrices();
        gasPrice.Month_Year__c = Date.today().addmonths(-1).tostartofmonth();
        update gasPrice;
        
        RG_UnApprovedRecordsClass unApprovedRecord = new RG_UnApprovedRecordsClass();
       // RG_UnApprovedRecordsClass.RembWrap rem = new RG_UnApprovedRecordsClass.RembWrap();
        unApprovedRecord.sendEmail();
        unApprovedRecord.UpdateRecord();
        RG_UnApprovedRecordsClass.getcurrentUserCompanyId();
        }
    }
    public static testmethod void Testmethod2() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Manager'];

        Account acc = TestUtilityClass.getTestSingleAccount();
        acc.Lock_date__c  = System.today();
        update acc;


        Contact cont = new contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acc.id, External_Email__c = 'test@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Monthly_Mileage_Limit__c = 100);
        insert cont;
        Contact cont1 = new contact(FirstName='FirstName201',lastName = 'testAdmin201', accountid = acc.id, External_Email__c = 'test1@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100);
        insert cont1;
         Contact cont2 = new contact(FirstName='FirstName401',lastName = 'testAdmin401', accountid = acc.id, External_Email__c = 'test2@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver',Manager__c=cont1.id, Monthly_Mileage_Limit__c = 100);
        insert cont2;
        List<Gas_Prices__c> obj_Gas_Prices = new List<Gas_Prices__c>();

        Gas_Prices__c gasPr = new Gas_Prices__c();
        
        gasPr.Fuel_Price__c = 1234 ;
        gasPr.Month_Year__c = date.newInstance(2018,11,02);
        gasPr.State__c = 'CA';
        gasPr.City__c ='testCity'; 
        
        insert gasPr;
        obj_Gas_Prices.add(gasPr);

        User u1 = [select id from user where Email='test1@gmail.com'];
       
           System.runAs(u1) {
              
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        
        empReim.Contact_Id__c = cont2.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 1234;
        empReim.MPG__c = 4567;
        empReim.Month__c =  ilmr.getLastMonthValue(-1);
        
        insert empReim;
       // Employee_Reimbursement__c reimburse = TestUtilityClass.getTestEmployeeReimbursement3(cont2);
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement = new List<Employee_Reimbursement__c>();
        obj_Employee_Reimbursement.add(empReim);
        Employee_Mileage__c mileage = TestUtilityClass.getTestEmployeeMileage2(empReim);
        mileage.Trip_Date__c  = System.today();
        mileage.approved_Date__c = null;
        mileage.Rejected__c = false;
        update mileage;
      
        
        
        RG_UnApprovedRecordsClass unApprovedRecord = new RG_UnApprovedRecordsClass();
        RG_UnApprovedRecordsClass.RembWrap obj_RembWrap = new RG_UnApprovedRecordsClass.RembWrap(obj_Employee_Reimbursement,false,false,obj_Gas_Prices);
        unApprovedRecord.wraplist.add(obj_RembWrap);
        for(RG_UnApprovedRecordsClass.RembWrap r:unApprovedRecord.wraplist)
        {
            r.isCheck = true;
        }
        unApprovedRecord.emailAddress.add('test1@gmail.com');
        unApprovedRecord.emailAddress.add('test2@gmail.com');
        unApprovedRecord.sendEmail();
        unApprovedRecord.UpdateRecord();
        RG_UnApprovedRecordsClass.getcurrentUserCompanyId();
        }
    }
    public static testmethod void Testmethod3() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Manager'];

        Account acc = TestUtilityClass.getTestSingleAccount();
        acc.Lock_date__c  = System.today();
        update acc;

        
        Contact cont = new contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acc.id, External_Email__c = 'test@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Monthly_Mileage_Limit__c = 100);
        insert cont;
        Contact cont1 = new contact(FirstName='FirstName201',lastName = 'testAdmin201', accountid = acc.id, External_Email__c = 'test1@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager',Manager__c=cont.id, Monthly_Mileage_Limit__c = 100);
        insert cont1;
         Contact cont2 = new contact(FirstName='FirstName401',lastName = 'testAdmin401', accountid = acc.id, External_Email__c = 'test2@gmail.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'CA', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Driver',Manager__c=cont1.id, Monthly_Mileage_Limit__c = 100);
        insert cont2;
        User u1 = [select id from user where Email='test1@gmail.com'];
        
           System.runAs(u1) {
              
      
        
        
        Employee_Reimbursement__c reimburse = TestUtilityClass.getTestEmployeeReimbursement3(cont2);
        reimburse.approved_Date__c = null;
        update reimburse;
         
        Employee_Mileage__c mileage = TestUtilityClass.getTestEmployeeMileage2(reimburse);
        mileage.Trip_Date__c  = System.today();
        mileage.approved_Date__c = null;
        mileage.Rejected__c = false;
        update mileage;
        
      
        Gas_Prices__c gasPrice = TestUtilityClass.getTestGasPrices();
        gasPrice.Month_Year__c = Date.today().addmonths(-1).tostartofmonth();
        update gasPrice;
        
        RG_UnApprovedRecordsClass unApprovedRecord = new RG_UnApprovedRecordsClass();
        unApprovedRecord.drsIDs.add(cont2.id);
        unApprovedRecord.sendEmail();
        unApprovedRecord.UpdateRecord();
        RG_UnApprovedRecordsClass.getcurrentUserCompanyId();
        }
    }
}