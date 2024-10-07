global class GetTripBatchClass implements Database.Batchable<sObject>,Database.AllowsCallouts {
   
    public Map<String,Employee_Reimbursement__c> contactEmployeeReimbursementMap;
    public String query, tripStatus;
    public String accounttripstatusnew;/*not needed*/
    public List<String> obj_reimbersmentid_list{get;set;}
    public Map<String,List<Employee_Reimbursement__c>> obj_contact_reimebersment_list_map{get;set;}
    global string finalstr{get;set;}
    public static final String changeURL = System.Label.Triplog_URL_For_TripStatus;//'https://triplogmileage.com/web/api/tripStatus';
    public static final String URL = System.Label.Triplog_URL_For_Trips;//'https://triplogmileage.com/web/api/trips?';
    public static HttpRequest req, putReq;
    public static HttpResponse res, putRes;
    public static Http h,putHTTP;
    public static TripLogJSONClass.TripLogJSONClassInner tripLog;
    public static Set<Integer> trip_IDs;
    public Map<String,Contact> contactMap;
    // Constructor with parameter
    global GetTripBatchClass(Id accId, String accoutTripStatus) 
    {
        Integer lastndays = numOfDayInPreviousMonth(-1);
        if(Test.isRunningTest()) 
        {
            query = 'SELECT Id, Name,Account.Name, External_Email__c,Email, AccountId, Account.Triplog_API__c FROM Contact WHERE External_Email__c = \'minkesh.patel1478@gmail.com\' LIMIT 1';
        } 
        else 
        {
            query = 'SELECT Id,Account.Name, Name, External_Email__c,Email, AccountId, Account.Triplog_API__c FROM Contact WHERE AccountId = \'' + accId + '\' AND Account.isUsingTriplog__c = true AND isCommunityUser__c = true AND (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:'+lastndays+') AND (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\')';
        }
        tripStatus = accoutTripStatus; 
    }
    // Constructor with parameter
    global GetTripBatchClass(List<Id> contactIds, String contactTripStatus) 
    {      
        String SOQL_IDs = '';
        for(Id id : contactIds) {
            String id_in_quotes = '\''+id+'\'';
            if (SOQL_IDs!='') { 
                SOQL_IDs+=','; 
            }
            SOQL_IDs += id_in_quotes;
        }
        Integer lastndays = numOfDayInPreviousMonth(-1);
        if(Test.isRunningTest()) 
        {
            query = 'SELECT Id, Name,Account.Name, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE External_Email__c = \'minkesh.patel1478@gmail.com\' LIMIT 1';
        } 
        else 
        {
            query = 'SELECT Id, Name, Account.Name, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE Id In ('+SOQL_IDs+') AND Account.isUsingTriplog__c = true AND (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:'+lastndays+') AND isCommunityUser__c = true AND (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\')';
        }
        tripStatus = contactTripStatus;
    }

    // Constructor without parameter
    global GetTripBatchClass(String trip) 
    {
        List<String> obj_accountnames = new List<String>();
        List<String> obj_accountnames1 = new List<String>();
        Integer lastndays = numOfDayInPreviousMonth(-1);
        String querybuilding ='';
        if(System.Label.TripstobeLogged!=null)
        {
            if(System.Label.TripstobeLogged.contains(','))
            {
                obj_accountnames= System.Label.TripstobeLogged.split(',');
            }
            Integer i=0;    
            for(String s:obj_accountnames)
            {
                s = s.trim();
                if(s.contains(','))
                {
                    s = s.replace(',','');
                }
                if(i==0)
                {
                    querybuilding = ' ( Account.Name = \''+s+'\'';    
                }
                else
                {
                    querybuilding = querybuilding+ ' OR '+ 'Account.Name = \''+s+'\'';
                }        
                i++;
            }
            querybuilding = querybuilding+' ) AND ';
        }
        
        if(Test.isRunningTest()) 
        {
            query = 'SELECT Id, Name,Account.Name, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE External_Email__c = \'minkesh.patel1478@gmail.com\' LIMIT 1';
        } 
        else 
        {
            query = 'SELECT Id, Name,Account.Name, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE'+querybuilding+' (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:'+lastndays+') AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND (Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\')';
        }
        tripStatus = trip;
    }
    global GetTripBatchClass() 
    {       
        Integer lastndays = numOfDayInPreviousMonth(-1);
        if(Test.isRunningTest()) 
        {
            query = 'SELECT Id, Name,Account.Name, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE External_Email__c = \'minkesh.patel1478@gmail.com\' LIMIT 1';
        } 
        else 
        {
            query = 'SELECT Id, Name,Account.Name, External_Email__c, Email, Account.Triplog_API__c FROM Contact WHERE (Deactivated_Date__c = NULL OR Deactivated_Date__c >= LAST_N_DAYS:'+lastndays+') AND isCommunityUser__c = true AND Account.isUsingTriplog__c = true AND ( Role__c = \''+StaticValues.roleAdminDriver+'\' OR Role__c = \'Driver\' OR Role__c = \'Driver/Manager\')';
        }

        tripStatus = 'U';
    }
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }
    //Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        obj_reimbersmentid_list = new List<String>();
        obj_contact_reimebersment_list_map = new Map<String,List<Employee_Reimbursement__c>>();
        contactMap = new Map<String,Contact>();
        String lastMonthYear,firstDateOfLastMonth,LastDateOfLastMonth;
        Integer lastMonth,lastYear;

        Date lastMonthDate = date.today().addmonths(-1);
        Date lastMonthOfFirstDate = date.newInstance(lastMonthDate.year(), lastMonthDate.month(), 1);
        Integer numberOfDays = Date.daysInMonth(lastMonthOfFirstDate.year(), lastMonthOfFirstDate.month());
        Date lastMonthOfLastDate = Date.newInstance(lastMonthOfFirstDate.year(), lastMonthOfFirstDate.month(), numberOfDays);
        
        lastMonth = lastMonthOfFirstDate.Month();
        lastYear = lastMonthOfFirstDate.Year();
        firstDateOfLastMonth = String.valueOf(lastMonthOfFirstDate);
        LastDateOfLastMonth = String.valueOf(lastMonthOfLastDate);

        if(String.valueOf(lastMonth).length() == 1) 
        {
            lastMonthYear = '0' + lastMonth+'-'+lastYear;
        } 
        else 
        {
            lastMonthYear = lastMonth+'-'+lastYear;
        }
        contactEmployeeReimbursementMap = new Map<String,Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c empReim : [SELECT Id,Contact_Id__c,Contact_Id__r.Account.Triplog_API__c, Total_Mileage_WithOut_Previous__c, Contact_Id__r.Monthly_Mileage_Limit__c,Contact_Email__c,Month__c,Fuel_price__c, MPG__c, Maintenance_and_Tires__c FROM Employee_Reimbursement__c where month__c =: lastMonthYear]) 
        {
            obj_reimbersmentid_list.add(empReim.id);
            contactEmployeeReimbursementMap.put(empReim.Contact_Email__c+'-'+empReim.Month__c,empReim);
            if(obj_contact_reimebersment_list_map.containsKey(empReim.Contact_Id__c))
            {
                List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = obj_contact_reimebersment_list_map.get(empReim.Contact_Id__c);
                obj_Employee_Reimbursement_list.add(empReim);
                obj_contact_reimebersment_list_map.remove(empReim.Contact_Id__c);
                obj_contact_reimebersment_list_map.put(empReim.Contact_Id__c,obj_Employee_Reimbursement_list);
            }
            else
            {
                List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = new List<Employee_Reimbursement__c>();
                obj_Employee_Reimbursement_list.add(empReim);
                obj_contact_reimebersment_list_map.put(empReim.Contact_Id__c,obj_Employee_Reimbursement_list);
            }
        }
        
        Map<String,String> obj_mileage_tripids = new Map<String,String>();
        for(Employee_Mileage__c mileage : [SELECT Id,Trip_Id__c,EmployeeReimbursement__c,EmployeeReimbursement__r.Contact_Id__c,EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c WHERE EmployeeReimbursement__c=:obj_reimbersmentid_list])
        {
            if(mileage.Trip_Id__c!=null && (!obj_mileage_tripids.containsKey(String.valueOf(mileage.Trip_Id__c))))
            {
                obj_mileage_tripids.put(String.valueOf(mileage.Trip_Id__c),String.valueOf(mileage.Trip_Id__c));
            }
        }
        Integer sizeoftrips=0;  
        List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();
        List<Employee_Mileage__c> empList = new List<Employee_Mileage__c>();
        Set<Employee_Mileage__c> mileageset = new Set<Employee_Mileage__c>();
        for(Contact con : (List<Contact>)Scope) 
        {
            Double totalmileages=0;
            if(con.Account.Triplog_API__c != null && con.Account.Triplog_API__c != '') 
            {
                if(contactEmployeeReimbursementMap.containsKey(con.External_Email__c+'-'+lastMonthYear)) 
                {
                    Employee_Reimbursement__c reim = contactEmployeeReimbursementMap.get(con.External_Email__c+'-'+lastMonthYear);
                    String reimFuel = String.valueof(reim.Fuel_price__c) != null ? String.valueof(reim.Fuel_price__c):'';
                    String reimMPG = String.valueof(reim.MPG__c) != null ? String.valueof(reim.MPG__c):'';
                    String reimMAT = String.valueof(reim.Maintenance_and_Tires__c) != null ? String.valueof(reim.Maintenance_and_Tires__c):'';

                    contactMap.put(con.External_Email__c,con);
                    if(reim != null && con.Email != null) 
                    {
                        String endPoint;
                        finalstr ='';
                        Set<Employee_Mileage__c> empSet = new Set<Employee_Mileage__c>();
                        
                        Employee_Mileage__c emp;        
                        endPoint = 'startDate='+firstDateOfLastMonth+'&userEmail='+con.Email+'&endDate='+LastDateOfLastMonth+'&status='+System.Label.Trips+'&activity=Business';
                        
                        res = ApiCalloutUtility.executeCallout(con.Account.Triplog_API__c,'GET',URL.trim(),endPoint,'');
                        trip_IDs = new Set<Integer>();
                        if(res.getStatusCode() == 200) 
                        {                
                            tripLog = TripLogJSONClass.parse(res.getBody());
                            List<TripLogJSONClass.Trips> listTrips = tripLog.trips;
                            /**** Create Employee Mileage Record ****/
                            
                            for(TripLogJSONClass.Trips lt : listTrips) 
                            {   
                                if(!obj_mileage_tripids.containsKey(String.valueOf(lt.id))){
                                    emp = new Employee_Mileage__c();        
                                    emp.Name = 'Test ';
                                    emp.Trip_Id__c = lt.Id;
                                    emp.Trip_Status__c = Label.Not_Approved_Yet_Mileage_Status;
                                    emp.Mileage__c = lt.mileage;
                                    if(emp.Mileage__c == null || emp.Mileage__c == 0) {
                                        emp.Trip_Status__c = 'Approved';
                                        emp.Approved_Date__c = System.Today();
                                    }
                                    emp.EmployeeReimbursement__c = reim.id;
                                    emp.Contact_Email_Id__c = con.Email;
                                    if(lt.startTime != null && lt.startTime != '') {
                                        string dateda = lt.startTime;
                                        dateda = dateda.replace(':','-');
                                        dateda = dateda.replace('T','-');
                                        DateTime myDateTime = DateTime.newInstance(integer.valueof(dateda.split('-')[0]), integer.valueof(dateda.split('-')[1]), integer.valueof(dateda.split('-')[2]), integer.valueof(dateda.split('-')[3]), integer.valueof(dateda.split('-')[4]), integer.valueof(dateda.split('-')[5].removeEnd('.000Z')));
                                        emp.StartTime__c = myDateTime;
                                        emp.Day_Of_Week__c = myDateTime.format('EEEE');
                                    } else {
                                        emp.StartTime__c = null;
                                    }
                                    if(lt.endTime != null && lt.endTime != '') {
                                        string dateda = lt.endTime;
                                        dateda = dateda.replace(':','-');
                                        dateda = dateda.replace('T','-');
                                        DateTime myDateTime = DateTime.newInstance(integer.valueof(dateda.split('-')[0]), integer.valueof(dateda.split('-')[1]), integer.valueof(dateda.split('-')[2]), integer.valueof(dateda.split('-')[3]), integer.valueof(dateda.split('-')[4]), integer.valueof(dateda.split('-')[5].removeEnd('.000Z')));
                                        emp.EndTime__c = myDateTime;
                                    } else {
                                        emp.EndTime__c = null;
                                    }
                                    if(reimFuel != null && reimFuel != '') {
                                        emp.Fuel_price__c = decimal.valueof(reimFuel);
                                    } else {
                                        emp.Fuel_price__c = null;
                                    }
                                    if(reimMPG != null && reimMPG != '') {
                                        emp.MPG__c = decimal.valueof(reimMPG);
                                    } else {
                                        emp.MPG__c = null;
                                    }
                                    if(reimMAT != null && reimMAT != '') {
                                        emp.Maintenance_and_Tires__c = decimal.valueof(reimMAT);
                                    } else {
                                        emp.Maintenance_and_Tires__c = null;
                                    }
                                    if(lt.fromLocation != null && lt.fromLocation.display != null) {
                                        if(lt.fromLocation.display.contains(','))
                                        {
                                           emp.Origin_Name__c = (lt.fromLocation.display.split(','))[0];  
                                        }
                                        else if(lt.fromLocation.display.contains(' '))
                                        {
                                            emp.Origin_Name__c = (lt.fromLocation.display.split(' '))[0];
                                        }
                                        else
                                        {
                                           emp.Origin_Name__c =  lt.fromLocation.display;
                                        }
                                    }
                                    if(lt.toLocation != null && lt.toLocation.display != null) {
                                        if(lt.toLocation.display.contains(','))
                                        {
                                           emp.Destination_Name__c = (lt.toLocation.display.split(','))[0];  
                                        }
                                        else if(lt.toLocation.display.contains(' '))
                                        {
                                            emp.Destination_Name__c = (lt.toLocation.display.split(' '))[0];
                                        }
                                        else
                                        {
                                           emp.Destination_Name__c =  lt.toLocation.display;
                                        }
                                    }
                                    if(lt.notes != null && lt.notes != '') {
                                        emp.Notes__c = lt.notes;
                                    } else {
                                        emp.Notes__c = null;
                                    }
                                    if(lt.trackingMethod != null && lt.trackingMethod != '') {
                                        emp.Tracing_Style__c = lt.trackingMethod;
                                    } else {
                                        emp.Tracing_Style__c = null;
                                    }
                                    String myDate = lt.startTime;
                                    String[] d = myDate.split('T');
                                    emp.Trip_Date__c = Date.valueof(d[0]);
                                    mileageset.add(emp);
                                    trip_IDs.add(Integer.valueOf(lt.id));
                                    totalmileages = totalmileages+Double.valueOf(emp.Mileage__c); 
                                }
                            }
                            
                            Tripslog__c obj = new Tripslog__c();
                            obj.Contact__c = con.id;
                            obj.Employee_Reimbursement__c = reim.id;
                            obj.Endpoint__c = URL.trim()+endPoint;
                            obj.Response__c = String.valueOf(res.getStatusCode())+' ### ' +res.getStatus();
                            obj.Status__c ='Success'; 
                            obj.Total_Trips__c= mileageset.size();
                            obj.Total_Mileages__c = totalmileages;
                            obj_Tripslog_list.add(obj); 
                        }
                        else
                        {
                            Tripslog__c obj = new Tripslog__c();
                            obj.Contact__c = con.id;
                            obj.Employee_Reimbursement__c = reim.id;
                            obj.Endpoint__c = URL.trim()+endPoint;
                            obj.Response__c = String.valueOf(res.getStatusCode())+' ### ' +res.getStatus();
                            obj.Status__c ='Fail'; 
                            obj.Total_Trips__c= mileageset.size();
                            obj.Total_Mileages__c = totalmileages;
                            obj_Tripslog_list.add(obj); 
                        }
                    }
                }
            }
        }
        if(mileageset.size() > 0) 
        {
            for(Employee_Mileage__c mil : mileageset){
                empList.add(mil);
            }    
        }
        
        if(empList.size() > 0){
            SendEmailToMe__c objSendEmailToMe = SendEmailToMe__c.getValues('GetTripCallOutApprovePutCall');
            if(objSendEmailToMe.Send_email_to_me__c == true){
                for(Employee_Mileage__c emp : empList){
                    
                    if(contactMap.containsKey(emp.Contact_Email_Id__c)){
                        String apiToken = contactMap.get(emp.Contact_Email_Id__c).Account.Triplog_API__c;
                        String contactid = contactMap.get(emp.Contact_Email_Id__c).Id;
                        putHTTP(apiToken,contactid,emp.EmployeeReimbursement__c);    
                    }
                }
            }                  
            insert empList;
        }
        if(obj_Tripslog_list.size()>0)
        {
            insert obj_Tripslog_list;
        }
            
    }
    
    public Integer numOfDayInPreviousMonth(Integer mon){
        Date LastMonth = date.today().addmonths(mon);
        Date FirstOfLastMonth = date.newInstance(Lastmonth.year(), lastmonth.month(), 1);
        Integer numberOfDays = Date.daysInMonth(FirstOfLastMonth.year(), FirstOfLastMonth.month());
        Date LastDayOfLastMonth = Date.newInstance(FirstOfLastMonth.year(), FirstOfLastMonth.month(), numberOfDays);
        return numberOfDays;
    }

    public static void putHTTP(String apiToken,String contactid,String empReID) {
        List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();
        String part = '';
        putRes = new HttpResponse();
        String body = '{"status":"Approved","ids":[';
        for (Integer i : trip_IDs) {
            part = part + String.valueof(i) +',';
        }
        part = part.removeEnd(',');
        body = body + part +']}';
        
        putRes = ApiCalloutUtility.executeCallout(apiToken,'PUT',changeURL,'',body);
        Tripslog__c obj = new Tripslog__c();
        /*obj.Body__c = body;*/
        obj.Contact__c = contactid;
        obj.Employee_Reimbursement__c = empReID;
        obj.Endpoint__c = changeURL;
        if(!Test.IsRunningTest())
        {
            obj.Response__c = String.valueOf(putRes.getStatusCode())+' ######## ' +putRes.getStatus();
        }
        
        obj.Total_Trips__c= 0;
        obj.Total_Mileages__c = 0;
        
        if(putRes.getStatusCode() == 200)
        {               
            obj.Status__c ='Success';
        }
        else
        {
            obj.Status__c ='Fail';
        }
        obj_Tripslog_list.add(obj);
        if(obj_Tripslog_list.size()>0)
        {
            insert obj_Tripslog_list;
        }
    }

    global void finish(Database.BatchableContext BC) 
    {
       
    }
}