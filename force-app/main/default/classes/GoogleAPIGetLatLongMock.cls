@isTest
global class GoogleAPIGetLatLongMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"results" : [{"address_components" : [{"long_name" : "6789","short_name" : "6789","types" : ["street_number"]},{"long_name" : "Brittany Chase Court","short_name" : "Brittany Chase Ct","types" : ["route"]},{"long_name" : "Orlando","short_name" : "Orlando","types" : ["locality","political"]},{"long_name" : "Orange County","short_name" : "Orange County","types" : ["administrative_area_level_2","political"]},{"long_name" : "Florida","short_name" : "FL","types" : ["administrative_area_level_1","political"]},{"long_name" : "United States","short_name" : "US","types" : ["country","political"]},{"long_name" : "32810","short_name" : "32810","types" : ["postal_code"]},{"long_name" : "3613","short_name" : "3613","types" : ["postal_code_suffix"]}],"formatted_address" : "6789 Brittany Chase Ct, Orlando, FL 32810, USA","geometry" : {"bounds" : {"northeast" : {"lat" : 28.62119,"lng" : -81.4262622},"southwest" : {"lat" : 28.6210732,"lng" : -81.4264431}},"location" : {"lat" : 28.6211337,"lng" : -81.42633169999999},"location_type" : "ROOFTOP","viewport" : {"northeast" : {"lat" : 28.6224127802915,"lng" : -81.42489751970849},"southwest" : {"lat" : 28.61971481970849,"lng" : -81.42759548029152}}},"place_id" : "ChIJ7a9YFs1w54gRrjfH3OOYhD8","types" : ["premise"]}],"status" : "OK"}');
        response.setStatusCode(200);
        return response;
    }
}