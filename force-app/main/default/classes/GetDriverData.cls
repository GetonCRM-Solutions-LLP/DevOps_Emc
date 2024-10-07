public with sharing class GetDriverData {
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    public static Boolean showMyTeam {get;set;}
    public static String contactName {get;set;}
    public static string videoCustom {get;set;}
    public static Integer userLoginCount {get;set;}
    public static String ScheduleGotoMeeting {get;set;}
    public static Date activationDate {get;set;}
    public static String systemNotification {get;set;} 
    public static String profileID {get;set;}   

    public GetDriverData() {
        NewDashboardVideoLink__c videoCustomSetting = NewDashboardVideoLink__c.getOrgDefaults();
        videoCustom = json.serialize(videoCustomSetting );
        if(!Test.isrunningtest()){
        setEmployeeName();
        }
             
       
        List<Contact> conList = [SELECT id,Activation_Date__c, Role__c, System_Notification__c FROM Contact WHERE id =: getContactid() ];
        if(conList.size() > 0){
            activationDate = conList[0].Activation_Date__c != null ? conList[0].Activation_Date__c: null;
            systemNotification = conList[0].System_Notification__c;
            profileID = conList[0].Role__c;
        }
        if(!Test.isrunningtest()){
            if(getContactid() != null){
            userLoginCount = DriverDashboardLWCController.countUserLogin(getContactid());
            if(getAccountId() != null){
                UpdateTimezonAppVerMlog(getAccountId(),getContactid());
            }
        }
        }
    }
    
    public static String getContactid() {
        if(ApexPages.currentPage().getParameters().containsKey('id') && String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
            return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        }
    }
    
    public static String getAccountId() {
        if(ApexPages.currentPage().getParameters().containsKey('accid') && String.isNotBlank(ApexPages.currentPage().getParameters().get('accid'))) {
            return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        }
    }
    
    Public static void UpdateTimezonAppVerMlog(String accountId,String contactId) {
        Contact employee = [select Id,Role__c from Contact where id =: contactId];
        if(employee != null && (employee.Role__c == 'Admin' || employee.Role__c == 'Driver/Admin')){
            UpdateUserIdandAppVertionBatch bcn = new UpdateUserIdandAppVertionBatch(accountId);
            ID batchprocessid = Database.executeBatch(bcn,200);
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List < sObject > fetchLookUpValues(String accId,String adminId,String accField,String idOfDriver,String whereField, String searchKey,String fieldName, String ObjectName,String keyField,Boolean isActive) {
        List < sObject > returnList = new List < sObject > ();
        Contact conObj ;
        String sQuery ;
        if(idOfDriver == 'All Drivers'){
            idOfDriver = '';
        }
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        }
        
        if((String.isBlank(idOfDriver) || String.isEmpty(idOfDriver)) && ((String.isBlank(adminId) || String.isEmpty(adminId)))){
            sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where '+accField+'='+'\''+accId+'\''+' AND '+searchKey+ ' != null LIMIT 49999' ;
        }
        else if((!String.isBlank(adminId) || !String.isEmpty(adminId)) && ObjectName == 'Contact' && (conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver))){
            if(isActive == true){
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c = null AND (Role__c != \'Admin\')AND (Role__c != \'Manager\') LIMIT 9999' ;
            }
            else {
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c != null AND (Role__c != \'Admin\')AND (Role__c != \'Manager\') LIMIT 9999' ;
            }
        }
        else if((!String.isBlank(adminId) || !String.isEmpty(adminId)) && ObjectName == 'Contact'){
            if(isActive == true){
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where ((Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+')) AND '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c = null AND (Role__c != \'Admin\')AND (Role__c != \'Manager\') LIMIT 9999' ;
            }
            else {
                sQuery =  'select '+fieldName+','+keyField+ ' from ' +ObjectName+' where ((Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+') OR (Manager__r.Manager__r.Manager__r.Manager__c ='+'\''+adminId+'\''+')) AND '+accField+'='+'\''+accId+'\''+' AND Deactivated_Date__c != null AND (Role__c != \'Admin\')AND (Role__c != \'Manager\') LIMIT 9999' ;
            }
        }
        else {
            sQuery =  'select '+fieldName+','+keyField+' from '+ObjectName+' where '+whereField+'='+'\''+idOfDriver+'\''+' and '+accField+'='+'\''+accId+'\'';
        }
        System.debug('sQuery'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    public static void setEmployeeName() {
        String id = ApexPages.currentPage().getParameters().get('id');
        Contact employee ;
        employee = [select Id,FirstName,showTeamRecord__c,External_Email__c,account.Schedule_Goto_Meeting__c from Contact where id =: id ];
        if(employee!=null){
            ScheduleGotoMeeting = employee.account.Schedule_Goto_Meeting__c != null ? employee.account.Schedule_Goto_Meeting__c : '' ;
            showMyTeam = employee.showTeamRecord__c;
            contactName = employee.FirstName != null ? employee.FirstName : '';
        }else{
            showMyTeam = false;
        }
    }
    
    @AuraEnabled
    public static string fetchWayPointPostAPI(Integer tripId,String apikey){
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        String body;
        String baseURL ;
        baseURL = !MLOGACCOUNT.Contains(apikey) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        baseURL = baseURL + '/api/trips/'+tripId+'/routes';
        if(!Test.isRunningTest()){
            HttpResponse res = ApiCalloutUtility.executeCallout(apikey,'GET',baseURL,'','');
            if(res.getStatusCode() == 200) {
                body = res.getBody();
            }
        }
        
        if(body != null){
            for(Employee_Mileage__c mileage : [SELECT id,Trip_Id__c,Way_Points__c  FROM Employee_Mileage__c  WHERE Trip_Id__c =: tripId LIMIT 10]){
                mileage.Way_Points__c = body;
                mileageList.add(mileage);
            }
        }
        if(!mileageList.isEmpty()){
            update mileageList;
        }
        return body;
    }
    
    @AuraEnabled
    public static String fetchMileagesSize(String accID,String adminId){
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        Contact conObj ;
        if(!String.isBlank(adminId) || !String.isEmpty(adminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: adminId LIMIT 1];
        }
        if(conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver)){
            mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c, StartTime__c, EndTime__c,EMP_Mileage__c,Trip_Destination_State__c,Approved_Date__c,Approval_Name__c  FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null ORDER BY ConvertedStartTime__c ASC  LIMIT 9999 ];
        }else {
            mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c, StartTime__c, EndTime__c,EMP_Mileage__c,Trip_Destination_State__c,Approved_Date__c,Approval_Name__c  FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId)  ) AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null order by ConvertedStartTime__c asc LIMIT 1999];
        }
        return String.valueOf(mileageList.size());
    }

    public String accID {get; set;}
    public String AdminId {get; set;}
    public Integer limitSize {get; set;}
    public Integer offset {get; set;}

    @AuraEnabled(cacheable=true)
    @RemoteAction 
    public static List<Employee_Mileage__c> fetchMileages(String accID,String AdminId,Integer limitSize, Integer offset){
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        Contact conObj ;
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        }
        if(conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver)){
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,EmployeeReimbursement__r.Mileage_Lock_Date__c, StartTime__c, EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Destination_State__c,Approved_Date__c,Approval_Name__c  FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth  AND   EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null order by ConvertedStartTime__c desc LIMIT :limitSize OFFSET :offset];
        }
        else {
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,EmployeeReimbursement__r.Mileage_Lock_Date__c, StartTime__c,EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Destination_State__c,Approved_Date__c,Approval_Name__c   FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId)  ) AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null ORDER BY ConvertedStartTime__c DESC LIMIT : limitSize OFFSET :offset];
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Employee_Mileage__c> fetchMileageslwc(String accID,String AdminId,Integer limitSize, Integer offset){
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        Contact conObj ;
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        }
        if(conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver)){
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,Trip_Destination_State__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,EmployeeReimbursement__r.Mileage_Lock_Date__c, StartTime__c, EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Approved_Date__c,Approval_Name__c  FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth  AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null ORDER BY ConvertedStartTime__c desc LIMIT :limitSize OFFSET :offset];
        }else {
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c,Trip_Destination_State__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,EmployeeReimbursement__r.Mileage_Lock_Date__c, StartTime__c,EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Approved_Date__c,Approval_Name__c   FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId)  ) AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null ORDER BY ConvertedStartTime__c DESC LIMIT : limitSize OFFSET :offset];
        }
    }
    
    @AuraEnabled
    public static String getMilegesDataSize(Id accountId,String AdminId,String idOfDriver, Date StartDate, Date EndDate, String OriginName, String DestinationName,Boolean ActiveDriver,String StartMileage,String EndMileage,String TripStatus,String TrackingMethod,String Tag,String Notes,String Activity,String reimMonth,String mileageType) {
        Contact conObj ;
        if(idOfDriver == 'All Drivers'){
            idOfDriver = '';
        }
        if(Tag == 'All Tags'){
            Tag = '';
        }
        if(TripStatus == 'All Status'){
            TripStatus = '';
        }
        if(TrackingMethod == 'All Tracking Methods'){
            TrackingMethod = '';
        }
        if(Activity == 'All Activities'){
            Activity = '';
        }
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        } 
        String query = 'SELECT id,Trip_Date__c,Trip_Destination_State__c,EmployeeReimbursement__r.Mileage_Lock_Date__c,Stay_Time__c,Tag__c,Activity__c,StartTime__c,EndTime__c,EMP_Mileage__c, Driving_Time__c,EmployeeReimbursement__r.Contact_Id_Name__c,ConvertedStartTime__c,ConvertedEndTime__c,EmployeeReimbursement__r.Contact_Id__r.Name,Mileage__c,Trip_Origin__c, Trip_Destination__c,Origin_Name__c, Destination_Name__c,EmployeeReimbursement__r.Contact_Id__c,Day_Of_Week__c,Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c,Notes__c, Tracing_Style__c,From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s,Trip_Id__c,EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,TimeZone__c,EmployeeReimbursement__r.Contact_Id__r.AccountId,Drive_Stay_Time__c,Approved_Date__c,Approval_Name__c FROM Employee_Mileage__c ';
        
        String whereClause = '';
        if(accountId != null || idOfDriver != null || StartDate != null || EndDate != null || OriginName != null || DestinationName != null || StartMileage != null || EndMileage != null || TripStatus != null || TrackingMethod != null || Tag != null || Notes != null || mileageType != 'All Types'){
            whereClause = ' WHERE ';
        }

        if(!String.isBlank(accountId) ){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.AccountId', accountId , '=','String');
        }

        if(!String.isBlank(idOfDriver)){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__c', idOfDriver , '=','String');
        }
        
        if(StartDate != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', String.valueOf(StartDate), '>=', 'Date');
        }
        
        if(EndDate != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', String.valueOf(EndDate), '<=', 'Date');
        }
        if(!String.isBlank(OriginName)){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Origin__c', OriginName, '=', 'String');
        }
        if(!String.isBlank(DestinationName)){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Destination__c', DestinationName, '=', 'String');
        }
        if(!String.isBlank(StartMileage)){
            whereClause = GenerateWhereClause (whereClause, 'Mileage__c', StartMileage, '>=', 'Number');
        }
        if(!String.isBlank(EndMileage)){
            whereClause = GenerateWhereClause (whereClause, 'Mileage__c', EndMileage, '<=', 'Number');
        }
        if(!String.isBlank(TripStatus)){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Status__c', TripStatus, '=', 'String');
        }
        if(!String.isBlank(TrackingMethod)){
            whereClause = GenerateWhereClause (whereClause, 'Tracing_Style__c', TrackingMethod, '=', 'String');
        }
        if(ActiveDriver == true){
            //whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c', null, '=', 'Number');
        }
        if(!String.isBlank(Tag)){
            whereClause = GenerateWhereClause (whereClause, 'Tag__c', Tag, '=', 'String');
        }
        if(!String.isBlank(Activity)){
            whereClause = GenerateWhereClause (whereClause, 'Activity__c', Activity, '=', 'String');
        }
        if(mileageType != 'All Types'){
            if(mileageType == 'High Risk') {
                // query += 'AND High_Risk_Mileage__c = true';
                whereClause = ( whereClause != ' WHERE ' ? whereClause + ' AND ' : whereClause ) + 'High_Risk_Mileage__c' + ' ' + '=' + ' ' + true;
            } else {
                List<Date> tripDates = getWeekendTrips();
                String strListTripDates = '';
                for(Date objDate : tripDates){
                    strListTripDates += String.valueOf(objDate).substring(0,10) + ', '; 
                }
                strListTripDates = strListTripDates.substring(0,strListTripDates.length()-2);
                strListTripDates = '( ' + strListTripDates + ' )';
    
                whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', strListTripDates, 'IN ', 'Date');
            }
        }
        query += whereClause;
        system.debug('query'+query);

        if(conObj != null && (conObj.Role__c == 'Manager' || conObj.Role__c == 'Driver/Manager')){
            query += 'AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c = \'' + AdminId + '\' )' ;
            query +=   'OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c = \'' + AdminId + '\' )' ;
            query +=   'OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c = \'' + AdminId + '\' )' ;
            query +=   'OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c = \'' + AdminId + '\' ))' ;
        }
        
        if(reimMonth != null){
            String yearNum = '';
            String monthNum = WrapperUtils.getMonthno(reimMonth);
            if(monthNum == '12'){
                yearNum = String.valueOf(System.today().year()-1);
            } else{
                yearNum = String.valueOf(System.today().year());
            }
            String monthVal = monthNum +'-'+ yearNum ;
            query += ' AND EmployeeReimbursement__r.Month__c =\''+ monthVal+ '\'';
        }
        
        //query += ' WITH SECURITY_ENFORCED ';
        query += ' order by ConvertedStartTime__c asc ';
        query += ' LIMIT 9999';
        List<Employee_Mileage__c> mileageDetail = new List<Employee_Mileage__c>();
        try {
            mileageDetail = Database.query(query); 
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        return string.valueOf(mileageDetail.size());
    }

    @AuraEnabled
    public static List <Employee_Mileage__c> getMilegesData(Id accountId,String AdminId,String idOfDriver, Date StartDate, Date EndDate, String OriginName, String DestinationName,Boolean ActiveDriver,String StartMileage,String EndMileage,String TripStatus,String TrackingMethod,String Tag,String Notes,String Activity,Integer limitSize, Integer offset,String reimMonth,String mileageType) {
        if(idOfDriver == 'All Drivers'){
            idOfDriver = '';
        }
        if(Tag == 'All Tags'){
            Tag = '';
        }
        if(TripStatus == 'All Status'){
            TripStatus = '';
        }
        if(TrackingMethod == 'All Tracking Methods'){
            TrackingMethod = '';
        }
        if(Activity == 'All Activities'){
            Activity = '';
        }
        Contact conObj ;
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        }
        String query = 'SELECT id,Trip_Date__c,Trip_Destination_State__c,EmployeeReimbursement__r.Mileage_Lock_Date__c,Stay_Time__c,Tag__c,StartTime__c,EMP_Mileage__c,Activity__c, EndTime__c, Driving_Time__c,EmployeeReimbursement__r.Contact_Id_Name__c,ConvertedStartTime__c,ConvertedEndTime__c,EmployeeReimbursement__r.Contact_Id__r.Name,Mileage__c,Trip_Origin__c, Trip_Destination__c,Origin_Name__c, Destination_Name__c,EmployeeReimbursement__r.Contact_Id__c,Day_Of_Week__c,Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c,EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c,Notes__c, Tracing_Style__c,From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s,Trip_Id__c,EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,TimeZone__c,EmployeeReimbursement__r.Contact_Id__r.AccountId,Drive_Stay_Time__c,Original_Origin_Name__c,Original_Destination_Name__c,Approved_Date__c,Approval_Name__c FROM Employee_Mileage__c ';
      
        String whereClause = '';
        if(accountId != null || idOfDriver != null || StartDate != null || EndDate != null || OriginName != null || DestinationName != null || StartMileage != null || EndMileage != null || TripStatus != null || TrackingMethod != null || Tag != null || Notes != null || mileageType != 'All Types'){
            whereClause = ' WHERE ';
        }

        if(!String.isBlank(accountId) ){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.AccountId', accountId , '=','String');
        }

        if(!String.isBlank(idOfDriver)){ 
            whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__c', idOfDriver , '=','String');
        }
        
        if(StartDate != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', String.valueOf(StartDate), '>=', 'Date');
        }
    
        if(EndDate != null){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', String.valueOf(EndDate), '<=', 'Date');
        }
        system.debug('whereClause '+whereClause );
        if(!String.isBlank(OriginName)){
        
            whereClause = GenerateWhereClause (whereClause, 'Trip_Origin__c', OriginName, '=', 'String');
        }
        if(!String.isBlank(DestinationName)){
        
            whereClause = GenerateWhereClause (whereClause, 'Trip_Destination__c', DestinationName, '=', 'String');
        }
        if(!String.isBlank(StartMileage)){
            whereClause = GenerateWhereClause (whereClause, 'Mileage__c', StartMileage, '>=', 'Number');
        }
        if(!String.isBlank(EndMileage)){
            whereClause = GenerateWhereClause (whereClause, 'Mileage__c', EndMileage, '<=', 'Number');
        }
        if(!String.isBlank(TripStatus)){
            whereClause = GenerateWhereClause (whereClause, 'Trip_Status__c', TripStatus, '=', 'String');
        }
        if(!String.isBlank(TrackingMethod)){
            whereClause = GenerateWhereClause (whereClause, 'Tracing_Style__c', TrackingMethod, '=', 'String');
        }
        if(ActiveDriver == true){
            //whereClause = GenerateWhereClause (whereClause, 'EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c', null, '=', 'Number');
        }
        if(!String.isBlank(Tag)){
            whereClause = GenerateWhereClause (whereClause, 'Tag__c', Tag, '=', 'String');
        }
        if(!String.isBlank(Activity)){
            whereClause = GenerateWhereClause (whereClause, 'Activity__c', Activity, '=', 'String');
        }
        if(mileageType != 'All Types'){
            if(mileageType == 'High Risk') {
                // query += 'AND High_Risk_Mileage__c = true';
                whereClause = ( whereClause != ' WHERE ' ? whereClause + ' AND ' : whereClause ) + 'High_Risk_Mileage__c' + ' ' + '=' + ' ' + true;
            } else {
                List<Date> tripDates = getWeekendTrips();
                String strListTripDates = '';
                for(Date objDate : tripDates){
                    strListTripDates += String.valueOf(objDate).substring(0,10) + ', ';
                }
                strListTripDates = strListTripDates.substring(0,strListTripDates.length()-2);
                strListTripDates = '( ' + strListTripDates + ' )';

                whereClause = GenerateWhereClause (whereClause, 'Trip_Date__c', strListTripDates, 'IN ', 'Date');
            }
        }
        query += whereClause;
        if(conObj != null && (conObj.Role__c == 'Manager' || conObj.Role__c == 'Driver/Manager')){
            query += 'AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c = \'' + AdminId + '\' )' ;
            query +=   'OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c = \'' + AdminId + '\' )' ;
            query +=   'OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c = \'' + AdminId + '\' )' ;
            query +=   'OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c = \'' + AdminId + '\' ))' ;
        }
        
        if(reimMonth != null){
            String yearNum = '';
            String monthNum = WrapperUtils.getMonthno(reimMonth);
            if(monthNum == '12'){
                yearNum = String.valueOf(System.today().year()-1);
            } else{
                yearNum = String.valueOf(System.today().year());
            }
            String monthVal = monthNum +'-'+ yearNum ;
            query += ' AND EmployeeReimbursement__r.Month__c =\''+ monthVal+ '\'';
        }
        system.debug('query'+query);
        //query += ' WITH SECURITY_ENFORCED ';
        query += ' order by ConvertedStartTime__c asc ';
        //query += ' LIMIT 500';
        query += 'LIMIT ' + limitSize +' ';
        query += 'OFFSET ' + offset;
        system.debug('Final Query : ' + query);
        List<Employee_Mileage__c> mileageDetail = new List<Employee_Mileage__c>();
        try {
            mileageDetail = Database.query(query); 
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        return mileageDetail;
    }

    public static List<Date> getWeekendTrips(){

        List<Date> weekendDates = new List<Date>();

        Date currentDate = Date.newInstance(System.today().year(), 1, 1);
        Date endDate = System.today();
        while(currentDate<=endDate){
            // Check if the current date is a Saturday or Sunday
            if (currentDate.toStartOfWeek() == currentDate.addDays(-6)) { // Saturday
                weekendDates.add(currentDate);
            } else if (currentDate.toStartOfWeek() == currentDate) { // Sunday
                weekendDates.add(currentDate);
            }
            // Move to the next day
            currentDate = currentDate.addDays(1);
        }

        return weekendDates;
    }

    public static String buildDateforactivation( Date datefield )
    {
        return (Datetime.newInstance(datefield, system.now().time())).format('YYYY-MM-dd');   
    }

    public static String GenerateWhereClause( String whereClause, String fieldAPI , String fieldValue, String operator, String dateType) {
        
        whereClause = ( whereClause != ' WHERE ' ? whereClause + ' AND ' : whereClause ) + 
                    fieldAPI + ' ' + operator + ' ' + ( dateType == 'String'? '\'' + fieldValue + '\'' : fieldValue);
        return whereClause;
    }
    
    @AuraEnabled
    public static String approveMileages(Boolean checked,String emailaddress,Boolean sendEmail,Boolean unapprove)
    {
        Map<String,List<String>> approveRejectMileageMap = new Map<String,List<String>>(); 
        List<String> nullList = new List<String>();
        List<String> mileageIds = new List<String>();
        List<Employee_Mileage__c> mileagesToApprove = new List<Employee_Mileage__c>();
        List<MileageJsonDeserialize> emailIdJson = MileageJsonDeserialize.parse(emailaddress);
        
        for(MileageJsonDeserialize objMileages : emailIdJson) {
            mileageIds.add(objMileages.Id);
            if(approveRejectMileageMap.size() > 0 && approveRejectMileageMap.containsKey(objMileages.employeeEmailId))
            {
                List<String> mileagesEmailList = approveRejectMileageMap.get(objMileages.employeeEmailId);
                mileagesEmailList.add(String.valueOf(objMileages.id));
                approveRejectMileageMap.put(objMileages.employeeEmailId,mileagesEmailList);
            }
            else
            {
                List<String> mileagesEmailList = new List<String>();
                mileagesEmailList.add(String.valueOf(objMileages.id));
                approveRejectMileageMap.put(objMileages.employeeEmailId,mileagesEmailList);
            }
        }
        if(checked == true ) {
            mileagesToApprove = WrapperUtils.UpdateMileages(mileageIds,'Approved');
        } else if(unapprove == true){
            List<Employee_Mileage__c> mileages = new List<Employee_Mileage__c>();
            for(String mileageId : mileageIds) {
                Employee_Mileage__c mil = new Employee_Mileage__c();
                mil.Id = mileageId;
                mil.name = mileageId;
                mil.Trip_Status__c = 'Not Approved Yet';
                mil.Approved_Date__c = null;
                mil.Rejected__c = false;
                mileagesToApprove.add(mil);
            }
            //mileagesToApprove = WrapperUtils.UpdateMileages(mileageIds,'Not Approved Yet');
        } else {
            mileagesToApprove = WrapperUtils.UpdateMileages(mileageIds,'Rejected');
        }

        if(!mileagesToApprove.isEmpty()) {
            update mileagesToApprove;
        }
    
            SendEmailToMe__c customSetValue = SendEmailToMe__c.getValues('ChangeTripStatusinTripLogBatch');
            if(customSetValue != null && customSetValue.Send_email_to_me__c == true && unapprove == false)
            {
                if(approveRejectMileageMap.size() > 0 && !Test.isRunningTest() ){
                    for(String currentMileages : approveRejectMileageMap.keySet()){
                        if(checked == true ) {
                            if(sendEmail == true){
                                Database.executeBatch(New ChangeTripStatusinTripLog(approveRejectMileageMap.get(currentMileages),nullList,'',currentMileages),1);
                            }
                            else {
                                Database.executeBatch(New ChangeTripStatusinTripLog(approveRejectMileageMap.get(currentMileages),nullList,'',''),1);
                            }
                            
                        }
                        else {
                            if(sendEmail == true ){
                                Database.executeBatch(New ChangeTripStatusinTripLog(nullList,approveRejectMileageMap.get(currentMileages),'',currentMileages),1);
                            }
                            else {
                                Database.executeBatch(New ChangeTripStatusinTripLog(nullList,approveRejectMileageMap.get(currentMileages),'',''),1);
                            }
                            
                        }
                    }
                }
            }
        return 'success';
    }

    @AuraEnabled
    public static string deleteMileages(String emailaddress)
    {
        Set<Id> mileagesIds = new Set<Id>();
        List<MileageJsonDeserialize> emailIdJson = MileageJsonDeserialize.parse(emailaddress);
        for(MileageJsonDeserialize objMileages : emailIdJson) {
            mileagesIds.add(objMileages.Id);
        }
        if(mileagesIds.size() > 0 ){
            delete[SELECT id FROM Employee_Mileage__c WHERE id =: mileagesIds];
        }
        return 'deleted';
    }

    @AuraEnabled
    public static string updateMileages(String tripId,String tripTag,String activity,String notes,Integer staytime)
    {
        Employee_Mileage__c mil = new Employee_Mileage__c();
        mil.Id = tripId;
        mil.Tag__c = tripTag;
        mil.Activity__c = activity;
        mil.Notes__c = notes ;
        mil.Stay_Time__c = staytime;
        //update mil;
        
        try{
            update mil;
        } catch (System.DmlException  e){
            SYSTEM.DEBUG('==='+e.getDmlMessage(0));
            return e.getDmlMessage(0);
        }
        return 'Sucessfully Updated Data !!';
    }
    
    @AuraEnabled
    public static void updateMileagesEmail(String adminId,date tripdate,String conName,String conEmail,String oldActivity,String newActivity,String mileage,String actualMileage,Integer tripId,String accApi)
    {
        if(newActivity != oldActivity){
            if(tripId != null && accApi != null){
                String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
                String baseURL = !MLOGACCOUNT.Contains(accApi) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                String rosterURL = baseURL + '/api/trips/'+tripId;
                String body = '{"activity":'+newActivity+'}';
                TriplogPutCall__c objTriplog = TriplogPutCall__c.getValues('GetDriverData');
                String jsonSubset;
                try {
                    if(!Test.isRunningTest() && objTriplog.TriplogPut__c == true) {
                        HttpResponse res = ApiCalloutUtility.executeCallout(accApi,'PUT',rosterURL,'',body);
                        Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        jsonSubset = JSON.serialize(jsonMap.get('message'));
                        system.debug('jsonSubset'+jsonSubset);
                    }
                } catch(System.CalloutException er) {
                }
            }
            
            Contact conObj ;
            if(!String.isBlank(adminId) || !String.isEmpty(adminId)){
                conObj = [SELECT id,Name FROM Contact WHERE id =: adminId LIMIT 1];
            }
            
            decimal tripMileage;
            if(newActivity == 'Commute' && decimal.valueof(actualMileage) >= 30){
            tripMileage = decimal.valueof(actualMileage) - 30;
            } else if(newActivity == 'Commute'){
                tripMileage = 0;
            } else if (newActivity == 'Business'){
                tripMileage = decimal.valueof(actualMileage);
            }
            List<Messaging.MassEmailMessage> mails = new List<Messaging.MassEmailMessage>();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:'driverservices@mburse.com'];
            List<EmailTemplate> temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Email_For_Update_Commute_Activity']);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            String[] sendingTo = new String[]{conEmail};
            mail.setToAddresses(sendingTo );
            mail.setSubject(temp[0].Subject);
            string htmlbody = '';
            htmlbody = temp[0].HTMLValue;
            htmlbody = htmlbody.replace('{!ContactFirstName}',conName);
            htmlbody = htmlbody.replace('{!AdminName}',conObj.Name);
            htmlbody = htmlbody.replace('{tripdate}',String.valueof(tripdate));
            htmlbody = htmlbody.replace('{oldacitivy}',oldActivity);
            htmlbody = htmlbody.replace('{newacitivy}',newActivity);
            htmlbody = htmlbody.replace('{mileage}',String.valueof(tripMileage));
            mail.setPlainTextBody(htmlbody);
            List<String> bccaddress = new list<String>();
            bccaddress.add('driverservices@mburse.com');
            mail.setBccAddresses(bccaddress);
            mail.setHtmlBody(htmlbody);
            mail_list.add(mail);
            
            SendEmail__c  sendEmailObj = SendEmail__c.getValues('GetDriverData');
            if((sendEmailObj!=null) && sendEmailObj.Send_email_from_code__c==true && mail_list.size()>0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mail_list);
            }
        }
        
    }
    @AuraEnabled
    public static string massUpdateActivityEmail(String newActivity,String jsondata)
    {
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        List<ChangeActivityJSON2Apex> tripJson = ChangeActivityJSON2Apex.parse(jsondata);
        for(ChangeActivityJSON2Apex objMileages : tripJson) {
            Employee_Mileage__c mil = new Employee_Mileage__c();
            mil.Id = objMileages.Id;
            mil.Activity__c = newActivity;
            mileageList.add(mil);
        }
        if(mileageList.size() > 0){
            update mileageList;
        }
        Database.executeBatch(New ChangeActivityInMlogEmail(newActivity,jsondata),100);
        return 'Success ';
    }
    @AuraEnabled
    public static List<Employee_Mileage__c> mileageListData(String accId,String adminId, date startDate, date endDate){
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        List<Contact> conList = new List<Contact>();
        if(adminId != null) {
            conList = [SELECT Id, Name, Role__c FROM Contact WHERE id =: adminId];
        }
        
        if(conList[0].Role__c =='Manager' || conList[0].Role__c =='Driver/Manager'){
            if(startDate != null && endDate != null ) {
                mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,EmployeeReimbursement__r.Mileage_Lock_Date__c, StartTime__c, EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Destination_State__c,Approved_Date__c,Approval_Name__c FROM Employee_Mileage__c where  (Trip_Date__c >=: startDate AND Trip_Date__c<=: endDate) AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId) ) ORDER BY ConvertedStartTime__c ASC LIMIT 49999]; 
            }
        } else {
            if(startDate != null && endDate != null ) {
                mileageList = [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,EmployeeReimbursement__r.Mileage_Lock_Date__c, StartTime__c, EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Destination_State__c,Approved_Date__c,Approval_Name__c FROM Employee_Mileage__c where  (Trip_Date__c >=: startDate AND Trip_Date__c<=: endDate) AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  ORDER BY ConvertedStartTime__c ASC LIMIT 49999];
            }
        }
        return mileageList;
    }

    @AuraEnabled
    public static string deleteTrips(String accountId,String month){
    if(accountId != null){
        delete [SELECT id  FROM Employee_Mileage__c WHERE Trip_Status__c = 'Not Approved Yet'  AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: accountId AND EmployeeReimbursement__r.Month__c =: month AND EmployeeReimbursement__r.Status__c = 'Pending' AND Trip_Id__c != null];
        }
        return 'deleted';
    }

    @AuraEnabled
    public static String deleteTripsForIndividualDriver(String driverId,String months){
        List<monthWrapper> monthResponse = 
        (List<monthWrapper>) System.JSON.deserialize(months, List<monthWrapper>.class);

        if(driverId != null){
            List<Employee_Mileage__c> empMil = [SELECT id FROM Employee_Mileage__c WHERE Trip_Status__c = 'Not Approved Yet' AND EmployeeReimbursement__r.Status__c = 'Pending' AND EmployeeReimbursement__r.Contact_Id__c =: driverId AND (EmployeeReimbursement__r.Month__c =: monthResponse[0].value OR EmployeeReimbursement__r.Month__c =: monthResponse[1].value) AND Trip_Id__c != null];
            if(empMil.size() > 0) {
                Database.DeleteResult[] drList = Database.delete(empMil, false);
                System.debug(drList);
            }
        }
        return 'Deleted';
    }

    @AuraEnabled
    public static String syncTripsIndividualDriver(String driverId,String month){
        System.debug('Month : ' + month);
        System.debug('Driver : ' + driverId);
        String result = 'No Reimbursement present for ' + month + '.';
        if(driverId != null) {
            Id convDriverId = Id.valueOf(driverId, true);
            Map<String,String> monthNumberMap = new Map<String,String>{
                '01' => 'January','02' => 'February', '03' => 'March',
                '04' => 'April', '05' => 'May', '06' => 'June',
                '07' => 'July', '08' => 'August', '09' => 'September',
                '10' => 'October', '11' => 'November', '12' => 'December'
            };
            List<Employee_Reimbursement__c> empReim = [SELECT Id,Name,Month__c,Fuel_Price__c,Maintenance_and_Tires__c,MPG__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: driverId AND Month__c  =: month];
            if(empReim.size() > 0) {
                System.debug('empReim - ' + empReim[0]);
                String convMonth = monthNumberMap.get(empReim[0].Month__c.split('-')[0]);
                String year = empReim[0].Month__c.split('-')[1];
                System.debug('month : ' + convMonth + ' - year : ' + year);
                result = WrapperUtils.TripCallout(convDriverId,convMonth,year,String.valueOf(empReim[0].Fuel_Price__c),String.valueOf(empReim[0].Maintenance_and_Tires__c),empReim[0].Id,String.valueOf(empReim[0].MPG__c),'U');
            }
        }
        return result;
    }

    @AuraEnabled
    public static string MassSyncTrips(String accountId,String startDate,String endDate,String month,String tripStatus,String activityStatus){
        MassSyncTripforCommute obj = new MassSyncTripforCommute(accountId,startDate,endDate,month,tripStatus,false,activityStatus);
        Database.executeBatch (obj,1);
        return 'Success';
    }
    @AuraEnabled
    public static boolean getInsuranceStatus(String conId){
        Contact employee = [SELECT Id,Insurance_Attachment_Id__c FROM Contact WHERE id =: conId];
        boolean insurancePage;
        if(employee!=null) {
            if(employee.Insurance_Attachment_Id__c != null) {
                insurancePage = true;
            }
        }
        return insurancePage;
    }

    @AuraEnabled
    public static String getDriverName(String accountId,String managerId,String role){
        Map<Id,String> conMap = new Map<Id,String>();  
        List<contact> driverDataList = new List<contact>();
        if(role=='Admin'){
            driverDataList = [SELECT id,Name,Address__r.Location_Lat_Long__Latitude__s,Address__r.Location_Lat_Long__Longitude__s,Fixed_Amount__c,  MailingCity, MailingState, MailingPostalCode,Reimbursement_Frequency__c,Half_Fixed_Amount__c,Accountid  from Contact  WHERE Accountid =: accountId AND Role__c != 'Admin' and Role__c != 'Manager'];
        } else if(role=='Manager'){
            driverDataList = [SELECT id,Name,Address__r.Location_Lat_Long__Latitude__s,Address__r.Location_Lat_Long__Longitude__s,Fixed_Amount__c,  MailingCity, MailingState, MailingPostalCode,Reimbursement_Frequency__c,Half_Fixed_Amount__c FROM Contact  WHERE (Manager__c =: managerId  OR (Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__c =: managerId) OR (Manager__r.Manager__r.Manager__r.Manager__r.Manager__c =: managerId)) AND Role__c != 'Admin' and Role__c != 'Manager' ];
        }
        
        for(Contact conList : driverDataList ){
            conMap.put(conList.Id,conList.name);
        }
        return json.serialize(conMap).unescapeHtml4();
    }

    @AuraEnabled
    public static string accountMonthList(String accountId){
        return LWCWrapperUtils.accountMonthList(accountId);
    }

    @AuraEnabled
    public static List<Employee_Mileage__c> highRiskMileages(String accID,String AdminId,Integer limitSize, Integer offset){
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        Contact conObj ;
        if(!String.isBlank(AdminId) || !String.isEmpty(AdminId)){
            conObj = [SELECT id,Role__c FROM Contact WHERE id =: AdminId LIMIT 1];
        }
        if(conObj != null && (conObj.Role__c == StaticValues.ROLE_ADMIN || conObj.Role__c == StaticValues.roleAdminDriver)){
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s,EmployeeReimbursement__r.Mileage_Lock_Date__c, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,Trip_Destination_State__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,High_Risk_Mileage__c, StartTime__c, EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Approved_Date__c,Approval_Name__c  FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth AND  EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null AND  High_Risk_Mileage__c = true order by ConvertedStartTime__c desc LIMIT :limitSize];
        }else {
            return [SELECT id,Name,EmployeeReimbursement__r.Contact_Id_Name__c, Stay_Time__c, Driving_Time__c,Trip_Date__c, EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c, Mileage__c,Trip_Origin__c, Trip_Destination__c, Origin_Name__c, Destination_Name__c,ConvertedStartTime__c, ConvertedEndTime__c,Notes__c,Triplog_Map__c,Day_Of_Week__c, Trip_Status__c,EmployeeReimbursement__r.Contact_Id__r.External_Email__c, From_Location__Latitude__s, From_Location__Longitude__s,Trip_Destination_State__c, To_Location__Latitude__s, To_Location__Longitude__s,EmployeeReimbursement__r.Mileage_Lock_Date__c, Tracing_Style__c,Trip_Id__c,Way_Points__c,Tag__c,Activity__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, TimeZone__c,EmployeeReimbursement__r.Month__c,Drive_Stay_Time__c,High_Risk_Mileage__c, StartTime__c,EndTime__c,EMP_Mileage__c,Original_Origin_Name__c,Original_Destination_Name__c,Approved_Date__c,Approval_Name__c   FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: accID  AND EmployeeReimbursement__r.Month__c =: lastMonth AND ((EmployeeReimbursement__r.Contact_Id__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__c =: AdminId)  OR (EmployeeReimbursement__r.Contact_Id__r.Manager__r.Manager__r.Manager__r.Manager__c =: AdminId)  ) AND  EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null AND High_Risk_Mileage__c = true ORDER BY ConvertedStartTime__c DESC LIMIT : limitSize];
        }
    }
    
    @RemoteAction
    Public static void UpdateTimezonAppVer(String accountId) {
    }

    public class monthWrapper{
        public String label{get;set;}
        public string value{get;set;}
    }
}