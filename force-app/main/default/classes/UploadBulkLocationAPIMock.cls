@isTest
Public class UploadBulkLocationAPIMock implements HttpCalloutMock {

    Public HTTPResponse respond(HTTPRequest request) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://app.mburse.com/web/api/locations', request.getEndpoint());
        System.assertEquals('POST', request.getMethod());
        
        // Create a fake response
        HttpResponse objResponse = new HttpResponse();
        objResponse.setHeader('Content-Type', 'application/json');
        objResponse.setBody('[{"userId":"20003599","name":"The White House","longitude":null,"latitude":null,"address":"abcd, adb, AR 11112","activity":"Business"}]');
        objResponse.setStatusCode(200);
        return objResponse;
    }
}