/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This class is used for create compliance report for PL marketing account.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 30 Decmber 2021 | Sanket Goswami
 * @description: 
 */
public with sharing class ComplianceReportPLM {
    public Date currentdate {get;set;}

    public Double TotalActualReimbursements {get;set;}
    public Double MaximumAllowable{get;set;}
    public Double AnnualTaxLiability{get;set;}
    public Decimal totalmileages  {get;set;}
    String accountId;
    Date payperiodStart;
    Date payperiodEnd;
    public List<wrapperTaxReport> obj_wrapperTaxReport {get;set;}
    public List<String> listofmonths {get;set;}

    public List<IRS_Mileage_Rate__c> irsrate {get;set;}
    public Map<String,Contact> obj_contact_map{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public ComplianceReportPLM() {
        accountId = ApexPages.currentPage().getParameters().get('accId');
        TaxLiablityPL__c customSetting = TaxLiablityPL__c.getInstance('DefaulDates');
        payperiodStart = customSetting.Start_Date__c;
        payperiodEnd = customSetting.End_Date__c;
        obj_wrapperTaxReport = new List<wrapperTaxReport>();
        irsrate = new List<IRS_Mileage_Rate__c>();
        obj_contact_map = new Map<String,Contact>();

        irsrate = [select id,year__c,IRS_Rate__c from IRS_Mileage_Rate__c where year__c =: customSetting.IRS_Year__c];
        getComplianceContacts();
    }
    public void getComplianceContacts()
    {
         system.debug('insert into getComplianceContacts');
        List<ID> obj_list_id = new List<ID>();
        for(Contact con : [SELECT id, Employee_ID__c,Name,
                                    External_Email__c,Division__c,
                                    Added_Date__c,Insurance__c,compliancestatus__c,
                                    Expiration_Date__c,Vehicle_Value_Check__c, 
                                    Vehicle_Age__c, Total_BiWeek_Mileage__c,
                                    No_of_Bi_Weekly_Reim_for_current_year__c,
                                    Compliance_Need_Mileage__c  
                            FROM Contact 
                            WHERE (compliancestatus__c != 'Yes')
                                AND Deactivated_Date__c = null 
                                AND AccountId =: accountId 
                                AND (Role__c =: StaticValues.roleAdminDriver 
                                        OR Role__c='Driver' 
                                        OR Role__c='Driver/Manager')]) {
            obj_list_id.add(con.id);
            if(!obj_contact_map.containsKey(con.id)) {
                obj_contact_map.put(con.id,con);    
            }
        }
        system.debug('payperiodStart=='+ payperiodStart);
        system.debug('payperiodEnd=='+ payperiodEnd);
        Map<String,List<Bi_Weekly_Reimbursement__c>> obj_map_Employee_Reimbursement = new Map<String,List<Bi_Weekly_Reimbursement__c>>();
        for(Bi_Weekly_Reimbursement__c biweekreim : [SELECT id,Total_Mileage__c,Total_Monthly_Reimbursement__c, 
                                                        Contact__c, Contact__r.Name, Contact__r.Employee_ID__c,
                                                        Contact__r.External_Email__c,Start_Date__c, End_Date__c,
                                                        Approved_Date__c,Half_Fixed_Amount__c  
                                                    FROM Bi_Weekly_Reimbursement__c 
                                                    WHERE Contact__c =: obj_list_id
                                                    AND Start_Date__c >=: payperiodStart
                                                    AND End_Date__c <=: payperiodEnd
                                                    AND Approved_Date__c != null 
                                                    AND Status__c ='Approved']){
            if(obj_map_Employee_Reimbursement.containsKey(biweekreim.Contact__c)) {
                obj_map_Employee_Reimbursement.get(biweekreim.Contact__c).add(biweekreim);
            } else {
                obj_map_Employee_Reimbursement.put(biweekreim.Contact__c, new List<Bi_Weekly_Reimbursement__c> {biweekreim});
            }
        }
        if(obj_map_Employee_Reimbursement.size() > 0) {
            obj_wrapperTaxReport = complianceStatus(obj_map_Employee_Reimbursement);
        }
    }
    public List<wrapperTaxReport> complianceStatus(Map<String,List<Bi_Weekly_Reimbursement__c>> obj_map_Employee_Reimbursement)
    {
        List<wrapperTaxReport> obj_ListwrapperTaxReport = new List<wrapperTaxReport>();
        for(String s : obj_map_Employee_Reimbursement.keySet()) {
            if(obj_map_Employee_Reimbursement.get(s).size() > 0) {
                totalmileages = 0;
                TotalActualReimbursements = 0;
                MaximumAllowable = 0;
                AnnualTaxLiability = 0;

                for(Bi_Weekly_Reimbursement__c obj : obj_map_Employee_Reimbursement.get(s)) {                       
                    if(obj.Total_Mileage__c != null) {
                        totalmileages = totalmileages +  obj.Total_Mileage__c.setScale(2);
                    }
                    
                    if(obj.Total_Monthly_Reimbursement__c != null) {
                        TotalActualReimbursements = TotalActualReimbursements + obj.Total_Monthly_Reimbursement__c.setScale(2);
                    }
                    
                    if(obj.Total_Mileage__c != null) {
                        MaximumAllowable = MaximumAllowable + ((obj.Total_Mileage__c.setScale(2))*(irsrate[0].IRS_Rate__c));
                    }                      
                    if((obj.Total_Monthly_Reimbursement__c != null)&&(obj.Total_Mileage__c != null)) {
                        AnnualTaxLiability = AnnualTaxLiability + ((obj.Total_Monthly_Reimbursement__c.setScale(2))-((obj.Total_Mileage__c.setScale(2))*irsrate[0].IRS_Rate__c));
                    } 
                    System.Debug(AnnualTaxLiability);   
                }
                
                if(obj_contact_map.containsKey(s)) {
                    wrapperTaxReport objw = new wrapperTaxReport();
                    objw.employeeid = obj_contact_map.get(s).Employee_ID__c;
                    objw.drivername = obj_contact_map.get(s).Name;                    
                    objw.emailid = obj_contact_map.get(s).External_Email__c;
                    objw.divison = String.valueOf(obj_contact_map.get(s).Division__c);
                    objw.addedDate = String.valueOf(obj_contact_map.get(s).Added_Date__c);
                    objw.insurance = obj_contact_map.get(s).Insurance__c;
                    objw.complianceStatus = obj_contact_map.get(s).compliancestatus__c;
                    objw.expirationDate = String.valueOf(obj_contact_map.get(s).Expiration_Date__c);
                    objw.vehicleValue = obj_contact_map.get(s).Vehicle_Value_Check__c;
                    objw.vehicleAge = obj_contact_map.get(s).Vehicle_Age__c;
                    objw.noOfBiweek = String.valueOf(obj_contact_map.get(s).No_of_Bi_Weekly_Reim_for_current_year__c);
                    objw.approvedmileages = totalmileages.setScale(2);
                    objw.complianceMileage = obj_contact_map.get(s).Compliance_Need_Mileage__c;
                    objw.totalreim = Decimal.valueOf(TotalActualReimbursements).setScale(2);
                    objw.iRSallowable = Decimal.valueOf(MaximumAllowable).setScale(2);
                    objw.imputedincome = Decimal.valueOf(AnnualTaxLiability).setScale(2);
                    obj_ListwrapperTaxReport.add(objw);
                }
            }    
        }
        return obj_ListwrapperTaxReport;
    }
    public class wrapperTaxReport
    {
        public String employeeid {get;set;}
        public String drivername {get;set;}
        public String emailid {get;set;}
        public String divison {get;set;}
        public String addedDate {get;set;}
        public String insurance {get;set;}
        public String complianceStatus {get;set;}
        public String expirationDate {get;set;}
        public String vehicleValue {get;set;}
        public String vehicleAge {get;set;}        
        public String noOfBiweek {get;set;}
        public Double approvedmileages {get;set;}
        public Double complianceMileage {get;set;}
        public Double totalreim {get;set;}
        public Double iRSallowable {get;set;}
        public Double imputedincome {get;set;}
        public wrapperTaxReport() { }
    }
}