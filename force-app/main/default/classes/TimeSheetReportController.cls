/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Apex class use to download a excel file for Timesheet report same as netchex time and attedance report.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 2 Sept 2020
 */
public with sharing class TimeSheetReportController {
    public List<ReibursementWrapper> timeWrapperList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public TimeSheetReportController() {
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        /*List<Employee_Mileage__c  > milList = new List<Employee_Mileage__c   >();
        for(Employee_Mileage__c  currentAccount : [select id,name,Origin_Name__c, Destination_Name__c,Driving_Time__c, Stay_Time__c 
                                                    from Employee_Mileage__c 
                                                    where Trip_Date__c >= : Date.valueOf(startDate)
                                                    and EmployeeReimbursement__r.Contact_Id__r.Account.name = 'ermi' 
                                                    and (EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Full Time' 
                                                        or  EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Part Time' ) 
                                                        and Origin_Name__c LIKE '%home%' and Destination_Name__c like '%home%' and Stay_Time__c > 0])
        {
           currentAccount.Stay_Time__c =0;         
           milList.add(currentAccount);
        }
        
        if(milList.size()> 0){
            update milList;    
        } */       
        TimeSheet();
    }
    public void TimeSheet(){
        //String Id = ApexPages.currentPage().getParameters().get('id');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        timeWrapperList = new List<ReibursementWrapper>();
        Map<Id, Decimal> reimbTotalTimeW1Map = new Map<Id, Decimal>();
        Map<Id, Decimal> reimbTotalTimeW2Map = new Map<Id, Decimal>();
        date firstend = Date.valueOf(startDate);
        firstend = firstend + 6;
        date secondstart = firstend + 1;
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c rid, SUM(Drive_Stay_Time__c) rtotal 
                                FROM Employee_Mileage__c 
                                WHERE (EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Full Time' 
                                        OR EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Part Time') 
                                        AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: System.Label.ERMI_Account
                                        AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                                        AND Trip_Date__c >= : Date.valueOf(startDate)
                                        AND Trip_Date__c <= : firstend group by EmployeeReimbursement__r.Contact_Id__c]) {
                                reimbTotalTimeW1Map.put((Id)ar.get('rid'), (Decimal) ar.get('rtotal')); 
        }
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c rid, SUM(Drive_Stay_Time__c) rtotal 
                                FROM Employee_Mileage__c 
                                WHERE (EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Full Time' 
                                        OR EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Part Time') 
                                        AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: System.Label.ERMI_Account
                                        AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                                        AND Trip_Date__c >= : secondstart
                                        AND Trip_Date__c <= : Date.valueOf(endDate) group by EmployeeReimbursement__r.Contact_Id__c]) {
                                reimbTotalTimeW2Map.put((Id)ar.get('rid'), (Decimal) ar.get('rtotal')); 
        }
        for(Contact currentContact : [SELECT id,Employee_Netchex_Id__c,Code__c FROM Contact WHERE (Driver_Type__c = 'Driver - Full Time' OR Driver_Type__c = 'Driver - Part Time')AND Employee_Netchex_Id__c != null AND Deactivated_Date__c = null AND AccountId =: System.Label.ERMI_Account]){
            ReibursementWrapper objWrapper = new ReibursementWrapper();
            objWrapper.CompanyCode = 'LIL';
            objWrapper.EntryDate = endDate;
            objWrapper.EmployeeId = currentContact.Employee_Netchex_Id__c;
            objWrapper.GrossToNetCode = '1';
            objWrapper.TypeCode = 'R';
            if(reimbTotalTimeW1Map.get(currentContact.Id) == null ){
                objWrapper.firstweekAmount = 0;
            } else {
                objWrapper.firstweekAmount = (reimbTotalTimeW1Map.get(currentContact.Id)).divide(60, 2);
            }
            if(reimbTotalTimeW2Map.get(currentContact.Id) == null ){
                objWrapper.secondweekamount = 0;
            } else {
                objWrapper.secondweekamount = (reimbTotalTimeW2Map.get(currentContact.Id)).divide(60, 2);
            }
            objWrapper.HoursOrAmount = objWrapper.firstweekAmount + objWrapper.secondweekamount ;
            
            timeWrapperList.add(objWrapper);
        }
    }

    public class ReibursementWrapper{
        public string CompanyCode { get; set; }
        public string EntryDate { get; set; }
        public string EmployeeId { get; set; }
        public string GrossToNetCode { get; set; }
        public string TypeCode { get; set; }
        public double firstweekAmount { get; set; }
        public double secondweekamount { get; set; }
        public double HoursOrAmount { get; set; }
        public ReibursementWrapper(){
        }
    }
}