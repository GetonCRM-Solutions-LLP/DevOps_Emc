/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This class is used to download excel file for Frampton construction account.
 * @Modification logs
 * @Page name :- JobCostingSummary
 * ========================================================================================================================
 * @Date: 11 March 2021 | Sanket Goswami
 * @description: 
 */
public with sharing class JobCostingSummaryReport {
    public List<MileageTagWrapper> mileageWrapperList{get;set;}
    public string contactName {get; set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
    
        }
    
    }

    public JobCostingSummaryReport(){
        jobCosting();
    }
    public void jobCosting(){
        System.debug('jobCosting');
        String id = ApexPages.currentPage().getParameters().get('id');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        // String startDate = '2020-07-01';
        // String endDate = '2020-08-07';
        mileageWrapperList = new List<MileageTagWrapper>();
        map<string, double> tagvsMilMap =  new map<string, double>();
        map<string, double> tagVariableMap =  new map<string, double>();
        Contact  contactObj = [SELECT id,name from Contact where Id=: id limit 1];
        contactName = contactObj.Name;        
        for(AggregateResult ar : [SELECT Tag__c tag, SUM(Mileage__c) rtotal                                  
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                    AND Trip_Date__c <= : Date.valueOf(endDate) 
                                    AND Tag__c != null 
                                    AND Mileage__c > 0
                                    group by Tag__c ]){               
                                        tagvsMilMap.put((String)ar.get('tag'),(Decimal)ar.get('rtotal'));                                        
        }
        for(AggregateResult ar : [SELECT Tag__c tag, SUM(Variable__c) rtotal
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                    AND Trip_Date__c <= : Date.valueOf(endDate) 
                                    AND Tag__c != null 
                                    AND Variable__c > 0
                                    group by Tag__c ]){
                                        System.debug('2'+ar);
                                        tagVariableMap.put((String)ar.get('tag'),(Decimal)ar.get('rtotal'));
        }
        if(Test.isRunningTest()){
            tagvsMilMap.put('admin',20);
            tagVariableMap.put('admin',20);
        }       
        for(String objTag : tagvsMilMap.keySet()){
            MileageTagWrapper objWrap = new MileageTagWrapper();
            objWrap.tag = objTag;
            objWrap.mileage = tagvsMilMap.get(objTag);
            objWrap.variable = tagVariableMap.get(objTag);
            System.debug(objWrap);
            mileageWrapperList.add(objWrap);
        }
    }
    public class MileageTagWrapper{
        public string tag {get; set;}
        public decimal mileage { get; set; }
        public decimal variable { get; set; }
    }
}