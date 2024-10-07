/**
@author Natavar Ghodasara
@date 26th Feb 2019
@description DriverDashboardController is used to show/edit Employee details.
*/
public with sharing class ReportListController {
    public List<reimbursementWrapper> reimWrapperList {get; set;}    
    public boolean checkTripStatus {get; set;}
    public string accPayperiodStart {get; set;}
    public string accPayDays {get; set;}
    public static Integer AccountYear{get;set;} 
    
    public ReportListController() {          
        for(Account acc : [SELECT id,Trip_Status_Lock__c,
                           Pay_Period_Start_Date__c, 
                           Pay_Period_Days__c,
                           CreatedDate  
                           FROM Account 
                           WHERE id =: getAccountid() ]){
                               accPayperiodStart = string.valueOf(acc.Pay_Period_Start_Date__c);
                               accPayDays = string.valueOf(acc.Pay_Period_Days__c);
                               AccountYear = Date.valueof(acc.CreatedDate).year();
                               if(acc.Trip_Status_Lock__c != null){
                                   checkTripStatus = false;
                               } else {
                                   checkTripStatus = true;
                               }
                           }
    }
    @AuraEnabled
    public static Integer AccountYear(String accountId){
        Account acc = [SELECT id,
                           CreatedDate  
                           FROM Account 
                           WHERE id =: accountId];  
                       return Date.valueof(acc.CreatedDate).year();
    }
    
    public static String getAccountid() {
        if (ApexPages.currentPage().getParameters().containsKey('accid')) {
            return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        }
    }
    public static String getContactid() {
        if (ApexPages.currentPage().getParameters().containsKey('id')) {
            return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        }
    }
    public static PageReference getRedirected() {
        if (getContactid() != '' && getAccountid() != '') {
            return null;
        } else {
            // redirect to error page
            return null;
        }   
    }
    
    public static string getRole() { 
        List<Contact> conRole = [SELECT Id, Role__c FROM Contact WHERE id =: getContactid()]; 
        string role = conRole[0].Role__c;
        return role;
    }
    
    public static string EmailAddress(String adminId) {
        List<Contact> conEmail = [SELECT Id, External_Email__c FROM Contact WHERE id =: adminId]; 
        string email = conEmail[0].External_Email__c;
        return email;
    }
    
    public static string AdminName(String adminId) {
        Contact conName = [SELECT Id,FirstName FROM Contact WHERE id =: adminId]; 
        string name = conName.FirstName != '' ? conName.FirstName : '';
        return name;
    }
    @AuraEnabled
    public static string getAllReports(String contactId) {       
        Map<String,List<Report_Accessibility__c>> obj_map_report_Accessibility = new Map<String,List<Report_Accessibility__c>>();
        for(Report_Accessibility__c obj_currentreportaccesibilty:[SELECT Custom_Report__r.ownerid,Custom_Report__r.Name,
                                                                  Custom_Report__c,Custom_Report__r.Report_Category__c,
                                                                  Custom_Report__r.Show_Lock_Date__c,Mileage_Lock_Date__c 
                                                                  FROM Report_Accessibility__c 
                                                                  WHERE user__r.contactid =: contactId Order By Custom_Report__r.Report_Category__c]) {
                                                                      if(obj_map_report_Accessibility.containsKey(obj_currentreportaccesibilty.Custom_Report__r.Report_Category__c)) {  
                                                                          obj_map_report_Accessibility.get(obj_currentreportaccesibilty.Custom_Report__r.Report_Category__c).add(obj_currentreportaccesibilty);   
                                                                      }
                                                                      else {
                                                                          List<Report_Accessibility__c> obj_Report_Accessibility_list = new List<Report_Accessibility__c>();
                                                                          obj_Report_Accessibility_list.add(obj_currentreportaccesibilty);
                                                                          obj_map_report_Accessibility.put(obj_currentreportaccesibilty.Custom_Report__r.Report_Category__c,obj_Report_Accessibility_list);   
                                                                      } 
                                                                  }
        List<CategoryWiseReportList> obj_CategoryWiseReportList = new List<CategoryWiseReportList>();
        for(String s:obj_map_report_Accessibility.keySet()) {
            CategoryWiseReportList obj = new CategoryWiseReportList();
            obj.categoryName = s;
            List<CategoryWiseReportList.Reports> reportsList = new List<CategoryWiseReportList.Reports>();
            for(Report_Accessibility__c r : obj_map_report_Accessibility.get(s)) {
                CategoryWiseReportList.Reports obj_report = new CategoryWiseReportList.Reports();
                obj_report.reportId = r.Custom_Report__c;
                obj_report.reportName = r.Custom_Report__r.Name;  
                obj_report.lockDate = r.Custom_Report__r.Show_Lock_Date__c; 
                obj_report.mileageLockDate = String.valueOf(r.Mileage_Lock_Date__c);
                reportsList.add(obj_report);
            }
            obj.currentReports = reportsList;
            obj_CategoryWiseReportList.add(obj);
        }
        return JSON.serialize(obj_CategoryWiseReportList);      
    }
    //AI-000426
    // @RemoteAction
    @AuraEnabled
    public static string updateLockDate(String accountId,String contactId) {
        List<Account> accList = new List<Account>();
        for(Account acc : [SELECT id,Trip_Status_Lock__c,Change_Status_Admin__c 
                           FROM Account 
                           Where id =: accountId]){
                               acc.Trip_Status_Lock__c = System.today();
                               string adminName = AdminName(contactId);
                               acc.Change_Status_Admin__c = adminName != null ? adminName : '';            
                               //acc.Change_Status_Admin__c = AdminName(contactId); 
                               accList.add(acc);
                           }
        if(accList.size() > 0) {
            update accList;
        }
        WrapperUtils.updateLockDate(accountId,contactId);
        return 'sucess';
    }
    //EMC-107 
    @RemoteAction
    public static void UpdateMileageLockDate(String startDate,String endDate) {
        UpdateMileageLockDate1(startDate,endDate);
    }
    //EMC-107
    @future 
    public static void UpdateMileageLockDate1(String startDate,String endDate) {
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c emp : [SELECT id,Mileage_Lock_Date__c 
                                       FROM Employee_Mileage__c 
                                       WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: System.Label.PLMarketing
                                       AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                                       AND Mileage_Lock_Date__c = null
                                       AND Trip_Date__c >= : Date.valueOf(startDate)
                                       AND Trip_Date__c <= : Date.valueOf(endDate)
                                      ]){
                                          emp.Mileage_Lock_Date__c = system.today();
                                          mileageList.add(emp);
                                      }
        If(mileageList.size() > 0 ) {
            update mileageList;
        }
    }
    //AI-000150
    @RemoteAction
    public static List<Contact> contactListModal(String accId) {
        List<Contact> contactList = new List<Contact>();
        for(contact currentContact:[SELECT id,FirstName,LastName 
                                    FROM Contact 
                                    WHERE (Role__c = 'Driver' OR Role__c =: StaticValues.roleAdminDriver OR Role__c = 'Manager/Driver') 
                                    AND Account.id =: accId ORDER BY FirstName]) {
                                        contactList.add(currentContact);
                                    }
        return contactList; 
    }
    
    @RemoteAction
    public static List<Employee_Reimbursement__c> reimbursementListModal(String reimbId) {
        List<Employee_Reimbursement__c> reimbursementList = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c currentReimbursement : [SELECT id,Name FROM Employee_Reimbursement__c WHERE Contact_Id__c =: reimbId  order by CreatedDate desc]) {
            reimbursementList.add(currentReimbursement);
        }
        return reimbursementList;   
    }
    
    @RemoteAction @AuraEnabled
    public static DateTime postTimeSheetImportAPI(String startDate, String endDate,String adminId) {
        DateTime runTime = System.Now();
        String AdminEmail = EmailAddress(adminId);
        String name = AdminName(adminId);
        TimeSheetImportNetchexBatch tripBtc = new TimeSheetImportNetchexBatch(startDate, endDate, runTime, AdminEmail, name);
        Database.executeBatch(tripBtc,200);
        return runTime;
    }
    
    @RemoteAction @AuraEnabled
    public static DateTime postVariablePaymentAPI(String startDate,String adminId) {
        DateTime runTime = System.Now();
        String AdminEmail = EmailAddress(adminId);
        String name = AdminName(adminId);
        NetchexVariablePaymentBatch tripBtc = new NetchexVariablePaymentBatch(runTime,startDate,AdminEmail,name);
        Database.executeBatch(tripBtc,200);
        return runTime;
    }
    
    // @RemoteAction 
    @AuraEnabled
    
    public static DateTime postFixedAmountAPI(String startDate,String adminId) {
        DateTime runTime = System.Now();
        String AdminEmail = EmailAddress(adminId);
        String name = AdminName(adminId);
        NetchexSalaryPartFixAmountBatch tripBtc = new NetchexSalaryPartFixAmountBatch(runTime,startDate,AdminEmail,name);
        Database.executeBatch(tripBtc,200);
        return runTime;
    }
    
    // @RemoteAction 
    @AuraEnabled
    public static String CheckStatus(Long longtime, String batchName) {
        DateTime runTime = DateTime.newInstance(longtime);
        List<Tripslog__c> logList = [SELECT Id, Response_Data__c  FROM Tripslog__c WHERE Log_Time__c =: runTime AND Response__c =: batchName];
        PollarResponse res = new PollarResponse();
        res.enablePollar = true;
        if(!logList.isEmpty()) {
            res.enablePollar = false; 
            res.message = logList.get(0).Response_Data__c;
        }
        return Json.Serialize(res);
    }
    
    @RemoteAction @AuraEnabled
   
    public static DateTime postHalfFPFullDriverAPI(String startDate, String endDate,String adminId) {
        DateTime runTime = System.Now();
        String AdminEmail = EmailAddress(adminId);
        String name = AdminName(adminId);
        NetchexFulltimeHalfFPBatch tripBtc = new NetchexFulltimeHalfFPBatch(runTime,startDate,endDate,AdminEmail,name);
        Database.executeBatch(tripBtc,200);
        return runTime;
    }
    
    @RemoteAction @AuraEnabled
   
    public static DateTime DeleteNetchexCallout(String startDate,String endDate) {
        DateTime runTime = System.Now();
        if(!Test.isRunningTest()) {
            NetchexDeleteCallout.DeletedataFromNetchex(startDate,endDate,runTime);
        }
        return runTime;
    }
    
    @RemoteAction
    public static void ChangeTripStatus(String accId) {
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        ChangeTripStatusByAdmin tripBtc = new ChangeTripStatusByAdmin(accId,lastMonth);
        Database.executeBatch(tripBtc,10);
    }
    @RemoteAction @AuraEnabled
    public static String TripDetailReport(String tripStartDate,String tripEndDate,String id) {
        String response = TripDetailReportController.drivingTime(tripStartDate,tripEndDate,id);
        return response;
    }
    @RemoteAction @AuraEnabled
    
    public static string ErmiDriverList (String startDate,String endDate,String accountId) {
        List<reimbursementWrapper> reimWrapperList = new List<reimbursementWrapper>();
        Map<String,String> contactMap = new Map<String,String>();
        if(System.Label.ERMI_Account == accountId){        
            for(Employee_Mileage__c mileage : [select id,EmployeeReimbursement__r.Contact_Id__c, EmployeeReimbursement__r.Contact_Id__r.FirstName, EmployeeReimbursement__r.Contact_Id__r.LastName from Employee_Mileage__c where EmployeeReimbursement__r.Contact_Id__r.isCommunityUser__c = true and EmployeeReimbursement__r.Contact_Id__r.AccountId =: accountId and (EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Part Time' OR EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Full Time' )and EmployeeReimbursement__r.Contact_Id__r.Role__c != 'Admin' and EmployeeReimbursement__r.Contact_Id__r.Role__c != 'Manager' AND Trip_Date__c >= : Date.valueOf(startDate)
                                               AND Trip_Date__c <= : Date.valueOf(endDate) order by EmployeeReimbursement__r.Contact_Id__r.FirstName asc]){
                                                   contactMap.put(mileage.EmployeeReimbursement__r.Contact_Id__c, mileage.EmployeeReimbursement__r.Contact_Id__r.FirstName+' '+mileage.EmployeeReimbursement__r.Contact_Id__r.LastName);
                                               }
        } else if(System.label.FramptonConstruction == accountId){
            for(Employee_Mileage__c mileage : [select id,EmployeeReimbursement__r.Contact_Id__c, EmployeeReimbursement__r.Contact_Id__r.FirstName, EmployeeReimbursement__r.Contact_Id__r.LastName from Employee_Mileage__c where EmployeeReimbursement__r.Contact_Id__r.isCommunityUser__c = true and EmployeeReimbursement__r.Contact_Id__r.AccountId =: accountId and EmployeeReimbursement__r.Contact_Id__r.Role__c != 'Admin' and EmployeeReimbursement__r.Contact_Id__r.Role__c != 'Manager' AND Tag__c != null 
                                               AND Mileage__c > 0 AND Trip_Date__c >= : Date.valueOf(startDate) AND Trip_Date__c <= : Date.valueOf(endDate) order by EmployeeReimbursement__r.Contact_Id__r.FirstName asc]){
                                                   contactMap.put(mileage.EmployeeReimbursement__r.Contact_Id__c, mileage.EmployeeReimbursement__r.Contact_Id__r.FirstName+' '+mileage.EmployeeReimbursement__r.Contact_Id__r.LastName);
                                               }
        }
        for(String currentContact : contactMap.keySet()) {
            reimbursementWrapper objWrapper = new reimbursementWrapper();
            objWrapper.reimbId = currentContact;
            objWrapper.name = contactMap.get(currentContact);
            reimWrapperList.add(objWrapper);
        }
        return JSON.serialize(reimWrapperList).unescapeHtml4();
    }

    @RemoteAction @AuraEnabled
    Public static string taxLiabilityReport (String accId){
        List<reimbursementWrapper> reimWrapperList = new List<reimbursementWrapper>();
        List<String> complianceCalculationList ;
        for(contact con : [SELECT id, compliancestatus__c, Name, Employee_ID__c, External_Email__c 
                           FROM Contact 
                           WHERE
                           Deactivated_Date__c = null 
                           AND AccountId =: accId 
                           AND (Role__c =: StaticValues.roleAdminDriver OR Role__c='Driver' OR Role__c='Driver/Manager')]){  
                            reimbursementWrapper objWrapper = new reimbursementWrapper();
                            objWrapper.reimbId = con.id;
                            objWrapper.name = con.name;
                            reimWrapperList.add(objWrapper);
                           }
        return JSON.serialize(reimWrapperList);
    }

    @RemoteAction @AuraEnabled
    Public static string downLoadComplianceReport (string condata, string year){
    System.debug('condata'+condata);
    System.debug('year'+year);
        return driverComplianceReport.downloadAnnualComplianceReport(condata, year);
    }

    @AuraEnabled  @RemoteAction
    public static string payPeriodDateList(String accId){
        String dateList = BiweeklyPayPeriod.payPeriodDateList(accId);
        return dateList;
    }

    public class reimbursementWrapper {
        public Id reimbId { get; set; }
        public string name { get; set; }
    }
    
    public class PollarResponse {
        public Boolean enablePollar;
        public String Message;
    }
}