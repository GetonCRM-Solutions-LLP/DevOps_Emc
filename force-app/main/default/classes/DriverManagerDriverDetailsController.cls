/**
@author Natavar Ghodasara
@date 29th March 2019
@description DriverManagerDetailsController is used to show/edit Employee details.
*/
public with sharing class DriverManagerDriverDetailsController 
{
    public static String query;
    public static String totalmileages{get;set;}
    public static String totalvariableamount{get;set;}
    public static String contactDataAsString {get; set;}
    public static String gaspriceforpreviosmonth {get; set;}
    public static String gasVariableRatePreviosMonth {get; set;}
    public static List<contact> obj_currect_contact {get;set;}
    public static String nameofEmployee{get;set;}
    public static String emailofEmployee{get;set;}
    public static String obj_current_contact_details {get;set;}
    public List<Attachment> obj_driver_insurance {get;set;}
    public List<Attachment> obj_driver_driverpacket {get;set;}
    public List<Attachment>  obj_driver_driverMVR {get;set;}
    public Integer obj_attachementsize {get;set;}
    public Integer obj_driverpacket_attachementsize {get;set;}
    public Integer obj_driverpacket_attachMVRsize {get;set;}
    public static Boolean showlastyear {get;set;}
    public String obj_content_version {get;set;}
    /**
    @author Natavar Ghodasara
    @date 26th Feb 2019
    @description RosterController is Default Constructor.    
    */
    public DriverManagerDriverDetailsController() 
    {
        obj_currect_contact = new List<contact>();
         System.debug('obj_currect_contact:--'+obj_currect_contact);
        obj_driver_driverMVR = new List<Attachment>();
        obj_current_contact_details = getDriverDetails();
        setEmployeeName();
        System.debug('obj_currect_contact:--'+obj_currect_contact);
        if(obj_currect_contact.size()>0) {
            gaspriceforpreviosmonth = getDriverGasPrice(obj_currect_contact[0].MailingState,obj_currect_contact[0].MailingCity);
            gasVariableRatePreviosMonth = WrapperUtils.getDriverFuelVariableRate(obj_currect_contact[0].Id);
        }
        obj_driver_insurance = new List<Attachment>();
        obj_driver_driverpacket = new List<Attachment>();
        obj_driver_insurance = [SELECT id, Body, Name FROM Attachment WHERE id=:obj_currect_contact[0].Insurance_Attachment_Id__c limit 1];
        obj_attachementsize = obj_driver_insurance.size();
        obj_driver_driverpacket = [SELECT id, Body, Name FROM Attachment WHERE ParentId=:ApexPages.currentPage().getParameters().get('id') and (Name LIKE '%Signed Document%' OR Name LIKE '%Driver_Packet%') limit 1];
        obj_driverpacket_attachementsize = obj_driver_driverpacket.size();
        obj_driver_driverMVR = [SELECT Id, Body, Name FROM Attachment WHERE ParentId=:ApexPages.currentPage().getParameters().get('id') and Name LIKE '%MVR%' limit 1];
        obj_driverpacket_attachMVRsize = obj_driver_driverMVR.size();
        try{
            List<ContentDocumentLink> contentDocLink = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId  =: getDriverid()];
            Set<Id> ids = new Set<Id>();
            for(ContentDocumentLink obj:  contentDocLink){
                ids.add(obj.ContentDocumentId);
            }
            ContentDistribution contentDist = [SELECT id,ContentDownloadUrl from ContentDistribution where ContentDocumentId in : ids and Name=: Constants.signedDocument order by createddate desc limit 1];
            obj_content_version = contentDist.ContentDownloadUrl;
            System.debug('obj_content_version-->'+obj_content_version);
        }catch(Exception e){System.debug('Exception:-->'+e.getmessage()+'--'+e.getLineNumber());}
    }
    public static String getAccountid() {
        if(ApexPages.currentPage().getParameters().containsKey('accid')) {
           return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        } 
    }
    public static String getDriverid() {        
        if(ApexPages.currentPage().getParameters().containsKey('id')) {
           return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        } 
    }
    public static String getManagerid() {        
        if(ApexPages.currentPage().getParameters().containsKey('manid')) {
           return ApexPages.currentPage().getParameters().get('manid');
        } else {
            return '';
        } 
    }
    public static PageReference getRedirected() {        
        if(getAccountid()!='' && getDriverid()!='' && getManagerid()!='') {
            return null;
        } else {
            // redirect to error page
            return null;
        }        
    }
    public static void setEmployeeName() {
        Contact employee= [SELECT Name, External_Email__c FROM Contact WHERE id =: getManagerid()];
        if(employee != null) {
            nameofEmployee= String.escapeSingleQuotes(employee.Name); // Name of the Employee
            emailofEmployee = employee.External_Email__c;
        } else {
            nameofEmployee='';
            emailofEmployee ='';  
        }       
    } 
    public static String getLast2Years() {
        // getpastYearReimbursement();
        // return WrapperUtils.getLast2Years();
        return String.escapeSingleQuotes(WrapperUtils.getpastYearReimbursement(getDriverid()));
    }
    // public static void getpastYearReimbursement(){
        
    //     if(WrapperUtils.getpastYearReimbursement(getDriverid()) > 0)
    //     {
    //         showlastyear = true;
    //     }
    //     else
    //     {
    //         showlastyear = false;
    //     }   
    // }
    //This method is use to get all reimbrsement data for a particular driver and for particular year.
    @RemoteAction
    public Static String getAllReimbursements(String year,String contactId,String accountId) {       
       return String.escapeSingleQuotes(WrapperUtils.getAllReimbursements(year,contactId,accountId));
    }    

    public static String getReimbursementsList() {   
        return String.escapeSingleQuotes(WrapperUtils.getReimbursementsList(getDriverid(),''));     
    }
    public static String getDriverDetails() {            
        //List<contact> obj_currect_contact = new List<contact>();
        obj_currect_contact = [SELECT Id, Name, MailingPostalCode, MailingState, MailingCity, 
                                        Fixed_Amount__c, compliancestatus__c, Car_Image__c,Insurance_Attachment_Id__c,
                                        Account.Name, Account.Logo_Document_Id__c, Vehicle_Type__c,
                                        Maintenance__c,Tires__c, Insurance_Rate__c, License_Ragistration__c, Taxes__c,
                                        Depreciation__c, Total_Monthly_Costs__c, Business_Use__c ,Fixed_Cost_Adjustment__c,
                                        Monthly_Reimbursement__c,Biweek_Reimbursement__c,Time_Attandance__c,
                                        Account.Bi_Weekly_Pay_Period__c
                                    FROM Contact 
                                    WHERE id =: getDriverid()];
        System.debug('obj_currect_contact:--'+obj_currect_contact);
        return String.escapeSingleQuotes(JSON.serialize(obj_currect_contact));
    }

    public static String getDriverGasPrice(String MailingState,String MailingCity) {   
        return WrapperUtils.getDriverGasPrice(MailingState,MailingCity);
    }

    @RemoteAction
    public static String approveReimbursements(String year,String contactId,String accountId,String reimbursements)
    {
        return WrapperUtils.approveReimbursements(year,contactId,accountId,reimbursements);
    }
    @RemoteAction
    public static String approveMileages(String checked,String selected,String unapprove,String name,String emailaddress)
    {        
        return WrapperUtils.approveMileagesForAdminDash(checked,selected,unapprove,name,emailaddress);
    }
    @RemoteAction
    public static String getMileages(String clickedMonth,String clickedYear,String contactId)
    {
         return String.escapeSingleQuotes(WrapperUtils.getMileages(clickedMonth,clickedYear,contactId));
    }
    @RemoteAction
    public static String getReimbursementsListClone(String driverid)
    {
       return String.escapeSingleQuotes(WrapperUtils.getReimbursementsListClone(driverid));
    }
    @RemoteAction
    public static List<String> getCompliance(String contactId)
    {
        return WrapperUtils.getComplianceCalculation(contactId,String.valueOf(System.today().year()));
    }
    @RemoteAction
    public static List<String> getPacketandMeeting(String contactId)
    {
        return WrapperUtils.getPacketandMeetingDetails(contactId);
    }
   /* @RemoteAction
    public static List<Attachment> getPacketAttachment(String contactId)
    {
        return WrapperUtils.getPacketAttachments(contactId);
    }*/
    
    //method is use for fatch mileages from triplog 
    //AI-000429
    @RemoteAction
    public static void TripCallout(Id driverId, String month, String year, String fuel, String maintTyre, Id empReID,String mpg,string status){
        WrapperUtils.TripCallout(driverId,month,year,fuel,maintTyre,empReID,mpg,status);
    }

    //method is use for change reimbursement status 
    //AI-000429
    @RemoteAction
    public static void UpdateReimbursementStatus(Id empReID){
        WrapperUtils.UpdateReimbursementStatus(empReID);
    }

    //AI-000587 
    @RemoteAction
    public static List<BiweeklyPayPeriod.TimeAttedanceWrap> TimeAttendance(String conId,String year){
        return BiweeklyPayPeriod.getTimeAndAttendance(conId,year);
    }

    @RemoteAction
    public static String getMileagesBasedTandAtt(String startdate,String enddate,String contactId)
    {
        return String.escapeSingleQuotes(WrapperUtils.getMileagesBasedTA(startdate,enddate,contactId));
    } 
    @RemoteAction
    public static List<BiweeklyPayPeriod.BiweeklyWrap> biweeklyMileage(String conId,Integer year){
        //return BiweeklyPayPeriod.getBiweeklyMileage(conId,year);
        return BiweeklyPayPeriod.getBiweeklyReimbursement(conId,year);
    }

    /*EMC-260 
    Author : Sanket Goswami
    Description : This method is used to get mileages with biweekly reimbursement data based on biweekly reimbursement selected by user*/
    @RemoteAction
    public static List<String> getBiweekMileages(string biweekId)
    {
        //return BiweeklyPayPeriod.getMileages1(date.valueof(startdate),date.valueof(enddate),contactId);
        return BiweeklyPayPeriod.getBiweekMileages1(biweekId);
    } 

    @RemoteAction
    public static string ApproveBiweekMileages(string biweekId)
    {
        //BiweeklyPayPeriod.ApproveTrips(date.valueof(startdate),date.valueof(enddate),contactId);
        BiweeklyPayPeriod.ApproveBiWeekTrips(biweekId);
        return 'sucess';
    } 
    @RemoteAction
    public static List<String> getAllMileages(String startdate,String enddate,String contactId)
    {
        return BiweeklyPayPeriod.getAllBiweekMileages1(date.valueof(startdate),date.valueof(enddate),contactId);
    }
}