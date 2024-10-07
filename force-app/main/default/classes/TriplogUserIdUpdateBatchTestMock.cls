@isTest
global class TriplogUserIdUpdateBatchTestMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        String json = '{'+
        '    \"message\": \"OK\",'+
        '    \"users\": ['+
        '        {'+
        '            \"id\": 120570,'+
        '            \"url\": \"https://triplogmileage.com/web/api/users/120570\",'+
        '            \"email\": \"test@gmail.com\",'+
        '            \"display\": \"Chiu, Doris\",'+
        '            \"firstName\": \"Doris\",'+
        '            \"lastName\": \"Chiu\",'+
        '            \"phone\": null,'+  
		'            \"timeZone\": \"sun.util.calendar.ZoneInfo[id=\\\"US/Pacific\\\",offset=-28800000,dstSavings=3600000,useDaylight=true,transitions=185,lastRule=java.util.SimpleTimeZone[id=US/Pacific,offset=-28800000,dstSavings=3600000,useDaylight=true,startYear=0,startMode=3,startMonth=2,startDay=8,startDayOfWeek=1,startTime=7200000,startTimeMode=0,endMode=3,endMonth=10,endDay=1,endDayOfWeek=1,endTime=7200000,endTimeMode=0]]\",'+
        '            \"employeeId\": null,'+
        '            \"dept\": null,'+
        '            \"supervisor\": null,'+
        '            \"admin\": false,'+
        '            \"masterAdmin\": false,'+
        '            \"driver\": true,'+
        '            \"accountant\": false,'+
        '            \"locked\": false,'+
        '            \"disabled\": true,'+
        '            \"dailyMileageExemption\": 0,'+
        '            \"mileageRate\": 0,'+
        '            \"exemptionOnlyWeekdays\": false,'+
        '            \"lastSynced\": \"2019-02-04T09:52:01.900Z\",'+
        '            \"appVersion\": \"iOS v7.0.1\",'+
        '            \"appSettings\": \"iOS v7.0.1. Auto start:Off. Business hours:9:00 AM - 6:00 PM Business. After hours:Personal.\",'+
        '            \"vehicles\": \"https://triplogmileage.com/web/api/users/120570/vehicles\",'+
        '            \"locations\": \"https://triplogmileage.com/web/api/users/120570/locations\",'+
        '            \"currentLocation\": \"https://triplogmileage.com/web/api/users/120570/currentLocation\"'+
        '        }'+        
        '    ]'+
        '}';

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(200);
        return response;
 
    }
   
}