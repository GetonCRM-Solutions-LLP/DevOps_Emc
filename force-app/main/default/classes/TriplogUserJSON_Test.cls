@IsTest
public class TriplogUserJSON_Test {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"message\": \"OK\",'+
        '    \"users\": ['+
        '        {'+
        '            \"id\": 120570,'+
        '            \"url\": \"https://triplogmileage.com/web/api/users/120570\",'+
        '            \"email\": \"doris.chiu@deltaww.com\",'+
        '            \"display\": \"Chiu, Doris\"'+
        '        }]'+
        '}';
        TriplogUserJSON r = TriplogUserJSON.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        TriplogUserJSON objTriplogUserJSON = new TriplogUserJSON(System.JSON.createParser(json));
        System.assert(objTriplogUserJSON != null);
        System.assert(objTriplogUserJSON.message == null);
        System.assert(objTriplogUserJSON.users == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        TriplogUserJSON.Users objUsers = new TriplogUserJSON.Users(System.JSON.createParser(json));
        System.assert(objUsers != null);
        System.assert(objUsers.id == null);
        System.assert(objUsers.url == null);
        System.assert(objUsers.email == null);
        System.assert(objUsers.display == null);
    }
}