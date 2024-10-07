@isTest
public class ExecuteQueryUtil_Test{
    public static testmethod void utilMethod(){
    	
    	Account obj_account = new Account();
    	obj_account.name='Test';
    	insert obj_account;

    	Contact obj_contactmanager = new Contact();
        obj_contactmanager.firstname='test';
        obj_contactmanager.lastname='testlastname1';
        obj_contactmanager.email = 'testlastname1@gmail.com';
        obj_contactmanager.External_Email__c = 'testlastname1@gmail.com';
        obj_contactmanager.Role__c ='Manager';
        obj_contactmanager.Accountid=obj_account.id;
        insert obj_contactmanager;

        Contact obj_contact = new Contact();
        obj_contact.firstname='test';
        obj_contact.lastname='testlastname2';
        obj_contact.email = 'testlastname2@gmail.com';
        obj_contact.External_Email__c = 'testlastname2@gmail.com';
        obj_contact.Role__c ='Driver';
        obj_contact.Accountid=obj_account.id;
        obj_contact.Manager__c = obj_contactmanager.id;
        
        insert obj_contact;

        String query = 'select id,name from contact LIMIT 10';
        Map<id,sObject> obj_map = new Map<id,sObject>();
        ExecuteQueryUtil equ = new ExecuteQueryUtil();
        ExecuteQueryUtil.getIDListFromsObject(query);
        ExecuteQueryUtil.getListFromMap(obj_map);
        ExecuteQueryUtil.getRecordMapWithSinglesObject(query);
        ExecuteQueryUtil.getRecordMapWithMultiplesObject(query);
    }
}