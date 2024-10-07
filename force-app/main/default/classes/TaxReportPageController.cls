/**
@author Pruthviraj Israni
@date 12th Oct 2020
@description TaxReportPageController is used to show Account's employee(drivers) traveling state detail.
*/
public with sharing class TaxReportPageController {
    public string inputMonthYear {get;set;}
    public string monthNameYear {get;set;}
    public string driverType {get; set;}
    public string excelfileName {get; set;}
    public final string ermiAcc = 'Ermi';
    public final string driverType1 = 'Driver - Part Time';
    public final string driverType2 = 'Driver - Full Time';
    public final string driverType3 = 'Driver - Salary';

    //public List<String> topRowAllStateList {get;set;}
    public List<Employee_Mileage__c> milList {get;set;}
    public Map<Id,String> contIdNameMap {get;set;}
    public Map<Id,String> contIdEmailMap {get;set;}
    public List<daysinStateWrapper> dayStateWrapList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    
    }
    public TaxReportPageController() {
        inputMonthYear = ApexPages.currentPage().getParameters().get('month');
        string monthName = WrapperUtils.getMonthNamefromno(Integer.valueOf(inputMonthYear.substringBefore('-')));
        string year = inputMonthYear.substringAfter('-');
        monthNameYear = monthName + ' ' + year; 
        driverType = ApexPages.currentPage().getParameters().get('empType');
        excelfileName = driverType +' '+ monthNameYear + ' Tax Report';
        if(driverType != null && inputMonthYear != null){
            if(driverType == 'All Employees' ){
                milList =[SELECT id,
                            Trip_Origin_State__c, Trip_Destination_State__c,
                            Trip_Date__c,EmployeeReimbursement__c,
                            EmployeeReimbursement__r.Contact_Id__c,
                            EmployeeReimbursement__r.Contact_Id_Name__c,
                            EmployeeReimbursement__r.Contact_Email__c
                        FROM Employee_Mileage__c
                        WHERE EmployeeReimbursement__r.Contact_Id__r.Account.Name = 'Ermi'
                        AND EmployeeReimbursement__r.Month__c =:inputMonthYear];    
            }else{
                string type;
                if(driverType.contains('Part Time')){
                    type = driverType1;
                }
                if(driverType.contains('Full Time')){
                    type = driverType2;
                }
                if(driverType.contains('Salary')){
                    type = driverType3;
                }
                milList =[SELECT id,
                                Trip_Origin_State__c, Trip_Destination_State__c,
                                Trip_Date__c,EmployeeReimbursement__c,
                                EmployeeReimbursement__r.Contact_Id__c,
                                EmployeeReimbursement__r.Contact_Id_Name__c,
                                EmployeeReimbursement__r.Contact_Email__c,
                                EmployeeReimbursement__r.Contact_Id__r.driver_type__c
                            FROM Employee_Mileage__c
                            WHERE EmployeeReimbursement__r.Contact_Id__r.Account.Name =: ermiAcc
                            AND EmployeeReimbursement__r.Month__c =:inputMonthYear
                            AND EmployeeReimbursement__r.Contact_Id__r.driver_type__c =: type];
            }
        }
        //setTopRow();
        filldaysinStateWrap();
    }
    /*
    public void setTopRow(){
        topRowAllStateList = new List<String>();
        Set<String> tempStateSet = new Set<String>();
        for(Employee_Mileage__c milObj : milList){
            if(mil)
            tempStateSet.add(milObj.Trip_Origin_State__c);
            tempStateSet.add(milObj.Trip_Destination_State__c);
        }
        system.debug('all tempStateSet-----'+tempStateSet);
        topRowAllStateList.addAll(tempStateSet);
        topRowAllStateList.sort();
        system.debug('all state list-----'+topRowAllStateList);
    }
    */

    public void filldaysinStateWrap(){
        contIdNameMap = new Map<Id,String>();
        contIdEmailMap =new Map<Id,String>();
        dayStateWrapList = new List<daysinStateWrapper> ();
        //Map<String,String> cont_TripDate_StateMap = new Map<String,String>();
        Map<String,Integer> contId_TripDate_State_DaysMap = new Map<String,Integer>(); //contactId,tripdate,state --- count
        for(Employee_Mileage__c milObj : milList){
            Integer tripCount = 0;
            String contId = milObj.EmployeeReimbursement__r.Contact_Id__c;
            String contName = milObj.EmployeeReimbursement__r.Contact_Id_Name__c;
            String contEmail = milObj.EmployeeReimbursement__r.Contact_Email__c;
            contIdNameMap.put(contId, contName);
            contIdEmailMap.put(contId, contEmail); 
            String tripDate = String.valueOf(milObj.Trip_Date__c);
            String oState = milObj.Trip_Origin_State__c;
            String dState = milObj.Trip_Destination_State__c;

            if(contId != null && tripDate != null){
                if(oState == dState){
                    tripCount = 1;
                    String mapKey = contId +','+ tripDate+','+oState;
                    if(!contId_TripDate_State_DaysMap.containsKey(mapKey)){
                        contId_TripDate_State_DaysMap.put(mapKey, 1);
                    }
                }else{
                    tripCount = 2;
                    String mapKey1 = contId +','+ tripDate+','+oState;
                    String mapKey2 = contId +','+ tripDate+','+dState;
                    if(oState != null){
                        if(!contId_TripDate_State_DaysMap.containsKey(mapKey1)){
                            contId_TripDate_State_DaysMap.put(mapKey1, 1);
                        }
                    }
                    if(dState != null){
                        if(!contId_TripDate_State_DaysMap.containsKey(mapKey2)){
                            contId_TripDate_State_DaysMap.put(mapKey2, 1);
                        }
                    }
                }
            }
        }
        system.debug('----map----'+ contId_TripDate_State_DaysMap);
        Map<String,Integer> contId_State_DaysMap = new Map<String,Integer>();
        for(String key : contId_TripDate_State_DaysMap.keySet()){
            List<String> templist = key.split(',');
            string newKey = templist[0]+','+templist[2];
            Integer oldCount = contId_TripDate_State_DaysMap.get(key);

            if(contId_State_DaysMap.containsKey(newKey)){
                Integer newCount = contId_State_DaysMap.get(newKey);
                contId_State_DaysMap.put(newKey, oldCount + newCount); 
            }else{
                contId_State_DaysMap.put(newKey, oldCount);
            }

        }
        system.debug('----map----'+ contId_State_DaysMap);
        //List<daysinStateWrapper> wrapLid
        for(String key : contId_State_DaysMap.keySet()){
            daysinStateWrapper wrapObj = new daysinStateWrapper();
            wrapObj.driverName = contIdNameMap.get(key.substringBefore(','));
            wrapObj.email = contIdEmailMap.get(key.substringBefore(','));
            wrapObj.stateName = key.substringAfter(',');
            wrapObj.daysCountInState = contId_State_DaysMap.get(key);
            dayStateWrapList.add(wrapObj);
        }
        System.debug('==='+dayStateWrapList);
    }
    
    
    public class daysinStateWrapper{
        public string driverName {get;set;}
        public string email {get;set;}
        public string stateName {get;set;}
        public Integer daysCountInState {get;set;}
        public daysinStateWrapper(){}
    }
}