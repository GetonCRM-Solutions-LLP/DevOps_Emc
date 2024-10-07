public class updateThresholdWrapper {
    public updateThresholdWrapper()
    {
    }
        public String contactid {get;set;} 
        public String threshold {get;set;} 

        public UpdateThresholdWrapper(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'contactid') {
                            contactid = parser.getText();
                        } else if (text == 'threshold') {
                            threshold = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'UpdateThresholdWrapper consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    
    public static List<UpdateThresholdWrapper> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfUpdateThresholdWrapper(parser);
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
    

    private static List<UpdateThresholdWrapper> arrayOfUpdateThresholdWrapper(System.JSONParser p) {
        List<UpdateThresholdWrapper> res = new List<UpdateThresholdWrapper>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new UpdateThresholdWrapper(p));
        }
        return res;
    }



}