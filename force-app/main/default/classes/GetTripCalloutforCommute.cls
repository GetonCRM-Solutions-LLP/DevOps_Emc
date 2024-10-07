/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Webservice class to fetch Mileages of contacts from TripLog 
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanjay Halpati - 12 May 2020
 * @Description: Added MLOGACCOUNT to Identify new MLOG API accounts for fetching Trips
 * Added a boolean variable for put call on 09/07/2020
 */
global class GetTripCalloutforCommute {
    
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2; 
    @AuraEnabled
    Webservice static void GetTripCalloutForCommuteMileage(ID empReID, String contactEmail, ID contactid, String priMin, String priMax, String fuel, String mpg, String maintenansAndTires, String apiToken, String tripStatus,Boolean putCall, String activityStatus,Boolean checkByWeek,String biWeekReimId) 
    {
        Contact con = [SELECT id,Account.Pay_Period_Days__c, Account.Pay_Period_Start_Date__c,Account.Bi_Weekly_Pay_Period__c,Driver_Type__c, Account.Name,Time_Zone__c  FROM Contact WHERE id =: contactId];
        List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();   
        List<Employee_Mileage__c> empList = new List<Employee_Mileage__c>();
        Double totalmileages = 0;
        Boolean partimeErmi = false;
        //Request Variables
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        // MLOG URL Change | Sanjay Halpati | 12 May 2020 | START
        String endPoint = 'startDate=' + priMin + '&userEmail=' + contactEmail + '&endDate=' + priMax + '&status=' + tripStatus + '&activity='+ activityStatus;
        system.debug('MLOGACCOUNT ==' + MLOGACCOUNT );
        String baseURL = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        req.setEndpoint(baseURL + StaticValues.GETTRIP_SUFFIX + endPoint );
        // MLOG URL Change | Sanjay Halpati | 12 May 2020 | END
        
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'apikey ' + apiToken);
        HttpResponse res = h.send(req);
        System.debug('Response-->>>'+res);
        Set<Integer> trip_IDs = new Set<Integer>();
        String empMilName = String.valueOf(empReID).substring(0, 15);
        Integer index = 0;
        if(res.getStatusCode() == 200) {
            TripLogDeserializeClass tripLog = TripLogDeserializeClass.parse(res.getBody());
            List<TripLogDeserializeClass.Trips> listTrips = tripLog.trips;
            Datetime MaxTime;
            Boolean CheckHomeTrip = false;
            String BiWeekId;
            if(checkByWeek == false){
                BiWeekId = getBiWeekReimId(contactid);
            }
            Date minTripdate;
            Date maxtripdate;
            Map<String, Id> biWeeklyReimMap = new Map<String, Id>();
            if(checkByWeek) {
                for(TripLogDeserializeClass.Trips lt : listTrips) 
                {
                    if(!CheckNull(lt.startTime)) {
                        Date tripDate = Date.valueof(lt.startTime.split('T')[0]);
                        minTripdate = minTripdate == null ? tripDate : tripDate < minTripDate ? tripDate : minTripDate;
                        maxtripdate = maxtripdate == null ? tripDate : tripDate > maxtripdate ? tripDate : maxtripdate;
                    } 
                }
                
                if(minTripDate != null && maxTripDate != null) {
                    //Integer payDays = Integer.valueOf([SELECT id,Account.Pay_Period_Days__c, Account.Pay_Period_Start_Date__c,Account.Bi_Weekly_Pay_Period__c FROM Contact WHERE id =: contactId].Account.Pay_Period_Days__c);
                    Integer payDays = con.Account.Pay_Period_Days__c != null ? Integer.valueOf(con.Account.Pay_Period_Days__c) : 0;//13
                    if((con.Driver_Type__c == 'Driver - Full Time' || con.Driver_Type__c == 'Driver - Part Time') ){
                        partimeErmi = true;//NULL
                    }
                    minTripDate = minTripDate.addDays(-1 * payDays);
                    System.debug('minTripDate : ' + minTripDate);

                    maxtripdate = maxtripdate.addDays(payDays);
                    System.debug('maxtripdate : ' + maxtripdate);

                    biWeeklyReimMap = BiWeeklyWrapperUtils.getBiweeklyReimMap (contactId, minTripDate, maxTripDate, true);
                }
            } else {
                biWeeklyReimMap = BiWeeklyWrapperUtils.getBiweeklyReimMap (contactId, minTripDate, maxTripDate, false);
            }
            System.debug('biWeeklyReimMap : ' + biWeeklyReimMap);

            /**** Create Employee Mileage Record ****/
            for(TripLogDeserializeClass.Trips lt : listTrips) 
            {   System.debug('lt.id=='+lt);  
                Employee_Mileage__c emp = new Employee_Mileage__c();
                emp.Name = 'EMP-' + empMilName + index;
                emp.Trip_Status__c = StaticValues.noApprovedYet;
                emp.Trip_Id__c = lt.id;
                System.debug('lt.id=='+lt.id);    
                emp.Mileage__c = lt.mileage;
                emp.EMP_Mileage__c = lt.mileage;
                //AI-000408
                /*if(emp.Mileage__c == null || emp.Mileage__c == 0) {
                    emp.Trip_Status__c = 'Approved';
                    emp.Approved_Date__c = System.Today();
                }*/
                emp.Last_Updated_In_Mlog__c = lt.lastUpdated;
                emp.Activity__c = lt.activity;
                if(emp.Activity__c == 'Commute' && emp.Mileage__c >= 30) {
                    emp.Mileage__c = emp.Mileage__c - 30;
                } else if(emp.Activity__c == 'Commute'){
                    emp.Mileage__c = 0;
                }
                emp.EmployeeReimbursement__c = empReID;
                emp.Contact_Email_Id__c = contactEmail;
                System.debug('Before operation : ' + lt.startTime + ':::' + lt.endTime);
                emp.StartTime__c = !CheckNull(lt.startTime) ? ConvertToDateTime(lt.startTime) : null;
                emp.EndTime__c = !CheckNull(lt.endTime) ? ConvertToDateTime(lt.endTime) : null;
                
              System.debug('After operation : ' + emp.StartTime__c + ':::' + emp.EndTime__c);
                emp.Day_Of_Week__c = !CheckNull(lt.startTime) ? emp.StartTime__c.format('EEEE') : null;
                emp.Fuel_price__c = !CheckNull(fuel) ? Decimal.valueof(fuel) : null;
                emp.MPG__c = !CheckNull(mpg) ? Decimal.valueof(mpg) : null;
                emp.Maintenance_and_Tires__c = !CheckNull(maintenansAndTires) ? Decimal.valueof(maintenansAndTires) : null;
                
                TripLogDeserializeClass.FromLocation fromLocationOfTrip = lt.fromLocation;
                if(fromLocationOfTrip != null && fromLocationOfTrip.id != null ) {
                    emp.FromLocationId__c = fromLocationOfTrip.id;                    
                    if(fromLocationOfTrip.name != null) {
                        emp.Origin_Name__c = String.valueOf(fromLocationOfTrip.name); 
                        emp.Original_Origin_Name__c = String.valueOf(fromLocationOfTrip.name); 
                    } else {
                        emp.Origin_Name__c = fromLocationOfTrip.address;
                        emp.Original_Origin_Name__c = null;
                    }
                    emp.From_Location__latitude__s = fromLocationOfTrip.latitude != null ? Decimal.valueOf(fromLocationOfTrip.latitude): null;
                    emp.From_Location__longitude__s = fromLocationOfTrip.longitude != null ? Decimal.valueOf(fromLocationOfTrip.longitude): null;
                    if(fromLocationOfTrip.address != null) {
                        emp.Trip_Origin__c = fromLocationOfTrip.address;
                    }
                }
                TripLogDeserializeClass.FromLocation toLocationOfTrip = lt.toLocation;
                if(toLocationOfTrip != null && toLocationOfTrip.id != null ) {
                    emp.ToLocationId__c = toLocationOfTrip.id;                    
                    if(toLocationOfTrip.name != null) {
                        emp.Destination_Name__c = String.valueOf(toLocationOfTrip.name);
                        emp.Original_Destination_Name__c =  String.valueOf(toLocationOfTrip.name);  
                    } else {
                        emp.Destination_Name__c = toLocationOfTrip.address;
                        emp.Original_Destination_Name__c = null;
                    }
                    emp.To_Location__latitude__s = toLocationOfTrip.latitude != null ? Decimal.valueOf(toLocationOfTrip.latitude): null;
                    emp.To_Location__longitude__s = toLocationOfTrip.longitude != null ? Decimal.valueOf(toLocationOfTrip.longitude): null;
                    if(toLocationOfTrip.address != null) {
                        emp.Trip_Destination__c = toLocationOfTrip.address;
                    }
                }

                emp.Notes__c = !CheckNull(String.valueOf(lt.notes)) ? String.valueOf(lt.notes) : null;
                emp.Tracing_Style__c = !CheckNull(String.valueOf(lt.trackingMethod)) ? String.valueOf(lt.trackingMethod) : null;
                emp.Tag__c = !CheckNull(String.valueOf(lt.tags)) ? String.valueOf(lt.tags) : null;
                emp.Stay_Time__c = !CheckNull(String.valueOf(lt.stayTimeMins)) ? lt.stayTimeMins : null;
                /*if( MaxTime != null && emp.StartTime__c.day() > MaxTime.day() && !empList.isEmpty()){
                    empList.get(empList.size()-1).Stay_Time__c = 0;
                }
                MaxTime = emp.EndTime__c;*/
                if(emp.Destination_Name__c != null && (emp.Destination_Name__c).toUppercase() == 'HOME'){
                   CheckHomeTrip = true;
                }
                if(emp.Origin_Name__c != null && (emp.Origin_Name__c).toUppercase() == 'HOME' && CheckHomeTrip == true){
                   emp.Stay_Time__c = 0;
                   CheckHomeTrip = false;
                }
                if(!CheckNull(lt.map_Z)){
                    emp.Triplog_Map__c = baseURL + '/kml/embed/' +  ( lt.map_Z.contains('/') ? lt.map_Z.split('/')[4] : ''); // MLOG Change | Sanjay Halpati | 12 May 2020
                } else {
                    emp.Triplog_Map__c = null;
                }

                emp.Trip_Date__c = !CheckNull(lt.startTime) ? Date.valueof(lt.startTime.split('T')[0]) : null;
                if(biWeekReimId != null && biWeekReimId != ''){
                    System.debug('169');

                    emp.Bi_Weekly_Reimbursement__c = biWeekReimId;
                     system.debug('------------------->172'+biWeekReimId);
                } else if(checkByWeek == false && BiWeekId != null){
                    system.debug('------------------->174'+BiWeekId);
                    emp.Bi_Weekly_Reimbursement__c = BiWeekId;
                } else {
                    if(Test.isRunningTest()){
                        emp.Bi_Weekly_Reimbursement__c =[Select Id From Bi_Weekly_Reimbursement__c Limit 1].Id; 
                    }else{
                        
                        emp.Bi_Weekly_Reimbursement__c = checkByWeek ? getReimId(emp.Trip_Date__c, biWeeklyReimMap) : biWeeklyReimMap.values()[0];//BiWeeklyWrapperUtils.getBiweekReimId(contactid,emp.Trip_Date__c,checkByWeek);
                        system.debug('------------------->182'+emp.Bi_Weekly_Reimbursement__c);    
                    }
                    
                }     
                if(emp.EMP_Mileage__c > 0 || partimeErmi == true){
                    empList.add(emp);
                } 
                trip_IDs.add(Integer.valueOf(lt.id));
                totalmileages += !CheckNull(String.valueOf(emp.Mileage__c)) ? Double.valueof(emp.Mileage__c) : 0;    
                index ++;                
            }

            Integer successCount = 0;
            if(!empList.isEmpty()) {
                SendEmailToMe__c objSendEmailToMe = SendEmailToMe__c.getValues('GetTripCallOutApprovePutCall');
                if(objSendEmailToMe.Send_email_to_me__c && putCall == true){
                    GetTripCallout.putHTTP(apiToken, contactid, empReID, trip_IDs); 
                }
                System.debug('empList=='+empList);
                
                Database.UpsertResult[] insertedTrips = Database.upsert(empList,Employee_Mileage__c.Fields.Trip_Id__c, true);
                System.debug('insertedTrips=='+insertedTrips );
                for(Database.UpsertResult srresult : insertedTrips) {
                System.debug('srresult =='+srresult );
                    if(srresult.isSuccess())
                        successCount ++;
                }
               
            }
            Tripslog__c obj = new Tripslog__c();
            obj.Contact__c = contactid;
            obj.Employee_Reimbursement__c = empReID;
            obj.Endpoint__c = baseURL + StaticValues.GETTRIP_SUFFIX + endPoint;
            obj.Response__c = String.valueOf(res.getStatusCode())+' ### ' +res.getStatus();
            obj.Status__c ='Success'; 
            obj.Total_Trips__c= successCount;
            obj.Total_Mileages__c = totalmileages;
            obj_Tripslog_list.add(obj); 
        }
        else {
            Tripslog__c obj = new Tripslog__c();
            obj.Contact__c = contactid;
            obj.Employee_Reimbursement__c = empReID;
            obj.Endpoint__c = baseURL + StaticValues.GETTRIP_SUFFIX + endPoint;
            obj.Response__c = String.valueOf(res.getStatusCode())+' ### ' +res.getStatus();
            obj.Status__c ='Fail'; 
            obj.Total_Trips__c = 0;
            obj.Total_Mileages__c = 0;
            obj_Tripslog_list.add(obj); 
        }
        if(!obj_Tripslog_list.isEmpty()) {
            //insert obj_Tripslog_list;
            
            /*if(!System.isBatch() && !Test.isRunningTest()) {
                Database.executeBatch(new LoadMileageLocationBatch(new Set<Id>{ empReID }, true ),50);
            }*/
        }
    }

    public static void putHTTP(String apiToken,String contactid,String empReID, Set<Integer> trip_IDs) {
        
        List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();
        HttpRequest putReq = new HttpRequest();
        Http putHTTP = new Http();
        String body = '{"status":"Submitted","ids":[';
        String part = '';

        for (Integer i : trip_IDs) {
            part += String.valueof(i) + ',';
        }
        part = part.removeEnd(',');
        body += part +']}';
        String endPoint = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        endPoint += StaticValues.STATUS_SUFFIX;
        putReq.setEndpoint(endPoint);
        putReq.setMethod('PUT');                 
        putReq.setBody(body);
        putReq.setTimeout(120000);
        putReq.setHeader('Authorization', 'apikey ' + apiToken);
        HttpResponse putRes = putHTTP.send(putReq);

        Tripslog__c obj = new Tripslog__c();
        obj.Body__c = body;
        obj.Contact__c = contactid;
        obj.Employee_Reimbursement__c = empReID;
        obj.Endpoint__c = endPoint;
        if(!Test.IsRunningTest())
        {
            obj.Response__c = String.valueOf(putRes.getStatusCode()) + ' ######## ' + putRes.getStatus();
        }
        
        obj.Total_Trips__c= 0;
        obj.Total_Mileages__c = 0;
        obj.Status__c = putRes.getStatusCode() == 200 ? 'Success' : 'Fail';
        obj_Tripslog_list.add(obj);

        if(!obj_Tripslog_list.isEmpty()) {
            //insert obj_Tripslog_list;
        }
    }

    public static Boolean CheckNull(String param1) {
        return param1 == null || param1 == '' ? true : false;
    }

    public Static DateTime ConvertToDateTime(String param1) {
        
        param1 = param1.replace(':','-');
        param1 = param1.replace('T','-');
        DateTime gmtDateTime= DateTime.newInstanceGMT(
                Integer.valueof(param1.split('-')[0]), 
                Integer.valueof(param1.split('-')[1]), 
                Integer.valueof(param1.split('-')[2]), 
                Integer.valueof(param1.split('-')[3]), 
                Integer.valueof(param1.split('-')[4]), 
                Integer.valueof(param1.split('-')[5].removeEnd('.000Z')));
        TimeZone panamaTZ = TimeZone.getTimeZone('America/Panama');
        DateTime panamaDateTime = gmtDateTime.addSeconds(-panamaTZ.getOffset(gmtDateTime) / 1000);
        return panamaDateTime;
    }
    public static string getBiWeekReimId (String ContactId){
        String biWeekId;
        for(Bi_Weekly_Reimbursement__c biWeekObj: [SELECT id,Start_Date__c, End_Date__c,Contact__c FROM Bi_Weekly_Reimbursement__c WHERE Contact__c =: contactId Limit 1] ) {
            biWeekId = biWeekObj.Id;
        }
        return biWeekId;
    }
    
    public Static string getReimId(Date tripDate, Map<String, Id> biWeeklyMap) {
        if(tripDate == null)  return null;

        for(String key : biWeeklyMap.keySet()) {
            system.debug('key== '+key );
            if(key.contains(':')){
                Date st = Date.parse(key.split(':')[0]);
                Date et = Date.parse(key.split(':')[1]);
                
                if(tripdate >= st && tripDate <= et) {
                    return biWeeklyMap.get(key);
                }
            }            
        }
        return null;
    }
}