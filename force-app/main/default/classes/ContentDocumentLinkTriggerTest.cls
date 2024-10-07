@isTest
public class ContentDocumentLinkTriggerTest {
    
    @isTest
    static void testTriggerLogic() {
        // Create a test ContentDocumentLink with the specified conditions
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting1 = TestDataFactory.sendEmailCustomSetting(true,'Send Email For Compliance');
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        Account acc = new Account();
        List<Contact> conList = new List<Contact>();
        System.runAs(admin) {
            acc = TestDataFactory.createAccount(false,'Test',true);
            acc.Vehicle_Types__c=vehicleObj.name;
            acc.True_Dialog__c = true;
            acc.Vehicle_Types__c = vehicleObj.Name;
            Insert acc;
            conList = TestDataFactory.createDriverContact(true, acc.Id, 'Driver', vehicleObj.Name, 'test.email', 1);
        }
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Driver Agreement.pdf   ',
            VersionData = Blob.valueOf('Test Content'),
            PathOnClient = 'Driver Agreement.pdf'
        );
        insert testContentVersion;
        system.debug('testconversion'+testContentVersion);
        ContentDocument testContentDocument = [SELECT Id, LatestPublishedVersionId,LatestPublishedVersion.Title FROM ContentDocument];
        system.debug('ContentDocument'+testContentDocument.LatestPublishedVersion.Title);
        
    }
}