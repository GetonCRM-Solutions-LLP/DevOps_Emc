public with sharing class triplogerrorcontroller 
{
    public String Selected_month{get;set;}
    public String Selected_month_failRecord {get; set;}
    String[] months = new String[]{};
    String[] status = new String[]{};
    public List<triplogWrapper> triplogWrapperList {get; set;}
    public Integer totalTrips {get; set;}
    public String reimDate;
    public triplogerrorcontroller() 
    {
        String s = ApexPages.currentPage().getParameters().get('reimDate');
        System.debug('reimDate---'+s); 
        if (ApexPages.currentPage().getParameters().containsKey('reimDate')) 
        {
            String st = ApexPages.currentPage().getParameters().get('reimDate');
            System.debug('reimDate---'+st);        
        }
        totalTrips = 0;
        triplogWrapperList = new List<triplogWrapper>();

    }
    public List<SelectOption> getresettableForMonth() 
    {     
        List<SelectOption> options = new List<SelectOption>();
        Date myDate = date.newinstance(2017, 01, 01);
        String value1 = '';
        options.add(new SelectOption('none','select'));
        if((myDate.month()<10))
        {
            value1 = '0'+String.valueOf(myDate.month()) +'-'+String.valueOf(myDate.year()); 
        }
        else
        {
            value1 = String.valueOf(myDate.month()) +'-'+String.valueOf(myDate.year());     
        }
        options.add(new SelectOption(value1,value1));
        Date todayDate = System.today();
        Integer monthsBetween = myDate.monthsBetween(todayDate);
        for(Integer i = 1; i <monthsBetween; i++)
        {
            myDate = myDate.addMonths(1);           
            if(myDate < todayDate) 
            {
                String value2 = '';
                if(myDate.month()<10)
                {
                    value2 = '0'+String.valueOf(myDate.month()) +'-'+String.valueOf(myDate.year());
                }
                else
                {
                    value2 = String.valueOf(myDate.month()) +'-'+String.valueOf(myDate.year());
                }
                options.add(new SelectOption(value2,value2));
            }
            else
            {
                break;
            }
        }
        return options;
    }

    public List<SelectOption> getStatuses() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('none','Select'));
        options.add(new SelectOption('Fail','Fail'));
        options.add(new SelectOption('Success','Success'));
        return options;
    }

    public PageReference resetfilter()
    {
        String s = ApexPages.currentPage().getParameters().get('reimDate');
        System.debug('reimDate---'+s);
        triplogWrapperList = new List<triplogWrapper>();
        String soql ='select Id,Name,Contact__r.Account.Name,Contact__c,Contact__r.Name,Total_Mileages__c,Total_Trips__c,Status__c,Contact__r.FirstName,Contact__r.LastName,Employee_Reimbursement__c,Employee_Reimbursement__r.Name,Employee_Reimbursement__r.Month__c,Endpoint__c,Response__c from Tripslog__c ';       
        
        if(Selected_month_failRecord == 'Fail' && Selected_month!=null) {
            System.debug('Status -- '+Selected_month_failRecord);
            soql = soql + ' where Status__c = \''+Selected_month_failRecord+'\' and Employee_Reimbursement__r.Month__c =\''+Selected_month+'\'';
            System.debug(soql);
        }  
        else if(Selected_month_failRecord == 'Success' && Selected_month!=null) {
            soql = soql + ' where Status__c = \''+Selected_month_failRecord+'\' and Employee_Reimbursement__r.Month__c =\''+Selected_month+'\'';
        } 
        else if(Selected_month!=null) {
            soql = soql + 'where Employee_Reimbursement__r.Month__c =\''+Selected_month+'\'';
        }  

        for(Tripslog__c t : (List<Tripslog__c>) Database.query(soql)) 
        {
            triplogWrapperList.add(new triplogWrapper(t.Name,t.Contact__r.Account.Name,t.Contact__r.FirstName,t.Contact__r.LastName,t.Employee_Reimbursement__r.Name,t.Employee_Reimbursement__r.Month__c,t.Endpoint__c,t.Response__c,t.Total_Mileages__c,t.Total_Trips__c,t.Status__c));            
        }
        totalTrips = triplogWrapperList.size();
        return null;
    }

    public String[] getMonths() {
        return months;
    }

    public void setMonths(String[] months) {
        this.months = months;
    }

    public String[] getStatus() {
        return status;
    }
            
    public void setStatus(String[] status) {
        this.status = status;
    }

    public class triplogWrapper {
        public String name {get; set;}
        public String accName {get; set;}
        public String conFirstName {get; set;}
        public String conLastName {get; set;}
        public String reimName {get; set;}
        public String reimMonth {get; set;}
        public String endpoint {get; set;}
        public String response {get; set;}
        public Decimal totalMilage {get; set;}
        public Decimal Total_Trips {get; set;}
        public String status {get; set;}
        public triplogWrapper(String name,String accName,String conFirstName,String conLastName,String reimName,String reimMonth,String endpoint,String response,Decimal totalMilage, Decimal Total_Trips,String status) {
            this.name = name;
            this.accName = accName;
            this.conFirstName = conFirstName;
            this.conLastName = conLastName;
            this.reimName = reimName;
            this.reimMonth = reimMonth;
            this.endpoint = endpoint;
            this.response = response;
            this.totalMilage = totalMilage;
            this.Total_Trips = Total_Trips;
            this.status = status;
        }
    }
    
}