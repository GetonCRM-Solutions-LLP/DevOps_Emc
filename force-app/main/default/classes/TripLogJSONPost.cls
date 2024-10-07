public class TripLogJSONPost {

    public class User {
        public Integer id {get;set;} 
        public String url {get;set;} 
        public String email {get;set;} 
        public String display {get;set;} 
        public String firstName {get;set;} 
        public String lastName {get;set;} 
        public String phone {get;set;} 
        public Object employeeId {get;set;} 
        public Object dept {get;set;} 
        public Object supervisor {get;set;} 
        public Boolean admin {get;set;} 
        public Boolean driver {get;set;} 
        public Boolean accountant {get;set;} 
        public Boolean locked {get;set;} 
        public Boolean disabled {get;set;} 
        public Integer dailyMileageExemption {get;set;} 
        public Integer mileageRate {get;set;} 
        public Boolean exemptionOnlyWeekdays {get;set;} 
        public Object lastSynced {get;set;} 
        public String vehicles {get;set;} 
        public String locations {get;set;} 
        public String currentLocation {get;set;} 

        public User(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'display') {
                            display = parser.getText();
                        } else if (text == 'firstName') {
                            firstName = parser.getText();
                        } else if (text == 'lastName') {
                            lastName = parser.getText();
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else if (text == 'employeeId') {
                            employeeId = parser.readValueAs(Object.class);
                        } else if (text == 'dept') {
                            dept = parser.readValueAs(Object.class);
                        } else if (text == 'supervisor') {
                            supervisor = parser.readValueAs(Object.class);
                        } else if (text == 'admin') {
                            admin = parser.getBooleanValue();
                        } else if (text == 'driver') {
                            driver = parser.getBooleanValue();
                        } else if (text == 'accountant') {
                            accountant = parser.getBooleanValue();
                        } else if (text == 'locked') {
                            locked = parser.getBooleanValue();
                        } else if (text == 'disabled') {
                            disabled = parser.getBooleanValue();
                        } else if (text == 'dailyMileageExemption') {
                            dailyMileageExemption = parser.getIntegerValue();
                        } else if (text == 'mileageRate') {
                            mileageRate = parser.getIntegerValue();
                        } else if (text == 'exemptionOnlyWeekdays') {
                            exemptionOnlyWeekdays = parser.getBooleanValue();
                        } else if (text == 'lastSynced') {
                            lastSynced = parser.readValueAs(Object.class);
                        } else if (text == 'vehicles') {
                            vehicles = parser.getText();
                        } else if (text == 'locations') {
                            locations = parser.getText();
                        } else if (text == 'currentLocation') {
                            currentLocation = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'User consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public String message {get;set;} 
    public User user {get;set;} 

    public TripLogJSONPost(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'message') {
                        message = parser.getText();
                    } else if (text == 'user') {
                        user = new User(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'TripLogJSONPost consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public static TripLogJSONPost parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new TripLogJSONPost(parser);
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
   
}