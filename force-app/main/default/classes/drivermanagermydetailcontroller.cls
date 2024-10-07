public with sharing class drivermanagermydetailcontroller {
    public static String query;
    public static String totalmileages{get;set;}
    public static String totalvariableamount{get;set;}
    public static String contactDataAsString {get; set;}
    public static String gaspriceforpreviosmonth {get; set;}
    public static String gasVariableRatePreviosMonth {get; set;}
    public static List<contact> obj_currect_contact {get;set;}
    public static String obj_current_contact_details {get;set;}
    public String accInsuranceList {get; set;}
    public Integer insuranceSize {get;set;}
    public List<Attachment> obj_driver_insurance {get;set;}
    public List<Attachment> obj_driver_driverpacket {get;set;}
    public List<Attachment>  obj_driver_driverMVR {get;set;}
    public Integer obj_attachementsize {get;set;}
    public Integer obj_driverpacket_attachementsize {get;set;}
    public Integer obj_driverpacket_attachMVRsize {get;set;}
    public static Boolean showlastyear {get;set;}
    public static String logoDocument_id {get;set;}
    public String obj_content_version {get;set;}
    public static String managerrole {get;set;} 
    public drivermanagermydetailcontroller() {
        obj_currect_contact = new List<contact>();
        obj_current_contact_details = getDriverDetails();
        obj_driver_driverMVR = new List<Attachment>();
        List<contact> currentDriverList = new List<contact>();
        obj_current_contact_details= getDriverDetails();
        if(obj_current_contact_details != null) {
            obj_currect_contact = (List<Contact>)JSON.deserialize(obj_current_contact_details,List<Contact>.Class);
        }
        if(obj_currect_contact.size() > 0) {
            gaspriceforpreviosmonth = getDriverGasPrice(obj_currect_contact[0].MailingState,obj_currect_contact[0].MailingCity);
            gasVariableRatePreviosMonth = WrapperUtils.getDriverFuelVariableRate(obj_currect_contact[0].Id);
        }
        obj_driver_insurance = new List<Attachment>();
        obj_driver_driverpacket = new List<Attachment>();
        if(obj_currect_contact!=null && obj_currect_contact[0].Insurance_Attachment_Id__c != null) {
            obj_driver_insurance = [SELECT id, Body, Name FROM Attachment WHERE id =: obj_currect_contact[0].Insurance_Attachment_Id__c limit 1];    
        }
        obj_attachementsize = obj_driver_insurance.size();
        obj_driver_driverpacket = [SELECT id, Body, Name FROM Attachment WHERE ParentId =: ApexPages.currentPage().getParameters().get('id') and (Name LIKE '%Signed Document%' OR Name LIKE '%Driver_Packet%') limit 1];
        obj_driverpacket_attachementsize = obj_driver_driverpacket.size();
        obj_driver_driverMVR = [SELECT Id, Body, Name FROM Attachment WHERE ParentId=:ApexPages.currentPage().getParameters().get('id') and Name LIKE '%MVR%' limit 1];
        obj_driverpacket_attachMVRsize = obj_driver_driverMVR.size();
        accInsuranceList = '[]';
        List<Contact> conList = new List<Contact>();
        if(ApexPages.currentPage().getParameters().containsKey('manid')){
            conList = [SELECT id,name,Role__c 
                                    FROM Contact 
                                    WHERE id =: ApexPages.currentPage().getParameters().get('manid')];
        } else if (ApexPages.currentPage().getParameters().containsKey('managerid')){
            conList = [SELECT id,name,Role__c 
                                    FROM Contact 
                                    WHERE id =: ApexPages.currentPage().getParameters().get('managerid')];
        }
        if(conList.size() > 0 && conList[0].Role__c != null){
            managerrole = conList[0].Role__c ;   
        }             
        //AI-000414
        if(getContactid() != '' && getAccountid() != '')
        {
            List<Account> accInsurances = [SELECT id,Bodily_Injury__c, Uninsured_Motorist__c, Property_Damage__c, Comprehensive__c, Collision__c,Umbrella_Coverage__c FROM account WHERE Id =: getAccountid()];
           accInsuranceList = String.escapeSingleQuotes( JSON.serialize(accInsurances));
        }
        try{
            List<ContentDocumentLink> contentDocLink = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId  =: getContactid()];
            Set<Id> ids = new Set<Id>();
            for(ContentDocumentLink obj : contentDocLink){
                ids.add(obj.ContentDocumentId);
            }
            ContentDistribution contentDist = [SELECT id,ContentDownloadUrl from ContentDistribution where ContentDocumentId in : ids and Name=: Constants.signedDocument order by createddate desc limit 1];
            obj_content_version = contentDist.ContentDownloadUrl;
        }catch(Exception e){System.debug('Exception:-->'+e.getmessage()+'--'+e.getLineNumber());}
    }
    public static String getAccountid() {
        if(ApexPages.currentPage().getParameters().containsKey('accid')) {
           return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        } 
    }
    public static String getContactid() {
        if(ApexPages.currentPage().getParameters().containsKey('id')) {
           return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        } 
    }
    public static PageReference getRedirected() {        
        if(getContactid()!=''&& getAccountid()!='') {
            return null;
        } else {
            // redirect to error page
            return null;
        }        
    }
    public static String getLast2Years() {
        return String.escapeSingleQuotes(WrapperUtils.getpastYearReimbursement(getContactid()));
    }
    @RemoteAction
    public Static String getAllReimbursements(String year,String contactId,String accountId) {       
       return String.escapeSingleQuotes(WrapperUtils.getAllReimbursements(year,contactId,accountId));
    }
    
    public static String getReimbursementsList() {   
          return String.escapeSingleQuotes(WrapperUtils.getReimbursementsList(getContactid(),'Approved'));
    }
    public static String getDriverDetails() {            
       string contactid=getContactid();
       return getDriverDetailsClone(contactid);        
    }
    @RemoteAction
    public static String getDriverDetailsClone(String contactid) {   
        obj_currect_contact = [SELECT id, Name, MailingPostalCode, MailingState, MailingCity,Driver_Type__c,Role__c, 
                                        Fixed_Amount__c, compliancestatus__c, Car_Image__c, Account.Name, Account.Logo_Document_Id__c, 
                                        Vehicle_Type__c,Insurance_Attachment_Id__c, Account.Triplog_API__c, Email,
                                        Maintenance__c,Tires__c, Insurance_Rate__c, License_Ragistration__c, Taxes__c,
                                        Depreciation__c, Total_Monthly_Costs__c, Business_Use__c,Fixed_Cost_Adjustment__c,
                                        Monthly_Reimbursement__c,Biweek_Reimbursement__c,Time_Attandance__c,
                                        Account.Bi_Weekly_Pay_Period__c
                                    FROM Contact 
                                    WHERE id =: contactid];
        //return JSON.serialize(obj_currect_contact).unescapeHtml4();
        return JSON.serialize(obj_currect_contact ).unescapeHtml4();
    }
    public static String getDriverGasPrice(String MailingState,String MailingCity) {   
         return WrapperUtils.getDriverGasPrice(MailingState,MailingCity);
    }
    @RemoteAction
    public static List<String> getMileages(String clickedMonth,String year,String contactId) {
         return WrapperUtils.getMileages1(clickedMonth,year,contactId);
    }  
    @RemoteAction
    public static String getdriverInsurance(String drid,string attachmentid) {
        List<Attachment> obj_driver_insurance = [select id,Body,Name from Attachment where id=:attachmentid];
        return String.escapeSingleQuotes(JSON.serialize(obj_driver_insurance));
    }
    @RemoteAction
    public static List<String> getCompliance(String contactId) {
         return WrapperUtils.getComplianceCalculation(contactId,String.valueOf(System.today().year()));
    }
    @RemoteAction
    public static List<String> getPacketandMeeting(String contactId) {
        return WrapperUtils.getPacketandMeetingDetails(contactId);
    }   

    @RemoteAction
    public static String readFromFileInchunk(String attachmentBody, String attachmentName, String attachmentId,String contactId,String accountId,String contactattachementid) {
         return  WrapperUtils.readFromFileInchunk(attachmentBody,attachmentName,attachmentId,contactId,accountId,contactattachementid); 
    }  

    //AI-000587 
    @RemoteAction
    public static List<BiweeklyPayPeriod.TimeAttedanceWrap> TimeAttendance(String conId,String year){
        return BiweeklyPayPeriod.getTimeAndAttendance(conId,year);
    }

    @RemoteAction
    public static String getMileagesBasedTandAtt(String startdate,String enddate,String contactId) {
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
    public static List<String> getBiweekMileages(string biweekId) {
        return BiweeklyPayPeriod.getBiweekMileages1(biweekId);
        //return BiweeklyPayPeriod.getMileages1(date.valueof(startdate),date.valueof(enddate),contactId);
    } 

    @RemoteAction
    public static string ApproveBiweekMileages(string biweekId) {
        //BiweeklyPayPeriod.ApproveTrips(date.valueof(startdate),date.valueof(enddate),contactId);
        BiweeklyPayPeriod.ApproveBiWeekTrips(biweekId);
        return 'sucess';
    } 
    @RemoteAction
    public static List<String> getAllMileages(String startdate,String enddate,String contactId) {
        return BiweeklyPayPeriod.getAllBiweekMileages1(date.valueof(startdate),date.valueof(enddate),contactId);
    }
    @RemoteAction
    public static void sendInsuranceEmail (String Id,String Name,String email){
        BiWeeklyWrapperUtils.sendInsuranceEmail(Id, Name, email);
    }
}