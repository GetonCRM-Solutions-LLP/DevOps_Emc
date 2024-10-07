/**
* @File Name          : TestOnboardEmailAndInsuranceDriverPacket
* @Description        : sending email to driver by the status of insurance and driver package this is test class 
* @Author             : khuman singh 
**/
@isTest
public with sharing class TestOnboardEmailAndInsuranceDriverPacket {
    
    @TestSetup
    static void makeData(){

        List<Contact> contacts = new List<Contact>();
        Account acc = TestDataFactory.createAccount(true,'Test',true);
        acc.True_Dialog__c=false;
        update acc; 
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate = TestDataFactory.createIRSRate(true,0);
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2020 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;
        List<Contact> conList = TestDataFactory.createDriverContact(false, acc.Id,'Driver', vehicleType.Name , 'khuman.bhadoriya', 10);
        conList[0].FirstName='test';
        conList[0].LastName='Driver1';
        conList[0].packet__c='Sent to Driver';
        conList[0].insurance__c='Not Submitted';

        conList[1].FirstName='test';
        conList[1].LastName='Driver2';
        conList[1].packet__c='Driver Signed';
        conList[1].insurance__c='Insurance Card';

        conList[2].FirstName='test';
        conList[2].LastName='Driver3';
        conList[2].packet__c='Admin Signed';
        conList[2].insurance__c='Not Meeting Plan Minimum';

        conList[3].FirstName='test';
        conList[3].LastName='Driver4';
        conList[3].packet__c='Driver Signed';
        conList[3].insurance__c='Expired';

        conList[4].FirstName='test';
        conList[4].LastName='Driver5';
        conList[4].packet__c='Admin Signed';
        conList[4].insurance__c='No Expiration Date';

        conList[5].FirstName='test';
        conList[5].LastName='Driver6';
        conList[5].packet__c='Completed';
        conList[5].insurance__c='Not Submitted';

        conList[6].FirstName='test';
        conList[6].LastName='Driver7';
        conList[6].packet__c='Completed';
        conList[6].insurance__c='Insurance Card';

        conList[7].FirstName='test';
        conList[7].LastName='Driver8';
        conList[7].packet__c='Completed';
        conList[7].insurance__c='Not Meeting Plan Minimum';

        conList[8].FirstName='test';
        conList[8].LastName='Driver9';
        conList[8].packet__c='Completed';
        conList[8].insurance__c='Expired';
    
        conList[9].FirstName='test';
        conList[9].LastName='Driver10';
        conList[9].packet__c='Completed';
        conList[9].insurance__c='No Expiration Date';
       
        TriggerConfig__c triggerConfigCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        System.debug('printing custom setting values'+triggerConfigCustomSetting);
        insert conList;
    }
    
    @isTest
    static void testScheduledJob() {
        List<Contact> contacts = [SELECT Id,Role__c,Name,packet__c,insurance__c FROM Contact Where FirstName='Test'];
        Test.startTest();
        String jobId = System.schedule('Test Onboarding Email Job', '0 15 * * * ?', new OnboardingEmailAndInsuranceDriverPacket());
        Test.stopTest();

        
    }
}