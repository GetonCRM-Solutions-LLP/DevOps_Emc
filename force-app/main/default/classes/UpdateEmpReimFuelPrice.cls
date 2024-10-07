/*
************************************************************************
Description : For that Month, update fuel price field based on gas price
************************************************************************
*/
global class UpdateEmpReimFuelPrice {
    webservice static Void updateFuelPrice(String reimMonth) {
        String month, year;
        Integer i  = 0;
        Date empReimMonth;
        List<Employee_Reimbursement__c> updateReimbersments = new List<Employee_Reimbursement__c>();
        Set<String> cityNames = new Set<String>();
        Set<String> stateNames = new Set<String>();
        Set<String> cityStateDate = new Set<String>();
        List<string> vehicleTypeList =  System.Label.Vehicle_Type.split(',');
        List<string> accountList= System.label.AccountWithoutFuelPrice.split(',');
        System.debug('fetched Account list'+accountList);
        Map<String, List<Employee_Reimbursement__c>> keyToReimbersment = new Map<String, List<Employee_Reimbursement__c> >();
        for(Employee_Reimbursement__c reimbers : [SELECT Id, Name, Month__c, City_State__c, Fixed_Amount__c,  Fuel_Price__c, Contact_Id__c, Contact_Id__r.Fixed_Amount__c, Contact_Id__r.MailingState,Contact_Id__r.MailingCity 
                                                  FROM  Employee_Reimbursement__c 
                                                  WHERE (fuel_price__c = null OR fuel_price__c = 0.0) 
                                                  AND contact_email__c != null AND Contact_Id__r.MailingState != null 
                                                  AND Contact_Id__r.MailingCity != null AND month__c =: reimMonth
                                                  AND Contact_id__r.Vehicle_Type__c !=: vehicleTypeList
                                                  AND (NOT Contact_id__r.Account.Name IN:accountList)])
                                                   {
            String city = reimbers.City_State__c.right(2);
            cityNames.add(reimbers.City_State__c.left(reimbers.City_State__c.length() - 3).trim());
            i++;
            stateNames.add(reimbers.City_State__c.right(2).trim());
            if(!String.isBlank(reimbers.Month__c)) {
                month = reimbers.Month__c.split('-')[0];
                year = reimbers.Month__c.split('-')[1];
            }
            date monthYear = date.parse(month + '/1/' + year);
            String tempStrDate = monthYear.format();
            String temp = reimbers.City_State__c.toLowerCase() + '-' + tempStrDate;
            if(!keyToReimbersment.containsKey(temp)) {
                keyToReimbersment.put(temp, new List<Employee_Reimbursement__c>{reimbers});
            } else {
                keyToReimbersment.get(temp).add(reimbers);
            }
        }
        empReimMonth = Date.valueof(year+'-'+month+'-01');
        for(Gas_Prices__c gasPrice : [SELECT City__c, State__c, Fuel_Price__c, Month_Year__c 
                                        FROM Gas_Prices__c WHERE City__c IN : cityNames AND 
                                        State__c IN : stateNames AND Month_Year__c =: empReimMonth]) {
                String tempStrDateGP = gasPrice.Month_Year__c.format();
            String key = gasPrice.City__c.trim().toLowerCase() + '-'+ gasPrice.State__c.trim().toLowerCase() + '-' + tempStrDateGP;
            if(keyToReimbersment.containsKey(key) && gasPrice.Fuel_Price__c != null) {
                for(Employee_Reimbursement__c er : keyToReimbersment.get(key)) {
                    er.Fuel_Price__c = gasPrice.Fuel_Price__c;
                    updateReimbersments.add(er);
                }
            }
        }
        if(!updateReimbersments.isEmpty()) {
            update updateReimbersments;
        }  
    }
}