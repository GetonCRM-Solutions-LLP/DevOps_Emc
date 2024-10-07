@isTest
public class RG_Contact_Attachment_Test {
    static testmethod void myTest () {
        
        //inserting Account
        Account acc = new Account(Name = 'AccTest');
        insert acc;
        
        //inserting list of Contacts
        List<Contact> conList = new List<Contact>();
        conList.add(new contact(LastName = 'ConTest1', AccountId = acc.id, External_Email__c = 'con1@gmail.com'));
        conList.add(new contact(LastName = 'ConTest2', AccountId = acc.id, External_Email__c = 'con2@gmail.com'));
        conList.add(new contact(LastName = 'ConTest3', AccountId = acc.id, External_Email__c = 'con3@gmail.com'));
        insert conList;
        
        List<Attachment> attachList = new List<Attachment>();
        attachList.add(new attachment(name = 'attachTest', body = Blob.valueOf('attachmnet body'), ParentId = conList.get(0).id));
        attachList.add(new attachment(name = 'attachTest', body = Blob.valueOf('attachmnet body'), ParentId = conList.get(1).id));
        attachList.add(new attachment(name = 'attachTest', body = Blob.valueOf('attachmnet body'), ParentId = conList.get(0).id));
        attachList.add(new attachment(name = 'attachTest', body = Blob.valueOf('attachmnet body'), ParentId = acc.id));
        insert attachList;
    }
}