@IsTest
public class ChangeActivityJSON2Apex_Test {
    
    static testMethod void testParse() {
        String json = '[{\"id\":\"a0B4C000004D1m6UAC\",\"adminId\":\"0030Z00003NFLTfQAP\",\"tripdate\":\"2021-08-17\",\"conName\":\"NIkita Patel\",\"conEmail\":\"nikita.patel@kiwiqa.com\",\"oldActivity\":\"Business\",\"mileage\":\"100\",\"actualMileage\":\"100\",\"tripId\":2000669507,\"accApi\":\"28beeea973f34daf89050a9b6a3b1a71\"},{\"id\":\"a0B4C000004DOjMUAW\",\"adminId\":\"0030Z00003NFLTfQAP\",\"tripdate\":\"2021-08-09\",\"conName\":\"NIkita Patel\",\"conEmail\":\"nikita.patel@kiwiqa.com\",\"oldActivity\":\"Business\",\"mileage\":\"1.6\",\"actualMileage\":\"1.6\",\"tripId\":2000698284,\"accApi\":\"28beeea973f34daf89050a9b6a3b1a71\"},{\"id\":\"a0B4C000004DLsXUAW\",\"adminId\":\"0030Z00003NFLTfQAP\",\"tripdate\":\"2021-08-08\",\"conName\":\"Jaytik Luhar\",\"conEmail\":\"jaytik.luhar@kiwiqa.com\",\"oldActivity\":\"Business\",\"mileage\":\"30\",\"actualMileage\":\"30\",\"tripId\":2000692935,\"accApi\":\"28beeea973f34daf89050a9b6a3b1a71\"}]';
        List<ChangeActivityJSON2Apex> obj = ChangeActivityJSON2Apex.parse(json);
        System.assert(obj != null);
    }
}