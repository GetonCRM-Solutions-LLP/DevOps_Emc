/**
@author Natavar Ghodasara
@date 26th Feb 2019
@group Wrapper
@group-content WrapperDetails.html
@description EmployeeDetails is used to Build Wrapper of Contact.
*/
public with sharing class EmployeeDetails 
{
    /*******************************************************************************************************
    * @description userid is Contact id.
    */
    public String userid {get;set;}
    /*******************************************************************************************************
    * @description name is Contact name.
    */
    public String name {get;set;}
    /*******************************************************************************************************
    * @description firstName is Contact First Name.
    */
    public string firstName {get;set;}
    /*******************************************************************************************************
    * @description lastName is Contact Last Name.
    */
    public string lastName {get;set;}
    /*******************************************************************************************************
    * @description email is Contact email and External_Email__c.
    */
    public string email {get;set;}
    /*******************************************************************************************************
    * @description zipCode is Contact Mailing Zip/Postal Code.
    */
    public string zipCode {get;set;}
    /*******************************************************************************************************
    * @description city is Contact Mailing City.
    */
    public string city {get;set;}
    /*******************************************************************************************************
    * @description state is Contact Mailing State/Province of 2 characters.
    */
    public string state {get;set;}
    /*******************************************************************************************************
    * @description employeeId is Contact Employee_ID__c.
    */
    public string employeeId {get;set;}
    /*******************************************************************************************************
    * @description activationDate is Contact Activation_Date__c.
    */
    public String activationDate {get;set;}
    /*******************************************************************************************************
    * @description role is Contact Role__c.
    */
    public string role {get;set;}
    /*******************************************************************************************************
    * @description managerId is Contact Manager__c.
    */
    public string managerId {get;set;}
    /*******************************************************************************************************
    * @description managerName is Contact Manager__r.name.
    */
    public string managerName{get;set;}
    /*******************************************************************************************************
    * @description vehicalType is Contact Vehicle_Type__c.
    */
    public string vehicalType {get;set;}
    /*******************************************************************************************************
    * @description drivingStates is Contact Driving_States__c (Multi Select Picklist).
    */
    public List<string> drivingStates {get;set;}
    /*******************************************************************************************************
    * @description deactivaedDate is Contact Deactivated_Date__c.
    */  
    public String deactivaedDate {get;set;}
    /*******************************************************************************************************
    * @description lastPayDate is Contact Last_Pay_Date__c.
    */  
    public String lastPayDate {get;set;}
    /*******************************************************************************************************
    * @description approvalThreshold is Contact Last_Pay_Date__c.
    */  
    public String approvalThreshold {get;set;}
    /*******************************************************************************************************
    * @description editmode is used in Visualforce page for editing Contact.
    */
    //public boolean editmode{get;set;}
    /*******************************************************************************************************
    * @description Accountid is Contact Account.
    */
    public string accountId {get;set;}
    public string appVersion {get;set;}
    public string manualEntryUser {get;set;}
    public string cellphone {get;set;}
    public string totalreimbursement {get;set;}
    public string compliancestatus {get;set;}
    public string monthlymileageLimit {get;set;}
    public string fixedamount{get;set;}
    public string branchName{get;set;}
    public string branchNumber{get;set;}
    public boolean IsDeactivated{get;set;}
    public boolean resetReimbursementLink {get;set;}
    public string monthlymileage{get;set;}
    public string sage100ID{get;set;}
    public string glcode{get;set;}
    public string addedDate {get;set;}
    public boolean IsMassDeactivated{get;set;}
    public Boolean IsMassFreeze{ get; set; }
    public String freeze{ get; set; }
    public string driverType {get;set;}
    public string netchexEmployeeID {get;set;}
    public string district {get;set;}
    public string code {get;set;}
    public string territory {get;set;}
    public string jobtitle {get;set;}
    public string department {get;set;}
    public string deptDesign {get;set;}
    public String deactivationBy {get;set;}
    public string deptPL {get;set;}
    public string divison {get;set;}
    public string loaStartDate {get;set;}
    public string loaEndDate {get;set;}
    public string payRollPeriod {get;set;}
    public string loaFixedAmount {get;set;}
    public boolean isleaveofabsence{get;set;}
    public string finalPayrollAmount {get;set;}
    public string firstPayrollPer {get;set;}
    /* EMC - 2396 added by Megha below (packet) */
    public string packet {get;set;}
    // Megha : Added boolean value to set contact field value IsDeactivated while deactivating user
    public boolean deactivateUser{get;set;}
    /*EMC-260 START 
    This field is used to check that particular driver is monthly or biweekly driver.based on value of checkbox display a data on driver page*/
    public Boolean monthlyReimbursement{ get; set; }
    public Boolean biWeekReimbursement{ get; set; }
    // timeAttandance is only use for ERMI account
    public Boolean timeAttandance{ get; set; }
    /* END */
    /*EMC - 331 */
    //Below am and an field is used for SurfacePrep account.
    public string company {get;set;}
    public string am {get;set;}
    public string an {get;set;}
    public string costCode {get;set;}
    public string appSetting {get;set;}
    public string Businesshours {get;set;}
    public String lastSynced {get;set;}
    /** by khuman*/
    public decimal mileageForDeduction {get;set;}
    // EMC-2356 Paras Dhanani
    public String bpCode {get;set;}
    public Boolean resendDriverPacket{ get; set; }
    /*******************************************************************************************************
    * @description ReimbursementFrequency is Contact Reimbursement_Frequency__c.
    */  
    public String ReimbursementFrequency {get;set;}
     /*******************************************************************************************************
    * @description CellPhoneProvider is Contact Cell_Phone__c.
    */  
    public String CellPhoneProvider {get;set;}
    public String accountCellPhoneProvider {get;set;}
    public String accountReimbursementFrequency {get;set;}
    
}