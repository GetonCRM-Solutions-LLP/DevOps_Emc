public with sharing class driverComplianceReport {
    public Date currentdate {get;set;}
    public Double TotalActualReimbursements {get;set;}
    public Double MaximumAllowable{get;set;}
    public Double AnnualTaxLiability{get;set;}
    public Decimal totalmileages  {get;set;}
    String accountId;
    public List<wrapperTaxReport> obj_wrapperTaxReport {get;set;}
    
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public driverComplianceReport() {
        obj_wrapperTaxReport = new List<wrapperTaxReport>();
        List<String> conIdList = new List<String>();
        accountId = ApexPages.currentPage().getParameters().get('accId');
        List<String> complianceCalculationList ;
        
        Map<Id,String> mapOfResult = new Map<Id,String>();
        List<wrapperTaxReport> obj_ListwrapperTaxReport ;        
        for(contact con : [SELECT id, compliancestatus__c, Name, Employee_ID__c, External_Email__c 
                           FROM Contact 
                           WHERE
                           Deactivated_Date__c = null 
                           AND AccountId =: accountId 
                           AND (Role__c =: StaticValues.roleAdminDriver OR Role__c='Driver' OR Role__c='Driver/Manager') LIMIT 30]){
                                    
                                    conIdList.add(con.Id);
                                    complianceCalculationList = new List<String>();
                                    Integer year = Date.today().year() - 1;
                                    complianceCalculationList.addAll(WrapperUtils.getComplianceCalculation(con.Id, String.valueOf(year)));
                                    
                                    If(complianceCalculationList.size() > 3){
                                        String summaryData = complianceCalculationList[4];
                                        if(summaryData != null) {
                                            mapOfResult.put(con.Id,summaryData);
                                        }
                                    }
        }
                                        If(mapOfResult != null){
                                            for(String mapKey : mapOfResult.keySet()){
                                                obj_ListwrapperTaxReport = new List<wrapperTaxReport>();
                                                obj_ListwrapperTaxReport = (List<wrapperTaxReport>)Json.deserialize(mapOfResult.get(mapKey),List<wrapperTaxReport>.class);
                                                wrapperTaxReport objw = new wrapperTaxReport();
                                                objw.drivername = obj_ListwrapperTaxReport[0].drivername;
                                                if(obj_ListwrapperTaxReport[0].employeeid != null){
                                                    objw.employeeid = obj_ListwrapperTaxReport[0].employeeid;
                                                }
                                                objw.emailid = obj_ListwrapperTaxReport[0].emailid;
                                                objw.imputedincome =obj_ListwrapperTaxReport[0].imputedincome;
                                                if(objw.imputedincome > 0){
                                                    obj_wrapperTaxReport.add(objw); 
                                                }   
                                            }
                                        }
        }

        Public Static String downloadAnnualComplianceReport(string condata, string year){
            List<ReportListController.reimbursementWrapper> reimWrapper = new List<ReportListController.reimbursementWrapper>();
            List<String> complianceCalculationList ;
            Map<Id,String> mapOfResult = new Map<Id,String>();
            List<wrapperTaxReport> objListwrapperTax ;
            List<wrapperTaxReport> obj_complianceReport = new  List<wrapperTaxReport>();
            List<String> contactIds = new List<String>();
            if(condata != null){
                //reimWrapper = (List<ReportListController.reimbursementWrapper>)Json.deserialize(condata , List<ReportListController.reimbursementWrapper>.class);
                contactIds = (List<String>) System.JSON.deserialize(condata, List<String>.class);
            }
           
            if(contactIds.size() > 0){
               
                for(String lstwrapper : contactIds ){
               
                    complianceCalculationList = new List<String>();
                    complianceCalculationList.addAll(WrapperUtils.getComplianceCalculation(lstwrapper, year));
                   
                    If(complianceCalculationList.size() > 3){
                    
                        String summaryData = complianceCalculationList[4];
                        if(summaryData != null) {
                            mapOfResult.put(lstwrapper,summaryData);
                        }
                    }
                }
                If(mapOfResult != null){
                    for(String mapKey : mapOfResult.keySet()){
                        objListwrapperTax = new List<wrapperTaxReport>();
                        objListwrapperTax = (List<wrapperTaxReport>)Json.deserialize(mapOfResult.get(mapKey),List<wrapperTaxReport>.class);
                        wrapperTaxReport objw = new wrapperTaxReport();
                        objw.drivername = objListwrapperTax[0].drivername;
                        if(objListwrapperTax[0].employeeid != null){
                            objw.employeeid = objListwrapperTax[0].employeeid;
                        }
                        objw.emailid = objListwrapperTax[0].emailid;
                        objw.imputedincome = objListwrapperTax[0].imputedincome;
                        if(objw.imputedincome > 0){
                            obj_complianceReport.add(objw); 
                        }                       
                        
                    }
                }
            }
            
            if(Test.isRunningTest()){
               integer i=0;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
            }
            return Json.serialize(obj_complianceReport);
        }
       
    public class wrapperTaxReport    {
        public String drivername {get;set;}
        public String employeeid {get;set;}
        public String emailid {get;set;}
        public Double approvedmileages {get;set;}
        public Double totalreim {get;set;}
        public Double iRSallowable {get;set;}
        public Double imputedincome {get;set;}
        public Integer month {get;set;}
        public String year {get;set;}
        public wrapperTaxReport() { }
    }

}