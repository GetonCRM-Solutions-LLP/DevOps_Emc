@isTest
global  with sharing class ChangeTripStatusinTripLogTestMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
    
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        Http putHTTP = new Http(); 
        HttpResponse putRes = new HttpResponse();
        HttpRequest putReq = new HttpRequest();  
        String json = '{'+
        '    \"message\": \"OK\",'+
        '    \"users\": ['+
        '        {'+
        '            \"id\": 333738,'+
        '            \"url\": \"https://triplogmileage.com/web/api/users/333738\",'+
        '            \"email\": \"eds@mburse.com\",'+
        '            \"display\": \"Barton, Ed\",'+
        '            \"firstName\": \"Ed\",'+
        '            \"lastName\": \"Barton\",'+
        '            \"phone\": null,'+
        '            \"employeeId\": null,'+
        '            \"dept\": null,'+
        '            \"supervisor\": null,'+
        '            \"admin\": true,'+
        '            \"masterAdmin\": true,'+
        '            \"driver\": false,'+
        '            \"accountant\": true,'+
        '            \"locked\": false,'+
        '            \"disabled\": false,'+
        '            \"dailyMileageExemption\": 0.0,'+
        '            \"mileageRate\": 0.0,'+
        '            \"exemptionOnlyWeekdays\": false,'+
        '            \"lastSynced\": \"2019-08-28T14:28:18.021Z\",'+
        '            \"appVersion\": null,'+
        '            \"appSettings\": null,'+
        '            \"vehicles\": \"https://triplogmileage.com/web/api/users/333738/vehicles\",'+
        '            \"locations\": \"https://triplogmileage.com/web/api/users/333738/locations\",'+
        '            \"currentLocation\": \"https://triplogmileage.com/web/api/users/333738/currentLocation\"'+
        '        }'+
        ']'+
        '}';
        putReq.setEndpoint('http://example.com/example/test');
        putReq.setMethod('PUT');                 
        putReq.setBody(json);
        //putReq.setTimeout(120000);
        putReq.setHeader('Authorization', 'apikey ');
        putRes = putHTTP.send(putReq);
    return putRes;
}
}