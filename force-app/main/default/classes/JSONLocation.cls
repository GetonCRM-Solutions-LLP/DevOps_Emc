//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class JSONLocation {

    public String name;
    public String address;
    public String activity;
    public String userId;
    public String strlatitude;
    public String strlongitude;
    public Double latitude;
    public Double longitude;
    
    // Paramterized constructor
    public JSONLocation(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'name') {
						name = parser.getText();
					} else if (text == 'address') {
						address = parser.getText();
					} else if (text == 'latitude') {
						strlatitude = parser.getText();
					} else if (text == 'longitude') {
						strlongitude = parser.getText();
					} else if (text == 'activity') {
						activity = parser.getText();
					} else if (text == 'userId') {
						userId = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	


    private static List<JSONLocation> arrayOfJSONLocation(System.JSONParser p) {
        List<JSONLocation> res = new List<JSONLocation>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new JSONLocation(p));
        }
        return res;
    }

    public void convertLatLong() {
        latitude = String.isNotBlank(strlatitude) ? Double.valueOf(strlatitude) : null;
        
        longitude = String.isNotBlank(strlongitude) ? Double.valueOf(strlongitude) : null;
    }
    
    public static List<JSONLocation> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        List<JSONLocation> lstJSONLocations = new List<JSONLocation>();
        if(json.startswith('[') && json.endswith(']')){
            lstJSONLocations = arrayOfJSONLocation(parser);
        }
        else{
            lstJSONLocations = new List<JSONLocation>{new JSONLocation(parser)};
                }
        for (JSONLocation objLocation : lstJSONLocations) {
            objLocation.convertLatLong();
        }
        return lstJSONLocations;
	}

    /*public static List<JSONLocation> parse(String json) {
       system.debug('Json@@--'+json);
        List<JSONLocation> locations = (List<JSONLocation>) System.JSON.deserialize(json, List<JSONLocation>.class);
        for (JSONLocation location : locations) {
            location.convertLatLong();
        }
        return locations;
    }*/
}