/*
***************************************************************************
Descreption: Controller for Update_Mileages Page
Functionality : Update Mileages - Change its Reim, Approved Date and Status
***************************************************************************
*/
public with sharing class UpdateMileageController {
   /* public Employee_Mileage__c mil                      {get; set;}*/
    public Employee_Reimbursement__c empReimbursement   {get; set;}
    public List<Employee_Mileage__c> empMileageList     {get; set;}
    /*public String empReim                               {get; set;}
    public String empMilStatus                          {get; set;}
    public String empReimStatus                         {get; set;}
    public Date empMilApprovedDate                      {get; set;}
    public Date empReimApprovedDate                     {get; set;}
    public double empReimFuel                           {get; set;}
    public Set<Id> empMileageIds;*/

    public Id reimbursementId                           {get; set;}
    public Employee_Reimbursement__c newReimbursement   {get; set;}
    public Employee_Mileage__c mileage                  {get; set;}
    public List<MileageWrapper> mileageWrapper          {get; set;}
    private Integer counter   = 0;
    private Integer list_Size = 500;
    private Integer total_Size                          {get; set;}
    /*public  Integer selected_Item                       {get; set;}*/
    public String messageView                           {get; set;}
    public String message                               {get; set;}
    public String jsonSubset                            {get; set;}
    
    public UpdateMileageController() {
    jsonSubset = '';
        reimbursementId  = ApexPages.currentPage().getParameters().get('id');
        try {
            empReimbursement = [SELECT Id,
                                       Name,
                                       Approved_Date__c,
                                       Status__c,
                                       Fuel_Price__c
                                  FROM Employee_Reimbursement__c
                                 WHERE Id =:reimbursementId];
            total_Size       = [SELECT count()
                                  FROM Employee_Mileage__c 
                                 WHERE EmployeeReimbursement__r.Id =: reimbursementId];
        } catch(QueryException e){
            System.debug('QueryException:'+e.getMessage());
        }               
        newReimbursement  = new  Employee_Reimbursement__c();
        mileage = new Employee_Mileage__c();
        Cookie cookie = ApexPages.currentPage().getCookies().get('message');
        if(cookie != null){
          messageView = cookie.getValue();
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,messageView));
        }
        //init();
        //initQueryMileage();
        //initQueryReim();
    }
    public void init() {
        /*empMileageIds = new Set<Id>();
        mil = new Employee_Mileage__c();
        empReimbursement = new Employee_Reimbursement__c();
        String mileageIds = ApexPages.currentPage().getParameters().get('id');
        String[] Ids = mileageIds.split(',');
        for(Integer i=0; i<Ids.size(); i++) {
            empMileageIds.add(Ids[i]);
        }*/
    }
    /*public void initQueryMileage() {
        empMileageList = [SELECT Name, 
                                 EmployeeReimbursement__r.Name, 
                                 EmployeeReimbursement__r.Approved_Date__c, 
                                 EmployeeReimbursement__r.Status__c, 
                                 EmployeeReimbursement__r.Fuel_Price__c,  
                                 Fuel_price__c, 
                                 Trip_Status__c, 
                                 Approved_Date__c
                                 FROM Employee_Mileage__c
                                 WHERE id =: empMileageIds];
    }
    public void initQueryReim() {
        empReimbursement = [SELECT Id, Name, Approved_Date__c, Status__c, Fuel_Price__c, Fixed_Amount__c
                                FROM Employee_Reimbursement__c 
                                WHERE id =: empMileageList[0].EmployeeReimbursement__c LIMIT 1];
        empReim = empReimbursement.Name;
        empMilApprovedDate = empMileageList[0].Approved_Date__c;
        empMilStatus = empMileageList[0].Trip_Status__c;
        empReimApprovedDate = empReimbursement.Approved_Date__c;
        empReimStatus = empReimbursement.Status__c;
        empReimFuel = empReimbursement.Fuel_Price__c;
        empReimbursement = new Employee_Reimbursement__c(id=empReimbursement.id);
    }
    public void updateRecords() {
        String msg = 'Successfully Updated';
        update empReimbursement;
        if(mil.EmployeeReimbursement__c != null) {
            empReimbursement = [SELECT Id, Name, Approved_Date__c, Status__c, Fuel_Price__c, Fixed_Amount__c
                                    FROM Employee_Reimbursement__c 
                                    WHERE id =: mil.EmployeeReimbursement__c LIMIT 1];
            for(Employee_Mileage__c emp : empMileageList) {
                emp.EmployeeReimbursement__c = mil.EmployeeReimbursement__c;
                emp.Fuel_Price__c = empReimbursement.Fuel_Price__c;
                if(mil.Trip_Status__c != null && mil.Trip_Status__c != '') {
                    emp.Trip_Status__c = mil.Trip_Status__c;
                }
                if(mil.Approved_Date__c != null) {
                    emp.Approved_Date__c = mil.Approved_Date__c;
                }
            }
        } else {
            for(Employee_Mileage__c emp : empMileageList) {
                emp.Fuel_Price__c = empReimFuel;
                if(mil.Trip_Status__c != null && mil.Trip_Status__c != '') {
                    emp.Trip_Status__c = mil.Trip_Status__c;
                }
                if(mil.Approved_Date__c != null) {
                    emp.Approved_Date__c = mil.Approved_Date__c;
                }
            }
        }
        if(((mil.Trip_Status__c != null && mil.Trip_Status__c != '') || mil.Approved_Date__c != null) && (mil.Trip_Status__c != empMilStatus || mil.Approved_Date__c != empMilApprovedDate)) {
            if(mil.Trip_Status__c != empMilStatus) {
               msg = msg + '--Trip Status : ' + mil.Trip_Status__c;
            }
            if(mil.Approved_Date__c != empMilApprovedDate) {
               msg = msg + ' -- Approved Date : ' + mil.Approved_Date__c;
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,msg));
        }
        update empMileageList;
        initQueryMileage();
        initQueryReim();
    }*/

    public List<MileageWrapper> getMileagesList() {
        try{
            empMileageList   = [SELECT Id,
                                       Name,
                                       Approved_Date__c,
                                       Trip_Status__c,
                                       Trip_Id__c,
                                       Mileage__c,
                                       Trip_Date__c,
                                       Fuel_price__c,
                                       MPG__c,
                                       Maintenance_and_Tires__c,
                                       EmployeeReimbursement__c,
                                       Activity__c
                                  FROM Employee_Mileage__c
                                 WHERE EmployeeReimbursement__r.Id =: reimbursementId
                                 LIMIT :list_Size
                                OFFSET :counter];
            mileageWrapper = new List<MileageWrapper>();                    
            for(Employee_Mileage__c singleMileage : empMileageList) {
                mileageWrapper.add(new MileageWrapper(singleMileage));
            }
            return mileageWrapper;
        } catch(QueryException e) {
            System.debug('QueryException:'+e.getMessage());
            return null;
        }                       
    }

    public PageReference updateMileages(){
        List<Employee_Mileage__c> selectedMileages = new List<Employee_Mileage__c>();
        message = '';
        update empReimbursement;
        message = 'Reimbursement Updated';
        
        for(MileageWrapper singleMileage : mileageWrapper) {
            if(singleMileage.isSelected == true) {
                empReimbursement.Id = (mileage.EmployeeReimbursement__c != null) ? mileage.EmployeeReimbursement__c : empReimbursement.Id;
                singleMileage.mileage.EmployeeReimbursement__c = empReimbursement.Id;
                /*singleMileage.mileage.Approved_Date__c = (mileage.Approved_Date__c != null && empReimbursement.Approved_Date__c == null) ? mileage.Approved_Date__c : 
                                                         (mileage.Approved_Date__c == null && empReimbursement.Approved_Date__c != null) ? empReimbursement.Approved_Date__c : 
                                                         (mileage.Approved_Date__c != null && empReimbursement.Approved_Date__c != null) ? empReimbursement.Approved_Date__c : singleMileage.mileage.Approved_Date__c;*/
                /*singleMileage.mileage.Trip_Status__c   = (mileage.Trip_Status__c != null && empReimbursement.Status__c == null) ? mileage.Trip_Status__c : 
                                                         (mileage.Trip_Status__c == null && empReimbursement.Status__c != null) ? empReimbursement.Status__c : 
                                                         (mileage.Trip_Status__c != null && empReimbursement.Status__c != null) ? empReimbursement.Status__c : singleMileage.mileage.Trip_Status__c;*/
                singleMileage.mileage.Approved_Date__c = (mileage.Approved_Date__c != null) ? mileage.Approved_Date__c : singleMileage.mileage.Approved_Date__c;
                singleMileage.mileage.Mileage__c = (mileage.Mileage__c != null) ? mileage.Mileage__c : singleMileage.mileage.Mileage__c;
                singleMileage.mileage.Trip_Status__c = (mileage.Trip_Status__c != null) ? mileage.Trip_Status__c : singleMileage.mileage.Trip_Status__c;
                singleMileage.mileage.Activity__c = (mileage.Activity__c != null) ? mileage.Activity__c : singleMileage.mileage.Activity__c;
                singleMileage.mileage.MPG__c         = (mileage.MPG__c != null) ? mileage.MPG__c : singleMileage.mileage.MPG__c;
                singleMileage.mileage.Maintenance_and_Tires__c  = (mileage.Maintenance_and_Tires__c != null) ? mileage.Maintenance_and_Tires__c : singleMileage.mileage.Maintenance_and_Tires__c;
                singleMileage.mileage.Fuel_price__c = empReimbursement.Fuel_Price__c;
                selectedMileages.add(singleMileage.mileage);
            }
        }
        if(!selectedMileages.isEmpty()){
            upsert selectedMileages;
            message += ' And Also Mileage Updated';
        }
        setCookie();
        PageReference page = new PageReference('/apex/Update_Mileages?id='+empReimbursement.Id);
        page.setRedirect(true);
        return page;
    }
    
     public void putHTTP() {
       
        String apiToken;
        String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
        Set<Integer> trip_IDs = new Set<Integer>();
        List<Employee_Reimbursement__c> reimList = [SELECT id,Contact_Id__r.Account.Triplog_API__c FROM Employee_Reimbursement__c where id =: reimbursementId ];
        if(reimList.size() > 0) {
            apiToken = reimList[0].Contact_Id__r.Account.Triplog_API__c;
        }
        for(MileageWrapper singleMileage : mileageWrapper) {
            if(singleMileage.isSelected == true) {
                System.debug('==='+singleMileage.mileage.Trip_Id__c);
                trip_IDs.add(Integer.valueof(singleMileage.mileage.Trip_Id__c));
            }
        }
        HttpRequest putReq = new HttpRequest();
        Http putHTTP = new Http();
        String body = '{"status":"Not Submitted","ids":[';
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
        try {
            if(!Test.isRunningTest()){
                HttpResponse putRes = putHTTP.send(putReq);
                Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(putRes.getBody());
                jsonSubset = JSON.serialize(jsonMap.get('message'));
            }
        } catch(System.CalloutException er) {

        }
        System.debug('==='+trip_IDs);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Succesfully change status of trip to unsubmitteed'));
       
        //return jsonSubset;
    }

    public void setCookie() {
      Cookie cookie = new Cookie('message',message,null,1,true);
      ApexPages.currentPage().setCookies(new Cookie[] {cookie});
    }

    public PageReference Beginning() { //user clicked beginning
       counter = 0;
       return null;
    }

    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }

    public PageReference Next() { //user clicked next button
       counter += list_size;
       return null;
    }

    public PageReference End() { //user clicked end
       counter = total_size - math.mod(total_size, list_size);
       return null;
    }

    public Boolean getDisablePrevious() { 
       //this will disable the previous and beginning buttons
       if (counter>0) return false; else return true;
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
       if (counter + list_size < total_size) return false; else return true;
    }

    public Integer getTotal_size() {
       return total_size;
    }

    public Integer getPageNumber() {
       return counter/list_size + 1;
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }

    public class MileageWrapper {
        public Boolean isSelected           {get; set;}
        public Employee_Mileage__c mileage  {get; set;}

        public MileageWrapper(Employee_Mileage__c objectDetail){
            this.isSelected = false;
            this.mileage = objectDetail;
        }
    }
}