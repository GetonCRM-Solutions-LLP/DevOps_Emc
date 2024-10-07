public class ChangeActivityJSON2Apex {
    public String id;
    public String adminId;
    public String tripdate;
    public String conName;
    public String conEmail;
    public String oldActivity;
    public String mileage;
    public String actualMileage;
    public Integer tripId;
    public String accApi;

    
    public static List<ChangeActivityJSON2Apex > parse(String json) {
        return (List<ChangeActivityJSON2Apex>) System.JSON.deserialize(json, List<ChangeActivityJSON2Apex>.class);
    }
}