/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : Vatsal Bhalani
**/
public with sharing class ManualEntryController {

    public static Map<String, usSatatesList__mdt> usMcs = new Map<String, usSatatesList__mdt>();
    public static Map<String, cndStatesList__mdt> cnMcs = new Map<String, cndStatesList__mdt>();

    @AuraEnabled(cacheable=true)
    public static List<usSatatesList__mdt> getAllUSStates(){
        try {
            return usSatatesList__mdt.getAll().values();
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<cndStatesList__mdt> getAllCANStates(){
        try {
            return cndStatesList__mdt.getAll().values();
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getLocations(String contactId, String driverCountry) {
        List<LocationWrapper> lstLocationWrapper = new List<LocationWrapper>();
        try {
            for(schema.Location objLocation : [SELECT Id, New_Location_Name__c, Location_Address__c, Range__c, Phone__c, Latitude, Longitude, Address__c FROM Location WHERE Driver__c =: contactId]){
                Address objAddress = objLocation.Address__c == null ? null : objLocation.Address__c;
                LocationWrapper objLocationWrapper = new LocationWrapper();
                objLocationWrapper.address = objLocation.Location_Address__c == null ? '' : objLocation.Location_Address__c;
                objLocationWrapper.id = objLocation.Id;
                objLocationWrapper.name = objLocation.New_Location_Name__c != null ? objLocation.New_Location_Name__c : '';
                objLocationWrapper.latitude = objLocation.Latitude == null ? '' : String.valueOf(objLocation.Latitude);
                objLocationWrapper.longitude = objLocation.Longitude == null ? '' : String.valueOf(objLocation.Longitude);
                objLocationWrapper.state = objAddress == null ? '' : objAddress.getState() == null ? '' : objAddress.getState();
                objLocationWrapper.city = objAddress == null ? '' : objAddress.getCity() == null ? '' : objAddress.getCity();
                objLocationWrapper.zipCode = objAddress == null ? '' : objAddress.getPostalCode() == null ? '' : objAddress.getPostalCode();
                objLocationWrapper.street = objAddress == null ? '' : objAddress.getStreet() == null ? '' : objAddress.getStreet();
                objLocationWrapper.range = (objLocation.Range__c == null ? '' : (driverCountry == 'CANADA'? String.valueOf(Integer.valueOf(objLocation.Range__c / 3.28)) : String.valueOf(Integer.valueOf(objLocation.Range__c))));
                objLocationWrapper.phone = objLocation.Phone__c == null ? '' : objLocation.Phone__c;
                lstLocationWrapper.add(objLocationWrapper);
            }
            return JSON.serialize(lstLocationWrapper);
        } catch (Exception e) {
            System.debug('Exception : ' + e);
            return 'Failure';
        }
    }

    @AuraEnabled
    public static String insertLocation(String locationJSONString , String accountId, String contactId, String driverCountry, String mLogArray){
        try{
            Schema.Location objLocationToInsert = new Schema.Location();
            LocationWrapper objLocationResponse = new LocationWrapper();
            System.debug('locationJSONString@@ : ' + locationJSONString);
            System.debug('mLogArray@@ : ' + mLogArray);
            objLocationResponse = (LocationWrapper) System.JSON.deserialize(locationJSONString, LocationWrapper.class);
            System.debug('objLocationResponse : ' + objLocationResponse);
            String countryCode;
            String stateCode;
            if(driverCountry == 'CANADA') {
                cnMcs = cndStatesList__mdt.getAll();
                cndStatesList__mdt st = cnMcs.get(objLocationResponse.state);
                stateCode = st.shortName__c;
                countryCode = 'CA';
                objLocationResponse.range = objLocationResponse.range == '' ? '' : String.valueOf(Decimal.valueOf(objLocationResponse.range) * 3.28);
            } else {
                usMcs = usSatatesList__mdt.getAll();
                usSatatesList__mdt st = usMcs.get(objLocationResponse.state);
                stateCode = st.shortName__c;
                countryCode = 'US';
            }
            System.debug('stateCode : ' + stateCode);
            objLocationToInsert.Name = objLocationResponse.name;
            objLocationToInsert.New_Location_Name__c = objLocationResponse.name;
            objLocationToInsert.Address__CountryCode__s = countryCode;
            objLocationToInsert.Address__StateCode__s = stateCode;
            // objLocationToInsert.Address__StateCode__s = 'AL';
            objLocationToInsert.Address__City__s = objLocationResponse.city;
            objLocationToInsert.Address__PostalCode__s = objLocationResponse.zipCode;
            objLocationToInsert.Address__Street__s = objLocationResponse.street;
            objLocationToInsert.Location_Address__c =  objLocationResponse.address;
            objLocationToInsert.Latitude = objLocationResponse.latitude == '' ? null : Decimal.valueOf(objLocationResponse.latitude);
            objLocationToInsert.Longitude = objLocationResponse.longitude == '' ? null : Decimal.valueOf(objLocationResponse.longitude);
            objLocationToInsert.Range__c = objLocationResponse.range == '' ? null : Decimal.valueOf(objLocationResponse.range);
            objLocationToInsert.Phone__c = objLocationResponse.phone == '' ? null : objLocationResponse.phone;
            objLocationToInsert.Activity__c = objLocationResponse.activity;
            objLocationToInsert.Driver__c = contactId;
            System.debug('objLocationToInsert : ' + objLocationToInsert);
            insert objLocationToInsert;

            /* Insert in mLog */
            List<Contact> conLst = [Select Id, Triplog_UserID__c from Contact where Id =: contactId ];
            if(conLst[0].Triplog_UserID__c != null && conLst[0].Triplog_UserID__c != '' && !Test.isRunningTest()){
                ManageNotificationController.UploadLocation(mLogArray, accountId);
            }
            /* Insert in mLog */

            objLocationToInsert.Address__StateCode__s = objLocationResponse.state;
            if(driverCountry == 'CANADA' && objLocationToInsert.Range__c != null) {
                objLocationToInsert.Range__c = Decimal.valueOf(Integer.valueOf(objLocationToInsert.Range__c / 3.28));
            }
            return JSON.serialize(objLocationToInsert);
        }
        catch(Exception e){
            return 'Failure';
        }
    }

    @AuraEnabled
    public static String updateLocation(String locationJSONString , String contactId, String driverCountry){
        try {
            System.debug('locationJSONString@@-'+locationJSONString);
            System.debug('driverCountry@@-'+driverCountry);
            System.debug('contactId@@-'+contactId);
            String result = '';
            LocationWrapper objLocationResponse = new LocationWrapper();
            objLocationResponse = (LocationWrapper) System.JSON.deserialize(locationJSONString, LocationWrapper.class);
            List<Schema.Location> lstLocationToUpdate = [SELECT Id, Name, New_Location_Name__c, Location_Address__c, Range__c, Phone__c, Latitude, Longitude, Address__c FROM Location WHERE Id =: objLocationResponse.id];
            String countryCode;
            String stateCode;
            if(driverCountry == 'CANADA') {
                cnMcs = cndStatesList__mdt.getAll();
                cndStatesList__mdt st = cnMcs.get(objLocationResponse.state);
                stateCode = st.shortName__c;
                countryCode = 'CA';
                objLocationResponse.range = objLocationResponse.range == '' ? '' : String.valueOf(Decimal.valueOf(objLocationResponse.range) * 3.28);
            } else {
                usMcs = usSatatesList__mdt.getAll();
                usSatatesList__mdt st = usMcs.get(objLocationResponse.state);
                stateCode = st.shortName__c;
                countryCode = 'US';
            }

            if(lstLocationToUpdate.size() > 0) {
                lstLocationToUpdate[0].Name = objLocationResponse.name;
                lstLocationToUpdate[0].New_Location_Name__c = objLocationResponse.name;
                lstLocationToUpdate[0].Address__CountryCode__s = countryCode;
                lstLocationToUpdate[0].Address__StateCode__s = stateCode;
                // lstLocationToUpdate[0].Address__StateCode__s = 'AL';
                lstLocationToUpdate[0].Address__City__s = objLocationResponse.city;
                lstLocationToUpdate[0].Address__PostalCode__s = objLocationResponse.zipCode;
                lstLocationToUpdate[0].Address__Street__s = objLocationResponse.street;
                lstLocationToUpdate[0].Location_Address__c =  objLocationResponse.address;
                lstLocationToUpdate[0].Latitude = objLocationResponse.latitude == '' ? null : Decimal.valueOf(objLocationResponse.latitude);
                lstLocationToUpdate[0].Longitude = objLocationResponse.longitude == '' ? null : Decimal.valueOf(objLocationResponse.longitude);
                lstLocationToUpdate[0].Range__c = objLocationResponse.range == '' ? null : Decimal.valueOf(objLocationResponse.range);
                lstLocationToUpdate[0].Phone__c = objLocationResponse.phone == '' ? null : objLocationResponse.phone;
                update lstLocationToUpdate;
                lstLocationToUpdate[0].Address__StateCode__s = objLocationResponse.state;
                if(driverCountry == 'CANADA' && lstLocationToUpdate[0].Range__c != null) {
                    lstLocationToUpdate[0].Range__c = Decimal.valueOf(Integer.valueOf(lstLocationToUpdate[0].Range__c / 3.28));
                }
                result = JSON.serialize(lstLocationToUpdate[0]);
            } else {
                result = 'This location is no longer exist, Please add new one.';
            }
            return result;
        } catch (Exception e) {
            return 'Something wrong while updating location.';
        }
    }

    @AuraEnabled
    public static String getTrips(String contactId, String selectedMonth){
        List<TripWrapper> lstTripWrapper = new List<TripWrapper>();
        try {
            String result;
            List<Employee_Mileage__c> lstEmpMileage = [SELECT Id, Tag__c, Notes__c, Trip_Date__c, Trip_Status__c, ConvertedStartTime__c, ConvertedEndTime__c, EMP_Mileage__c, Trip_Origin__c, Original_Origin_Name__c, Trip_Destination__c, Original_Destination_Name__c, CreatedDate, Tracing_Style__c, Approved_Date__c, Approval_Name__c, Trip_Origin_State__c, Trip_Destination_State__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, TimeZone__c, Way_Points__c, EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Contact_Id__c =: contactId AND EmployeeReimbursement__r.Month__c =: selectedMonth];
            if(lstEmpMileage.size() > 0) {
                for(Employee_Mileage__c objEmpMileage : lstEmpMileage){
                    TripWrapper objTripWrapper = new TripWrapper();
                    objTripWrapper.id = objEmpMileage.Id;
                    objTripWrapper.tags = objEmpMileage.Tag__c != null ? objEmpMileage.Tag__c : '';
                    objTripWrapper.notes = objEmpMileage.Notes__c != null ? objEmpMileage.Notes__c : '';
                    objTripWrapper.mileage = String.valueOf(objEmpMileage.EMP_Mileage__c);
                    objTripWrapper.tripDate = String.valueOf(objEmpMileage.Trip_Date__c);
                    objTripWrapper.tripStatus = objEmpMileage.Trip_Status__c;
                    objTripWrapper.origin = objEmpMileage.Trip_Origin__c != null ? objEmpMileage.Trip_Origin__c : '';
                    objTripWrapper.destination = objEmpMileage.Trip_Destination__c != null ? objEmpMileage.Trip_Destination__c : '';
                    objTripWrapper.originName = objEmpMileage.Original_Origin_Name__c != null ? objEmpMileage.Original_Origin_Name__c : '';
                    objTripWrapper.destinationName = objEmpMileage.Original_Destination_Name__c != null ? objEmpMileage.Original_Destination_Name__c : '';
                    objTripWrapper.startTime = objEmpMileage.ConvertedStartTime__c != null ? String.valueOf(objEmpMileage.ConvertedStartTime__c) : '';
                    objTripWrapper.endTime = objEmpMileage.ConvertedEndTime__c != null ? String.valueOf(objEmpMileage.ConvertedEndTime__c) : '';
                    objTripWrapper.createdDate = String.valueOf(objEmpMileage.CreatedDate);
                    objTripWrapper.tracingStyle = objEmpMileage.Tracing_Style__c != null ? objEmpMileage.Tracing_Style__c : '';
                    objTripWrapper.processDate = objEmpMileage.Approved_Date__c != null ? String.valueOf(objEmpMileage.Approved_Date__c) : '';
                    objTripWrapper.processBy = objEmpMileage.Approval_Name__c != null ? objEmpMileage.Approval_Name__c : '';
                    objTripWrapper.originState = objEmpMileage.Trip_Origin_State__c != null ? objEmpMileage.Trip_Origin_State__c : '';
                    objTripWrapper.destinationState = objEmpMileage.Trip_Destination_State__c != null ? objEmpMileage.Trip_Destination_State__c : '';
                    /* For map component */
                    // objTripWrapper.fromLat = objEmpMileage.From_Location__Latitude__s;
                    // objTripWrapper.fromLong = objEmpMileage.From_Location__Longitude__s;
                    // objTripWrapper.toLat = objEmpMileage.To_Location__Latitude__s;
                    // objTripWrapper.toLong = objEmpMileage.To_Location__Longitude__s;
                    // objTripWrapper.timeZone = objEmpMileage.TimeZone__c;
                    // objTripWrapper.wayPoints = objEmpMileage.Way_Points__c;
                    // objTripWrapper.triplogApi = objEmpMileage.EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c;
                    /* For map component */
                    lstTripWrapper.add(objTripWrapper);
                }
                result = JSON.serialize(lstTripWrapper);
            } else {
                result = JSON.serialize('No trips found for current month.');
            }
            return result;
        } catch (Exception e) {
            System.debug(e);
            return 'Failure';
        }
    }

    @AuraEnabled
    public static String insertTrip(String contactId, String tripToInsert, Integer selectedMonth){
        System.debug('selectedMonth : ' + selectedMonth);
        try {
            String result = '';
            TripWrapper objTripResponse = new TripWrapper();
            objTripResponse = (TripWrapper) System.JSON.deserialize(tripToInsert, TripWrapper.class);

            List<Contact> lstContact = [SELECT Id, Name, Email, Reimbursement_Frequency__c FROM Contact WHERE Id =: contactId];
            if(lstContact.size() > 0) {
                String reimId;
                String biWeekReimId;

                String year = '20' + objTripResponse.tripDate.split('/')[2];
                String month = objTripResponse.tripDate.split('/')[0];
                String day = objTripResponse.tripDate.split('/')[1];
                Date convTripDate = date.newinstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
                System.debug('convTripDate : ' + convTripDate);

                String sHour;
                String sMinute;
                if(objTripResponse.startTime != '') {
                    String sPeriod = objTripResponse.startTime.split(' ')[1];
                    String sOriginalTime = objTripResponse.startTime.split(' ')[0];
                    sMinute = sOriginalTime.split(':')[1];
                    sHour = sOriginalTime.split(':')[0];
                    Integer sTempHour = Integer.valueOf(sHour);
                    if(sPeriod == 'PM' && sTempHour < 12) {
                        sTempHour = sTempHour + 12;
                        sHour = String.valueOf(sTempHour);
                    }
                }
                System.debug('Start HH:MM - ' + sHour + ':' + sMinute);

                String eHour;
                String eMinute;
                if(objTripResponse.endTime != '') {
                    String ePeriod = objTripResponse.endTime.split(' ')[1];
                    String eOriginalTime = objTripResponse.endTime.split(' ')[0];
                    eMinute = eOriginalTime.split(':')[1];
                    eHour = eOriginalTime.split(':')[0];
                    Integer eTempHour = Integer.valueOf(eHour);
                    if(ePeriod == 'PM' && eTempHour < 12) {
                        eTempHour = eTempHour + 12;
                        eHour = String.valueOf(eTempHour);
                    }
                }
                System.debug('End HH:MM - ' + eHour + ':' + eMinute);

                String tSecond = System.now().format('hh:mm:ss').split(':')[2];
                Datetime sTime;
                Datetime eTime;
                if(objTripResponse.startTime != '') {
                    sTime = Datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day), Integer.valueOf(sHour), Integer.valueOf(sMinute), Integer.valueOf(tSecond));
                }
                if(objTripResponse.endTime != '') {
                    eTime = Datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day), Integer.valueOf(eHour), Integer.valueOf(eMinute), Integer.valueOf(tSecond));
                }
                System.debug('startTime : ' + sTime);
                System.debug('endTime : ' + eTime);

                if(lstContact[0].Reimbursement_Frequency__c == 'Monthly Reimbursement') {
                    String reimMonth;
                    List<Employee_Reimbursement__c> lstEmpReim;
                    Integer monthDifference = Integer.valueOf(System.now().format('MM')) - selectedMonth;
                    if(monthDifference == 0) {
                        reimMonth = System.now().format('MM-YYYY');
                        lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                        if(lstEmpReim.size() > 0) {
                            reimId = lstEmpReim[0].Id;
                        } else {
                            result = 'Reimbursement not present for month: ' + reimMonth;
                        }
                    } else if(monthDifference == 1) {
                        reimMonth = System.now().addMonths(-1).format('MM-YYYY');
                        lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                        if(lstEmpReim.size() > 0 && lstEmpReim[0].Mileage_Lock_Date__c == null) {
                            reimId = lstEmpReim[0].Id;
                        } else {
                            reimMonth = System.now().format('MM-YYYY');
                            lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                            if(lstEmpReim.size() > 0) {
                                reimId = lstEmpReim[0].Id;
                            } else {
                                result = 'Reimbursement not present for month: ' + reimMonth;
                            }
                        }
                    } else {
                        reimMonth = System.now().addMonths(-2).format('MM-YYYY');
                        lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                        if(lstEmpReim.size() > 0 && lstEmpReim[0].Mileage_Lock_Date__c == null) {
                            reimId = lstEmpReim[0].Id;
                        } else {
                            reimMonth = System.now().addMonths(-1).format('MM-YYYY');
                            lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                            if(lstEmpReim.size() > 0 && lstEmpReim[0].Mileage_Lock_Date__c == null) {
                                reimId = lstEmpReim[0].Id;
                            } else {
                                reimMonth = System.now().format('MM-YYYY');
                                lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                                if(lstEmpReim.size() > 0) {
                                    reimId = lstEmpReim[0].Id;
                                } else {
                                    result = 'Reimbursement not present for month: ' + reimMonth;
                                }
                            }
                        }
                    }
                    // String reimMonth = System.now().addMonths(-1).format('MM-YYYY');
                    // List<Employee_Reimbursement__c> lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                    // if(lstEmpReim.size() > 0 && lstEmpReim[0].Mileage_Lock_Date__c == null) {
                    //     reimId = lstEmpReim[0].Id;
                    // } else {
                    //     reimMonth = System.now().format('MM-YYYY');
                    //     lstEmpReim = [SELECT Id, Name, Month__c, Mileage_Lock_Date__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Month__c =: reimMonth];
                    //     if(lstEmpReim.size() > 0) {
                    //         reimId = lstEmpReim[0].Id;
                    //     } else {
                    //         result = 'Reimbursement not present for month: ' + reimMonth;
                    //     }
                    // }
                    List<Bi_Weekly_Reimbursement__c> lstBiWeekReim = [SELECT Id, Name FROM Bi_Weekly_Reimbursement__c WHERE Contact__c =: contactId LIMIT 1];
                    if(lstBiWeekReim.size() > 0) {
                        biWeekReimId = lstBiWeekReim[0].Id;
                    } else {
                        result = 'Bi-week reimbursement not present';
                    }
                    if(reimId != null && biWeekReimId != null) {
                        if(lstEmpReim[0].MPG__c == null || lstEmpReim[0].Fuel_Price__c == null || lstEmpReim[0].Maintenance_and_Tires__c == null) {
                            result = 'Please fill value of MPG, Fuel Price and Maintenance and Tires for reimbursement: ' + reimMonth;
                        } else {
                            Employee_Mileage__c objEmpMileage = new Employee_Mileage__c ();
                            objEmpMileage.Contact_Email_Id__c = lstContact[0].Email;
                            objEmpMileage.EmployeeReimbursement__c = reimId;
                            objEmpMileage.Bi_Weekly_Reimbursement__c = biWeekReimId;
                            objEmpMileage.Trip_Date__c = convTripDate;
                            objEmpMileage.EMP_Mileage__c = Decimal.valueOf(objTripResponse.mileage);
                            objEmpMileage.Trip_Origin__c = objTripResponse.origin;
                            objEmpMileage.Trip_Destination__c = objTripResponse.destination;
                            objEmpMileage.Origin_Name__c = objTripResponse.origin;
                            objEmpMileage.Destination_Name__c = objTripResponse.destination;
                            objEmpMileage.Original_Origin_Name__c = objTripResponse.originName;
                            objEmpMileage.Original_Destination_Name__c = objTripResponse.destinationName;
                            objEmpMileage.StartTime__c = sTime;
                            objEmpMileage.EndTime__c = eTime;
                            objEmpMileage.Notes__c = objTripResponse.notes == '' ? null : objTripResponse.notes;
                            objEmpMileage.Tag__c = objTripResponse.tags == '' ? null : objTripResponse.tags;
                            objEmpMileage.Activity__c = 'Business';
                            objEmpMileage.Trip_Status__c = 'Not Approved Yet';
                            objEmpMileage.MPG__c = lstEmpReim[0].MPG__c;
                            objEmpMileage.Fuel_price__c = lstEmpReim[0].Fuel_Price__c;
                            objEmpMileage.Maintenance_and_Tires__c = lstEmpReim[0].Maintenance_and_Tires__c;
                            objEmpMileage.TimeZone__c = lstEmpReim[0].Contact_Id__r.Time_Zone__c;
                            objEmpMileage.Tracing_Style__c = 'mDash Manual Entry';
                            /* For map component */
                            // objEmpMileage.Way_Points__c = null;
                            // objEmpMileage.From_Location__Latitude__s = null;
                            // objEmpMileage.From_Location__Longitude__s = null;
                            // objEmpMileage.To_Location__Latitude__s = null;
                            // objEmpMileage.To_Location__Longitude__s = null;
                            /* For map component */
                            System.debug('Monthly Mileage To Create : ' + objEmpMileage);
                            insert objEmpMileage;
                            MonthWrapper mileagetoReturn = new MonthWrapper();
                            mileagetoReturn.trip = objEmpMileage;
                            mileagetoReturn.reimMonth = reimMonth;
                            result = JSON.serialize(mileagetoReturn);
                        }
                    }
                }
                else if(lstContact[0].Reimbursement_Frequency__c == 'Bi-Weekly Reimbursement') {
                    List<Bi_Weekly_Reimbursement__c> lstBiWeekReim = [SELECT Id, Name, Employee_Reimbursement__c FROM Bi_Weekly_Reimbursement__c WHERE Contact__c =: contactId AND Start_Date__c <=: convTripDate AND End_Date__c >=: convTripDate];
                    if(lstBiWeekReim.size() > 0) {
                        System.debug('In Bi-week');
                        biWeekReimId = lstBiWeekReim[0].Id;
                    } else {
                        result = 'Bi-week reimbursement not present that have date: ' + convTripDate;
                    }
                    List<Employee_Reimbursement__c> lstEmpReim = [SELECT Id, Name, Month__c, MPG__c, Fuel_Price__c, Maintenance_and_Tires__c, Contact_Id__r.Time_Zone__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: contactId AND Id =: lstBiWeekReim[0].Employee_Reimbursement__c];
                    if(lstEmpReim.size() > 0) {
                        reimId = lstEmpReim[0].Id;
                    } else {
                        result = 'Monthly reimbursement not present that have date: ' + convTripDate;
                    }
                    if(reimId != null && biWeekReimId != null) {
                        if(lstEmpReim[0].MPG__c == null || lstEmpReim[0].Fuel_Price__c == null || lstEmpReim[0].Maintenance_and_Tires__c == null) {
                            result = 'Please fill value of MPG, Fuel Price and Maintenance and Tires for reimbursement: ' + lstEmpReim[0].Month__c;
                        } else {
                            Employee_Mileage__c objEmpMileage = new Employee_Mileage__c ();
                            objEmpMileage.Contact_Email_Id__c = lstContact[0].Email;
                            objEmpMileage.EmployeeReimbursement__c = reimId;
                            objEmpMileage.Bi_Weekly_Reimbursement__c = biWeekReimId;
                            objEmpMileage.Trip_Date__c = convTripDate;
                            objEmpMileage.EMP_Mileage__c = Decimal.valueOf(objTripResponse.mileage);
                            objEmpMileage.Trip_Origin__c = objTripResponse.origin;
                            objEmpMileage.Trip_Destination__c = objTripResponse.destination;
                            objEmpMileage.Origin_Name__c = objTripResponse.origin;
                            objEmpMileage.Destination_Name__c = objTripResponse.destination;
                            objEmpMileage.Original_Origin_Name__c = objTripResponse.originName;
                            objEmpMileage.Original_Destination_Name__c = objTripResponse.destinationName;
                            objEmpMileage.StartTime__c = sTime;
                            objEmpMileage.EndTime__c = eTime;
                            objEmpMileage.Notes__c = objTripResponse.notes == '' ? null : objTripResponse.notes;
                            objEmpMileage.Tag__c = objTripResponse.tags == '' ? null : objTripResponse.tags;
                            objEmpMileage.Activity__c = 'Business';
                            objEmpMileage.Trip_Status__c = 'Not Approved Yet';
                            objEmpMileage.MPG__c = lstEmpReim[0].MPG__c;
                            objEmpMileage.Fuel_price__c = lstEmpReim[0].Fuel_Price__c;
                            objEmpMileage.Maintenance_and_Tires__c = lstEmpReim[0].Maintenance_and_Tires__c;
                            objEmpMileage.TimeZone__c = lstEmpReim[0].Contact_Id__r.Time_Zone__c;
                            objEmpMileage.Tracing_Style__c = 'mDash Manual Entry';
                            /* For map component */
                            // objEmpMileage.Way_Points__c = null;
                            // objEmpMileage.From_Location__Latitude__s = null;
                            // objEmpMileage.From_Location__Longitude__s = null;
                            // objEmpMileage.To_Location__Latitude__s = null;
                            // objEmpMileage.To_Location__Longitude__s = null;
                            /* For map component */
                            System.debug('Bi-week Mileage To Create : ' + objEmpMileage);
                            insert objEmpMileage;
                            MonthWrapper mileagetoReturn = new MonthWrapper();
                            mileagetoReturn.trip = objEmpMileage;
                            mileagetoReturn.reimMonth = lstEmpReim[0].Month__c;
                            result = JSON.serialize(mileagetoReturn);
                        }
                    }
                }
            }
            return result;
        } catch (Exception e) {
            System.debug(e);
            return 'Something wrong while creating trip.';
        }
    }

    @AuraEnabled
    public static String updateTrip(String contactId, String tripToUpdate){
        try {
            String result = '';
            TripWrapper objTripResponse = new TripWrapper();
            objTripResponse = (TripWrapper) System.JSON.deserialize(tripToUpdate, TripWrapper.class);
            String year = '20' + objTripResponse.tripDate.split('/')[2];
            String month = objTripResponse.tripDate.split('/')[0];
            String day = objTripResponse.tripDate.split('/')[1];
            Date convTripDate = date.newinstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
            System.debug('convTripDate : ' + convTripDate);

            String sHour;
            String sMinute;
            if(objTripResponse.startTime != '') {
                String sPeriod = objTripResponse.startTime.split(' ')[1];
                String sOriginalTime = objTripResponse.startTime.split(' ')[0];
                sMinute = sOriginalTime.split(':')[1];
                sHour = sOriginalTime.split(':')[0];
                Integer sTempHour = Integer.valueOf(sHour);
                if(sPeriod == 'PM' && sTempHour < 12) {
                    sTempHour = sTempHour + 12;
                    sHour = String.valueOf(sTempHour);
                }
            }
            System.debug('Start HH:MM - ' + sHour + ':' + sMinute);

            String eHour;
            String eMinute;
            if(objTripResponse.endTime != '') {
                String ePeriod = objTripResponse.endTime.split(' ')[1];
                String eOriginalTime = objTripResponse.endTime.split(' ')[0];
                eMinute = eOriginalTime.split(':')[1];
                eHour = eOriginalTime.split(':')[0];
                Integer eTempHour = Integer.valueOf(eHour);
                if(ePeriod == 'PM' && eTempHour < 12) {
                    eTempHour = eTempHour + 12;
                    eHour = String.valueOf(eTempHour);
                }
            }
            System.debug('End HH:MM - ' + eHour + ':' + eMinute);

            String tSecond = System.now().format('hh:mm:ss').split(':')[2];
            Datetime sTime;
            Datetime eTime;
            if(objTripResponse.startTime != '') {
                sTime = Datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day), Integer.valueOf(sHour), Integer.valueOf(sMinute), Integer.valueOf(tSecond));
            }
            if(objTripResponse.endTime != '') {
                eTime = Datetime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day), Integer.valueOf(eHour), Integer.valueOf(eMinute), Integer.valueOf(tSecond));
            }
            System.debug('startTime : ' + sTime);
            System.debug('endTime : ' + eTime);

            List<Employee_Mileage__c> lstEmpMileage = [SELECT Id, Tag__c, Notes__c, Trip_Date__c, Trip_Status__c, StartTime__c, EndTime__c, EMP_Mileage__c, Trip_Origin__c, Original_Origin_Name__c, Origin_Name__c, Trip_Destination__c, Original_Destination_Name__c, Destination_Name__c, CreatedDate, Tracing_Style__c, Approved_Date__c, Approval_Name__c, From_Location__Latitude__s, From_Location__Longitude__s, To_Location__Latitude__s, To_Location__Longitude__s, TimeZone__c, Way_Points__c FROM Employee_Mileage__c WHERE Id =: objTripResponse.id];
            if(lstEmpMileage.size() > 0) {
                Double fLat = lstEmpMileage[0].From_Location__Latitude__s;
                Double fLong = lstEmpMileage[0].From_Location__Longitude__s;
                Double tLat = lstEmpMileage[0].To_Location__Latitude__s;
                Double tLong = lstEmpMileage[0].To_Location__Longitude__s;
                String wayPt = lstEmpMileage[0].Way_Points__c;
                String tZone = lstEmpMileage[0].TimeZone__c;
                lstEmpMileage[0].Trip_Date__c = convTripDate;
                lstEmpMileage[0].EMP_Mileage__c = Decimal.valueOf(objTripResponse.mileage);
                lstEmpMileage[0].Trip_Origin__c = objTripResponse.origin;
                lstEmpMileage[0].Trip_Destination__c = objTripResponse.destination;
                lstEmpMileage[0].Origin_Name__c = objTripResponse.origin;
                lstEmpMileage[0].Destination_Name__c = objTripResponse.destination;
                lstEmpMileage[0].Original_Origin_Name__c = objTripResponse.originName;
                lstEmpMileage[0].Original_Destination_Name__c = objTripResponse.destinationName;
                lstEmpMileage[0].StartTime__c = sTime;
                lstEmpMileage[0].EndTime__c = eTime;
                lstEmpMileage[0].Notes__c = objTripResponse.notes == '' ? null : objTripResponse.notes;
                lstEmpMileage[0].Tag__c = objTripResponse.tags == '' ? null : objTripResponse.tags;
                /* For map component */
                // lstEmpMileage[0].From_Location__Latitude__s = fLat;
                // lstEmpMileage[0].From_Location__Longitude__s = fLong;
                // lstEmpMileage[0].To_Location__Latitude__s = tLat;
                // lstEmpMileage[0].To_Location__Longitude__s = tLong;
                // lstEmpMileage[0].TimeZone__c = tZone;
                // lstEmpMileage[0].Way_Points__c = wayPt;
                /* For map component */
                update lstEmpMileage;
                result = JSON.serialize(lstEmpMileage[0]);
            } else {
                result = 'This trip is no longer exist, Please add new one.';
            }
            return result;
        } catch (Exception e) {
            System.debug(e);
            return 'Something wrong while updating trip.';
        }
    }

    @AuraEnabled
    public static String deleteTrips(String tripIds){
        try {
            String tempStr1 = tripIds.substring(1, tripIds.length()-1);
            List<String> lstIds = tempStr1.split(',');
            List<Employee_Mileage__c> lstEmpMileagesToDelete = [SELECT Id FROM Employee_Mileage__c WHERE Id IN :lstIds];

            if(lstEmpMileagesToDelete.size()>0){
                delete lstEmpMileagesToDelete;
                return 'Success';
            } else {
                return 'Failure';
            }
        } catch (Exception e) {
            System.debug(e);
            return 'Failure';
        }
    }

    public class LocationWrapper {
        public String id{get;set;}
        public String name{get;set;}
        public String address{get;set;}
        public String latitude{get;set;}
        public String longitude{get;set;}
        public String state{get;set;}
        public String city{get;set;}
        public String street{get;set;}
        public String zipCode{get;set;}
        public String range{get;set;}
        public String phone{get;set;}
        public String activity{get;set;}
        public String userId{get;set;}
    }

    public class TripWrapper {
        public String id{get;set;}
        public String tripDate{get;set;}
        public String tripStatus{get;set;}
        public String startTime{get;set;}
        public String endTime{get;set;}
        public String origin{get;set;}
        public String destination{get;set;}
        public String originName{get;set;}
        public String destinationName{get;set;}
        public String mileage{get;set;}
        public String tags{get;set;}
        public String notes{get;set;}
        public String createdDate{get;set;}
        public String tracingStyle{get;set;}
        public String processDate{get;set;}
        public String processBy{get;set;}
        public String originState{get;set;}
        public String destinationState{get;set;}
        public Double fromLat{get;set;}
        public Double fromLong{get;set;}
        public Double toLat{get;set;}
        public Double toLong{get;set;}
        public String timeZone{get;set;}
        public String wayPoints{get;set;}
        public String triplogApi{get;set;}
    }

    public class MonthWrapper {
        public Object trip{get;set;}
        public String reimMonth{get;set;}
    }
}