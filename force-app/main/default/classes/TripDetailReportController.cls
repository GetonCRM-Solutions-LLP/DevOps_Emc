/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Apex class use to download a excel file for trip.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 9 August 2022
 */
public with sharing class TripDetailReportController {
    //public List<mileageWrapper> mileageWrapperList{get;set;}
    /*public string mileageWrapperJson {get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
    
        }
    
    }*/
    public TripDetailReportController() {}
    
    public static string drivingTime(String startDate ,String endDate ,String accId ){
        string mileageWrapperJson;        
        List<mileageWrapper> mileageWrapperList = new List<mileageWrapper>();
        for(Employee_Mileage__c objMileages : [SELECT id,EmployeeReimbursement__r.Contact_Id_Name__c,
                                                        Contact_Email_Id__c,Trip_Date__c,Day_Of_Week__c,
                                                        ConvertedStartTime__c,ConvertedEndTime__c,Mileage__c,
                                                        Origin_Name__c, Trip_Origin__c,Destination_Name__c, 
                                                        Trip_Destination__c, Notes__c, Tracing_Style__c,
                                                        From_Location__Latitude__s,From_Location__Longitude__s, 
                                                        To_Location__Latitude__s, To_Location__Longitude__s
                                                    FROM Employee_Mileage__c 
                                                    WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId  =: accId 
                                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                                    AND Trip_Date__c <= : Date.valueOf(endDate)
                                                    LIMIT 49999
                                                    ]){
                                    List<String> dateSplitted = new List<String>();
                                    if(String.valueOf(objMileages.Trip_Date__c) != null && String.valueOf(objMileages.Trip_Date__c).contains('-')){
                                        dateSplitted = String.valueOf(objMileages.Trip_Date__c).split('-');
                                    }
                                    mileageWrapper objMileageWrap = new mileageWrapper();
                                    objMileageWrap.driverName = objMileages.EmployeeReimbursement__r.Contact_Id_Name__c;
                                    objMileageWrap.driverEmail = objMileages.Contact_Email_Id__c;
                                    objMileageWrap.tripDate = dateSplitted[1]+'/'+dateSplitted[2]+'/'+dateSplitted[0].substring(2,4);
                                    objMileageWrap.tripDay = objMileages.Day_Of_Week__c != null ? objMileages.Day_Of_Week__c : null;
                                    if(objMileages.ConvertedStartTime__c  != null ) {
                                       DateTime startTime = objMileages.ConvertedStartTime__c;
                                       objMileageWrap.startTime = startTime.format('h:mm a','America/Panama');
                                    }                                    
                                    if(objMileages.ConvertedEndTime__c  != null) {
                                       DateTime endTime = objMileages.ConvertedEndTime__c ;
                                       objMileageWrap.endTime = endTime.format('h:mm a','America/Panama');
                                    }                                   
                                    objMileageWrap.mileage = objMileages.Mileage__c != null ? objMileages.Mileage__c : null;
                                    objMileageWrap.FLocationName = objMileages.Origin_Name__c != null ? objMileages.Origin_Name__c : null;
                                    objMileageWrap.FLocationAdd = objMileages.Trip_Origin__c != null ? objMileages.Trip_Origin__c : null;
                                    objMileageWrap.TLocationName = objMileages.Destination_Name__c != null ? objMileages.Destination_Name__c : null;
                                    objMileageWrap.TLocationAdd = objMileages.Trip_Destination__c != null ? objMileages.Trip_Destination__c : null;
                                    objMileageWrap.notes = objMileages.Notes__c != null ? objMileages.Notes__c : null;
                                    objMileageWrap.FLocationLatitude = objMileages.From_Location__Latitude__s != null ? String.valueOf(objMileages.From_Location__Latitude__s) : null;
                                    objMileageWrap.FLocationLongitude = objMileages.From_Location__Longitude__s != null ? String.valueOf(objMileages.From_Location__Longitude__s) : null;
                                    objMileageWrap.TLocationLatitude = objMileages.To_Location__Latitude__s != null ? String.valueOf(objMileages.To_Location__Latitude__s) : null;
                                    objMileageWrap.TLocationLongitude = objMileages.To_Location__Longitude__s != null ? String.valueOf(objMileages.To_Location__Longitude__s) : null;
                                    objMileageWrap.trackingMethod = objMileages.Tracing_Style__c;
                                    mileageWrapperList.add(objMileageWrap);
        }
        if(mileageWrapperList.size () > 0 ){
            mileageWrapperJson = Json.serialize(mileageWrapperList);
        }
        return      mileageWrapperJson ; 
    }
    public class mileageWrapper{
        public string driverName { get; set; }
        public string driverEmail { get; set; }
        public string tripDate { get; set; }
        public string tripDay { get; set; }
        public string startTime { get; set; }
        public string endTime { get; set; }
        public decimal mileage { get; set; }
        public string FLocationName { get; set; }
        public string FLocationAdd { get; set; }
        public string TLocationName { get; set; }
        public string TLocationAdd { get; set; }
        public string notes { get; set; }
        public string FLocationLatitude{ get; set; }
        public string FLocationLongitude { get; set; }
        public string TLocationLatitude{ get; set; }
        public string TLocationLongitude { get; set; }
        public string trackingMethod { get; set; }
        public mileageWrapper(){
        }
    }
}