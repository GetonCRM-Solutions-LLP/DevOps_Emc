public  class DriverDashboardFromAdminManager 
{
    public static String query;
    public static String totalmileages{get;set;}
    public static String totalvariableamount{get;set;}
    public static String contactDataAsString {get; set;}
    public static String gaspriceforpreviosmonth {get; set;}
    public static String gasVariableRatePreviosMonth {get; set;}
    public static List<contact>  obj_currect_contact {get;set;}
    public static String obj_current_contact_details {get;set;}
    public List<Attachment>  obj_driver_insurance {get;set;}
    public List<Attachment>  obj_driver_driverpacket {get;set;}
    public List<Attachment>  obj_driver_driverMVR {get;set;}
    public Integer obj_attachementsize {get;set;}
    public Integer obj_driverpacket_attachementsize {get;set;}
    public Integer obj_driverpacket_attachMVRsize {get;set;}
    public static Boolean showlastyear {get;set;}
    public static String nameofEmployee{get;set;}
    public static String emailofEmployee{get;set;}
    public String obj_content_version {get;set;}
    //public static String htmlContent{get;set;}

    public DriverDashboardFromAdminManager() 
    {
        obj_currect_contact = new List<contact>();
        obj_driver_insurance = new List<Attachment>();
        obj_driver_driverpacket = new List<Attachment>();
        obj_driver_driverMVR = new List<Attachment>();

        obj_driver_driverpacket = [SELECT Id, Body, Name FROM Attachment WHERE ParentId=:ApexPages.currentPage().getParameters().get('id') and (Name LIKE '%Signed Document%' OR Name LIKE '%Driver_Packet%') limit 1];
        obj_driverpacket_attachementsize = obj_driver_driverpacket.size();
        
        obj_driver_driverMVR = [SELECT Id, Body, Name FROM Attachment WHERE ParentId=:ApexPages.currentPage().getParameters().get('id') and Name LIKE '%MVR%' limit 1];
        obj_driverpacket_attachMVRsize = obj_driver_driverMVR.size();

        obj_current_contact_details = getDriverDetails();
        //htmlContent = getHtml();
        setEmployeeName();
        obj_driver_insurance = [SELECT id, Body, Name FROM Attachment WHERE id=:obj_currect_contact[0].Insurance_Attachment_Id__c limit 1];
        obj_attachementsize = obj_driver_insurance.size();
        if(obj_currect_contact.size() > 0) {
            gaspriceforpreviosmonth = getDriverGasPrice(obj_currect_contact[0].MailingState,obj_currect_contact[0].MailingCity);
            gasVariableRatePreviosMonth = WrapperUtils.getDriverFuelVariableRate(obj_currect_contact[0].Id);
        }
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
        //getpastYearReimbursement();

    }
    /*public static String getHtml(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'dynamicFile' LIMIT 1];
        String body = sr.Body.toString();
        System.debug('body=' + body);
        return body;
    }*/
    public static String getAccountid()
    {
        if(ApexPages.currentPage().getParameters().containsKey('accid') && String.isNotEmpty(ApexPages.currentPage().getParameters().get('accid')))
        {
           return ApexPages.currentPage().getParameters().get('accid');
        }
        else
        {
            return '';
        } 
    }    
    public static String getAdminid()
    {
        // manager id
        if(ApexPages.currentPage().getParameters().containsKey('adminid') && String.isNotEmpty(ApexPages.currentPage().getParameters().get('adminid')))
        {
           return ApexPages.currentPage().getParameters().get('adminid');
        }
        else
        {
            return '';
        } 
    }
    public static void setEmployeeName() {
        Contact employee= [SELECT Name, External_Email__c FROM Contact WHERE id =: getAdminid()];
        if(employee!=null)
        {
            nameofEmployee= String.escapeSingleQuotes(employee.Name); // Name of the Employee
            emailofEmployee = employee.External_Email__c;
        }
        else
        {
            nameofEmployee='';
            emailofEmployee ='';
            
        }       
    } 
    public static String getDriverid()
    {
        
        if(ApexPages.currentPage().getParameters().containsKey('id') && String.isNotEmpty(ApexPages.currentPage().getParameters().get('id')))
        {
           return ApexPages.currentPage().getParameters().get('id');
        }
        else
        {
            return '';
        } 
    }
    public static PageReference getRedirected()
    {
        
        if(getAdminid()!=''&& getAccountid()!='' && getDriverid()!='')
        {
            return null;
        }
        else
        {
            // redirect to error page
            return null;
        }
        
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

     public static String getLast2Years()
    {
        //getpastYearReimbursement();
        //return WrapperUtils.getLast2Years();
        return String.escapeSingleQuotes(WrapperUtils.getpastYearReimbursement(getDriverid()));
    }
    
    @RemoteAction
    public Static String getAllReimbursements(String year,String contactId,String accountId) 
    {       
         System.debug('year'+year);
        return String.escapeSingleQuotes(WrapperUtils.getAllReimbursements(year,contactId,accountId));
    }
    
    public static String getReimbursementsList()
    {   
         return String.escapeSingleQuotes(WrapperUtils.getReimbursementsList(getDriverid(),'Approved'));
    }
    @RemoteAction
    public static String getReimbursementsListClone(String driverid)
    {
        return String.escapeSingleQuotes(WrapperUtils.getReimbursementsListClone(driverid));
    }
    public static String getDriverDetails()
    {   
        obj_currect_contact = [SELECT id, Name, MailingPostalCode, MailingState, MailingCity,Driver_Type__c, 
                                        Fixed_Amount__c, compliancestatus__c, Car_Image__c, Account.Name, Account.Logo_Document_Id__c, 
                                        Vehicle_Type__c,Insurance_Attachment_Id__c, Account.Triplog_API__c, Email,
                                        Maintenance__c,Tires__c, Insurance_Rate__c, License_Ragistration__c, Taxes__c,
                                        Depreciation__c, Total_Monthly_Costs__c, Business_Use__c,Fixed_Cost_Adjustment__c,
                                        Monthly_Reimbursement__c,Biweek_Reimbursement__c,Time_Attandance__c,
                                        Account.Bi_Weekly_Pay_Period__c
                                    FROM Contact 
                                    WHERE id =: getDriverid()];
        return String.escapeSingleQuotes(JSON.serialize(obj_currect_contact));
    }
    public static String getDriverGasPrice(String MailingState,String MailingCity)
    {   
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
        system.debug('checked'+checked);
        return WrapperUtils.approveMileagesForAdminDash(checked,selected,unapprove,name,emailaddress);
    }
    @RemoteAction
    public static String getMileages(String clickedMonth,String clickedYear,String contactId)
    {
        return String.escapeSingleQuotes(WrapperUtils.getMileages(clickedMonth,clickedYear,contactId));
    } 
    @RemoteAction
    public static List<String> getCompliance(String contactId)
    {
    System.debug('getCompliance'+contactId);
        return WrapperUtils.getComplianceCalculation(contactId,String.valueOf(System.today().year()));
       
    }
    @RemoteAction
    public static List<String > getPacketandMeeting(String contactId)
    {
        return WrapperUtils.getPacketandMeetingDetails(contactId);
    }   

    //method is use for fatch mileages from triplog 
    //AI-000429
    @RemoteAction
    public static void TripCallout(Id driverId, String month, String year, String fuel, String maintTyre, Id empReID,String mpg,String status){
        System.debug('=='+status);
        WrapperUtils.TripCallout(driverId,month,year,fuel,maintTyre,empReID,mpg,status);
    }

    //method is use for change reimbursement status 
    //AI-000429
    @RemoteAction
    public static void UpdateReimbursementStatus(Id empReID){
        WrapperUtils.UpdateReimbursementStatus(empReID);
    }

    //AI-000435 Method is use for concer expense triplog api
    @RemoteAction
    public static void postExpenseReimbursement(Id accountId,String empReMonth,String contactEmail,String totalReimburement){
        UploadConcurQuickExpenseTriplog.postTotalReimbursement(accountId,empReMonth,contactEmail,totalReimburement);
    }

    ////AI-000587   
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
    public static List<String> getBiweekMileages(String biweekId)
    {
        //return BiweeklyPayPeriod.getMileages1(date.valueof(startdate),date.valueof(enddate),contactId);
        return BiweeklyPayPeriod.getBiweekMileages1(biweekId);
    } 

    @RemoteAction
    public static string ApproveBiweekMileages(String biweekId)
    {
        //BiweeklyPayPeriod.ApproveTrips(date.valueof(startdate),date.valueof(enddate),contactId);
        BiweeklyPayPeriod.ApproveBiWeekTrips(biweekId);
        return 'sucess';
    } 
    @AuraEnabled
    public static String getUnapprovedMileages(String reimbursementDetails) // Please change the method body,UI Dev require to pass the several parameters
    {
        system.debug('inside getUnapprovedMileages'+reimbursementDetails);
        return String.escapeSingleQuotes(WrapperUtils.getUnapprovedMileages(reimbursementDetails));
    }
    @AuraEnabled
    public static string getAllDriversLastMonthUpdatedReimbursements(String contactId, String accountId,String showTeamRecord) {
        return String.escapeSingleQuotes(WrapperUtils.getLastMonthReimbursements(contactId,accountId,boolean.valueOf(showTeamRecord),'Admin'));
    }  
    @AuraEnabled
    public static string getAllDriversLastMonthUnapprovedReimbursementsClone(String contactId, String accountId,String showTeamRecord) 
    {        
        return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(contactId,accountId,boolean.valueOf(showTeamRecord),'Admin'));
    }  
    @RemoteAction
    public static List<String> getAllMileages(String startdate,String enddate,String contactId)
    {
        return BiweeklyPayPeriod.getAllBiweekMileages1(date.valueof(startdate),date.valueof(enddate),contactId);
    } 
}