public with sharing class ManualEntryMileageController {
    @AuraEnabled
    public static string currentMonthMileages (String conID){
        
        Date dToday = Date.today();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month()-4,dToday.day());
        String dateStr = dt.format('MM-YYYY');
        System.debug('dateStr: '+dateStr);
       
        List<EmployeeMileages> employeeMileagesList = new List<EmployeeMileages>();

        for(Employee_Mileage__c currentMileage : [SELECT id,Name,Trip_Status__c,High_Risk_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Bi_Weekly_Reimbursement__c,Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,TimeZone__c,Tag__c,Bi_Weekly_Reimbursement__r.month__c,Bi_Weekly_Reimbursement__r.Total_Pending__c,Stay_Time__c, Bi_Weekly_Reimbursement__r.Total_Mileage__c,Bi_Weekly_Reimbursement__r.Contact__c,Driving_Time__c,Total_Time__c,CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Mileage_Lock_Date__c, Day_Of_Week__c,Destination_Name__c,Bi_Weekly_Reimbursement__r.Contact__r.External_Email__c,Bi_Weekly_Reimbursement__r.Half_Fixed_Amount__c, Maintenance_and_Tires__c,Fuel_price__c,Bi_Weekly_Reimbursement__r.Total_Variable_Rate__c,ConvertedStartTime__c,ConvertedEndTime__c, Bi_Weekly_Reimbursement__r.Total_Rejected__c,Notes__c,Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Bi_Weekly_Pay_Period__c FROM Employee_Mileage__c 
                                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: conID  AND EmployeeReimbursement__r.Month__c =: dateStr ]){

                employeeMileagesList.add(BiWeeklyWrapperUtils.getMileagesOfReimbursement(currentMileage));
        }
        return JSON.serialize(employeeMileagesList);
    }

    @AuraEnabled
    public static void mileageCollection(String mileageJSONString, String mileageId) {
        List<Employee_Mileage__c> updateMileageList = new List<Employee_Mileage__c>();
        List<EmployeeMileages> mileageResponse = (List<EmployeeMileages>) System.JSON.deserialize(mileageJSONString, List<EmployeeMileages>.class);

        for(EmployeeMileages wrapData : mileageResponse){
            Employee_Mileage__c empMileage = new Employee_Mileage__c();
            empMileage.Id = wrapData.id;
            empMileage.Trip_Origin__c = wrapData.origin;
            empMileage.Destination_Name__c = wrapData.destinationname;
            empMileage.Mileage__c = Decimal.valueOf(wrapData.mileage);
            empMileage.Notes__c = wrapData.notes;
            empMileage.Tag__c = wrapData.tag;
            empMileage.Trip_Date__c = Date.parse(wrapData.tripdate);
            empMileage.Trip_Origin__c = wrapData.origin;
            empMileage.Trip_Destination__c = wrapData.destination;
            updateMileageList.add(empMileage);
        }
        if(updateMileageList.size() > 0){
            update updateMileageList;
        }
    }

    @AuraEnabled
    public static string fromAndToVal(String conId){
        return Json.serialize(ImportLocationController.getLocation(conId));
    }
    
    @AuraEnabled
    public static List<Employee_Mileage__c> fetchMileages(String conId){
        return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c,Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c,Mileage__c,Trip_Origin__c, Trip_Destination__c,Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c,Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s,Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,  TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,StartTime__c, EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c FROM Employee_Mileage__c
                    WHERE EmployeeReimbursement__r.Contact_Id__c =: conId];
    }
}