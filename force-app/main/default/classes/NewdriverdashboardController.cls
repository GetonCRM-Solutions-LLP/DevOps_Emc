/**
 * @Author: GetonCRM Solutions LLP
 * @Description: this class represent methods related to dashboard in Mdash including the profile Manger/Driver, Admin/Driver ,Driver.
 * @Modification logs
 * ========================================================================================================================
 * @Date:  08th November 2021 | Sanket goswami
 *
 */
global class NewdriverdashboardController {
    global static Map<String,String> reimMap {get;set;}
    global static string contactObj {get;set;}
    global static string chartData {get;set;}
    global static string gasPrice {get;set;}
    global static string contactRole {get;set;}
    global static string unreimbursement {get;set;}
    global static Map<String,String> mileageMap {get;set;}
    global static List<String> reimList {get; set;}
    
    
    global NewdriverdashboardController () {
        contactObj = getContactDetailsClone(getContactid());
        chartData = getChartData(getContactid());
        unreimbursement = String.escapeSingleQuotes(WrapperUtils.getReimbursementsList(getContactid(),'Approved'));
        List<Contact> conList = [SELECT id,Role__c,Driving_States__c FROM Contact WHERE id =: getContactid() ];
        if(conList.size() > 0){
            contactRole = Json.serialize(String.valueOf(conList[0].Role__c));
        }
    }
    //fetches the account id from header
    public static String getAccountid() {
        if(ApexPages.currentPage().getParameters().containsKey('accid') && String.isNotBlank(ApexPages.currentPage().getParameters().get('accid'))) {
            return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        }
    }
    //gets contact id
    public static String getContactid() {
        if(ApexPages.currentPage().getParameters().containsKey('id') && String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
            return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        }
    }
    //redirection link
    public static PageReference getRedirected() {
        if(getContactid()!=''&& getAccountid()!='') {
            return null;
        } else {
            // redirect to error page
            return null;
        }
    }
    //gets reimbursment list
    global static String getReimbursementsList() {
        return String.escapeSingleQuotes(WrapperUtils.getReimbursementsList(getContactid(),'Approved'));
    }
    //gets contact details
    @RemoteAction
    global static string getContactDetailsClone(String contactid) {
        Map<Integer,String> monthNameMap=new Map<Integer, String>{01 =>'Jan', 02=>'Feb', 03=>'Mar', 04=>'Apr', 05=>'May', 06=>'Jun', 07=>'Jul', 08=>'Aug', 09=>'Sep',10=>'Oct', 11=>'Nov', 12=>'Dec'};
        reimMap = new Map<string,string>();
        mileageMap = new Map<string,string>();
        ContactDetails contactObj = new ContactDetails();
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        String contactFixedAmount ;
        String biWeekFixedAmount ;
        Boolean check = false;
        
        for(Employee_Reimbursement__c reim : [SELECT id,Total_Approved__c,Total_Monthly_Reimbursement__c,Variable_Rate__c, Year__c,Contact_Id__r.MailingCity,Contact_Id__r.MailingState,  Contact_Id__r.MailingPostalCode, Contact_Id__r.Fixed_Amount__c,  Contact_Id__r.Driving_States__c, Contact_Id__r.Vehicle_Type__c,Contact_Id__r.Half_Fixed_Amount__c, Contact_Id__r.Car_Image__c, Contact_Id__r.Annual_Total_Approved_Mileage__c, Contact_Id__r.Total_reimbursment__c,Contact_Id__r.Account.name,YearMonth__c, Contact_Id__r.monthly_compliance_status__c,Contact_Id__r.Account.Logo_Document_Id__c, Contact_Id__r.Name,Contact_Id__r.Insurance_Attachment_Id__c,Month__c,Fixed_Amount__c, Contact_Id__r.Driver_Type__c,Contact_Id__r.Plan_Years__c,Contact_Id__r.Insurance_Plan__c, Contact_Id__r.Compliance_Mileage__c,Contact_Id__r.Vehicle_Value__c,Contact_Id__r.Biweek_Reimbursement__c,Contact_Id__r.Reimbursement_Frequency__c, Contact_Id__r.Insurance_Upload_Date__c,Contact_Id__r.Notification_Message__c,Contact_Id__r.Insurance__c, Contact_Id__r.Vehicle_Age__c,Contact_Id__r.Vehicle_Value_Check__c,Contact_Id__r.Mileage_Meet__c FROM Employee_Reimbursement__c  WHERE Contact_Id__c =: contactid AND ( Year__c =: System.today().year() OR Month__c =: lastMonth ) ORDER BY YearMonth__c DESC LIMIT 2]){

            String m = reim.Month__c;
            List<String> monthList = m.split('-');
            reimMap.put(monthNameMap.get(Integer.valueof(monthList[0])), String.valueof(reim.Total_Monthly_Reimbursement__c+'-'+reim.Total_Monthly_Reimbursement__c));
            mileageMap.put(monthNameMap.get(Integer.valueof(monthList[0])), String.valueof(reim.Total_Approved__c+'-'+reim.Total_Approved__c));
            contactFixedAmount = String.valueof(reim.Contact_Id__r.Fixed_Amount__c) != null ? String.valueof(reim.Contact_Id__r.Fixed_Amount__c) : '0';
            biWeekFixedAmount = String.valueof(reim.Contact_Id__r.Half_Fixed_Amount__c) != null ? String.valueof(reim.Contact_Id__r.Half_Fixed_Amount__c) : '0';
            contactObj.accountName = reim.Contact_Id__r.Account.name;
            contactObj.accountLogo = reim.Contact_Id__r.Account.Logo_Document_Id__c != null ? reim.Contact_Id__r.Account.Logo_Document_Id__c : null;
            contactObj.contactName = reim.Contact_Id__r.Name;
            contactObj.zipCode = reim.Contact_Id__r.MailingPostalCode != null ? reim.Contact_Id__r.MailingPostalCode : null;
            contactObj.city = reim.Contact_Id__r.MailingCity != null ? reim.Contact_Id__r.MailingCity : null;
            contactObj.state = reim.Contact_Id__r.MailingState != null ? reim.Contact_Id__r.MailingState : null;
            contactObj.vehicalType = reim.Contact_Id__r.Vehicle_Type__c ;
            contactObj.compliancestatus = reim.Contact_Id__r.monthly_compliance_status__c ;
            contactObj.carImage = reim.Contact_Id__r.Car_Image__c ;
            contactObj.insuranceAttchId = reim.Contact_Id__r.Insurance_Attachment_Id__c ;
            contactObj.driverType = reim.Contact_Id__r.Driver_Type__c != null ? reim.Contact_Id__r.Driver_Type__c : null;
            contactObj.annualReim = String.valueof(reim.Contact_Id__r.Total_reimbursment__c) != null ? String.valueof(reim.Contact_Id__r.Total_reimbursment__c) : '0';
            contactObj.annualMileages = String.valueof(reim.Contact_Id__r.Annual_Total_Approved_Mileage__c) != null ? String.valueof(reim.Contact_Id__r.Annual_Total_Approved_Mileage__c) : '0';
            contactObj.planInsurance = String.valueof(reim.Contact_Id__r.Insurance_Plan__c) != null ? String.valueof(reim.Contact_Id__r.Insurance_Plan__c) : null;
            contactObj.complianceMileage = String.valueof(reim.Contact_Id__r.Compliance_Mileage__c) != null ? String.valueof((reim.Contact_Id__r.Compliance_Mileage__c).setScale(2)) : '0';
            contactObj.planYears = String.valueof(reim.Contact_Id__r.Plan_Years__c) != null ? String.valueof(reim.Contact_Id__r.Plan_Years__c) : '0';
            contactObj.vehicleValue = String.valueof(reim.Contact_Id__r.Vehicle_Value__c) != null ? String.valueof(reim.Contact_Id__r.Vehicle_Value__c) : '0';
            contactObj.insuranceDate = reim.Contact_Id__r.Insurance_Upload_Date__c != null ? reim.Contact_Id__r.Insurance_Upload_Date__c : null;
            contactObj.drivingState = reim.Contact_Id__r.Driving_States__c != null ? reim.Contact_Id__r.Driving_States__c : null;
            contactObj.notimessage = reim.Contact_Id__r.Notification_Message__c != null ? reim.Contact_Id__r.Notification_Message__c : null;
            contactObj.vehicleage = reim.Contact_Id__r.Vehicle_Age__c != null ? reim.Contact_Id__r.Vehicle_Age__c : null;
            contactObj.vehiclevaluecheck = reim.Contact_Id__r.Vehicle_Value_Check__c != null ? reim.Contact_Id__r.Vehicle_Value_Check__c : null;
            contactObj.mileagemeet = reim.Contact_Id__r.Mileage_Meet__c != null ? reim.Contact_Id__r.Mileage_Meet__c : null;
            contactObj.insurance = reim.Contact_Id__r.Insurance__c != null ? reim.Contact_Id__r.Insurance__c : null;
            contactObj.biWeekContact =  reim.Contact_Id__r.Reimbursement_Frequency__c != null && reim.Contact_Id__r.Reimbursement_Frequency__c == 'Monthly Reimbursement' ? false : true;
            if(reim.Month__c != null && reim.Month__c == lastMonth){
                contactObj.variableRate = String.valueof(reim.Variable_Rate__c) != null ? String.valueof(reim.Variable_Rate__c) : null;
                check = true;
            } else if(check == false){
                contactObj.variableRate = String.valueof(reim.Variable_Rate__c) != null ? String.valueof(reim.Variable_Rate__c) : null;
            }
        }
        if(contactObj.biWeekContact == true){
            contactObj.fixedAmount = biWeekFixedAmount;
        } else if (contactFixedAmount != null) {
            contactObj.fixedAmount = contactFixedAmount;
        }
        gasPrice = WrapperUtils.getDriverGasPrice(contactObj.state,contactObj.city);
        return JSON.serialize(contactObj).unescapeHtml4();
    }
    //gets all the reimbursement
    @RemoteAction
    global Static String getAllReimbursements(String year,String did,String accid) {
        return String.escapeSingleQuotes(WrapperUtils.getAllReimbursements(year,did,accid));
    }
    //gets charts for the mburse dashboard
    @RemoteAction
    global static String getChartData(String contactid) {
        Map<Integer,String> monthNameMap = new Map<Integer, String>{01 =>'Jan', 02=>'Feb', 03=>'Mar', 04=>'Apr', 05=>'May', 06=>'Jun', 07=>'Jul', 08=>'Aug', 09=>'Sep',10=>'Oct', 11=>'Nov', 12=>'Dec'};
        List<ReibursementWrapper> wrapList = new List<ReibursementWrapper>();
        List<Contact> conList = [SELECT id,Account.Start_Graph_Month__c,Activation_Date__c,Deactivated_Date__c FROM contact WHERE id =:contactid ];
        Integer startMonth;
        integer endMonth;
        String graphMonth;
        if(conList[0].Account.Start_Graph_Month__c != null){
            graphMonth = conList[0].Account.Start_Graph_Month__c;
        }
        if(conList[0].Deactivated_Date__c != null && conList[0].Deactivated_Date__c.Year() == system.today().year()){
            endMonth =  conList[0].Deactivated_Date__c.month();
        }else {
            endMonth = System.today().month();
        }

        if(conList[0].Activation_Date__c != null && conList[0].Activation_Date__c.Year() == system.today().year()){
            startMonth =  conList[0].Activation_Date__c.month();
        } else if(graphMonth == 'Jan' ){
            startMonth= 1;
        }else{
            startmonth =12;
        }
        
        List<String> monthList = new List<String>();
        if(startMonth==12){
            Integer year = Date.today().year() - 1;
            monthList.add('12-'+year);
            
            for(integer i = 1;i <=endMonth;i++){
                If(endMonth==12){
                    break;
                }
                monthList.add( ( i < 10 ? '0' : '' ) + i + '-' + system.today().year());
            }
        } else {
            for(integer i = startMonth;i <=endMonth;i++){
                monthList.add( ( i < 10 ? '0' : '' ) + i + '-' + system.today().year());
            }
        }
        Map<String,Decimal> milMap = new Map<String,Decimal>();
        Map<String,Decimal> reimMap = new Map<String,Decimal>();
        for(Employee_Reimbursement__c reim : [SELECT Id,Month__c, Total_Approved_Pending_Mileage__c, Total_Monthly_Reimbursement__c  FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactid AND Month__c IN:monthList ORDER BY CreatedDate DESC LIMIT 12 ]) {
           
            milMap.put(reim.Month__c, reim.Total_Approved_Pending_Mileage__c);
            reimMap.put(reim.Month__c, reim.Total_Monthly_Reimbursement__c);
        }
        Decimal sumMileage = 0;
        Decimal sumReim = 0;
        Map<Integer, Decimal> averageReimMap = new Map<Integer, Decimal>();
        List<String> monthNum= new List<String>();
        Integer noOfMonthPassed =1;
        List<String> monthListForGraphtoShow = new List<String>();
        if(graphMonth != null && graphMonth == 'Jan'){
            for(integer i = 1;i <=12;i++){
                monthListForGraphtoShow.add( ( i < 10 ? '0' : '' ) + i + '-' + system.today().year());
            }
        } else if(graphMonth != null && graphMonth == 'Dec'){
            Integer year = Date.today().year() - 1;
            monthListForGraphtoShow.add('12-'+year);
            for(integer i = 1;i <=11;i++){
                monthListForGraphtoShow.add( ( i < 10 ? '0' : '' ) + i + '-' + system.today().year());
            }
        }
        for(String i :monthListForGraphtoShow ){
            sumMileage += milMap.containskey(i) ? milMap.get(i) : 0;
            sumReim += reimMap.containskey(i) ? reimMap.get(i) : 0;
            ReibursementWrapper reimWrap = new ReibursementWrapper();
            reimWrap.mileage = milMap.get(i);
            reimWrap.reimbursement = reimMap.get(i);
            monthNum = i.split('-');
            reimWrap.month = monthNameMap.get(Integer.valueOf(monthNum[0]));
            reimWrap.averageMileage = milMap.containskey(i) ? ( sumMileage / noOfMonthPassed).setScale(2):0;
            reimWrap.averagereimbursement = milMap.containskey(i) ? ( sumReim / noOfMonthPassed).setScale(2):0;
            reimWrap.ActivationDate =conList[0].Activation_Date__c;
            if(monthList.contains(i)){
                noOfMonthPassed++;
            }
            wrapList.add(reimWrap);
        }
    System.debug('output'+JSON.serialize(wrapList));
        return JSON.serialize(wrapList);
    }
    //fetches notification message for the account
    @AuraEnabled
    public static String getNotificationMessageList(String conId){
        List<NotificationWrapper> wrapList = new List<NotificationWrapper>();
        List<String> messages = new List<String>();
        for(Message__c msgList : [Select Id,Contacts__c,Notification_Message__c,Unread__c,LastModifiedDate from Message__c where Contacts__c =: conId and Notification_Message__c != null and Unread__c = true Order by LastModifiedDate Desc]){
            NotificationWrapper reimWrap = new NotificationWrapper();
            reimWrap.id = msgList.Id;
            reimWrap.modifiedDate = msgList.LastModifiedDate;
            reimWrap.notificationMessage = msgList.Notification_Message__c;
            reimWrap.unread = msgList.Unread__c;
            wrapList.add(reimWrap);
        }
        return JSON.serialize(wrapList);
    }
    //updating notification message 
    @AuraEnabled
    public static string updateNotificationMessage(String msgId){
        String updatedWrapperJson;
        Message__c msgVal = [Select Id,Contacts__c,Notification_Message__c,Unread__c,LastModifiedDate from Message__c where Id =: msgId];
        if(msgVal != null){
            msgVal.Unread__c = false;
            update msgVal;
        }
        updatedWrapperJson = getNotificationMessageList(msgVal.Contacts__c);
        return updatedWrapperJson;
    }
    //notification data wrapper class
    public class NotificationWrapper{
        public string id {get; set;}
        public DateTime modifiedDate {get; set;}
        public String notificationMessage {get; set;}
        public Boolean unread {get; set;}
    }
    //reimbursement data wrapper
    public class ReibursementWrapper{
        public string month {get; set;}
        public Decimal mileage {get; set;}
        public Decimal averageMileage {get; set;}
        public Decimal reimbursement {get; set;}
        public Decimal averagereimbursement {get; set;}
        public Date ActivationDate{get; set;}
    }
    
}