/***************************************************************************************************************************************
 * this test class is created for the Address trigger coverage   
 ****************************************************************************************************************************************/
@isTest
public class AddressTriggerTest {
    
    @isTest
    static void testAddress() {
        //TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        // Create a TriggerConfig__c custom setting
        TriggerConfig__c customSetting = new TriggerConfig__c(
            Name = 'Defaulttrigger',
            AddressTrigger__c = true 
        );
        insert customSetting;

        Address__c address = new Address__c(
            State__c = 'California',
            City__c = 'San Francisco',
            ZIP_Code__c = '94101'
        );
        insert address;
        checkRecursive.setting_run(true);
        address.City__c = 'Albany';
        update address;
    }
}