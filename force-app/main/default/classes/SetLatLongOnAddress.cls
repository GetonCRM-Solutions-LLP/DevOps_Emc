public class SetLatLongOnAddress {
    @InvocableMethod(label='Set Lat and Long on Address' description='Update Latitude and Longtitude on Address fields' category='Address__c')
    public static void updateLatLong(List<String> ids){
      System.debug('Call Method from Flow');

        Address__c addresses = [SELECT Id,Name,City__c,State__c,ZIP_Code__c,Location_Lat_Long__c,Abbreviation__c from Address__c where Id =: ids[0]];
        System.debug('City__c: '+addresses.City__c);
        System.debug('State__c: '+addresses.Abbreviation__c);
        System.debug('ID: '+addresses.Id);
        if(!test.isrunningtest()){
            fetchLatLong(addresses.City__c,addresses.Abbreviation__c,addresses.ZIP_Code__c,addresses.Id);
        }
        
    }

    @future(callout=true)
    public static void fetchLatLong(String city,String state,String zipCode,String id){
        System.debug('City__c: '+city);
        System.debug('State__c: '+state);
        System.debug('ID: '+id);

        city = city.replaceAll(' ', '%20');
        state = state.replaceAll(' ', '%20');
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+city+'+'+state+'+'+zipCode+'&sensor=false&key=AIzaSyDnaP6tZBTFOCUpfNbCXMZwnLDTQ3aOrug');
        req.setMethod('GET');
        req.setTimeout(5000);

        try{
        // callout

            HttpResponse res = h.send(req);
            System.debug('res.getBody(): '+res.getBody());
            // parse coordinates from response
            JSONParser parser = JSON.createParser(res.getBody());
            System.debug('parser: '+parser);
            double lat = null;
            double lon = null;

            while (parser.nextToken() != null) {

                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText() == 'location')){
                    parser.nextToken(); // object start
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                        String txt = parser.getText();
                        parser.nextToken();
                        if (txt == 'lat'){
                            lat = parser.getDoubleValue();
                        }
                        else if (txt == 'lng'){
                            lon = parser.getDoubleValue();
                        }
                    }
                }
            }
        system.debug('lat: '+lat);
        system.debug('lon: '+lon);

        Address__c addresses = [SELECT Id,Name,City__c,State__c,ZIP_Code__c,Location_Lat_Long__Latitude__s, Location_Lat_Long__Longitude__s from Address__c where Id =: id];
            if(addresses != null){
                addresses.Location_Lat_Long__Latitude__s = lat ;
                addresses.Location_Lat_Long__Longitude__s = lon ;
                update addresses;
            }
        }
        catch (Exception e) {
            system.debug(e);
        }
    }
}