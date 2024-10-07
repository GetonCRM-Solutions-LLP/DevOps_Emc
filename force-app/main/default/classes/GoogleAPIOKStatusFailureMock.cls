@isTest
global class GoogleAPIOKStatusFailureMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"destination_addresses" : ["Bypass, NYATI EMPIRE, Mundhwa - Kharadi Rd, Santipur, Thite Nagar, Kharadi, Pune, Maharashtra 411014, India"],"origin_addresses" : ["Porwal Rd, Kutwal Colony, Lohegaon, Pune, Maharashtra 411047, India"],"rows" : [{"elements" : [{"distance" : {"text" : "11.3 km","value" : 11290},"duration" : {"text" : "33 mins","value" : 1986},"status" : "OK"}]}],"status" : "ERROR"}');
        response.setStatusCode(200);
        return response;
    }
}