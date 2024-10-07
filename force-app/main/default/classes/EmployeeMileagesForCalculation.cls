public with sharing class EmployeeMileagesForCalculation {

    public String reimbursementid {get;set;}
    public String id {get;set;} //Megha
    public String mileageid {get;set;}
    public String contactid {get;set;}
    public String contactEmail {get;set;}
    public String fuel {get;set;}
    public String maintainsAndTyres {get;set;}
    public String mpg {get; set;}
    public String accountApi{get; set;}
    public String reimbursementFrequency{get; set;}
    public String name {get;set;}
    public String month {get;set;}
    public String threshold {get;set;}
    public String totalMileages {get;set;}
    public List<EmployeeMileages> mileagesList {get;set;}
    public String approvedMileages {get;set;}
    public String TotalReimMileages {get;set;}
    public String status {get;set;}
//  public String approvedDate {get;set;}   
    public Boolean isSelected {get;set;}
    public Boolean reimbursementApproval {get;set;}
    public List<String> reimbursementIdList {get;set;}
    public String managerName{get;set;}
    public Boolean isSelectedEmailReminder {get;set;}
    public String mileageApproval {get;set;}
    public String managerEmail {get;set;}
    public String lockDate {get;set;}   
    public String rejectedMileges {get;set;}  
    public String rejectedMileages {get;set;}  //Megha
    public Double totalHighRiskMileages {get;set;}
    public Double highRiskTotalApproved {get;set;}
    public Double highRiskTotalRejected {get;set;}
    public Double highRiskTotalPending {get;set;}
    public String originalReimbursementid {get;set;}
    public boolean highRiskMileage{get; set;}
    
    public EmployeeMileagesForCalculation() {
        
    }
}