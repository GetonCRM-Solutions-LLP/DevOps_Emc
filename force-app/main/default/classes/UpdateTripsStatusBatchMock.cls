/*
    @Description: Reject Trips callout and Mock test class for updatestatusBatchclass callout
*/
@isTest
global class UpdateTripsStatusBatchMock implements HttpCalloutMock {
    

    global static HTTPResponse respond(HTTPrequest request) {
        HttpResponse  response = new HttpResponse();
        
        response.setHeader('Content-Type', 'application/json');
        
        String resbody = '{' + 
            '"message": "OK",' + 
            '"successfulIds": [967235],' + 
            '"unsuccessfulIds": [967238],' +
        '}';
        
        response.setBody(resbody);      
        response.setStatusCode(200);
        return response;
    }
}