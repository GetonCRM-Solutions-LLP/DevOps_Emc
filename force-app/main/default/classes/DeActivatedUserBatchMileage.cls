/**
 * @Autor:  GetonCRM Solutions LLP
 * @Description:  Batch to fetch trips for deactivate Users
 */
global class DeActivatedUserBatchMileage implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    private static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    public Integer decider;

    // Added by sanjay
    public final List<string> monthsList = utils.fetchMonths(2, -1);
    public List<string> contactIds;
    public String userId;
    public String query;
    public final List<Employee_Reimbursement__c> currentMonthreimbursementsList;
    
    global DeActivatedUserBatchMileage() {
        decider = 0;
        query = 'SELECT Id, Fuel_Price__c, MPG__c, Maintenance_and_Tires__c, Contact_Id__r.Triplog_UserID__c, Contact_Id__r.Deactivated_Date__c,' +  
                'Contact_Id__r.External_Email__c, Contact_Id__r.IsDeactivated__c, Contact_Id__r.Account.Triplog_API__c, Contact_Id__r.Employee_ID__c,' + 
                'Month__c, Contact_Id__r.Account.Timezone__c, Contact_Id__r.AccountId' + 
                ' FROM Employee_Reimbursement__c ' +
                ' WHERE Contact_Id__r.Deactivated_Date__c = Today AND Month__c IN: monthsList ' + 
                ' AND Contact_Id__r.Account.Triplog_API__c != null' +
                ' AND Contact_Id__r.IsDeactivated__c = false';  
        query += (!Test.isRunningTest() ? '' : ' LIMIT 1');   
        
        this.currentMonthreimbursementsList = [SELECT Id, 
                                                    Month__c, 
                                                    Contact_Id__c 
                                                FROM Employee_Reimbursement__c
                                                WHERE Contact_Id__r.Deactivated_Date__c = Today 
                                                AND Month__c In: utils.fetchMonths(1, 0)
                                                AND Contact_Id__r.Account.Triplog_API__c != null
                                                AND Contact_Id__r.IsDeactivated__c = false];
    }
    global DeActivatedUserBatchMileage(List<String> contactIds) {
        System.debug('@@@@ Called from DeActivatedUserBatchMileage @@@@@');
        decider = 1;
        this.contactIds = contactIds;
        query = 'SELECT Id, Fuel_Price__c, MPG__c, Maintenance_and_Tires__c, Contact_Id__r.Triplog_UserID__c, Contact_Id__r.Deactivated_Date__c,' +  
                'Contact_Id__r.External_Email__c, Contact_Id__r.IsDeactivated__c, Contact_Id__r.Account.Triplog_API__c, Contact_Id__r.Employee_ID__c,' + 
                'Month__c, Contact_Id__r.Account.Timezone__c, Contact_Id__r.AccountId' + 
                ' FROM Employee_Reimbursement__c ' +
                ' WHERE Contact_Id__c In: contactIds' +
                ' AND Contact_Id__r.Account.Triplog_API__c != null';
        
        query += (!Test.isRunningTest() ? ' AND Month__c IN: monthsList' : ' LIMIT 1');
        this.currentMonthreimbursementsList = [SELECT Id, 
                                                    Month__c, 
                                                    Contact_Id__c 
                                                FROM Employee_Reimbursement__c
                                                WHERE Month__c In: utils.fetchMonths(1, 0)
                                                AND Contact_Id__r.Account.Triplog_API__c != null
                                                AND Contact_Id__c In : contactIds]; 
    
    }
    global DeActivatedUserBatchMileage(String userId) {
        decider = 2;
        this.userId = userId;
        query = 'SELECT Id, Fuel_Price__c, MPG__c, Maintenance_and_Tires__c, Contact_Id__r.Triplog_UserID__c, Contact_Id__r.Deactivated_Date__c,' +  
                'Contact_Id__r.External_Email__c, Contact_Id__r.IsDeactivated__c, Contact_Id__r.Account.Triplog_API__c, Contact_Id__r.Employee_ID__c,' + 
                'Month__c, Contact_Id__r.Account.Timezone__c, Contact_Id__r.AccountId' + 
                ' FROM Employee_Reimbursement__c ' +
                ' WHERE Contact_Id__r.Account.Triplog_API__c != null';
        if(!Test.isRunningTest()) {
            query += ( userId.left(3) == '001' ? ' AND Contact_Id__r.AccountId = ' : ' AND Contact_Id__c = ' )  + '\'' + userId + '\'';
            query += ' AND Month__c IN: monthsList';
        } else {
            query += ' LIMIT 1';
        }

        if(userId.left(3) == '001') {
            this.currentMonthreimbursementsList = [SELECT Id, 
                                                    Month__c, 
                                                    Contact_Id__c 
                                                FROM Employee_Reimbursement__c
                                                WHERE Month__c In: utils.fetchMonths(1, 0)
                                                AND Contact_Id__r.Account.Triplog_API__c != null
                                                AND Contact_Id__r.AccountId =: userId]; 
            
        } else {
            this.currentMonthreimbursementsList = [SELECT Id, 
                                                    Month__c, 
                                                    Contact_Id__c 
                                                FROM Employee_Reimbursement__c
                                                WHERE Month__c In: utils.fetchMonths(1, 0)
                                                AND Contact_Id__r.Account.Triplog_API__c != null
                                                AND Contact_Id__c =: userId];
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        MakeCallOut((list<Employee_Reimbursement__c>) scope, currentMonthreimbursementsList);     
    }

    Webservice static void MakeCallOut(list<Employee_Reimbursement__c> reimbursementList, list<Employee_Reimbursement__c> currentMonthreimbursementsList) {
        // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020 | START
        List<Employee_Reimbursement__c> reimbursementListToDelete = new List<Employee_Reimbursement__c>();
        Map<String,Employee_Reimbursement__c> reimbursementMap = new Map<String, Employee_Reimbursement__c>();
        // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020 | ENDS
        Set<Id> reimburIDs = new Set<Id>();
        List<Tripslog__c> triplogList = new List<Tripslog__c>();
        List<String> callOutTripStatus = new List<String>{'S','U'};   
        Set<Employee_Mileage__c> mileageset = new Set<Employee_Mileage__c>();
        Double totalmileages = 0;
        Map<Integer,Double> oldMileagesMap = new Map<Integer,Double>();

        for(Employee_Reimbursement__c reim : reimbursementList) {
            reimburIDs.add(reim.Id);
            // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020
            reimbursementMap.put(reim.Month__c + ':' + reim.Contact_Id__c, reim); 
        }
        
        for(Employee_Reimbursement__c reim : currentMonthreimbursementsList) {
            reimbursementMap.put(reim.Month__c + ':' + reim.Contact_Id__c, reim); 
        }


        if(!reimburIDs.isEmpty()){
            for(Employee_Mileage__c mil : [SELECT id,
                                                    Trip_Id__c, 
                                                    Mileage__c, 
                                                    EmployeeReimbursement__c 
                                                FROM Employee_Mileage__c 
                                                WHERE EmployeeReimbursement__c In : reimburIDs]){
                oldMileagesMap.put(Integer.valueOf(mil.Trip_Id__c), mil.Mileage__c);
            }
        }
        
        for(Employee_Reimbursement__c reim : reimbursementList)
        {
            Tripslog__c triplogRecord;
            String startDate, endDate;
            Integer reimmonth = Integer.valueOf(reim.month__c.split('-')[0]);
            DateTime deactivateDate = reim.Contact_Id__r.Deactivated_Date__c;
            if(deactivateDate != null && deactivateDate.Month() == reimmonth) {
                startDate = deactivateDate.Year() + '-' + deactivateDate.Month() + '-1';
                endDate = deactivateDate.Year() + '-' + deactivateDate.Month() + '-' + deactivateDate.day(); 
            }

            else if(deactivateDate != null && deactivateDate.Month() != reimmonth) {
                if(reimmonth == 12) {
                    startDate = ( System.today().year() - 1 ) + '-12-1'; 
                    endDate = ( System.today().year() - 1 ) + '-12-31';
                } else {
                    startDate = System.today().year() + '-' + reimmonth +'-1';
                    endDate = System.today().year() + '-' + reimmonth + '-' + 
                                 String.valueOf(date.newInstance(
                                     System.today().year() , reimmonth + 1, 1 ).addDays(-1).day() );                   
                }
            }
            

            // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020 | STARTS
            String reimbursementId = getReimbursementId(reim, reimbursementMap); 
            if(reimbursementId != reim.Id)
                reimbursementListToDelete.add(new Employee_Reimbursement__c(Id = reim.Id));
            // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020 | ENDS
            
            for(String status : callOutTripStatus) 
            {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                String endPoint = 'startDate=' + startDate + '&userEmail=' + reim.Contact_Id__r.External_Email__c + '&endDate=' + endDate + 
                           '&status=' + status + '&activity=Business';
                String apiKey = reim.Contact_Id__r.Account.Triplog_API__c;
                String baseURL = !MLOGACCOUNT.Contains(apiKey) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                req.setEndpoint( baseURL + StaticValues.TRIPS_SUFFIX +  endPoint.trim());
                req.setMethod('GET');
                req.setTimeout(120000);
                req.setHeader('Authorization', 'apikey ' + apiKey );

                res = !Test.isRunningTest() ? h.send(req) : GetTripCalloutMock.respond(req);  
                
                if(res.getStatusCode() == 200) {                    
                    TripLogDeserializeClass tripLog = TripLogDeserializeClass.parse(res.getBody());
                    for( TripLogDeserializeClass.Trips trip : tripLog.trips ) {
                        Employee_Mileage__c mil = new Employee_Mileage__c();
                        mil.Name = 'New Trip';
                        mil.Approved_Date__c = null;
                        mil.Trip_Status__c = StaticValues.STATUS_NOTAPPROVEDYET;
                        // Commented | AI-000432 | Sanjay Halpati | 21 Apr 2020
                        //mil.EmployeeReimbursement__c = reim.Id;

                        // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020 
                        mil.EmployeeReimbursement__c = reimbursementId;

                        mil.Contact_Email_Id__c = reim.Contact_Id__r.External_Email__c;
                        mil.Trip_Id__c = trip.Id;
                        mil.Mileage__c = trip.mileage;
                        mil.Fuel_price__c = reim.Fuel_Price__c;
                        mil.MPG__c = reim.MPG__c;
                        mil.Maintenance_and_Tires__c = reim.Maintenance_and_Tires__c;         
                        TripLogDeserializeClass.FromLocation fromLocationOfTrip = trip.fromLocation;
                        if(fromLocationOfTrip != null && fromLocationOfTrip.id != null ) {
                            mil.FromLocationId__c = fromLocationOfTrip.id;                    
                            if(fromLocationOfTrip.name != null) {  
                                mil.Origin_Name__c = String.valueOf(fromLocationOfTrip.name); 
                                mil.Original_Origin_Name__c = String.valueOf(fromLocationOfTrip.name); 
                            } else {
                                mil.Origin_Name__c = fromLocationOfTrip.address;
                                mil.Original_Origin_Name__c = null;
                            }
                            /*if(fromLocationOfTrip.address != null && fromLocationOfTrip.address.contains(',')){
                                mil.Origin_Name__c = fromLocationOfTrip.address.split(',')[0];
                            } else if(fromLocationOfTrip.address != null && fromLocationOfTrip.address.contains(' ')){
                                mil.Origin_Name__c = fromLocationOfTrip.address.split(' ')[0];
                            } else {
                                mil.Origin_Name__c = fromLocationOfTrip.address;
                            }*/
                            if(fromLocationOfTrip.address != null) {
                                mil.Trip_Origin__c = fromLocationOfTrip.address;
                            }
                        }
                        TripLogDeserializeClass.FromLocation toLocationOfTrip = trip.toLocation;
                        if(toLocationOfTrip != null && toLocationOfTrip.id != null ) {
                            mil.ToLocationId__c = toLocationOfTrip.id;                    
                            if(toLocationOfTrip.name != null) {
                                mil.Destination_Name__c = String.valueOf(toLocationOfTrip.name);  
                                mil.Original_Destination_Name__c =  String.valueOf(toLocationOfTrip.name);  
                            } else {
                                mil.Destination_Name__c = toLocationOfTrip.address;
                                mil.Original_Destination_Name__c = null;
                            }
                            /*if(toLocationOfTrip.address != null && toLocationOfTrip.address.contains(',')){
                                mil.Destination_Name__c = toLocationOfTrip.address.split(',')[0];
                            } else if(toLocationOfTrip.address != null && toLocationOfTrip.address.contains(' ')){
                                mil.Destination_Name__c = toLocationOfTrip.address.split(' ')[0];
                            } else {
                                mil.Destination_Name__c = toLocationOfTrip.address;
                            }*/
                            if(toLocationOfTrip.address != null) {
                                mil.Trip_Destination__c = toLocationOfTrip.address;
                            }
                        }
                
                        if(mil.Mileage__c != null ) {
                            totalmileages += Double.valueOf(mil.Mileage__c);
                        }    
                        mil.StartTime__c = Utils.CheckNulls(trip.startTime) ? GetTripCallout.ConvertToDateTime(trip.startTime) : null;
                        mil.Day_Of_Week__c = Utils.CheckNulls(trip.startTime) ? mil.StartTime__c.format('EEEE') : null;
                        mil.StartTime__c = Utils.CheckNulls(trip.endTime) ? GetTripCallout.ConvertToDateTime(trip.endTime) : null;
                        mil.Notes__c = Utils.CheckNulls(trip.notes) ? trip.notes : null;
                        mil.Tracing_Style__c = Utils.CheckNulls(trip.trackingMethod) ? trip.trackingMethod : null;
                        mil.Stay_Time__c = Utils.CheckNulls(trip.stayTimeMins) ? trip.stayTimeMins : null;
                        
                        if(Utils.CheckNulls(trip.map_Z)){
                            mil.Triplog_Map__c = baseURL + '/kml/embed/' +  ( trip.map_Z.contains('/') ? trip.map_Z.split('/')[4] : ''); 
                        } else {
                            mil.Triplog_Map__c = null;
                        }
                    
                        mil.Trip_Date__c = Date.valueof(trip.startTime.split('T')[0]);
                        if(mil.Mileage__c > 0){
                            if(oldMileagesMap.containsKey(trip.Id)) {
                            if(oldMileagesMap.get(trip.Id) != trip.mileage)
                                mileageset.add(mil);
                            } else {
                                mileageset.add(mil);
                            }  
                        }                                              
                    }

                    triplogRecord = new TripsLog__c();
                    triplogRecord.Contact__c = reim.Contact_Id__c;
                    triplogRecord.Employee_Reimbursement__c = reim.Id;
                    triplogRecord.Endpoint__c = baseURL + StaticValues.TRIPS_SUFFIX + endPoint.trim();
                    triplogRecord.Response__c = String.valueOf(res.getStatusCode())+' ### ' +res.getStatus();
                    triplogRecord.Status__c = 'Success';
                    triplogRecord.Total_Trips__c= mileageset.size();
                    triplogRecord.Total_Mileages__c = totalmileages;
                    triplogList.add(triplogRecord);
                } else {
                    triplogRecord = new TripsLog__c();
                    triplogRecord.Contact__c = reim.Contact_Id__c;
                    triplogRecord.Employee_Reimbursement__c = reim.Id;
                    triplogRecord.Endpoint__c = baseURL + StaticValues.TRIPS_SUFFIX +  endPoint.trim();
                    triplogRecord.Response__c = String.valueOf(res.getStatusCode()) + ' ### ' +res.getStatus();
                    triplogRecord.Status__c = 'Fail';
                    triplogRecord.Total_Trips__c = mileageset.size();
                    triplogList.add(triplogRecord);
                }
            }
            if(!triplogList.isEmpty()) { 
                insert triplogList;
            }
            
            if(!mileageset.isEmpty())
                Database.UpsertResult[] result = Database.upsert( new List<Employee_Mileage__c>(mileageset), Employee_Mileage__c.Fields.Trip_Id__c, false);
            
            // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020 | STARTS
            if(!reimbursementListToDelete.isEmpty())
                Delete reimbursementListToDelete;
            // Added | AI-000432 | Sanjay Halpati | 21 Apr 2020 | ENDS
            
        }
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('decider is :- '+ decider);
        if(!Test.isRunningTest()){
            DeActivatedUsermileageTransfer batch = decider == 0 ? 
                                                new DeActivatedUsermileageTransfer() : 
                                                ( 
                                                    decider == 1 ?
                                                    new DeActivatedUsermileageTransfer(contactIds):
                                                    new DeActivatedUsermileageTransfer(userId)
                                                );
            Database.executeBatch(batch, 1);
        }   
    }

    /*
        Added | AI-000432 | Sanjay Halpati | 21 Apr 2020
        Fetch previous month reimbursment if deactivation date is first day of the month
    */
    private static String getReimbursementId( Employee_Reimbursement__c reim, Map<String, Employee_Reimbursement__c> reimbursementMap) {
        DateTime deactivateDate = reim.Contact_Id__r.Deactivated_Date__c;
        if(deactivateDate != null && deactivateDate.Day() == 1 
            && deactivateDate.Date() == Date.newInstance(Integer.valueOf(reim.month__c.split('-')[1]), Integer.valueOf(reim.month__c.split('-')[0]), 1 )) {
            
            date pastmonth = deactivateDate.addMonths(-1).Date();
            String key;
            if(pastmonth.month() < 10)
                key = '0' + pastmonth.month() + '-' + pastmonth.Year() + ':' + reim.Contact_Id__c;    
            else
                key = pastmonth.month() +'-' + pastmonth.Year() + ':' + reim.Contact_Id__c;

            return reimbursementMap.Containskey(key) ? reimbursementMap.get(key).Id : reim.Id;
        }

        return reim.Id;
    }
}