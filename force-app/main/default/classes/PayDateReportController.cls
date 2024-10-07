public with sharing class PayDateReportController {
    public static List<BiweeklyWrapper> biweeklyWrapperList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public PayDateReportController() {
        String accId = ApexPages.currentPage().getParameters().get('id');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        checkBiweeklyPayPeriod(Date.valueOf(startDate),Date.valueOf(endDate),accId);
    }
    public void checkBiweeklyPayPeriod(Date startDT,Date endDt,String accId){
        System.debug('startdt== '+startDT);
        System.debug('enddt== '+endDt);
        System.debug('accid == '+accId);
        biweeklyWrapperList = new List<BiweeklyWrapper>();
        for(Bi_Weekly_Reimbursement__c biWeeklyList : [Select Id,Name,Start_Date__c,End_Date__c,Contact__c,Contact__r.name,Contact__r.Email,Contact__r.Employee_ID__c,Total_Variable_Rate__c,Monthly_Approved_Variable_Amount__c,IRS_Mileage_Rate__c,Monthly_Fixed_Amount__c,Total_Mileage__c,Total_Approved__c,Total_Mileages_after_Deduction__c,Net_Reimbursement__c from Bi_Weekly_Reimbursement__c where Start_Date__c =:startDT and End_Date__c =:endDt and Contact__r.Account.Id =: accId]){
            BiweeklyWrapper objWrapper = new BiweeklyWrapper();
            objWrapper.name = biWeeklyList.Contact__r.name != null ? biWeeklyList.Contact__r.name : null;
            objWrapper.email = biWeeklyList.Contact__r.Email != null ? biWeeklyList.Contact__r.Email : null;
            objWrapper.variableRate = biWeeklyList.Total_Variable_Rate__c != null ? biWeeklyList.Total_Variable_Rate__c : null;
            objWrapper.variableAmount = biWeeklyList.Net_Reimbursement__c.setScale(2) != null ? biWeeklyList.Net_Reimbursement__c : null;        
            objWrapper.totalApproved = biWeeklyList.Total_Mileages_after_Deduction__c != null ? biWeeklyList.Total_Mileages_after_Deduction__c : null;
            objWrapper.employeeId = biWeeklyList.Contact__r.Employee_ID__c != null ? biWeeklyList.Contact__r.Employee_ID__c : null;
            objWrapper.biweeklyName = biWeeklyList.Name != null ? biWeeklyList.Name : null;
            biweeklyWrapperList.add(objWrapper);
        }
    }
    public class BiweeklyWrapper{
        public string employeeId { get; set; }
        public string name { get; set; }
        public string biweeklyName { get; set; }
        public string email { get; set; }
        public Decimal variableRate { get; set; }
        public double variableAmount{ get; set; }   
        public Decimal totalApproved { get; set; }
    }
}