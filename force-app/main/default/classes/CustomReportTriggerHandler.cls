/**
 * @File Name          : CustomReportTriggerHandler.cls
 * @Description        : Custom Report Trigger handler class
 * @Author             : GetOnCRM Solutions LLP
**/
public with sharing class CustomReportTriggerHandler{
    
    /*
        Method to validate added/ updated Custom report record
    */
    public static void ValidateCustomReoport( List<Custom_Report__c> reportList){
        for(Custom_Report__c cr : reportList) {
            if( String.isNotBlank(cr.Report_Soql__c) 
                && cr.Report_Soql__c.containsIgnoreCase('select') 
                && cr.Report_Soql__c.containsIgnoreCase(',') && cr.Report_Soql__c.containsIgnoreCase('from')) {
                List<String> fieldList = new List<String>();
                String query =  cr.Report_Soql__c.removeStartIgnoreCase('select').toLowerCase();

                System.debug('query: ' + query);
                System.debug('query: ' + query);
                String[] fields = String.valueOf(query.split(' from ')[0]).split(',');
                for(String cField : fields){
                    fieldList.add(cField.toLowerCase().trim());
                }
                
                System.debug('fieldList: ' + JSON.serializePretty(fieldList));
                System.debug('cr.Date_Fields__c: ' + cr.Date_Fields__c);
                System.debug('cr.Date_Time_Fields__c: ' + cr.Date_Time_Fields__c);
                System.debug('cr.Numeric_Fields__c: ' + cr.Numeric_Fields__c);
                System.debug('cr.Date_Time_To_Time__c: ' + cr.Date_Time_To_Time__c);

                if(String.isNotBlank(cr.Date_Fields__c)) 
                    CheckField(fieldList, cr.Date_Fields__c, Label.Custom_Report_Err_Message.replace('***', 'Date'), cr );               
                
                if(String.isNotBlank(cr.Date_Time_Fields__c))
                    CheckField(fieldList, cr.Date_Time_Fields__c, Label.Custom_Report_Err_Message.replace('***', 'Date Time'), cr );              
                
                if(String.isNotBlank(cr.Numeric_Fields__c))
                    CheckField(fieldList, cr.Numeric_Fields__c, Label.Custom_Report_Err_Message.replace('***', 'Numeric'), cr );  
                    
                if(String.isNotBlank(cr.Date_Time_To_Time__c))
                    CheckField(fieldList, cr.Date_Time_To_Time__c, Label.Custom_Report_Err_Message.replace('***', 'Time'), cr );      
            }
            else if( !String.isNotBlank(cr.Report_Soql__c) 
                    || !cr.Report_Soql__c.containsIgnoreCase('select')
                    || !cr.Report_Soql__c.containsIgnoreCase('from') ) {

                cr.addError(Label.Custom_Report_Err_Message.replace('*** Field', 'valid query'));
            }

            if(!cr.Use_Driver_List__c && !cr.Use_Manager_List__c ) 
                cr.addError('Please Select 1 of the Filters');
        }
    }

    /*
        @fieldList - Available field list with query field
        @fieldvalue - available field value
        @message - Error message to display
        @cr - current custom report record
    */
    public static void CheckField ( List<String> fieldList, String fieldValue, String message, Custom_Report__c cr) {

        for(String cField : fieldValue.split(',')) {
            if(!fieldList.contains(cField.toLowerCase().trim())) {
                cr.addError(message);
                break;
            }
        }
        
    }
}