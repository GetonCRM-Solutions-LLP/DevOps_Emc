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
    //public string currentYear {get; set;}
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
        //System.debug('empReimMonthsList ==> '+empReimMonthsList);
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
        //System.debug('inside annual tax method ');
        
        String strAccountId = currentPageAccountId;
        Account objAccount;
        List<String> monthList = getReimbursementMonths(currentYear);
        taxLiabilityWrapperLst = new List<TaxLiabilityWrapper>();
        Map<String, Double> mapOfReimTax = new Map<String, Double>();

        if (Test.isRunningTest()) {
            currentYear = String.valueOf(System.today().year());
            objAccount = [SELECT Id, Name 
                            FROM Account
                            WITH SECURITY_ENFORCED
                            LIMIT 1];
            strAccountId = objAccount.Id;
        } else if (strAccountId != null) {
            objAccount = [SELECT Id, Name 
                            FROM Account 
                            WHERE Id = :strAccountId 
                            WITH SECURITY_ENFORCED
                            LIMIT 1];
        }
        System.debug('strAccountId-----'+strAccountId);
        System.debug('objAccount-----'+objAccount);
        // Exit if account is not found
        if (objAccount == null) {
            // System.debug('Inside objAccount == null')
            return;
        }

        accName = objAccount.Name;
        preYear = String.valueOf(Integer.valueOf(currentYear) - 1);
        DateTime startDateOfReport = DateTime.newInstance(Integer.valueOf(preYear), 12, 1, 0, 0, 0);

        System.debug('currentYear -->' + currentYear);
        System.debug('Previous Year -->' + preYear);
        System.debug('Month -->' + monthList);

        List<Employee_Reimbursement__c> lstEmpReim = [SELECT Name, Imputed_Amount_for_Year__c 
                                                                FROM Employee_Reimbursement__c 
                                                                WHERE Contact_Id__r.AccountId = :strAccountId
                                                                    AND Month__c IN :monthList
                                                                    AND Contact_Id__r.Account.isUsingTriplog__c = true
                                                                    AND (Contact_Id__r.Deactivated_Date__c = null OR Contact_Id__r.Deactivated_Date__c > :startDateOfReport)
                                                                    AND Contact_Id__r.Role__c NOT IN ('Admin', 'Manager')
                                                                    WITH SECURITY_ENFORCED];

        // Map the reimbursement data to the respective months
        for (Employee_Reimbursement__c empReim : lstEmpReim) {
            mapOfReimTax.put(empReim.Name, empReim.Imputed_Amount_for_Year__c);
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
            //System.debug('===>>>'+objContact.Name);
            
            // if(objContact.Activation_Date__c==null){
            //     continue;
            // }
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
                
                taxliabilityrecord.December = Date.newInstance(Integer.ValueOf(currentYear), 12, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey
                (nameDec) ? String.valueOf(mapOfReimTax.get(nameDec)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 12, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameDec) ? mapOfReimTax.get(nameDec) : 0;

            }else{
                
                taxliabilityrecord.December = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 1, 1)){
                
                taxliabilityrecord.January = Date.newInstance(Integer.ValueOf(currentYear), 1, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey
                (nameJan) ? String.valueOf(mapOfReimTax.get(nameJan)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 1, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameJan) ? mapOfReimTax.get(nameJan) : 0;

            }else{
                
                taxliabilityrecord.January = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 2, 1)){
                
                taxliabilityrecord.February = Date.newInstance(Integer.ValueOf(currentYear), 2, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey
                (nameFeb) ? String.valueOf(mapOfReimTax.get(nameFeb)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 2, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameFeb) ? mapOfReimTax.get(nameFeb) : 0;

            }else{
                
                taxliabilityrecord.February = ' ';

            }

            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 3, 1)){
                
                taxliabilityrecord.March = Date.newInstance(Integer.ValueOf(currentYear), 3, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey(nameMar) ? 
                String.valueOf(mapOfReimTax.get(nameMar)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 3, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameMar) ? mapOfReimTax.get(nameMar) : 0;

            }else{
                
                taxliabilityrecord.March = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 4, 1)){
                
                taxliabilityrecord.April = Date.newInstance(Integer.ValueOf(currentYear), 4, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey(nameApr) ? 
                String.valueOf(mapOfReimTax.get(nameApr)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 4, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameApr) ? mapOfReimTax.get(nameApr) : 0;

            }else{
                
                taxliabilityrecord.April = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 5, 1)){
                
                taxliabilityrecord.May = Date.newInstance(Integer.ValueOf(currentYear), 5, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey(nameMay) ? 
                String.valueOf(mapOfReimTax.get(nameMay)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 5, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameMay) ? mapOfReimTax.get(nameMay) : 0;

            }else{
                
                taxliabilityrecord.May = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 6, 1)){
                
                taxliabilityrecord.June = Date.newInstance(Integer.ValueOf(currentYear), 6, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey(nameJun) ? 
                String.valueOf(mapOfReimTax.get(nameJun)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 6, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameJun) ? mapOfReimTax.get(nameJun) : 0;

            }else{
                
                taxliabilityrecord.June = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 7, 1)){
                
                taxliabilityrecord.July = Date.newInstance(Integer.ValueOf(currentYear), 7, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey(nameJul) ? 
                String.valueOf(mapOfReimTax.get(nameJul)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 7, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameJul) ? mapOfReimTax.get(nameJul) : 0;

            }else{
                
                taxliabilityrecord.July = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 8, 1)){
                
                taxliabilityrecord.August = Date.newInstance(Integer.ValueOf(currentYear), 8, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey
                (nameAug) ? String.valueOf(mapOfReimTax.get(nameAug)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 8, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameAug) ? mapOfReimTax.get(nameAug) : 0;

            }else{
                
                taxliabilityrecord.August = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 9, 1)){
                
                taxliabilityrecord.September = Date.newInstance(Integer.ValueOf(currentYear), 9, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey
                (nameSept) ? String.valueOf(mapOfReimTax.get(nameSept)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 9, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameSept) ? mapOfReimTax.get(nameSept) : 0;

            }else{
                
                taxliabilityrecord.September = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 10, 1)){
                
                taxliabilityrecord.October = Date.newInstance(Integer.ValueOf(currentYear), 10, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey
                (nameOct) ? String.valueOf(mapOfReimTax.get(nameOct)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 10, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameOct) ? mapOfReimTax.get(nameOct) : 0;

            }else{
                
                taxliabilityrecord.October = ' ';

            }


            if(objContact.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 11, 1)){
                
                taxliabilityrecord.November = Date.newInstance(Integer.ValueOf(currentYear), 11, 1) == System.today().toStartOfMonth() ? '0' : mapOfReimTax.containsKey
                (nameNov) ? String.valueOf(mapOfReimTax.get(nameNov)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 11, 1) == System.today().toStartOfMonth() ? 0 : mapOfReimTax.containsKey(nameNov) ? mapOfReimTax.get(nameNov) : 0;

            }else{
                
                taxliabilityrecord.November = ' ';

            }
            
            taxliabilityrecord.TotalAnnualTax = taxtotal > 0 ? taxtotal:0;
            taxLiabilityWrapperLst.add(taxliabilityrecord);
        }
        //preYear = 'Dec-'+preYear.substring(2, 4);
        System.debug('tax liability data '+taxLiabilityWrapperLst);
        
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