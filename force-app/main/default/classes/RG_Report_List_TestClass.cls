/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class RG_Report_List_TestClass {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        account acc = new account(name='portalaccount');
        insert acc;
        contact portalContact = new contact(LastName = 'ManagerTest', AccountId = acc.Id,External_Email__c='abc@abc.com',Monthly_Mileage_Limit__c=120);
        
        insert portalContact;
        Custom_Report__c cReport = new Custom_Report__c(Report_Soql__c='select name from Employee_Reimbursement__c');
        
        insert cReport;
         Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Manager'];
        
        
        User u1 = new User( email='testCommUser@gmail.com',
                profileid = p.id, 
                UserName='testCommUser@gmail.com', 
                Alias = 'GDS',
                TimeZoneSidKey='America/New_York',
                EmailEncodingKey='ISO-8859-1',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US',
                ContactId = portalContact.Id,
                PortalRole = 'Manager',
                FirstName = 'testComm',
                LastName = 'User');
        
        System.runAs(u1){
        Report_Accessibility__c rA = new Report_Accessibility__c(Custom_Report__c=cReport.id, User__c=u1.id);
        insert rA;
            RG_Reports_List_Page_Class rR = new RG_Reports_List_Page_Class();
    }
        }
}