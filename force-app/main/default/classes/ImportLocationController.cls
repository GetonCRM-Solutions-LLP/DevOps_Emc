/**
 * @description       : 
 * @author            : Vatsal Bhalani
 * @group             : 
 * @last modified on  : 08-01-2024
 * @last modified by  : Vatsal Bhalani
**/
public class ImportLocationController {

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
    Public Static String getLocation(String conId) {
        List<locationWrapper> locationWrapperList = new List<locationWrapper>(); 
        System.debug('getLocation@@-');
        for(schema.Location loc : [SELECT id,Name,New_Location_Name__c,Driver__r.App__c,Driver__r.Map_Country__c,Latitude,Longitude,Activity__c,Driver__r.Triplog_UserID__c,Location_Address__c,Range__c,Address__c
                                   FROM Location 
                                   WHERE Driver__c =: conId and Driver__r.App__c != null ]){
                                       Address adrs = loc.Address__c;
                                       locationWrapper wrapper = new locationWrapper();
                                       wrapper.userId = loc.Driver__r.Triplog_UserID__c;
                                       wrapper.name = loc.New_Location_Name__c  ;
                                       wrapper.id = loc.Id;
                                       wrapper.address = loc.Location_Address__c;
                                       wrapper.latitude = loc.Latitude;
                                       wrapper.longitude = loc.Longitude;
                                       wrapper.range = loc.Range__c == null ? null : loc.Driver__r.Map_Country__c == 'CANADA' ? Decimal.valueOf((loc.Range__c / 3.28).round()) : Decimal.valueOf(Integer.valueOf(loc.Range__c));                                    
                                       wrapper.activity = loc.Activity__c;
                                       wrapper.state = adrs == null ? '' : adrs.getState() == null ? '' : adrs.getState();
                                       wrapper.city = adrs == null ? '' : adrs.getCity() == null ? '' : adrs.getCity();
                                       wrapper.zipCode = adrs == null ? null : adrs.getPostalCode() == null ? null : adrs.getPostalCode();
                                       wrapper.street = adrs == null ? '' : adrs.getStreet() == null ? '' : adrs.getStreet();
                                       System.debug('wrapper@@'+wrapper);
                                       locationWrapperList.add(wrapper);
                                   }
        String locationJSONString = JSON.serialize(locationWrapperList);
        return locationJSONString;
    } 
    
    // locationJSONString - for Save Location in Salesforce
    // localJSONString - for Save Location in mLog
    @AuraEnabled
    Public Static string updateLocation(String locationJSONString , String contactId, String localJSONString){

        try{
            List<Schema.Location> locationLstToUpdate = new List<Schema.Location>();
            locationLstToUpdate = jsonCollectionCommon(locationJSONString,contactId);

            if(locationLstToUpdate.size() > 0){
                update locationLstToUpdate;
            }
            return 'Success';
        }
        catch(Exception e){
            return 'Fail';
        }
    }
    
    // locationJSONString - for Save Location in Salesforce
    // localJSONString - for Save Location in mLog
    @AuraEnabled
    Public Static String updateLocationMlog(String locationJSONString , String contactId, String localJSONString){
        List<Schema.Location> locationLstToInsert = new List<Schema.Location>();
        try{
            System.debug('contactId@@-'+contactId);
            System.debug('locationJSONString : ' + locationJSONString);
            System.debug('localJSONString : ' + localJSONString);
            locationLstToInsert = jsonCollectionCommon(locationJSONString,contactId);
            System.debug('contactId@@-'+contactId);
            System.debug('locationLstToInsert : ' + locationLstToInsert);
            if(locationLstToInsert.size() > 0){
                Database.SaveResult[] srList = Database.insert(locationLstToInsert, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Message. Messages ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Message fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }

            List<Contact> conLst = [Select Id, AccountId, Triplog_UserID__c from Contact where Id =: contactId ];
            System.debug('conLst@@--'+conLst);
            List<JSONLocation> LocationJson = JSONLocation.parse(localJSONString);
            System.debug('@@@ Outside Mlog @@@');
            if(conLst[0].Triplog_UserID__c != null && conLst[0].Triplog_UserID__c != '' && !Test.isRunningTest()){
                //System.debug('inside loop@@--');
                try {
                    System.debug('@@@ Inside Mlog @@@');
                    ManageNotificationController.UploadLocation(localJSONString,conLst[0].AccountId);    
                } catch (Exception e) {
                    System.debug('Something Went Wrong While Uploading The Locations : '+e.getMessage());
                }   
            }  
            return 'Success';
        }
        catch(Exception e){
            return 'Fail';
        }
    }

    Public Static List<Schema.Location> jsonCollectionCommon (String locationJSONString, String conId){
        
        List<locationWrapper> locationResponse =  (List<locationWrapper>) System.JSON.deserialize(locationJSONString, List<locationWrapper>.class);
        List<Schema.Location> locationLstToUpdateOrInsert = new List<Schema.Location>();
        System.debug('locationResponse@@-'+locationResponse);

        List<Contact> conLst = [Select Id,Name, Map_Country__c from Contact where Id=: conId];
        Integer tempNum = 0;
        for(locationWrapper wrapData : locationResponse){

            System.debug('wrapData@@-'+wrapData);
            Schema.Location objLocation = new Schema.Location();
            
            if(wrapData.id == null){
                objLocation = createLocation(wrapData,conLst[0], tempNum);
                objLocation.Driver__c = conId;
            }else{
                objLocation = createLocation(wrapData,conLst[0], tempNum);
                objLocation.Id = wrapData.id;
                objLocation.Driver__c = conId;
            }
            locationLstToUpdateOrInsert.add(objLocation);
            tempNum++;
        }
        return locationLstToUpdateOrInsert;
    }

    private static Schema.Location createLocation(locationWrapper wrapData, Contact objContact, Integer tempNum){
       
        Schema.Location objLocation = new Schema.Location();
        objLocation.Name = (wrapData.name == null || wrapData.name == '') ? String.valueOf(objContact.Id)+' '+tempNum : wrapData.name;
        objLocation.Address__CountryCode__s = objContact.Map_Country__c == 'CANADA' ? 'CA' : 'US';
        String stateCode;
        if(wrapData.state != '') {
            if(objContact.Map_Country__c == 'USA') {
                usMcs = usSatatesList__mdt.getAll();
                System.debug('state Name : ' + wrapData.state);
                usSatatesList__mdt st = usMcs.get(wrapData.state);
                stateCode = st.shortName__c;
            } else {
                cnMcs = cndStatesList__mdt.getAll();
                cndStatesList__mdt st = cnMcs.get(wrapData.state);
                stateCode = st.shortName__c;
            }
        } else {
            stateCode = null;
        }
        objLocation.Address__StateCode__s = stateCode;
        objLocation.Address__City__s = wrapData.city;
        objLocation.Address__PostalCode__s = wrapData.zipCode;
        objLocation.Address__Street__s = wrapData.street;
        // objLocation.Location_Address__c =  wrapData.street + ', ' + wrapData.city + ', ' + wrapData.state + ' ' + wrapData.zipCode;
        objLocation.Location_Address__c = wrapData.address;
        objLocation.Latitude = wrapData.latitude;
        objLocation.Longitude = wrapData.longitude;
        objLocation.Range__c =wrapData.range;
        objLocation.Activity__c = wrapData.activity;
        objLocation.New_Location_Name__c = wrapData.name == '' ? null : wrapData.name;

        return objLocation;        
    }

    public class locationWrapper{
        public String userId{get;set;} 
        public string id{get;set;} 
        public string name{get;set;}
        public Decimal latitude{get;set;}
        public Decimal longitude{get;set;}
        public string address{get;set;}
        public string street{get;set;}
        public string city{get;set;}
        public string state{get;set;}
        public String zipCode{get;set;}
        public Decimal range{get;set;}
        public String activity{get;set;}
    }
}