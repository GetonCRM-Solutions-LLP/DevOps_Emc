public with sharing class GoogleAPICallouts {

    @AuraEnabled
    public static String getDistance(String address) {
        String result = '';
        String googleMapAPIKey = System.Label.Google_Map_API_Key;
        String baseURL = StaticValues.GOOGLEMAP_DISTANCEMATRIX_BASEURL;

        AddressWrapper addressWrapper = new AddressWrapper();
        addressWrapper = (AddressWrapper) System.JSON.deserialize(address, AddressWrapper.class);

        addressWrapper.origins = addressWrapper.origins.replaceAll(' ', '%20');
        addressWrapper.destinations = addressWrapper.destinations.replaceAll(' ', '%20');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseURL+''+addressWrapper.origins+'&destinations='+addressWrapper.destinations+'&mode=driving&key='+googleMapAPIKey);
        req.setMethod('GET');

        try {
            HttpResponse res = h.send(req);

            String bodyResponse = res.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(bodyResponse);
            String status = (String) responseMap.get('status');

            if(status == 'OK') {
                List<Object> rows = (List<Object>) responseMap.get('rows');
                Map<String, Object> row = (Map<String, Object>) rows[0];
                List<Object> elements = (List<Object>) row.get('elements');
                if (!elements.isEmpty()) {
                    Map<String, Object> element = (Map<String, Object>) elements[0];
                    String statusCalculations = (String) element.get('status');
                    if(statusCalculations == 'OK') {
                        Map<String, Object> distance = (Map<String, Object>) element.get('distance');
                        Decimal distanceValue = (Decimal) distance.get('value');
                        distanceValue = (distanceValue * 0.000621371).setScale(2);
                        System.debug('Distance Value: ' + distanceValue);

                        Map<String, Object> duration = (Map<String, Object>) element.get('duration');
                        Integer durationValueInSeconds = (Integer) duration.get('value');
                        Integer durationValueInMinutes = Integer.valueOf(durationValueInSeconds / 60);
                        System.debug('durationValueInMinutes Value: ' + durationValueInMinutes);

                        DistanceDurationWrapper objDisDurWrapper = new DistanceDurationWrapper();
                        objDisDurWrapper.distance = String.valueOf(distanceValue);
                        objDisDurWrapper.duration = String.valueOf(durationValueInMinutes);

                        result = JSON.serialize(objDisDurWrapper);
                    } else {
                        result = 'Failure';
                    }
                }
            } else {
                result = 'Failure';
            }
        } catch (Exception e) {
            System.debug('Exception : ' + e);
            result = 'Failure';
        }
        return result;
    }

    @AuraEnabled
    public static String getLatLong(String zipCode) {
        String result = '';
        String googleMapAPIKey = System.Label.Google_Map_API_Key;
        String baseURL = StaticValues.GOOGLEMAP_GEOCODE_BASEURL;
        LatLongWrapper latLongWrapper = new LatLongWrapper();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseURL+''+zipCode+'&key='+googleMapAPIKey);
        req.setMethod('GET');

        try {
            HttpResponse res = h.send(req);
            String bodyResponse = res.getBody();
            Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(bodyResponse);
            String status = (String) jsonResponseMap.get('status');

            List<Object> results = (List<Object>) jsonResponseMap.get('results');
            if (!results.isEmpty() && status == 'OK') {
                Map<String, Object> resultObj = (Map<String, Object>) results[0];
                Map<String, Object> geometry = (Map<String, Object>) resultObj.get('geometry');
                Map<String, Object> location = (Map<String, Object>) geometry.get('location');

                Decimal latitude = (Decimal) location.get('lat');
                Decimal longitude = (Decimal) location.get('lng');
                latLongWrapper.lati = latitude;
                latLongWrapper.longi = longitude;
                result = JSON.serialize(latLongWrapper);
            } else {
                result = 'Failure';
            }
        } catch (Exception e) {
            System.debug('Exception : ' + e);
            result = 'Failure';
        }
        return result;
    }

    public class AddressWrapper{
        public String origins{get;set;}
        public String destinations{get;set;}
    }

    public class LatLongWrapper{
        public Decimal lati{get;set;}
        public Decimal longi{get;set;}
    }

    public class DistanceDurationWrapper{
        public String distance{get;set;}
        public String duration{get;set;}
    }

}