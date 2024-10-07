public with sharing class MissingFuelPrice implements Database.Batchable<sObject> {

    public List<Employee_Mileage__c> start(Database.BatchableContext bc){
        String prevReim = System.now().addMonths(-1).format('MM-YYYY');
        List<Employee_Mileage__c> mils = [SELECT Id, Trip_Status__c, Variable__c, Trip_Date__c, Fuel_price__c, EmployeeReimbursement__r.Fuel_Price__c, EmployeeReimbursement__r.Name, EmployeeReimbursement__r.Contact_Id__r.Account.Name FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.Month__c =: prevReim AND Rejected__c = False AND Approved_Date__c = null AND (Fuel_price__c = 0 OR Fuel_price__c = null) AND (NOT EmployeeReimbursement__r.Contact_Id__r.Account.Name IN ('GPS (General Production Service)','Flat Water Homes','Test Accounts','Acme Corporation','Sidney Electric')) AND (NOT EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c LIKE '%Mileage Rate%')];
        return mils;
    }

    public void execute(Database.BatchableContext bc, List<Employee_Mileage__c> mils) {
        List<Employee_Mileage__c> updtMils = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c mil : mils) {
            mil.Fuel_price__c = mil.EmployeeReimbursement__r.Fuel_Price__c;
            updtMils.add(mil);
        }

        if(updtMils.size() > 0){
            update updtMils;
        }
    }

    public void finish(Database.BatchableContext bc){}

}