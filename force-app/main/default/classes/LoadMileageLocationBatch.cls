/*
*  @Author:          GetonCRM Solutions LLP
*  @Desription:      Batch class to update geo location co-ordinates to mileage based on location Id.
*  @Version:         1.0.0
*/
global class LoadMileageLocationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    //global static final string LOC_URL = Label.Triplog_Location_API;
    global Set<Id> mileageIds;
    global Set<Id> reimbersumentIds;
    global String baseURL ;
    /*
        Contructor with Mileage Ids or reimbursement
    */
    global LoadMileageLocationBatch(Set<Id> recordIds, Boolean isReim) {
        if(isReim)
            this.reimbersumentIds = recordIds;
        else
            this.mileageIds = recordIds;
        
    }

    global LoadMileageLocationBatch(){}

    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id,EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c, ' +
                       ' From_Location__c, To_Location__c, FromLocationId__c, ToLocationId__c ' +
                       ' FROM Employee_Mileage__c WHERE ' +
                       ' ( FromLocationId__c != null  OR ' +
                       '   ToLocationId__c != null ) AND ' +
                       ' EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c != null';
        if(mileageIds != null && !mileageIds.isEmpty())
            query += ' AND  Id In: mileageIds';
        if(reimbersumentIds != null && !reimbersumentIds.isEmpty())
            query += ' AND  EmployeeReimbursement__c In: reimbersumentIds';
        query += ' order by CreatedDate desc ' +
                    ' LIMIT 49999';
        return Database.getQueryLocator(query);
    }
    
    //Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Map<Id, Employee_Mileage__c> milMap = new Map<Id, Employee_Mileage__c>();
        for( Employee_Mileage__c mil : (List<Employee_Mileage__c>) scope) {
            baseURL = !MLOGACCOUNT.Contains(mil.EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
            baseURL = baseURL + StaticValues.GETTRIPLOCATION_SUFFIX;
            if(mil.From_Location__c == null && mil.FromLocationId__c != null ) {
                MakeLocationCallout(mil, milMap, true);
            }
            
            if(mil.To_Location__c == null && mil.ToLocationId__c != null ) {
                MakeLocationCallout(mil, milMap, false);
            }
        }

        if(!milMap.isEmpty())
            update milMap.values();
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    /**
        @description: Method to set latitude and longitude
        @param String response body from location API
        @param Employee_Mileage__c mileage record to update 
        @param Boolean varible to identify location type
    **/
    void SetLocation(String body, Employee_Mileage__c mil, Boolean isFrom ) {
        Map<String, object> responseMap = (Map<String, object>)JSON.deserializeUnTyped(body);
        Map<String, object> locMap = (Map<String, object>) responseMap.get('location');
        if(isFrom) {
            mil.From_Location__latitude__s = (Decimal)locMap.get('latitude');
            mil.From_Location__longitude__s = (Decimal)locMap.get('longitude');
        } else {
            mil.To_Location__latitude__s = (Decimal)locMap.get('latitude') ;
            mil.To_Location__longitude__s = (Decimal)locMap.get('longitude') ;
        }
    }

    /**
        @description: Method to set latitude and longitude
        @param Employee_Mileage__c mileage record to update 
        @param Employee_Mileage__c mileage map with updated values 
        @param Boolean varible to identify location type
    **/
    void MakeLocationCallout(Employee_Mileage__c mil, Map<Id, Employee_Mileage__c> milMap, Boolean isFrom) {
        HttpResponse res = ApiCalloutUtility.executeCallout(
                                        mil.EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c,
                                        'GET',
                                        baseURL,
                                        '' + ( isFrom ? mil.FromLocationId__c.longValue() :  mil.ToLocationId__c.longValue() ),
                                        ''
                                    );
        if(res.getStatusCode() == 200) {
            SetLocation(res.getBody(), mil, isFrom);
            milMap.put(mil.Id, mil);
        }
    }

}