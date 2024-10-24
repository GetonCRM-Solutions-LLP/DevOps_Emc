/**
@authOR Natavar Ghodasara
@date 26th Feb 2019
@group Wrapper
@group-content WrapperDetails.html
@description WrapperUtils is used to show/edit Employee details AND other Utility features.
Before deploy to production uncomment this batch ChangeTripStatusinTripLog.
*/
public with sharing class WrapperUtils 
{
    /**
@authOR Natavar Ghodasar
@date 26th Feb 2019
@description Default Constructor.
*/
    public WrapperUtils() { 
        system.debug('WrapperUtils class started');
    }
    public static string getChartData(String contactId,boolean showTeamRecord,String accountId,String role) {
        List<Employee_Reimbursement__c> reimbursementList = new List<Employee_Reimbursement__c>();
        if(showTeamRecord == true && (role == 'Admin' || role == StaticValues.roleAdminDriver)) {
            reimbursementList =[SELECT ID,Total_Mileage__c,Status__c,Month__c 
                                        FROM Employee_Reimbursement__c 
                                        WHERE Contact_Id__r.Accountid =:accountId  
                                            AND (Month__c=:WrapperUtils.getLastMonthValue(-1) 
                                                    OR Month__c=:WrapperUtils.getLastMonthValue(-2) 
                                                    OR Month__c=:WrapperUtils.getLastMonthValue(-3))
                                        WITH SECURITY_ENFORCED];
        } else if(showTeamRecord == false && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
            reimbursementList =[SELECT ID,Total_Mileage__c,Status__c,Month__c 
                                        FROM Employee_Reimbursement__c 
                                        WHERE (Contact_Id__r.Manager__c =:contactId 
                                                OR (Contact_Id__r.Manager__r.Manager__c =:contactId) 
                                                OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)) 
                                            AND (Month__c=:WrapperUtils.getLastMonthValue(-1) 
                                            OR Month__c=:WrapperUtils.getLastMonthValue(-2) 
                                            OR Month__c=:WrapperUtils.getLastMonthValue(-3))
                                        WITH SECURITY_ENFORCED];
        } else if(showTeamRecord == true && (role=='Manager' || role=='Driver/Manager')) {
            reimbursementList =[SELECT ID,Total_Mileage__c,Status__c,Month__c 
                                            FROM Employee_Reimbursement__c 
                                            WHERE (Contact_Id__r.Manager__c =:contactId 
                                                    OR (Contact_Id__r.Manager__r.Manager__c =:contactId) 
                                                    OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                    OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId) 
                                                    OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)) 
                                                AND (Month__c=:WrapperUtils.getLastMonthValue(-1) OR Month__c=:WrapperUtils.getLastMonthValue(-2) 
                                                    OR Month__c=:WrapperUtils.getLastMonthValue(-3))
                                            WITH SECURITY_ENFORCED];
        } else if(showTeamRecord == false && (role=='Manager' || role=='Driver/Manager')) {
            reimbursementList =[SELECT ID,Total_Mileage__c,Status__c,Month__c 
                                        FROM Employee_Reimbursement__c 
                                        WHERE Contact_Id__r.Manager__c =:contactId 
                                        AND (Month__c=:WrapperUtils.getLastMonthValue(-1) 
                                                OR Month__c=:WrapperUtils.getLastMonthValue(-2) 
                                                OR Month__c=:WrapperUtils.getLastMonthValue(-3))
                                        WITH SECURITY_ENFORCED];
        }
        return JSON.serialize(reimbursementList);
        }
    
        /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getEmployeeDetails is used to built EmployeeDetails Wrapper object FROM Contact.
    @param currentContact currentContact is the Single Contact FROM which you want to Built Wrapper. 
    @return EmployeeDetails built by the method.
    */
    public static EmployeeDetails getEmployeeDetails(Contact currentContact, Decimal avgReim, Decimal avgMileage) {
        EmployeeDetails currentEmployeeDetail = new EmployeeDetails();
        currentEmployeeDetail.userid = currentContact.id  !=  null ? currentContact.id : '';
        if(currentContact.firstName  !=  null) {
            currentEmployeeDetail.firstName=currentContact.firstName;  
            currentEmployeeDetail.name = currentEmployeeDetail.firstName;  
        } else {
            currentEmployeeDetail.firstName= '';
            currentEmployeeDetail.name = '';
        }
        //Megha : changed FROM "currentEmployeeDetail.IsDeactivated" to "currentEmployeeDetail.deactivateUser"
        currentEmployeeDetail.deactivateUser = currentContact.IsDeactivated__c;
        if(currentContact.lastName  !=  null) {
            currentEmployeeDetail.lastName=currentContact.lastName;
            currentEmployeeDetail.name = currentEmployeeDetail.name + ' '+ currentContact.lastName;   
        } else {
            currentEmployeeDetail.lastName='';            
        }
        /* khuman*/
        if(currentContact.Mileage_for_deduct__c  !=  null) {
            currentEmployeeDetail.mileageForDeduction=currentContact.Mileage_for_deduct__c;
        } else {
            currentEmployeeDetail.mileageForDeduction= 0;            
        }
        /* khuman*/
        currentEmployeeDetail.cellphone = currentContact.Phone  !=  null ? currentContact.Phone : '';
        currentEmployeeDetail.branchName = String.IsNotBlank(currentContact.Branch_Name__c) ? currentContact.Branch_Name__c : '';
        currentEmployeeDetail.deactivationBy = currentContact.Deactivated_By__c != null ? currentContact.Deactivated_By__c : '';
        currentEmployeeDetail.branchNumber = String.IsNotBlank(String.valueOf(currentContact.Branch_Number__c)) ? String.valueOf(currentContact.Branch_Number__c) : '';
        currentEmployeeDetail.cellphone = currentContact.MobilePhone  !=  null ? currentContact.MobilePhone : '';
        currentEmployeeDetail.appVersion = currentContact.App__c != null ?  currentContact.App__c : '';
        currentEmployeeDetail.manualEntryUser = currentContact.is_Manual_Entry_User__c == true ? 'Yes' : 'No';
        currentEmployeeDetail.compliancestatus = currentContact.compliancestatus__c != null ? currentContact.compliancestatus__c : '';
        currentEmployeeDetail.monthlymileage = String.isNotBlank(String.valueOf(avgMileage)) ? String.valueOf(avgMileage) : ''; 
        currentEmployeeDetail.finalPayrollAmount = String.isNotBlank(String.valueOf(currentContact.Final_Payroll_Amount__c)) ? String.valueOf(currentContact.Final_Payroll_Amount__c) : ''; 
        currentEmployeeDetail.firstPayrollPer = String.isNotBlank(String.valueOf(currentContact.First_Payroll__c)) ? String.valueOf(currentContact.First_Payroll__c) : '';
        currentEmployeeDetail.sage100ID = currentContact.Sage_100_ID__c != null ? currentContact.Sage_100_ID__c : '';
        currentEmployeeDetail.glcode = currentContact.GL_Code__c != null ? currentContact.GL_Code__c : '';
        currentEmployeeDetail.territory = currentContact.Territory__c != null ? currentContact.Territory__c : '';
        currentEmployeeDetail.code = currentContact.Code__c != null ? currentContact.Code__c : '';
        /* Added by below below line no. 76*/
        currentEmployeeDetail.packet = currentContact.Packet__c != null ? currentContact.Packet__c : '';
        currentEmployeeDetail.district = currentContact.District__c != null ? currentContact.District__c : '';
        currentEmployeeDetail.totalreimbursement = String.valueOf(avgReim);
        currentEmployeeDetail.am = currentContact.AM__c != null ? currentContact.AM__c : '';
        currentEmployeeDetail.an = currentContact.AN__c != null ? currentContact.AN__c : '';
        if(String.isNotBlank(String.valueOf(currentContact.Monthly_Mileage_Limit__c))) {
            currentEmployeeDetail.monthlymileageLimit = String.valueOf(currentContact.Monthly_Mileage_Limit__c);
            currentEmployeeDetail.approvalThreshold = String.valueOf(currentContact.Monthly_Mileage_Limit__c);            
        } else {
            currentEmployeeDetail.monthlymileageLimit = '';
            currentEmployeeDetail.approvalThreshold = '';
        }
        currentEmployeeDetail.fixedamount = String.isNotBlank(String.valueOf(currentContact.Fixed_Amount__c)) ? String.valueOf(currentContact.Fixed_Amount__c) : ''; 
        currentEmployeeDetail.zipCode = currentContact.MailingPostalCode  !=  null ? String.valueOf(currentContact.MailingPostalCode) : '';
        currentEmployeeDetail.city = currentContact.MailingCity  !=  null ? currentContact.MailingCity : '';
        currentEmployeeDetail.state = currentContact.MailingState  !=  null ? currentContact.MailingState : '';
        if(currentContact.Employee_ID__c  !=  null && currentContact.Employee_ID__c  !=  '') {
            currentEmployeeDetail.employeeId=currentContact.Employee_ID__c;    
        } else {
            currentEmployeeDetail.employeeId= '';
        }
        if(currentContact.Role__c  !=  null && currentContact.Role__c  !=  '') {
            currentEmployeeDetail.role = currentContact.Role__c;    
        }
        if(currentContact.Company__c  !=  null && currentContact.Company__c  !=  '') {
            currentEmployeeDetail.company = currentContact.Company__c; 
        }
        if(currentContact.Department__c  !=  null && currentContact.Department__c  !=  '') {
            currentEmployeeDetail.department = currentContact.Department__c;    
        }
        if(currentContact.Department !=  null && currentContact.Department !=  '') {
            currentEmployeeDetail.deptPL = currentContact.Department;    
        }
        if(String.isNotBlank(String.valueOf(currentContact.Division__c))) {
            currentEmployeeDetail.divison  = String.valueof(currentContact.Division__c);    
        }
        if(currentContact.Dept__c  !=  null && currentContact.Dept__c  !=  '') {
            currentEmployeeDetail.deptDesign = currentContact.Dept__c;    
        }
        if(currentContact.Job_Title__c  !=  null && currentContact.Job_Title__c  !=  '') {
            currentEmployeeDetail.jobtitle = currentContact.Job_Title__c;    
        }
        if(currentContact.Driver_Type__c  !=  null && currentContact.Driver_Type__c  !=  '') {
            currentEmployeeDetail.driverType = currentContact.Driver_Type__c;    
        }
        if(currentContact.Employee_Netchex_Id__c  !=  null && currentContact.Employee_Netchex_Id__c  !=  '') {
            currentEmployeeDetail.netchexEmployeeID = currentContact.Employee_Netchex_Id__c;    
        }
        if(currentContact.Freeze__c != null) {
            currentEmployeeDetail.freeze = currentContact.Freeze__c.format();
        } else {
            currentEmployeeDetail.freeze = '';
        }
        currentEmployeeDetail.managerId = currentContact.Manager__c;     
        if(currentContact.email != null) {
            currentEmployeeDetail.email =currentContact.email;
        } else {
            currentEmployeeDetail.email =currentContact.External_Email__c;
        }
        if(currentContact.Manager__r.Name  !=  null) {
            currentEmployeeDetail.managerName=currentContact.Manager__r.Name;    
        } else {
            currentEmployeeDetail.managerName= '';
        }
        currentEmployeeDetail.activationDate = currentContact.Activation_Date__c  !=  null ? currentContact.Activation_Date__c.format() : '';
        currentEmployeeDetail.vehicalType =currentContact.Vehicle_Type__c;
        currentEmployeeDetail.deactivaedDate = currentContact.Deactivated_Date__c  !=  null ?  String.valueOf(currentContact.Deactivated_Date__c.month())+'/'+String.valueOf(currentContact.Deactivated_Date__c.day())+'/'+String.valueOf(currentContact.Deactivated_Date__c.year()) : null;
        currentEmployeeDetail.lastPayDate = currentContact.Last_Pay_Date__c  !=  null ? String.valueOf(currentContact.Last_Pay_Date__c.month())+'/'+String.valueOf(currentContact.Last_Pay_Date__c.day())+'/'+String.valueOf(currentContact.Last_Pay_Date__c.year()) : null;
        currentEmployeeDetail.addedDate = currentContact.Added_Date__c  !=  null ? String.valueOf(currentContact.Added_Date__c.month())+'/'+String.valueOf(currentContact.Added_Date__c.day())+'/'+String.valueOf(currentContact.Added_Date__c.year()) : null;
        if(currentContact.Driving_States__c != null) {
            List<String> drivingStatesSplitted = new list<String>();
            if(currentContact.Driving_States__c.contains(';')) {                   
                for(String objdrivingstate:currentContact.Driving_States__c.split(';')) {
                    drivingStatesSplitted.add(objdrivingstate.trim());
                }
            } else {                   
                drivingStatesSplitted.add(currentContact.Driving_States__c);
            }
            currentEmployeeDetail.drivingStates = drivingStatesSplitted; 
        } else {
            currentEmployeeDetail.drivingStates =null;
        }
        currentEmployeeDetail.loaStartDate = currentContact.LOA_Start_Date__c !=  null ? String.valueOf(currentContact.LOA_Start_Date__c.month())+'/'+String.valueOf(currentContact.LOA_Start_Date__c.day())+'/'+String.valueOf(currentContact.LOA_Start_Date__c.year()) : null;
        currentEmployeeDetail.loaEndDate = currentContact.LOA_End_Date__c !=  null ? String.valueOf(currentContact.LOA_End_Date__c.month())+'/'+String.valueOf(currentContact.LOA_End_Date__c.day())+'/'+String.valueOf(currentContact.LOA_End_Date__c.year()) : null;
        currentEmployeeDetail.loaFixedAmount = currentContact.LOA_Fixed_Amount__c !=  null ? String.valueOf(currentContact.LOA_Fixed_Amount__c) : null;
        currentEmployeeDetail.payRollPeriod = currentContact.Payroll_Period__c != null ?  String.valueOf(currentContact.Payroll_Period__c) : null;
        currentEmployeeDetail.isleaveofabsence = false;
        currentEmployeeDetail.resetReimbursementLink = false;
        /*EMC-260 START */
        currentEmployeeDetail.monthlyReimbursement = currentContact.Monthly_Reimbursement__c;       
        currentEmployeeDetail.biWeekReimbursement = currentContact.Reimbursement_Frequency__c != null && currentContact.Reimbursement_Frequency__c == 'Monthly Reimbursement' ? false : true;
        currentEmployeeDetail.timeAttandance = currentContact.Time_Attandance__c;
        currentEmployeeDetail.costCode = currentContact.Cost_Code__c != null ? currentContact.Cost_Code__c : '';
         if(currentContact.App_Settings__c != null){
             string app = currentContact.App_Settings__c;
             string[] splitApp = app.split('Auto start:');            
             string newapp = splitApp[1];
             string[] businessSplit =  newapp.split('Business hours:');
             currentEmployeeDetail.appSetting = 'Auto start:' + businessSplit[0];
             currentEmployeeDetail.Businesshours = 'Business hours:' + businessSplit[1];
         } else {
             currentEmployeeDetail.appSetting = '';
         }        
         if(currentContact.Last_Synced__c != null){
            string lsynced = string.valueOf(currentContact.Last_Synced__c);
            string[] splitdate = lsynced.split(' ');
            string lsynceddate = splitdate[0];
            currentEmployeeDetail.lastSynced =  lsynceddate ;
        } else {
             currentEmployeeDetail.lastSynced = '';
        }
        currentEmployeeDetail.bpCode = currentContact.BP_Code__c != null ? currentContact.BP_Code__c : '';
        if(currentContact.Hello_Sign_Request_Id__c != null && currentContact.Hello_Sign_Status__c == 'signed' && currentContact.Packet__c=='Driver Signed' ){
            currentEmployeeDetail.resendDriverPacket = true;
        }
        if(currentContact.Reimbursement_Frequency__c!=null){
            currentEmployeeDetail.ReimbursementFrequency = currentContact.Reimbursement_Frequency__c;
        }
        if(currentContact.Cell_Phone__c!=null){
            currentEmployeeDetail.CellPhoneProvider = currentContact.Cell_Phone__c;
        }
        if(currentContact.Account.Reimbursement_Frequency__c!=null){
            currentEmployeeDetail.accountReimbursementFrequency = currentContact.Account.Reimbursement_Frequency__c;
        }
        if(currentContact.Account.Cell_Phone__c!=null){
            currentEmployeeDetail.accountCellPhoneProvider = currentContact.Account.Cell_Phone__c;
        }
        /* END */
        return currentEmployeeDetail;       
    }
    
    /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getContact is used to built Contact FROM EmployeeDetails Wrapper object.
    @param currentEmployeeDetail currentEmployeeDetail is the Single EmployeeDetails FROM which you want to Built Contact. 
    @return Contact built by the method.
    */
    public static Contact getContact(EmployeeDetails currentEmployeeDetail)
    {
        Contact currentContact = new Contact();
        currentContact.id=currentEmployeeDetail.userid;
        currentContact.Mileage_for_deduct__c = currentEmployeeDetail.mileageForDeduction;
        currentContact.firstname=currentEmployeeDetail.firstName;
        currentContact.lastname = currentEmployeeDetail.lastName;
        currentContact.email =currentEmployeeDetail.email;
        currentContact.External_Email__c = currentEmployeeDetail.email;
        currentContact.MailingPostalCode =String.valueOf(currentEmployeeDetail.zipCode);
        currentContact.MailingCity = currentEmployeeDetail.city;
        currentContact.MailingState = currentEmployeeDetail.state;
        currentContact.Employee_ID__c = currentEmployeeDetail.employeeId;
        
        if(currentEmployeeDetail.appVersion!=null) {    
            currentContact.App__c = currentEmployeeDetail.appVersion;
        }
        if(currentEmployeeDetail.cellphone!=null){
            currentContact.Phone = currentEmployeeDetail.cellphone;
        }      
        
        if(currentEmployeeDetail.compliancestatus!=null){
            currentContact.compliancestatus__c = currentEmployeeDetail.compliancestatus;
        }
        if(String.isNotBlank(String.valueOf(currentEmployeeDetail.monthlymileageLimit))) {
            currentContact.Monthly_Mileage_Limit__c =Decimal.valueOf(currentEmployeeDetail.monthlymileageLimit);
        }
        if(String.isNotBlank(String.valueOf(currentEmployeeDetail.fixedamount))) {
            currentContact.Fixed_Amount__c =Decimal.valueOf(currentEmployeeDetail.fixedamount);
        }
        currentContact.IsDeactivated__c = currentEmployeeDetail.deactivateUser;
        currentContact.Role__c = currentEmployeeDetail.role;
        currentContact.Company__c = currentEmployeeDetail.company;
        currentContact.Department__c = currentEmployeeDetail.department;
        currentContact.Department = currentEmployeeDetail.deptPL ;
        if(String.isNotBlank(String.valueOf(currentEmployeeDetail.divison))) {
            currentContact.Division__c = Decimal.valueOf(currentEmployeeDetail.divison) ;
        }
        currentContact.Dept__c = currentEmployeeDetail.deptDesign;
        currentContact.Job_Title__c = currentEmployeeDetail.jobtitle;
        currentContact.Manager__c = currentEmployeeDetail.managerId;
        currentContact.Vehicle_Type__c = currentEmployeeDetail.vehicalType;
        if(String.isNotBlank(currentEmployeeDetail.finalPayrollAmount)){
            currentContact.Final_Payroll_Amount__c = Decimal.valueOf(currentEmployeeDetail.finalPayrollAmount);
        } else {
            currentContact.Final_Payroll_Amount__c = null;
        }
        if(String.isNotBlank(currentEmployeeDetail.firstPayrollPer)){
            currentContact.First_Payroll__c = currentEmployeeDetail.firstPayrollPer;
        } else {
            currentContact.First_Payroll__c = null;
        }
        if(currentEmployeeDetail.lastPayDate  !=  null) {
            List<String> lastPaydateSplitted = new List<String>();
            if((String.valueOf(currentEmployeeDetail.lastPayDate).contains('-'))) {
                lastPaydateSplitted = String.valueOf(currentEmployeeDetail.lastPayDate).split('-');                
            } else if(String.valueOf(currentEmployeeDetail.lastPayDate).contains('/')) {
                lastPaydateSplitted = String.valueOf(currentEmployeeDetail.lastPayDate).split('/');                
            }
            currentContact.Last_Pay_Date__c = Date.newInstance(Integer.valueOf(lastPaydateSplitted[2]), Integer.valueOf(lastPaydateSplitted[0]), Integer.valueOf(lastPaydateSplitted[1]));       
        } else {
            currentContact.Last_Pay_Date__c =null;
        }
        
        if(currentEmployeeDetail.monthlymileage !=null && currentEmployeeDetail.monthlymileage != '') {           
            currentContact.Monthly__c = Decimal.valueOf(currentEmployeeDetail.monthlymileage);
        }
        
        if(currentEmployeeDetail.sage100ID != null && currentEmployeeDetail.sage100ID != '') {
            currentContact.Sage_100_ID__c = currentEmployeeDetail.sage100ID;
        }
        
        if(currentEmployeeDetail.glcode != null && currentEmployeeDetail.glcode != '') {
            currentContact.GL_Code__c = currentEmployeeDetail.glcode;
        }
        if(currentEmployeeDetail.territory != null && currentEmployeeDetail.territory != '') {
            currentContact.Territory__c = currentEmployeeDetail.territory;
        }
        if(currentEmployeeDetail.code != null && currentEmployeeDetail.code != '') {
            currentContact.Code__c = currentEmployeeDetail.code;
        }
        if(currentEmployeeDetail.district != null && currentEmployeeDetail.district != '') {
            currentContact.District__c = currentEmployeeDetail.district;
        }
        if(currentEmployeeDetail.deactivaedDate != null &&  currentEmployeeDetail.deactivaedDate != '') {       
            List<String> deactivationDateSplitted = new List<String>();
            if(String.valueOf(currentEmployeeDetail.deactivaedDate).contains('-')) {
                deactivationDateSplitted = String.valueOf(currentEmployeeDetail.deactivaedDate).split('-');
            } else if((String.valueOf(currentEmployeeDetail.deactivaedDate).contains('/'))) {
                deactivationDateSplitted = String.valueOf(currentEmployeeDetail.deactivaedDate).split('/');                
            }            
            currentContact.Deactivated_Date__c = Datetime.newInstance(Integer.valueOf(deactivationDateSplitted[2]), Integer.valueOf(deactivationDateSplitted[0]), Integer.valueOf(deactivationDateSplitted[1]),0,0,0);           
        } else {
            currentContact.Deactivated_Date__c =null;
        }
        
        if(currentEmployeeDetail.freeze  !=  null) {
            List<String> freezeDateSplitted = new List<String>();
            if(String.valueOf(currentEmployeeDetail.freeze).contains('-')) {
                freezeDateSplitted = String.valueOf(currentEmployeeDetail.freeze).split('-');
            } else if((String.valueOf(currentEmployeeDetail.freeze).contains('/'))) {
                freezeDateSplitted = String.valueOf(currentEmployeeDetail.freeze).split('/');                
            }
            if(freezeDateSplitted.size() > 0){
                currentContact.Freeze__c =  Date.newInstance(Integer.valueOf(freezeDateSplitted[2]), Integer.valueOf(freezeDateSplitted[0]), Integer.valueOf(freezeDateSplitted[1]));
            }
        } else {
            currentContact.Freeze__c =null;
        }
        
        if(currentEmployeeDetail.drivingStates != null && currentEmployeeDetail.drivingStates.size() > 0) {
            String state='';
            for(String currentState:currentEmployeeDetail.drivingStates) {
                if(state != '') {
                    state=state+ ';'+currentState;
                } else {
                    state = currentState;
                }
            }
            currentContact.Driving_States__c = state; 
        } else {
            currentContact.Driving_States__c = null;
        }
        if(String.isNotBlank(String.valueOf(currentEmployeeDetail.loaFixedAmount ))) {
            currentContact.LOA_Fixed_Amount__c = Decimal.valueOf(currentEmployeeDetail.loaFixedAmount );
        }
        if(currentEmployeeDetail.loaStartDate !=  null) {
            List<String> lastPaydateSplitted = new List<String>();
            if((String.valueOf(currentEmployeeDetail.loaStartDate).contains('-'))) {
                lastPaydateSplitted = String.valueOf(currentEmployeeDetail.loaStartDate).split('-');                
            }
            else if(String.valueOf(currentEmployeeDetail.loaStartDate).contains('/')) {
                lastPaydateSplitted = String.valueOf(currentEmployeeDetail.loaStartDate).split('/');                
            }
            currentContact.LOA_Start_Date__c = Date.newInstance(Integer.valueOf(lastPaydateSplitted[2]), Integer.valueOf(lastPaydateSplitted[0]), Integer.valueOf(lastPaydateSplitted[1]));       
            
        } else {
            currentContact.LOA_Start_Date__c = null;
        }
        if(currentEmployeeDetail.loaEndDate !=  null) {
            List<String> lastPaydateSplitted = new List<String>();
            if((String.valueOf(currentEmployeeDetail.loaEndDate).contains('-'))) {
                lastPaydateSplitted = String.valueOf(currentEmployeeDetail.loaEndDate).split('-');                
            } else if(String.valueOf(currentEmployeeDetail.loaEndDate).contains('/')) {
                lastPaydateSplitted = String.valueOf(currentEmployeeDetail.loaEndDate).split('/');                
            }
            currentContact.LOA_End_Date__c = Date.newInstance(Integer.valueOf(lastPaydateSplitted[2]), Integer.valueOf(lastPaydateSplitted[0]), Integer.valueOf(lastPaydateSplitted[1]));       
            
        } else {
            currentContact.LOA_End_Date__c = null;
        }
        if(String.isNotBlank(String.valueOf(currentEmployeeDetail.payRollPeriod))) {
            currentContact.Payroll_Period__c = String.valueOf(currentEmployeeDetail.payRollPeriod);
        }
        currentContact.Cost_Code__c = currentEmployeeDetail.costCode != null ? currentEmployeeDetail.costCode : '';
        currentContact.BP_Code__c = currentEmployeeDetail.bpCode != null ? currentEmployeeDetail.bpCode : '';
        if(currentEmployeeDetail.ReimbursementFrequency!=null){
            currentContact.Reimbursement_Frequency__c=currentEmployeeDetail.ReimbursementFrequency;
        }
        if(currentEmployeeDetail.CellPhoneProvider!=null){
            currentContact.Cell_Phone__c=currentEmployeeDetail.CellPhoneProvider;
        }
        return currentContact;      
    }
    
    public static EmployeeMileages getMileagesOfReimbursement(Employee_Mileage__c employeeMileage) { 
        System.debug('@@@@ employeeMileage ==> '+employeeMileage);     
        EmployeeMileages currentEmployeeMileage = new EmployeeMileages();
        currentEmployeeMileage.id=employeeMileage.id;
        currentEmployeeMileage.isSelected = false;
        currentEmployeeMileage.isChecked = false;
        currentEmployeeMileage.isUnapprove = false;
        if(employeeMileage.Trip_Status__c != null) {
            currentEmployeeMileage.status = employeeMileage.Trip_Status__c;    
        }
        if(employeeMileage.Approval_Name__c != null) {
            currentEmployeeMileage.approvalName = employeeMileage.Approval_Name__c;    
        }
        if(employeeMileage.Activity__c != null) {
            currentEmployeeMileage.tripActivity = employeeMileage.Activity__c;    
        }
        if(employeeMileage.Maintenance_and_Tires__c != null) {
            currentEmployeeMileage.maintTyre = string.valueof(employeeMileage.Maintenance_and_Tires__c);
        }
        
        if(employeeMileage.Stay_Time__c != null){
            currentEmployeeMileage.staytime = string.valueof(employeeMileage.Stay_Time__c);
        } else {
            currentEmployeeMileage.staytime = '0';
        }
        
        if(employeeMileage.Driving_Time__c != null) {
            currentEmployeeMileage.drivingtime = string.valueof(employeeMileage.Driving_Time__c);
        } else {
            currentEmployeeMileage.drivingtime = '0';
        }
        
        if(employeeMileage.Total_Time__c   != null){
            currentEmployeeMileage.totaltime = string.valueof(employeeMileage.Total_Time__c);
        } else {
            currentEmployeeMileage.totaltime = '0';
        }
        if(employeeMileage.Fuel_price__c != null){
            currentEmployeeMileage.fuelRate = string.valueof(employeeMileage.Fuel_price__c);
        }
        
        if(employeeMileage.Variable_Rate__c != null){            
            currentEmployeeMileage.variablerate = employeeMileage.Variable_Rate__c != null ? String.valueOf(employeeMileage.Variable_Rate__c) : '0';     
        }
        if(employeeMileage.Fuel_Variable_Rate__c!= null){
            currentEmployeeMileage.fuelVariableRate= string.valueof(employeeMileage.Fuel_Variable_Rate__c);
        }
        
        currentEmployeeMileage.dayofweek='';
        currentEmployeeMileage.starttime='';
        currentEmployeeMileage.endtime='';
        currentEmployeeMileage.originname='';
        currentEmployeeMileage.destinationname='';
        currentEmployeeMileage.tracingstyle='';
        currentEmployeeMileage.emailaddress='';
        if(employeeMileage.Origin_Name__c != null) {
            currentEmployeeMileage.originname= employeeMileage.Origin_Name__c;
        }
        if(employeeMileage.Notes__c != null) { 
            currentEmployeeMileage.notes = employeeMileage.Notes__c;
        }
        
        if(employeeMileage.Tag__c != null){ 
            currentEmployeeMileage.tag = employeeMileage.Tag__c;
        }
        
        if(employeeMileage.Tracing_Style__c != null) {
            currentEmployeeMileage.tracingstyle=employeeMileage.Tracing_Style__c;
        }
        
        if(employeeMileage.ConvertedStartTime__c  != null ) {
            DateTime startTime = employeeMileage.ConvertedStartTime__c;
            currentEmployeeMileage.starttime = startTime.format('h:mm a','America/Panama');
        }
        
        if(employeeMileage.ConvertedEndTime__c  != null) {
            DateTime endTime = employeeMileage.ConvertedEndTime__c ;
            currentEmployeeMileage.endTime = endTime.format('h:mm a','America/Panama');
        }       
        
        if(employeeMileage.Day_Of_Week__c != null) {
            currentEmployeeMileage.dayofweek=employeeMileage.Day_Of_Week__c;
        }
        if(employeeMileage.Destination_Name__c != null) {
            currentEmployeeMileage.destinationname=employeeMileage.Destination_Name__c;
        }
       
        if(employeeMileage.Original_Origin_Name__c != null) {
            currentEmployeeMileage.originalOriginName = employeeMileage.Original_Origin_Name__c;
        }
        if(employeeMileage.Original_Destination_Name__c != null) {
            currentEmployeeMileage.originalDestinationName = employeeMileage.Original_Destination_Name__c;
        }
        currentEmployeeMileage.emailaddress = employeeMileage.EmployeeReimbursement__r.Contact_Id__r.External_Email__c;
        
        if(employeeMileage.Trip_Status__c != null && employeeMileage.Trip_Status__c == 'Rejected') {
            currentEmployeeMileage.isChecked = true;
        }        
        currentEmployeeMileage.origin = employeeMileage.Trip_Origin__c;
        currentEmployeeMileage.destination = employeeMileage.Trip_Destination__c;
        if(employeeMileage.Trip_Date__c != null) {
            if(String.valueOf(employeeMileage.Trip_Date__c).contains('-')) {
                List<String> tripDateSplitted = new List<String>();
                tripDateSplitted = String.valueOf(employeeMileage.Trip_Date__c).split('-');
                currentEmployeeMileage.tripdate  = tripDateSplitted[1]+'/'+tripDateSplitted[2]+'/'+tripDateSplitted[0].substring(2,4);
            }
        }
        if(String.valueOf(employeeMileage.Mileage__c) != null){
            currentEmployeeMileage.mileage  = String.valueOf(employeeMileage.Mileage__c);
        } else {
            currentEmployeeMileage.mileage  = '0.00';
        }
        
        if(employeeMileage.Approved_Date__c != null) {
            if(String.valueOf(employeeMileage.Approved_Date__c).contains('-')) {
                List<String> approveDateSplitted = new List<String>();
                approveDateSplitted = String.valueOf(employeeMileage.Approved_Date__c).split('-');
                currentEmployeeMileage.approveddate  = approveDateSplitted[1]+'/'+approveDateSplitted[2]+'/'+approveDateSplitted[0].substring(2,4);
            }
        }
        if(employeeMileage.EmployeeReimbursement__r.Mileage_Lock_Date__c != null) {
            if(String.valueOf(employeeMileage.EmployeeReimbursement__r.Mileage_Lock_Date__c).contains('-')) {
                List<String> lockDateSplitted = new List<String>();
                lockDateSplitted = String.valueOf(employeeMileage.EmployeeReimbursement__r.Mileage_Lock_Date__c).split('-');
                currentEmployeeMileage.lockdate  = lockDateSplitted[1]+'/'+lockDateSplitted[2]+'/'+lockDateSplitted[0].substring(2,4);
                currentEmployeeMileage.isLockDate = true;
            }
        }
        Date createddate = Date.valueOf(employeeMileage.CreatedDate);
        if(String.valueOf(createddate).contains('-')) {
            List<String> createdDateSplitted = new List<String>();
            createdDateSplitted = String.valueOf(createddate).split('-');
            currentEmployeeMileage.submitteddate =  createdDateSplitted[1]+'/'+createdDateSplitted[2]+'/'+createdDateSplitted[0].substring(2,4);
        }
        currentEmployeeMileage.totalrejected = String.valueOf(employeeMileage.EmployeeReimbursement__r.Total_Rejected__c);
        currentEmployeeMileage.totalMileages = String.valueOf(employeeMileage.EmployeeReimbursement__r.Total_Mileage__c);
        currentEmployeeMileage.totalpending = String.valueOf(employeeMileage.EmployeeReimbursement__r.Total_Pending__c);
        currentEmployeeMileage.variableamount  = String.valueOf(employeeMileage.Variable__c);
        currentEmployeeMileage.month  = employeeMileage.EmployeeReimbursement__r.month__c;
        currentEmployeeMileage.reimbursementid  = employeeMileage.EmployeeReimbursement__c;
        currentEmployeeMileage.driverid = employeeMileage.EmployeeReimbursement__r.Contact_Id__c;
        currentEmployeeMileage.highRiskMileage = employeeMileage.High_Risk_Mileage__c;
        currentEmployeeMileage.approvalName = employeeMileage.Approval_Name__c;
        return currentEmployeeMileage;
    }
    public static Contact getNewContact(EmployeeDetails currentEmployeeDetail) {
        Contact currentContact = new Contact();
        currentContact.Mileage_for_deduct__c = currentEmployeeDetail.mileageForDeduction;
        currentContact.firstname=currentEmployeeDetail.firstName;
        currentContact.lastname = currentEmployeeDetail.lastName;
        currentContact.email =currentEmployeeDetail.email;
        currentContact.External_Email__c = currentEmployeeDetail.email;
        currentContact.MailingPostalCode =String.valueOf(currentEmployeeDetail.zipCode);
        currentContact.MailingCity = currentEmployeeDetail.city;
        currentContact.MailingState = currentEmployeeDetail.state;
        currentContact.Employee_ID__c = currentEmployeeDetail.employeeId;
        currentContact.Pay_Number__c = '3';
        currentContact.Batch_ID_Fixed__c = 'M351';
        currentContact.Adjust_Ded_Code_Fixed__c = 'MR';
        currentContact.Batch_Variable_ID__c = 'M352';
        currentContact.Adjust_Ded_Code_Variable__c = 'VR';
        currentContact.Special_Action__c = 'W';
        currentContact.IsCreatedFromCommunity__c = true;
        
        if(String.IsNotBlank(currentEmployeeDetail.branchName)) {
            currentContact.Branch_Name__c =currentEmployeeDetail.branchName;
        } else {
            currentContact.Branch_Name__c ='';
        }
        if(String.IsNotBlank(currentEmployeeDetail.branchNumber)) {
            currentContact.Branch_Number__c = String.valueOf(currentEmployeeDetail.branchNumber);
        } else {
            currentContact.Branch_Number__c ='';
        }
        if(currentEmployeeDetail.cellphone!=null) {
            currentContact.Phone = currentEmployeeDetail.cellphone;
            currentContact.MobilePhone = currentEmployeeDetail.cellphone;
        }
        if(currentEmployeeDetail.activationDate != null && currentEmployeeDetail.activationDate != '') {
            List<String> activationDateSplitted = new List<String>();
            if(String.valueOf(currentEmployeeDetail.activationDate).contains('-')) {
                activationDateSplitted = String.valueOf(currentEmployeeDetail.activationDate).split('-');
            } else if((String.valueOf(currentEmployeeDetail.activationDate).contains('/'))) {
                activationDateSplitted = String.valueOf(currentEmployeeDetail.activationDate).split('/');
            }
            currentContact.Activation_Date__c =  Date.newInstance(Integer.valueOf(activationDateSplitted[2]), Integer.valueOf(activationDateSplitted[0]), Integer.valueOf(activationDateSplitted[1]));
        }
        
        if(currentEmployeeDetail.freeze != null && currentEmployeeDetail.freeze != '') {
            List<String> freezeSplitted = new List<String>();
            if(String.valueOf(currentEmployeeDetail.freeze).contains('-')) {
                freezeSplitted = String.valueOf(currentEmployeeDetail.freeze).split('-');
            } else if((String.valueOf(currentEmployeeDetail.freeze).contains('/'))) {
                freezeSplitted = String.valueOf(currentEmployeeDetail.freeze).split('/');
            }
            currentContact.Freeze__c =  Date.newInstance(Integer.valueOf(freezeSplitted[2]), Integer.valueOf(freezeSplitted[0]), Integer.valueOf(freezeSplitted[1]));
        }
        
        if(currentEmployeeDetail.addedDate != null && currentEmployeeDetail.addedDate != '') {
            List<String> addedDateSplitted = new List<String>();
            if(String.valueOf(currentEmployeeDetail.addedDate).contains('-')) {
                addedDateSplitted = String.valueOf(currentEmployeeDetail.addedDate).split('-');
            } else if((String.valueOf(currentEmployeeDetail.addedDate).contains('/'))) {
                addedDateSplitted = String.valueOf(currentEmployeeDetail.addedDate).split('/');
            }
            currentContact.Added_Date__c =  Date.newInstance(Integer.valueOf(addedDateSplitted[2]), Integer.valueOf(addedDateSplitted[0]), Integer.valueOf(addedDateSplitted[1]));
            
        }
        if((String.isNotBlank(currentEmployeeDetail.approvalThreshold) && currentEmployeeDetail.approvalThreshold.isNumeric()) || (String.isNotBlank(currentEmployeeDetail.approvalThreshold) && currentEmployeeDetail.approvalThreshold.contains('.') && (currentEmployeeDetail.approvalThreshold.countMatches('.') == 1 ) )) {
            currentContact.Monthly_Mileage_Limit__c = Decimal.valueOf(currentEmployeeDetail.approvalThreshold);
        }
        currentContact.Role__c = currentEmployeeDetail.role;
        currentContact.Company__c = currentEmployeeDetail.company;
        currentContact.Job_Title__c = currentEmployeeDetail.jobtitle;
        currentContact.Department__c = currentEmployeeDetail.department;
        currentContact.Dept__c = currentEmployeeDetail.deptDesign;
        currentContact.Department = currentEmployeeDetail.deptPL ;
        currentContact.AM__c = currentEmployeeDetail.am;
        currentContact.AN__c = currentEmployeeDetail.an;
        if(String.isNotBlank(currentEmployeeDetail.divison)){
            currentContact.Division__c = Decimal.valueOf(currentEmployeeDetail.divison) ;
        }
        if(String.isNotBlank(currentEmployeeDetail.finalPayrollAmount)){
            currentContact.Final_Payroll_Amount__c = Decimal.valueOf(currentEmployeeDetail.finalPayrollAmount);
        }
        
        if(String.isNotBlank(currentEmployeeDetail.firstPayrollPer)){
            currentContact.First_Payroll__c = currentEmployeeDetail.firstPayrollPer;
        }
        currentContact.Driver_Type__c = currentEmployeeDetail.driverType;
        currentContact.Employee_Netchex_Id__c = currentEmployeeDetail.netchexEmployeeID;
        if(String.isNotBlank(currentEmployeeDetail.managerId)) {
            currentContact.Manager__c = currentEmployeeDetail.managerId;   
        }
        
        if(currentEmployeeDetail.vehicalType!=null) {            
            currentContact.Vehicle_Type__c = currentEmployeeDetail.vehicalType;
        }
        
        if(currentEmployeeDetail.accountId  !=  null && currentEmployeeDetail.accountId  !=  '') {
            currentContact.AccountID = currentEmployeeDetail.accountId;    
        }
        if((String.isNotBlank(currentEmployeeDetail.monthlymileage) && currentEmployeeDetail.monthlymileage.isNumeric()) || (String.isNotBlank(currentEmployeeDetail.monthlymileage) && currentEmployeeDetail.monthlymileage.contains('.') && (currentEmployeeDetail.monthlymileage.countMatches('.') == 1 ) )) {
            currentContact.Monthly__c = Decimal.valueOf(currentEmployeeDetail.monthlymileage);
        }
        
        if(currentEmployeeDetail.sage100ID != null && currentEmployeeDetail.sage100ID != '') {
            currentContact.Sage_100_ID__c = currentEmployeeDetail.sage100ID;
        }
        
        if(currentEmployeeDetail.glcode != null && currentEmployeeDetail.glcode != '') {
            currentContact.GL_Code__c = currentEmployeeDetail.glcode;
        }
        if(currentEmployeeDetail.territory != null && currentEmployeeDetail.territory != '') {
            currentContact.Territory__c = currentEmployeeDetail.territory;
        }
        if(currentEmployeeDetail.code != null && currentEmployeeDetail.code != '') {
            currentContact.Code__c = currentEmployeeDetail.code;
        }
        if(currentEmployeeDetail.district != null && currentEmployeeDetail.district != '') {
            currentContact.District__c = currentEmployeeDetail.district;
        }
        if(currentEmployeeDetail.drivingStates != null && currentEmployeeDetail.drivingStates.size()>0) {
            String state='';
            for(String currentState : currentEmployeeDetail.drivingStates) {
                if(state != '') {
                    state=state+ ';'+currentState;
                } else {
                    state = currentState;
                }
            }
            currentContact.Driving_States__c =state; 
        } else {
            currentContact.Driving_States__c = null;
        }
        currentContact.Cost_Code__c = currentEmployeeDetail.costCode != null ? currentEmployeeDetail.costCode : '';
        currentContact.BP_Code__c = currentEmployeeDetail.bpCode != null ? currentEmployeeDetail.bpCode : '';
        if(currentEmployeeDetail.ReimbursementFrequency!=null){
            currentContact.Reimbursement_Frequency__c=currentEmployeeDetail.ReimbursementFrequency;
        }
        if(currentEmployeeDetail.CellPhoneProvider!=null){
            currentContact.Cell_Phone__c=currentEmployeeDetail.CellPhoneProvider;
        }
        return currentContact;      
    }
    /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getEmployeeReimbursements is used to built EmployeeReimbursements FROM Employee_Reimbursement__c object.
    @param currentEmployeeReimbursement currentEmployeeReimbursement is the Single Employee_Reimbursement__c FROM which you want to Built EmployeeReimbursements. 
    @return EmployeeReimbursements built by the method.
    */
    public static EmployeeReimbursements getEmployeeReimbursements(Employee_Reimbursement__c currentEmployeeReimbursement, Double sumTotalReim, Integer count)
    {
        EmployeeReimbursements employeeReimbursement = new EmployeeReimbursements();
        employeeReimbursement.employeeReimbursementId = currentEmployeeReimbursement.id;
        if(currentEmployeeReimbursement.Approved_Date__c != null) {
            if(String.valueOf(currentEmployeeReimbursement.Approved_Date__c).contains('-')) {
                List<String> approvedDateSplitted = new List<String>();
                approvedDateSplitted = String.valueOf(currentEmployeeReimbursement.Approved_Date__c).split('-');
                employeeReimbursement.approveddate  = approvedDateSplitted[1]+'/'+approvedDateSplitted[2]+'/'+approvedDateSplitted[0].substring(2,4);
            }            
        }
        if(currentEmployeeReimbursement.Status__c != null) {
            employeeReimbursement.status = currentEmployeeReimbursement.Status__c; 
        }
        employeeReimbursement.isSelected = false;       
        employeeReimbursement.contactEmail = currentEmployeeReimbursement.Contact_Email__c;
        employeeReimbursement.variableRate  = ' $'+String.valueOf(currentEmployeeReimbursement.Total_Variable_Rate__c);
        employeeReimbursement.month  = getMonthName(currentEmployeeReimbursement.Month__c);
        employeeReimbursement.intmonth  = getMonthInteger(currentEmployeeReimbursement.Month__c);
        employeeReimbursement.fuel  = String.valueOf(currentEmployeeReimbursement.Fuel_Price__c) != null ? String.valueOf((currentEmployeeReimbursement.Fuel_Price__c).setScale(2)) : null ;       
        employeeReimbursement.fixedAmount = String.valueOf(currentEmployeeReimbursement.Fixed_Amount__c) != null ? String.valueOf((currentEmployeeReimbursement.Fixed_Amount__c).setScale(2)) : null ;       
        
            /* EMC-260  START
        Description : Added a new field : Total_Approved__c,Total_Mileage__c, Total_Pending__c 
        This 3 field values is populated on driver dashboard page
        Modified By : Sanket Goswami */
        employeeReimbursement.mileage  = (currentEmployeeReimbursement.Total_Mileage__c != null ? String.valueOf((currentEmployeeReimbursement.Total_Mileage__c).setScale(2)) : null);
        employeeReimbursement.pendingMileage  = String.valueOf(currentEmployeeReimbursement.Total_Pending__c);
        employeeReimbursement.approveMileage  = String.valueOf(currentEmployeeReimbursement.Total_Approved__c);
        /* EMC-260  END */
        
        employeeReimbursement.maintainsAndTyres  = String.valueOf(currentEmployeeReimbursement.Maintenance_and_Tires__c);
        employeeReimbursement.mpg  =String.valueOf(currentEmployeeReimbursement.MPG__c );
        String fixedandvariable ='';
        if(currentEmployeeReimbursement.Fixed_Amount__c != null && (currentEmployeeReimbursement.Contact_Id__r.Driver_Type__c != 'Driver - Part Time' && currentEmployeeReimbursement.Contact_Id__r.Driver_Type__c != 'Driver - Full Time' && currentEmployeeReimbursement.Contact_Id__r.Driver_Type__c != 'Driver - Salary')) {
            fixedandvariable = '$' + String.valueOf(currentEmployeeReimbursement.Fixed_Amount__c)+' + ';
        } else if(currentEmployeeReimbursement.Monthly_Fixed_Amount__c != null && currentEmployeeReimbursement.Contact_Id__r.Driver_Type__c == 'Driver - Part Time') {
            fixedandvariable = '$' + String.valueOf(currentEmployeeReimbursement.Monthly_Fixed_Amount__c.setScale(2))+' + ';
        } else if(currentEmployeeReimbursement.Half_Fixed_Amount__c != null && (currentEmployeeReimbursement.Contact_Id__r.Driver_Type__c != 'Driver - Full Time' || currentEmployeeReimbursement.Contact_Id__r.Driver_Type__c != 'Driver - Salary')){
            fixedandvariable = '$' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c.setScale(2))+' + ';
        } else {
            fixedandvariable = '$0 + ';
        }
        
        if(currentEmployeeReimbursement.Monthly_Variable_Amount__c!= null) {
            employeeReimbursement.varibleAmount = ' $' + String.valueOf(currentEmployeeReimbursement.Monthly_Variable_Amount__c);
            fixedandvariable = fixedandvariable + ' $' + String.valueOf(currentEmployeeReimbursement.Monthly_Variable_Amount__c);
        } else {
            employeeReimbursement.varibleAmount =  '$0';
            fixedandvariable  = fixedandvariable + '$0';
        }
        
        if(currentEmployeeReimbursement.Number_of_Pay_Period__c != null && currentEmployeeReimbursement.Number_of_Pay_Period__c == 1 && currentEmployeeReimbursement.Half_Fixed_Amount__c != null){
            employeeReimbursement.fixed1 = ' $' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c);
            employeeReimbursement.fixed2 = 'null';
            employeeReimbursement.fixed3 = 'null';
            employeeReimbursement.totalFixedAmount =  ' $' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c);
        } else if(currentEmployeeReimbursement.Number_of_Pay_Period__c != null && currentEmployeeReimbursement.Number_of_Pay_Period__c == 2 && currentEmployeeReimbursement.Half_Fixed_Amount__c != null){
            employeeReimbursement.fixed1 = ' $' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c);
            employeeReimbursement.fixed2 = ' $' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c);
            employeeReimbursement.fixed3 = 'null';
            employeeReimbursement.totalFixedAmount =  ' $' + String.valueOf(2 * currentEmployeeReimbursement.Half_Fixed_Amount__c);
        } else if(currentEmployeeReimbursement.Number_of_Pay_Period__c != null && currentEmployeeReimbursement.Number_of_Pay_Period__c == 3 && currentEmployeeReimbursement.Half_Fixed_Amount__c != null){
            employeeReimbursement.fixed1 = ' $' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c);
            employeeReimbursement.fixed2 = ' $' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c);
            employeeReimbursement.fixed3 = ' $' + String.valueOf(currentEmployeeReimbursement.Half_Fixed_Amount__c);
            employeeReimbursement.totalFixedAmount =  ' $' + String.valueOf(3 * currentEmployeeReimbursement.Half_Fixed_Amount__c);
        } else {
            employeeReimbursement.fixed1 = 'null';
            employeeReimbursement.fixed2 = 'null';
            employeeReimbursement.fixed3 = 'null';
            employeeReimbursement.totalFixedAmount = 'null';
        }
        employeeReimbursement.varibleAndFixedReimbursements  = fixedandvariable;
        if(currentEmployeeReimbursement.Contact_Id__r.Reimbursement_Frequency__c == 'Bi-Weekly Reimbursement' && currentEmployeeReimbursement.Contact_Id__r.Reimbursement_Type__c == 'FAVR' ){
            employeeReimbursement.totalReimbursements  ='$'+String.valueOf(currentEmployeeReimbursement.Total_Monthly_Reimbursement_BiWeek__c);
        } else {
            employeeReimbursement.totalReimbursements  ='$'+String.valueOf(currentEmployeeReimbursement.Total_Monthly_Reimbursement__c);
        }
        employeeReimbursement.contactdrivertype = currentEmployeeReimbursement.Contact_Id__r.Driver_Type__c;
        if(String.valueOf(currentEmployeeReimbursement.Reimbursement_Month__c) != null && Integer.valueof(currentEmployeeReimbursement.Reimbursement_Month__c) > 0 ){
            Decimal sumdivide = sumTotalReim / count;
            employeeReimbursement.avgToDate = String.valueOf((sumdivide ).setScale(2));        
        }
        if(currentEmployeeReimbursement.Reimbursement_Lock_Time__c != null){
            employeeReimbursement.lockDate = date.valueOf(currentEmployeeReimbursement.Reimbursement_Lock_Time__c);
        }
        if(currentEmployeeReimbursement.Lock_Date_User__c!= null){
            employeeReimbursement.lockDateUserName = currentEmployeeReimbursement.Lock_Date_User__c;
        }
        employeeReimbursement.syncMileageBtn = true;
        employeeReimbursement.concurBtn = true;
        return employeeReimbursement;
    }
    
    public static EmployeeReimbursementDetailsAdmin getEmployeeReimbursementDetails(Employee_Reimbursement__c currentEmployeeReimbursement) {   
        Double totalrejected =0;    
        EmployeeReimbursementDetailsAdmin employeeReimbursement = new EmployeeReimbursementDetailsAdmin();
        employeeReimbursement.id= currentEmployeeReimbursement.id;
        employeeReimbursement.contactid=currentEmployeeReimbursement.Contact_Id__c;
        employeeReimbursement.name = currentEmployeeReimbursement.Contact_Id__r.Name;
        employeeReimbursement.month = currentEmployeeReimbursement.Month__c;
        employeeReimbursement.threshold =String.valueOf( currentEmployeeReimbursement.Contact_Id__r.Monthly_Mileage_Limit__c);
        employeeReimbursement.totalMileages = String.valueOf(currentEmployeeReimbursement.Total_Mileage__c);
        employeeReimbursement.approvedMileages = String.valueOf(currentEmployeeReimbursement.Total_Approved__c);
        employeeReimbursement.managerName = currentEmployeeReimbursement.Contact_Id__r.Manager__r.Name;
        employeeReimbursement.mileageApproval = currentEmployeeReimbursement.Mileage_Approver__c != null ? currentEmployeeReimbursement.Mileage_Approver__c : '';
        employeeReimbursement.managerEmail = currentEmployeeReimbursement.Contact_Id__r.Manager__r.External_Email__c != null ? currentEmployeeReimbursement.Contact_Id__r.Manager__r.External_Email__c : '';
        employeeReimbursement.status = currentEmployeeReimbursement.Status__c;
        if(currentEmployeeReimbursement.Approved_Date__c != null) {
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
    
    public static Employee_Reimbursement__c approveReimbursementofDriver(EmployeeReimbursements currentEmployeeReimbursement){       
        Employee_Reimbursement__c currentReimbursement = new Employee_Reimbursement__c();
        currentReimbursement.id= currentEmployeeReimbursement.employeeReimbursementId;
        currentReimbursement.Status__c = 'Approved';
        currentReimbursement.Approved_Date__c = system.today();
        return currentReimbursement;
    }
    /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getMonthName is used get Month's name. Ex: 01 =>January.
    @param monthname monthname is the String value which is passed as string value of 01. 
    @return String as January.
    */
    public static String getMonthNamefromno(Integer monthname)
    {
        Map<Integer,String> monthNameMap=new Map<Integer, String>{01 =>'January', 02=>'February', 03=>'March', 04=>'April', 05=>'May',
            06=>'June', 07=>'July', 08=>'August', 09=>'September',10=>'October',
            11=>'November', 12=>'December'};
                return monthNameMap.get(monthname);
    }
    /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getMonthName is used get Month's name. Ex: 01 =>January.
    @param monthname monthname is the String value which is passed as string value of 01. 
    @return String as January.
    */
    public static String getMonthName(String monthname) {
        Map<Integer,String> monthNameMap=new Map<Integer, String>{01 =>'January', 02=>'February', 03=>'March', 04=>'April', 05=>'May',
            06=>'June', 07=>'July', 08=>'August', 09=>'September',10=>'October',
            11=>'November', 12=>'December'};
                if(monthname.contains('-'))    {
                    return monthNameMap.get(Integer.valueOf((monthname.split('-')[0]))); 
                }
        return '';
    }
    
    
    /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getMonthName is used get Month's Integer.
    @param monthname monthname is the String value which is passed as string value of 01. 
    @return String as January.
    */
    public static Integer getMonthInteger(String monthname) {        
        if(monthname.contains('-')) {
            return Integer.valueOf( monthname.split('-')[0]); 
        }
        return 0;
    }
        /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getMonthno is used get Month's No. Ex: January => 01.
    @param monthname monthname is the String value which is passed as January. 
    @return String as 01.
    */
    public static String getMonthno(String monthname){
        Map<String,String> monthNameMap=new Map<String,String>{'January'=>'01', 'February'=>'02', 'March'=>'03', 'April'=>'04', 'May'=>'05',
            'June'=>'06', 'July'=>'07', 'August'=>'08', 'September'=>'09','October'=>'10',
            'November'=>'11', 'December'=>'12'};
                if(monthNameMap.containsKey(monthname)) {
                    return String.valueOf(monthNameMap.get(monthname));    
                }                                                            
        return '';
    }
    /**
    @authOR Natavar Ghodasara
    @date 22nd Jan 2019
    @description getMonthandYear is used get Month's No. Ex: January => 01 AND then Proccess it with current year. Ex. : Current year is 2019 AND you are passing month as parameter as string value Of 01
    @param clickedMonth clickedMonth is the String value which is passed as January. 
    @return String as 01-2019 WHERE 2019 is the current year.
    */
    public static String getMonthandYear(String clickedMonth) {
        String month = getMonthno(clickedMonth);
        if(((month == '12') && (Date.today().month() == 12))||((month == '11')&&((Date.today().month() == 11) || (Date.today().month() == 12)))||((Integer.valueOf(month)<11)&&(Date.today().month()<11))) {
            month=month+'-'+String.valueOf(Date.today().year());
        } else if(((month == '12'|| month == '11') && (Date.today().month()<11)))  {
            month=month+'-'+String.valueOf(Date.today().year()-1);
        }
        return month;
    }
    
    public static String getLastMonthValue(Integer value) {
        String todaysDate= date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
        String lastMonth = todaysDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + todaysDate;
        } else {
            lastMonth = todaysDate;
        }
        return lastMonth;
    }
    public static List<String> getPacketandMeetingDetails(String did) {
        List<String> driverPlanInfoList = new List<String>();
        List<Contact> currentDriver = new List<Contact>();       
        for(Contact con : [SELECT id,name,Meeting__c,Packet__c FROM Contact WHERE id =:did]){
            currentDriver.add(con);
        }
        if(currentDriver.size()>0) {
            driverPlanInfoList.add(JSON.serialize(currentDriver));
        }
        return driverPlanInfoList;
    }
    
    public static List<string> getComplianceCalculation(String did,String year) {
        Decimal totalmileages1 = 0;
        Double totalActualReimbursements = 0;
        Double totalApprovedMileages = 0;
        Double maximumAllowable = 0;
        Double annualTaxLiability = 0;
        
        Contact currentDriver=[SELECT id, name,FirstName, account.Motor_Vehicle_Record_Check_Document__c, email, Insurance_Attachment_Id__c, 
                               MVR_Attachment_Id__c,monthly_compliance_status__c,Compliance_Mileage__c,Avg_Mileage__c  FROM contact WHERE id =: did limit 1];   
        
        Map<integer,WrappperTax>  quaterWiseWrapperTaxMap = new map<integer,WrappperTax>();
        List<WrapperTaxReport> quaterWiseWrapperTaxList = new List<WrapperTaxReport>();
        Map<Integer,WrapperTaxReport> quaterWiseTaxReportMap = new Map<Integer,WrapperTaxReport>();
        List<WrapperTaxReport> taxSummaryReport = new List<WrapperTaxReport>();
        WrapperTaxReport currentDriverTaxReport = new WrapperTaxReport();
        
        List<String> complinceMonthList =  new List<String>();
        if(year == String.valueOf(System.today().Year())) {
            Integer month = System.Today().Month();
            complinceMonthList.add(String.valueOf(12)+'-'+(System.Today().year()-1));
            if(month==12) {
                month=11;
            }
            for(Integer i=1;i<=month;i++) {
                
                complinceMonthList.add((i < 10 ? '0' : '') + String.valueOf(i) +'-'+year);
            }
        } else {
            complinceMonthList.add(String.valueOf(12)+'-'+(Integer.valueOf(year)-1));
            Integer month =11;
            for(Integer i=1;i<=month;i++) {
                
                complinceMonthList.add((i < 10 ? '0' : '') + String.valueOf(i) +'-'+year);
            }
        }
        if(Test.isRunningTest()) {
            
            for(Integer i=1;i<13;i++) {
                if(i<10) {
                    complinceMonthList.add('0'+String.valueOf(i)+'-'+System.Today().year());
                } else if(i==10 || i==11) {
                    complinceMonthList.add(String.valueOf(i)+'-'+System.Today().year());
                } else {
                    complinceMonthList.add(String.valueOf(i)+'-'+String.valueOf((System.Today().year()-1)));
                }
            }
        }
        System.debug('@@@ complinceMonthList @@@'+complinceMonthList);
        WrappperTax wrapppertaxQuater1 = new WrappperTax();
        WrappperTax wrapppertaxQuater2 = new WrappperTax();
        WrappperTax wrapppertaxQuater3 = new WrappperTax();
        WrappperTax wrapppertaxQuater4 = new WrappperTax();
        
        List<WrappperTax> wrapppertaxList = new List<WrappperTax>();

        if(Test.isRunningTest()) {
            List<Employee_Reimbursement__c> reimbursementListTemp= new List<Employee_Reimbursement__c>();
            reimbursementListTemp=[SELECT id,Total_Mileage__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Contact_Id__r.Name,Variable_Rate__c, Contact_Id__r.Employee_ID__c,Contact_Id__r.External_Email__c,Month__c,Approved_Date__c,IRS_Mileage_Rate__c,IRS_Mileage_Rate__r.IRS_Rate__c,IRS_Mileage_Rate__r.year__c FROM Employee_Reimbursement__c  WHERE Contact_Id__c =: currentDriver.id AND Month__c IN: complinceMonthList];
            for(Employee_Reimbursement__c objReim : reimbursementListTemp){
                System.debug('reimbursementListTemp Reim ==> '+objReim);
            }
        }
        
        //Fetch Employee Reimbursement 
        List<Employee_Reimbursement__c> reimbursementList= new List<Employee_Reimbursement__c>();
        reimbursementList=[SELECT id,Total_Mileage__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Contact_Id__r.Name,Variable_Rate__c, Contact_Id__r.Employee_ID__c,Contact_Id__r.External_Email__c,Month__c,Approved_Date__c,IRS_Mileage_Rate__c,IRS_Mileage_Rate__r.IRS_Rate__c,IRS_Mileage_Rate__r.year__c FROM Employee_Reimbursement__c  WHERE Contact_Id__c =: currentDriver.id AND Month__c IN: complinceMonthList AND Approved_Date__c != null];
        if(Test.isRunningTest()) {
            for(Employee_Reimbursement__c objReim : reimbursementList){
                System.debug('reimbursementList Reim ==> '+objReim);
            }
        }
        System.debug('@@@ ==> reimbursementList ==> '+reimbursementList);
        for(Employee_Reimbursement__c currentReimbursement:reimbursementList) {
            List<String> riembursementMonthSplitted = new List<String>();
            if((currentReimbursement.Month__c != null)&&(currentReimbursement.Month__c.contains('-')) && currentReimbursement.IRS_Mileage_Rate__c !=null) {
                riembursementMonthSplitted = currentReimbursement.Month__c.split('-');
                
                //FOR Quater 1 - Calculation AND Assign Value using Wrapper
              
                if((Integer.valueOf(riembursementMonthSplitted[0]) == 12)||(Integer.valueOf(riembursementMonthSplitted[0])<=2)) {
                    if(quaterWiseWrapperTaxMap.containsKey(1)) {
                        wrapppertaxQuater1 =  quaterWiseWrapperTaxMap.get(1);
                    }
                    wrapppertaxQuater1.quarterno = 1;
                    if((wrapppertaxQuater1.Mileages != null)) {
                        Double mileageinDouble = wrapppertaxQuater1.Mileages;
                        if(currentReimbursement.Total_Mileage__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Mileage__c;
                        }                                                   
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater1.Mileages = mileageinDouble; 
                    } else {  
                        if(currentReimbursement.Total_Mileage__c != null) {
                            wrapppertaxQuater1.Mileages = currentReimbursement.Total_Mileage__c.setScale(2);
                        }                      
                    }
                    if((wrapppertaxQuater1.Reimbursements != null)) {
                        Double mileageinDouble = wrapppertaxQuater1.Reimbursements;
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Monthly_Reimbursement__c;    
                        }                          
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater1.Reimbursements = mileageinDouble; 
                    } else {    
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            wrapppertaxQuater1.Reimbursements= currentReimbursement.Total_Monthly_Reimbursement__c.setScale(2);
                        }                                            
                    }
                    if((wrapppertaxQuater1.MaxIRSrate != null)) {
                        Decimal mileageinDouble = wrapppertaxQuater1.MaxIRSrate;
                        if((currentReimbursement.Total_Mileage__c != null)) {
                            mileageinDouble = mileageinDouble + (((currentReimbursement.Total_Mileage__c)*(Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c))));                         
                        }                          
                        mileageinDouble = mileageinDouble.setScale(2);                          
                        wrapppertaxQuater1.MaxIRSrate = mileageinDouble; 
                    } else {
                        if((currentReimbursement.Total_Mileage__c != null)) {
                            wrapppertaxQuater1.MaxIRSrate = ((currentReimbursement.Total_Mileage__c)* Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));
                        }
                    }
                    
                    Double imputedAmountinDouble = 0;
                    Decimal imputedAmountiCheck = 0;
                    if(wrapppertaxQuater1.ImputedAmount != null) {
                        imputedAmountinDouble =wrapppertaxQuater1.ImputedAmount;                      
                        imputedAmountiCheck = wrapppertaxQuater1.ImputedAmount;                      
                    }
                    if((currentReimbursement.Total_Monthly_Reimbursement__c != null) && (currentReimbursement.Total_Mileage__c != null)) {
                        imputedAmountinDouble = imputedAmountinDouble+ currentReimbursement.Total_Monthly_Reimbursement__c-((currentReimbursement.Total_Mileage__c)* Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));                          
                    }       
                    
                    Decimal imputedAmountinDecimal= Decimal.valueOf(imputedAmountinDouble);
                    imputedAmountinDouble = imputedAmountinDecimal.setScale(2);
                    wrapppertaxQuater1.ImputedAmount = imputedAmountinDouble;                       
                    quaterWiseWrapperTaxMap.put(1,wrapppertaxQuater1);
                  
                }
                //FOR Quater 2 - Calculation AND Assign Value using Wrapper
                else if((Integer.valueOf(riembursementMonthSplitted[0])>=3)&&(Integer.valueOf(riembursementMonthSplitted[0])<=5)) {
                    if(quaterWiseWrapperTaxMap.containsKey(2)) {
                        wrapppertaxQuater2 =  quaterWiseWrapperTaxMap.get(2);
                    }
                    wrapppertaxQuater2.quarterno = 2;                      
                    if((wrapppertaxQuater2.Mileages != null)) {
                        Double mileageinDouble = wrapppertaxQuater2.Mileages;
                        if(currentReimbursement.Total_Mileage__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Mileage__c;
                        } 
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater2.Mileages = mileageinDouble;  
                    } else {
                        if(currentReimbursement.Total_Mileage__c != null) {
                            wrapppertaxQuater2.Mileages = currentReimbursement.Total_Mileage__c.setScale(2);
                        }
                    }
                    if((wrapppertaxQuater2.Reimbursements != null)) {
                        Double mileageinDouble = wrapppertaxQuater2.Reimbursements;
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Monthly_Reimbursement__c;    
                        }
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater2.Reimbursements = mileageinDouble; 
                    } else {
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            wrapppertaxQuater2.Reimbursements= currentReimbursement.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                    }
                    if((wrapppertaxQuater2.MaxIRSrate != null)){
                        Decimal mileageinDouble =wrapppertaxQuater2.MaxIRSrate;
                        if((currentReimbursement.Total_Mileage__c != null)) {
                            mileageinDouble = mileageinDouble + (((currentReimbursement.Total_Mileage__c)*(Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c))));                         
                        }
                        mileageinDouble = mileageinDouble.setScale(2);                          
                        wrapppertaxQuater2.MaxIRSrate = mileageinDouble; 
                    } else {
                        wrapppertaxQuater2.MaxIRSrate = ((currentReimbursement.Total_Mileage__c)*Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));
                    }

                    Double imputedAmountinDouble = 0;
                    if(wrapppertaxQuater2.ImputedAmount != null) {
                        imputedAmountinDouble =wrapppertaxQuater2.ImputedAmount;                      
                    }
                    if((currentReimbursement.Total_Monthly_Reimbursement__c != null) && (currentReimbursement.Total_Mileage__c != null)) {
                        imputedAmountinDouble = imputedAmountinDouble+ currentReimbursement.Total_Monthly_Reimbursement__c-((currentReimbursement.Total_Mileage__c)*Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));                          
                    }
                    Decimal imputedAmountinDecimal= Decimal.valueOf(imputedAmountinDouble);
                    imputedAmountinDouble = imputedAmountinDecimal.setScale(2);
                    wrapppertaxQuater2.ImputedAmount = imputedAmountinDouble;
                    quaterWiseWrapperTaxMap.put(2,wrapppertaxQuater2);
                    
                }
                //FOR Quater 3 - Calculation AND Assign Value using Wrapper
                else if((Integer.valueOf(riembursementMonthSplitted[0])>=6)&&(Integer.valueOf(riembursementMonthSplitted[0])<=8)) {
                    if(quaterWiseWrapperTaxMap.containsKey(3)) {
                        wrapppertaxQuater3 =  quaterWiseWrapperTaxMap.get(3);
                    }
                    wrapppertaxQuater3.quarterno = 3;                      
                    if((wrapppertaxQuater3.Mileages != null)) {
                        Double mileageinDouble = wrapppertaxQuater3.Mileages;
                        if(currentReimbursement.Total_Mileage__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Mileage__c;
                        } 
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater3.Mileages = mileageinDouble; 
                    } else {
                        if(currentReimbursement.Total_Mileage__c != null) {
                            wrapppertaxQuater3.Mileages = currentReimbursement.Total_Mileage__c.setScale(2);
                        }
                    }
                    if((wrapppertaxQuater3.Reimbursements != null)) {
                        Double mileageinDouble = wrapppertaxQuater3.Reimbursements;
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Monthly_Reimbursement__c;    
                        }
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater3.Reimbursements = mileageinDouble; 
                    } else {
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            wrapppertaxQuater3.Reimbursements= currentReimbursement.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                    }
                    if((wrapppertaxQuater3.MaxIRSrate != null)) {
                        Decimal mileageinDouble =wrapppertaxQuater3.MaxIRSrate;
                        if((currentReimbursement.Total_Mileage__c != null)) {
                            mileageinDouble = mileageinDouble + (((currentReimbursement.Total_Mileage__c)*(Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c))));                         
                        }
                        mileageinDouble = mileageinDouble.setScale(2);                          
                        wrapppertaxQuater3.MaxIRSrate = mileageinDouble;  
                    } else {
                        wrapppertaxQuater3.MaxIRSrate = ((currentReimbursement.Total_Mileage__c)*Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));
                    }

                    Double imputedAmountinDouble = 0;
                    if(wrapppertaxQuater3.ImputedAmount != null) {
                        imputedAmountinDouble =wrapppertaxQuater3.ImputedAmount;                      
                    }
                    if((currentReimbursement.Total_Monthly_Reimbursement__c != null) && (currentReimbursement.Total_Mileage__c != null)) {
                        imputedAmountinDouble = imputedAmountinDouble+ currentReimbursement.Total_Monthly_Reimbursement__c-((currentReimbursement.Total_Mileage__c)* Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));                          
                    }
                    Decimal imputedAmountinDecimal= Decimal.valueOf(imputedAmountinDouble);
                    imputedAmountinDouble = imputedAmountinDecimal.setScale(2);
                    wrapppertaxQuater3.ImputedAmount = imputedAmountinDouble;
                    quaterWiseWrapperTaxMap.put(3,wrapppertaxQuater3);
                    
                }
                //FOR Quater 4 - Calculation AND Assign Value using Wrapper 
                else if((Integer.valueOf(riembursementMonthSplitted[0])>=9)&&(Integer.valueOf(riembursementMonthSplitted[0])<=11)) {
                    if(quaterWiseWrapperTaxMap.containsKey(4)) {
                        wrapppertaxQuater4 =  quaterWiseWrapperTaxMap.get(4);
                    }
                    wrapppertaxQuater4.quarterno = 4;                      
                    if((wrapppertaxQuater4.Mileages != null)) {
                        Double mileageinDouble = wrapppertaxQuater4.Mileages;
                        if(currentReimbursement.Total_Mileage__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Mileage__c;
                        } 
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater4.Mileages = mileageinDouble; 
                    } else {
                        if(currentReimbursement.Total_Mileage__c != null) {
                            wrapppertaxQuater4.Mileages = currentReimbursement.Total_Mileage__c.setScale(2);
                        }
                    }
                    if((wrapppertaxQuater4.Reimbursements != null)) {
                        Double mileageinDouble = wrapppertaxQuater4.Reimbursements;
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            mileageinDouble = mileageinDouble + currentReimbursement.Total_Monthly_Reimbursement__c;    
                        }
                        Decimal mileageinDecimal= Decimal.valueOf(mileageinDouble);
                        mileageinDouble = mileageinDecimal.setScale(2);
                        wrapppertaxQuater4.Reimbursements = mileageinDouble; 
                    } else {
                        if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                            wrapppertaxQuater4.Reimbursements= currentReimbursement.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                    }
                    if((wrapppertaxQuater4.MaxIRSrate != null)) {
                        Decimal mileageinDouble =wrapppertaxQuater4.MaxIRSrate;
                        if((currentReimbursement.Total_Mileage__c != null)) {
                            mileageinDouble = mileageinDouble + (((currentReimbursement.Total_Mileage__c)*(Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c))));                         
                        }  
                        mileageinDouble = mileageinDouble.setScale(2);                          
                        wrapppertaxQuater4.MaxIRSrate = mileageinDouble; 
                    } else {
                        wrapppertaxQuater4.MaxIRSrate = ((currentReimbursement.Total_Mileage__c)*Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));
                    }

                    Double imputedAmountinDouble = 0;
                    if(wrapppertaxQuater4.ImputedAmount != null) {
                        imputedAmountinDouble =wrapppertaxQuater4.ImputedAmount;                      
                    }
                    if((currentReimbursement.Total_Monthly_Reimbursement__c != null) && (currentReimbursement.Total_Mileage__c != null)) {
                        imputedAmountinDouble = imputedAmountinDouble+ currentReimbursement.Total_Monthly_Reimbursement__c-((currentReimbursement.Total_Mileage__c)*Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));                          
                    }
                    Decimal imputedAmountinDecimal= Decimal.valueOf(imputedAmountinDouble);
                    imputedAmountinDouble = imputedAmountinDecimal.setScale(2);
                    wrapppertaxQuater4.ImputedAmount = imputedAmountinDouble;
                    quaterWiseWrapperTaxMap.put(4,wrapppertaxQuater4);
                    
                }
               
                if(currentReimbursement.Approved_Date__c != null) {
                    WrapperTaxReport currentTaxReport = new WrapperTaxReport();
                    currentTaxReport.drivername= currentReimbursement.Contact_Id__r.Name;
                    currentTaxReport.employeeid =currentReimbursement.Contact_Id__r.Employee_ID__c;
                    currentTaxReport.emailid = currentReimbursement.Contact_Id__r.External_Email__c;
                    if(currentReimbursement.Total_Mileage__c != null) {
                        currentTaxReport.approvedmileages = currentReimbursement.Total_Mileage__c.setScale(2);
                    } else {
                        currentTaxReport.approvedmileages = 0;
                    }
                    currentTaxReport.variableRate = currentReimbursement.Variable_Rate__c != null ? currentReimbursement.Variable_Rate__c : null;
                    if(currentReimbursement.Total_Monthly_Reimbursement__c != null) {
                        currentTaxReport.totalreim = currentReimbursement.Total_Monthly_Reimbursement__c.setScale(2);
                    } else {
                        currentTaxReport.totalreim = 0;
                    }
                    if((currentReimbursement.Total_Mileage__c != null)) {
                        currentTaxReport.iRSallowable =(((currentReimbursement.Total_Mileage__c.setScale(2))*(Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c))));
                    }                      
                    if((currentReimbursement.Total_Monthly_Reimbursement__c  != null)&&(currentReimbursement.Total_Mileage__c != null)) {
                        currentTaxReport.imputedincome=(currentReimbursement.Total_Monthly_Reimbursement__c.setScale(2))-((currentReimbursement.Total_Mileage__c.setScale(2))*Double.valueOf(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c));
                    }

                    // @Date : 31/05/24 || Vatsal Bhalani

                    if(currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c != null) {
                        currentTaxReport.iRSmileageRate = currentReimbursement.IRS_Mileage_Rate__r.IRS_Rate__c;
                    } else {
                        currentTaxReport.iRSmileageRate = 0;
                    }

                    //==
                    currentTaxReport.month =Integer.valueOf(riembursementMonthSplitted[0]);
                    currentTaxReport.year =String.valueOf(riembursementMonthSplitted[1]);
                    currentTaxReport.monthyear = getMonthNamefromno(Integer.valueOf(riembursementMonthSplitted[0]))+' '+String.valueOf(riembursementMonthSplitted[1]);
                    quaterWiseTaxReportMap.put(Integer.valueOf(riembursementMonthSplitted[0]),currentTaxReport);
                    currentDriverTaxReport.drivername = currentReimbursement.Contact_Id__r.Name;
                    if(currentReimbursement.Contact_Id__r.Employee_ID__c != null) {
                        currentDriverTaxReport.employeeid = currentReimbursement.Contact_Id__r.Employee_ID__c;
                    }
                    if(currentReimbursement.Contact_Id__r.External_Email__c != null) {
                        currentDriverTaxReport.emailid = currentReimbursement.Contact_Id__r.External_Email__c;
                    }                   
                }
            }
        }
        String message='';       
        
         //Use FOR Quater - 1 
        if(quaterWiseWrapperTaxMap.containsKey(1)) {
            totalActualReimbursements =quaterWiseWrapperTaxMap.get(1).Reimbursements;
            totalApprovedMileages = quaterWiseWrapperTaxMap.get(1).Mileages;
            maximumAllowable =  quaterWiseWrapperTaxMap.get(1).MaxIRSrate;
            annualTaxLiability =quaterWiseWrapperTaxMap.get(1).ImputedAmount; 
            if(quaterWiseWrapperTaxMap.get(1).Mileages != null) {
                totalmileages1 = quaterWiseWrapperTaxMap.get(1).Mileages;
            }  
        }
        
         //Use FOR Quater - 2 
        if(quaterWiseWrapperTaxMap.containsKey(2)) {
            totalActualReimbursements =totalActualReimbursements+quaterWiseWrapperTaxMap.get(2).Reimbursements;
            totalApprovedMileages = totalApprovedMileages + quaterWiseWrapperTaxMap.get(2).Mileages;
            maximumAllowable = maximumAllowable  +quaterWiseWrapperTaxMap.get(2).MaxIRSrate;
            annualTaxLiability =annualTaxLiability+quaterWiseWrapperTaxMap.get(2).ImputedAmount;
            if(quaterWiseWrapperTaxMap.get(2).Mileages != null) {
                totalmileages1 =totalmileages1+quaterWiseWrapperTaxMap.get(2).Mileages;
            }            
        }
        
         //Use FOR Quater - 3 
        if(quaterWiseWrapperTaxMap.containsKey(3)) {
            totalActualReimbursements =totalActualReimbursements+quaterWiseWrapperTaxMap.get(3).Reimbursements;
            totalApprovedMileages = totalApprovedMileages + quaterWiseWrapperTaxMap.get(3).Mileages;
            maximumAllowable = maximumAllowable  +quaterWiseWrapperTaxMap.get(3).MaxIRSrate;
            annualTaxLiability =annualTaxLiability+quaterWiseWrapperTaxMap.get(3).ImputedAmount; 
            if(quaterWiseWrapperTaxMap.get(3).Mileages != null) {
                totalmileages1 =totalmileages1+quaterWiseWrapperTaxMap.get(3).Mileages; 
            }
        }
        
        //Use FOR Quater - 4 
        if(quaterWiseWrapperTaxMap.containsKey(4)) {
            totalActualReimbursements =totalActualReimbursements+quaterWiseWrapperTaxMap.get(4).Reimbursements;
            totalApprovedMileages = totalApprovedMileages + quaterWiseWrapperTaxMap.get(4).Mileages;
            maximumAllowable = maximumAllowable  +quaterWiseWrapperTaxMap.get(4).MaxIRSrate;
            annualTaxLiability =annualTaxLiability+quaterWiseWrapperTaxMap.get(4).ImputedAmount;
            if(quaterWiseWrapperTaxMap.get(4).Mileages != null) {
                totalmileages1 =totalmileages1+quaterWiseWrapperTaxMap.get(4).Mileages; 
            }                     
        }
        if(currentDriver.monthly_compliance_status__c==null) {
            if(quaterWiseWrapperTaxMap.containsKey(1)) {            
                wrapppertaxList.add(quaterWiseWrapperTaxMap.get(1));
            }
            if(quaterWiseWrapperTaxMap.containsKey(2)){            
                wrapppertaxList.add(quaterWiseWrapperTaxMap.get(2));
            }
            if(quaterWiseWrapperTaxMap.containsKey(3)) {  
                wrapppertaxList.add(quaterWiseWrapperTaxMap.get(3));
            }
            if(quaterWiseWrapperTaxMap.containsKey(4)) {
                wrapppertaxList.add(quaterWiseWrapperTaxMap.get(4));
            }
            message=label.waitingfordocumentation;
        } else  {
            if(currentDriver.monthly_compliance_status__c =='Yes') {
                if(totalmileages1 < currentDriver.Compliance_Mileage__c) {
                    message=label.compliancenotmeeting;
                    if(quaterWiseWrapperTaxMap.containsKey(1)) {   
                        wrapppertaxList.add(quaterWiseWrapperTaxMap.get(1));
                    }
                    if(quaterWiseWrapperTaxMap.containsKey(2)) {       
                        wrapppertaxList.add(quaterWiseWrapperTaxMap.get(2));
                    }
                    if(quaterWiseWrapperTaxMap.containsKey(3)) {   
                        wrapppertaxList.add(quaterWiseWrapperTaxMap.get(3));
                    }
                    if(quaterWiseWrapperTaxMap.containsKey(4)) {
                        wrapppertaxList.add(quaterWiseWrapperTaxMap.get(4));
                    }
                }
                
                if(currentDriver.Avg_Mileage__c<416.67){
                    message=label.compliancenotmeeting;
                }else {
                    message=Label.compliance;
                }
            } else {
                if(quaterWiseWrapperTaxMap.containsKey(1)) {                  
                    wrapppertaxList.add(quaterWiseWrapperTaxMap.get(1));
                }
                if(quaterWiseWrapperTaxMap.containsKey(2)) {  
                    wrapppertaxList.add(quaterWiseWrapperTaxMap.get(2));
                }
                if(quaterWiseWrapperTaxMap.containsKey(3)) {  
                    wrapppertaxList.add(quaterWiseWrapperTaxMap.get(3));
                }
                if(quaterWiseWrapperTaxMap.containsKey(4)) {
                    wrapppertaxList.add(quaterWiseWrapperTaxMap.get(4));
                }
                if(currentDriver.monthly_compliance_status__c =='No – Vehicle Age') {
                    message=Label.NoVehicleAge;
                    message = message.replace('Name',currentDriver.FirstName);
                }  
                else if(currentDriver.monthly_compliance_status__c =='No – Insurance Not Meeting Minimum'){
                    message=Label.noInsurancenotmeetingminimum;
                    message = message.replace('Name',currentDriver.FirstName);
                }
                else if(currentDriver.monthly_compliance_status__c =='No – Vehicle Value'){
                    message=Label.novehiclevalue;
                    message = message.replace('Name',currentDriver.FirstName);
                }
                else if(currentDriver.monthly_compliance_status__c =='No - Insurance Not Provided') {
                    message=Label.insuranceisnotmeeting;
                    message = message.replace('Name',currentDriver.FirstName);
                } else if(currentDriver.monthly_compliance_status__c =='No - Missing Coverage Dates') {
                    message=Label.MissingCoverageDates;
                    message = message.replace('Name',currentDriver.FirstName);
                } else if(currentDriver.monthly_compliance_status__c =='Expired Insurance') {
                    message = Label.ExpiredInsurance;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='No – Insurance Card') {
                    message=Label.Insurancecard;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='') {
                    message=Label.waitingfordocumentation;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='No - Mileage') {
                    message=Label.compliancenotmeeting;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='No - Umbrella Policy') {
                    message=Label.noUmbrellaPolicy;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='No - Insurance Dec Page') {
                    message=Label.noInsuranceDeclarationPage;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='No - Mileage & Vehicle Value') {
                    message=Label.noMileageVehicleValue;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='No - Mileage & Vehicle Age') {
                    message=Label.noMileageVehicleAge;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='No - Mileage & Insurance') {
                    message=Label.noMileageInsurance;
                    message = message.replace('Name',currentDriver.FirstName);
                }else if(currentDriver.monthly_compliance_status__c =='Pending') {
                    message=Label.CompliancePending;
                    
                }
            }
        }         
        
        if(quaterWiseTaxReportMap.containsKey(12)) {
            WrapperTaxReport currentTaxReport = quaterWiseTaxReportMap.get(12);              
            currentTaxReport.approvedmileages = Decimal.valueOf(quaterWiseTaxReportMap.get(12).approvedmileages).setScale(2);
            currentTaxReport.totalreim = Decimal.valueOf(quaterWiseTaxReportMap.get(12).totalreim).setScale(2);
            currentTaxReport.iRSallowable= Decimal.valueOf(quaterWiseTaxReportMap.get(12).iRSallowable).setScale(2);
            
            // @Date : 03/06/24 || Vatsal Bhalani
            currentTaxReport.imputedincome = quaterWiseTaxReportMap.get(12).imputedincome<0? 0:Decimal.valueOf(quaterWiseTaxReportMap.get(12).imputedincome).setScale(2);
            //currentTaxReport.imputedincome = Decimal.valueOf(quaterWiseTaxReportMap.get(12).imputedincome).setScale(2);
            //===

            // @Date : 31/05/24 || Vatsal Bhalani
            currentTaxReport.iRSmileageRate = Decimal.valueOf(quaterWiseTaxReportMap.get(12).iRSmileageRate);
            //====
            quaterWiseTaxReportMap.put(12,currentTaxReport);
            quaterWiseWrapperTaxList.add(quaterWiseTaxReportMap.get(12));
        }
        Set<Integer> uniqueMonthSet = new Set<Integer>();
        List<Integer> monthList = new List<Integer>();
        if(quaterWiseTaxReportMap.size()>0) {
            uniqueMonthSet = quaterWiseTaxReportMap.keySet();
            monthList.addAll(uniqueMonthSet);
            monthList.sort();
        }
        for(Integer i : monthList) {
            if(i != 12) {
                WrapperTaxReport currentTaxReport = quaterWiseTaxReportMap.get(i);              
                currentTaxReport.approvedmileages = Decimal.valueOf(quaterWiseTaxReportMap.get(i).approvedmileages).setScale(2);
                currentTaxReport.totalreim = Decimal.valueOf(quaterWiseTaxReportMap.get(i).totalreim).setScale(2);
                currentTaxReport.iRSallowable= Decimal.valueOf(quaterWiseTaxReportMap.get(i).iRSallowable).setScale(2);
                
                // @Date : 03/06/24 || Vatsal Bhalani
                currentTaxReport.imputedincome = quaterWiseTaxReportMap.get(i).imputedincome<0? 0:Decimal.valueOf(quaterWiseTaxReportMap.get(i).imputedincome).setScale(2);
                //currentTaxReport.imputedincome = Decimal.valueOf(quaterWiseTaxReportMap.get(i).imputedincome).setScale(2);
                //===
                
                // @Date : 31/05/24 || Vatsal Bhalani
                currentTaxReport.iRSmileageRate = Decimal.valueOf(quaterWiseTaxReportMap.get(i).iRSmileageRate);
                //---
                quaterWiseTaxReportMap.put(i,currentTaxReport);
                quaterWiseWrapperTaxList.add(quaterWiseTaxReportMap.get(i));
            }
        }
        
        //FOR Annual Tax Liability Summary Report
        annualTaxLiability = annualTaxLiability < 0 ? 0 : annualTaxLiability ;
        currentDriverTaxReport.imputedincome=annualTaxLiability;
        taxSummaryReport.add(currentDriverTaxReport);
        
        //FOR Annual Tax Liability Detail Report
        List<String> complianceCalculationList = new List<String>();
        complianceCalculationList.add(JSON.serialize(String.valueOf(currentDriver.name)));
        complianceCalculationList.add(JSON.serialize(message));        
        if(wrapppertaxList.size()>0) { 
            complianceCalculationList.add(JSON.serialize(wrapppertaxList));
            complianceCalculationList.add(JSON.serialize(quaterWiseWrapperTaxList));
            complianceCalculationList.add(JSON.serialize(taxSummaryReport));         
            complianceCalculationList.add(JSON.serialize(String.valueOf(Decimal.valueOf(totalActualReimbursements).setScale(2)))); 
            complianceCalculationList.add(JSON.serialize(String.valueOf(Decimal.valueOf(maximumAllowable).setScale(2))));          
            complianceCalculationList.add(JSON.serialize(String.valueOf(Decimal.valueOf(annualTaxLiability).setScale(2)))); 
            complianceCalculationList.add(JSON.serialize(String.valueOf(Decimal.valueOf(totalApprovedMileages).setScale(2))));  
        }   
        return complianceCalculationList;
    }
    public static String approveMileagesForAdminDash(String checked,String selected,String unapprove,String name,String emailaddress) {
        List<EmployeeMileages> employeeMileagesList = new List<EmployeeMileages>();
        List<Employee_Mileage__c> mileagesList = new List<Employee_Mileage__c>(); 
        List<String> approvedIdList = new List<String>();
        List<String> rejectedIdList = new List<String>();
        List<String> unapproveIdList = new List<String>();
        MAP<Id,Employee_Mileage__c> milMap = new MAP<Id,Employee_Mileage__c>();
        if(selected != null) {
            List<EmployeeMileages> employeeMileagesListApprove = new List<EmployeeMileages>();
            employeeMileagesListApprove = (List<EmployeeMileages>)JSON.deserialize(selected,List<EmployeeMileages>.Class);
            employeeMileagesList.addAll(employeeMileagesListApprove);
        } 
        if(checked != null) {
            List<EmployeeMileages> employeeMileagesListRejected = new List<EmployeeMileages>();
            employeeMileagesListRejected = (List<EmployeeMileages>)JSON.deserialize(checked,List<EmployeeMileages>.Class);
            employeeMileagesList.addAll(employeeMileagesListRejected);
        }
        if(unapprove != null){
            List<EmployeeMileages> employeeMileagesListUnapprove = new List<EmployeeMileages>();
            employeeMileagesListUnapprove = (List<EmployeeMileages>)JSON.deserialize(unapprove,List<EmployeeMileages>.Class);
            employeeMileagesList.addAll(employeeMileagesListUnapprove);
        }
        if(employeeMileagesList.size()>0) {
            for(EmployeeMileages currentMileage : employeeMileagesList) {
                if(currentMileage.isSelected == true) {
                    approvedIdList.add(currentMileage.id);
                }
                else if(currentMileage.isUnapprove == true){
                    unapproveIdList.add(currentMileage.id);
                } else {
                    rejectedIdList.add(currentMileage.id);
                }
            }
            
            List<Employee_Mileage__c> mileagesToApprove = WrapperUtils.UpdateMileages(approvedIdList,'Approved');
            mileagesToApprove.addAll(WrapperUtils.UpdateMileages(rejectedIdList,'Rejected'));
            mileagesToApprove.addAll(WrapperUtils.UpdateMileages(unapproveIdList,'Not Approved Yet'));            
           
            milMap.putall(mileagesToApprove);
            
            if(milMap.size()>0){
                update milMap.values();
            }            
            SendEmailToMe__c customSetValue = SendEmailToMe__c.getValues('ChangeTripStatusinTripLogBatch');
            if(customSetValue!=null && customSetValue.Send_email_to_me__c==true) {
                Database.executeBatch(New ChangeTripStatusinTripLog(approvedIdList,rejectedIdList,name,emailaddress),1);
            } 
            return 'success';
        }               
        return 'success';
    }
    
        /**
    * Method to update Mileages
    */
    public static List<Employee_Mileage__c> UpdateMileages(List<String> mileageIds, String status) {
        List<Employee_Mileage__c> mileages = new List<Employee_Mileage__c>();
        for(String mileageId : mileageIds) {
            Employee_Mileage__c mil = new Employee_Mileage__c();
            mil.Id = mileageId;
            mil.Trip_Status__c = status;
            if(status == 'Not Approved Yet'){
                mil.Approved_Date__c = null;
                mil.Rejected__c = false;
            } else {
                mil.Approved_Date__c = System.Today();
                mil.Trip_Approval_Time__c = DateTime.now();
                mil.Rejected__c = (status == 'Approved' ? false : true);
            }
            mileages.add(mil);
        }
        return mileages;
    }
    // AdminDashboard Class Methods Started 
    
    public static String getManager(String did, String accid) {        
        List<Contact> managerList = new List<Contact>();
        managerList = [SELECT id, Name, Email,Accountid FROM Contact WHERE Accountid =: accid AND (Deactivated_Date__c = null OR Deactivated_Date__c > TODAY) AND (Role__c='Manager' OR Role__c='Driver/Manager')];
        return JSON.serialize(managerList);
    }
    
    public static String getadminname(String did) {
        Contact adminContact = [SELECT Id,Name FROM Contact WHERE id =: did];
        return JSON.serialize(adminContact.Name);
    }
    // AdminDashboard Class Methods END
    // ManagerDashboard Class Methods Starts
    
    public static String getDriverGasPrice(String strMailingState,String strMailingCity) {   
        String gaspriceyearmonth = '';
        if(System.today().month() == 1) {
            gaspriceyearmonth = strMailingCity + strMailingState + 12+ String.valueOf(System.today().year()-1); 
        } else {
            gaspriceyearmonth = strMailingCity + strMailingState + String.valueOf(System.today().month()-1) + String.valueOf(System.today().year()); 
        }
        List<Gas_Prices__c> gasPriceList = new List<Gas_Prices__c>();
        gasPriceList = [SELECT id,Fuel_Price__c FROM Gas_Prices__c WHERE Month_State_City__c =: gaspriceyearmonth];
        return JSON.serialize(gasPriceList);
    }
    public static String getDriverFuelVariableRate(String conId){      
        String lastMonth = Utils.fetchMonths(1, 0)[0];       
        String fuelVariableRate = '';
        List<Employee_Reimbursement__c> reimList = new List<Employee_Reimbursement__c>();     
        for(Employee_Reimbursement__c reim : [SELECT id,Fuel_Variable_Rate__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: conId AND Month__c =: lastMonth AND Fuel_Variable_Rate__c != null]){
            fuelVariableRate = String.valueOf(reim.Fuel_Variable_Rate__c);
            return fuelVariableRate;
        }
        return '0';
    }
        /*EMC-260 
    Added a new field : Total_Approved__c,Total_Mileage__c, Total_Pending__c  
    AuthOR : Sanket Goswami */
    public Static String getAllReimbursements(String year,String did,String accid) {
        String query=''; 
        List<String> monthList = new List<String>();
        integer month = 12;
        if(Integer.valueOf(year)==System.today().year()) {
            month = System.today().month();
        }
        for(Integer i=1;i<=month;i++){
            if(i<10) {
                monthList.add('0'+String.valueOf(i)+'-'+year);
            } else {
                monthList.add(String.valueOf(i)+'-'+year);
            }
        }
        query ='';
        String editedquery = '';
        List<Contact> conList = [SELECT id,Deactivated_Date__c,Account.Bi_Weekly_Pay_Period__c   FROM Contact   WHERE id =: did    AND (Deactivated_Date__c = null  AND ( Driver_Type__c != 'Driver - Full Time'  AND Driver_Type__c != 'Driver - Part Time' AND Driver_Type__c != 'Driver - Salary'  AND Account.Bi_Weekly_Pay_Period__c = false))];
        if((monthList.size() > 0 && conList.isEmpty()) || (monthList.size() > 0 && !conList.isEmpty() && System.today().Month() == 1) || (monthList.size() > 0 && !conList.isEmpty() && Integer.valueOf(year) != System.today().year())) {
            editedquery = setQueryParameters(monthList);
            query = 'SELECT id,Reimbursement_Month__c,Mileage_Lock_Date__c,Reimbursement_Lock_Time__c,Lock_Date_User__c,Contact_Email__c,Total_Monthly_Reimbursement_BiWeek__c,Contact_Id__r.Driver_Type__c,Contact_Id__r.Reimbursement_Frequency__c,Contact_Id__r.Reimbursement_Type__c,Total_Approved__c,Monthly_Fixed_Amount__c,Number_of_Pay_Period__c,Half_Fixed_Amount__c,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Monthly_Variable_Amount__c,Total_Monthly_Approved_Variable__c,MPG__c,Maintenance_and_Tires__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+did+'\' AND Month__c IN '+ editedquery+'Order by Reimbursement_Month__c asc';
        } 
        else if(monthList.size() > 0 && !conList.isEmpty() ) {
            monthlist.remove(monthList.size()-1);
            editedquery = setQueryParameters(monthList);
            query = 'SELECT id,Reimbursement_Month__c,Mileage_Lock_Date__c,Reimbursement_Lock_Time__c,Lock_Date_User__c,Contact_Email__c,Contact_Id__r.Driver_Type__c,Total_Monthly_Reimbursement_BiWeek__c,Contact_Id__r.Reimbursement_Frequency__c,Contact_Id__r.Reimbursement_Type__c,Total_Approved__c,Monthly_Fixed_Amount__c,Number_of_Pay_Period__c,Half_Fixed_Amount__c,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Monthly_Variable_Amount__c,Total_Monthly_Approved_Variable__c,MPG__c,Maintenance_and_Tires__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+did+'\' AND Month__c IN '+ editedquery+'Order by Reimbursement_Month__c asc';
        } else {
            query = 'SELECT id,Reimbursement_Month__c,Mileage_Lock_Date__c,Reimbursement_Lock_Time__c,Lock_Date_User__c,Month__c,Total_Monthly_Reimbursement_BiWeek__c,Contact_Id__r.Reimbursement_Frequency__c,Contact_Id__r.Reimbursement_Type__c,Contact_Id__r.Driver_Type__c,Total_Approved__c,Monthly_Fixed_Amount__c,Number_of_Pay_Period__c,Half_Fixed_Amount__c,Contact_Email__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Monthly_Variable_Amount__c,Total_Monthly_Approved_Variable__c,MPG__c,Maintenance_and_Tires__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+did+'\''+'Order by Reimbursement_Month__c asc';
        }
        
        List<EmployeeReimbursements> reimbursementList =  new List<EmployeeReimbursements>();
        Double sumTotalReim = 0;
        Integer count = 0;
        for(Employee_Reimbursement__c currentReimbursement : (List<Employee_Reimbursement__c>)ExecuteQueryUtil.getRecordListFromsObject(query)) {
            count += 1;
            if(currentReimbursement.Total_Monthly_Reimbursement_BiWeek__c > 0 && currentReimbursement.Contact_Id__r.Reimbursement_Frequency__c == 'Bi-Weekly Reimbursement' ){
                sumTotalReim = sumTotalReim + currentReimbursement.Total_Monthly_Reimbursement_BiWeek__c;
            } else if(currentReimbursement.Total_Monthly_Reimbursement__c > 0){
                sumTotalReim = sumTotalReim + currentReimbursement.Total_Monthly_Reimbursement__c;
            }

            reimbursementList.add(WrapperUtils.getEmployeeReimbursements(currentReimbursement,sumTotalReim,count));
        }
        return JSON.serialize(reimbursementList);
    }
    
    public static String getReimbursementsList(String driverid,String status) {
        String currentMonth = Utils.fetchMonths(1, 0)[0];
        String query ='';
        
        List<contact> conList = [SELECT id,Deactivated_Date__c FROM contact WHERE id =: driverid ];
        if(conList[0].Deactivated_Date__c != null && String.isNotEmpty(status)){
            query = 'SELECT id,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Total_Monthly_Approved_Variable__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+driverid+'\' AND Status__c != \''+status+'\' AND Total_Pending__c > 0' ;
        } else if(conList[0].Deactivated_Date__c != null && String.isEmpty(status)) {
            query = 'SELECT id,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Monthly_Variable_Amount__c,Total_Monthly_Approved_Variable__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+driverid+'\' AND Total_Pending__c > 0 '; 
        } else if(String.isNotEmpty(status)){
            query = 'SELECT id,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Total_Monthly_Approved_Variable__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+driverid+'\' AND Status__c != \''+status+'\' AND Month__c=\''+currentMonth+'\' AND Total_Pending__c > 0 ' ;
        } else {
            query = 'SELECT id,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Monthly_Variable_Amount__c,Total_Monthly_Approved_Variable__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+driverid+'\' AND Month__c=\''+currentMonth+'\' AND Total_Pending__c > 0 '; 
        }
        
        List<Employee_Reimbursement__c> reimbursementList =  new List<Employee_Reimbursement__c>();
        reimbursementList = (List<Employee_Reimbursement__c>)ExecuteQueryUtil.getRecordListFromsObject(query);
        if(reimbursementList.size()>0) {
            return JSON.serialize(reimbursementList);
        } else {
            return JSON.serialize(0);
        }
    }
    
    public static String getMileages(String clickedMonth,string clickedYear,String did) {
        String monthno = WrapperUtils.getMonthno(clickedMonth);
        Integer currentMonth = System.today().month();
        if((currentMonth == 1 || currentMonth == 2) && monthno == '12'){
            clickedYear = String.valueOf(System.today().year()- 1);
        } else {
            clickedYear = String.valueOf(System.today().year());
        }
        
        String month = monthno + '-'+ clickedYear;
        List<EmployeeMileages> employeeMileageList = new List<EmployeeMileages>();
        for(Employee_Mileage__c currentMileage : [SELECT id,Name,Trip_Date__c,Trip_Origin__c,Approval_Name__c,Trip_Destination__c,Mileage__c,Variable__c,Trip_Status__c, Approved_Date__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,Total_Time__c, EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,Driving_Time__c,Tag__c, EmployeeReimbursement__r.Total_Variable_Rate__c,EmployeeReimbursement__r.Total_Pending__c,Stay_Time__c, Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Total_Monthly_Approved_Variable__c, EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Monthly_Variable_Amount__c, Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Mileage__c,ConvertedEndTime__c, EmployeeReimbursement__r.Total_Rejected__c,Notes__c,ConvertedStartTime__c,Variable_Rate__c,Original_Origin_Name__c,Original_Destination_Name__c, TimeZone__c,EmployeeReimbursement__r.Mileage_Lock_Date__c,Activity__c,Mileage_Lock_Date__c,EmployeeReimbursement__r.Fuel_Variable_Rate__c,Fuel_Variable_Rate__c,High_Risk_Mileage__c FROM Employee_Mileage__c  WHERE EmployeeReimbursement__r.Month__c =: month AND EmployeeReimbursement__r.Contact_Id__c =: did order by ConvertedStartTime__c asc]) {
            employeeMileageList.add(WrapperUtils.getMileagesOfReimbursement(currentMileage));
        }
        
        if(!employeeMileageList.isEmpty())  {
            return JSON.serialize(employeeMileageList);
        } else {
            return JSON.serialize(employeeMileageList);
        }
    }

    public static String getMileagesBasedTA(String startdate,string enddate,String did) {
        List<EmployeeMileages> employeeMileageList = new List<EmployeeMileages>();
        for(Employee_Mileage__c currentMileage : [SELECT id,Name,Trip_Date__c,Trip_Origin__c,Approval_Name__c,Trip_Destination__c,Mileage__c,Variable__c,Trip_Status__c, Approved_Date__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,Total_Time__c, EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,Driving_Time__c,Tag__c, EmployeeReimbursement__r.Total_Variable_Rate__c,EmployeeReimbursement__r.Total_Pending__c,Stay_Time__c, Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Total_Monthly_Approved_Variable__c, EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Monthly_Variable_Amount__c, Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Mileage__c,ConvertedEndTime__c, EmployeeReimbursement__r.Total_Rejected__c,Notes__c,ConvertedStartTime__c,Variable_Rate__c,Original_Origin_Name__c,Original_Destination_Name__c, TimeZone__c,EmployeeReimbursement__r.Mileage_Lock_Date__c,Activity__c,Mileage_Lock_Date__c,EmployeeReimbursement__r.Fuel_Variable_Rate__c,Fuel_Variable_Rate__c,High_Risk_Mileage__c FROM Employee_Mileage__c  WHERE Trip_Date__c >= : Date.valueOf(startDate) AND Trip_Date__c <= : Date.valueOf(endDate)  AND EmployeeReimbursement__r.Contact_Id__c =: did order by ConvertedStartTime__c asc]) {
                employeeMileageList.add(WrapperUtils.getMileagesOfReimbursement(currentMileage));
            }
        if(!employeeMileageList.isEmpty())
            return JSON.serialize(employeeMileageList);
        
        return '';
    }
    
    public static List<String> getMileages1(String clickedMonth,String year,String did) {
        
        String month = WrapperUtils.getMonthno(clickedMonth);
        month = month +'-'+year;
        String query = 'SELECT id,Name,Trip_Date__c,Mileage_Lock_Date__c,Variable_Rate__c,Trip_Origin__c,Stay_Time__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Destination__c,Mileage__c,Variable__c,Approval_Name__c,Trip_Status__c,Approved_Date__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c, EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,EmployeeReimbursement__r.Total_Variable_Rate__c,EmployeeReimbursement__r.Total_Pending__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Monthly_Variable_Amount__c,EmployeeReimbursement__r.Total_Monthly_Approved_Variable__c,Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Mileage__c,EmployeeReimbursement__r.Total_Rejected__c,Notes__c,TimeZone__c,EmployeeReimbursement__r.Mileage_Lock_Date__c,ConvertedStartTime__c,ConvertedEndTime__c,Driving_Time__c,Total_Time__c,Tag__c,Activity__c,EmployeeReimbursement__r.Fuel_Variable_Rate__c,Fuel_Variable_Rate__c,High_Risk_Mileage__c  FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Month__c = \''+month+'\' AND EmployeeReimbursement__r.Contact_Id__c =\''+did+'\' order by ConvertedStartTime__c asc';      
        
        List<Employee_Mileage__c> employeeMileageList =  (List<Employee_Mileage__c>)ExecuteQueryUtil.getRecordListFromsObject(query);
        List<String> mileagesList = new List<String>();
        double mileages=0;
        double variableamount=0;
        List<EmployeeMileages> reimbursementList = new List<EmployeeMileages>();
        for(Employee_Mileage__c currentMileage : employeeMileageList) {
            mileages = mileages + (currentMileage.Mileage__c != null ? currentMileage.Mileage__c : 0);
            variableamount = variableamount + (currentMileage.Variable__c != null ? currentMileage.Variable__c : 0);
            reimbursementList.add(WrapperUtils.getMileagesOfReimbursement(currentMileage));
        }
        mileagesList.add(JSON.serialize(reimbursementList));
        mileagesList.add(String.valueOf(mileages));
        mileagesList.add(String.valueOf(variableamount)); 
        if(mileagesList.size() > 0)  {
            return mileagesList;
        } else {
            return mileagesList;
        }
    }
    public static String readFromFileInchunk(String attachmentBody, String attachmentName, String attachmentId,String did,String accid,String contactattachementid) {
        
        if(attachmentBody != null) {
            Attachment insuranceAttachment = getAttachment(attachmentId);
            String newBody = '';
            if(insuranceAttachment.Body != null) {
                newBody = EncodingUtil.base64Encode(insuranceAttachment.Body);
            }
            newBody += attachmentBody;
            
            insuranceAttachment.Body = EncodingUtil.base64Decode(newBody);
            if(attachmentId == null) {
                insuranceAttachment.Name = attachmentName;
                insuranceAttachment.parentId = did;
            }
            
            upsert insuranceAttachment;
            return insuranceAttachment.Id;
        } else {
            return 'Attachment Body was null';
        }
    }
    public static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
    public static String setQueryParameters(List<String> stringlist) {
        String editedquery = '( ';
        for(String currentMonthName : stringlist) {
            editedquery = editedquery + '\''+currentMonthName+ '\',';
        }
        if(editedquery.endsWith(',')) {
            editedquery = editedquery.removeEnd(',');
        }
        editedquery = editedquery+' )';
        return editedquery;
    }
    
    public static String getpastYearReimbursement(String drid) {
        List<String> lastYear = new List<String>();
        for(Integer i=1;i<13;i++) {
            if(i<=system.today().month()) {
                if(i<10) {
                    lastYear.add('0'+i+'-'+String.valueOf((System.today().year())));
                } else {
                    lastYear.add(i+'-'+String.valueOf((System.today().year())));
                }
            }
            if(i<10) {
                lastYear.add('0'+i+'-'+String.valueOf((System.today().year()-1)));
                lastYear.add('0'+i+'-'+String.valueOf((System.today().year()-2)));
            } else {
                lastYear.add(i+'-'+String.valueOf((System.today().year()-1)));
                lastYear.add(i+'-'+String.valueOf((System.today().year()-2)));
            }
        }
        String query ='';
        Set<String> years = new Set<String>();
        List<String> yearsTobeReturned = new List<String>();
        String editedquery = setQueryParameters(lastYear);
        query = 'SELECT id,Year__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+drid+'\' AND Month__c IN '+ editedquery ;
        for(Employee_Reimbursement__c currentReimbursement : (List<Employee_Reimbursement__c>)ExecuteQueryUtil.getRecordListFromsObject(query)) {
            years.add(String.valueOf(currentReimbursement.Year__c));
        }
        if(years.size()>0) {
            yearsTobeReturned.addAll(years);
        }
        return JSON.serialize(yearsTobeReturned);
    }
    
    public static String getLast2Years() {
        List<String> last2Years = new List<String>();
        last2Years.add(String.valueOf(System.today().year()));
        last2Years.add(String.valueOf(System.today().year()-1));
        last2Years.add(String.valueOf(System.today().year()-2));
        return JSON.serialize(last2Years);
    }
    public static String getReimbursementsListClone(String driverid) {
        List<String> monthList = new List<String>();
        if(System.today().month()==12) {
            monthList.add('11-'+System.today().year());
            monthList.add('12-'+System.today().year());
        }
        else if(System.today().month()==11) {
            monthList.add('11-'+System.today().year());
        } else {
            for(Integer i=1;i<=12;i++) {
                if(i<10) {
                    monthList.add('0'+String.valueOf(i)+'-'+String.valueOf(System.today().year()));
                }
                else if(i==10) {
                    monthList.add(String.valueOf(i)+'-'+String.valueOf(System.today().year()));
                } else {
                    monthList.add(String.valueOf(i)+'-'+String.valueOf((System.today().year()-1)));
                }
            }
        }
        String editedquery ='';
        String query = '';
        String status = 'Approved';
        if(monthList.size()>0) {
            editedquery = setQueryParameters(monthList);
        }
        if(String.isNotBlank(editedquery)) {
            query = 'SELECT id,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Monthly_Variable_Amount__c,Total_Monthly_Approved_Variable__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+driverid+'\' AND Status__c != \''+status+'\' AND Total_Pending__c > 0 AND Month__c IN '+ editedquery ;
        } else {
            query = 'SELECT id,Month__c,Total_Variable_Rate__c,Fuel_Price__c,Total_Mileage__c,Fixed_Amount__c,Variable_Rate__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Approved_Date__c,Status__c,Total_Pending__c,Monthly_Variable_Amount__c,Total_Monthly_Approved_Variable__c FROM Employee_Reimbursement__c WHERE Contact_Id__c=\''+driverid+'\' AND Status__c != \''+status+'\''; 
        }
        List<Employee_Reimbursement__c> reimbursementList =  new List<Employee_Reimbursement__c>();
        reimbursementList = (List<Employee_Reimbursement__c>)ExecuteQueryUtil.getRecordListFromsObject(query);
        if(reimbursementList.size()>0) {
            return JSON.serialize(reimbursementList);
        } else {
            return JSON.serialize(0);
        }
    }
    public static String approveReimbursements(String year,String did,String accid,String reimbursements) {
        List<EmployeeReimbursements> reimbursementList = new List<EmployeeReimbursements>();
        List<Employee_Reimbursement__c> employeeReimbursementList = new List<Employee_Reimbursement__c>();
        if(reimbursements!=null) {
            reimbursementList = (List<EmployeeReimbursements>)JSON.deserialize(reimbursements,List<EmployeeReimbursements>.Class);
            for(EmployeeReimbursements obj_current_reimbursment : reimbursementList)  {
                employeeReimbursementList.add(WrapperUtils.approveReimbursementofDriver(obj_current_reimbursment));
            }
            if(employeeReimbursementList.size() > 0)  {
                update employeeReimbursementList;
                return getAllReimbursements(year,did,accid);
            }
        }
        return '';
    }
    // my New methods
    public static string getUnapprovedReimbursements(String contactId, String accountId,boolean showteam,String role) {
        // its replacement of getAllDriversLastMonthUpdatedUnapprovedReimburseClone AND getAllDriversLastMonthUnapprovedReimbursementsClone
        Map<String,EmployeeMileagesForCalculation> employeeReimbursementMap = new Map<String,EmployeeMileagesForCalculation>();
        String currentMonth = Utils.fetchMonths(1, -1)[0];
        List<Employee_Reimbursement__c> employeeReimbursementList = new List<Employee_Reimbursement__c>();
        if(showteam!=null && showteam == true && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
            employeeReimbursementList =[SELECT id, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__r.Accountid, Contact_Id__r.Manager__r.Name, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c,  Total_Approved__c, Total_Mileage__c, Status__c, Total_Variable_Rate__c, Total_Pending__c,High_Risk_Total_Pending__c, Total_Approved_Pending_Mileage__c, Reimbursement_Approval__c,Mileage_Approver__c,Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c,High_Risk_Total_Mileages__c,High_Risk_Total_Rejected__c,High_Risk_Total_Approved__c,Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Email__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c  WHERE Approved_Date__c = null AND Status__c='Pending'  AND Contact_Id__r.Accountid =: accountId AND (Month__c !=: currentMonth OR Contact_Id__r.Deactivated_Date__c = THIS_YEAR) Order by Total_Pending__c desc];
        }
        else if(showteam!=null && showteam == false && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
            employeeReimbursementList =[SELECT id, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__r.Accountid, Contact_Id__c, Contact_Id__r.Manager__r.Name, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c,  Total_Approved__c, Total_Mileage__c, Status__c, Total_Approved_Pending_Mileage__c,High_Risk_Total_Pending__c,  Total_Variable_Rate__c, Total_Pending__c, Reimbursement_Approval__c, Mileage_Approver__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c,High_Risk_Total_Mileages__c,High_Risk_Total_Rejected__c,High_Risk_Total_Approved__c, Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Email__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c  WHERE Approved_Date__c = null  AND Status__c='Pending'  AND Contact_Id__r.Accountid =: accountId AND (Month__c !=: currentMonth OR Contact_Id__r.Deactivated_Date__c = THIS_YEAR) AND ((Contact_Id__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)) Order by Total_Pending__c desc];
        }
        else if(showteam!=null && showteam == true && (role=='Manager' || role=='Driver/Manager')) {
            employeeReimbursementList =[SELECT id, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__r.Accountid,  Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Manager__r.Name, Contact_Id__r.Monthly_Mileage_Limit__c,  Total_Approved__c, Total_Mileage__c, Status__c,Total_Approved_Pending_Mileage__c,High_Risk_Total_Pending__c,  Total_Variable_Rate__c, Total_Pending__c, Reimbursement_Approval__c, Mileage_Approver__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c,High_Risk_Total_Mileages__c,High_Risk_Total_Rejected__c,High_Risk_Total_Approved__c, Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Email__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c  WHERE Approved_Date__c = null  AND Status__c='Pending'  AND Contact_Id__r.Accountid =: accountId AND (Month__c !=: currentMonth OR Contact_Id__r.Deactivated_Date__c = THIS_YEAR) AND ((Contact_Id__r.Manager__c =: contactId)  OR (Contact_Id__r.Manager__r.Manager__c =: contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =: contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: contactId)) Order by Total_Pending__c desc];
        }
        else if(showteam != null && showteam == false && (role == 'Manager' || role =='Driver/Manager')) {
            employeeReimbursementList = [SELECT id, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__r.Accountid,  Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Manager__r.Name, Contact_Id__r.Manager__c, Contact_Id__r.Monthly_Mileage_Limit__c, Total_Approved__c, Total_Mileage__c, Status__c,  Total_Variable_Rate__c, Total_Pending__c, Reimbursement_Approval__c, Mileage_Approver__c,High_Risk_Total_Pending__c,  Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c,High_Risk_Total_Mileages__c,High_Risk_Total_Rejected__c,High_Risk_Total_Approved__c, Contact_Id__r.External_Email__c,Contact_Id__r.Account.Triplog_API__c,Contact_Email__c,Fuel_Price__c, MPG__c, Maintenance_and_Tires__c,Contact_Id__r.Reimbursement_Frequency__c FROM Employee_Reimbursement__c  WHERE Approved_Date__c = null  AND Status__c='Pending' AND (Month__c !=: currentMonth OR Contact_Id__r.Deactivated_Date__c = THIS_YEAR) AND Contact_Id__r.Accountid =: accountId  AND (Contact_Id__r.Manager__c =: contactId) Order by Total_Pending__c desc];
        }
        System.debug('employeeReimbursementList=='+employeeReimbursementList );
        for(Employee_Reimbursement__c currentReimbursement : employeeReimbursementList) {
            EmployeeMileagesForCalculation reimbursement = new EmployeeMileagesForCalculation();
            System.debug('currentReimbursement =='+currentReimbursement );
            if(employeeReimbursementMap.containsKey(currentReimbursement.Contact_Id__c)) {
                if(employeeReimbursementMap.get(currentReimbursement.Contact_Id__c).reimbursementIdList != null && employeeReimbursementMap.get(currentReimbursement.Contact_Id__c).reimbursementIdList.size() > 0) {
                    reimbursement = employeeReimbursementMap.get(currentReimbursement.Contact_Id__c);
                    reimbursement.totalMileages =(currentReimbursement.Total_Pending__c!=null) ? String.valueOf(double.valueOf((reimbursement.totalMileages!=null) ? reimbursement.totalMileages : '0')+double.valueOf(currentReimbursement.Total_Pending__c)):'0';
                    reimbursement.TotalReimMileages =(currentReimbursement.Total_Mileage__c !=null) ? String.valueOf(double.valueOf((reimbursement.TotalReimMileages != null) ? reimbursement.TotalReimMileages : '0')+double.valueOf(currentReimbursement.Total_Mileage__c)):'0';
                    reimbursement.totalHighRiskMileages =(currentReimbursement.High_Risk_Total_Mileages__c != null) ? double.valueOf((reimbursement.totalHighRiskMileages!=null) ? reimbursement.totalHighRiskMileages : 0.00)+double.valueOf(currentReimbursement.High_Risk_Total_Mileages__c):0.00;
                    reimbursement.highRiskTotalApproved =(currentReimbursement.High_Risk_Total_Approved__c != null) ? double.valueOf((reimbursement.highRiskTotalApproved!=null) ? reimbursement.highRiskTotalApproved : 0.00)+double.valueOf(currentReimbursement.High_Risk_Total_Approved__c):0.00;
                    reimbursement.highRiskTotalRejected =(currentReimbursement.High_Risk_Total_Rejected__c != null) ? double.valueOf((reimbursement.highRiskTotalRejected!=null) ? reimbursement.highRiskTotalRejected : 0.00)+double.valueOf(currentReimbursement.High_Risk_Total_Rejected__c):0.00;
                    reimbursement.highRiskTotalPending =(currentReimbursement.High_Risk_Total_Pending__c != null) ? double.valueOf((reimbursement.highRiskTotalPending !=null) ? reimbursement.highRiskTotalPending : 0.00)+double.valueOf(currentReimbursement.High_Risk_Total_Pending__c):0.00;
                    
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
                reimbursement.reimbursementid = currentReimbursement.Id;
                reimbursement.name = currentReimbursement.Contact_Id__r.Name;
                reimbursement.month = currentReimbursement.Month__c;
                reimbursement.threshold = String.valueOf(currentReimbursement.Contact_Id__r.Monthly_Mileage_Limit__c);
                reimbursement.totalMileages = (currentReimbursement.Total_Pending__c!=null) ? String.valueOf(currentReimbursement.Total_Pending__c) : '0';
                reimbursement.TotalReimMileages = (currentReimbursement.Total_Mileage__c !=null) ? String.valueOf(currentReimbursement.Total_Mileage__c) : '0';
                reimbursement.rejectedMileges = (currentReimbursement.Total_Rejected__c != null) ? String.valueOf(currentReimbursement.Total_Rejected__c) : '0';
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
                reimbursement.totalHighRiskMileages  = currentReimbursement.High_Risk_Total_Mileages__c != null ? double.valueOf(currentReimbursement.High_Risk_Total_Mileages__c) : 0.00; 
                reimbursement.highRiskTotalApproved  = currentReimbursement.High_Risk_Total_Approved__c != null ? double.valueOf(currentReimbursement.High_Risk_Total_Approved__c) : 0.00;             
                reimbursement.highRiskTotalRejected  = currentReimbursement.High_Risk_Total_Rejected__c != null ? double.valueOf(currentReimbursement.High_Risk_Total_Rejected__c) : 0.00;  
                reimbursement.highRiskTotalPending = currentReimbursement.High_Risk_Total_Pending__c != null ? double.valueOf(currentReimbursement.High_Risk_Total_Pending__c) : 0.00;                        
                if(currentReimbursement.Mileage_Lock_Date__c != null) {
                if(String.valueOf(currentReimbursement.Mileage_Lock_Date__c).contains('-')) {
                        List<String> approvedDateSplitted = new List<String>();
                        approvedDateSplitted = String.valueOf(currentReimbursement.Mileage_Lock_Date__c).split('-');
                        reimbursement.lockDate = approvedDateSplitted[1]+'/'+approvedDateSplitted[2]+'/'+approvedDateSplitted[0].substring(2,4);
                    }
                } else {
                    reimbursement.lockDate = '';
                }
                reimbursement.maintainsAndTyres  = String.valueOf(currentReimbursement.Maintenance_and_Tires__c);
                reimbursement.contactEmail = currentReimbursement.Contact_Id__r.External_Email__c;
                reimbursement.fuel = String.valueOf(currentReimbursement.Fuel_Price__c);
                reimbursement.mpg = String.valueOf(currentReimbursement.MPG__c);
                reimbursement.accountApi = currentReimbursement.Contact_Id__r.Account.Triplog_API__c;
                reimbursement.reimbursementFrequency = currentReimbursement.Contact_Id__r.Reimbursement_Frequency__c;
                employeeReimbursementMap.put(currentReimbursement.Contact_Id__c,reimbursement);
            }
        }
        System.debug('employeeReimbursementMap=='+employeeReimbursementMap);
        return JSON.serialize((List<EmployeeMileagesForCalculation>)employeeReimbursementMap.values()).unescapeHtml4();
    }
    public static string getLastMonthReimbursements(String contactId, String accountId,boolean showteam,String role) {
        List<EmployeeReimbursementDetailsAdmin> reimbursementList = new List<EmployeeReimbursementDetailsAdmin>();
        Account currentAccount = new Account();
        if(String.isNotBlank(accountId)) {
            currentAccount = [SELECT id,Last_Reimbursement_Created__c FROM Account WHERE ID =: accountId];
        }
        if(currentAccount != null && String.isNotBlank(currentAccount.Last_Reimbursement_Created__c)) {
            List<Employee_Reimbursement__c> employeeReimbursementList = new List<Employee_Reimbursement__c>();
            if(showteam != null && showteam == true && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
                employeeReimbursementList =[SELECT ID, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__c, Contact_Id__r.name, Contact_Id__r.Monthly_Mileage_Limit__c, Contact_Id__r.Manager__r.Name, Total_Approved__c, Total_Mileage__c, Status__c, Reimbursement_Approval__c, Mileage_Approver__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  AND Month__c = :currentAccount.Last_Reimbursement_Created__c AND Contact_Id__r.Deactivated_Date__c = null ];
            }
            else if(showteam!=null && showteam == false && (role=='Admin' || role == StaticValues.roleAdminDriver)) {
                employeeReimbursementList = [SELECT ID, Name, Month__c, Total_Rejected__c, Approved_Date__c, Contact_Id__c, Contact_Id__r.name,  Contact_Id__r.Monthly_Mileage_Limit__c, Contact_Id__r.Manager__r.Name, Total_Approved__c,  Total_Mileage__c, Status__c, Reimbursement_Approval__c,  Mileage_Approver__c, Contact_Id__r.Manager_External_Email__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  AND Month__c = :currentAccount.Last_Reimbursement_Created__c AND Contact_Id__r.Deactivated_Date__c = null  AND ((Contact_Id__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
            } else if(showteam!=null && showteam == true && (role=='Manager' || role=='Driver/Manager')) {
                employeeReimbursementList = [SELECT ID,  Name,  Month__c,  Total_Rejected__c,  Approved_Date__c,  Contact_Id__c,  Contact_Id__r.name,  Contact_Id__r.Monthly_Mileage_Limit__c, Contact_Id__r.Manager__c, Contact_Id__r.Manager__r.Name, Total_Approved__c,  Total_Mileage__c,  Status__c, Reimbursement_Approval__c,                                                                                         Mileage_Approver__c,Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  AND Contact_Id__r.Deactivated_Date__c = null AND Month__c = :currentAccount.Last_Reimbursement_Created__c  AND ((Contact_Id__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId)  OR (Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =:contactId))];
            } else if(showteam != null && showteam == false && (role == 'Manager' || role == 'Driver/Manager')) {
                employeeReimbursementList = [SELECT ID,  Name,  Month__c,  Total_Rejected__c,  Approved_Date__c,  Contact_Id__c,  Contact_Id__r.name,  Contact_Id__r.Monthly_Mileage_Limit__c,  Contact_Id__r.Manager__c, Contact_Id__r.Manager__r.Name, Total_Approved__c,  Total_Mileage__c,  Status__c, Contact_Id__r.Manager__r.External_Email__c,Mileage_Lock_Date__c, Reimbursement_Approval__c, Mileage_Approver__c,Contact_Id__r.Manager_External_Email__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.Accountid = :accountId  AND Contact_Id__r.Deactivated_Date__c = null AND Month__c = :currentAccount.Last_Reimbursement_Created__c  AND (Contact_Id__r.Manager__c =:contactId)];
            }
            for(Employee_Reimbursement__c currentReimbursement : employeeReimbursementList) {
                reimbursementList.add(getEmployeeReimbursementDetails(currentReimbursement));
            }
        }
        return JSON.serialize(reimbursementList).unescapeHtml4();
    }
    public static void updateContactThresholdLimit(String thresholdLimitList) {  
        List<updateThresholdWrapper> employeeDetailList = new List<updateThresholdWrapper>();        
        if(thresholdLimitList != null) {
            employeeDetailList = (List<updateThresholdWrapper>)Json.deserialize(thresholdLimitList,List<updateThresholdWrapper>.class);
        }
        List<Contact> driverList = new List<Contact>();        
        MAP<Id,Contact> accMap = new MAP<Id,Contact>();
        if(employeeDetailList!= null) {
            for(updateThresholdWrapper currentEmployee : employeeDetailList) {
                Contact driver = new Contact();
                if(String.isNotBlank(String.valueOf(currentEmployee.contactid))  && String.isNotBlank(String.valueOf(currentEmployee.threshold))) {
                    driver.id = currentEmployee.contactid; 
                    driver.Monthly_Mileage_Limit__c = Decimal.valueOf(currentEmployee.threshold);  
                    driverList.add(driver);                    
                } else if(String.isNotBlank(String.valueOf(currentEmployee.contactid))) {
                    driver.id = currentEmployee.contactid; 
                    driver.Monthly_Mileage_Limit__c = null;  
                    driverList.add(driver);
                }                
            }
            accMap.putall(driverList);
            if(accmap.size() > 0) {
                update accmap.values();
            }
        }        
    }
    public static Employee_Reimbursement__c approveReimbursement(String currentReimbursementid) {       
        Employee_Reimbursement__c currentReimbursement = new Employee_Reimbursement__c();
        currentReimbursement.id= currentReimbursementid;
        currentReimbursement.Status__c = 'Approved';
        currentReimbursement.Approved_Date__c = system.today();
        return currentReimbursement;
    }
    public static void updateReimbursements(String reimbursements) {    
        if(reimbursements!=null && reimbursements!='') {
            List<String> employeeReimbursementList = new List<String>();
            employeeReimbursementList = (List<String>)Json.deserialize(reimbursements,List<String>.class);
            List<Employee_Reimbursement__c> reimbursementList = new List<Employee_Reimbursement__c>();
            for(String currentReimbursement : employeeReimbursementList) {
                reimbursementList.add(approveReimbursement(currentReimbursement));              
            }
            if(reimbursementList.size() > 0) {
                update reimbursementList;
            }
            }  
    }
    public static String getUnapprovedMileages(String reimbursementDetails) {
        EmployeeMileagesForCalculation reimbursement = new EmployeeMileagesForCalculation();
        if(reimbursementDetails!=null && reimbursementDetails!='') {
            reimbursement = (EmployeeMileagesForCalculation)Json.deserialize(reimbursementDetails,EmployeeMileagesForCalculation.class);
            List<EmployeeMileages> employeeMileagesList = new List<EmployeeMileages>();
            for(Employee_Mileage__c currentMileage : [SELECT id,Name,Trip_Status__c,Trip_Date__c,Approval_Name__c,Trip_Origin__c,Trip_Destination__c,
                                                      Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,TimeZone__c,Tag__c,Original_Origin_Name__c,Original_Destination_Name__c,
                                                      EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Total_Pending__c,Stay_Time__c,
                                                      EmployeeReimbursement__r.Total_Mileage__c,EmployeeReimbursement__r.Contact_Id__c,Driving_Time__c,Total_Time__c,
                                                      CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Mileage_Lock_Date__c,
                                                      Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,Variable_Rate__c,
                                                      Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Variable_Rate__c,ConvertedStartTime__c,ConvertedEndTime__c, 
                                                      EmployeeReimbursement__r.Total_Rejected__c,Notes__c,EmployeeReimbursement__r.Mileage_Lock_Date__c,Activity__c,Fuel_Variable_Rate__c,High_Risk_Mileage__c
                                                      FROM Employee_Mileage__c 
                                                      WHERE 
                                                      Trip_Status__c =: StaticValues.noApprovedYet AND Approved_Date__c = null AND 
                                                      EmployeeReimbursement__c IN : reimbursement.reimbursementIdList order by ConvertedStartTime__c asc]) {
                                                          employeeMileagesList.add(getMileagesOfReimbursement(currentMileage));
                                                      }
            reimbursement.mileagesList = employeeMileagesList;            
        }
        return JSON.serialize(reimbursement).unescapeHtml4();
    }
    //method is use fOR fatch mileages FROM triplog 
    //AI-000429
    public static String TripCallout(Id driverId, String month, String year, String fuel, String maintTyre, Id empReID,String mpg,String status){
        System.debug('driverID'+ driverId);
        System.debug('month'+ month);
        System.debug('year'+ year);
        System.debug('fuel'+ fuel);
        System.debug('maintTyre'+ maintTyre);
        System.debug('empReID'+ empReID);
        System.debug('status'+ status);

        String result = 'Something wrong while fetching driver information.';
        List<contact> objCurrentcontact = new List<contact>();
        objCurrentcontact = [SELECT id, Email, Account.Triplog_API__c,Biweek_Reimbursement__c,Reimbursement_Frequency__c 
                                FROM Contact 
                                WHERE id =: driverId];
        
        Map<String,String> monthNumberMap = new Map<String,String>{'January' => '01','February' => '02', 'March' => '03', 'April' => '04', 'May' => '05',
            'June' => '06', 'July' => '07', 'August' => '08', 'September' => '09', 'October' => '10',
            'November' => '11', 'December' => '12'};
                
                String priMin =  year+'-'+monthNumberMap.get(month) + '-1';    
                String priMax = String.valueOf(Date.valueOf(priMin).addDays(date.daysInMonth(Integer.valueOf(year), Integer.valueOf(monthNumberMap.get(month))) - 1));
        
        String apiToken = objCurrentcontact[0].Account.Triplog_API__c ;
        //Boolean checkBiWeek = objCurrentcontact[0].Biweek_Reimbursement__c;
        Boolean checkBiWeek = objCurrentcontact[0].Reimbursement_Frequency__c != null && objCurrentcontact[0].Reimbursement_Frequency__c == 'Monthly Reimbursement' ? false : true;
        if(apiToken != null && !Test.isRunningTest() ){
            result = GetTripCallout.GetTripCalloutForMileage(empReID, objCurrentcontact[0].Email,objCurrentcontact[0].id,priMin,priMax,fuel,mpg,maintTyre,apiToken,status,false,checkBiWeek,null);
        }
        return result;
    }
    
    //method is use fOR change reimbursement status 
    //AI-000429
    public static string UpdateReimbursementStatus(Id empReID){
        system.debug('ReimId---'+ empReID);
        if(empReID != null) {
            system.debug('Inside If condition ');
            List<Employee_Reimbursement__c> reimbursementList = new List<Employee_Reimbursement__c>();
            for(Employee_Reimbursement__c reimbsement : [SELECT id,Status__c, Approved_Date__c 
                                                         FROM Employee_Reimbursement__c 
                                                         WHERE id =: empReID ]){
                                                             if(reimbsement.Status__c != 'Pending'){
                                                                 reimbsement.Status__c = 'Pending';
                                                                 reimbsement.Approved_Date__c = null;
                                                                 reimbursementList.add(reimbsement);
                                                             }
                                                         }
            if(!reimbursementList.isEmpty()){
                update reimbursementList;
            }
            
            List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
            for(Employee_Mileage__c mileage : [SELECT id,Trip_Status__c,Trip_Id__c,High_Risk_Mileage__c 
                                               FROM Employee_Mileage__c 
                                               WHERE EmployeeReimbursement__c =: empReID 
                                               AND Trip_Status__c = 'Not Approved Yet' AND Trip_Id__c != null]){
                                                   mileageList.add(mileage);
                                               }
            if(!mileageList.isEmpty()){
                delete mileageList;
            }
            return 'Success';
        }else{
            return null;
        }
    }
    
    //AI-000426
    @AuraEnabled
    @future
    public static void updateLockDate(String accountId,String contactID){        
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        if(accountId != null){
            Account acc = [SELECT Id, Trip_Status_Lock__c FROM Account WHERE Id =: accountId];
            acc.Trip_Status_Lock__c = System.today();
            if(acc != null){
                update acc;
            
            }
            List<Employee_Reimbursement__c> reimbursementList = new List<Employee_Reimbursement__c>();
            for(Employee_Reimbursement__c objReimb : [SELECT ID,Mileage_Lock_Date__c,Reimbursement_Lock_Time__c,Status__c,Approved_Date__c  FROM Employee_Reimbursement__c  WHERE Contact_Id__r.AccountId =: accountId  AND Contact_Id__r.Deactivated_Date__c = null AND Month__c =: lastMonth]){
                                                        //   objReimb.Status__c = 'Approved';
                                                        //   objReimb.Approved_Date__c = System.today();
                                                          objReimb.Mileage_Lock_Date__c = System.today();
                                                          objReimb.Reimbursement_Lock_Time__c = DateTime.now();
                                                          reimbursementList.add(objReimb);
                                                      }
            List<Report_Accessibility__c> reportList = new List<Report_Accessibility__c>();
            for(Report_Accessibility__c objReport : [SELECT id,Name,Mileage_Lock_Date__c FROM Report_Accessibility__c WHERE Custom_Report__r.Show_Lock_Date__c =true AND User__r.Contact.AccountId =: accountId]){
                                                         objReport.Mileage_Lock_Date__c = String.valueof(System.today());
                                                         reportList.add(objReport);
                                                     }
            
            List<Employee_Mileage__c> mileageUpdatelist = new List<Employee_Mileage__c>();
            for(Employee_Mileage__c empmilege : [SELECT id, Trip_Status__c, EmployeeReimbursement__c, Approved_Date__c FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accountId  AND EmployeeReimbursement__r.Month__c =: lastMonth AND Trip_Status__c ='Not Approved Yet' ]) {
                empmilege.Approved_Date__c = System.today();
                empmilege.Trip_Status__c = 'Approved';
                empmilege.Trip_Approval_Time__c = System.now();
                mileageUpdatelist.add(empmilege);
            }
            if(!mileageUpdatelist.isEmpty()) {
                update mileageUpdatelist;    
            }
            if(!reimbursementList.isEmpty() ){
                update reimbursementList;
            }
            
            if(!reportList.isEmpty() ){
                update reportList;
            }
        }
    }
    @AuraEnabled
    public static string ReportUnlock(String accId){
        try {
            Account acc =[SELECT id,Trip_Status_Lock__c FROM Account WHERE Id =: accId];
            acc.Trip_Status_Lock__c = null;
            if(acc != null){
                update acc;
            }
            
            String lastMonth = Utils.fetchMonths(1, 0)[0];            
            List<Employee_Reimbursement__c> reimlist = new List<Employee_Reimbursement__c>();
            for(Employee_Reimbursement__c reimbursement : [SELECT id,Mileage_Lock_Date__c,Reimbursement_Lock_Time__c,name FROM Employee_Reimbursement__c WHERE Month__c =: lastMonth AND Contact_Id__r.AccountId =: accId]){                
                reimbursement .Mileage_Lock_Date__c=null;
                reimbursement .Reimbursement_Lock_Time__c=null;
                reimlist.add(reimbursement );
            }
            if(reimlist.size() > 0 ){
                Update reimlist;
            }
            
            List<Report_Accessibility__c> reportlist = new List<Report_Accessibility__c> ();
            for(Report_Accessibility__c Report: [SELECT id,Name,Mileage_Lock_Date__c FROM Report_Accessibility__c WHERE Custom_Report__r.Show_Lock_Date__c =true AND User__r.Contact.AccountId =: accId]){
                Report.Mileage_Lock_Date__c = null;
                reportlist.add(Report);
            }
            if(reportlist.size() > 0 ){
                Update reportlist;
            }
            update reportlist;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            return 'Failure';
        }
    }
}