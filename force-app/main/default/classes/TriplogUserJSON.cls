public class TriplogUserJSON {

    public String message {get;set;} 
    public List<Users> users {get;set;} 

    public TriplogUserJSON(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'message') {
                        message = parser.getText();
                    } else if (text == 'users') {
                        users = arrayOfUsers(parser);
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Users {
        public Integer id {get;set;} 
        public String url {get;set;} 
        public String email {get;set;} 
        public String display {get;set;} 

        public Users(JSONParser parser) {
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
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static TriplogUserJSON parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new TriplogUserJSON(parser);
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
    




    private static List<Users> arrayOfUsers(System.JSONParser p) {
        List<Users> res = new List<Users>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Users(p));
        }
        return res;
    }
}