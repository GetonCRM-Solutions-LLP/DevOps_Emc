@isTest
global class LoadMileageLocationBatchTestMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        String json = '{'+
		'    \"message\": \"OK\",'+
		'    \"location\": {'+
		'        \"id\": 143316643,'+
		'        \"url\": \"https://triplogmileage.com/web/api/locations/143316643\",'+
		'        \"lastUpdated\": \"2020-04-01T19:32:17.753Z\",'+
		'        \"display\": \"33.182021,-96.748293\",'+
		'        \"name\": null,'+
		'        \"address\": null,'+
		'        \"latitude\": 33.182021,'+
		'        \"longitude\": -96.748293,'+
		'        \"accuracy\": 5,'+
		'        \"defaultActivity\": null'+
		'    }'+
		'}';

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(200);
        return response;
 
    }
   
}