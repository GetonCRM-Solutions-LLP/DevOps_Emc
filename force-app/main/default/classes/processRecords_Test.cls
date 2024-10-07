@isTest
public class processRecords_Test {
    static testmethod void myTest () {
        
        //inserting Account
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Account acc = new Account(Name = 'AccTest');
        insert acc;
        
        //inserting Contact List
        List<Contact> conList = new List<Contact>();
        conList.add(new Contact(LastName = 'ConTest1', AccountId = acc.id, External_Email__c = 'con1@gmail.com'));
        conList.add(new contact(LastName = 'ConTest2', AccountId = acc.id, External_Email__c = 'con2@gmail.com'));
        conList.add(new contact(LastName = 'ConTest3', AccountId = acc.id, External_Email__c = 'con3@gmail.com'));
        insert conList;
        
        //inserting list of Reimbursement
        List<Employee_Reimbursement__c> reimbursementList = new List<Employee_Reimbursement__c>();
        reimbursementList.add(new Employee_Reimbursement__c(Name = 'TestReimburse1',Contact_Id__c = conList.get(0).id));
        reimbursementList.add(new Employee_Reimbursement__c(Name = 'TestReimburse2',Contact_Id__c = conList.get(1).id));
        reimbursementList.add(new Employee_Reimbursement__c(Name = 'TestReimburse3',Contact_Id__c = conList.get(0).id));
        insert reimbursementList; 
        
        //inserting list of Mileage
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        mileageList.add(new Employee_Mileage__c(Name = 'TestMileage1', Contact_Email_Id__c = 'mileage1@gmail.com', EmployeeReimbursement__c = reimbursementList.get(0).id));
        mileageList.add(new Employee_Mileage__c(Name = 'TestMileage1', Contact_Email_Id__c = 'mileage1@gmail.com', EmployeeReimbursement__c = reimbursementList.get(1).id));
        mileageList.add(new Employee_Mileage__c(Name = 'TestMileage1', Contact_Email_Id__c = 'mileage1@gmail.com', EmployeeReimbursement__c = reimbursementList.get(0).id));
        insert mileageList;
        
        //List of sObject to add cContact List, Reimbursement List & Mileage List
        List<sObject> sObjList = new List<sObject>();
        sObjList.addAll((List<sObject>)conList);
        sObjList.addAll((List<sObject>)reimbursementList);
        sObjList.addAll((List<sObject>)mileageList);
        
        List<Contact> conList2 = new List<Contact>();
        conList2.add(new Contact(LastName = 'ConTest1', AccountId = acc.id, External_Email__c = 'con1@gmail.com'));
        
        List<Employee_Reimbursement__c> reimbursementList2 = new List<Employee_Reimbursement__c>();
        reimbursementList2.add(new Employee_Reimbursement__c(Name = 'TestReimburse1',Contact_Id__c = conList2.get(0).id));
        
        List<Employee_Mileage__c> mileageList2 = new List<Employee_Mileage__c>();
        mileageList2.add(new Employee_Mileage__c(Name = 'TestMileage1', Contact_Email_Id__c = 'mileage1@gmail.com', EmployeeReimbursement__c = reimbursementList2.get(0).id));
        
        List<sObject> sObjList2 = new List<sObject>();
        sObjList2.addAll((List<sObject>)conList2);
        sObjList.addAll((List<sObject>)reimbursementList2);
        sObjList.addAll((List<sObject>)mileageList2);
        
        Test.startTest();
            processRecords obj = new processRecords(sObjList);
            DataBase.executeBatch(obj); 
            
            processRecords obj2 = new processRecords(sObjList2);
            DataBase.executeBatch(obj2); 
        Test.stopTest();
    }
}