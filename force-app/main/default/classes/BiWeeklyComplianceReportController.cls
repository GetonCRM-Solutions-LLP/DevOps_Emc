public with sharing class BiWeeklyComplianceReportController {
    
    public double totalImputedIncome {get; set;}
    public List<ReibursementWrapper> BiweeklyComplianceWrapperList{get;set;}
    public Integer slot = 0;
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public BiWeeklyComplianceReportController() {
        BiweeklyComplianceWrapperList = new List<ReibursementWrapper>();
        ReibursementWrapper wrapperObj = new ReibursementWrapper();
        List<String> startEnddate = new List<String>();
        String contactid = ApexPages.currentPage().getParameters().get('id');
        List<String> dateRange = new List<String>();
        dateRange = BiweeklyPayPeriod.getPayPeriodDates (contactid,System.today().year());
        if(!dateRange.isEmpty())
        {
            Integer i = 0;    
            for(String s : dateRange)
            {
                String startdate2;
                String enddate2;
                if(s.contains('to'))
                {
                    startEnddate = s.split('to');
                    startdate2 = startEnddate[0];
                    enddate2 = startEnddate[1];
                    Date d1 = Date.today();
                    Date d2 = date.valueof(startdate2);
                    if(d2 < d1){
                        wrapperObj = calculateBiweekMil(startdate2,enddate2,contactid);
                        BiweeklyComplianceWrapperList.add(wrapperObj);
                    }
                }   
            }
        }

    }

    public static ReibursementWrapper calculateBiweekMil (String startdates,String enddates,String contactid){
        Map<Id,Decimal> mileageMap = new Map<Id,Decimal>();
        Map<Id,Decimal> variableMap = new Map<Id,Decimal>();
        Date startdate = date.valueof(startdates);
        Date enddate = date.valueof(enddates);
        String reimStartMonth,reimEndMonth;
        if(startdate.month() < 10 ) {
           reimStartMonth = '0'+String.valueOf(startdate.month())+'-'+startdate.year();
        } else {
            reimStartMonth = String.valueOf(startdate.month())+'-'+startdate.year();
        }
        if(enddate.month() < 10 ) {
           reimEndMonth = '0'+String.valueOf(enddate.month())+'-'+enddate.year();
        } else {
            reimEndMonth = String.valueOf(enddate.month())+'-'+enddate.year();
        }
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c cid,
                                     SUM(Variable__c) vtotal,SUM(Mileage__c) rtotal
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: contactid 
                                    AND Trip_Date__c >= : Date.valueOf(startdates)
                                    AND Trip_Date__c <= : Date.valueOf(enddates) 
                                    AND Trip_Status__c = 'Approved' 
                                    AND Approved_Date__c != null group by EmployeeReimbursement__r.Contact_Id__c ]) {
                                        variableMap.put((Id)ar.get('cid'),(Decimal)ar.get('vtotal'));  
                                        mileageMap.put((Id)ar.get('cid'),(Decimal)ar.get('rtotal'));                     
        } 
        //system.debug('reimStartMonth :: '+reimStartMonth + ':: reimEndMonth ::'+reimEndMonth);
        List<Employee_Reimbursement__c> reimList = new List<Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c reim : [SELECT id,Half_Fixed_Amount__c,Fuel_Price__c,
                                                    IRS_Mileage_Rate__r.IRS_Rate__c 
                                                FROM Employee_Reimbursement__c 
                                                WHERE (Month__c =: reimStartMonth OR Month__c =: reimEndMonth)
                                                AND Contact_Id__c =: contactid LIMIT 100]){
            reimList.add(reim);
        }
        //System.debug('**reimList**'+reimList);
        ReibursementWrapper wrapperObj = new ReibursementWrapper();
        //System.debug('**startdates**'+startdates+'**enddates**'+enddates);
        wrapperObj.StartDate = startdates.trim();
        wrapperObj.EndDate = enddates.trim();
        if(reimList.size() > 0 ){      
            wrapperObj.GasPrices = reimList[0].Fuel_Price__c;
            wrapperObj.FixedTotal = reimList[0].Half_Fixed_Amount__c;
            if(variableMap.containskey(contactid)){
                wrapperObj.VariableRate = variableMap.get(contactid);
            } else {
                wrapperObj.VariableRate = 0;
            }
            wrapperObj.TotalReimbursement = wrapperObj.FixedTotal + wrapperObj.VariableRate;
            if(mileageMap.containskey(contactid)){
                wrapperObj.Mileage = mileageMap.get(contactid);
            } else {
                wrapperObj.Mileage = 0;
            }
            if(reimList[0].IRS_Mileage_Rate__r.IRS_Rate__c != null){
                wrapperObj.IRSRate = reimList[0].IRS_Mileage_Rate__r.IRS_Rate__c;
            } else {
                wrapperObj.IRSRate = 0;
            }
            
            wrapperObj.MaxAllowable = (wrapperObj.Mileage * wrapperObj.IRSRate).setScale(2);
            wrapperObj.ImputedIncome = (wrapperObj.TotalReimbursement - wrapperObj.MaxAllowable).setScale(2);

            /*if(totalImputedIncome > 0 ){
                totalImputedIncome = totalImputedIncome + wrapperObj.ImputedIncome;
            } else {
                totalImputedIncome = wrapperObj.ImputedIncome;
            }*/
        }
        //System.debug('**contactid**'+contactid);
        //System.debug('**wrapperObj**'+wrapperObj);
        return wrapperObj;
    }

    public class ReibursementWrapper{
        public String StartDate { get; set; }
        public String EndDate { get; set; }
        public Decimal GasPrices { get; set; }
        public Decimal FixedTotal { get; set; }
        public Decimal VariableRate { get; set; }
        public Decimal TotalReimbursement { get; set; }
        public Decimal Mileage { get; set; }
        public Decimal IRSRate {get; set;} 
        public Decimal MaxAllowable {get; set;} 
        public Decimal ImputedIncome {get; set;} 
        public ReibursementWrapper(){
        }
    }
}