@IsTest
public class TripLogJSONPost_Test {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"message\": \"OK\",'+
        '    \"user\": '+
        '{'+
        '        \"id\": 205597,'+
        '        \"url\": \"https://triplogmileage.com/web/api/users/205597\",'+
        '        \"email\": \"testtl42426@gmail.com\",'+
        '        \"display\": \"test, tl\",'+
        '        \"firstName\": \"tl\",'+
        '        \"lastName\": \"test\",'+
        '        \"phone\": \"1234599067\",'+
        '        \"employeeId\": null,'+
        '        \"dept\": null,'+
        '        \"supervisor\": null,'+
        '        \"admin\": false,'+
        '        \"driver\": true,'+
        '        \"accountant\": false,'+
        '        \"locked\": false,'+
        '        \"disabled\": false,'+
        '        \"dailyMileageExemption\": 0,'+
        '        \"mileageRate\": 0,'+
        '        \"exemptionOnlyWeekdays\": false,'+
        '        \"lastSynced\": null,'+
        '        \"vehicles\": \"https://triplogmileage.com/web/api/users/205597/vehicles\",'+
        '        \"locations\": \"https://triplogmileage.com/web/api/users/205597/locations\",'+
        '        \"currentLocation\": \"https://triplogmileage.com/web/api/users/205597/currentLocation\"'+
        '    }'+
        '}';
        TripLogJSONPost r = TripLogJSONPost.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        TripLogJSONPost.User objUser = new TripLogJSONPost.User(System.JSON.createParser(json));
        System.assert(objUser != null);
        System.assert(objUser.id == null);
        System.assert(objUser.url == null);
        System.assert(objUser.email == null);
        System.assert(objUser.display == null);
        System.assert(objUser.firstName == null);
        System.assert(objUser.lastName == null);
        System.assert(objUser.phone == null);
        System.assert(objUser.employeeId == null);
        System.assert(objUser.dept == null);
        System.assert(objUser.supervisor == null);
        System.assert(objUser.admin == null);
        System.assert(objUser.driver == null);
        System.assert(objUser.accountant == null);
        System.assert(objUser.locked == null);
        System.assert(objUser.disabled == null);
        System.assert(objUser.dailyMileageExemption == null);
        System.assert(objUser.mileageRate == null);
        System.assert(objUser.exemptionOnlyWeekdays == null);
        System.assert(objUser.lastSynced == null);
        System.assert(objUser.vehicles == null);
        System.assert(objUser.locations == null);
        System.assert(objUser.currentLocation == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        TripLogJSONPost objTripLogJSONPost = new TripLogJSONPost(System.JSON.createParser(json));
        System.assert(objTripLogJSONPost != null);
        System.assert(objTripLogJSONPost.message == null);
        System.assert(objTripLogJSONPost.user == null);
    }
}