/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : Test class coverage for TrueDialogReceiveMessage
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/

@isTest
public class TrueDialogReceiveMessageTest {

    @isTest 
    public static void testReceiveMessageTest() {
        // Call the method to test
        Test.setMock(HttpCalloutMock.class, new TrueDialogMockCallout());   
        Test.startTest();
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        
        Vehicle_URL_Mapping__c vehicleType = TestDataFactory.createVehicleData(false, 3);
        vehicleType.Name = '2019 Full-Size Sedan';
        vehicleType.vehicle__c = 'Full-Size Sedan';
        Insert vehicleType;

        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);

        Account a = TestDataFactory.createAccount(true, 'demo', false);
        
        Contact c  = TestDataFactory.createCICDContact(false, a.id);
        
        c.email ='test@gmail.com';
        c.MobilePhone = '1239638840';
        c.lastName = 'Veer';
        c.firstName ='Sharma';
        c.External_Email__c='test@gmail.com';
        c.TrueDialog_Contact_Id__c = '81071892';
        
        insert c;

        String requestBody = '{ "MessageId": "d78b790f-798e-4215-86d1-1d00a5e6815a", "AccountName": "mBurse", "Message": "<media type=\\"image/jpg\\">d824fce2-cfe5-4b54-b181-f60472fb86c9681982515.jpg</media>", "ChannelId": 22, "ContactId": 81071892, "PhoneNumber": "+13239638840", "ChannelCode": "+19705100114", "ActionId": 117756672, "Media": [], "AccountId": 18409, "CallbackTimestamp": "2022-06-29T02:52:01", "CallbackToken": "bd054ccb-372b-40d3-a304-26cd540b4768", "CallbackType": 11, "CallbackURL": "https://eo3padl7dt1obtv.m.pipedream.net", "TransactionId": "107cdfe3-a0f7-44f7-b940-e2cc00ff8330", "CustomHeaders": {}, "Id": null, "DequeueCount": 0, "Priority": 0 }';
        
        RestRequest request = new RestRequest();
        request.requestUri = 'https://partialdev-gasmanager.cs220.force.com/truedialog/services/apexrest/api/webhook';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;
        
        TrueDialogReceiveMessage.insertMessage();
        Test.stopTest();
        
        
        
        requestBody = '{ "MessageId": "d78b790f-798e-4215-86d1-1d00a5e6815a", "AccountName": "mBurse", "Message": "<media type=\\"image/jpg\\">d824fce2-cfe5-4b54-b181-f60472fb86c9681982515.jpg</media><text>This is Will again </text>", "ChannelId": 22, "ContactId": 81071892, "PhoneNumber": "+13239638840", "ChannelCode": "+19705100114", "ActionId": 117756672, "Media": [], "AccountId": 18409, "CallbackTimestamp": "2022-06-29T02:52:01", "CallbackToken": "bd054ccb-372b-40d3-a304-26cd540b4768", "CallbackType": 11, "CallbackURL": "https://eo3padl7dt1obtv.m.pipedream.net", "TransactionId": "107cdfe3-a0f7-44f7-b940-e2cc00ff8330", "CustomHeaders": {}, "Id": null, "DequeueCount": 0, "Priority": 0 }';
   
        
        request.requestUri = 'https://partialdev-gasmanager.cs220.force.com/truedialog/services/apexrest/api/webhook';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res1 = new RestResponse();
        RestContext.request = request;
        RestContext.response = res1;
        
        TrueDialogReceiveMessage.insertMessage();
    }
}