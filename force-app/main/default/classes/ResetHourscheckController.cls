public with sharing class ResetHourscheckController {
    private ApexPages.StandardController stdController;
    public Boolean refreshPage {get; set;}
    
    public ResetHourscheckController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.refreshPage = false;
    }
    
    public PageReference resetFields() {
        Bi_Weekly_Reimbursement__c objBiReim = (Bi_Weekly_Reimbursement__c)stdController.getRecord();
        objBiReim.Confirm_Hours__c = false;
        objBiReim.Error_Hours__c = false;
        objBiReim.Count_Error_Check__c = 0;
        
        try {
            update objBiReim;
            refreshPage = true;
        } catch (DmlException e) {
            System.debug('Error =>'+e.getMessage());
        }
        
        return null;
    }
}