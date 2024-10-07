//If having NULL or zero value, populates Fuel Price of all related Mileage records for an account.
//Accessed through 'Update Mileage Fuel Price' custom buttom in account.

global class PopulateFuelPriceonMileage {
    public static String result = 'SUCCESS!';
    webservice static String setFuelPrice(Id accountId) {
        List<Employee_Mileage__c> mileages = new List<Employee_Mileage__c>();
        Map<Id, Double> reimburseIdtoFuelPrice = new Map<Id, Double>();
        List<Contact> contacts = new List<Contact>([SELECT Id FROm Contact WHERE AccountId =: accountId]);
        for(Employee_Reimbursement__c reimburse : [SELECT Id, Fuel_Price__c, (SELECT Id, Fuel_Price__c, EmployeeReimbursement__c
            FROM Employees_Mileage__r) FROM Employee_Reimbursement__c WHERE Contact_Id__c IN : contacts]) {
            if(!reimburse.Employees_Mileage__r.isEmpty()) {
                mileages.addAll(reimburse.Employees_Mileage__r);
                if(reimburse.Fuel_Price__c != null || reimburse.Fuel_Price__c != 0) {
                    reimburseIdtoFuelPrice.put(reimburse.Id, reimburse.Fuel_Price__c);
                }
            }
        }
        
        for(Employee_Mileage__c mileage : mileages) {
            if(reimburseIdtoFuelPrice.containsKey(mileage.EmployeeReimbursement__c) && (mileage.Fuel_Price__c == NULL || mileage.Fuel_Price__c == 0)) {
                mileage.Fuel_Price__c = reimburseIdtoFuelPrice.get(mileage.EmployeeReimbursement__c);
            }
        }
        
        if(!mileages.isEmpty()) {
            try {
                update mileages;
            } catch(Exception e) {
                result = e.getMessage();
            }
        }
        return result;
    }
}