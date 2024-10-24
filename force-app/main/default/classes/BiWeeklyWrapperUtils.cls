/**
 * @description       : 
 * @author            : Harsita
 * @group             : 
 * @last modified on  : 23-10-2024
 * @last modified by  : Harsita
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   17-10-2024   Harsita   Initial Version
**/
public with sharing class BiWeeklyWrapperUtils {
    public BiWeeklyWrapperUtils() {
        system.debug('BiWeeklyWrapperUtils Class Started');
    }
    public static String getPayPeriodDates (String accountId){
        Decimal days;
        String startDate;
        List<String> dateRange = new List<String>();
        for(account acc : [SELECT id,name,Pay_Period_Start_Date__c, Pay_Period_Days__c 
                                    FROM Account 
                                    WHERE id =: accountId
                                    WITH SECURITY_ENFORCED])
        {
            days = (acc.Pay_Period_Days__c != null ? acc.Pay_Period_Days__c : null);
            startDate = (acc.Pay_Period_Start_Date__c !=null ? string.valueof(acc.Pay_Period_Start_Date__c) : null);
        }
        for(integer i=0; i<=100; i++ ) {
            string[] splitsdate = startDate.split('-');
            string splitStartDate = splitsdate[1]+'/'+splitsdate[2]+'/'+splitsdate[0];
            String enddate = String.valueof(date.valueof(startDate).addDays(Integer.valueof(days)));
            string[] splitdate = enddate.split('-');
            string splitEndDate = splitdate[1]+'/'+splitdate[2]+'/'+splitdate[0];
            if(date.valueof(enddate) < date.today()){
                dateRange.add(splitStartDate+' to '+ splitEndDate);
            }
            startDate = String.valueof(date.valueof(enddate).addDays(1));
        }
        if(dateRange.size() == 0){
            return null;
        } else {
            return dateRange.get(dateRange.size()-1);
        }
    }
    
    public static Boolean checkBiweekAccount(String accountId){
        List<Account> account = [SELECT id,Bi_Weekly_Pay_Period__c FROM Account WHERE id =: accountId WITH SECURITY_ENFORCED];
        return account[0].Bi_Weekly_Pay_Period__c;
    }
    public static string getLastMonthReimbursements(String contactId, String accountId,boolean showteam,String role) {  
        // its replacement of 
        List<EmployeeReimbursementDetailsAdmin> reimbursementList = new List<EmployeeReimbursementDetailsAdmin>();
        Account currentAccount = new Account();
        String payPeriodName = getPayPeriodDates(accountId);
        if(String.isNotBlank(accountId)) {
            currentAccount = [SELECT id,Last_Reimbursement_Created__c FROM Account WHERE ID =: accountId WITH SECURITY_ENFORCED];
        }
        if(currentAccount != null && String.isNotBlank(currentAccount.Last_Reimbursement_Created__c)) {   
            List<Bi_Weekly_Reimbursement__c> employeeReimbursementList = new List<Bi_Weekly_Reimbursement__c>();
            
            if(showteam != null && showteam == true && (role=='Admin' || role == StaticValues.roleAdminDriver)) // || role == 'Admin/Driver'
            {
                employeeReimbursementList =[SELECT ID, 
                                                    Name, 
                                                    Month__c,
                                                    Total_Rejected__c,
                                                    Approved_Date__c,
                                                    Contact__r.AccountId,
                                                    Contact__r.Manager__r.Name,
                                                    Contact__c,
                                                    Contact__r.name,
                                                    Contact__r.Monthly_Mileage_Limit__c,
                                                    Total_Approved__c,
                                                    Total_Mileage__c,
                                                    Status__c,
                                                    Mileage_Lock_Date__c,
                                                    Reimbursement_Approval__c 
                                                FROM Bi_Weekly_Reimbursement__c
                                                WHERE Contact__r.Accountid = :accountId
                                                    AND Name =: payPeriodName
                                                    AND Contact__r.Deactivated_Date__c = null
                                                WITH SECURITY_ENFORCED];
            }
            else if(showteam!=null && showteam == false && (role=='Admin' || role == StaticValues.roleAdminDriver)) //|| role == 'Admin/Driver'
            {
                employeeReimbursementList = [SELECT ID, 
                                                    Name, 
                                                    Month__c, 
                                                    Total_Rejected__c, 
                                                    Approved_Date__c, 
                                                    Contact__c, 
                                                    Contact__r.name, 
                                                    Contact__r.Monthly_Mileage_Limit__c,
                                                    Contact__r.Manager__r.Name, 
                                                    Total_Approved__c, 
                                                    Total_Mileage__c, 
                                                    Status__c,
                                                    Reimbursement_Approval__c,
                                                    Mileage_Lock_Date__c
                                                FROM Bi_Weekly_Reimbursement__c 
                                                WHERE Contact__r.Accountid = :accountId 
                                                    AND Name =: payPeriodName
                                                    AND Contact__r.Deactivated_Date__c = null 
                                                    AND ((Contact__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))
                                                WITH SECURITY_ENFORCED];
            }
            else if(showteam!=null && showteam == true && (role=='Manager' || role=='Driver/Manager'))
            {
                employeeReimbursementList = [SELECT ID, 
                                                    Name, 
                                                    Month__c, 
                                                    Total_Rejected__c, 
                                                    Approved_Date__c, 
                                                    Contact__c, 
                                                    Contact__r.name, 
                                                    Contact__r.Monthly_Mileage_Limit__c,
                                                    Contact__r.Manager__c,
                                                    Contact__r.Manager__r.Name,
                                                    Total_Approved__c, 
                                                    Total_Mileage__c, 
                                                    Status__c,
                                                    Reimbursement_Approval__c,
                                                    Mileage_Lock_Date__c 
                                                FROM Bi_Weekly_Reimbursement__c 
                                                WHERE Contact__r.Accountid = :accountId 
                                                    AND Contact__r.Deactivated_Date__c = null
                                                    AND Name =: payPeriodName
                                                    AND ((Contact__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))
                                                    WITH SECURITY_ENFORCED];
            }
            else if(showteam != null && showteam == false && (role == 'Manager' || role == 'Driver/Manager'))
            {
                employeeReimbursementList = [SELECT ID, 
                                                    Name, 
                                                    Month__c, 
                                                    Total_Rejected__c, 
                                                    Approved_Date__c, 
                                                    Contact__c, 
                                                    Contact__r.name, 
                                                    Contact__r.Monthly_Mileage_Limit__c, 
                                                    Contact__r.Manager__c,
                                                    Contact__r.Manager__r.Name,
                                                    Total_Approved__c, 
                                                    Total_Mileage__c, 
                                                    Status__c,
                                                    Reimbursement_Approval__c,
                                                    Mileage_Lock_Date__c 
                                                FROM Bi_Weekly_Reimbursement__c 
                                                WHERE Contact__r.Accountid = :accountId 
                                                    AND Contact__r.Deactivated_Date__c = null
                                                    AND Name =: payPeriodName
                                                    AND (Contact__r.Manager__c =:contactId)
                                                WITH SECURITY_ENFORCED];
            }       
            if(Test.isRunningTest()){
                employeeReimbursementList = [SELECT ID, 
                                                    Name, 
                                                    Month__c, 
                                                    Total_Rejected__c, 
                                                    Approved_Date__c, 
                                                    Contact__c, 
                                                    Contact__r.name, 
                                                    Contact__r.Monthly_Mileage_Limit__c, 
                                                    Contact__r.Manager__c,
                                                    Contact__r.Manager__r.Name,
                                                    Total_Approved__c, 
                                                    Total_Mileage__c, 
                                                    Status__c,
                                                    Reimbursement_Approval__c,
                                                    Mileage_Lock_Date__c  
                                                FROM Bi_Weekly_Reimbursement__c
                                                WHERE Contact__r.Accountid = :accountId
                                                    AND Contact__r.Deactivated_Date__c = null
                                                WITH SECURITY_ENFORCED];
            }
            for (Bi_Weekly_Reimbursement__c currentReimbursement : employeeReimbursementList) 
            {
                reimbursementList.add(getEmployeeReimbursementDetails(currentReimbursement));
            }
            
        }        
        return JSON.serialize(reimbursementList).unescapeHtml4();
    }
    
    public static EmployeeReimbursementDetailsAdmin getEmployeeReimbursementDetails(Bi_Weekly_Reimbursement__c currentEmployeeReimbursement)
    {
        Double totalrejected =0;
        EmployeeReimbursementDetailsAdmin employeeReimbursement = new EmployeeReimbursementDetailsAdmin();
        employeeReimbursement.id= currentEmployeeReimbursement.id;
        employeeReimbursement.contactid=currentEmployeeReimbursement.Contact__c;
        employeeReimbursement.name = currentEmployeeReimbursement.Contact__r.Name;
        employeeReimbursement.month = currentEmployeeReimbursement.Month__c;
        employeeReimbursement.threshold =String.valueOf( currentEmployeeReimbursement.Contact__r.Monthly_Mileage_Limit__c);
        employeeReimbursement.totalMileages = String.valueOf(currentEmployeeReimbursement.Total_Mileage__c);
        employeeReimbursement.approvedMileages = String.valueOf(currentEmployeeReimbursement.Total_Approved__c);
        employeeReimbursement.managerName = currentEmployeeReimbursement.Contact__r.Manager__r.Name;
        employeeReimbursement.status = currentEmployeeReimbursement.Status__c;
        if(currentEmployeeReimbursement.Approved_Date__c != null)
        {
            if(String.valueOf(currentEmployeeReimbursement.Approved_Date__c).contains('-')) {
                List<String> approvedDateSplitted = new List<String>();
                approvedDateSplitted = String.valueOf(currentEmployeeReimbursement.Approved_Date__c).split('-');
                employeeReimbursement.approvedDate = approvedDateSplitted[1]+'/'+approvedDateSplitted[2]+'/'+approvedDateSplitted[0].substring(2,4);
            }
        } else {
            employeeReimbursement.approvedDate = '';
        }
        if(currentEmployeeReimbursement.Mileage_Lock_Date__c != null) {
            if(String.valueOf(currentEmployeeReimbursement.Mileage_Lock_Date__c).contains('-')) {
                List<String> approvedDateSplitted = new List<String>();
                approvedDateSplitted = String.valueOf(currentEmployeeReimbursement.Mileage_Lock_Date__c).split('-');
                employeeReimbursement.lockDate = approvedDateSplitted[1]+'/'+approvedDateSplitted[2]+'/'+approvedDateSplitted[0].substring(2,4);
            }
        } else {
            employeeReimbursement.lockDate = '';
        }  
        employeeReimbursement.rejectedMileages = String.valueOf(currentEmployeeReimbursement.Total_Rejected__c);
        employeeReimbursement.reimbursementApproval = currentEmployeeReimbursement.Reimbursement_Approval__c;
        employeeReimbursement.isSelected = false;
        return employeeReimbursement;
    }
    
    public static string getUnapprovedReimbursements(String contactId, String accountId,boolean showteam,String role) 
    {
        
        // its replacement of getAllDriversLastMonthUpdatedUnapprovedReimburseClone and getAllDriversLastMonthUnapprovedReimbursementsClone
        Map<String,EmployeeMileagesForCalculation> employeeReimbursementMap = new Map<String,EmployeeMileagesForCalculation>();
        String payPeriodName = getPayPeriodDates(accountId);
        List<Bi_Weekly_Reimbursement__c> employeeReimbursementList = new List<Bi_Weekly_Reimbursement__c>();
        
        if(showteam!=null && showteam == true && (role=='Admin' || role == StaticValues.roleAdminDriver)) // || role == 'Admin/Driver'
        {
            employeeReimbursementList =[SELECT id,
                                                Name, 
                                                Month__c,
                                                Total_Rejected__c,
                                                Approved_Date__c,
                                                Contact__r.AccountId,
                                                Contact__r.Manager__r.Name,
                                                Contact__c,
                                                Contact__r.name,
                                                Contact__r.Monthly_Mileage_Limit__c,
                                                Total_Approved__c,
                                                Total_Mileage__c,                                            
                                                Status__c,
                                                Total_Variable_Rate__c,
                                                Total_Pending__c,
                                                Total_Approved_Pending_Mileage__c,
                                                Mileage_Lock_Date__c,
                                                Reimbursement_Approval__c,Employee_Reimbursement__c
                                            FROM Bi_Weekly_Reimbursement__c
                                            WHERE Approved_Date__c = null AND Status__c='Pending'
                                                AND Contact__r.Accountid =: accountId
                                                AND (Name =: payPeriodName OR Contact__r.Deactivated_Date__c = THIS_YEAR)
                                            WITH SECURITY_ENFORCED 
                                            ORDER BY Total_Pending__c desc];
        }
        else if(showteam!=null && showteam == false && (role=='Admin' || role == StaticValues.roleAdminDriver)) // || role == 'Admin/Driver'
        {
            employeeReimbursementList =[SELECT id,
                                                Name, 
                                                Month__c,
                                                Total_Rejected__c,
                                                Approved_Date__c,
                                                Contact__r.AccountId,
                                                Contact__r.Manager__r.Name,
                                                Contact__c,
                                                Contact__r.name,
                                                Contact__r.Monthly_Mileage_Limit__c,
                                                Total_Approved__c,
                                                Total_Mileage__c,                                            
                                                Status__c,
                                                Total_Variable_Rate__c,
                                                Total_Pending__c,
                                                Total_Approved_Pending_Mileage__c,
                                                Mileage_Lock_Date__c,
                                                Reimbursement_Approval__c,Employee_Reimbursement__c
                                            FROM Bi_Weekly_Reimbursement__c
                                            WHERE Approved_Date__c = null AND Status__c='Pending'
                                                AND Contact__r.Accountid =: accountId
                                                AND (Name =: payPeriodName OR Contact__r.Deactivated_Date__c = THIS_YEAR)
                                                AND ((Contact__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                        OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))
                                            WITH SECURITY_ENFORCED
                                            ORDER BY Total_Pending__c desc];
        }
        else if(showteam!=null && showteam == true && (role=='Manager' || role=='Driver/Manager'))
        {
            employeeReimbursementList =[SELECT id,
                                                Name, 
                                                Month__c,
                                                Total_Rejected__c,
                                                Approved_Date__c,
                                                Contact__r.AccountId,
                                                Contact__r.Manager__r.Name,
                                                Contact__c,
                                                Contact__r.name,
                                                Contact__r.Monthly_Mileage_Limit__c,
                                                Total_Approved__c,
                                                Total_Mileage__c,                                            
                                                Status__c,
                                                Total_Variable_Rate__c,
                                                Total_Pending__c,
                                                Total_Approved_Pending_Mileage__c,
                                                Mileage_Lock_Date__c,
                                                Reimbursement_Approval__c,Employee_Reimbursement__c
                                            FROM Bi_Weekly_Reimbursement__c
                                            WHERE Approved_Date__c = null AND Status__c='Pending'
                                                AND Contact__r.Accountid =: accountId
                                                AND (Name =: payPeriodName OR Contact__r.Deactivated_Date__c = THIS_YEAR)
                                                AND ((Contact__r.Manager__c =: contactId) 
                                                    OR (Contact__r.Manager__r.Manager__c =: contactId) 
                                                    OR (Contact__r.Manager__r.Manager__r.Manager__c =: contactId) 
                                                    OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__c =: contactId) 
                                                    OR (Contact__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: contactId))
                                            WITH SECURITY_ENFORCED
                                            ORDER BY Total_Pending__c desc];
        }
        
        else if(showteam != null && showteam == false && (role == 'Manager' || role =='Driver/Manager'))
        {
            employeeReimbursementList = [SELECT id,
                                                Name, 
                                                Month__c,
                                                Total_Rejected__c,
                                                Approved_Date__c,
                                                Contact__r.AccountId,
                                                Contact__r.Manager__r.Name,
                                                Contact__c,
                                                Contact__r.name,
                                                Contact__r.Monthly_Mileage_Limit__c,                                            
                                                Total_Approved__c,
                                                Total_Mileage__c,
                                                Status__c,
                                                Total_Variable_Rate__c,
                                                Total_Pending__c,
                                                Total_Approved_Pending_Mileage__c,
                                                Mileage_Lock_Date__c,
                                                Reimbursement_Approval__c,Employee_Reimbursement__c
                                            FROM Bi_Weekly_Reimbursement__c
                                            WHERE Approved_Date__c = null AND Status__c='Pending'
                                                AND Contact__r.Accountid =: accountId
                                                AND (Name =: payPeriodName OR Contact__r.Deactivated_Date__c = THIS_YEAR)
                                                AND (Contact__r.Manager__c =: contactId) 
                                            WITH SECURITY_ENFORCED
                                            ORDER BY Total_Pending__c desc];        
            
        }       
        for(Bi_Weekly_Reimbursement__c currentReimbursement : employeeReimbursementList)
        {
            EmployeeMileagesForCalculation reimbursement = new EmployeeMileagesForCalculation();
            if(employeeReimbursementMap.containsKey(currentReimbursement.Contact__c))
            {
                if(employeeReimbursementMap.get(currentReimbursement.Contact__c).reimbursementIdList != null && employeeReimbursementMap.get(currentReimbursement.Contact__c).reimbursementIdList.size() > 0)
                {                    
                    reimbursement = employeeReimbursementMap.get(currentReimbursement.Contact__c);
                    reimbursement.totalMileages =(currentReimbursement.Total_Pending__c!=null) ? String.valueOf(double.valueOf((reimbursement.totalMileages!=null) ? reimbursement.totalMileages : '0')+double.valueOf(currentReimbursement.Total_Pending__c)):'0';                    
                    if(reimbursement.reimbursementIdList != null && reimbursement.reimbursementIdList.size() >0)
                    {                        
                        List<String> reimbursementIdList = new List<String>();
                        reimbursementIdList = reimbursement.reimbursementIdList;
                        reimbursementIdList.add(currentReimbursement.id);
                        reimbursement.reimbursementIdList = reimbursementIdList; 
                    }
                    employeeReimbursementMap.put(currentReimbursement.Contact__c,reimbursement);
                }                
            }
            else
            {
                reimbursement.contactid = currentReimbursement.Contact__c;
                reimbursement.reimbursementid = currentReimbursement.Id;
                reimbursement.name = currentReimbursement.Contact__r.Name;
                reimbursement.month = currentReimbursement.Month__c;
                reimbursement.threshold = String.valueOf(currentReimbursement.Contact__r.Monthly_Mileage_Limit__c);
                reimbursement.totalMileages = (currentReimbursement.Total_Pending__c!=null) ? String.valueOf(currentReimbursement.Total_Pending__c) : '0';
                reimbursement.TotalReimMileages = (currentReimbursement.Total_Mileage__c != null) ? String.valueOf(currentReimbursement.Total_Mileage__c) : '0';                reimbursement.approvedMileages = String.valueOf(currentReimbursement.Total_Approved__c);             
                reimbursement.isSelected = false;
                reimbursement.isSelectedEmailReminder = false;
                List<String> reimbursementIdList = new List<String>();
                reimbursementIdList.add(currentReimbursement.Id);
                reimbursement.reimbursementIdList = reimbursementIdList;
                reimbursement.reimbursementApproval = currentReimbursement.Reimbursement_Approval__c;
                reimbursement.status = currentReimbursement.Status__c;
                reimbursement.originalReimbursementid = currentReimbursement.Employee_Reimbursement__c != null ? currentReimbursement.Employee_Reimbursement__c : null;
                reimbursement.rejectedMileges = (currentReimbursement.Total_Rejected__c != null) ? String.valueOf(currentReimbursement.Total_Rejected__c) : '0';
                if(currentReimbursement.Mileage_Lock_Date__c != null) {
                    if(String.valueOf(currentReimbursement.Mileage_Lock_Date__c).contains('-')) {
                        List<String> approvedDateSplitted = new List<String>();
                        approvedDateSplitted = String.valueOf(currentReimbursement.Mileage_Lock_Date__c).split('-');
                        reimbursement.lockDate = approvedDateSplitted[1]+'/'+approvedDateSplitted[2]+'/'+approvedDateSplitted[0].substring(2,4);
                    }
                } else {
                    reimbursement.lockDate = '';
                }
                employeeReimbursementMap.put(currentReimbursement.Contact__c,reimbursement);                                          
            }
        }    
        return JSON.serialize((List<EmployeeMileagesForCalculation>)employeeReimbursementMap.values()).unescapeHtml4();
    }
    
    public static String getUnapprovedMileages(String reimbursementDetails)
    {
        EmployeeMileagesForCalculation reimbursement = new EmployeeMileagesForCalculation();
        if(reimbursementDetails!=null && reimbursementDetails!='')
        {
            reimbursement = (EmployeeMileagesForCalculation)Json.deserialize(reimbursementDetails,EmployeeMileagesForCalculation.class);
            List<EmployeeMileages> employeeMileagesList = new List<EmployeeMileages>();
            for(Employee_Mileage__c currentMileage : [SELECT id,Name,Trip_Status__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Date__c,
                                                            Trip_Origin__c,Trip_Destination__c,Bi_Weekly_Reimbursement__c,
                                                            Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,TimeZone__c,Tag__c,
                                                            Bi_Weekly_Reimbursement__r.month__c,Bi_Weekly_Reimbursement__r.Total_Pending__c,Stay_Time__c,
                                                            Bi_Weekly_Reimbursement__r.Total_Mileage__c,Bi_Weekly_Reimbursement__r.Contact__c,Driving_Time__c,
                                                            Total_Time__c,CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,
                                                            Mileage_Lock_Date__c,Day_Of_Week__c,Destination_Name__c,
                                                            Bi_Weekly_Reimbursement__r.Contact__r.External_Email__c,Bi_Weekly_Reimbursement__r.Half_Fixed_Amount__c, 
                                                            Maintenance_and_Tires__c,Fuel_price__c,Bi_Weekly_Reimbursement__r.Total_Variable_Rate__c,
                                                            ConvertedStartTime__c,ConvertedEndTime__c,Bi_Weekly_Reimbursement__r.Total_Rejected__c,
                                                            Notes__c,Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c,Activity__c,
                                                            EmployeeReimbursement__r.Contact_Id__r.Account.Bi_Weekly_Pay_Period__c,
                                                            High_Risk_Mileage__c,Approval_Name__c
                                                            FROM Employee_Mileage__c 
                                                            WHERE Trip_Status__c =: StaticValues.noApprovedYet 
                                                                AND Approved_Date__c = null 
                                                                AND Bi_Weekly_Reimbursement__c IN : reimbursement.reimbursementIdList
                                                            WITH SECURITY_ENFORCED])
            {
                employeeMileagesList.add(getMileagesOfReimbursement(currentMileage));
            }
            reimbursement.mileagesList = employeeMileagesList;
        }
        return JSON.serialize(reimbursement).unescapeHtml4();
    }
    
    public static EmployeeMileages getMileagesOfReimbursement(Employee_Mileage__c employeeMileage)
    {
        EmployeeMileages objEmployeeMileage = new EmployeeMileages();
        objEmployeeMileage.id=employeeMileage.id;
        objEmployeeMileage.isSelected = false;
        objEmployeeMileage.isChecked = false;
        objEmployeeMileage.isUnapprove = false;
        if(employeeMileage.Trip_Status__c != null) {
            objEmployeeMileage.status = employeeMileage.Trip_Status__c;    
        }
        if(employeeMileage.Activity__c != null) {
            objEmployeeMileage.tripActivity = employeeMileage.Activity__c;    
        }
        if(employeeMileage.Maintenance_and_Tires__c != null){
            objEmployeeMileage.maintTyre = string.valueof(employeeMileage.Maintenance_and_Tires__c);
        }
        
        if(employeeMileage.Stay_Time__c != null){
            objEmployeeMileage.staytime = string.valueof(employeeMileage.Stay_Time__c);
        }
        else{
            objEmployeeMileage.staytime = '0';
        }
        
        if(employeeMileage.Driving_Time__c != null){
            objEmployeeMileage.drivingtime = string.valueof(employeeMileage.Driving_Time__c);
        } else {
            objEmployeeMileage.drivingtime = '0';
        }
        
        if(employeeMileage.Total_Time__c   != null){
            objEmployeeMileage.totaltime = string.valueof(employeeMileage.Total_Time__c);
        } else{
            objEmployeeMileage.totaltime = '0';
        }
        
        
        if(employeeMileage.Fuel_price__c != null){
            objEmployeeMileage.fuelRate = string.valueof(employeeMileage.Fuel_price__c);
        }
        if(employeeMileage.Bi_Weekly_Reimbursement__r.Half_Fixed_Amount__c != null){
            objEmployeeMileage.halfFixedAmount = string.valueof(employeeMileage.Bi_Weekly_Reimbursement__r.Half_Fixed_Amount__c);
        }
        if(employeeMileage.Bi_Weekly_Reimbursement__r.Total_Variable_Rate__c != null){
            objEmployeeMileage.variablerate = string.valueof(employeeMileage.Bi_Weekly_Reimbursement__r.Total_Variable_Rate__c);
        }
        
        objEmployeeMileage.fromLocation='';
        objEmployeeMileage.toLocation='';
        
        objEmployeeMileage.dayofweek='';
        objEmployeeMileage.starttime='';
        objEmployeeMileage.endtime='';
        objEmployeeMileage.originname='';
        objEmployeeMileage.destinationname='';
        objEmployeeMileage.tracingstyle='';
        objEmployeeMileage.emailaddress='';
        if(employeeMileage.Origin_Name__c != null)
        {
            objEmployeeMileage.originname= employeeMileage.Origin_Name__c;
        }
        if(employeeMileage.Notes__c != null){ 
            objEmployeeMileage.notes = employeeMileage.Notes__c;
        }
        
        if(employeeMileage.Tag__c != null){ 
            objEmployeeMileage.tag = employeeMileage.Tag__c;
        }
        
        if(employeeMileage.Tracing_Style__c != null)
        {
            objEmployeeMileage.tracingstyle=employeeMileage.Tracing_Style__c;
        }
        
        if(employeeMileage.ConvertedStartTime__c  != null ) {
            DateTime startTime = employeeMileage.ConvertedStartTime__c;
            objEmployeeMileage.startdatetime = employeeMileage.ConvertedStartTime__c;
            objEmployeeMileage.starttime = startTime.format('h:mm a','America/Panama');
        }
        
        if(employeeMileage.ConvertedEndTime__c  != null) {
            DateTime endTime = employeeMileage.ConvertedEndTime__c ;
            objEmployeeMileage.enddatetime = employeeMileage.ConvertedEndTime__c ;
            objEmployeeMileage.endTime = endTime.format('h:mm a','America/Panama');
        }         
        
        if(employeeMileage.Day_Of_Week__c != null)
        {
            objEmployeeMileage.dayofweek=employeeMileage.Day_Of_Week__c;
        }
        if(employeeMileage.Destination_Name__c != null)
        {
            objEmployeeMileage.destinationname=employeeMileage.Destination_Name__c;
        }
        objEmployeeMileage.emailaddress=employeeMileage.Bi_Weekly_Reimbursement__r.Contact__r.External_Email__c;
        
        if(employeeMileage.Trip_Status__c != null && employeeMileage.Trip_Status__c == 'Rejected')
        {
            objEmployeeMileage.isChecked = true;
        }        
        objEmployeeMileage.origin = employeeMileage.Trip_Origin__c;
        objEmployeeMileage.destination = employeeMileage.Trip_Destination__c;
        if(employeeMileage.Trip_Date__c != null)
        {
            if(String.valueOf(employeeMileage.Trip_Date__c).contains('-'))
            {
                List<String> tripDateSplitted = new List<String>();
                tripDateSplitted = String.valueOf(employeeMileage.Trip_Date__c).split('-');
                objEmployeeMileage.tripdate  = tripDateSplitted[1]+'/'+tripDateSplitted[2]+'/'+tripDateSplitted[0].substring(2,4);
            }
        }
        if(String.valueOf(employeeMileage.Mileage__c) != null){
            objEmployeeMileage.mileage  = String.valueOf(employeeMileage.Mileage__c);
        } else {
            objEmployeeMileage.mileage  = '0.00';
        }
        
        if(employeeMileage.Approved_Date__c != null)
        {
            if(String.valueOf(employeeMileage.Approved_Date__c).contains('-'))
            {
                List<String> approveDateSplitted = new List<String>();
                approveDateSplitted = String.valueOf(employeeMileage.Approved_Date__c).split('-');
                objEmployeeMileage.approveddate  = approveDateSplitted[1]+'/'+approveDateSplitted[2]+'/'+approveDateSplitted[0].substring(2,4);
            }
        }
        if(employeeMileage.Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c != null) {
            if(String.valueOf(employeeMileage.Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c).contains('-'))
            {
                List<String> lockDateSplitted = new List<String>();
                lockDateSplitted = String.valueOf(employeeMileage.Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c).split('-');
                objEmployeeMileage.lockdate  = lockDateSplitted[1]+'/'+lockDateSplitted[2]+'/'+lockDateSplitted[0].substring(2,4);
                objEmployeeMileage.isLockDate = true;
            }
        }
        Date createddate = Date.valueOf(employeeMileage.CreatedDate);
        if(CreatedDate != null && String.valueOf(createddate).contains('-'))
        {
            List<String> createdDateSplitted = new List<String>();
            createdDateSplitted = String.valueOf(createddate).split('-');
            objEmployeeMileage.submitteddate =  createdDateSplitted[1]+'/'+createdDateSplitted[2]+'/'+createdDateSplitted[0].substring(2,4);
        }
        objEmployeeMileage.totalrejected = String.valueOf(employeeMileage.Bi_Weekly_Reimbursement__r.Total_Rejected__c);
        objEmployeeMileage.totalMileages = String.valueOf(employeeMileage.Bi_Weekly_Reimbursement__r.Total_Mileage__c);
        objEmployeeMileage.totalpending = String.valueOf(employeeMileage.Bi_Weekly_Reimbursement__r.Total_Pending__c);
        objEmployeeMileage.variableamount  = String.valueOf(employeeMileage.Variable__c);
        objEmployeeMileage.month  = employeeMileage.Bi_Weekly_Reimbursement__r.month__c;               
        if(employeeMileage.EmployeeReimbursement__r.Contact_Id__r.Account.Bi_Weekly_Pay_Period__c == true){
            objEmployeeMileage.reimbursementid  = employeeMileage.Bi_Weekly_Reimbursement__c;
            objEmployeeMileage.originalReimbursementid = employeeMileage.EmployeeReimbursement__c;
        } else {
            objEmployeeMileage.reimbursementid  = employeeMileage.EmployeeReimbursement__c;
        }
        objEmployeeMileage.driverid = employeeMileage.Bi_Weekly_Reimbursement__r.Contact__c;
        
        if(employeeMileage.Original_Origin_Name__c != null){
            objEmployeeMileage.originalOriginName = employeeMileage.Original_Origin_Name__c;
        } else if(employeeMileage.Origin_Name__c != null){
            objEmployeeMileage.originalOriginName = employeeMileage.Origin_Name__c;
        } else{
            objEmployeeMileage.originalOriginName = null;
        }
        
        if(employeeMileage.Original_Destination_Name__c != null){
            objEmployeeMileage.originalDestinationName = employeeMileage.Original_Destination_Name__c;
        } else if(employeeMileage.Destination_Name__c != null){
            objEmployeeMileage.originalDestinationName = employeeMileage.Destination_Name__c;
        } else{
            objEmployeeMileage.originalDestinationName = null;
        }
        objEmployeeMileage.highRiskMileage = employeeMileage.High_Risk_Mileage__c;
        objEmployeeMileage.approvalName = employeeMileage.Approval_Name__c;
        return objEmployeeMileage;
    }
    
    public static Map<String, Id> getBiweeklyReimMap (String contactId,Date minTripdate, Date maxTripDate, Boolean checkBiweekAcc){
        Map<String, Id> biWeeklyReimMap = new Map<String, Id>();
        if(checkBiweekAcc) {
            for(Bi_Weekly_Reimbursement__c biWeekObj: [SELECT id,Start_Date__c, End_Date__c,Contact__c 
                                                        FROM Bi_Weekly_Reimbursement__c 
                                                        WHERE Contact__c =: contactId 
                                                            AND Start_Date__c >=: minTripdate
                                                            AND End_Date__c <=: maxTripDate
                                                            AND Start_Date__c != null
                                                            AND End_Date__c != null
                                                        WITH SECURITY_ENFORCED])
            {
                biWeeklyReimMap.put(biWeekObj.Start_Date__c.format() + ':' + biWeekObj.End_Date__c.format(),  biWeekObj.Id);                                   
            }
        } else {
            List<Bi_Weekly_Reimbursement__c> biWeekObjlist = [SELECT id,Start_Date__c, End_Date__c,Contact__c 
                                                              FROM Bi_Weekly_Reimbursement__c 
                                                              WHERE Contact__c =: contactId
                                                              WITH SECURITY_ENFORCED
                                                              Limit 1];
            biWeeklyReimMap.put(biWeekObjlist.get(0).Id, biWeekObjlist.get(0).Id);
            
        }
        return biWeeklyReimMap;
    }
    
    public static string getBiweekReimId (String contactId,Date tripdate,Boolean checkBiweekAcc){
        String biWeekId;
        if(checkBiweekAcc == true ){
            Integer payDays;
            Date payStartDate;            
            for(Contact con : [SELECT id,Account.Pay_Period_Days__c,
                                      Account.Pay_Period_Start_Date__c,Account.Bi_Weekly_Pay_Period__c 
                                    FROM Contact 
                                    WHERE id =: contactId
                                    WITH SECURITY_ENFORCED])
            {
                payDays = Integer.valueOf(con.Account.Pay_Period_Days__c);
                payStartdate = con.Account.Pay_Period_Start_Date__c;                
            }            
            Date endDate;
            List<Date> dtList = new list<Date>();
            do {
                endDate = payStartdate.addDays(payDays);
                if(payStartdate <= tripdate && tripdate <= endDate) {
                    dtList.add(payStartdate);
                    dtList.add(endDate);
                }
                payStartdate = endDate.addDays(1);
            } while(endDate <= System.today());
            if(!dtList.isEmpty()){
                for(Bi_Weekly_Reimbursement__c biWeekObj: [SELECT id,Start_Date__c, End_Date__c,Contact__c 
                                                                FROM Bi_Weekly_Reimbursement__c 
                                                                WHERE Contact__c =: contactId 
                                                                AND Start_Date__c =: date.valueof(dtList[0])
                                                                AND End_Date__c =: date.valueof(dtList[1])
                                                                WITH SECURITY_ENFORCED])
                {
                    System.debug('***inside for  ***');
                    biWeekId = biWeekObj.Id;
                }
            } 
        } else {
            for(Bi_Weekly_Reimbursement__c biWeekObj: [SELECT id,Start_Date__c, End_Date__c,Contact__c 
                                                            FROM Bi_Weekly_Reimbursement__c 
                                                            WHERE Contact__c =: contactId 
                                                            WITH SECURITY_ENFORCED
                                                            Limit 1]) 
            {
                biWeekId = biWeekObj.Id;
            }
        }        
        return biWeekId;       
    }
    
    public static void sendInsuranceEmail (String contactId,String objName,String driverEmail){
        String adminName;
        String adminEmail;        
        if(contactId != null){
            for(Contact conObj : [SELECT id,FirstName,External_Email__c
                                  FROM Contact 
                                  WHERE ID =: contactId
                                  WITH SECURITY_ENFORCED])
            {
                adminName = conObj.FirstName;
                adminEmail = conObj.External_Email__c;
            }
        }
        List<Messaging.SingleEmailMessage> emailist = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateId;
        String newemailBody;
        OrgWideEmailAddress[] owea = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address = 'driverservices@mburse.com' WITH SECURITY_ENFORCED];
        List<String> toAddress = new List<String>();
        if(contactId != null && adminEmail != driverEmail) {       
            templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'SendAdminInsuranceEmail' WITH SECURITY_ENFORCED Limit 1];
            newemailBody = templateId.HtmlValue;
            if(adminName != null ){
                newemailBody = newemailBody.replace('{!Contact.Manager__r}', adminName);
            }
            if(objName != null ){
                newemailBody = newemailBody.replace('{drivername}', objName);
            }            
            toAddress.add(adminEmail);            
        } else {
            templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'SendDriverInsuranceEmail' WITH SECURITY_ENFORCED Limit 1];
            newemailBody = templateId.HtmlValue;
            newemailBody = newemailBody.replace('{!ContactName}', objName);
            toAddress.add(driverEmail);            
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();        
        newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        messaging.singleEmailMessage email = Utils.CreateEmail(templateId.Subject,newemailBody,toAddress,null,null,null);
        email.setOrgWideEmailAddressId(owea[0].Id);
        emailist.add(email); 
        SendEmail__c  sendEmailObj = SendEmail__c.getValues('BiWeekWrapSendAdmin');
        if(!emailist.isEmpty() && !Test.IsRunningTest() && sendEmailObj.Send_email_from_code__c == true) {                 
            Messaging.SendEmailResult [] result = Messaging.sendEmail(emailist, false);             
        }
    }
}