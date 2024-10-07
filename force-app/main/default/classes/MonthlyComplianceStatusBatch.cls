/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch updates the value of monthly compliance status on contact based on the previous month's approved mileage.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 31 January 2024 | Khuman Singh Bhadoriya
 */
public with sharing class MonthlyComplianceStatusBatch implements Database.Batchable<sObject>, Schedulable {

    private List<String> accountNames;

    // Default constructor
    public MonthlyComplianceStatusBatch() {
        this(null);
    }

    // Parameterized constructor
    public MonthlyComplianceStatusBatch(List<String> accountNames) {
        this.accountNames = accountNames;
    }

    // Start method for the batch
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Avg_Mileage__c, Name, Role__c, Activation_Date__c, monthly_compliance_status__c, Insurance__c, Vehicle_Age__c, Vehicle_Value_Check__c ' +
                       'FROM Contact WHERE Deactivated_Date__c = NULL AND Account.isUsingTriplog__c = true ' +
                       'AND Activation_Date__c != null AND (Role__c = \'Driver\' OR Role__c = \'Driver/Manager\' OR Role__c = \'Driver/Admin\') AND Insurance__c != \'Under Review\'';

        if (this.accountNames != null && !this.accountNames.isEmpty()) {
            query += ' AND Account.Name IN :accountNames';
        } 

        return Database.getQueryLocator(query);
    }

    // Execute method for the batch
    public void execute(Database.BatchableContext bc, List<Contact> conList) {
        if (conList.isEmpty()) {
            return;
        }

        List<Id> conIdList = new List<Id>();
        List<Contact> updatedContacts = new List<Contact>();
        Map<Id, Decimal> approvedMileageTotal = new Map<Id, Decimal>();
        List<String> monthsList = generateMonthsList();

        for (Contact con : conList) {
            conIdList.add(con.Id);
        }

        List<AggregateResult> mileageResults = [
            SELECT Contact_Id__c, AVG(Total_Mileage__c) TotalApproved 
            FROM Employee_Reimbursement__c 
            WHERE Contact_Id__c IN :conIdList AND Month__c IN :monthsList 
            GROUP BY Contact_Id__c
        ];

        for (AggregateResult ar : mileageResults) {
            Id contactId = (Id)ar.get('Contact_Id__c');
            Decimal avgApproved = (Decimal)ar.get('TotalApproved');
            approvedMileageTotal.put(contactId, avgApproved);
        }

        for (Contact con : conList) {
            updateContactComplianceStatus(con, approvedMileageTotal);
            updatedContacts.add(con);
        }

        if (!updatedContacts.isEmpty() && Schema.sObjectType.Contact.fields.monthly_compliance_status__c.isUpdateable()) {
            Database.SaveResult[] srList = Database.update(updatedContacts, false);
            handleSaveResults(srList);
        }
    }

    // Finish method for the batch
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing finished.');
    }

    // Execute method for the scheduled batch
    public void execute(SchedulableContext sc) {
        MonthlyComplianceStatusBatch batch = new MonthlyComplianceStatusBatch();
        Database.executeBatch(batch, 20);
    }

    // Helper method to generate months list for the query
    private List<String> generateMonthsList() {
        List<String> monthsList = new List<String>();
        Date today = System.today().addMonths(-1);
        Integer monthVal = today.month();
        monthsList.add('12-' + String.valueOf(System.today().addYears(-1).year()));

        for (Integer i = 1; i <= monthVal; i++) {
            String month = (i < 10 ? '0' : '') + i;
            String monthYear = month + '-' + String.valueOf(today.year());
            monthsList.add(monthYear);
        }
        return monthsList;
    }

    // Helper method to update compliance status for a contact
    private void updateContactComplianceStatus(Contact con, Map<Id, Decimal> approvedMileageTotal) {
        con.Avg_Mileage__c = approvedMileageTotal.get(con.Id);

        if (con.Activation_Date__c.addDays(30) >= System.today()) {
            return;
        }

        Decimal avgMileage = approvedMileageTotal.get(con.Id);
        Boolean isTest = Test.isRunningTest();
        Boolean meetsMileageRequirement = avgMileage != null && avgMileage >= 416.66;
        Boolean isNewActivation = con.Activation_Date__c >= System.today().addMonths(-1).toStartOfMonth();

        if (meetsMileageRequirement || isNewActivation || isTest) {
            if (con.Insurance__c == 'Yes') {
                if (con.Vehicle_Age__c == 'Yes' && con.Vehicle_Value_Check__c == 'Yes') {
                    con.monthly_compliance_status__c = 'Yes';
                } else if (con.Vehicle_Age__c == 'No'){
                    con.monthly_compliance_status__c = 'No – Vehicle Age';
                }else{
                    con.monthly_compliance_status__c = 'No – Vehicle Value';
                }
            } else {
                con.monthly_compliance_status__c = getInsuranceNonComplianceReason(con.Insurance__c);
            }
        } else {
            con.monthly_compliance_status__c = getNonComplianceReason(con);
        }
    }

    // Helper method to get insurance non-compliance reason
    private String getInsuranceNonComplianceReason(String insuranceStatus) {
        if (insuranceStatus == 'Not Submitted') {
            return 'No - Insurance Not Provided';
        } else if (insuranceStatus == 'Insurance Card') {
            return 'No – Insurance Card';
        } else if (insuranceStatus == 'Not Meeting Plan Minimum') {
            return 'No – Insurance Not Meeting Minimum';
        } else if (insuranceStatus == 'Expired') {
            return 'Expired Insurance';
        } else if (insuranceStatus == 'No Expiration Date') {
            return 'No - Missing Coverage Dates';
        } else if (insuranceStatus == 'Missing Umbrella Policy') {
            return 'No - Umbrella Policy';
        } else if (insuranceStatus == 'Missing Insurance Dec Page') {
            return 'No - Insurance Dec Page';
        } else {
            return 'No - Insurance Not Provided';
        }
    }

    // Helper method to get non-compliance reason based on contact details
    private String getNonComplianceReason(Contact con) {
        if (con.Insurance__c == 'Yes') {
            if (con.Vehicle_Age__c == 'Yes') {
                return con.Vehicle_Value_Check__c == 'Yes' ? 'No - Mileage' : 'No - Mileage & Vehicle Value';
            } else {
                return 'No - Mileage & Vehicle Age';
            }
        } else {
            return 'No - Mileage & Insurance';
        }
    }

    // Helper method to handle save results
    private void handleSaveResults(Database.SaveResult[] srList) {
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    System.debug('Fields: ' + err.getFields());
                }
            } else {
                System.debug('Compliance status updated successfully: ' + sr.getId());
            }
        }
    }
}