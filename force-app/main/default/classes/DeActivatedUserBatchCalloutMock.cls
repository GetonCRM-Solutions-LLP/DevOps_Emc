@isTest
global class DeActivatedUserBatchCalloutMock implements HttpCalloutMock {
    global static HTTPResponse respond(HTTPrequest request) {
        HttpResponse  response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String resbody = '{\"users\":['+
        '{\"id\":120570,\"url\":\"https://triplogmileage.com/web/api/users/120570\",\"email\":\"doris.chiu@deltaww.com\",\"display\":\"Chiu, Doris\",\"firstName\":\"Doris\",\"lastName\":\"Chiu\",\"phone\":null,\"employeeId\":null,\"dept\":null,\"supervisor\":null,\"admin\":false,\"masterAdmin\":false,\"driver\":true,\"accountant\":false,\"locked\":false,\"disabled\":true,\"dailyMileageExemption\":0.0,\"mileageRate\":0.0,\"exemptionOnlyWeekdays\":false,\"lastSynced\":\"2018-02-07T23:34:12.600Z\",\"vehicles\":\"https://triplogmileage.com/web/api/users/120570/vehicles\",\"locations\":\"https://triplogmileage.com/web/api/users/120570/locations\",\"currentLocation\":\"https://triplogmileage.com/web/api/users/120570/currentLocation\"},{\"id\":126144,\"url\":\"https://triplogmileage.com/web/api/users/126144\",\"email\":\"deltadriverservices@askemc.com\",\"display\":\"Services, Driver\",\"firstName\":\"Driver\",\"lastName\":\"Services\",\"phone\":null,\"employeeId\":null,\"dept\":null,\"supervisor\":null,\"admin\":true,\"masterAdmin\":true,\"driver\":true,\"accountant\":true,\"locked\":false,\"disabled\":false,\"dailyMileageExemption\":0.0,\"mileageRate\":0.0,\"exemptionOnlyWeekdays\":false,\"lastSynced\":\"2018-10-12T00:56:51.605Z\",\"vehicles\":\"https://triplogmileage.com/web/api/users/126144/vehicles\",\"locations\":\"https://triplogmileage.com/web/api/users/126144/locations\",\"currentLocation\":\"https://triplogmileage.com/web/api/users/126144/currentLocation\"}]}';
        response.setBody(resbody);      
        response.setStatusCode(200);
        return response;
    }
}