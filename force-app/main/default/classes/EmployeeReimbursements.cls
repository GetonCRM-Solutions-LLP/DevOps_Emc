/**
@author Natavar Ghodasara
@date 26th Feb 2019
@group Wrapper
@group-content WrapperDetails.html
@description EmployeeReimbursements is used to Build Wrapper of Reimbursements.
*/
public with sharing class EmployeeReimbursements 
{
    /*******************************************************************************************************
    * @description employeeReimbursementId is Employee Reimbursement id.
    */
    public String employeeReimbursementId {get;set;}
    /*******************************************************************************************************
    * @description isSelected.
    */
    public boolean isSelected {get;set;}
    /*******************************************************************************************************
    * @description Approved date.
    */
    public String approveddate {get;set;}
    /*******************************************************************************************************
    * @description status.
    */
    public String status {get;set;}
    /*******************************************************************************************************
    * @description variableRate is Employee_Reimbursement__c's Total_Variable_Rate__c.
    */
    public String variableRate {get;set;}
    /*******************************************************************************************************
    * @description month is Employee_Reimbursement__c's Month__c.
    */
    public String month {get;set;}
    /*******************************************************************************************************
    * @description intmonth is Employee_Reimbursement__c's Month__c.
    */
    public Integer intmonth {get;set;}
    /*******************************************************************************************************
    * @description fuel is Employee_Reimbursement__c's Fuel_Price__c.
    */
    public String fuel {get;set;}
    /* EMC-260  START
        Added a new field : Total_Approved__c,Total_Mileage__c, Total_Pending__c  
        Modified By : Sanket Goswami */
    /*******************************************************************************************************
    * @description mileage is Employee_Reimbursement__c's Total_Mileage__c.
    */
    public String mileage {get;set;}
    /*******************************************************************************************************
    * @description pendingMileage is Employee_Reimbursement__c's Total_Pending__c.
    */
    public String pendingMileage {get;set;}
    /*******************************************************************************************************
    * @description approveMileage is Employee_Reimbursement__c's Total_Approved__c.
    */
    public String approveMileage {get;set;}
    /* EMC-260  END */
    /*******************************************************************************************************
    * @description varibleAndFixedReimbursements is Employee_Reimbursement__c's Fixed_Amount__c + Employee_Reimbursement__c's Variable_Rate__c.
    */
    public String varibleAndFixedReimbursements {get;set;}
    /*******************************************************************************************************
    * @description totalReimbursements is Employee_Reimbursement__c's Total_Monthly_Reimbursement__c.
    */
    public String totalReimbursements {get;set;}
    /*******************************************************************************************************
    * @description maintainsAndTyres is Employee_Reimbursement__c's Maintenance_and_Tires__c.
    */
    public String maintainsAndTyres {get;set;}
    /*******************************************************************************************************
    * @description mpg is Employee_Reimbursement__c's MPG__c.
    */
    public String mpg {get; set;}
    /*******************************************************************************************************
    * @description varibleAmount is Employee_Reimbursement__c's Monthly_Variable_Amount__c.
    */
    public String varibleAmount {get;set;}
    public String fixed1 {get; set;}
    public String fixed2 {get; set;}
    public String fixed3 {get; set;}
    /*******************************************************************************************************
    * @description totalFixedAmount is Number of pay period * Employee_Reimbursement__c's Half_Fixed_Amount__c.
    */
    public String totalFixedAmount {get;set;}
    /*******************************************************************************************************
    * @description contactEmail is Employee_Reimbursement__c's Contact_Email__c.
    */
    public String contactEmail {get; set;}
    /*******************************************************************************************************
    * @description contactdrivertype is Employee_Reimbursement__r.Contact_Id__r.Driver_Type__c.
    */
    public String contactdrivertype {get;set;}
    public String fixedAmount {get;set;}
    public String avgToDate {get;set;}
    //@description If Lock date should be available then Lock date user should be display
    public date lockDate {get;set;}
    public String lockDateUserName {get; set;}
    public Boolean syncMileageBtn {get;set;}
    public Boolean concurBtn {get;set;}
    /**
    @author Natavar Ghodasara
    @date 26th Feb 2019
    @description Default Constructor.
    */
    public EmployeeReimbursements() 
    {
        
    }
}