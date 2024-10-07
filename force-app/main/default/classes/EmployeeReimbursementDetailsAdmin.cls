public with sharing class EmployeeReimbursementDetailsAdmin 
{
    public String id {get;set;}
    public String contactid {get;set;}
    public String name {get;set;}
    public String month {get;set;}
    public String threshold {get;set;}
    public String totalMileages {get;set;}
    public String approvedMileages {get;set;}
    public String rejectedMileages {get;set;}
    public String status {get;set;}
    public String approvedDate {get;set;}
    public String lockDate {get;set;}   
    public Boolean isSelected {get;set;}
    public String managerName {get;set;}
    public Boolean isSelectedEmailReminder {get;set;}
    public Boolean reimbursementApproval {get;set;}
    public String mileageApproval {get;set;}
    public String managerEmail {get;set;}
}