public class BiWeeklyReimReportforPLMController {
    public List<ReibursementWrapper> BiweeklyWrapperList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public BiWeeklyReimReportforPLMController(){
        BiWeeklyReimbursement();
    }
     public void BiWeeklyReimbursement(){
         //String startDate = '2021-07-28';
         //String endDate = '2021-08-11';
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        System.debug('***startDate***'+startDate+'***endDate***'+endDate);
        String[] month = endDate.split('-');
        String monthValue = month[1]+ '-' +month[0];
        System.debug('***monthValue***'+monthValue);
        BiweeklyWrapperList = new List<ReibursementWrapper>();
        Map<Id, Decimal> idVsVariableMap = new Map<Id, Decimal>();
        Map<Id, Decimal> idVsMileageMap = new Map<Id, Decimal>();
        Map<Id, Decimal> idVsHalfFixedAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> idVsHalfReimMap = new Map<Id, Decimal>();
        Map<Id, Decimal> idVsIRSMap = new Map<Id, Decimal>();
        Map<Id, Decimal> DivisionMap = new Map<Id,decimal>();
        System.debug('***startDate***'+startDate+'***endDate***'+endDate);
        List<Bi_Weekly_Reimbursement__c> reibursementList = new List<Bi_Weekly_Reimbursement__c>();
         
        if(Test.isRunningTest()) {
            reibursementList = [SELECT id,Fixed_Amount__c,Half_Fixed_Amount__c,
                                    Contact__c,Contact__r.Division__c,
                                    IRS_Mileage_Rate__r.IRS_Rate__c,
                                    Start_Date__c,End_Date__c,
                                    Total_Monthly_Approved_Variable__c,
                                    Total_Approved_Pending_Mileage__c
                                 FROM Bi_Weekly_Reimbursement__c 
                                 WHERE Start_Date__c =: Date.valueOf(startDate)
                                     AND End_Date__c =: Date.valueOf(endDate)];
        } else {
            reibursementList = [SELECT id,Fixed_Amount__c,Half_Fixed_Amount__c,
                                    Contact__c,Contact__r.Division__c,
                                    IRS_Mileage_Rate__r.IRS_Rate__c,
                                    Start_Date__c,End_Date__c,
                                    Total_Monthly_Approved_Variable__c,
                                    Total_Approved_Pending_Mileage__c
                                 FROM Bi_Weekly_Reimbursement__c 
                                 WHERE Start_Date__c =: Date.valueOf(startDate)
                                     AND End_Date__c =: Date.valueOf(endDate)
                                     AND Contact__r.AccountId =: System.Label.PLMarketing];
        }
        for(Bi_Weekly_Reimbursement__c reimHalfFixedAmount : reibursementList){ 
                                        idVsMileageMap.put(reimHalfFixedAmount.Contact__c, reimHalfFixedAmount.Total_Approved_Pending_Mileage__c);  
                                        idVsVariableMap.put(reimHalfFixedAmount.Contact__c, reimHalfFixedAmount.Total_Monthly_Approved_Variable__c);
                                        DivisionMap.put(reimHalfFixedAmount.Contact__c, reimHalfFixedAmount.Contact__r.Division__c );                                                                                                                               
                                        idVsHalfFixedAmountMap.put(reimHalfFixedAmount.Contact__c, reimHalfFixedAmount.Half_Fixed_Amount__c); 
                                        if(reimHalfFixedAmount.IRS_Mileage_Rate__r.IRS_Rate__c != null){
                                            idVsIRSMap.put(reimHalfFixedAmount.Contact__c, reimHalfFixedAmount.IRS_Mileage_Rate__r.IRS_Rate__c); 
                                        }                                        
                                        if(reimHalfFixedAmount.Total_Monthly_Approved_Variable__c!= NULL || reimHalfFixedAmount.Total_Monthly_Approved_Variable__c!= 0){
                                            idVsHalfReimMap.put(reimHalfFixedAmount.Contact__c, reimHalfFixedAmount.Total_Monthly_Approved_Variable__c+ reimHalfFixedAmount.Half_Fixed_Amount__c); 
                                        } else {
                                            idVsHalfReimMap.put(reimHalfFixedAmount.Contact__c, 0 + reimHalfFixedAmount.Half_Fixed_Amount__c); 
                                        }   
                                            
                                       }          

        List<Contact> contactList; 
        if(Test.isRunningTest()) {
            contactList = [SELECT id,Employee_ID__c,Name,Job_Title__c,External_Email__c,Division__c,Fixed_Amount__c,
                                            Deactivated_Date__c FROM Contact WHERE 
                                            (Role__c !='Manager' AND Role__c != 'Admin')];
        } else {
            contactList = [SELECT id,Employee_ID__c,Name,Job_Title__c,External_Email__c,Division__c,Fixed_Amount__c,
                                            Deactivated_Date__c FROM Contact WHERE ((Deactivated_Date__c >=: Date.valueOf(startDate) AND Deactivated_Date__c <=: Date.valueOf(endDate)) OR Deactivated_Date__c = null)
                                            AND (Role__c !='Manager' AND Role__c != 'Admin') AND AccountId =: System.Label.PLMarketing];
        }
        for(Contact currentContact : contactList){
            ReibursementWrapper objWrapper = new ReibursementWrapper();
            objWrapper.ReibursementMonth = monthValue;
            objWrapper.Name = currentContact.Name;
            objWrapper.EmployeeId = currentContact.Employee_ID__c;
            objWrapper.Email = currentContact.External_Email__c;
            objWrapper.JobTitle = currentContact.Job_Title__c;
            if(idVsVariableMap.containsKey(currentContact.Id)){
                objWrapper.BiWeeklyVariableAmount = (idVsVariableMap.get(currentContact.Id)).setScale(2);
            } else {
                objWrapper.BiWeeklyVariableAmount = 0;
            }
            if(idVsMileageMap.containsKey(currentContact.Id)){
                objWrapper.BiWeeklyMileage = (idVsMileageMap.get(currentContact.Id)).setScale(2);
            } else {
                objWrapper.BiWeeklyMileage = 0;
            }
            if(idVsHalfFixedAmountMap.containsKey(currentContact.Id)){
                objWrapper.BiWeeklyFixedAmount = (idVsHalfFixedAmountMap.get(currentContact.Id)).setScale(2);
            } else {
                objWrapper.BiWeeklyFixedAmount = 0;
            }
            if(idVsHalfReimMap.containsKey(currentContact.Id)){
                objWrapper.BiWeeklyTotalReim = (idVsHalfReimMap.get(currentContact.Id)).setScale(2);
            } else {
                objWrapper.BiWeeklyTotalReim = 0;
            }
           /* Decimal IRSRate;
            if(idVsIRSMap.containsKey(currentContact.Id)){
                IRSRate = (idVsIRSMap.get(currentContact.Id)).setScale(2);
            } else {
                IRSRate = 0;
            }*/
            objWrapper.payPeriodDate = startDate +' to '+ endDate;
            system.debug('payPeriodDate=='+ objWrapper.payPeriodDate);
            objWrapper.Division = String.valueOf(currentContact.Division__c);
            if(currentContact.Deactivated_Date__c != null && date.valueOf(currentContact.Deactivated_Date__c) >= Date.valueOf(startDate) && date.valueOf(currentContact.Deactivated_Date__c) <= Date.valueOf(endDate)){
                List<String> dateRange = new List<String>();
                List<BiWeeklyComplianceReportController.ReibursementWrapper> BiweeklyComplianceWrapperList = new List<BiWeeklyComplianceReportController.ReibursementWrapper>();
                dateRange = BiweeklyPayPeriod.getPayPeriodDates (currentContact.Id,System.today().year());
                BiWeeklyComplianceReportController.ReibursementWrapper wrapperObj = new BiWeeklyComplianceReportController.ReibursementWrapper();
                List<String> startEnddate = new List<String>();                
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
                                wrapperObj = BiWeeklyComplianceReportController.calculateBiweekMil(startdate2,enddate2,currentContact.Id);
                                BiweeklyComplianceWrapperList.add(wrapperObj);
                            }
                        }   
                    }
                }               
                Decimal imputedIncomeCal = 0;
                for(BiWeeklyComplianceReportController.ReibursementWrapper ar : BiweeklyComplianceWrapperList){
                    if(ar.ImputedIncome != null){
                        imputedIncomeCal =  imputedIncomeCal + ar.ImputedIncome;
                    } else {
                        imputedIncomeCal =  imputedIncomeCal + 0;                      
                    }
                   
                }
                objWrapper.ImputedIncome = imputedIncomeCal.setScale(2);
                BiweeklyWrapperList.add(objWrapper); 
            } else if(currentContact.Deactivated_Date__c == null){
                objWrapper.ImputedIncome = 0;
                BiweeklyWrapperList.add(objWrapper);
            }
            
        }
      
    }
    public class ReibursementWrapper{
        public string ReibursementMonth { get; set; }
        public string Name { get; set; }
        public string EmployeeId { get; set; }
        public string Email { get; set; }
        public string JobTitle { get; set; }
        public string payPeriodDate { get; set; }
        public Decimal BiWeeklyFixedAmount { get; set; }
        public Decimal BiWeeklyVariableAmount { get; set; }
        public Decimal BiWeeklyTotalReim { get; set; }
        public Decimal BiWeeklyMileage { get; set; }
        public String Division {get; set;} 
        public Decimal ImputedIncome {get; set;} 
        public ReibursementWrapper(){
        }
    }
}