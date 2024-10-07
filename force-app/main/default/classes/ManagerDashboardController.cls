/**
 * @Author: GetonCRM Solutions LLP
 * @Description: this class represent methods related to dashboard in Mdash including the profile manger/driver, admin/driver ,Admin, Manager.
 * @Modification logs
 * ========================================================================================================================
 * @Date:  4th june 2019 | Natavar Ghodasara
 *
 */
public class ManagerDashboardController
{   //These are public static properties used to store information related to the dashboard.
    public static String totalmileages{get;set;}
    public static String totalvariableamount{get;set;}
    public static String nameofEmployee{get;set;}
    public static String emailofEmployee{get;set;}
    public static Boolean showMyTeam {get;set;}
    public static string videoCustom {get;set;}
//constructor  setting up required this before execution of any other method these varible will be set on loading of the class
    public ManagerDashboardController(){
        setEmployeeName();
        NewDashboardVideoLink__c videoCustomSetting = NewDashboardVideoLink__c.getOrgDefaults();
        videoCustom = json.serialize(videoCustomSetting );
    }
    //This methods retrieve information from the current page parameters providing account id
    public static String getAccountid(){
        if(ApexPages.currentPage().getParameters().containsKey('accid') && String.isNotBlank(ApexPages.currentPage().getParameters().get('accid')))        {
            return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        }
    }
    //This methods retrieve information from the current page parameters providing Contact id
    public static String getContactid()
    {
        if(ApexPages.currentPage().getParameters().containsKey('id') && String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
           return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        }
    }
    //This methods will define the checkbox which in tern gives admin access to his contacts
     public static String getShowTeam() {
        if (ApexPages.currentPage().getParameters().containsKey('showteam') && String.isNotBlank(ApexPages.currentPage().getParameters().get('showteam'))) {
            return ApexPages.currentPage().getParameters().get('showteam');
        } else {
            return '';
        }
    }
    //this method return a reference link which will help in redirection
    public static PageReference getRedirected()
    {
        if(getContactid()!=''&& getAccountid()!='' && getShowTeam() != '')        {
            setEmployeeName(); // sets the Name of the Employee name and Show team record Values according to Database.
            return null;
        } else {
            // redirect to error page
            return null;
        }
    }


  // This method is sending the details of user whoes id is passed in the argument


    @AuraEnabled(cacheable=true)
    public static String getDriverDetails(String managerId) {
        List<contact> driverDataList = new List<contact>();
        
        driverDataList = [SELECT id,Address__r.Location_Lat_Long__Latitude__s,Address__r.Location_Lat_Long__Longitude__s,MailingCity, MailingState, MailingPostalCode,Map_Country__c,Name, FirstName,External_Email__c,Driver_Type__c,Driving_States__c,Expiration_Date__c,Compliance_Mileage__c, Vehicle_Value__c,Time_Attandance__c,Fixed_Amount__c, compliancestatus__c, Car_Image__c,Notification_Message__c,Contact_Picture__c,Insurance_Plan__c,Plan_Years__c,Vehicle_Type__c,Insurance_Upload_Date__c,Insurance_Attachment_Id__c,Total_Approved_Mileages__c,Total_Annual_Reimbursement__c,Total_reimbursment__c,Monthly_Reimbursement__c, Biweek_Reimbursement__c, Bi_Week_Fixed_Amount__c, Monthly_Mileage_Rate__c,Maintenance__c,Tires__c, Insurance_Rate__c, License_Ragistration__c, Taxes__c,Depreciation__c, Total_Monthly_Costs__c, Business_Use__c,Fixed_Cost_Adjustment__c,Vehicle_Value_Check__c,Mileage_Meet__c,Vehicle_Age__c,Insurance__c, Notification_Date__c, Account.Bodily_Injury__c, Account.Uninsured_Motorist__c, Account.Property_Damage__c, Account.Comprehensive__c, Account.Collision__c,Account.Umbrella_Coverage__c,Triplog_UserID__c,Reimbursement_Type__c,Reimbursement_Frequency__c, Account.Reimbursement_Type__c,Account.Bi_Weekly_Pay_Period__c,MobilePhone,Activation_Date__c,Account.CreatedDate from Contact where Id =: managerId];
        
        return JSON.serialize(driverDataList ).unescapeHtml4();
    }
    //This method is sending the value of vehicle from vehicle value object for the account whoes id is passed in the argument
    @AuraEnabled(cacheable=true)
    public static String getVehicleValue(String accountId) {
        List<Vehicle_Value__c> vehicleValueList = new List<Vehicle_Value__c>();
        vehicleValueList = [SELECT id,Vehicle_URL_Mapping__r.vehicle__c,Value__c, Plan_Years__c from Vehicle_Value__c where Account__c =: accountId];
        return JSON.serialize(vehicleValueList ).unescapeHtml4();
    }
    // Calls a method from a utility class (WrapperUtils) to get chart data.
    public static string getChartData(String did,Boolean showTeam,String accid,String role)
    {
        return WrapperUtils.getChartData(did,showTeam,accid,role);
    }
    // Sets the employee name, email, and showMyTeam based on the contact ID.
    public static void setEmployeeName() {
        Contact employee= [select Id,Name,showTeamRecord__c,External_Email__c from Contact where id =: getContactid()];
        if(employee!=null) {
            nameofEmployee= String.escapeSingleQuotes(employee.Name); // Name of the Employee
            emailofEmployee = employee.External_Email__c;
            showMyTeam = employee.showTeamRecord__c;
        } else {
            nameofEmployee='';
            emailofEmployee ='';
            showMyTeam = false;
        }
    }
    //this method will update the reimbursement of all the driver with fresh data from the mlog
    @RemoteAction
    public static string getAllDriversLastMonthUpdatedReimbursements(String did,String accid,boolean showTeamRecord,String role)
    {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getLastMonthReimbursements(did,accid,boolean.valueOf(showTeamRecord),role));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getLastMonthReimbursements(did,accid,boolean.valueOf(showTeamRecord),role));
        }
    }
     //this method will get the reimbursement of all the driver with data from the mlog
    @AuraEnabled
    public static string getAllDriversLastMonthReimbursements(String accountId,String contactId,Boolean showTeam,String role)
    {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accountId) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getLastMonthReimbursements(contactId,accountId,showTeam,role));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getLastMonthReimbursements(contactId,accountId,showTeam,role));
        }
    }
    //this method will get the unapproved trips reimbursement of all the driver with data from the mlog
    public static string getAllDriversLastMonthUpdatedUnapprovedReimburseclone(String did,String accid,boolean showTeamRecord,String role) 
    {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(did,accid,showTeamRecord,role));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(did,accid,showTeamRecord,role));
        }
    }
    //this method will get the unapproved trip of all the driver from the mlog and update it while overwriting previous data
    @RemoteAction
    public static string getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(String did, String accid,string showTeamRecord,String role) 
    {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),role));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),role));
        }
    }
    //this method will get the unapproved trip of all the driver from the mlog and update it while overwriting previous data
    @AuraEnabled
    public static string getAllDriversLastMonthUnapprovedReimbursementsclone(String accountId,String contactId,Boolean showTeam,String role)
    {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accountId) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(contactId,accountId,showTeam,role));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(contactId,accountId,showTeam,role));
        }
    }
    //this method will approve the reimbursement for the drivers
    @RemoteAction
    public static AsyncApexJob approveReimbursements(String reimbursements,String did,String accid,String showTeamRecord,String updateThreshold)
    {
        List<String> updatedlist = new List<String>();
        if(updateThreshold!=null && String.isNotBlank(updateThreshold)){
            WrapperUtils.updateContactThresholdLimit(updateThreshold);
        }
        ApproveReimBatch tripBtc = new ApproveReimBatch(reimbursements,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
        ID batchprocessid = Database.executeBatch(tripBtc,1);
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
        return aaj;
    }
    //Returns a list of updated reimbursements.
    @AuraEnabled
    public static List<String> UpdatedReimList(String did,String accid,String showTeamRecord,String role){
        List<String> updatedlist = new List<String>();
        updatedlist.add(getAllDriversLastMonthUpdatedReimbursements(did,accid,boolean.valueOf(showTeamRecord),role));
        updatedlist.add(getAllDriversLastMonthUpdatedUnapprovedReimburseClone(did,accid,boolean.valueOf(showTeamRecord),role));
        return updatedlist;
    }
    // Checks the status of a batch job.
    @AuraEnabled
    public static String CheckBatchStatus(ID batchprocessid){
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
        if(aaj.Status == 'Failed'){
            return aaj.Status+'='+aaj.ExtendedStatus;
        }
        return aaj.Status;
    }
    //Initiates the approval of mileages.
    @AuraEnabled
    public static AsyncApexJob approveMileagesClone(String mileages, String did, String accid,String showTeamRecord,Boolean highrisk)
    {
        /*AsyncApexJob aaj;
        List<String> updatedlist = new List<String>();
        if(mileages!=null)
        {
            ApproveReimBatch tripBtc = new ApproveReimBatch(mileages,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
            ID batchprocessid = Database.executeBatch(tripBtc,1);
            aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
        }
        return aaj;
        List<String> employeeReimbursementList = new List<String>();   
        List<Employee_Mileage__c> mileageUpdatelist = new List<Employee_Mileage__c>();
  
        if(mileages != null && mileages != '') {
            employeeReimbursementList = (List<String>)Json.deserialize(mileages,List<String>.class);          
        }
        */
        AsyncApexJob aaj;
        ID batchprocessid;
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true){         
            ApproveMileageBatch tripBtc = new ApproveMileageBatch(mileages,true,highrisk);
            batchprocessid = Database.executeBatch(tripBtc,200);
        } else {
            ApproveMileageBatch tripBtc = new ApproveMileageBatch(mileages,false,highrisk);
            batchprocessid = Database.executeBatch(tripBtc,200);
        }        
        aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
        return aaj;
}
    //Initiates the approval of mileages.
    @AuraEnabled
    public static String approveMileages(String checked,String selected,String unapprove,String name,String emailaddress)
    {
        return WrapperUtils.approveMileagesForAdminDash(checked,selected,unapprove,name,emailaddress);
    }
    //Retrieves unapproved mileages.
    @AuraEnabled
    public static String getUnapprovedMileages(String reimbursementDetails,String accountId)
    {   system.debug('reimbursementDetails'+reimbursementDetails);
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accountId) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedMileages(reimbursementDetails));
        } else{
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedMileages(reimbursementDetails));
        }
    }
    //Retrieves the total number of drivers for a manager.
    @AuraEnabled(cacheable=true)
    public static object totalNoofDriverforManager(String managerId) {
        AggregateResult[] groupedResults = [select COUNT(id) totalDriver from contact where Deactivated_Date__c = null and Manager__c =:  managerId];
        Object totalNoOfDriver = groupedResults[0].get('totalDriver');
        return totalNoOfDriver;
    }
    //Retrieve onboarding and insurance-related data.
    @AuraEnabled(cacheable=true)
    public static  string onboardingStatus(String managerId,String accountId,String role) {
        map<String, Decimal>  onBoardingMap = new map<String, Decimal>();
        List<Contact> conList = new List<Contact>();
        Decimal packetCount = 0;
        Decimal insuranceCount = 0;
        Decimal packetandInsCount = 0;
        Decimal osStatusCount = 0;
        Decimal totalDriver = 0;
        Decimal completedCompStatus = 0;
        Decimal pendingCompStatus = 0;
        Decimal notCompletedCompStatus = 0;
        Decimal onBordPercentage =0;
        Decimal insurancePercentage=0;
        Decimal missingpacinsurancePercentage =0;
        Decimal completePercentage=0;
        Decimal completeCompPercentage =0;
        Decimal pendingCompPercentage =0;
        Decimal notCompleteCompPercentage =0;
        if(role=='Admin'){
            conList = [SELECT id,Packet__c,Insurance_Attachment_Id__c,monthly_compliance_status__c  FROM contact WHERE Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager') AND Accountid =: accountId];
        } else if(role=='Manager'){
            conList = [select id,Packet__c,Insurance_Attachment_Id__c,monthly_compliance_status__c FROM contact WHERE Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager') AND(Manager__c =: managerId OR (Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerId))];
        }
        
        totalDriver = conList.size();

        for(contact con : conList){
            if(con.Packet__c != 'Completed' && con.Insurance_Attachment_Id__c != null){
                packetCount++;
            }
            if(con.Packet__c == 'Completed' && con.Insurance_Attachment_Id__c == null){
                insuranceCount++;
            }
            if(con.Packet__c != 'Completed' && con.Insurance_Attachment_Id__c == null){
                packetandInsCount++;
            }
            if(con.Packet__c == 'Completed' && con.Insurance_Attachment_Id__c != null){
                osStatusCount++;
            }
            if(con.monthly_compliance_status__c == 'Yes'){
                completedCompStatus++;
            }
            if(con.monthly_compliance_status__c == 'Pending') {
                pendingCompStatus++;
            }
            if(con.monthly_compliance_status__c != 'Yes' && con.monthly_compliance_status__c != 'Pending'){
                notCompletedCompStatus++;
            }
        }
        onBordPercentage = ((packetCount*100)/totalDriver);
        onBoardingMap.put('missingpacket', onBordPercentage);

        insurancePercentage = (insuranceCount*100)/totalDriver;
        onBoardingMap.put('missingInsurance', insurancePercentage);

        missingpacinsurancePercentage = (packetandInsCount*100)/totalDriver;
        onBoardingMap.put('missingPacketandmissingInsurance', missingpacinsurancePercentage);

        completePercentage = (osStatusCount*100)/totalDriver;
        onBoardingMap.put('Complete', completePercentage);

        completeCompPercentage = ((completedCompStatus*100)/totalDriver).setScale(1);
        onBoardingMap.put('Compliant', completeCompPercentage);

        pendingCompPercentage = ((pendingCompStatus*100)/totalDriver).setScale(1);
        onBoardingMap.put('Pending', pendingCompPercentage);

        notCompleteCompPercentage = ((notCompletedCompStatus*100)/totalDriver).setScale(1);
        onBoardingMap.put('NonCompliant', notCompleteCompPercentage);

        return json.serialize(onBoardingMap);
    }
    //Retrieve onboarding and insurance-related data.
    @AuraEnabled(cacheable=true)
    public Static String insuranceReport(String managerId,String accountId,String role){
        map<String , Integer>  InsuranceMap = new map<String, Integer>();
        List<Contact> conList = new List<Contact>();
        Integer meetingMinimumCount = 0;
        Integer insuranceCardCount = 0;
        Integer underMinimumCount = 0;
        Integer expiredInsCount = 0;
        Integer missingUmbrellaPolicy=0;
        Integer missingInsuranceDecPage=0;
        Integer yesCount = 0;
        Integer noExpirationDateCount = 0;
        Integer UnderReview = 0;
        
        if(role=='Admin'){
            conList = [SELECT id,Insurance__c,Packet__c,Account.Umbrella_Coverage__c  FROM contact WHERE Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager')AND Accountid =: accountId];
        } else if(role=='Manager'){
            conList = [SELECT id,Insurance__c,Packet__c,Account.Umbrella_Coverage__c  FROM contact WHERE Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager') AND(Manager__c =: managerId OR (Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerId))];
        }
        for(contact con : conList){
            if(con.Insurance__c == 'Not Meeting Plan Minimum'){
                meetingMinimumCount++;
            }
            if(con.Insurance__c == 'Under Review'){
                UnderReview++;
            }
            if(con.Insurance__c == 'Insurance Card' ){
                insuranceCardCount++;
            }
            if(con.Insurance__c == 'Not Submitted'){
                underMinimumCount++;
            }
            if(con.Insurance__c == 'Expired'){
                expiredInsCount++;
            }
            if(con.Insurance__c == 'Yes'){
                yesCount++;
            }
            if(con.Insurance__c == 'No Expiration Date'){
                noExpirationDateCount++;
            }
            if(con.Insurance__c == 'Missing Umbrella Policy'){
                missingUmbrellaPolicy++;
            }
            if(con.Insurance__c == 'Missing Insurance Dec Page'){
                missingInsuranceDecPage++;
            }
        }
        InsuranceMap.put('UnderReview', UnderReview);
        InsuranceMap.put('InsuranceCard', insuranceCardCount);
        InsuranceMap.put('NotSubmitted', underMinimumCount);
        InsuranceMap.put('ExpiredInsurance', expiredInsCount);
        InsuranceMap.put('Yes', yesCount);
        InsuranceMap.put('noExpirationDate', noExpirationDateCount);
        InsuranceMap.put('NotMeetingMinimum', meetingMinimumCount);
        if(conList[0].Account.Umbrella_Coverage__c != null) {
            InsuranceMap.put('missingUmbrellaPolicy', missingUmbrellaPolicy);
        }
        InsuranceMap.put('missingInsuranceDecPage', missingInsuranceDecPage);
        return json.serialize(InsuranceMap);
    }
    //Retrieves details of the manager's team members.
    @AuraEnabled
    public static string myTeamDetails(String managerId, String accountId, Boolean showteam,String role){
        List<ContactWrapper> conWrapList = new List<ContactWrapper >();
        List<Contact> contactList = new List<Contact>();
        
        if(showTeam == true && role=='Manager' || showTeam == false && role=='Admin') {
            contactList = [SELECT Id, Name,Fixed_Amount__c, Activation_Date__c, Half_Fixed_Amount__c,Email,Reimbursement_Frequency__c FROM Contact WHERE (Manager__c =: managerId OR (Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerId)) AND Role__c != 'Admin' AND Role__c != 'Manager' AND  Deactivated_Date__c = null Order by Name asc];
        } else if(showTeam == false && role=='Manager') {
            contactList = [SELECT Id, Name,Fixed_Amount__c, Activation_Date__c, Half_Fixed_Amount__c,Email,Reimbursement_Frequency__c  FROM Contact  WHERE Manager__c =: managerId AND Role__c != 'Admin' AND Role__c != 'Manager' AND  Deactivated_Date__c = null Order by Name asc];
        } else if(showTeam == true && role=='Admin'){
            contactList = [SELECT Id, Name,Fixed_Amount__c, Activation_Date__c, Half_Fixed_Amount__c,Email,Reimbursement_Frequency__c FROM Contact WHERE Accountid =: accountId AND Role__c != 'Admin' AND Role__c != 'Manager' AND  Deactivated_Date__c = null Order by Name asc];
        }

        for(Contact conList : contactList){
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.id = conList.Id;
            conWrap.name = conList.Name;
            conWrap.activationDate = conList.Activation_Date__c;
            conWrap.fixedamount = conList.Fixed_Amount__c != null ? conList.Fixed_Amount__c : 0.00;
            conWrap.email = conList.Email;
            conWrapList.add(conWrap);
        }
        String wrapjson = JSON.serialize(conWrapList);
        return wrapjson;
    }
    // Retrieves details of high-risk drivers.
    @AuraEnabled
    public static string highRiskDriversDetails(String managerId,String accountId,boolean highMileage, boolean showTeam,String role){
        List<ContactWrapperForMileage> conWrapList = new List<ContactWrapperForMileage >();
        Set<String> contactIds = new Set<String>();
        String lastMonth = Utils.fetchMonths(1, 0)[0];

        String query = 'SELECT id, Name, Month__c, Contact_Id__c, Contact_Id__r.name, Total_Mileage__c, High_Risk_Total_Mileages__c FROM Employee_Reimbursement__c ';
        query += ' WHERE Month__c =\''+ lastMonth + '\'';

        if(showTeam == true && role=='Manager' || showTeam == false && role=='Admin') {
            query += ' AND ((Contact_Id__r.Manager__c = \'' + managerId + '\' ) OR (Contact_Id__r.Manager__r.Manager__c = \'' + managerId + '\' ) OR (Contact_Id__r.Manager__r.Manager__r.Manager__c = \'' + managerId + '\' ) OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c = \'' + managerId + '\' ))' ;
        } else if(showTeam == false && role=='Manager') {
            query += ' AND Contact_Id__r.Manager__c = \'' + managerId + '\' ' ;
        } else if(showTeam == true && role=='Admin'){
            query += ' AND Contact_Id__r.Accountid = \'' + accountId + '\' ';
        }

        if(highMileage){
            query += ' AND Total_Mileage__c > 0 ORDER BY Total_Mileage__c desc';
        }else{
            query += ' AND High_Risk_Total_Mileages__c > 0 ORDER BY High_Risk_Total_Mileages__c desc';
        }
        List<Employee_Reimbursement__c> reimDetail = new List<Employee_Reimbursement__c>();
        try {
            reimDetail = Database.query(query);
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }

        for(Employee_Reimbursement__c currentReimbursement : reimDetail) {
            ContactWrapperForMileage conWrap = new ContactWrapperForMileage();
                conWrap.id = currentReimbursement.Contact_Id__c;
                conWrap.name = currentReimbursement.Contact_Id__r.Name;
                conWrap.mileage = highMileage == true ? currentReimbursement.Total_Mileage__c : currentReimbursement.High_Risk_Total_Mileages__c;
                conWrapList.add(conWrap);
        }
        if(conWrapList.size() > 0){
            String wrapjson = JSON.serialize(conWrapList);
            return wrapjson;
        } else{
            return 'No Trips Found More than 250 miles for this contact';
        }
    }
    // Methods related to notifications and reimbursements.
    @AuraEnabled
    public static String getNotificationMessageList(String conId,Integer year,String month){
        return LWCWrapperUtils.getNotificationMessageList(conId,year,month);
    }
    // Methods related to notifications and reimbursements.
    @AuraEnabled
    public static string updateNotificationMessage(String msgId,Integer year,String month){
        return LWCWrapperUtils.updateNotificationMessage(msgId,year,month);
    }
    // identifies the mileages which are high risk and create reimbursement for those mileagse
    @AuraEnabled
    public static string reimbursementForHighMileageOrRisk(String managerId,String accountId,String month,boolean showteam,boolean highMileage,String role){
        return LWCWrapperUtils.reimbursementForHighMileageOrRisk(managerId,accountId,month,showteam,highMileage,role);
    }
    //Retrieves contact data for a manager.
    @AuraEnabled(cacheable=true)
    public static String managerContactData(String managerId,String accountId,String role){
        List<contact> driverDataList = new List<contact>();
        if(role=='Admin'){
            driverDataList = [SELECT id,Name,Address__r.Location_Lat_Long__Latitude__s,Address__r.Location_Lat_Long__Longitude__s,Fixed_Amount__c,MailingCity, MailingState,Map_Country__c, MailingPostalCode,Reimbursement_Frequency__c,Half_Fixed_Amount__c FROM Contact WHERE Accountid =: accountId and Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager')];
        } else if(role=='Manager'){
            driverDataList = [SELECT id,Name,Address__r.Location_Lat_Long__Latitude__s,Address__r.Location_Lat_Long__Longitude__s,Fixed_Amount__c, MailingCity, MailingState,Map_Country__c, MailingPostalCode,Reimbursement_Frequency__c,Half_Fixed_Amount__c from Contact  WHERE (Manager__c =: managerId  OR (Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerId)) AND Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager')];
        }
        return JSON.serialize(driverDataList ).unescapeHtml4();
    }
    //methods returns details of the specific account
    @AuraEnabled
    public static string accountDetails(String accountId){
        Account acc = [SELECT Id, Name FROM Account WHERE Id =: accountId];
        return acc != null ? (acc.Name != null ? acc.Name : '') : 'Failure';
    }
   
    //methods returns list of months for the specific account
    @AuraEnabled
    public static string accountMonthList(String accountId){
        return LWCWrapperUtils.accountMonthList(accountId);
    }
    //return mileage for the specific month
    @AuraEnabled
    public static String getMileages(String clickedMonth,string clickedYear,String did) {
        return WrapperUtils.getMileages(clickedMonth,clickedYear,did);
    }
    //return list of reimbursement for the given contact
    @AuraEnabled
    public static string contactReimMonthList(String contactId){
        return LWCWrapperUtils.contactReimMonthList(contactId);
    }
    //return the last month reimbursement fir the given contact
    @AuraEnabled
    public static string getLastMonthReimbursements(String accountId,String contactId,Boolean showTeam,String month,String role){
        return LWCWrapperUtils.getLastMonthReimbursements(contactId,accountId,showTeam,role,month);
    }
    //sync trip for the given account
    @AuraEnabled
    public static string MassSyncTrips(String accountId,String startDate,String endDate,String month,String tripStatus,String activityStatus){
        MassSyncTrips  obj = new MassSyncTrips(accountId,startDate,endDate,month,tripStatus,false);
        Database.executeBatch (obj,1);
        return 'Success';
    }
    // sync the trip for the reimbursement passed in the string
    @AuraEnabled
    public static string MassSyncTripsForReimbursements(String reimbursements){
        List<String> reimIds = new List<String>();
        reimIds = (List<String>) System.JSON.deserialize(reimbursements, List<String>.class);
        MassSyncTripforCommute obj = new MassSyncTripforCommute(reimIds);
        Database.executeBatch (obj,1);
        return 'Success';
    }
    //delete the mileage for the reimbursements
    @AuraEnabled
    public static string DeleteMileages(String reimbursements){
        List<String> reimIds = new List<String>();
        reimIds = (List<String>) System.JSON.deserialize(reimbursements, List<String>.class);
        try {
            if(!reimIds.isempty()){
                delete [select id  from Employee_Mileage__c where EmployeeReimbursement__c IN :reimIds and Trip_Status__c = 'Not Approved Yet' and Trip_Id__c != null];
            }
        } catch(DmlException e) {
            return e.getMessage();
        }
        return 'Success';
    }
    
    //sync trip for the given reimbursement period 
    @AuraEnabled
    public static string MassSyncTripsForBiweek(String biWeek,String accID){
        MassSyncTripforCommute obj = new MassSyncTripforCommute(biWeek,accID);
        Database.executeBatch (obj,1);
        return 'Success';
    }
    //return the link for the redirection
    @AuraEnabled
    public static String loginRedirection(String contactId){
        return 'success';
    }
    //Methods related to compliance and onboarding reports.
    @AuraEnabled
    Public Static String complRptDownloadtData (String managerId,String accountId,String role){
        List<Contact> conList = new List<Contact>();
        if(role=='Admin'){
            conList = [select id,Name,Email,monthly_compliance_status__c,isActive__c from contact where Deactivated_Date__c = null and Accountid =: accountId and Role__c != 'Admin' and Role__c != 'Manager'];
        } else if(role=='Manager'){
            conList = [select id,Name,Email,monthly_compliance_status__c,isActive__c from contact  where Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager') AND(Manager__c =: managerId  OR (Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerId))];
        }
        string conListJson = JSON.serialize(conList);
        return conListJson;
    }
    // Methods related to compliance and onboarding reports.
    @AuraEnabled
    Public Static String onboardRptDownloadtData (String managerId,String accountId,String role){
        List<Contact> conList = new List<Contact>();
        if(role == 'Admin'){
            conList = [SELECT Name,Expiration_Date__c,Email,Onboarding_Status__c,Insurance__c,Hello_Sign_Status__c,Hello_Sign_Admin_Status__c,Schedule_Driver_Meeting__c,Activation_Date__c,isActive__c FROM contact WHERE Deactivated_Date__c = null and Accountid =: accountId and Role__c != 'Admin' and Role__c != 'Manager'];
        } else if(role=='Manager'){
            conList = [SELECT Name,Expiration_Date__c,Email,Onboarding_Status__c,Insurance__c,Hello_Sign_Status__c,Hello_Sign_Admin_Status__c,Schedule_Driver_Meeting__c,Activation_Date__c,isActive__c FROM contact WHERE Deactivated_Date__c = null AND (Role__c != 'Admin' AND  Role__c != 'Manager') AND(Manager__c =: managerId OR (Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerId))];
        }
        string conListJson = JSON.serialize(conList);
        return conListJson;
    }
    //batch for getting the unapproved trips for the reimbursement
    @AuraEnabled
    public static String getUnapprovedReim(String reimbursements){
        List<String> reimIds = new List<String>();
        reimIds = (List<String>) System.JSON.deserialize(reimbursements, List<String>.class);
        List<ReimbursementWrapper> wrapList = new List<ReimbursementWrapper>();
        for(Employee_Reimbursement__c  reim : [SELECT Id,Contact_Id__c,Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Id__r.Biweek_Reimbursement__c,Status__c,Month__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Reimbursement_Month__c,Year__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c WHERE Id In: reimIds ]){
            Boolean biWeekVal = reim.Contact_Id__r.Reimbursement_Frequency__c != null && reim.Contact_Id__r.Reimbursement_Frequency__c == 'Bi-Weekly Reimbursement' ? true : false;
            Integer numberOfDays = Date.daysInMonth(Integer.Valueof(reim.Year__c), Integer.Valueof(reim.Reimbursement_Month__c));
            Date lastDayOfMonth = Date.newInstance(Integer.Valueof(reim.Year__c), Integer.Valueof(reim.Reimbursement_Month__c), numberOfDays);
            Date firstDayOfMonth = Date.newInstance(Integer.Valueof(reim.Year__c), Integer.Valueof(reim.Reimbursement_Month__c), 1);
            string startDate1 = String.valueOf(firstDayOfMonth);
            string endDate1 = String.valueOf(lastDayOfMonth);
            ReimbursementWrapper reimWrap = new ReimbursementWrapper();
            reimWrap.reimbursementId = reim.id;
            reimWrap.contactEmail = reim.Contact_Id__r.External_Email__c;
            reimWrap.contactId = reim.Contact_Id__c;
            reimWrap.startdate = startDate1;
            reimWrap.enddate = endDate1;
            reimWrap.fuel = String.valueOf(reim.Fuel_Price__c);
            reimWrap.mpg = String.valueOf(reim.MPG__c);
            reimWrap.maintaincetyre = String.valueOf(reim.Maintenance_and_Tires__c);
            reimWrap.accountapi = reim.Contact_Id__r.Account.Triplog_API__c;
            reimWrap.biWeekValue = biWeekVal;
            wrapList.add(reimWrap);
        }
        return Json.serialize(wrapList);
    }

    @AuraEnabled(cacheable=true)
    public static List<BasicReporting__c> getCustomReportSettings() {
        return BasicReporting__c.getAll().values();
    }
    
    @AuraEnabled
    public static String postExpenseReimbursement(Id accountId,String empReMonth,String contactEmail,String totalReimburement){
        String status = UploadConcurQuickExpenseTriplog.postTotalReimbursement(accountId,empReMonth,contactEmail,totalReimburement);
        return status;
    }
    
    @AuraEnabled
    public static void TripCallout(Id driverId, String month, String year, String fuel, String maintTyre, Id empReID,String mpg,String status){
       
        String result = WrapperUtils.TripCallout(driverId,month,year,fuel,maintTyre,empReID,mpg,status);
    }

    //method is use for change reimbursement status    
    @AuraEnabled
    public static void UpdateReimbursementStatus(Id empReID){
        WrapperUtils.UpdateReimbursementStatus(empReID);
    }
    
    Public class ReimbursementWrapper{
        public String reimbursementId;
        public String contactEmail;
        public String contactId;
        public String startdate;
        public String enddate;
        public String fuel;
        public String mpg;
        public String maintaincetyre;
        public String accountapi;
        public Boolean biWeekValue;
    }
    Public class HighRiskContactWrapper{
        public String id {get;set;}
        public String name {get;set;}
    }

    Public class ContactWrapper{
        public String id {get;set;}
        public String name {get;set;}
        public Date activationDate {get;set;}
        public Decimal fixedamount{get;set;}
        public String email {get;set;}
    }
    Public class ContactWrapperForMileage{
        public String id {get;set;}
        public String name {get;set;}
        public Decimal mileage{get;set;}
    }

}