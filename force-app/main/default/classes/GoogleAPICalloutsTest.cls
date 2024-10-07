@isTest
public class GoogleAPICalloutsTest {
	
    @isTest
    static void getDistanceTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GoogleAPICalloutsMock());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
		GoogleAPICallouts.AddressWrapper addressWrapper = new GoogleAPICallouts.AddressWrapper();
        addressWrapper.origins = '721 Broadway, New York, NY 10003';
        addressWrapper.destinations = '715 Broadway, New York, NY 10003';
        Test.startTest();
		String response = GoogleAPICallouts.getDistance(JSON.serialize(addressWrapper));
        Test.stopTest();
    }

    @isTest
    static void getDistanceOkStatusFailureTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GoogleAPIOKStatusFailureMock());
		GoogleAPICallouts.AddressWrapper addressWrapper = new GoogleAPICallouts.AddressWrapper();
        addressWrapper.origins = '721 Broadway, New York, NY 10003';
        addressWrapper.destinations = '715 Broadway, New York, NY 10003';
        Test.startTest();
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
		String response = GoogleAPICallouts.getDistance(JSON.serialize(addressWrapper));
        Test.stopTest();
    }

    @isTest
    static void GoogleAPIStatusCalculationsFailureTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GoogleAPIStatusCalculationsFailureMock());
		GoogleAPICallouts.AddressWrapper addressWrapper = new GoogleAPICallouts.AddressWrapper();
        addressWrapper.origins = '721 Broadway, New York, NY 10003';
        addressWrapper.destinations = '715 Broadway, New York, NY 10003';
        Test.startTest();
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
		String response = GoogleAPICallouts.getDistance(JSON.serialize(addressWrapper));
        Test.stopTest();
    }
    
    @isTest
    static void getDistanceCatchTest(){
        GoogleAPICallouts.AddressWrapper addressWrapper = new GoogleAPICallouts.AddressWrapper();
        addressWrapper.origins = '721 Broadway, New York, NY 10003';
        addressWrapper.destinations = '715 Broadway, New York, NY 10003';
        Test.startTest();
        GoogleAPICallouts.getDistance(JSON.serialize(addressWrapper));
        Test.stopTest();
    }

    @isTest
    static void getLatLongTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GoogleAPIGetLatLongMock());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
		GoogleAPICallouts.LatLongWrapper latLongWrapper = new GoogleAPICallouts.LatLongWrapper();
        latLongWrapper.lati = 40.729462;
        latLongWrapper.longi = -73.993568;
        Test.startTest();
		GoogleAPICallouts.getLatLong('10003');
        Test.stopTest();
    }

    @isTest
    static void getLatLongStatusFailureTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GoogleAPIGetLatLongStatusFailureMock());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
		GoogleAPICallouts.LatLongWrapper latLongWrapper = new GoogleAPICallouts.LatLongWrapper();
        latLongWrapper.lati = 40.729462;
        latLongWrapper.longi = -73.993568;
        Test.startTest();
		GoogleAPICallouts.getLatLong('10003');
        Test.stopTest();
    }

    @isTest
    static void getLatLongCatchTest() {
        Test.startTest();
		GoogleAPICallouts.getLatLong('10003');
        Test.stopTest();
    }
    
    

}