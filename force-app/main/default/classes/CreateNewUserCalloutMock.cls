/***********************************************
Description: Test Mock class for HTTPPOST method
***********************************************/
@isTest
global class CreateNewUserCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPrequest request) {
        HttpResponse  response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        string resbody = '{'+
                           ' "message": "OK",'+
                           ' "user": { '+
                              '  "id": 205652, '+
                              '  "url": "https://triplogmileage.com/web/api/users/205652", '+
                              '  "email": "testtl421426@gmail.com", '+
                              '  "display": "test, tl", '+
                              '  "firstName": "tl", '+
                              '  "lastName": "test", '+
                              '  "phone": "1234599067", '+
                              '  "employeeId": null, '+
                              '  "dept": null, '+
                              '  "supervisor": null, '+
                              '  "admin": false, '+
                              '  "driver": true, '+
                              '  "accountant": false, '+
                              '  "locked": false, '+
                              '  "disabled": false, '+
                              '  "dailyMileageExemption": 0, '+
                              '  "mileageRate": 0, '+
                              '  "exemptionOnlyWeekdays": false, '+
                              '  "lastSynced": null, '+
                              '  "vehicles": "https://triplogmileage.com/web/api/users/205652/vehicles", '+
                              '  "locations": "https://triplogmileage.com/web/api/users/205652/locations", '+
                              '  "currentLocation": "https://triplogmileage.com/web/api/users/205652/currentLocation" '+
                          ' }} ';
        response.setBody(resbody);      
        response.setStatusCode(200);
        return response;
    }
}