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
    public AnnualTaxliabilityReport() {
        annualTax();
    }
    public List<TaxLiabilityWrapper> taxLiabilityWrapperLst{get;set;}
    public string accName {get; set;}
    public string currentYear {get; set;}
    public string preYear {get; set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public static List<String> getReimbursementMonths(String passYear)
    {
        Integer month =11;
        List<String> empReimMonthsList = new List<String>();
        empReimMonthsList.add('12-'+String.valueOf(Integer.valueOf(passYear)-1));
        for(integer currentmonth = 1; currentmonth <= month; currentmonth++) {
            if(currentmonth<10) {
                empReimMonthsList.add('0' + String.valueOf(currentmonth)+'-'+passYear);
            } else {
                empReimMonthsList.add(String.valueOf(currentmonth)+'-'+passYear);
            }
        }
        return empReimMonthsList;
    }
    public void annualTax(){
        System.debug('annual tax method ');
        
        String accid = ApexPages.currentPage().getParameters().get('accid');
        currentYear = ApexPages.currentPage().getParameters().get('Year');
        Account acc = new Account();
        if(Test.isRunningTest()){
            currentYear=String.valueOf(System.today().year());
            acc = [SELECT Id, Name FROM Account ];
            accid= acc.Id;
        }
        System.debug('Admin ID-->'+accid);
        if(accid != null) {
            acc = [SELECT Id, Name FROM Account WHERE Id =: accid];
        }
        accName = acc.Name;
        taxLiabilityWrapperLst = new List<TaxLiabilityWrapper>();
         
        preYear = String.valueOf(Integer.valueOf(currentYear)-1);

        List<string>monthlist=new list<string>();
        monthlist= getReimbursementMonths(currentYear);
        
        System.debug('currentYear-->'+currentYear);
        System.debug('Previous Year-->'+preYear);
        System.debug('Month -->'+monthlist);
        
        Map<String, Double> ReimbTax =New Map<String,Double>();
        // List<Employee_Reimbursement__c>  ReimLst = [select id,name,Imputed_Amount_for_Year__c,Month__c from Employee_Reimbursement__c Where Contact_Id__r.AccountId =:accid AND Month__c  IN :monthlist AND Contact_Id__r.Account.isUsingTriplog__c =true and (Contact_Id__r.Deactivated_Date__c =null OR Contact_Id_Deactivated_Date__c >:StartDateOfReport) AND Contact_Id__r.Role__c !='Admin' AND Contact_Id__r.Role__c !='Manager'  ];
        DateTime StartDateOfReport = DateTime.newInstance(Integer.valueOf(preYear), 12, 1, 0, 0, 0);
        for(Employee_Reimbursement__c empReim : [SELECT  id,name,Imputed_Amount_for_Year__c FROM Employee_Reimbursement__c WHERE Contact_Id__r.AccountId =:accid AND Month__c  IN :monthlist AND Contact_Id__r.Account.isUsingTriplog__c =true and (Contact_Id__r.Deactivated_Date__c =null OR Contact_Id_Deactivated_Date__c >:StartDateOfReport) AND Contact_Id__r.Role__c !='Admin' AND Contact_Id__r.Role__c !='Manager'  ]){
            ReimbTax.put(empReim.Name,empReim.Imputed_Amount_for_Year__c);
        }

        for(contact con:[select id,name,Email,Employee_ID__c,Activation_Date__c from Contact Where AccountId =:accid And Account.isUsingTriplog__c =true and (Deactivated_Date__c =null OR Deactivated_Date__c >:StartDateOfReport) ANd Role__c !='Admin' ANd Role__c !='Manager' Order By Email Asc  ]){
            if(con.Activation_Date__c==null){
                continue;
            }
            TaxLiabilityWrapper taxliabilityrecord =new TaxLiabilityWrapper();
            String nameDec=con.Name+':12-'+preYear;
            String nameJan=con.Name+':01-'+currentYear;
            String nameFeb=con.Name+':02-'+currentYear;
            String nameMar=con.Name+':03-'+currentYear;
            String nameApr=con.Name+':04-'+currentYear;
            String nameMay=con.Name+':05-'+currentYear;
            String nameJun=con.Name+':06-'+currentYear;
            String nameJul=con.Name+':07-'+currentYear;
            String nameAug=con.Name+':08-'+currentYear;
            String nameSept=con.Name+':09-'+currentYear;
            String nameOct=con.Name+':10-'+currentYear;
            String nameNov=con.Name+':11-'+currentYear;
            Decimal taxtotal = 0;
            
            taxliabilityrecord.Name=con.Name;
            taxliabilityrecord.Email=con.email;
            taxliabilityrecord.EmployeeID=con.Employee_ID__c;
            
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(preYear), 12, 1)){
                taxliabilityrecord.December = Date.newInstance(Integer.ValueOf(currentYear), 12, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameDec) ? String.valueOf(ReimbTax.get(nameDec)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 12, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameDec) ? ReimbTax.get(nameDec) : 0;
            }else{
                taxliabilityrecord.December = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 1, 1)){
                taxliabilityrecord.January = Date.newInstance(Integer.ValueOf(currentYear), 1, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameJan) ? String.valueOf(ReimbTax.get(nameJan)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 1, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameJan) ? ReimbTax.get(nameJan) : 0;
            }else{
                taxliabilityrecord.January = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 2, 1)){
                taxliabilityrecord.February = Date.newInstance(Integer.ValueOf(currentYear), 2, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameFeb) ? String.valueOf(ReimbTax.get(nameFeb)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 2, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameFeb) ? ReimbTax.get(nameFeb) : 0;
            }else{
                taxliabilityrecord.February = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 3, 1)){
                taxliabilityrecord.March = Date.newInstance(Integer.ValueOf(currentYear), 3, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameMar) ? String.valueOf(ReimbTax.get(nameMar)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 3, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameMar) ? ReimbTax.get(nameMar) : 0;
            }else{
                taxliabilityrecord.March = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 4, 1)){
                taxliabilityrecord.April = Date.newInstance(Integer.ValueOf(currentYear), 4, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameApr) ? String.valueOf(ReimbTax.get(nameApr)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 4, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameApr) ? ReimbTax.get(nameApr) : 0;
            }else{
                taxliabilityrecord.April = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 5, 1)){
                taxliabilityrecord.May = Date.newInstance(Integer.ValueOf(currentYear), 5, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameMay) ? String.valueOf(ReimbTax.get(nameMay)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 5, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameMay) ? ReimbTax.get(nameMay) : 0;
            }else{
                taxliabilityrecord.May = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 6, 1)){
                taxliabilityrecord.June = Date.newInstance(Integer.ValueOf(currentYear), 6, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameJun) ? String.valueOf(ReimbTax.get(nameJun)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 6, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameJun) ? ReimbTax.get(nameJun) : 0;
            }else{
                taxliabilityrecord.June = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 7, 1)){
                taxliabilityrecord.July = Date.newInstance(Integer.ValueOf(currentYear), 7, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameJul) ? String.valueOf(ReimbTax.get(nameJul)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 7, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameJul) ? ReimbTax.get(nameJul) : 0;
            }else{
                taxliabilityrecord.July = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 8, 1)){
                taxliabilityrecord.August = Date.newInstance(Integer.ValueOf(currentYear), 8, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameAug) ? String.valueOf(ReimbTax.get(nameAug)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 8, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameAug) ? ReimbTax.get(nameAug) : 0;
            }else{
                taxliabilityrecord.August = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 9, 1)){
                taxliabilityrecord.September = Date.newInstance(Integer.ValueOf(currentYear), 9, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameSept) ? String.valueOf(ReimbTax.get(nameSept)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 9, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameSept) ? ReimbTax.get(nameSept) : 0;
            }else{
                taxliabilityrecord.September = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 10, 1)){
                taxliabilityrecord.October = Date.newInstance(Integer.ValueOf(currentYear), 10, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameOct) ? String.valueOf(ReimbTax.get(nameOct)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 10, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameOct) ? ReimbTax.get(nameOct) : 0;
            }else{
                taxliabilityrecord.October = ' ';
            }
            if(con.Activation_Date__c.toStartOfMonth()<=Date.newInstance(Integer.ValueOf(currentYear), 11, 1)){
                taxliabilityrecord.November = Date.newInstance(Integer.ValueOf(currentYear), 11, 1) == System.today().toStartOfMonth() ? '0' : ReimbTax.containsKey(nameNov) ? String.valueOf(ReimbTax.get(nameNov)) : '0';

                taxtotal += Date.newInstance(Integer.ValueOf(currentYear), 11, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameNov) ? ReimbTax.get(nameNov) : 0;
            }else{
                taxliabilityrecord.November = ' ';
            }
            
            // taxtotal = Decimal.valueOf(taxliabilityrecord.December) +  Decimal.valueOf(taxliabilityrecord.January) + Decimal.valueOf(taxliabilityrecord.February) + Decimal.valueOf(taxliabilityrecord.March) + Decimal.valueOf(taxliabilityrecord.April) + Decimal.valueOf(taxliabilityrecord.May) + Decimal.valueOf(taxliabilityrecord.June) + Decimal.valueOf(taxliabilityrecord.July) + Decimal.valueOf(taxliabilityrecord.August) + Decimal.valueOf(taxliabilityrecord.September) + Decimal.valueOf(taxliabilityrecord.October) + Decimal.valueOf(taxliabilityrecord.November);

            //Working// taxtotal =(ReimbTax.containsKey(nameDec) ? ReimbTax.get(nameDec) : 0)+(ReimbTax.containsKey(nameJan) ? ReimbTax.get(nameJan) : 0)+( ReimbTax.containsKey(nameFeb) ? ReimbTax.get(nameFeb) : 0)+(ReimbTax.containsKey(nameMar) ? ReimbTax.get(nameMar) : 0)+(ReimbTax.containsKey(nameApr) ? ReimbTax.get(nameApr) : 0)+( ReimbTax.containsKey(nameMay) ? ReimbTax.get(nameMay) : 0)+(ReimbTax.containsKey(nameJun) ? ReimbTax.get(nameJun) : 0)+(ReimbTax.containsKey(nameJul) ? ReimbTax.get(nameJul) : 0)+(ReimbTax.containsKey(nameAug) ? ReimbTax.get(nameAug) : 0)+(ReimbTax.containsKey(nameSept) ? ReimbTax.get(nameSept) : 0)+(ReimbTax.containsKey(nameOct) ? ReimbTax.get(nameOct) : 0)+(ReimbTax.containsKey(nameNov) ? ReimbTax.get(nameNov) : 0);

            // taxtotal = (Date.newInstance(Integer.ValueOf(currentYear), 12, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameDec) ? ReimbTax.get(nameDec) : 0) + 
            // (Date.newInstance(Integer.ValueOf(currentYear), 1, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameJan) ? ReimbTax.get(nameJan) : 0)  +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 2, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameFeb) ? ReimbTax.get(nameFeb) : 0)  +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 3, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameMar) ? ReimbTax.get(nameMar) : 0)  +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 4, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameApr) ? ReimbTax.get(nameApr) : 0)  + 
            // (Date.newInstance(Integer.ValueOf(currentYear), 5, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameMay) ? ReimbTax.get(nameMay) : 0)  +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 6, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameJun) ? ReimbTax.get(nameJun) : 0)  + 
            // (Date.newInstance(Integer.ValueOf(currentYear), 7, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameJul) ? ReimbTax.get(nameJul) : 0) +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 8, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameAug) ? ReimbTax.get(nameAug) : 0) +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 9, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameSept) ? ReimbTax.get(nameSept) : 0) +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 10, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameOct) ? ReimbTax.get(nameOct) : 0) +  
            // (Date.newInstance(Integer.ValueOf(currentYear), 11, 1) == System.today().toStartOfMonth() ? 0 : ReimbTax.containsKey(nameNov) ? ReimbTax.get(nameNov) : 0);

            taxliabilityrecord.TotalAnnualTax = taxtotal > 0 ? taxtotal:0;
            taxLiabilityWrapperLst.add(taxliabilityrecord);
        }
        System.debug('tax liability data '+taxLiabilityWrapperLst);
        
    }
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