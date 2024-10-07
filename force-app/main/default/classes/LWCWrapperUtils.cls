/*
@author Sanket Goswami
@date 11th November 2022
@group Wrapper
@description LWCWrapperUtils is used to show/edit Employee details and other Utility features.
*/
public with sharing class LWCWrapperUtils {
    
    /*This method is used to get the reimbursement month list like 01-2022,02-2022.
    Boolean Parameter currentMonth value is true then it will add current reimbursement month in list and if it is false then it will not add current month reimbursement.*/
    public static List<String> monthList (String year, Boolean currentMonth) {
        List<String> reaimMonthList =  new List<String>();
        if(year == String.valueOf(System.today().Year())) {
            Integer month = System.Today().Month();
            if(currentMonth) {
                for(Integer i=1;i<=month-1;i++) {
                    if(i < 10 ) {
                        reaimMonthList.add('0'+String.valueOf(i)+'-'+year); 
                    } else if((i == 10)||(i == 11)) {
                        reaimMonthList.add(String.valueOf(i)+'-'+year);
                    }          
                }
                if(month == 01){
                    reaimMonthList.add('12-'+String.valueOf(System.today().Year()-1));
                }
            } else {
                for(Integer i=1;i<=month;i++) {
                    if(i < 10 ) {
                        reaimMonthList.add('0'+String.valueOf(i)+'-'+year); 
                    } else if((i == 10)||(i == 11)) {
                        reaimMonthList.add(String.valueOf(i)+'-'+year);
                    }          
                }
            }
        } else {
            for(Integer i=1;i<=12;i++) {
                if(i < 10) {
                    reaimMonthList.add('0'+String.valueOf(i)+'-'+year); 
                } else if((i == 10)||(i == 11)) {
                    reaimMonthList.add(String.valueOf(i)+'-'+year);
                }          
            }
        }
        return reaimMonthList;
    }
    
    /* This method is used to get the last and current month mileages and reimbursement data. */
    public static String getReimbursementData(String contactId) {       
        List<String> monthList = new List<String> ();
        date currentMonthDate = System.today();
        date pastMonthDate = System.today().addMonths(-1);
        String currentMonthDateStr = DateTime.newInstance(currentMonthDate.year(),currentMonthDate.month(),currentMonthDate.day()).format('MM-yyyy');
        String pastMonthDateStr = DateTime.newInstance(pastMonthDate.year(),pastMonthDate.month(),pastMonthDate.day()).format('MM-yyyy');        
        monthList.add(currentMonthDateStr);
        monthList.add(pastMonthDateStr);
        WrapReaim objWrap = new WrapReaim();
        for(Employee_Reimbursement__c reimObj : [SELECT Id,Name,Total_Approved__c,Month__c,Fuel_Price__c,Total_Mileage__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Total_Approved_Pending_Mileage__c,Half_Fixed_Amount__c,Total_Monthly_Reimbursement_BiWeek__c,Contact_Id__r.Driver_Type__c,Contact_Id__r.Reimbursement_Frequency__c,Contact_Id__r.Biweek_Reimbursement__c,Contact_Id__r.MailingState,Contact_Id__r.MailingCity,Fixed_Amount__c,Maintenance_and_Tires__c,MPG__c,Contact_Id__r.Activation_Date__c,Contact_Id__r.Half_Fixed_Amount__c,Contact_Id__r.Fixed_Amount__c FROM Employee_Reimbursement__c WHERE Month__c  =: monthList and Contact_Id__c =: contactId]){
            objWrap.pastmonthdate = pastMonthDateStr;
            objWrap.currentmonthdate = currentMonthDateStr;
            if(reimObj.Month__c == pastMonthDateStr || Test.isRunningTest()){
                objWrap.lastmonthmiles = string.valueOf(reimObj.Total_Approved_Pending_Mileage__c);
                    objWrap.lastmonthreimbursement = string.valueOf(reimObj .Total_Monthly_Reimbursement__c);
                objWrap.lastmonthmileagerate = reimObj.Variable_Rate__c != null ? String.valueOf(reimObj.Variable_Rate__c) : '0';     
                objWrap.lastmonthfuelprice = string.valueOf(getDriverGasPrice(reimObj.Contact_Id__r.MailingState,reimObj.Contact_Id__r.MailingCity));
                /* Added By Megha Sachania : 20-03-2024 */
                objWrap.maintainsAndTyresLastMonth  = String.valueOf(reimObj.Maintenance_and_Tires__c);
                objWrap.mpgLastMonth  =String.valueOf(reimObj.MPG__c );
                objWrap.reimIdLastMonth = reimObj.id;
                If(!isCurrentMonth(reimObj.Contact_Id__r.Activation_Date__c)){
                    if(reimObj.Contact_Id__r.Reimbursement_Frequency__c == 'Bi-Weekly Reimbursement'){
                        objWrap.halfFixedAmount = string.valueOf(reimObj.Half_Fixed_Amount__c);
                    }
                    else{
                        objWrap.fixedAmount = string.valueOf(reimObj.Fixed_Amount__c);
                        
                    }
                }
                
            }
            if(reimObj.Month__c == currentMonthDateStr){
                objWrap.halfFixedAmount = string.valueOf(reimObj.Half_Fixed_Amount__c);
                
                If(isCurrentMonth(reimObj.Contact_Id__r.Activation_Date__c)){
                    if(reimObj.Contact_Id__r.Reimbursement_Frequency__c == 'Bi-Weekly Reimbursement'){
                        objWrap.halfFixedAmount = string.valueOf(reimObj.Contact_Id__r.Half_Fixed_Amount__c);
                    }
                    else{
                        objWrap.fixedAmount = string.valueOf(reimObj.Contact_Id__r.Fixed_Amount__c);
                    }
                }
                objWrap.currentmonthmiles = string.valueOf(reimObj.Total_Mileage__c); 
               /* Added By Megha Sachania : 20-03-2024 */
                objWrap.thismonthfuelprice = string.valueOf(getDriverGasPrice(reimObj.Contact_Id__r.MailingState,reimObj.Contact_Id__r.MailingCity));
                objWrap.maintainsAndTyresThisMonth  = String.valueOf(reimObj.Maintenance_and_Tires__c);
                objWrap.mpgThisMonth  =String.valueOf(reimObj.MPG__c );
                objWrap.reimIdThisMonth = reimObj.id;
            }
        }
        return JSON.serialize(objWrap).unescapeHtml4();
    }
    public static Boolean isCurrentMonth(Date dateToCheck) {
        // Get the current date
        Date currentDate = System.today();
        
        // Extract the month from the given date and the current date
        Integer givenMonth = dateToCheck.month();
        Integer givenYear = datetoCheck.year();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.Year();
        // Compare the months
        If(givenMonth == currentMonth &&givenYear == currentYear){
            return true;
        }else{
        return false;
        }
    }
    
    public static String getDriverGasPrice(String mailingState,String mailingCity) {   
        String gaspriceyearmonth = '';
        if(System.today().month() == 1) {
            gaspriceyearmonth = mailingCity + mailingState + 12+ String.valueOf(System.today().year()-1); 
        } else {
            gaspriceyearmonth = mailingCity + mailingState + String.valueOf(System.today().month()-1) + String.valueOf(System.today().year()); 
        }
        List<Gas_Prices__c> gasPriceList = new List<Gas_Prices__c>();
        gasPriceList = [SELECT id,Fuel_Price__c FROM Gas_Prices__c WHERE Month_State_City__c =: gaspriceyearmonth LIMIT 1];
        
        if(gasPriceList.size() > 0 && gasPriceList[0].Fuel_Price__c != null ){
            return String.valueOf(gasPriceList[0].Fuel_Price__c );
        } else {
            return '0';
        }
    }

    public static String getNotificationMessageList(String conId,Integer year,String month){ 
        List<NotificationWrapper> wrapList = new List<NotificationWrapper>();   
        List<String> messages = new List<String>(); 
        Integer monthVal = Integer.valueOf(WrapperUtils.getMonthno(month));
        for(Message__c msgList : [Select Id,Contacts__c,Notification_Message__c,Unread__c,LastModifiedDate,CreatedBy.Name,CreatedDate  from Message__c where Contacts__c =: conId and Notification_Message__c != null Order by Unread__c Desc]){   
            NotificationWrapper reimWrap = new NotificationWrapper(); 
            if(msgList.CreatedBy.Name != 'Tom Honkus' || Test.isRunningTest()){
                String dateval = String.valueOf(msgList.CreatedDate);
                String updatedDate = dateval.substringBefore('T');
                List<String> fullDate = updatedDate.split('-');
                if(Integer.valueOf(fullDate[0]) == year && Integer.valueOf(fullDate[1]) == monthVal){
                    reimWrap.id = msgList.Id;   
                    reimWrap.modifiedDate = msgList.CreatedDate;   
                    reimWrap.notificationMessage = msgList.Notification_Message__c; 
                    reimWrap.createdBy = msgList.CreatedBy.Name;
                    reimWrap.unread = msgList.Unread__c;    
                    wrapList.add(reimWrap);
                }
            } 
            if(msgList.CreatedBy.Name == 'Tom Honkus'){
                reimWrap.id = msgList.Id;   
                reimWrap.modifiedDate = msgList.LastModifiedDate;   
                reimWrap.notificationMessage = msgList.Notification_Message__c; 
                reimWrap.createdBy = msgList.CreatedBy.Name;
                reimWrap.unread = msgList.Unread__c;  
                wrapList.add(reimWrap); 
            }
            
        }
        return JSON.serialize(wrapList);
    }

    public static string updateNotificationMessage(String msgId,Integer year,String month){
        String updatedWrapperJson;
        Message__c msgVal = [Select Id,Contacts__c,Notification_Message__c,Unread__c,LastModifiedDate from Message__c where Id =: msgId];
        if(msgVal != null){
            msgVal.Unread__c = false;
            update msgVal;
        }
        updatedWrapperJson = getNotificationMessageList(msgVal.Contacts__c,year,month);
        return updatedWrapperJson;
    }

    public static string contactDetail(String contactId){
        Contact clist = [SELECT id, Name, External_Email__c, Sync_Feature__c FROM Contact  WHERE id =: contactId];
        if(clist != null){
            clist.Sync_Feature__c = false;
            update clist;
        }
        
        return 'Success';
    }

    /*
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

    public static string updateNotificationMessage(String msgId){
        String updatedWrapperJson;
        Message__c msgVal = [Select Id,Contacts__c,Notification_Message__c,Unread__c,LastModifiedDate from Message__c where Id =: msgId];
        if(msgVal != null){
            msgVal.Unread__c = false;
            update msgVal;
        }
        updatedWrapperJson = getNotificationMessageList(msgVal.Contacts__c);
        return updatedWrapperJson;
    }*/

    public static string reimbursementForHighMileageOrRisk(String managerId,String accountId,String month,boolean showteam,boolean highMileage,String role){
        Map<String,EmployeeMileagesForCalculation> employeeReimbursementMap = new Map<String,EmployeeMileagesForCalculation>();
        
        String query = 'SELECT id, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__r.Accountid,Contact_Id__r.Manager__r.Name, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c, Total_Pending__c,Total_Approved_Pending_Mileage__c, Reimbursement_Approval__c,Mileage_Approver__c,Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c,High_Risk_Total_Mileages__c,High_Risk_Total_Approved__c,High_Risk_Total_Rejected__c FROM Employee_Reimbursement__c ';
        
        if(showteam!=null && showteam == false && (role=='Admin' || role == StaticValues.roleAdminDriver)){
            query += ' WHERE ((Contact_Id__r.Manager__c = \'' + managerId + '\' )' ;
            query +=   ' OR (Contact_Id__r.Manager__r.Manager__c = \'' + managerId + '\' )' ;
            query +=   ' OR (Contact_Id__r.Manager__r.Manager__r.Manager__c = \'' + managerId + '\' )' ;
            query +=   ' OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c = \'' + managerId + '\' ))' ;
        }
        else if(showteam!=null && showteam == true && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
            query += ' WHERE Contact_Id__r.Accountid =\''+ accountId + '\'';
        }
        else if(showteam!=null && showteam == true && (role=='Manager' || role=='Driver/Manager')) {
            query += ' WHERE ((Contact_Id__r.Manager__c = \'' + managerId + '\' )' ;
            query +=   ' OR (Contact_Id__r.Manager__r.Manager__c = \'' + managerId + '\' )' ;
            query +=   ' OR (Contact_Id__r.Manager__r.Manager__r.Manager__c = \'' + managerId + '\' )' ;
            query +=   ' OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c = \'' + managerId + '\' ))' ;
        }
        else if(showteam != null && showteam == false && (role == 'Manager' || role =='Driver/Manager')) {
            query += ' WHERE Contact_Id__r.Accountid =\''+ accountId + '\''; 
            query += ' AND Contact_Id__r.Manager__c =\'' + managerId + '\'';
        }
        String monthstr = WrapperUtils.getMonthno(month);        
        Integer year;
        Integer currentMonth = System.today().month();
        if((currentMonth == 1 || currentMonth == 2) && monthstr == '12'){
            year = System.today().year()- 1;
        } else {
            year = System.today().year();
        }
        string monthVal = String.valueOf(monthstr)+'-'+String.valueOf(year);
        query += ' AND Month__c =\''+ monthVal + '\'';
        //query += ' AND Month__c =\''+ month+ '\'';
        if(!highMileage){
            query += ' AND High_Risk_Total_Mileages__c > 0';  
            query += ' Order By High_Risk_Total_Mileages__c desc';  
        } else{
            query += ' AND Total_Mileage__c > 0';  
            query += ' Order By Total_Mileage__c  desc';
        }

        List<Employee_Reimbursement__c> reimDetail = new List<Employee_Reimbursement__c>();

        try {
            reimDetail = Database.query(query); 
        } catch(System.QueryException qe) {
        }
        for(Employee_Reimbursement__c currentReimbursement : reimDetail) {
            EmployeeMileagesForCalculation reimbursement = new EmployeeMileagesForCalculation();
            if(employeeReimbursementMap.containsKey(currentReimbursement.Contact_Id__c)) {
                if(employeeReimbursementMap.get(currentReimbursement.Contact_Id__c).reimbursementIdList != null && employeeReimbursementMap.get(currentReimbursement.Contact_Id__c).reimbursementIdList.size() > 0) {
                    reimbursement = employeeReimbursementMap.get(currentReimbursement.Contact_Id__c);
                    reimbursement.totalMileages =(currentReimbursement.Total_Pending__c!=null) ? String.valueOf(double.valueOf((reimbursement.totalMileages!=null) ? reimbursement.totalMileages : '0')+double.valueOf(currentReimbursement.Total_Pending__c)):'0';  
                    reimbursement.totalHighRiskMileages  = double.valueOf(currentReimbursement.High_Risk_Total_Mileages__c);
                    if(reimbursement.reimbursementIdList != null && reimbursement.reimbursementIdList.size() >0) {
                        List<String> reimbursementIdList = new List<String>();
                        reimbursementIdList = reimbursement.reimbursementIdList;
                        reimbursementIdList.add(currentReimbursement.id);
                        reimbursement.reimbursementIdList = reimbursementIdList;
                    }
                    employeeReimbursementMap.put(currentReimbursement.Contact_Id__c,reimbursement);
                }
            } else {
                reimbursement.contactid = currentReimbursement.Contact_Id__c;
                reimbursement.id = currentReimbursement.Id;
                reimbursement.name = currentReimbursement.Contact_Id__r.Name;
                reimbursement.month = currentReimbursement.Month__c;
                reimbursement.threshold = String.valueOf(currentReimbursement.Contact_Id__r.Monthly_Mileage_Limit__c);
                reimbursement.totalMileages = (currentReimbursement.Total_Pending__c!=null) ? String.valueOf(currentReimbursement.Total_Pending__c) : '0';
                reimbursement.rejectedMileages = (currentReimbursement.Total_Rejected__c != null) ? String.valueOf(currentReimbursement.Total_Rejected__c) : '0';
                reimbursement.approvedMileages = String.valueOf(currentReimbursement.Total_Approved__c);
                reimbursement.isSelected = false;
                reimbursement.isSelectedEmailReminder = false;
                reimbursement.managerName = currentReimbursement.Contact_Id__r.Manager__r.Name != null ? currentReimbursement.Contact_Id__r.Manager__r.Name : '';
                reimbursement.mileageApproval = currentReimbursement.Mileage_Approver__c != null ? currentReimbursement.Mileage_Approver__c : '';
                reimbursement.managerEmail = currentReimbursement.Contact_Id__r.Manager__r.External_Email__c != null ? currentReimbursement.Contact_Id__r.Manager__r.External_Email__c : '';
                List<String> reimbursementIdList = new List<String>();
                reimbursementIdList.add(currentReimbursement.Id);
                reimbursement.reimbursementIdList = reimbursementIdList;
                reimbursement.reimbursementApproval = currentReimbursement.Reimbursement_Approval__c;
                reimbursement.status = currentReimbursement.Status__c;
                reimbursement.totalHighRiskMileages  = double.valueOf(currentReimbursement.High_Risk_Total_Mileages__c);
                reimbursement.highRiskTotalApproved  = double.valueOf(currentReimbursement.High_Risk_Total_Approved__c);
                reimbursement.highRiskTotalRejected  = double.valueOf(currentReimbursement.High_Risk_Total_Rejected__c);
                if(currentReimbursement.Mileage_Lock_Date__c != null) {
                if(String.valueOf(currentReimbursement.Mileage_Lock_Date__c).contains('-')) {
                        List<String> approvedDateSplitted = new List<String>();
                        approvedDateSplitted = String.valueOf(currentReimbursement.Mileage_Lock_Date__c).split('-');
                        reimbursement.lockDate = approvedDateSplitted[1]+'/'+approvedDateSplitted[2]+'/'+approvedDateSplitted[0].substring(2,4);
                    }
                } else {
                    reimbursement.lockDate = '';
                }
                employeeReimbursementMap.put(currentReimbursement.Contact_Id__c,reimbursement);
            }
        }    
        return JSON.serialize((List<EmployeeMileagesForCalculation>)employeeReimbursementMap.values()).unescapeHtml4();
        // return query;
    }

    public static string accountMonthList(String accountId){
        Account acc = [Select id, name, CreatedDate from Account where id =: accountId ];
        Integer monthVal = acc.CreatedDate.month();
        Integer yearVal = acc.CreatedDate.year();
        Integer currentMonth = System.today().month();
        List<Integer> monthLst = new List<Integer>();
        List<String> monthStringLst = new List<String>();
            if(yearVal == System.today().year()){
                for(Integer i=currentMonth; i >= monthVal; i--){
                    monthLst.add(currentMonth);
                    currentMonth -= 1 ;
                }
            }
            else{
                for(Integer i=currentMonth; i > 0; i--){
                    monthLst.add(currentMonth);
                    currentMonth -= 1 ;
                }
                if(System.today().month() == 01){
                    monthLst.add(12);
                }
            }
        for(Integer monthValue: monthLst){
            monthStringLst.add(WrapperUtils.getMonthNamefromno(monthValue));
        }
        return JSON.serialize(monthStringLst).unescapeHtml4();
    }

    public static string contactReimMonthList(String contactId){
        List<Integer> monthVal = new List<Integer>();
        List<String> monthStringLst = new List<String>();
        Integer CurrentMonth= System.today().month();

        if(CurrentMonth==1){
            monthStringLst.add('December');
            monthStringLst.add('January');
        }else{
            for(Employee_Reimbursement__c reimList : [Select id , Name, Contact_Id__c, Month__c,Year__c,Month_Field__c from Employee_Reimbursement__c where Contact_Id__c =: contactId order by Month__c desc]){
                if(reimList.Year__c == System.today().year()){
                    monthVal.add(reimList.Month_Field__c.month());
                }
            }
            monthVal.sort();
            for(Integer monthValue: monthVal){
                monthStringLst.add(WrapperUtils.getMonthNamefromno(monthValue));
            }
        }
        return JSON.serialize(monthStringLst).unescapeHtml4();
    }


    public static string getLastMonthReimbursements(String contactId, String accountId,boolean showteam,String role,String month) {
        String monthstr = WrapperUtils.getMonthno(month);
        String year ;
        Integer currentMonth = System.today().month();
        if((currentMonth == 1 || currentMonth == 2) && monthstr == '12'){
            year  = String.valueOf(System.today().year()- 1);
        } else {
            year = String.valueOf(System.today().year());
        }
        
        
        string monthVal = String.valueOf(monthstr)+'-'+String.valueOf(year);
        
        List<EmployeeReimbursementDetailsAdmin> reimbursementList = new List<EmployeeReimbursementDetailsAdmin>();
        Account currentAccount = new Account();
        if(String.isNotBlank(accountId)) {
            currentAccount = [SELECT id,Last_Reimbursement_Created__c FROM Account WHERE ID =: accountId];
        }
        if(currentAccount != null && String.isNotBlank(currentAccount.Last_Reimbursement_Created__c)) {
            List<Employee_Reimbursement__c> employeeReimbursementList = new List<Employee_Reimbursement__c>();
            if(showteam != null && showteam == true && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
                employeeReimbursementList =[SELECT ID, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Contact_Id__r.Manager__r.Name, Total_Approved__c, Total_Mileage__c, Status__c, Reimbursement_Approval__c, Mileage_Approver__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  AND Month__c = :monthVal AND Contact_Id__r.Deactivated_Date__c = null ];
            }
            else if(showteam!=null && showteam == false && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
                employeeReimbursementList = [SELECT ID, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__c, Contact_Id__r.name,  Contact_Id__r.Monthly_Mileage_Limit__c, Contact_Id__r.Manager__r.Name, Total_Approved__c,  Total_Mileage__c, Status__c, Reimbursement_Approval__c,  Mileage_Approver__c, Contact_Id__r.Manager_External_Email__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  and Month__c = :monthVal AND Contact_Id__r.Deactivated_Date__c = null  and ((Contact_Id__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
            } else if(showteam!=null && showteam == true && (role=='Manager' || role=='Driver/Manager')) {
                employeeReimbursementList = [SELECT ID,  Name,  Month__c,  Total_Rejected__c,  Approved_Date__c,  Contact_Id__c,  Contact_Id__r.name,  Contact_Id__r.Monthly_Mileage_Limit__c, Contact_Id__r.Manager__c, Contact_Id__r.Manager__r.Name, Total_Approved__c,  Total_Mileage__c,  Status__c, Reimbursement_Approval__c,Mileage_Approver__c, Contact_Id__r.Manager__r.External_Email__c, Mileage_Lock_Date__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  AND Contact_Id__r.Deactivated_Date__c = null and Month__c = :monthVal and ((Contact_Id__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
            } else if(showteam != null && showteam == false && (role == 'Manager' || role == 'Driver/Manager')) {
                employeeReimbursementList = [SELECT ID,  Name,  Month__c,  Total_Rejected__c,  Approved_Date__c,  Contact_Id__c,  Contact_Id__r.name,  Contact_Id__r.Monthly_Mileage_Limit__c,  Contact_Id__r.Manager__c, Contact_Id__r.Manager__r.Name, Total_Approved__c,  Total_Mileage__c,  Status__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c, Reimbursement_Approval__c, Mileage_Approver__c,Contact_Id__r.Manager_External_Email__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  AND Contact_Id__r.Deactivated_Date__c = null AND Month__c = :monthVal AND (Contact_Id__r.Manager__c =:contactId)];
            }
            for (Employee_Reimbursement__c currentReimbursement : employeeReimbursementList) {
                reimbursementList.add(WrapperUtils.getEmployeeReimbursementDetails(currentReimbursement));
            }
        }
        return JSON.serialize(reimbursementList).unescapeHtml4();
    }

    public class NotificationWrapper{
        public string id {get; set;}
        public DateTime modifiedDate {get; set;}
        public String createdBy {get;set;}
        public String notificationMessage {get; set;}
        public Boolean unread {get; set;}
    }
    
    public class WrapReaim{
        public string lastmonthmiles {get;set;}
        public string currentmonthmiles {get;set;}
        public string lastmonthreimbursement {get;set;}
        public string lastmonthmileagerate {get;set;}
        public string lastmonthfuelprice {get;set;}
        public string thismonthfuelprice {get;set;}
        public string maintainsAndTyresLastMonth {get;set;}
        public string maintainsAndTyresThisMonth {get;set;}
        public string mpgThisMonth {get;set;}
        public string mpgLastMonth {get;set;}
        public string reimIdLastMonth {get;set;}
        public string reimIdThisMonth {get;set;}
        public string pastmonthdate {get;set;}
        public string currentmonthdate {get;set;}
        public string halfFixedAmount {get;set;}
        public string fixedAmount {get;set;}
    }
}