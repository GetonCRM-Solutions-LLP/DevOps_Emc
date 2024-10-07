Public with sharing class AdminDashboardController {

    Public static String query;
    Public static String totalmileages{get;set;}
    Public static String nameofEmployee{get;set;}
    Public static String emailofEmployee{get;set;}
    Public static boolean insurancePage {get; set;}
    Public static Boolean showTeamRecord{get;set;}
    Public static String totalvariableamount{get;set;}
   
    Public AdminDashboardController() {
        UpdateTimezonAppVer(getAccountid()); 
    }
    Public static String getAccountid() {
        if (ApexPages.currentPage().getParameters().containsKey('accid') && String.isNotBlank(ApexPages.currentPage().getParameters().get('accid'))) {
            return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        }
    }
    Public static String getContactid() {
        if (ApexPages.currentPage().getParameters().containsKey('id') && String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
            return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        }
    }
    Public static String getShowTeam() {
        if (ApexPages.currentPage().getParameters().containsKey('showteam') && String.isNotBlank(ApexPages.currentPage().getParameters().get('showteam'))) {
            return ApexPages.currentPage().getParameters().get('showteam');
        } else {
            return '';
        }
    }
    Public static PageReference getRedirected() {
        if (getContactid() != '' && getAccountid() != '' && getShowTeam() != '') {
            showTeamRecord = boolean.valueOf(getShowTeam());            
            setEmployeeName(); // sets the Name of the Employee name and Show team record Values according to Database.
            return null;
        } else {
            // redirect to error page
            return null;
        }
    }
    Public static string getChartData() {
        System.debug('AdmindashgetChartData');
        return WrapperUtils.getChartData(getContactid(),boolean.valueOf(getShowTeam()),getAccountid(),'Admin');
    }
    
    @AuraEnabled
    Public static void setEmployeeName() {
        Contact employee= [SELECT Id, Name, showTeamRecord__c, External_Email__c,Insurance_Attachment_Id__c 
                            FROM Contact 
                            WHERE id =: getContactid()];
        if(employee!=null) {
            emailofEmployee = employee.External_Email__c;
            nameofEmployee= String.escapeSingleQuotes(employee.Name); // Name of the Employee
            if(employee.Insurance_Attachment_Id__c != null) {
                insurancePage = true;
            }            
        } else {
            nameofEmployee=''; 
            emailofEmployee ='';           
        }       
    }
    Public static string getAllDriversLastMonthReimbursements() {    
        return String.escapeSingleQuotes(getAllDriversLastMonthUpdatedReimbursements(getContactid(),getAccountid(),getShowTeam()));        
    }    
    Public static string getAllDriversLastMonthUnapprovedReimbursementsClone() {        
        if(BiWeeklyWrapperUtils.checkBiweekAccount(getAccountid()) == true) {
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(getContactid(),getAccountid(),boolean.valueOf(getShowTeam()),'Admin'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(getContactid(),getAccountid(),boolean.valueOf(getShowTeam()),'Admin'));
        }
    }    
    @RemoteAction
    Public static string getAllDriversLastMonthUpdatedReimbursements(String did, String accid,String showTeamRecord) {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true) {
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getLastMonthReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Admin'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getLastMonthReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Admin'));
        }
    }    
    Public static string getAllDriversLastMonthUpdatedUnapprovedReimburseClone(String did, String accid,boolean showTeamRecord) {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true) {
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(did,accid,showTeamRecord,'Admin'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(did,accid,showTeamRecord,'Admin'));
        }
    }
    @RemoteAction
    Public static string getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(String did, String accid,string showTeamRecord) {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true) {
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Admin'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Admin'));
        }
    }
    @RemoteAction
    Public static AsyncApexJob approveReimbursements(String reimbursements,String did,String accid,String showTeamRecord,String updateThreshold) {
        List<String> updatedlist = new List<String>();
        if(updateThreshold!=null && String.isNotBlank(updateThreshold)) {            
            WrapperUtils.updateContactThresholdLimit(updateThreshold);
        }
        ApproveReimBatch tripBtc = new ApproveReimBatch(reimbursements,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
        ID batchprocessid = Database.executeBatch(tripBtc,1);
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                FROM AsyncApexJob 
                                WHERE ID =: batchprocessid ];

        return aaj;
    }
    @RemoteAction
    Public static string CheckBatchStatus(ID batchProcessId) {
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                FROM AsyncApexJob 
                                WHERE ID =: batchprocessid ];
        if(aaj.Status == 'Failed') {
            return aaj.Status+'='+aaj.ExtendedStatus; 
        }
        return aaj.Status;
    }
    @RemoteAction
    Public static List<String> UpdatedReimList(String did,String accid,String showTeamRecord) {
        List<String> updatedlist = new List<String>();
        updatedlist.add(getAllDriversLastMonthUpdatedReimbursements(did,accid,showTeamRecord));
        updatedlist.add(getAllDriversLastMonthUpdatedUnapprovedReimburseClone(did,accid,boolean.valueOf(showTeamRecord)));
        return updatedlist;
    }

    @RemoteAction
    Public static AsyncApexJob approveMileagesClone(String mileages, String did, String accid,String showTeamRecord) {
        List<String> updatedlist = new List<String>();
        AsyncApexJob aaj;
        if(mileages!=null) {
            ApproveReimBatch tripBtc = new ApproveReimBatch(mileages,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
            ID batchprocessid = Database.executeBatch(tripBtc,1);
            aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                        FROM AsyncApexJob 
                        WHERE ID =: batchprocessid ];
        }       
        return aaj;
    }
    @RemoteAction
    Public static void invokeSendEmailForAdmin(String reimbursements) {
            List<String> dataList =(List<String>)(JSON.deserialize(reimbursements,List<String>.class));
           }

    @RemoteAction
    Public static String approveMileages(String checked,String selected,String unapprove,String name,String emailaddress) {                          
        return WrapperUtils.approveMileagesForAdminDash(checked,selected,unapprove,name,emailaddress);  
    }
    @RemoteAction
    Public static String getUnapprovedMileages(String reimbursementDetails,String accountId) { // Please change the method body,UI Dev require to pass the several parameters
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accountId) == true) {
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedMileages(reimbursementDetails));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedMileages(reimbursementDetails));
        }
    }
    @RemoteAction
    Public static String getManager(String did, String accid) {
        List<Contact> adminContact = new List<Contact>();
        if(accid == '0013r00002D3DlPAAV') {
            //This is for Anton Paar account
            adminContact = [SELECT id, Name, Email, Accountid FROM Contact WHERE Accountid =: accid AND (Deactivated_Date__c = null OR Deactivated_Date__c > TODAY) AND (Role__c='Manager' OR Role__c='Driver/Manager' OR Role__c = 'Admin')];
        } else {
            adminContact = [SELECT id, Name, Email, Accountid FROM Contact WHERE Accountid =: accid AND (Deactivated_Date__c = null OR Deactivated_Date__c > TODAY) AND (Role__c='Manager' OR Role__c='Driver/Manager')];
        }
        return String.escapeSingleQuotes(JSON.serialize(adminContact));
    }    
    @AuraEnabled
    Public static AsyncApexJob approveMileagesCloneLWC(String mileages, String did, String accid,String showTeamRecord) {
        List<String> updatedlist = new List<String>();
        AsyncApexJob aaj;
        if(mileages!=null) {
            ApproveReimBatch tripBtc = new ApproveReimBatch(mileages,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
            ID batchprocessid = Database.executeBatch(tripBtc,1);
            aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                        FROM AsyncApexJob 
                        WHERE ID =: batchprocessid ];
        }       
        return aaj;
    }

    @AuraEnabled
    Public static AsyncApexJob approveReimbursementsLWC(String reimbursements,String did,String accid,String showTeamRecord,String updateThreshold) {
        List<String> updatedlist = new List<String>();
        if(updateThreshold!=null && String.isNotBlank(updateThreshold)) {            
            WrapperUtils.updateContactThresholdLimit(updateThreshold);
        }
        ApproveReimBatch tripBtc = new ApproveReimBatch(reimbursements,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
        ID batchprocessid = Database.executeBatch(tripBtc,1);
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                FROM AsyncApexJob 
                                WHERE ID =: batchprocessid ];
        return aaj;
    }
    @AuraEnabled
    Public static String CheckBatchStatusLWC(String batchprocessid) {
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                FROM AsyncApexJob 
                                WHERE ID =: batchprocessid ];
        if(aaj.Status == 'Failed') {
            return aaj.Status+'='+aaj.ExtendedStatus; 
        }
        return aaj.Status;
    }
    @AuraEnabled
    Public static List<String> UpdatedReimListLWC(String did,String accid,String showTeamRecord) {
        List<String> updatedlist = new List<String>();
        updatedlist.add(getAllDriversLastMonthUpdatedReimbursements(did,accid,showTeamRecord));
        updatedlist.add(getAllDriversLastMonthUpdatedUnapprovedReimburseClone(did,accid,boolean.valueOf(showTeamRecord)));
        return updatedlist;
    }
    Public static void UpdateTimezonAppVer(String accid) {
        UpdateUserIdandAppVertionBatch bcn = new UpdateUserIdandAppVertionBatch(accid);
        ID batchprocessid = Database.executeBatch(bcn,200);
    }
}