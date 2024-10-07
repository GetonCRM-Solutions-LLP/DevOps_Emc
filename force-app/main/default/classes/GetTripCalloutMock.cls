@isTest
global class GetTripCalloutMock implements HttpCalloutMock {
    
    global static HTTPResponse respond(HTTPrequest request) {
        HttpResponse  response = new HttpResponse();
        //response.setheader('Authorization', 'authorizationHeader');
        response.setHeader('Content-Type', 'application/json');
        String resbody = '{'+
            '"message": "OK",' +
            '"trips": ['+
                '{'+
                '"id": 61829058,'+
                '"url": "https://triplogmileage.com/web/api/trips/61829058",'+
                '"lastUpdated": "2017-12-05T17:30:22.596Z",'+
                    '"user": {'+
                        ' "id": 132913,'+
                        '"url": "https://triplogmileage.com/web/api/users/132913",'+
                        '"email": "shakeel.shaikh@deltaww.com",'+
                        '"display": "Shaikh, Shakeel"'+
                    '},'+
                    '"vehicle": {'+
                        '"id": 190414,'+
                        '"url": "https://triplogmileage.com/web/api/vehicles/190414",'+
                        '"lastUpdated": "2017-03-22T16:56:07.032Z",'+
                        '"display": "2012 Acura TL"'+
                    '},'+
                    '"startTime": "2021-12-05T17:30:00.000Z",'+
                    '"endTime": "2021-12-05T17:30:00.000Z",'+
                    '"startOdometer": 64114,'+
                    '"endOdometer": 64165,'+
                    '"mileage": 51,'+
                    '"fromLocation": {'+
                        '"id": 106149130,'+
                        '"url": "https://triplogmileage.com/web/api/locations/106149130",'+
                        '"lastUpdated": "2017-03-25T19:04:58.080Z",'+
                        '"display": "Home Office"'+
                    '},'+
                    '"toLocation": {'+
                        '"id": 108746995,'+
                        '"url": "https://triplogmileage.com/web/api/locations/108746995",'+
                        '"lastUpdated": "2017-06-12T19:40:42.826Z",'+
                        '"display": "International Paper"'+
                    '},'+
                    '"activity": "Business",'+
                    '"parking": 0,'+
                    '"toll": 0,'+
                    '"tags": "",'+
                    '"notes": "",'+
                    '"status": null,'+
                    '"statusUpdateTime": null,'+
                    '"statusUpdatedBy": null,'+
                    '"polyline": null,'+
                    '"route": "https://triplogmileage.com/web/api/trips/61829058/routes",'+
                    '"receipts": "https://triplogmileage.com/web/api/trips/61829058/receipts",'+
                    '"map": "http://trplg.co/k/2ul7dt01c",'+
                    '"trackingMethod": "Updated from the app"'+
                    ' }]}';
        response.setBody(resbody);      
        response.setStatusCode(200);
        return response;
    }
}