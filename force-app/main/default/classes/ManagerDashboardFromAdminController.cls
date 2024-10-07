public class ManagerDashboardFromAdminController 
{
    public static String totalmileages{get;set;}
    public static String totalvariableamount{get;set;}
    public static String nameofEmployee{get;set;}
    public static Boolean showTeamRecord{get;set;}
    public static String emailofEmployee{get;set;}
    public ManagerDashboardFromAdminController() 
    {
        
    }
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
        if(ApexPages.currentPage().getParameters().containsKey('id') && String.isNotEmpty(ApexPages.currentPage().getParameters().get('id')))
        {
           return ApexPages.currentPage().getParameters().get('id');
        }
        else
        {
            return '';
        } 
    }
    public static String getContactid()
    {
        if(ApexPages.currentPage().getParameters().containsKey('managerid') && String.isNotEmpty(ApexPages.currentPage().getParameters().get('managerid')))
        {
           return ApexPages.currentPage().getParameters().get('managerid');
        }
        else
        {
            return '';
        } 
    }
    public static String getShowTeam() {
        if (ApexPages.currentPage().getParameters().containsKey('showteam') && String.isNotBlank(ApexPages.currentPage().getParameters().get('showteam'))) {
            return ApexPages.currentPage().getParameters().get('showteam');
        } else {
            return '';
        }
    }
    public static PageReference getRedirected() {
        if (getContactid() != '' && getAccountid() != '' && getAdminid()!= '') {
            setEmployeeName(); // sets the Name of the Employee name and Show team record Values according to Database.
            return null;
        } else {
            // redirect to error page
            return null;
        }
    }
    public static string getChartData()
    {        
        return WrapperUtils.getChartData(getContactid(),boolean.valueOf(getShowTeam()),getAccountid(),'Manager');
    }    
    public static void setEmployeeName() {
        Contact employee= [SELECT Id, Name, showTeamRecord__c, External_Email__c FROM Contact WHERE Id =: getContactid()];
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
    public static string getAllDriversLastMonthReimbursements()
    {        
         //return String.escapeSingleQuotes(getLastMonthReimbursements(getContactid(),getAccountid(),boolean.valueOf(getShowTeam()),'Manager')); 
         return String.escapeSingleQuotes(getAllDriversLastMonthUpdatedReimbursements(getContactid(),getAccountid(),getShowTeam()));      
    }
    @RemoteAction
    public static string getAllDriversLastMonthUpdatedReimbursements(String managerid, String accid,String showTeamRecord) {
       // System.debug('**BiWeeklyWrapperUtils.checkBiweekAccount(accid)**'+BiWeeklyWrapperUtils.checkBiweekAccount(accid));
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getLastMonthReimbursements(managerid,accid,boolean.valueOf(showTeamRecord),'Manager'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getLastMonthReimbursements(managerid,accid,boolean.valueOf(showTeamRecord),'Manager'));
        }
    }
   /* public static string getAllDriversLastMonthUnapprovedReimbursements()
    {        
        return WrapperUtils.getLastMonthReimbursements(getContactid(),getAccountid(),boolean.valueOf(getShowTeam()),'Manager');
    } */
    /*public static string getAllDriversLastMonthUpdatedUnapprovedReimbursements(String managerid,String accid)
    {        
        List<EmployeeReimbursementDetailsAdmin> employeeReimbursementList = new List<EmployeeReimbursementDetailsAdmin>();
        double mileages=0;
        double variableamount=0;
        for(Employee_Reimbursement__c currentReimbursement:[Select ID,Name,Month__c,Approved_Date__c,Contact_Id__c,Contact_Id__r.name,Contact_Id__r.Monthly_Mileage_Limit__c,Total_Approved__c,Total_Mileage__c,Status__c,Total_Variable_Rate__c,Total_Pending__c from Employee_Reimbursement__c where Contact_Id__r.Accountid =:accid and Month__c=:WrapperUtils.getLastMonthValue(-1) and Status__c='Pending' and Approved_Date__c=null and (Contact_Id__r.Manager__c =: managerid or Contact_Id__r.Manager__r.Manager__c =: managerid OR  Contact_Id__r.Manager__r.Manager__r.Manager__c =: managerid OR Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerid)])
        {
            mileages = mileages+currentReimbursement.Total_Mileage__c;
            variableamount = variableamount +currentReimbursement.Total_Variable_Rate__c;
            employeeReimbursementList.add(WrapperUtils.getEmployeeReimbursementDetails(currentReimbursement));          
        }
        totalmileages = String.valueOf(mileages);
        totalvariableamount = String.valueOf(variableamount);
        return String.escapeSingleQuotes(JSON.serialize(employeeReimbursementList));
    }*/
    public static string getAllDriversLastMonthUnapprovedReimbursementsclone()
    {       
       // return getAllDriversLastMonthUpdatedUnapprovedReimburseClone(getContactid(),getAccountid(),getShowTeam());
        if(BiWeeklyWrapperUtils.checkBiweekAccount(getAccountid()) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(getContactid(),getAccountid(),boolean.valueOf(getShowTeam()),'Manager'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(getContactid(),getAccountid(),boolean.valueOf(getShowTeam()),'Manager'));
        } 
    }
    
    public static string getAllDriversLastMonthUpdatedUnapprovedReimburseClone(String did, String accid,String showTeamRecord) {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Manager'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Manager'));
        } 
    }
    @RemoteAction
    public static string getAllDriversLastMonthUpdatedUnapprovedReimburseClone1(String did, String accid,string showTeamRecord) 
    {
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accid) == true){
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Manager'));
        } else {
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedReimbursements(did,accid,boolean.valueOf(showTeamRecord),'Manager'));
        }
    }
     @RemoteAction
    public static AsyncApexJob approveReimbursements(String reimbursements,String did,String accid,String showTeamRecord)
    {      
        //updatedlist.add(getAllDriversLastMonthUpdatedReimbursements(managerid,accid,showTeamRecord));
        //updatedlist.add(getAllDriversLastMonthUpdatedUnapprovedReimburseclone(managerid,accid,showTeamRecord));              
        ApproveReimBatch tripBtc = new ApproveReimBatch(reimbursements,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
        ID batchprocessid = Database.executeBatch(tripBtc,1);
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                    FROM AsyncApexJob WHERE ID =: batchprocessid ];
        return aaj;
    }
     @RemoteAction
    public static String CheckBatchStatus(ID batchprocessid){
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                    FROM AsyncApexJob WHERE ID =: batchprocessid ];
        if(aaj.Status == 'Failed'){
            return aaj.Status+'='+aaj.ExtendedStatus; 
        }
        return aaj.Status;
    }
    @RemoteAction
    public static List<String> UpdatedReimList(String did,String accid,String showTeamRecord){
        List<String> updatedlist = new List<String>();
        updatedlist.add(getAllDriversLastMonthUpdatedReimbursements(did,accid,String.valueOf(showTeamRecord)));
        updatedlist.add(getAllDriversLastMonthUpdatedUnapprovedReimburseClone(did,accid,String.valueOf(showTeamRecord)));
        return updatedlist;
    }

    @RemoteAction
    public static AsyncApexJob approveMileagesClone(String mileages, String did, String accid,String showTeamRecord)
    {
        AsyncApexJob aaj;
        if(mileages!=null)
        {
            // WrapperUtils.approveMileagesClone1(mileages);
            //  updatedlist.add(getAllDriversLastMonthUpdatedReimbursements(did,accid,showTeamRecord));
            //  updatedlist.add(getAllDriversLastMonthUpdatedUnapprovedReimburseClone(did,accid,showTeamRecord));
             ApproveReimBatch tripBtc = new ApproveReimBatch(mileages,BiWeeklyWrapperUtils.checkBiweekAccount(accid));
             ID batchprocessid = Database.executeBatch(tripBtc,1);
             aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                     FROM AsyncApexJob WHERE ID =: batchprocessid ];
        }       
        return aaj;
    }
    @RemoteAction
    public static String approveMileages(String checked,String selected,String unapprove,String name,String emailaddress)
    {        
        return WrapperUtils.approveMileagesForAdminDash(checked,selected,unapprove,name,emailaddress);
    }

    @RemoteAction
    public static String getUnapprovedMileages(String reimbursementDetails,String accountId)
    {
        system.debug('accountId=='+ accountId);
        system.debug('reimbursementDetails=='+ reimbursementDetails);
        /*double mileages=0;
        double variableamount=0;
        totalmileages =''; 
        totalvariableamount=''; 
        List<EmployeeMileages> employeeReimbursementList = new List<EmployeeMileages>();
        List<Employee_Mileage__c> employeeMileageList = new List<Employee_Mileage__c>();
        if(unapprovemileagesList != null && unapprovemileagesList != '')
        {
            employeeMileageList = (List<Employee_Mileage__c>)JSON.deserialize(unapprovemileagesList,List<Employee_Mileage__c>.class);    
            for(Employee_Mileage__c currentMileage : employeeMileageList)
            {
                mileages = mileages+currentMileage.Mileage__c;
                variableamount = variableamount +currentMileage.Variable__c;
                employeeReimbursementList.add(WrapperUtils.getMileagesOfReimbursement(currentMileage));
            }
        }
        else
        {
            for(Employee_Mileage__c currentMileage:[Select id,Name,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Mileage__c,Variable__c,Trip_Status__c,Approved_Date__c,EmployeeReimbursement__c,EmployeeReimbursement__r.month__c,EmployeeReimbursement__r.Contact_Id__c,CreatedDate,Rejected__c,EmployeeReimbursement__r.Total_Pending__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Day_Of_Week__c,Destination_Name__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,Maintenance_and_Tires__c,Fuel_price__c,EmployeeReimbursement__r.Total_Variable_Rate__c FROM Employee_Mileage__c WHERE ((Trip_Status__c =:StaticValues.noApprovedYet) and Approved_Date__c = null) AND EmployeeReimbursement__r.Contact_Id__c =:did])
            {
                mileages = mileages+currentMileage.Mileage__c;
                variableamount = variableamount +currentMileage.Variable__c;
                employeeReimbursementList.add(WrapperUtils.getMileagesOfReimbursement(currentMileage));
            }   
        }
        System.debug(JSON.serialize(employeeReimbursementList).unescapeHtml4());*/
   
        
        if(BiWeeklyWrapperUtils.checkBiweekAccount(accountId) == true){
            //system.debug('BiWeeklyWrapperUtils.checkBiweekAccount(accountId)=='+ BiWeeklyWrapperUtils.checkBiweekAccount(accountId));
            //system.debug('reimbursementDetails=='+ String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedMileages(reimbursementDetails)));
            return String.escapeSingleQuotes(BiWeeklyWrapperUtils.getUnapprovedMileages(reimbursementDetails));
        } else{
            return String.escapeSingleQuotes(WrapperUtils.getUnapprovedMileages(reimbursementDetails));
        }
    }
}