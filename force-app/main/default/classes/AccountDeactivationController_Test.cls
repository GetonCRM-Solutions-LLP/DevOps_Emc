@isTest
public class AccountDeactivationController_Test
{
    public static testmethod void AccountDeactivationController_Testmethod1()
    {
        list<account> acclist = new  list<account>();
        for(integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        Insert acclist;
        
        list<contact> conlist = new  list<contact>();
        
        
        conlist.add(new  contact(FirstName='FirstName201',lastName = 'testManager201', accountid = acclist[0].id, External_Email__c = 'test_Managr101@test99.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100));
       // conlist.add(new  contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acclist[0].id, External_Email__c = 'test_Admin1@test089.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Monthly_Mileage_Limit__c = 100));
        Insert conlist;
        
        
        list<Gas_Prices__c> gaslist = new  list<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) 
        {
            gaslist.add(new  Gas_Prices__c(City__c = 'Delhi' + i, Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 't' + i));
        }
        Insert gaslist;
        
        PageReference pageRef = Page.DeactivateUser;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(acclist[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acclist[0]);
        AccountDeactivationController obj_AccountDeactivationController = new AccountDeactivationController(sc);
        
        obj_AccountDeactivationController.calldeactivebatch();
        obj_AccountDeactivationController.backtoAccount();
    }
}