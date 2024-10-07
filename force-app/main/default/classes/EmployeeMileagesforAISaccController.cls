/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Apex class use to download a excel file for total reimbursment for AIS account.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * Page Name :- MileagesforAISAccountReport
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 22 Feb 2021
 */
public with sharing class EmployeeMileagesforAISaccController {
    public List<milWrapper> milWrapList {get; set; }
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public EmployeeMileagesforAISaccController() {
        getEmployeeMileages();
    }
    
    // This method is used to get the mileages and do sum of that trips and calculate total reimbursement.
    public void getEmployeeMileages() {
        //String startDate = '2021-01-01';
        //String endDate = '2021-01-31';
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        milWrapList = new List<milWrapper>();
        Map<Id, Decimal> mileageMap = new Map<Id, Decimal>();
        Map<Id, Decimal> variableMap = new Map<Id, Decimal>();
        List<String> lastPaydateSplitted = new List<String>();
        system.debug('startDate=='+startDate);
        if((String.valueOf(startDate).contains('-'))) {
                        lastPaydateSplitted = String.valueOf(startDate).split('-');                
        }
        String reimMonth = lastPaydateSplitted[1]+'-'+lastPaydateSplitted[0];
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c rid, SUM(Mileage__c) rtotal
                                FROM Employee_Mileage__c 
                                WHERE   EmployeeReimbursement__r.Contact_Id__r.Account.Name = 'Advanced Inventory Solutions'
                                        AND Trip_Date__c >= : Date.valueOf(startDate)
                                        AND Trip_Date__c <= : Date.valueOf(endDate)
                                        AND Trip_Status__c = 'Approved' 
                                        AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null 
                                        AND EmployeeReimbursement__r.Contact_Id__r.Role__c != 'Admin' 
                                        AND EmployeeReimbursement__r.Contact_Id__r.Role__c !='Manager' 
                                  AND Approved_Date__c != null group by EmployeeReimbursement__r.Contact_Id__c]) {
            mileageMap.put((Id)ar.get('rid'), (Decimal) ar.get('rtotal'));    
        }

        for(Employee_Mileage__c objMil : [SELECT EmployeeReimbursement__r.Contact_Id__c,
                                                    EmployeeReimbursement__r.Fixed_Amount__c, 
                                                    EmployeeReimbursement__r.Total_Variable_Rate__c,
                                                    EmployeeReimbursement__r.Variable_Rate__c
                                            FROM Employee_Mileage__c 
                                            WHERE   EmployeeReimbursement__r.Contact_Id__r.Account.Name = 'Advanced Inventory Solutions'
                                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                                    AND Trip_Date__c <= : Date.valueOf(endDate)
                                                    AND Trip_Status__c = 'Approved' 
                                            AND Approved_Date__c != null
                                            AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null 
                                            AND EmployeeReimbursement__r.Contact_Id__r.Role__c != 'Admin' 
                                            AND EmployeeReimbursement__r.Contact_Id__r.Role__c !='Manager' ]) {
            variableMap.put(objMil.EmployeeReimbursement__r.Contact_Id__c,objMil.EmployeeReimbursement__r.Total_Variable_Rate__c);
        }
        for(Contact currentContact : [SELECT id,Name,External_Email__c,Employee_ID__c 
                                            FROM Contact 
                                            WHERE Account.Name = 'Advanced Inventory Solutions'
                                            AND Deactivated_Date__c = null
                                            AND Role__c != 'Admin' 
                                            AND Role__c !='Manager']) {
            List<String> dateSplitted = new List<String>();
            if(endDate != null && endDate.contains('-')){
                dateSplitted = String.valueOf(endDate).split('-');
            }
            
            milWrapper objWrap = new milWrapper();
            objWrap.name = currentContact.Name;
            objWrap.email = currentContact.External_Email__c;
            objWrap.employeeID = currentContact.Employee_ID__c;
            if(!dateSplitted.isEmpty()){
				objWrap.payperioddate = dateSplitted[1]+'/'+dateSplitted[2]+'/'+dateSplitted[0];
            }
            if(mileageMap.containsKey(currentContact.Id)){
                objWrap.mileages = mileageMap.get(currentContact.Id);
            } else {
                objWrap.mileages = 0;
            }
            if(variableMap.containsKey(currentContact.Id)){
                objWrap.variableRate = variableMap.get(currentContact.Id);
            } else {
                objWrap.variableRate = 0;
            }
            if(objWrap.mileages > 0 ){
                objWrap.variableAmount = ((mileageMap.get(currentContact.Id) * objWrap.variableRate).setScale(2));
            } else {
                objWrap.variableAmount = 0;
            }
            milWrapList.add(objWrap);
        }
    }

    public class milWrapper {
        public string name { get; set; }
        public string employeeID { get; set; }
        public string email { get; set; }
        public string payperioddate { get; set; }
        public decimal mileages { get; set; }
        public decimal variableRate { get; set; }
        public decimal variableAmount { get; set; }
        public milWrapper(){}
    }
}