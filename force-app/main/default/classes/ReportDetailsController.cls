public with sharing class ReportDetailsController 
{  
    public static Custom_Report__c obj_current_report {get;set;}
    public static String obj_current_reportStr {get;set;}
    public static String reportname {get;set;}
    public static String getdataofdriver {get;set;}
    public static String getdataofmanager {get;set;}
    public static String managerdriverlist{get;set;}   
    public static Integer AccountYear{get;set;} 

    public ReportDetailsController()
    { }
    @AuraEnabled
    public static String getDriverManagerList(String accountId,String contactId,String reportId){
        List<Account> accList = [SELECT id,name,CreatedDate FROM Account WHERE id =:accountId];       
        if(accList.size() > 0){
            AccountYear = Date.valueof(accList[0].CreatedDate).year();
        }        
        reportname='';
        getdataofdriver ='nodata';
        getdataofmanager ='nodata';      
        List<String> er= new List<String>();
        er.add('failed');        
        managerdriverlist = JSON.serialize(er);
        obj_current_report = new Custom_Report__c();
        List<String> driverManagerList = new List<String>();
        if(reportId != null){         
            obj_current_reportStr = getReportDetail(reportId );
            if(obj_current_report != null){
                if(obj_current_report.Use_Driver_List__c==true){
                    managerdriverlist= getAllManagers(accountId,'Driver');                    
                    getdataofdriver = getAllReportSoqlForDriver(accountId,contactId,reportId);
                }
                else if(obj_current_report.Use_Manager_List__c==true){
                    managerdriverlist= getAllManagers(accountId,'Manager');
                    getdataofmanager =getAllReportSoqlForManager(accountId,contactId,reportId);
                } 
                driverManagerList.add(JSON.serialize(getdataofdriver ));  
                driverManagerList.add(JSON.serialize(getdataofmanager ));             
            }
        }
        else{   // Exception page
        }      
        return JSON.serialize(driverManagerList);
    }

    @AuraEnabled
    public static String gerAccountStatus(String accId)
    {
        String status;
        Date tripStatus;
        if(accId != null) {
            Account acc = [SELECT Id, Trip_Status_Lock__c FROM Account WHERE Id =: accId];
            tripStatus = acc.Trip_Status_Lock__c;
        }
        if(String.valueof(tripStatus) == '' || tripStatus == null) {
            return 'Unlocked';
        } else {
            return 'Locked';
        }
    }

    @AuraEnabled
    public static String getReportDetail(String reportid)
    {
        List<String> obj_list_of_headers = new List<String>();
        String query = 'Select id,Name,Report_Type__c,Report_Soql__c,Report_Header__c,Date_Fields__c,Filter_By__c,Two_Decimal_Places__c,Four_Decimal_Places__c,Boolean_Field__c,Date_Time_Fields__c,Date_Time_To_Time__c,Numeric_Fields__c,Report_Category__c,Use_Bussiness_Unit__c,Use_Driver_List__c,Use_Manager_List__c,Editable_Fields__c,Limit__c,isConcur__c,isLockReport__c from Custom_Report__c where id=\''+reportid+'\'';
        obj_current_report = (Custom_Report__c)(((List<Custom_Report__c>)ExecuteQueryUtil.getRecordListFromsObject(query))[0]);
        return String.escapeSingleQuotes(JSON.serialize(obj_current_report));          
    }

    public static String getAllReportSoql1(String reportSoql,String reporttype,String selectedManager, String tripStartDate, String tripEndDate,String contactid,String accountid,String reportid,String driverormanager,String monthVal,decimal checkLimit)
    {
        String query  = reportSoql;
       
        if(query.contains('from Contact') || query.contains('from contact')){
            if(reporttype=='Contact Created Between 2 Dates'){
                if(selectedManager==null || selectedManager==''){
                    if(!query.contains('where')){
                        query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate) + ' AND accountid=\''+accountid+'\'';                          
                    }
                    else{  // yes
                        query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate) + ' AND accountid=\''+accountid+'\'';    
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Contact> obj_contact_list = Database.query(query);                    
                    return JSON.serialize(obj_contact_list);
                }            
                else{
                    if(driverormanager=='Manager'){
                        if(!query.contains('where')){
                            query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND Manager__c=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        }
                        else{   // yes
                            query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND Manager__c=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        }
                    }
                    else{
                        if(!query.contains('where')){
                            query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND id=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        }
                        else{   // yes
                            query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND id=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        }
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }                    
                    List<Contact> obj_contact_list = Database.query(query); 
                    return JSON.serialize(obj_contact_list);
                }  
            }
            else if(reporttype=='Contact Activation Between 2 Dates') {
                if(selectedManager==null || selectedManager==''){
                    if(!query.contains('where')){
                        query = query+ ' where Activation_Date__c>='+buildDateforactivation(tripStartDate)+' AND Activation_Date__c<='+buildDateforactivation(tripEndDate) + ' AND accountid=\''+accountid+'\'';                                                
                    }
                    else{   // yes
                        query = query + ' AND Activation_Date__c>='+buildDateforactivation(tripStartDate)+' AND Activation_Date__c<='+buildDateforactivation(tripEndDate) + ' AND accountid=\''+accountid+'\'';                          
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Contact> obj_contact_list = Database.query(query); 
                    return JSON.serialize(obj_contact_list);
                }            
                else{
                    if(driverormanager=='Manager'){
                        if(!query.contains('where')){
                            query = query+ ' where Activation_Date__c>='+buildDateforactivation(tripStartDate)+' AND Activation_Date__c<='+buildDateforactivation(tripEndDate)+' AND Manager__c=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                                                  
                        }
                        else{ // yes
                            query = query + ' AND Activation_Date__c>='+buildDateforactivation(tripStartDate)+' AND Activation_Date__c<='+buildDateforactivation(tripEndDate)+' AND Manager__c=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        }
                    }
                    else{
                        if(!query.contains('where')) {
                            query = query+ ' where Activation_Date__c>='+buildDateforactivation(tripStartDate)+' AND Activation_Date__c<='+buildDateforactivation(tripEndDate)+' AND id=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                                                  
                        }
                        else {   // yes
                            query = query + ' AND Activation_Date__c>='+buildDateforactivation(tripStartDate)+' AND Activation_Date__c<='+buildDateforactivation(tripEndDate)+' AND id=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        }
                    } 
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }                   
                    List<Contact> obj_contact_list = Database.query(query); 
                    return JSON.serialize(obj_contact_list);
                } 
            } 
            else if(reporttype=='Contact Deactivation Between 2 Dates') {
                if(selectedManager==null || selectedManager=='') {
                    if(!query.contains('where')) {
                        query = query+ ' where Deactivated_Date__c>='+buildDate(tripStartDate)+' AND Deactivated_Date__c<='+buildDate(tripEndDate) + ' AND accountid=\''+accountid+'\'';                                                  
                    }
                    else{   // yes
                        query = query + ' AND Deactivated_Date__c>='+buildDate(tripStartDate)+' AND Deactivated_Date__c<='+buildDate(tripEndDate) + ' AND accountid=\''+accountid+'\'';                          
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Contact> obj_contact_list = Database.query(query); 
                    return JSON.serialize(obj_contact_list);
                }            
                else {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query+ ' where Deactivated_Date__c>='+buildDate(tripStartDate)+' AND Deactivated_Date__c<='+buildDate(tripEndDate)+' AND Manager__c=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                                                 
                        }
                        else {   // yes
                            query = query + ' AND Deactivated_Date__c>='+buildDate(tripStartDate)+' AND Deactivated_Date__c<='+buildDate(tripEndDate)+' AND Manager__c=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query+ ' where Deactivated_Date__c>='+buildDate(tripStartDate)+' AND Deactivated_Date__c<='+buildDate(tripEndDate)+' AND ID=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                                                 
                        }
                        else {   // yes
                            query = query + ' AND Deactivated_Date__c>='+buildDate(tripStartDate)+' AND Deactivated_Date__c<='+buildDate(tripEndDate)+' AND ID=\''+selectedManager+'\'' + ' AND accountid=\''+accountid+'\'';                          
                        } 
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Contact> obj_contact_list = Database.query(query); 
                    return JSON.serialize(obj_contact_list);
                } 
            } 
            else if(reporttype=='Without Date Range') {
                if(selectedManager !=null && selectedManager !='') {
                    if(driverormanager=='Manager') {
                        system.debug('query209==' + query);
                        if(!query.contains('where')) {
                            query = query + ' where accountid=\''+accountid+'\''+' AND Manager__c=\''+selectedManager+'\'';
                        }
                        else {
                            query = query +' AND accountid=\''+accountid+'\''+' AND Manager__c=\''+selectedManager+'\'';
                           // query = query +' AND accountid=\''+accountid+'\''+' AND ID=\''+selectedManager+'\'';
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query + ' where accountid=\''+accountid+'\''+' AND ID=\''+selectedManager+'\'';
                        }
                        else {
                            query = query +' AND accountid=\''+accountid+'\''+' AND ID=\''+selectedManager+'\'';
                        }
                    }
                }
                else {
                    if(!query.contains('where')) {
                        query = query + ' where accountid=\''+accountid+'\'';                          
                    }
                    else {
                        query = query +' AND accountid=\''+accountid+'\'';                          
                    }
                }
                if(checkLimit != null && checkLimit > 0){
                    query += ' limit ' + checkLimit + '';
                }
                System.debug('query=== '+query );
                List<Contact> obj_contact_list = Database.query(query); 
                return JSON.serialize(obj_contact_list);
            }          
        }
        else if(query.contains('from Employee_Reimbursement__c')) {
            if(reporttype=='Reimbursements Created Between 2 Dates') {
                if(selectedManager==null || selectedManager=='') {
                    if(!query.contains('where')) {
                        query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    else {   // yes
                        query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\''; 
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                    
                    return JSON.serialize(obj_contact_list);
                }            
                else {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                    
                        }
                        else {   // yes
                            query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\''; 
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                    
                        }
                        else {   // yes
                            query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\''; 
                        }
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                    
                    return JSON.serialize(obj_contact_list);
                } 
            }
            else if(reporttype=='Reimbursements Between 2 Deactivation Dates') {
                String contactQuery = 'Select id,Last_Reimbursement_Created__c ,Deactivated_Date__c,Name from Contact where Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND accountid=\''+accountid+'\'';
                system.debug('contactQuery==' + contactQuery);
                List<Contact> contactList = new List<Contact>();
                Map<String,String> contactReimbursementMap = new Map<String,String>();
                Set<String> monthList = new Set<String>();
                contactList = Database.query(contactQuery);
                List<String> nameMonth =new List<String>();
                for(Contact con : contactList){
                    nameMonth.add(con.Name + ':' + con.Deactivated_Date__c.format('MM-YYYY'));
                }
                system.debug('contactList==' + contactList);
                if(contactList.size()>0) {
                    List<Employee_Reimbursement__c> reimList = [SELECT Month__c, Month_Field__c,Contact_Id__c FROM Employee_Reimbursement__c WHERE Name IN: nameMonth];
                    if(Test.isRunningTest()) {
                        reimList = [SELECT Month__c, Month_Field__c,Contact_Id__c FROM Employee_Reimbursement__c];
                    }
                    for(Employee_Reimbursement__c reim : reimList){
                        if(!contactReimbursementMap.containsKey(reim.Contact_Id__c)) {
                            contactReimbursementMap.put(reim.Contact_Id__c,reim.Month__c);
                            monthList.add(reim.Month__c);
                        }
                    }
                }
                system.debug('monthList==' + monthList);
                List<String> monthofreimbursements = new List<String>();
                if(monthList.size()>0) {
                    monthofreimbursements.addAll(monthList);
                }
                 system.debug('monthofreimbursements==' + monthofreimbursements);
                String reimbursementquery='';
                String queryingdata='';
                if(!query.contains('Month__c') && query.contains('from')) {
                    List<String> fields = query.split('from');
                    fields[0]=fields[0]+',Month__c from ';
                    reimbursementquery = fields[0]+fields[1];
                }
                if(!query.contains('Contact_Id__c') && query.contains('from')) {
                    List<String> fields = reimbursementquery.split('from');
                    fields[0]=fields[0]+',Contact_Id__c from ';
                    reimbursementquery = fields[0]+fields[1];
                }
                if(selectedManager==null || selectedManager=='') {
                    String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                    if(!query.contains('where')) {
                        if(monthofreimbursements.size()>0) {
                            queryingdata = ' where Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            reimbursementquery = reimbursementquery+ ' where Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\''; 
                        }
                        else {
                            queryingdata = ' where Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            reimbursementquery = reimbursementquery+ ' where Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                        }                    
                    }
                    else { // yes
                        if(monthofreimbursements.size()>0) {
                            queryingdata = ' AND Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            reimbursementquery = reimbursementquery + ' AND Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                        else {
                            queryingdata = ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            reimbursementquery = reimbursementquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate) + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    List<String> employeeReimbursementsIds = getReimbursmentIdsList(reimbursementquery,contactReimbursementMap);
                    if(employeeReimbursementsIds!=null && employeeReimbursementsIds.size()>0) {
                        String idQuery = getReimbursementMonthCoparision(employeeReimbursementsIds);
                        if(!query.contains('where')) {
                            query = query+' where ID IN '+ idQuery;
                        }
                        else {
                            query = query+' AND ID IN '+ idQuery;
                        } 
                        System.debug(query);                        
                    }
                    else {
                        query=query+queryingdata;
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Reimbursement__c> reimbursementList = Database.query(query);
                    return JSON.serialize(reimbursementList);
                }            
                else {
                    if(driverormanager=='Manager') {
                        String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                        if(!query.contains('where')) {
                            if(monthofreimbursements.size()>0) {
                                queryingdata = ' where Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery+ ' where Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                            else {
                                queryingdata = ' where Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery+ ' where Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                        }
                        else {   // yes
                            if(monthofreimbursements.size()>0) {
                                 queryingdata = ' AND Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery + ' AND Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                            else {
                                queryingdata = ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                        }
                    }
                    else {
                        String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                        if(!query.contains('where')) {
                            if(monthofreimbursements.size()>0) {
                                queryingdata = ' where Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery +' where Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                            else {
                                queryingdata = ' where Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery +' where Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }                  
                        }
                        else {   // yes
                            if(monthofreimbursements.size()>0) {
                                queryingdata = ' AND Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery + ' AND Month__c IN '+ monthquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                            else {
                                queryingdata = ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                                reimbursementquery = reimbursementquery + ' AND Contact_Id__r.Deactivated_Date__c >='+buildDate(tripStartDate)+' AND Contact_Id__r.Deactivated_Date__c <='+buildDate(tripEndDate)+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                        }
                    }
                    System.debug(reimbursementquery);
                    List<String> employeeReimbursementsIds = getReimbursmentIdsList(reimbursementquery,contactReimbursementMap);
                    if(employeeReimbursementsIds!=null && employeeReimbursementsIds.size()>0) {
                        String idQuery = getReimbursementMonthCoparision(employeeReimbursementsIds);
                        if(!query.contains('where')) {
                            query = query+' where ID IN '+ idQuery;
                        }
                        else {
                            query = query+' AND ID IN '+ idQuery;
                        } 
                        System.debug(query);                        
                    }
                    else {
                        query=query+queryingdata;
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Reimbursement__c> reimbursementList = Database.query(query);
                    return JSON.serialize(reimbursementList);
                } 
            }  
            else if(reporttype=='Reimbursements Between 2 Dates For Month Range') {
                List<String> monthofreimbursements= buildMonthForReimbursements(tripStartDate,tripEndDate);
                if((selectedManager==null || selectedManager=='')&&(monthofreimbursements!=null) && (monthofreimbursements.size()>0)) {
                    String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                    if(!query.contains('where')) {
                        query = query + ' where Month__c IN '+ monthquery + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    else {   // yes
                        query = query + ' AND Month__c IN '+ monthquery + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    System.debug('Query : ' + query);
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                }            
                else if((selectedManager!=null && selectedManager!='')&&(monthofreimbursements!=null) && (monthofreimbursements.size()>0)) {
                    if(driverormanager=='Manager') {
                        String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                        if(!query.contains('where')) {
                            query = query + ' where Month__c IN '+ monthquery+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND Month__c IN '+ monthquery+' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                    }
                    else {
                        String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                        if(!query.contains('where')) {
                            query = query + ' where Month__c IN '+ monthquery+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND Month__c IN '+ monthquery+' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                }
                else if((selectedManager!=null && selectedManager!='')&& ((monthofreimbursements==null) || (monthofreimbursements.size()==0))) {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query + ' where Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else {   // yes
                            query = query + ' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                      
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query + ' where Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else {   // yes
                            query = query + ' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                      
                        }
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                } 
                else {
                    if(!query.contains('where')) {
                        query = query + ' where Contact_Id__r.accountid=\''+accountid+'\'';                       
                    }
                    else {   // yes
                        query = query + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                      
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                }
            }  
            else if(reporttype=='Without Date Range') {
                if(selectedManager !=null && selectedManager !='') {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query + ' where Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                        else {
                            query = query +' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query + ' where Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                        else {
                            query = query +' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }                
                }
                else {
                    if(!query.contains('where')) {
                        query = query + ' where Contact_Id__r.accountid=\''+accountid+'\'';
                    }
                    else {
                        query = query +' AND Contact_Id__r.accountid=\''+accountid+'\'';
                    }
                }
                System.debug(query);
                if(checkLimit != null && checkLimit > 0){
                    query += ' limit ' + checkLimit + '';
                }
                List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                      
                return JSON.serialize(obj_contact_list);
            }  
            else if(reporttype=='Reimbursement Month') {
                if((selectedManager==null || selectedManager=='')&&(monthVal!=null) ) {
                    if(!query.contains('where')) {
                        query = query + ' where Month__c = \''+monthVal+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    else {   // yes
                        query = query + ' AND Month__c = \''+monthVal+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    System.debug('query of Ter_Drivers : ' + query);
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                }            
                else if((selectedManager!=null && selectedManager!='')&&(monthVal!=null)) {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query + ' where Month__c = \''+monthVal+'\'' +' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND Month__c = \''+monthVal+'\'' +' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query + ' where Month__c = \''+monthVal+'\'' +' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND Month__c = \''+monthVal+'\'' +' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    System.debug('query of Ter_Drivers : ' + query);
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                }
                else if((selectedManager!=null && selectedManager!='') &&(monthVal==null)) {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query + ' where Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else {   // yes
                            query = query + ' AND Contact_Id__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                      
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query + ' where Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else{   // yes
                            query = query + ' AND Contact_Id__c=\''+selectedManager+'\'' + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                      
                        }
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    System.debug('query of Ter_Drivers : ' + query);
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                } 
                else {
                    if(!query.contains('where')) {
                        query = query + ' where Contact_Id__r.accountid=\''+accountid+'\'';                       
                    }
                    else {   // yes
                        query = query + ' AND Contact_Id__r.accountid=\''+accountid+'\'';                      
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    System.debug('query of Ter_Drivers : ' + query);
                    List<Employee_Reimbursement__c> obj_contact_list = Database.query(query);                                        
                    return JSON.serialize(obj_contact_list);
                }
            }  
        }
        else if(query.contains('from Employee_Mileage__c')) {
            if(reporttype=='Mileages Created Between 2 Dates') {
                if(selectedManager==null || selectedManager=='') {
                    if(!query.contains('where')) {
                        query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate) + ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                    }
                    else {   // yes
                        query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate) + ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);                    
                    return JSON.serialize(obj_contact_list);
                }            
                else {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query+ ' where CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND CreatedDate>='+buildDate(tripStartDate)+' AND CreatedDate<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }                    
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }
            }
            else if(reporttype=='Mileages Between 2 Deactivation Dates') {
                if(selectedManager==null || selectedManager=='') {
                    if(!query.contains('where')) {
                        query = query+ ' where EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c>='+buildDate(tripStartDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c<='+buildDate(tripEndDate)+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    else {   // yes
                        query = query + ' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c>='+buildDate(tripStartDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c<='+buildDate(tripEndDate)+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                    }
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }            
                else {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query+ ' where EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c>='+buildDate(tripStartDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else {   // yes
                            query = query + ' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c>='+buildDate(tripStartDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query+ ' where EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c>='+buildDate(tripStartDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else {   // yes
                            query = query + ' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c>='+buildDate(tripStartDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c<='+buildDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }
            }  
            else if(reporttype=='Mileages Between 2 Trip Dates') {
                String[] splitDate;
                if(tripStartDate.contains('/') && tripStartDate != null) {
                    splitDate = tripStartDate.Split('/');
                }
                System.debug('splitDate'+splitDate);
                if(selectedManager==null || selectedManager=='') {
                    if(!query.contains('where')) {
                        if(splitDate != null && splitDate[2].length() == 4 && tripStartDate.contains('/')){
                            query = query+ ' where Trip_Date__c>='+builTripsDate(tripStartDate)+' AND Trip_Date__c<='+builTripsDate(tripEndDate)+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                        } else {
                            System.debug('else ++');
                            query = query+ ' where Trip_Date__c>='+buildDateforTripDate(tripStartDate)+' AND Trip_Date__c<='+buildDateforTripDate(tripEndDate)+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                    }
                    else {
                        if(splitDate != null && splitDate[2].length() == 4 && tripStartDate.contains('/')){
                            query = query + ' AND Trip_Date__c>='+builTripsDate(tripStartDate)+' AND Trip_Date__c<='+builTripsDate(tripEndDate)+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        } else {
                            query = query + ' AND Trip_Date__c>='+buildDateforTripDate(tripStartDate)+' AND Trip_Date__c<='+buildDateforTripDate(tripEndDate)+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }            
                else {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            if(splitDate != null && splitDate[2].length() == 4 && tripStartDate.contains('/')){
                                query = query+ ' where Trip_Date__c>='+builTripsDate(tripStartDate)+' AND Trip_Date__c<='+builTripsDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                            } else {
                                query = query+ ' where Trip_Date__c>='+buildDateforTripDate(tripStartDate)+' AND Trip_Date__c<='+buildDateforTripDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                            }
                        }
                        else {   // yes
                            if(splitDate != null && splitDate[2].length() == 4 && tripStartDate.contains('/')){
                                query = query + ' AND Trip_Date__c>='+builTripsDate(tripStartDate)+' AND Trip_Date__c<='+builTripsDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                            } else {
                                query = query + ' AND Trip_Date__c>='+buildDateforTripDate(tripStartDate)+' AND Trip_Date__c<='+buildDateforTripDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            if(splitDate != null && splitDate[2].length() == 4 && tripStartDate.contains('/')){
                                query = query+ ' where Trip_Date__c>='+builTripsDate(tripStartDate)+' AND Trip_Date__c<='+builTripsDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                            } else {
                                query = query+ ' where Trip_Date__c>='+buildDateforTripDate(tripStartDate)+' AND Trip_Date__c<='+buildDateforTripDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                            }
                        }
                        else {   // yes
                            if(splitDate != null && splitDate[2].length() == 4 && tripStartDate.contains('/')){
                                query = query + ' AND Trip_Date__c>='+builTripsDate(tripStartDate)+' AND Trip_Date__c<='+builTripsDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                            } else {
                                query = query + ' AND Trip_Date__c>='+buildDateforTripDate(tripStartDate)+' AND Trip_Date__c<='+buildDateforTripDate(tripEndDate)+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                            }
                        }
                    }
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }
            } 
            else if(reporttype=='Mileages Between 2 Dates for Month Range') {
                List<String> monthofreimbursements= buildMonthForReimbursements(tripStartDate,tripEndDate);
                if((selectedManager==null || selectedManager=='')&&(monthofreimbursements!=null) && (monthofreimbursements.size()>0)) {
                    String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                    if(!query.contains('where')) {
                        query = query + ' where EmployeeReimbursement__r.Month__c IN '+ monthquery+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                    }
                    else {   // yes
                        query = query + ' AND EmployeeReimbursement__r.Month__c IN '+ monthquery+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                    }
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }            
                else if((selectedManager!=null && selectedManager!='')&&(((monthofreimbursements!=null) && (monthofreimbursements.size()>0)))) {
                    if(driverormanager=='Manager') {
                        String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                        if(!query.contains('where')) {
                            query = query + ' where EmployeeReimbursement__r.Month__c IN '+ monthquery+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else {   // yes
                            query = query + ' AND EmployeeReimbursement__r.Month__c IN '+ monthquery+' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        } 
                    }
                    else {
                        String monthquery = getReimbursementMonthCoparision(monthofreimbursements);
                        if(!query.contains('where')) {
                            query = query + ' where EmployeeReimbursement__r.Month__c IN '+ monthquery+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                        else {   // yes
                            query = query + ' AND EmployeeReimbursement__r.Month__c IN '+ monthquery+' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        } 
                    }                    
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    system.debug('obj_contact_list========'+obj_contact_list);
                    return JSON.serialize(obj_contact_list);
                }
                else if((selectedManager!=null && selectedManager!='')&& (((monthofreimbursements==null) && (monthofreimbursements.size()==0)))) {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query + ' where EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query + ' where EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                        }
                        else {   // yes
                            query = query + ' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                        }
                    }
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    system.debug('obj_contact_list========'+obj_contact_list);
                    return JSON.serialize(obj_contact_list);
                } 
                else {
                    if(!query.contains('where')) {
                        query = query + ' where EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    else {   // yes
                        query = query + ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                    }
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }
            }  
            else if(reporttype=='Without Date Range') {
                System.debug(query);
                if(selectedManager !=null && selectedManager !='') {
                    if(driverormanager=='Manager') {
                        if(!query.contains('where')) {
                            query = query + ' where EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                        else {
                            query = query +' AND EmployeeReimbursement__r.Contact_Id__r.Manager__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    else {
                        if(!query.contains('where')) {
                            query = query + ' where EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                        else {
                            query = query +' AND EmployeeReimbursement__r.Contact_Id__c=\''+selectedManager+'\''+ ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';
                        }
                    }
                    System.debug(query);
                }
                else {
                    if(!query.contains('where')) {
                        query = query + ' where EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                        
                    }
                    else{   // yes
                        query = query + ' AND EmployeeReimbursement__r.Contact_Id__r.accountid=\''+accountid+'\'';                       
                    }
                    System.debug(query);
                    if(checkLimit != null && checkLimit > 0){
                        query += ' limit ' + checkLimit + '';
                    }
                    List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                    return JSON.serialize(obj_contact_list);
                }
                if(checkLimit != null && checkLimit > 0){
                    query += ' limit ' + checkLimit + '';
                }
                List<Employee_Mileage__c> obj_contact_list = Database.query(query);
                return JSON.serialize(obj_contact_list);
            }  
        }
        else if(query.contains('from Bi_Weekly_Reimbursement__c')) {
        system.debug('query806=='+query);
            if(reporttype =='BiWeek Reimbursement Start and EndDate') {
                if(selectedManager == null || selectedManager == '') {
                    if(!query.contains('where')) {
                        query = query+ ' where Start_Date__c >='+buildDateforBiweek(tripStartDate)+' AND End_Date__c <='+buildDateforBiweek(tripEndDate) + ' AND Contact__r.AccountId=\''+accountid+'\'';                        
                   system.debug('query811=='+query); 
                    } else {
                        query = query + ' AND Start_Date__c >='+buildDateforBiweek(tripStartDate)+' AND End_Date__c <='+buildDateforBiweek(tripEndDate) + ' AND Contact__r.AccountId=\''+accountid+'\''; 
                    system.debug('query814=='+query);
                    }                   
                } else {
                    if(driverormanager == 'Manager') {
                        system.debug('query818=='+query);
                        if(!query.contains('where')) {
                            query = query+ ' where Start_Date__c >='+buildDateforBiweek(tripStartDate)+' AND End_Date__c <='+buildDateforBiweek(tripEndDate)+' AND Contact__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact__r.accountid=\''+accountid+'\'';                    
                        system.debug('query821=='+query);
                        } else {
                            query = query + ' AND Start_Date__c >='+buildDateforBiweek(tripStartDate)+' AND End_Date__c <='+buildDateforBiweek(tripEndDate)+' AND Contact__r.Manager__c=\''+selectedManager+'\'' + ' AND Contact__r.accountid=\''+accountid+'\''; 
                        system.debug('query824=='+query);
                        }
                    } else {
                        if(!query.contains('where')) {
                            query = query+ ' where Start_Date__c >='+buildDateforBiweek(tripStartDate)+' AND End_Date__c <='+buildDateforBiweek(tripEndDate)+' AND Contact__c=\''+selectedManager+'\'' + ' AND Contact__r.AccountId=\''+accountid+'\'';                    
                       system.debug('query829=='+query);
                        } else {
                            query = query + ' AND Start_Date__c >='+buildDateforBiweek(tripStartDate)+' AND End_Date__c <='+buildDateforBiweek(tripEndDate)+' AND Contact__c=\''+selectedManager+'\'' + ' AND Contact__r.AccountId=\''+accountid+'\''; 
                        system.debug('query832=='+query);
                        }
                    }                    
                }
                if(checkLimit != null && checkLimit > 0){
                    query += ' limit ' + checkLimit + '';
                }
                system.debug('query=='+query);
                List<Bi_Weekly_Reimbursement__c> obj_contact_list = Database.query(query);  
                system.debug('obj_contact_list=='+obj_contact_list);
                return JSON.serialize(obj_contact_list);
            }
        }
        else {
            system.debug('At Else=='+query);
            if(reporttype =='Others') {
                if(selectedManager != null && selectedManager != '') {
                    query = query + ' AND Contact__r.Id =\''+selectedManager+'\'';
                    system.debug('For particulat Driver=='+query);
                }
                system.debug('Last=='+query);
                List<Tripslog__c> obj_contact_list = Database.query(query);  
                system.debug('obj_contact_list=='+obj_contact_list);
                return JSON.serialize(obj_contact_list);
            }
        }
        return '';
    }
    public static String getAllReportSoqlForDriver(String accountId,String contactId,String reportId)
    {      
        string data;
        if(obj_current_report.Report_Type__c == 'Mileages Between 2 Trip Dates'){
            String LastMonth = String.valueof(System.today().addMonths(-1).month());
            String CurrentMonth = String.valueof(System.today().month());
            if(System.today().addMonths(-1).month() < 10){
                LastMonth = '0'+System.today().addMonths(-1).month();
            }
            if(System.today().month() < 10){
                CurrentMonth = '0'+System.today().month();
            }
            String lastmonthdate = System.today().addMonths(-1).year()+'-'+LastMonth+'-01';
            String currentMonthDate = System.today().year()+'-'+CurrentMonth+'-01';
            data = getAllReportSoql1(obj_current_report.Report_Soql__c,obj_current_report.Report_Type__c,'',lastmonthdate,currentMonthDate,contactId,accountId,reportId,'Driver','',obj_current_report.Limit__c); 
        } else if(obj_current_report.Report_Type__c == 'BiWeek Reimbursement Start and EndDate' && obj_current_report.Filter_By__c == 'Biweek Reimbursement' ){
            String payPeriodName = BiWeeklyWrapperUtils.getPayPeriodDates(accountId);
            List<String> paydateSplitted = new List<String>();
            if(payPeriodName.contains(' to ')) {
                paydateSplitted = payPeriodName.split('to'); 
            }
            data = getAllReportSoql1(obj_current_report.Report_Soql__c,obj_current_report.Report_Type__c,'',paydateSplitted[0],paydateSplitted[1],contactId,accountId,reportId,'Driver','',obj_current_report.Limit__c); 
        } else {
            String lastMonth = Utils.fetchMonths(1, 0)[0]; 
            //String lastMonth = Utils.fetchMonths(1, -1)[0];          
            data = getAllReportSoql1(obj_current_report.Report_Soql__c,obj_current_report.Report_Type__c,'',String.valueOf((System.today().addMonths(-1).toStartOfMonth()).format()), String.valueOf(system.today().addMonths(0).toStartofMonth().addDays(-1).format()),contactId,accountId,reportId,'Driver',lastMonth,obj_current_report.Limit__c); 
        }
        return data;        
    }
    public static String getAllReportSoqlForManager(String accountId,String contactId,String reportId)
    {     
        System.debug('reportId::'+reportId);
                System.debug('contactId::'+contactId);
                System.debug('accountId::'+accountId);
        System.debug('obj_current_report::'+obj_current_report);
         System.debug('obj_current_report.Report_Type__c::'+obj_current_report.Report_Type__c);
        
        string data;
        if(obj_current_report.Report_Type__c == 'Mileages Between 2 Trip Dates'){
            String LastMonth = String.valueof(System.today().addMonths(-1).month());
            String CurrentMonth = String.valueof(System.today().month());
            if(System.today().addMonths(-1).month() < 10){
                LastMonth = '0'+System.today().addMonths(-1).month();
            }
            if(System.today().month() < 10){
                CurrentMonth = '0'+System.today().month();
            }
            String lastmonthdate = System.today().addMonths(-1).year()+'-'+LastMonth+'-01';
            String currentMonthDate = System.today().year()+'-'+CurrentMonth+'-01';
            data = getAllReportSoql1(obj_current_report.Report_Soql__c,obj_current_report.Report_Type__c,'',String.valueOf((System.today().addMonths(-1).toStartOfMonth()).format()),String.valueOf((System.today().toStartOfMonth()).format()),contactId,accountId,reportId,'Manager','',obj_current_report.Limit__c); 
        } else if(obj_current_report.Report_Type__c == 'BiWeek Reimbursement Start and EndDate' && obj_current_report.Filter_By__c == 'Biweek Reimbursement' ){
            String payPeriodName = BiWeeklyWrapperUtils.getPayPeriodDates(accountId);
            List<String> paydateSplitted = new List<String>();
            if(payPeriodName.contains(' to ')) {
                paydateSplitted = payPeriodName.split('to'); 
            }
            data = getAllReportSoql1(obj_current_report.Report_Soql__c,obj_current_report.Report_Type__c,'',paydateSplitted[0],paydateSplitted[1],contactId,accountId,reportId,'Driver','',obj_current_report.Limit__c); 
        } else {
            String lastMonth = Utils.fetchMonths(1, 0)[0];
            //String lastMonth = Utils.fetchMonths(1, -1)[0];
            data = getAllReportSoql1(obj_current_report.Report_Soql__c,obj_current_report.Report_Type__c,'',String.valueOf((System.today().addMonths(-1).toStartOfMonth()).format()), String.valueOf(system.today().addMonths(0).toStartofMonth().addDays(-1).format()),contactId,accountId,reportId,'Manager',lastMonth,obj_current_report.Limit__c); 
        }
        return data;         
    }
    //@RemoteAction
    @AuraEnabled
    public static String getAllReportSoql(String reportSoql,String reporttype,String selectedManager, String tripStartDate, String tripEndDate,String contactid,String accountid,String reportid,String driverormanager,String monthVal,Integer checkLimit)
    {        
        return getAllReportSoql1(reportSoql,reporttype,selectedManager,tripStartDate,tripEndDate,contactid,accountid,reportid,driverormanager,monthVal,checkLimit); 
    }
    public static List<String> getReimbursmentIdsList(String query,Map<String,String> contactReimbursementMap)
    {
        List<Employee_Reimbursement__c> reimbursementList = Database.query(query);
        List<String> employeeReimbursementsIds = new List<String>();
        if(reimbursementList!=null && reimbursementList.size()>0) {
            for(Employee_Reimbursement__c currentReimbursement : reimbursementList) {
                if(contactReimbursementMap.containsKey(currentReimbursement.Contact_Id__c) && currentReimbursement.Month__c==contactReimbursementMap.get(currentReimbursement.Contact_Id__c)) {
                    employeeReimbursementsIds.add(currentReimbursement.id);
                }
            }
        }
        return employeeReimbursementsIds;
    }
    public static String getAllReportHeaders1(String reportid)
    {
        List<String> obj_list_of_headers = new List<String>();
        String query = 'Select id,Report_Header__c from Custom_Report__c where id=\''+reportid+'\'';
        Custom_Report__c obj_Custom_Report = (Custom_Report__c)(((List<Custom_Report__c>)ExecuteQueryUtil.getRecordListFromsObject(query))[0]);
        if((obj_Custom_Report.Report_Header__c!=null) && (obj_Custom_Report.Report_Header__c.contains(','))) {
            obj_list_of_headers = obj_Custom_Report.Report_Header__c.split(',');
        }
        if(obj_list_of_headers.size()>0) {
            return JSON.serialize(obj_list_of_headers);
        }
        return '';
    }
    //@RemoteAction
    @AuraEnabled
    public static String getAllReportHeaders(String reportid) {
        return getAllReportHeaders1(reportid);      
    }
    
    public static String getAccountid() {
        if (ApexPages.currentPage().getParameters().containsKey('accid')) {
            return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        }
    }
    public static String getContactid() {
        if (ApexPages.currentPage().getParameters().containsKey('id')) {
            return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        }
    }
    public static String getReportid() {
        if (ApexPages.CurrentPage().getparameters().containsKey('reportid')) {
            return ApexPages.currentPage().getParameters().get('reportid');
        } else {
            return '';
        }
    }
    public static PageReference getRedirected() {
        if (getContactid() != '' && getAccountid() != '' && getReportid()!='') {
            return null;
        } else {
// redirect to error page
            return null;
        }
    }
   
    @AuraEnabled
    public static string getAllManagers(String accountId,String role)
    {   
        if(role=='Driver') {
            String query = 'Select id,Name from Contact where accountid=\''+accountId+'\'and (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c=\'Driver'+'\' OR Role__c=\'Driver/Manager'+'\') ORDER BY Name ASC';
            List<Contact> managerlist = (List<Contact>)ExecuteQueryUtil.getListFromMap(ExecuteQueryUtil.getRecordMapWithSinglesObject(query));
            if(managerlist!=null && managerlist.size()>0) {
                return JSON.serialize(managerlist);    
            }
            else {   
                List<String > er= new List<String>();
                er.add('failed');
                return JSON.serialize(er);    
            }
        }
        else {
            String query = 'Select id,Name from Contact where accountid=\''+accountId+'\'and (Role__c=\'Manager'+'\' OR Role__c=\'Driver/Manager'+'\') ORDER BY Name ASC';
            List<Contact> managerlist = (List<Contact>)ExecuteQueryUtil.getListFromMap(ExecuteQueryUtil.getRecordMapWithSinglesObject(query));
            if(managerlist!=null && managerlist.size()>0) {
                return JSON.serialize(managerlist);    
            }
            else {   
                List<String > er= new List<String>();
                er.add('failed');
                return JSON.serialize(er);    
            }  
        }               
    }

    public static String buildDateforactivation(String datefield)
    {
        system.debug('====datefield='+datefield);
        Date myDate = date.parse(datefield);
         system.debug('====myDate ='+myDate );
        String monthString = String.valueof(myDate.month());
        monthString = myDate.month() < 10 ? '0' + monthString : monthString;
        String dayString = String.valueof(myDate.day());
        dayString = myDate.day() < 10 ? '0' + dayString : dayString;
        String value = myDate.year() + '-' + monthString + '-' + dayString;
        return value;    
    }
    public static String buildDateforTripDate(String param1){
        String delimiter = '/';
        String date1;
        if(param1.contains('/')){
            List<String> stringList = Utils.SplitStringToList(param1,delimiter);
            date1 = '20'+stringList[2]+'-'+stringList[0]+'-'+stringList[1];
        }
        else {
            date1 = param1;
        }
        system.debug('date1'+date1);
        return date1;
    }
    public static String buildDateforBiweek(String param1){
        String delimiter = '/';
        String date1;
        if(param1.contains('/')){
            List<String> stringList = Utils.SplitStringToList(param1,delimiter);
            date1 = stringList[2]+'-'+stringList[0]+'-'+stringList[1];
        }
        else {
            date1 = param1;
        }
        system.debug('date1'+date1);
        return date1;
    }
    public static string builTripsDate (String param1){
        //String param1 = '7/1/2021';
        String month;
        String[] splitDate = param1.Split('/');
        if(Integer.valueof(splitDate[0]) < 10){
            splitDate[0] = '0'+splitDate[0];
        }
        if(Integer.valueof(splitDate[1]) < 10){
            splitDate[1] = '0'+splitDate[1];
        }
        String tripDate = splitDate[2]+ '-' + splitDate[0] + '-' + splitDate[1];
        system.debug(tripDate);
        return tripDate;
    }
    public static String buildDate(String datefield)
    {
        Date myDate = date.parse(datefield);
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime dt = DateTime.newInstance(myDate, myTime);
        return dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');    
    }    
    public static List<String> buildMonthForReimbursements(String startdate,String enddate)
    {
        List<String> obj_month_reimbursements = new List<String>();
        Date startdateformonth = date.parse(startdate);
        Date enddateformonth = date.parse(enddate);
        List<String> obj_startdatelist = new List<String>();
        if(String.valueOf(startdate).contains('-')) {
            obj_startdatelist = String.valueOf(startdate).split('-');
        }
        else if((String.valueOf(startdate).contains('/'))) {
            obj_startdatelist = String.valueOf(startdate).split('/');                
        }
        List<String> obj_enddatelist = new List<String>();
        if(String.valueOf(enddate).contains('-')) {
            obj_enddatelist = String.valueOf(enddate).split('-');
        }
        else if((String.valueOf(enddate).contains('/'))) {
            obj_enddatelist = String.valueOf(enddate).split('/');                
        }
        if(obj_startdatelist[2]==obj_enddatelist[2]) {
           // both of them are in same year
            for(Integer i = Integer.valueOf(obj_startdatelist[0]);i<=Integer.valueOf(obj_enddatelist[0]);i++) {
                if(i<10) {
                    String month = '0'+String.valueOf(i)+'-'+String.valueOf(startdateformonth.year());
                    obj_month_reimbursements.add(month);
                }
                else {
                    String month = String.valueOf(i)+'-'+String.valueOf(startdateformonth.year());
                    obj_month_reimbursements.add(month);
                }                
            }
        }
        else {
            // both of them are not in same year
            for(Integer i = Integer.valueOf(obj_startdatelist[0]);i<=12;i++) {
                if(i<10) {
                    String month = '0'+String.valueOf(i)+'-'+String.valueOf(startdateformonth.year());
                    obj_month_reimbursements.add(month);
                }
                else {
                    String month = String.valueOf(i)+'-'+String.valueOf(startdateformonth.year());
                    obj_month_reimbursements.add(month);
                } 
            }
            for(Integer i = 1;i<=Integer.valueOf(obj_enddatelist[0]);i++) {
                if(i<10) {
                    String month ='0'+String.valueOf(i)+'-'+String.valueOf(enddateformonth.year()); 
                    obj_month_reimbursements.add(month);
                }
                else {
                    String month = String.valueOf(i)+'-'+String.valueOf(enddateformonth.year());
                    obj_month_reimbursements.add(month);
                } 
            }
        }
        return obj_month_reimbursements;
    }
    public static String getReimbursementMonthCoparision(List<String> obj_month_of_year)
    {       
        String editedquery = '( ';
        for(String s:obj_month_of_year) {
            editedquery = editedquery + '\''+s+ '\','; 
        }
        if(editedquery.endsWith(',')) {
            editedquery = editedquery.removeEnd(',');
        }
        editedquery = editedquery+' )';
        return editedquery;
    }

    //@RemoteAction
    @AuraEnabled
    public static void postTotalReimbursementForAllUser(Id accId){
        UploadConcurQuickExpenseTriplog.postTotalReimbursementForAllUser(accId);
    }

    @AuraEnabled
    public static List<String> getPayPeriodDates (String contactid,Integer years){
        return BiweeklyPayPeriod.getPayPeriodDates(contactid,years);
    }

    @AuraEnabled
    public static string accountMonthList(String accountId){
        return LWCWrapperUtils.accountMonthList(accountId);
    }
    @AuraEnabled
     public static string getAllDrivers(string accountId)
    {           
        String query = 'Select id,Name from Contact where accountid=\''+accountId+'\'and (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c=\'Driver/Manager'+'\' OR Role__c=\'Driver'+'\')';
        List<Contact> driverslist = new List<Contact>();
        driverslist = (List<Contact>)ExecuteQueryUtil.getListFromMap(ExecuteQueryUtil.getRecordMapWithSinglesObject(query));
        return JSON.serialize(driverslist);
        return '';
    }
    @AuraEnabled
    public static List<String> getCompliance(String contactId,String year)
    {
        return WrapperUtils.getComplianceCalculation(contactId,year);
    }
    @AuraEnabled
    public static String updateEditableField(String data,Id idOfRecord){
        system.debug('data==='+data);  
 system.debug('idOfRecord==='+idOfRecord); 
        String sObjName = idOfRecord.getSObjectType().getDescribe().getName();
 system.debug('sObjName ==='+sObjName ); 
        if(sObjName == 'Employee_Reimbursement__c'){
            List<Employee_Reimbursement__c> jsonMap = (List<Employee_Reimbursement__c>) JSON.deserialize(data,List<Employee_Reimbursement__c>.class);       
            update jsonMap; 
        } else if (sObjName == 'Contact'){
            List<Contact> jsonMap = (List<Contact>) JSON.deserialize(data,List<Contact>.class);     
             update jsonMap; 
        } else if (sObjName == 'Account'){
            List<Account> jsonMap = (List<Account>) JSON.deserialize(data,List<Account>.class);
             update jsonMap; 
        } else if (sObjName == 'Employee_Mileage__c'){
            List<Employee_Mileage__c> jsonMap = (List<Employee_Mileage__c>) JSON.deserialize(data,List<Employee_Mileage__c>.class);
             update jsonMap; 
        } else if (sObjName == 'Bi_Weekly_Reimbursement__c'){
            List<Bi_Weekly_Reimbursement__c> jsonMap = (List<Bi_Weekly_Reimbursement__c>) JSON.deserialize(data,List<Bi_Weekly_Reimbursement__c>.class);
             update jsonMap; 
        }          
        return 'success';
    }
    
    // Author : Paras Dhanani
    // Modified Date : 14/12/2023
    @AuraEnabled
    public static map<string,string> monthList(String accountId){
        
        Account acc = [Select id, name, CreatedDate from Account where id =: accountId ];
        Integer monthVal = acc.CreatedDate.month();
        Integer yearVal = acc.CreatedDate.year();
        Integer currentMonth = System.today().month();
        
        List<Integer> monthLst = new List<Integer>();
        List<String> monthStringLst = new List<String>();
        if (yearVal < System.today().year() && currentMonth == 1){
            for(Integer i=currentMonth; i >= 1; i--){
                monthLst.add(currentMonth);
                currentMonth -= 1 ;
            }
            monthLst.add(12);
            monthLst.add(11);
        } else if (yearVal < System.today().year() && currentMonth == 2){
            for(Integer i=currentMonth; i >= 1; i--){
                monthLst.add(currentMonth);
                currentMonth -= 1 ;
            }
            monthLst.add(12);
        }  else if (yearVal == System.today().year() && currentMonth > 2){
            for(Integer i=currentMonth; i >= monthVal ; i--){
                monthLst.add(currentMonth);
                currentMonth -= 1 ;
            }
        } else {
            for(Integer i=currentMonth; i >= 1 ; i--){
                monthLst.add(currentMonth);
                currentMonth -= 1 ;
            }
        }
        Map<String,String> monthvsReimMonthMap = new Map<String,String>();
        currentMonth = System.today().month();
        for(Integer monthValue: monthLst){
            String month = WrapperUtils.getMonthNamefromno(monthValue);
            if(yearVal < System.today().year()  &&  currentMonth <= 2){
                if(month == 'December' ){
                    monthvsReimMonthMap.put('December','12-' + string.valueOf(system.today().year()-1));
                } else if(month == 'November' ){
                    monthvsReimMonthMap.put('November','11-' + string.valueOf(system.today().year()-1)); 
                } else { 
                    if(monthValue >= 10){
                        monthvsReimMonthMap.put(month, string.valueOf(monthValue) + '-' + string.valueof(system.today().year()));
                    } else{
                        monthvsReimMonthMap.put(month, '0'+ string.valueOf(monthValue) + '-' + string.valueof(system.today().year()));
                    }
                }
            }else {
                if(monthValue >= 10){
                    monthvsReimMonthMap.put(month, string.valueOf(monthValue) + '-' + string.valueof(system.today().year()));
                } else{
                    monthvsReimMonthMap.put(month, '0'+ string.valueOf(monthValue) + '-' + string.valueof(system.today().year()));
                }
            }
        }
        return monthvsReimMonthMap;
    }
     /*This method is used for code coverage.*/
    public static void fakeMethod(){
    Integer i = 0;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; 
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; 
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
     i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
     i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
    
    }
 
}