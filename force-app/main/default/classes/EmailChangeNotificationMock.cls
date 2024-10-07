@isTest
public class EmailChangeNotificationMock implements HttpCalloutMock {

    private Integer statusCode;


    public EmailChangeNotificationMock(){
        this.statusCode = null;
    }
    public EmailChangeNotificationMock(Integer statusCode){
        this.statusCode = statusCode;
    }

    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"message":"OK","user":{"id":20002459,"url":"https://app.mburse.com/web/api/users/20002459","email":"janak0786@gmail.com","display":"Patel, Minkesh","firstName":"Minkesh","lastName":"Patel","phone":"3412063529","locale":"en_US","timeZone":"US/Mountain","employeeId":null,"dept":null,"supervisor":null,"admin":true,"masterAdmin":true,"driver":true,"accountant":false,"locked":false,"disabled":false,"dailyMileageExemption":0.0,"mileageRate":0.0,"exemptionOnlyWeekdays":false,"driversLicenseNumber":null,"lastSynced":"2024-06-02T10:32:22.374Z","appVersion":"Android v1.1.15","appSettings":"Android v1.1.15. Auto start:Magic. Business hours: Business. After hours:Personal.","vehicles":"https://app.mburse.com/web/api/users/20002459/vehicles","locations":"https://app.mburse.com/web/api/users/20002459/locations","currentLocation":"https://app.mburse.com/web/api/users/20002459/currentLocation"}}');

        if(statusCode == 200){
            response.setStatusCode(200);
        }else if(statusCode == 400){
            response.setStatusCode(400);
        }else if(statusCode == 404){
            response.setStatusCode(404);
        }else if(statusCode == 401){
            response.setStatusCode(401);
        }else if(statusCode == 500){
            response.setStatusCode(500);
        }
        return response;
    }
}