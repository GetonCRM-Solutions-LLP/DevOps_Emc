@isTest
public class SetLatLongOnAddressTest {
    @isTest
    static void testUpdateLatLong() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        Address__c testAddress = new Address__c(    
            City__c = 'Test City',
            State__c = 'TS', 
            ZIP_Code__c = '12345'
        );
        insert testAddress;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        List<String> ids = new List<String>{testAddress.Id};
        Test.startTest();
        SetLatLongOnAddress.updateLatLong(ids);
        SetLatLongOnAddress.fetchLatLong(testAddress.City__c,testAddress.State__c,testAddress.ZIP_Code__c,testAddress.Id);
        Test.stopTest();

        Address__c updatedAddress = [SELECT Id, Location_Lat_Long__Latitude__s, Location_Lat_Long__Longitude__s
                                     FROM Address__c WHERE Id = :testAddress.Id];
        //System.assertEquals(true, updatedAddress.Location_Lat_Long__Latitude__s != null);
       // System.assertEquals(true, updatedAddress.Location_Lat_Long__Longitude__s != null);
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"location": {"lat": 37.7749, "lng": -122.4194}}');
            response.setStatusCode(200);
            return response;
        }
    }
}