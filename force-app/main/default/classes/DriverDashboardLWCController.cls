/**
 * @Author: GetonCRM Solutions LLP
 * @Description: this class represent methods related to dashboard in Mdash including the profile Manger/Driver, Admin/Driver ,Driver.
 * @Modification logs
 * ========================================================================================================================
 * @Date:  14th september 2023 | Sanket goswami
 *
 */
global class DriverDashboardLWCController {
    public static string videoCustom {get;set;}
    global static string drivingStates {get;set;}
    global static string contactName {get;set;}
    global static Integer userLoginCount {get;set;}
    global static String scheduleGotoMeeting {get;set;} //
    public static Date activationDate {get;set;}
    public static String activationDateForBatch {get;set;}
    public static String systemNotification {get;set;}
    public static String profileID {get;set;}
    global static String last2Month {get;set;}
    public static String strOWEEmail {get;set;}
    // Constructor to initialize properties
    global DriverDashboardLWCController(){
        NewDashboardVideoLink__c videoCustomSetting = NewDashboardVideoLink__c.getOrgDefaults();
        videoCustom = json.serialize(videoCustomSetting );
        List<Contact> conList = [SELECT id,FirstName,Role__c,Driving_States__c,
                                            account.Schedule_Goto_Meeting__c,Activation_Date__c, 
                                            System_Notification__c 
                                        FROM Contact 
                                        WHERE id =: getContactid() WITH SECURITY_ENFORCED];
        if(conList.size() > 0){
            scheduleGotoMeeting = conList[0].account.Schedule_Goto_Meeting__c != null ? conList[0].account.Schedule_Goto_Meeting__c : '' ;
            drivingStates = Json.serialize(String.valueOf(conList[0].Driving_States__c));
            contactName = conList[0].FirstName != null ? conList[0].FirstName : '';
            activationDate = conList[0].Activation_Date__c != null ? conList[0].Activation_Date__c: null;
            activationDateForBatch = conList[0].Activation_Date__c != null ? DateTime.newInstance(conList[0].Activation_Date__c.year(), conList[0].Activation_Date__c.month(), conList[0].Activation_Date__c.day()).format('MM/dd/yyyy') : null;
            System.debug('Activation date assigned -->'+activationDateForBatch);
            systemNotification = conList[0].System_Notification__c;
            profileID = conList[0].Role__c;
        }
        userLoginCount = countUserLogin(getContactid());
        
    last2Month = String.escapeSingleQuotes(WrapperUtils.getpastYearReimbursement(getContactid()));
    }
    // Method to get the contact ID from the current page parameters
    public static String getContactid() {
        if(ApexPages.currentPage().getParameters().containsKey('id') && String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
            return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        }
    }
    
    // Method to count user logins based on contact ID
    public static Integer countUserLogin(String contactId){
        integer countLogin = 0;
        User userObj = [SELECT id FROM User WHERE ContactId =: contactId WITH SECURITY_ENFORCED limit 1];
        if(userObj != null){
            for(LoginHistory objLogin : [SELECT id,Status 
                                                FROM LoginHistory 
                                                WHERE LoginUrl = 'https://mburse--partialdev.sandbox.my.site.com/app/adminlogin' 
                                                    AND UserId =: userObj.Id WITH SECURITY_ENFORCED]){
                if(objLogin.Status == 'Success'){
                    countLogin = countLogin + 1;
                }
            }
        }
        return countLogin;
    }
    
    
       /**
     * @Description: AuraEnabled method to get Driver's details
     * @param contactId: The ID of the contact for which driver details are requested
     * @return JSON-serialized driver details
     */
    @AuraEnabled(cacheable=true)
    public static String getDriverDetails(String contactId) {
        List<contact> driverDataList = new List<contact>();
        driverDataList = [SELECT id, Name, FirstName, MailingPostalCode,MailingState,External_Email__c, MailingCity,Driver_Type__c,
                                        Driving_States__c,Expiration_Date__c,Compliance_Mileage__c, Vehicle_Value__c,
                                        Time_Attandance__c, Fixed_Amount__c, monthly_compliance_status__c, Car_Image__c,
                                        Notification_Message__c,Contact_Picture__c,Insurance_Plan__c,Plan_Years__c,
                                        Vehicle_Type__c,Insurance_Upload_Date__c,Insurance_Attachment_Id__c, 
                                        Total_Approved_Mileages__c,Total_Annual_Reimbursement__c,Total_reimbursment__c,
                                        Monthly_Reimbursement__c, Biweek_Reimbursement__c, Bi_Week_Fixed_Amount__c,
                                        Monthly_Mileage_Rate__c,Maintenance__c,Tires__c, Insurance_Rate__c, 
                                        License_Ragistration__c, Taxes__c, Depreciation__c, Total_Monthly_Costs__c,
                                        Business_Use__c,Fixed_Cost_Adjustment__c,Vehicle_Value_Check__c,Mileage_Meet__c,
                                        Vehicle_Age__c,Insurance__c, Notification_Date__c, Account.Bodily_Injury__c,
                                        Account.Uninsured_Motorist__c, Account.Property_Damage__c,Map_Country__c,
                                        Account.Comprehensive__c, Account.Collision__c,Account.Umbrella_Coverage__c,
                                        Triplog_UserID__c,Reimbursement_Type__c,Reimbursement_Frequency__c,
                                        Account.Reimbursement_Type__c,MobilePhone,Avg_Mileage__c,Sync_Feature__c,
                                        Role__c 
                                    FROM Contact  
                                    WHERE id =: contactId
                                    WITH SECURITY_ENFORCED];
        
        return JSON.serialize(driverDataList ).unescapeHtml4();
    }
    
    //AuraEnabled method to get Driver's details
    @AuraEnabled
    public static String getDriverDetailsClone(String contactId) {
        List<contact> driverDataList = new List<contact>();
        driverDataList = [SELECT id, Name, FirstName, MailingPostalCode, MailingState,External_Email__c, MailingCity,
                                        Driver_Type__c,Driving_States__c,Expiration_Date__c,Compliance_Mileage__c, 
                                        Vehicle_Value__c,Time_Attandance__c, Fixed_Amount__c, monthly_compliance_status__c, 
                                        Car_Image__c,Notification_Message__c,Contact_Picture__c,Insurance_Plan__c,Plan_Years__c,
                                        Vehicle_Type__c,Insurance_Upload_Date__c,Insurance_Attachment_Id__c, Total_Approved_Mileages__c,
                                        Total_Annual_Reimbursement__c,Total_reimbursment__c,Monthly_Reimbursement__c, Biweek_Reimbursement__c, 
                                        Bi_Week_Fixed_Amount__c, Monthly_Mileage_Rate__c,Maintenance__c,Tires__c, Insurance_Rate__c, 
                                        License_Ragistration__c, Taxes__c, Depreciation__c, Total_Monthly_Costs__c, Business_Use__c,
                                        Fixed_Cost_Adjustment__c,Vehicle_Value_Check__c,Mileage_Meet__c,Vehicle_Age__c,Insurance__c, 
                                        Notification_Date__c,Account.Bodily_Injury__c, Account.Uninsured_Motorist__c, Account.Property_Damage__c,
                                        Map_Country__c, Account.Comprehensive__c, Account.Collision__c,Account.Umbrella_Coverage__c,
                                        Triplog_UserID__c,Reimbursement_Type__c,Reimbursement_Frequency__c, Account.Reimbursement_Type__c,
                                        Sync_Feature__c,Role__c,is_Manual_Entry_User__c 
                                    FROM Contact
                                    WHERE id =: contactId
                                    WITH SECURITY_ENFORCED];
        return JSON.serialize(driverDataList ).unescapeHtml4();
    }
    
    // This Method is used to get Driver's Driving State.
    @AuraEnabled
    public static String getDrivingState(String contactId) {
        List<contact> driverDataList = new List<contact>();
        driverDataList = [SELECT id, Name, Driving_States__c FROM Contact  WHERE id =: contactId WITH SECURITY_ENFORCED];
        return JSON.serialize(driverDataList ).unescapeHtml4();
    }

    // This Method is used to get Company's logo from the account object.
    @AuraEnabled(cacheable=true)
    public static String getCompanyLogoUrl(String accountId) {
        String imageURL;
        Account acc = [SELECT Id,Name,Logo_Document_Id__c FROM Account WHERE id =:accountId WITH SECURITY_ENFORCED];
        if(acc.Logo_Document_Id__c != null){
            imageURL = acc.Logo_Document_Id__c;
        }else{
            imageURL ='';
        }
        return JSON.serialize(imageURL).unescapeHtml4();
    }
    
    // This Method is used to get Mileages based on the month and year.
    @AuraEnabled
    public static List<String> getMileages(String clickedMonth,String year,String contactId) {
        return WrapperUtils.getMileages1(clickedMonth,year,contactId);
    }

    //method to get the mileage data for the given contact for the given year
    @AuraEnabled
    public static String getMileagesData(Integer year,String contactId) {
        List<mileageValueWrapper> lstMileageValueWrappers = new List<mileageValueWrapper>();
        for(Employee_Mileage__c lstEmployeeMileages : [SELECT Id,StartTime__c, EndTime__c,CreatedDate, Contact_Email_Id__c,
                                                                    Tracing_Style__c, Day_Of_Week__c,  Trip_Date__c, Origin_Name__c,
                                                                    Destination_Name__c, Mileage__c, Trip_Status__c, Approved_Date__c,
                                                                    ConvertedStartTime__c,ConvertedEndTime__c, Fuel_Variable_Rate__c,
                                                                    Variable_Rate__c,Variable__c,Maintenance_and_Tires__c ,
                                                                    EmployeeReimbursement__r.Month__c ,Total_Time__c,
                                                                    Notes__c, Tag__c,Approval_Name__c
                                                                FROM Employee_Mileage__c 
                                                                WHERE EmployeeReimbursement__r.Contact_Id__c =: contactId 
                                                                    AND EmployeeReimbursement__r.Year__c =:year 
                                                                    WITH SECURITY_ENFORCED
                                                                    ORDER BY Trip_Date__c  DESC]){
            
            String strstrMonthVal = lstEmployeeMileages.EmployeeReimbursement__r.Month__c.split('-').get(0);
            String strMonth = WrapperUtils.getMonthNamefromno(Integer.valueOf(strstrMonthVal));
            mileageValueWrapper objMileageValueWrapper = new mileageValueWrapper ();
            objMileageValueWrapper.reimMonth = strMonth;
            objMileageValueWrapper.id = String.valueOf(lstEmployeeMileages.Id);
            if(lstEmployeeMileages.ConvertedStartTime__c != null ) {
                DateTime employeMileageStartTime = lstEmployeeMileages.ConvertedStartTime__c;
                objMileageValueWrapper.starttime = employeMileageStartTime.format('h:mm a','America/Panama');
            }
            if(lstEmployeeMileages.ConvertedEndTime__c != null) {
                DateTime employeMileageEndTime = lstEmployeeMileages.ConvertedEndTime__c ;
                objMileageValueWrapper.endTime = employeMileageEndTime.format('h:mm a','America/Panama');
            }
            objMileageValueWrapper.email = String.valueOf(lstEmployeeMileages.Contact_Email_Id__c);
            objMileageValueWrapper.tracingStyle = String.valueOf(lstEmployeeMileages.Tracing_Style__c);
            objMileageValueWrapper.dayOfWeek = String.valueOf(lstEmployeeMileages.Day_Of_Week__c);
            
            Date employeMileageTripDate = lstEmployeeMileages.Trip_Date__c;
            DateTime dt = DateTime.newInstance(employeMileageTripDate.year(), employeMileageTripDate.month(),employeMileageTripDate.day());
            String strDateTrip = dt.format('MM/dd/yy');

            objMileageValueWrapper.tripDate = strDateTrip;
            objMileageValueWrapper.originName = String.valueOf(lstEmployeeMileages.Origin_Name__c);
            objMileageValueWrapper.destinationName = String.valueOf(lstEmployeeMileages.Destination_Name__c);
            objMileageValueWrapper.mileage = String.valueOf(lstEmployeeMileages.Mileage__c);
            objMileageValueWrapper.tripStatus = String.valueOf(lstEmployeeMileages.Trip_Status__c);
            if(lstEmployeeMileages.Approved_Date__c != null ){
                Date employeMileageApproveDate = lstEmployeeMileages.Approved_Date__c;
                DateTime approvedDateTime = DateTime.newInstance(employeMileageApproveDate.year(), employeMileageApproveDate.month(),employeMileageApproveDate.day());
                String strApprovedDate = approvedDateTime.format('MM/dd/yy');
                objMileageValueWrapper.approvedDate = strApprovedDate;
            }
        
            objMileageValueWrapper.fuelVaraibleRate = String.valueOf(lstEmployeeMileages.Fuel_Variable_Rate__c);
            objMileageValueWrapper.varaibleRate = lstEmployeeMileages.Variable_Rate__c != null ? String.valueOf(lstEmployeeMileages.Variable_Rate__c) : '0';
            objMileageValueWrapper.varaibleAmount = String.valueOf(lstEmployeeMileages.Variable__c);
            objMileageValueWrapper.maintTyre = String.valueOf(lstEmployeeMileages.Maintenance_and_Tires__c);
            objMileageValueWrapper.totalTime = String.valueOf(lstEmployeeMileages.Total_Time__c);
            objMileageValueWrapper.notes = String.valueOf(lstEmployeeMileages.Notes__c);
            objMileageValueWrapper.tag = String.valueOf(lstEmployeeMileages.Tag__c);

            Date createddate = Date.valueOf(lstEmployeeMileages.CreatedDate);
            if(String.valueOf(createddate).contains('-')) {
                List<String> lstCreatedDateSplitted = new List<String>();
                lstCreatedDateSplitted = String.valueOf(createddate).split('-');
                objMileageValueWrapper.submitteddate =  lstCreatedDateSplitted[1]+'/'+lstCreatedDateSplitted[2]+'/'+lstCreatedDateSplitted[0].substring(2,4);
            }
            objMileageValueWrapper.approvalName = String.valueOf(lstEmployeeMileages.Approval_Name__c);
            lstMileageValueWrappers.add(objMileageValueWrapper);
        }
        return JSON.serialize(lstMileageValueWrappers).unescapeHtml4();
    }
    //wrapper class to manage the data to send in frontend
    public class mileageValueWrapper {
        public string reimMonth {get;set;}
        public string id {get;set;}
        public string starttime {get;set;}
        public string endtime {get;set;}
        public string email {get;set;}
        public string tracingStyle {get;set;}
        public string dayOfWeek {get;set;}
        public string tripDate {get;set;}
        public string originName {get;set;}
        public string destinationName {get;set;}
        public string mileage {get;set;}
        public string tripStatus {get;set;}
        public string approvedDate {get;set;}
        public string fuelVaraibleRate {get;set;}
        public string varaibleRate {get;set;}
        public string varaibleAmount {get;set;}
        public string totalTime {get;set;}
        public string notes {get;set;}
        public string tag {get;set;}
        public string maintTyre {get;set;}
        public string submitteddate {get;set;}
        public string approvalName {get;set;}
    }

    //method to access the charts in the dashboard
    @RemoteAction
    public static String getChartData(String contactId) {
        return NewdriverdashboardController.getChartData(contactid);
    }
    
    // This Method is used to return reimbursement list
    @AuraEnabled
    global Static List<String> getAllReimbursements(String year,String contactId,String accountId) {
        List<EmployeeReimbursements> employeeReimList = new List<EmployeeReimbursements>();
        List<reaimValueWrapperNew> employeeReimWrap = new List<reaimValueWrapperNew>();

        Decimal mileageCount = 0.00;
        Decimal fixedCount = 0.00;
        Decimal avgToDateCount = 0.00;
        Decimal varibleAmountCount = 0.00;
        Decimal fixed1Count = 0.00;
        Decimal fixed2Count = 0.00;
        Decimal fixed3Count = 0.00;
        Decimal totalFixedAmountCount = 0.00;
        Decimal reimCount = 0.00;

        String responseData = WrapperUtils.getAllReimbursements(year,contactId,accountId);
        if(responseData != null) {
            employeeReimList = (List<EmployeeReimbursements>)Json.deserialize(responseData,List<EmployeeReimbursements>.class);
        }
        reaimValueWrapperNew employeeReimbursement = new reaimValueWrapperNew();

        for(EmployeeReimbursements empReim : employeeReimList){
            Double variableAmou = Double.valueof((empReim.varibleAmount).replace('$',''));

            if(empReim.mileage != 'null'){
                mileageCount = mileageCount + Double.valueof(empReim.mileage);
            }
            
            if(variableAmou > 0 ){
                varibleAmountCount = varibleAmountCount + variableAmou;
            }
            System.debug('emp value before : '+empReim.fixed1);
            if(empReim.fixed1 != 'null'){
                fixed1Count = fixed1Count + Double.valueof((empReim.fixed1).replace('$',''));
            }
            if(empReim.fixed2 != 'null'){
                fixed2Count = fixed2Count + Double.valueof((empReim.fixed2).replace('$',''));
            }
            if(empReim.fixed3 != 'null'){
                fixed3Count = fixed3Count + Double.valueof((empReim.fixed3).replace('$',''));
            }
            if(empReim.fixedAmount != 'null' && empReim.fixedAmount != null  && empReim.fixedAmount != ''){
                fixedCount = fixedCount + Double.valueof((empReim.fixedAmount).replace('$',''));
            }
            if(empReim.avgToDate != 'null'){
                avgToDateCount = avgToDateCount + Double.valueof((empReim.avgToDate).replace('$',''));
            }
            if(empReim.totalReimbursements != 'null'){
                reimCount = reimCount + Double.valueof((empReim.totalReimbursements).replace('$',''));
            }
        }
        employeeReimbursement.mileageCalc = String.valueOf((mileageCount).setScale(2));
        employeeReimbursement.varibleAmountCalc = '$' +String.valueOf((varibleAmountCount).setScale(2));
        employeeReimbursement.fixed1Calc = fixed1Count != null ? '$' +String.valueOf((fixed1Count).setScale(2)) : '0';
        employeeReimbursement.fixed2Calc = fixed2Count != null ? '$' +String.valueOf((fixed2Count).setScale(2)) : '0';
        employeeReimbursement.fixed3Calc = fixed3Count != null ? '$' +String.valueOf((fixed3Count).setScale(2)) : '0';
        employeeReimbursement.totalFixedAmountCalc = '$' +String.valueOf((totalFixedAmountCount).setScale(2));
        employeeReimbursement.totalMonthlyFixedCalc = '$' +String.valueOf((fixedCount).setScale(2));
        employeeReimbursement.totalAVGCalc = '$' +String.valueOf((avgToDateCount).setScale(2));
        employeeReimbursement.totalReim = '$' +String.valueOf((reimCount).setScale(2));        
        List<String> lstOfReim = new List<String>();
        lstOfReim.add(responseData);
        lstOfReim.add(Json.serialize(employeeReimbursement));
        return lstOfReim;
    }
    //reimbursement wrapper for sending the data in frontend LWC component js class
    public class reaimValueWrapperNew{
        public String mileageCalc {get;set;}
        public String varibleAmountCalc {get;set;}
        public String fixed1Calc {get;set;}
        public String fixed2Calc {get;set;}
        public String fixed3Calc {get;set;}
        public String totalFixedAmountCalc {get;set;}
        public String totalMonthlyFixedCalc {get;set;}
        public String totalAVGCalc {get;set;}
        public String totalReim {get;set;}        
    }

     // AuraEnabled method to get gas price and rate
    @AuraEnabled(cacheable = true)
    public static String getGasPriceandRate(String contactId) {
        List<reaimValueWrapper> reimValue = new List<reaimValueWrapper>();
        List<String> reaimMonthList =  new List<String>();
        reaimMonthList = LWCWrapperUtils.monthList(String.valueOf(System.today().Year()),true);
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        for(Employee_Reimbursement__c empReimLst : [SELECT Id,Month__c,Fuel_Price__c,Variable_Rate__c,Fuel_Variable_Rate__c,Contact_Id__r.MailingCity,Contact_Id__r.MailingState   FROM Employee_Reimbursement__c WHERE Month__c =: reaimMonthList AND Contact_Id__c =: contactId]){
            String strMonthVal = empReimLst.Month__c.split('-').get(0);
            String strMonth = WrapperUtils.getMonthNamefromno(Integer.valueOf(strMonthVal));
            reaimValueWrapper reimWrap = new reaimValueWrapper ();
            reimWrap.reimMonth = strMonth;
            reimWrap.fuelPrice = empReimLst.Fuel_Price__c != null ? String.valueOf(empReimLst.Fuel_Price__c) : '0';
            reimWrap.variableRate = empReimLst.Variable_Rate__c != null ? String.valueOf(empReimLst.Variable_Rate__c) : '0';
            reimValue.add(reimWrap);
        }
        return Json.serialize(reimValue);
    }

    //gives last 2 years reimbursment details
    @AuraEnabled
    public static String getLast2Years(String contactId) {
        return String.escapeSingleQuotes(WrapperUtils.getpastYearReimbursement(contactId));
    }
    //gives user activation time in whole year
    @AuraEnabled
    public static string TimeAttendance(String conId,String year){
        return Json.serialize(BiweeklyPayPeriod.getTimeAndAttendance(conId,year));
    }
    //gives mileage based on the attendence 
    @AuraEnabled
    public static String getMileagesBasedTandAtt(String startdate,String enddate,String contactId) {
        return String.escapeSingleQuotes(WrapperUtils.getMileagesBasedTA(startdate,enddate,contactId));
    }
    //bi-week mileage of whole year
    @AuraEnabled
    public static string biweeklyMileage(String conId,Integer year){
        return Json.serialize(BiweeklyPayPeriod.getBiweeklyReimbursement(conId,year)); 
    }
    //gets the biweek mileage
    @AuraEnabled
    public static List<String> getBiweekMileages(string biweekId) {
        return BiweeklyPayPeriod.getBiweekMileages1(biweekId);
    }
    //aprroved mileage retreival
    @AuraEnabled
    public static string ApproveBiweekMileages(string biweekId) {
        BiweeklyPayPeriod.ApproveBiWeekTrips(biweekId);
        return 'sucess';
    }
    //all the mileage retirieved
    @AuraEnabled
    public static List<String> getAllMileages(String startdate,String enddate,String contactId) {
        return BiweeklyPayPeriod.getAllBiweekMileages1(date.valueof(startdate),date.valueof(enddate),contactId);
    }
    //compliance mileages
    @AuraEnabled
    public static List<String> getCompliance(String contactId) {
        return WrapperUtils.getComplianceCalculation(contactId,String.valueOf(System.today().year()));
    }
    //fuel and variable rates
    @AuraEnabled
    public static String getFuelvariableRate(String contactId) {
        return WrapperUtils.getDriverFuelvariableRate(contactId);
    }
    public class reaimValueWrapper {
        public string reimMonth {get;set;}
        public string fuelPrice {get;set;}
        public string variableRate {get;set;}
    }
    //get reimbursement data
    @AuraEnabled(cacheable=true)
    public static String getReimbursementData(String contactId) {
        return LWCWrapperUtils.getReimbursementData(contactId);
    }
    //packet and meetings
    @AuraEnabled(cacheable=true)
    public static List<String> getPacketandMeeting(String contactId) {
        return WrapperUtils.getPacketandMeetingDetails(contactId);
    }
    //custom settings
    @AuraEnabled
    public static NewDashboardVideoLink__c getCustomSettings(){
        return NewDashboardVideoLink__c.getOrgDefaults();
    }
    
     @AuraEnabled
    public static void postExpenseReimbursement(Id accountId,String empReMonth,String contactEmail,String totalReimburement){
        UploadConcurQuickExpenseTriplog.postTotalReimbursement(accountId,empReMonth,contactEmail,totalReimburement);
    }
    
    @AuraEnabled
    public static void TripCallout(Id driverId, String month, String year, String fuel, String maintTyre, Id empReID,String mpg,String status){
       
        String result = WrapperUtils.TripCallout(driverId,month,year,fuel,maintTyre,empReID,mpg,status);
    }

    //method is use for change reimbursement status    
    @AuraEnabled
    public static String UpdateReimbursementStatus(Id empReID){
        System.debug('Reimb---'+ empReID);
        String result = WrapperUtils.UpdateReimbursementStatus(empReID);
        return result;
    }
    
    //get planned parameter
    @AuraEnabled
    public static String getPlanParameter (String contactId) {
        planParameterWrap wrapObj = new planParameterWrap ();
        List<Attachment> driverPacketAttachmentList = new List<Attachment>();
        for (Attachment att : [select id,Name FROM Attachment WHERE ParentId =: contactId AND (Name LIKE '%Signed Document%' OR Name LIKE '%Driver_Packet%' OR Name LIKE'%MVR%' OR Name Like '%Driver Agreement.pdf%')]){
            driverPacketAttachmentList.add(att);
        }
        if(driverPacketAttachmentList.size() > 0){
            for(Attachment objPacket: driverPacketAttachmentList ){
                String strName = objPacket.Name;
                if(strName.contains('MVR') ){
                    wrapObj.driverMVR = objPacket.Id;
                }
                if(strName.contains('Signed Document') || strName.contains('Driver_Packet') || strName.contains('Driver Agreement.pdf') ) {
                    wrapObj.driverPacketId = objPacket.Id;
                }
            }
        }
        try{
            List<ContentDocumentLink> contentDocLink = [SELECT ContentDocumentId,LinkedEntityId 
                                                                FROM ContentDocumentLink 
                                                                WHERE LinkedEntityId  =: contactId 
                                                                WITH SECURITY_ENFORCED];
            Set<Id> ids = new Set<Id>();
            for(ContentDocumentLink obj:  contentDocLink){
                ids.add(obj.ContentDocumentId);
            }
            ContentDistribution contentDist = [SELECT id,ContentDownloadUrl 
                                                        FROM ContentDistribution
                                                        WHERE ContentDocumentId in : ids
                                                            AND (Name=: Constants.signedDocument OR Name LIKE '%Driver Agreement.pdf%')
                                                            WITH SECURITY_ENFORCED
                                                            ORDER BY createddate DESC limit 1];
            wrapObj.obj_content_version = contentDist.ContentDownloadUrl;
        }catch(Exception e)
            {System.debug('Exception:-->'+e.getmessage()+'--'+e.getLineNumber());}
        return Json.serialize(wrapObj);
    }
    
    @AuraEnabled
    public static string updateContactDetail(String contactId){
        return LWCWrapperUtils.contactDetail(contactId);
    }
    
    
    public class planParameterWrap {
        public string driverPacketId {get;set;}
        public string driverMVR {get;set;}
        public string obj_content_version {get;set;}
    }

    /*
    *************************************
    @Method Name    : getDrivingStates
    @author         : Megha Sachania
    @description    : method used to get driving states
    ********************************************
    */

    @AuraEnabled
    public static String getDrivingStates() {
        List<String> drivingStateList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Driving_States__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry currentPickListEntry : pickListEntries) {
            drivingStateList.add(currentPickListEntry.getValue());
        }
        return JSON.serialize(drivingStateList);     
    }
    
     /*
    *************************************
    @Method Name    : updateStateList
    @author         : Megha Sachania
    @description    : method used to update driving states from mDash
    ********************************************
    */
    
    @AuraEnabled
    public static String updateStateList(String contactId, String listOfStates){
        Contact contactList = [SELECT id, Name, External_Email__c, Driving_States__c 
                                        FROM Contact 
                                        WHERE id =: contactId
                                        WITH SECURITY_ENFORCED];
        if(contactList != null){
           if(listOfStates != null || listOfStates != ''){
                contactList.Driving_States__c = listOfStates;
                update contactList;
           } 
        }
         return 'Success';
    }

    /*
    *************************************
    @Method Name    : sendDrivingStateEmail
    @author         : Megha Sachania
    @description    : Send Email to Admin when driver added driving states from mDash
    ********************************************
    */
    @AuraEnabled
    public static void sendDrivingStateEmail(String id, String drivingStates)
    {
        strOWEEmail = System.Label.Driver_Service_OWE;
        OrgWideEmailAddress[] owea = [SELECT Id, Address 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address =: strOWEEmail
                                                WITH SECURITY_ENFORCED];
        String adminName;
        String driverName;
        String adminEmail;
        if(id != null){
            for(Contact conObj: [SELECT id, FirstName, External_Email__c, 
                                    Manager__r.Role__c, 
                                    Manager__r.Manager__r.Role__c, 
                                    Manager__r.Manager__r.Manager__r.Role__c, 
                                    Manager__r.Manager__r.Manager__r.Manager__r.Role__c,
                                    Manager__r.Manager__r.Manager__r.Manager__r.Manager__r.Role__c,
                                    Manager__r.Name, 
                                    Manager__r.Manager__r.Name, 
                                    Manager__r.Manager__r.Manager__r.Name, 
                                    Manager__r.Manager__r.Manager__r.Manager__r.Name,
                                    Manager__r.Manager__r.Manager__r.Manager__r.Manager__r.Name,  
                                    Manager__r.External_Email__c, 
                                    Manager__r.Manager__r.External_Email__c, 
                                    Manager__r.Manager__r.Manager__r.External_Email__c ,
                                    Manager__r.Manager__r.Manager__r.Manager__r.External_Email__c,
                                    Manager__r.Manager__r.Manager__r.Manager__r.Manager__r.External_Email__c
                                FROM Contact 
                                WHERE ID =: id 
                                    AND Deactivated_Date__c = null
                                WITH SECURITY_ENFORCED]){
                driverName = conObj.FirstName;
                adminName = (conObj.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Name : (conObj.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.Name : (conObj.Manager__r.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.Manager__r.Name : (conObj.Manager__r.Manager__r.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.Manager__r.Manager__r.Name : (conObj.Manager__r.Manager__r.Manager__r.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.Manager__r.Manager__r.Manager__r.Name : null;
                adminEmail = (conObj.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.External_Email__c : (conObj.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.External_Email__c : (conObj.Manager__r.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.Manager__r.External_Email__c : (conObj.Manager__r.Manager__r.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.Manager__r.Manager__r.External_Email__c : (conObj.Manager__r.Manager__r.Manager__r.Manager__r.Manager__r.Role__c == 'Admin') ? conObj.Manager__r.Manager__r.Manager__r.Manager__r.Manager__r.External_Email__c : '';
            }
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateId;
        String newEmailBody;
        String htmlTemplate = '';
        String adminId = '';
        List<String> toAddress = new List<String>();
        List<String> drivingStatesSplitted = new List<String>(); 
        templateId = [SELECT Id, Subject, HtmlValue, body 
                                FROM EmailTemplate 
                                WHERE developerName = 'SendAdminDrivingState' 
                                WITH SECURITY_ENFORCED Limit 1];
        if(templateId != null){
            newEmailBody = templateId.HtmlValue;
            String subjectModify;
            subjectModify = templateId.Subject;
            if(adminName != null && adminEmail != null){
                newEmailBody = newEmailBody.replace('{!ContactName}', adminName);
                newEmailBody = newEmailBody.replace('{!Driver.Name}', driverName);
                List<Contact> conList = [SELECT id, External_Email__c 
                                                    FROM Contact 
                                                    WHERE External_Email__c =: adminEmail
                                                    WITH SECURITY_ENFORCED];
                adminId = (conList.size() != 0) ? conList[0].id : '';
                if(drivingStates != null){
                        drivingStatesSplitted = drivingStates.split(';');   
                        system.debug('drivingStatesSplitted=='+ drivingStatesSplitted);
                        Message__c  newMessage = new Message__c();
                        newMessage.Unread__c = true;
                        newMessage.Notification_Message__c = driverName + ' recently added these driving states: '+ drivingStates.replaceAll(';', ', ');
                        newMessage.Contacts__c = adminId;
                        insert newMessage;
                        for(String objDriving: drivingStatesSplitted) {
                            System.debug('Element at index ' + objDriving);
                            htmlTemplate = htmlTemplate +
                                           '<li style="font-size:16px;font-family:"Calibri",sans-serif;">'+ objDriving +'</li>'; 
                        }
                        newEmailBody = newEmailBody.replace('{drivingState}', htmlTemplate);
                        toAddress.add(adminEmail);
                        newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                        messaging.SingleEmailMessage email = new messaging.SingleEmailMessage();
                        email = Utils.CreateEmail(subjectModify, newEmailBody, toAddress, null, null, null);
                        email.setOrgWideEmailAddressId(owea.get(0).Id);    
                        emailList.add(email);
                }
            }
        }

        if(!emailList.isEmpty() && !Test.isRunningTest()){
            Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList, false); 
        }
    }
}