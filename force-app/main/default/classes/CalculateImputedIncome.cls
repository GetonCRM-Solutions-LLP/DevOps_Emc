public class CalculateImputedIncome {    
    public static void getImputedIncome(List<String> contactIdList,String year) {
        List<Contact> contactList = new List<Contact>();
        Map<String,Decimal> imputedAmountMap = new Map<String,Decimal>();
        Map<String,Decimal> approveMieageMap = new Map<String,Decimal>();
        Map<String,Decimal> totalReimburseMap = new Map<String,Decimal>();
        Map<String,Decimal> maxIrsAllowMap = new Map<String,Decimal>();
        List<String> monthList = new List<String>();
        if(String.isNotBlank(year)) {
            monthList = getReimbursementMonths(year);            
        } 
        
        if(contactIdList.size()>0 && monthList.size() > 0) {
            for(Employee_Reimbursement__c currentReimbursement : [Select id,Imputed_Amount_for_Year__c,Month__c,Contact_Id__c,Total_Approved__c,Contact_Id__r.Imputed_Amount__c,Total_Monthly_Reimbursement__c,Max_IRS_Allowable__c From Employee_Reimbursement__c Where Contact_Id__c In: contactIdList and Month__c In: monthList and Approved_Date__c != null Order By Contact_Id__c Limit 10000])
            {               
                if(!imputedAmountMap.containsKey(currentReimbursement.Contact_Id__c)) {
                    imputedAmountMap.put(currentReimbursement.Contact_Id__c,currentReimbursement.Imputed_Amount_for_Year__c);
                    approveMieageMap.put(currentReimbursement.Contact_Id__c,currentReimbursement.Total_Approved__c);                    
                    totalReimburseMap.put(currentReimbursement.Contact_Id__c,currentReimbursement.Total_Monthly_Reimbursement__c);
                    maxIrsAllowMap.put(currentReimbursement.Contact_Id__c,currentReimbursement.Max_IRS_Allowable__c);                    
                } else  {
                    Decimal imputedAmount = imputedAmountMap.get(currentReimbursement.Contact_Id__c);
                    imputedAmountMap.put(currentReimbursement.Contact_Id__c,imputedAmount + currentReimbursement.Imputed_Amount_for_Year__c);                    
                    imputedAmount = 0;
                    imputedAmount = approveMieageMap.get(currentReimbursement.Contact_Id__c);
                    approveMieageMap.put(currentReimbursement.Contact_Id__c,imputedAmount + currentReimbursement.Total_Approved__c);                    
                    imputedAmount = 0;
                    imputedAmount = totalReimburseMap.get(currentReimbursement.Contact_Id__c);
                    totalReimburseMap.put(currentReimbursement.Contact_Id__c,imputedAmount + currentReimbursement.Total_Monthly_Reimbursement__c);                    
                    imputedAmount = 0;
                    imputedAmount = maxIrsAllowMap.get(currentReimbursement.Contact_Id__c);
                    maxIrsAllowMap.put(currentReimbursement.Contact_Id__c,imputedAmount + currentReimbursement.Max_IRS_Allowable__c);                    
                }                
            }
            for(String currentContactId : imputedAmountMap.keySet()) {
                Contact currentContact =  new Contact();
                currentContact.id = currentContactId;
                if(imputedAmountMap.get(currentContactId) < 0 ){
                     currentContact.Imputed_Amount__c = 0;
                } else {
                     currentContact.Imputed_Amount__c = imputedAmountMap.get(currentContactId);
                }                
                currentContact.Tax_Calculation_Year__c = year;
                currentContact.Approve_Mileages__c = approveMieageMap.get(currentContactId);
                currentContact.Yearly_Total_Reimbursement__c = totalReimburseMap.get(currentContactId);
                currentContact.Max_IRS_Allowable__c = maxIrsAllowMap.get(currentContactId);
                contactList.add(currentContact);
            } 
            if(contactList.size() > 0) {               
                update contactList;
            }                        
        }
    }
    public static List<String> getReimbursementMonths(String passYear)
    {
        Integer month =11;
        List<String> empReimMonthsList = new List<String>();
        empReimMonthsList.add('12-'+String.valueOf(Integer.valueOf(passYear)-1));
        if(String.valueOf(System.Today().year()) == passYear  && System.Today().month() < 12) {
            month = System.Today().month();
        }
        for(integer currentmonth = 1; currentmonth <= month; currentmonth++) {
            if(currentmonth<10) {
                empReimMonthsList.add('0' + String.valueOf(currentmonth)+'-'+passYear);
            } else {
                empReimMonthsList.add(String.valueOf(currentmonth)+'-'+passYear);
            }            
        }
        return empReimMonthsList;
    }
}