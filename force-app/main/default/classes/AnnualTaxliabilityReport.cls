/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This class is used to download excel file for Account.
 * @Modification logs
 * @Page name :- Annual tax liability report
 * ========================================================================================================================
 * @Date: 15 March 2024 | Khuman singh
 * @description:
 */
public with sharing class AnnualTaxliabilityReport {
    
    // Retrieves the current year from the page parameters.
    public static String currentYear 
    {
        get 
        {
            if(String.isBlank(currentYear))
            {
                currentYear = getParameterFromCurrentPage('Year');
            }
            return currentYear;
        } 
        private set; 
    }

    // Retrieves the current account ID from the page parameters
    public static Id currentPageAccountId 
    { 
        get     
        {
            if(String.isBlank(currentPageAccountId))
            {
                currentPageAccountId = getParameterFromCurrentPage('accid');
            }
            return currentPageAccountId;
        } 
        private set; 
    }

    /**
    * @description Helper method to retrieve a specific parameter from the current page's URL.
    * @author Vatsal Bhalani | 10-10-2024 
    * @param strParameterName 
    * @return String 
    **/
    private static String getParameterFromCurrentPage(String strParameterName)
    {
        if(ApexPages.currentPage().getParameters().containsKey(strParameterName) 
            && String.isNotBlank(ApexPages.currentPage().getParameters().get(strParameterName))) 
        {
            String paramValue = ApexPages.currentPage().getParameters().get(strParameterName);
            return paramValue.escapeHtml4();
        }

        return null;
    }
    
    /*
        * Constructor for AnnualTaxliabilityReport.
        * Calls the `annualTax` method to generate the tax liability report when an instance of the class is created.
    */
    public AnnualTaxliabilityReport() {
        annualTax();
    }
    public List<TaxLiabilityWrapper> taxLiabilityWrapperLst{get;set;}
    public string accName {get; set;}
    public string preYear {get; set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    /**
    * @description  * Retrieves the list of reimbursement months for a given year, starting from December of the previous year.
                    * This method generates a list of month-year combinations for the 12 months of the report period.
    * @author Vatsal Bhalani | 10-10-2024 
    * @param passYear 
    * @return List<String> 
    **/
    public static List<String> getReimbursementMonths(String passYear) {
        
        List<String> empReimMonthsList = new List<String>();
        empReimMonthsList.add('12-' + String.valueOf(Integer.valueOf(passYear) - 1));
        
        for (Integer currentMonth = 1; currentMonth <= 11; currentMonth++) {
            String monthStr = (currentMonth < 10 ? '0' : '') + String.valueOf(currentMonth);
            empReimMonthsList.add(monthStr + '-' + passYear);
        }
        return empReimMonthsList;
    }

    /**
    * @description 
        * Core method that calculates the annual tax liability report.
        * It fetches the relevant Employee Reimbursement and Contact data for the account,
        * and then maps the reimbursements to the respective months for each contact.
    * @author Vatsal Bhalani | 10-10-2024 
    **/
    public void annualTax(){
        
        String strAccountId = currentPageAccountId;
        Account objAccount;
        List<String> lstMonths = getReimbursementMonths(currentYear);
        taxLiabilityWrapperLst = new List<TaxLiabilityWrapper>();
        Map<String, Double> mapImputedAmtByReimName = new Map<String, Double>();

        if (strAccountId != null) {
            objAccount = [SELECT Id, Name 
                            FROM Account 
                            WHERE Id = :strAccountId 
                            WITH SECURITY_ENFORCED
                            LIMIT 1];
        }
        
        // Exit if account is not found
        if (objAccount == null) {
            return;
        }

        accName = objAccount.Name;
        preYear = String.valueOf(Integer.valueOf(currentYear) - 1);
        DateTime startDateOfReport = DateTime.newInstance(Integer.valueOf(preYear), 12, 1, 0, 0, 0);

        // Map the reimbursement data to the respective months
        for (Employee_Reimbursement__c empReim : [SELECT Name, Imputed_Amount_for_Year__c 
                                                                FROM Employee_Reimbursement__c 
                                                                WHERE Contact_Id__r.AccountId = :strAccountId
                                                                    AND Month__c IN :lstMonths
                                                                    AND Contact_Id__r.Account.isUsingTriplog__c = true
                                                                    AND (Contact_Id__r.Deactivated_Date__c = null OR Contact_Id__r.Deactivated_Date__c > :startDateOfReport)
                                                                    AND Contact_Id__r.Role__c NOT IN ('Admin', 'Manager')
                                                                    WITH SECURITY_ENFORCED]) {
            mapImputedAmtByReimName.put(empReim.Name, empReim.Imputed_Amount_for_Year__c);
        }
        
        for(contact objContact: [SELECT Name, Email, Employee_ID__c, Activation_Date__c
                            FROM Contact
                            WHERE AccountId = :strAccountId
                                AND Account.isUsingTriplog__c = true
                                AND (Deactivated_Date__c = null OR Deactivated_Date__c > :StartDateOfReport)
                                AND Role__c NOT IN ('Admin', 'Manager')
                                AND Activation_Date__c != null 
                                WITH SECURITY_ENFORCED
                                ORDER BY Email ASC
                                ]){

            TaxLiabilityWrapper taxliabilityrecord =new TaxLiabilityWrapper();
            String nameDec=objContact.Name+':12-'+preYear;
            String nameJan=objContact.Name+':01-'+currentYear;
            String nameFeb=objContact.Name+':02-'+currentYear;
            String nameMar=objContact.Name+':03-'+currentYear;
            String nameApr=objContact.Name+':04-'+currentYear;
            String nameMay=objContact.Name+':05-'+currentYear;
            String nameJun=objContact.Name+':06-'+currentYear;
            String nameJul=objContact.Name+':07-'+currentYear;
            String nameAug=objContact.Name+':08-'+currentYear;
            String nameSept=objContact.Name+':09-'+currentYear;
            String nameOct=objContact.Name+':10-'+currentYear;
            String nameNov=objContact.Name+':11-'+currentYear;
            Decimal taxtotal = 0;
            
            taxliabilityrecord.Name=objContact.Name;
            taxliabilityrecord.Email=objContact.email;
            taxliabilityrecord.EmployeeID=objContact.Employee_ID__c;
            

            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(preYear), 12, 1)){
                
                taxliabilityrecord.December = Date.newInstance(Integer.ValueOf(currentYear), 12, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey
                (nameDec) ? String.valueOf(mapImputedAmtByReimName.get(nameDec)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 12, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameDec) ? mapImputedAmtByReimName.get(nameDec) : 0;

            }else{
                
                taxliabilityrecord.December = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 1, 1)){
                
                taxliabilityrecord.January = Date.newInstance(Integer.ValueOf(currentYear), 1, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey
                (nameJan) ? String.valueOf(mapImputedAmtByReimName.get(nameJan)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 1, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameJan) ? mapImputedAmtByReimName.get(nameJan) : 0;

            }else{
                
                taxliabilityrecord.January = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 2, 1)){
                
                taxliabilityrecord.February = Date.newInstance(Integer.ValueOf(currentYear), 2, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey
                (nameFeb) ? String.valueOf(mapImputedAmtByReimName.get(nameFeb)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 2, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameFeb) ? mapImputedAmtByReimName.get(nameFeb) : 0;

            }else{
                
                taxliabilityrecord.February = null;

            }

            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 3, 1)){
                
                taxliabilityrecord.March = Date.newInstance(Integer.ValueOf(currentYear), 3, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey(nameMar) ? 
                String.valueOf(mapImputedAmtByReimName.get(nameMar)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 3, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameMar) ? mapImputedAmtByReimName.get(nameMar) : 0;

            }else{
                
                taxliabilityrecord.March = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 4, 1)){
                
                taxliabilityrecord.April = Date.newInstance(Integer.ValueOf(currentYear), 4, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey(nameApr) ? 
                String.valueOf(mapImputedAmtByReimName.get(nameApr)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 4, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameApr) ? mapImputedAmtByReimName.get(nameApr) : 0;

            }else{
                
                taxliabilityrecord.April = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 5, 1)){
                
                taxliabilityrecord.May = Date.newInstance(Integer.ValueOf(currentYear), 5, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey(nameMay) ? 
                String.valueOf(mapImputedAmtByReimName.get(nameMay)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 5, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameMay) ? mapImputedAmtByReimName.get(nameMay) : 0;

            }else{
                
                taxliabilityrecord.May = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 6, 1)){
                
                taxliabilityrecord.June = Date.newInstance(Integer.ValueOf(currentYear), 6, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey(nameJun) ? 
                String.valueOf(mapImputedAmtByReimName.get(nameJun)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 6, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameJun) ? mapImputedAmtByReimName.get(nameJun) : 0;

            }else{
                
                taxliabilityrecord.June = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 7, 1)){
                
                taxliabilityrecord.July = Date.newInstance(Integer.ValueOf(currentYear), 7, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey(nameJul) ? 
                String.valueOf(mapImputedAmtByReimName.get(nameJul)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 7, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameJul) ? mapImputedAmtByReimName.get(nameJul) : 0;

            }else{
                
                taxliabilityrecord.July = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 8, 1)){
                
                taxliabilityrecord.August = Date.newInstance(Integer.ValueOf(currentYear), 8, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey
                (nameAug) ? String.valueOf(mapImputedAmtByReimName.get(nameAug)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 8, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameAug) ? mapImputedAmtByReimName.get(nameAug) : 0;

            }else{
                
                taxliabilityrecord.August = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 9, 1)){
                
                taxliabilityrecord.September = Date.newInstance(Integer.ValueOf(currentYear), 9, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey
                (nameSept) ? String.valueOf(mapImputedAmtByReimName.get(nameSept)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 9, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameSept) ? mapImputedAmtByReimName.get(nameSept) : 0;

            }else{
                
                taxliabilityrecord.September = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 10, 1)){
                
                taxliabilityrecord.October = Date.newInstance(Integer.ValueOf(currentYear), 10, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey
                (nameOct) ? String.valueOf(mapImputedAmtByReimName.get(nameOct)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 10, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameOct) ? mapImputedAmtByReimName.get(nameOct) : 0;

            }else{
                
                taxliabilityrecord.October = null;

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 11, 1)){
                
                taxliabilityrecord.November = Date.newInstance(Integer.ValueOf(currentYear), 11, 1) == System.today().toStartOfMonth() ? '0' : mapImputedAmtByReimName.containsKey
                (nameNov) ? String.valueOf(mapImputedAmtByReimName.get(nameNov)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 11, 1) == System.today().toStartOfMonth() ? 0 : mapImputedAmtByReimName.containsKey(nameNov) ? mapImputedAmtByReimName.get(nameNov) : 0;

            }else{
                
                taxliabilityrecord.November = null;

            }
            
            taxliabilityrecord.TotalAnnualTax = taxtotal > 0 ? taxtotal:0;
            taxLiabilityWrapperLst.add(taxliabilityrecord);
        }
    }

    /*
     * Wrapper class to hold individual tax liability details for a contact.
     * Includes contact information, monthly imputed amounts, and the total annual tax.
     */
    public class TaxLiabilityWrapper{
        
        public string Name {get; set;}
        public string Email {get; set;}
        public string EmployeeID {get; set;}
        public String December { get; set; }
        public String January { get; set; }
        public String February { get; set; }
        public String March { get; set; }
        public String April { get; set; }
        public String May { get; set; }
        public String June { get; set; }
        public String July { get; set; }
        public String August { get; set; }
        public String September { get; set; }
        public String October { get; set; }
        public String November { get; set; }
        public Decimal TotalAnnualTax { get; set; }
    }
}