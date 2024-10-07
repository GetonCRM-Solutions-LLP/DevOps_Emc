@isTest
global class NetchexDeleteMockclass implements HttpCalloutMock{
    global static HTTPResponse respond(HTTPrequest request) {
        HttpResponse  response = new HttpResponse();
        //response.setheader('Authorization', 'authorizationHeader');
        response.setHeader('Content-Type', 'application/json');
        String resbody = '{'+
        '"IsSuccess": true,' +
        '"Messages":[],' +
        '"ObjectInstance":{'+
        '"CompanyCode":"LIL",'+
        '"EntryDate":"2020-08-14T00:00:00Z",'+
        '"EmployeeId":"EAKING6",'+
        '"GrossToNetCode":"1",'+
        '"TypeCode":"R",'+
        '"HoursOrAmount":12.2,'+
        '"TemporaryRate":1.2,'+
        '"DistributedDivisionCode":000,'+
        '"DistributedBusinessUnitCode":000,'+
        '"DistributedDepartmentCode":001,'+
        '"WorkersCompCode":1,'+
        '"ProjectClientName":"mburse",'+
        '"ProjectName":"test"'+
        '}'+
        '}';
        response.setBody(resbody);      
        response.setStatusCode(200);
        return response;
}
}