public with sharing class DriversMileageReportClass {
    public List<DriverWrp> drivers {get;set;}
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public Decimal minMileage {get;set;}
    public String accounts {get;set;}
    
    public DriversMileageReportClass() {
        drivers = new List<DriverWrp>();
        minMileage = 0.00;
        String accName = apexpages.currentpage().getparameters().get('name');
        if(!String.isBlank(accName)) {
            accounts = accName;
        } else {
            accounts = '';
        }
    }
    public Void getDrivers() {
        Integer monthsBetween = startDate.monthsBetween(endDate);
        String month = String.valueOf(startDate.month());
        String year = String.valueOf(startDate.year());
        String months = '';
        if(month.length() == 1) {
            month = '0' + month;
        }
        months = month+'-'+year;
        for(Integer i = 0; i < monthsBetween; i++) {
            month = String.valueOf(Integer.valueOf(Month) + 1);
            if(month.length() == 1) {
                month = '0'+month;
                if(month == '01') {
                    year = String.valueOf(Integer.valueOf(year) + 1);
                }
            }
            months += ',' + month + '-' + year;
            if(month == '12') {
                month = '0';
            }
        }
        List<String> allMonths = months.split(',');
        List<String> allAccounts = accounts.split(',');
        for(Contact contact : [SELECT Id, Name, Account.Name, External_Email__c, (SELECT Id, Month__c, Total_Mileage__c
            FROM Employee_Reimbursements__r WHERE Month__c IN : allMonths)
            FROM Contact WHERE Account.Name IN : allAccounts]) {
            Double totalMileage = 0.00;
            for(Employee_Reimbursement__c er : contact.Employee_Reimbursements__r) {
                if(er.Total_Mileage__c != null) {
                    totalMileage += er.Total_Mileage__c;
                }
            }
            if(totalMileage < minMileage) {
                drivers.add(new DriverWrp(contact.Name, contact.Account.Name, contact.External_Email__c, totalMileage));
            }
        }
    }
    
    public Class DriverWrp {
        public String name {get;set;}
        public String accName {get;set;}
        public Double mileage {get;set;}
        public String email {get;set;}
        
        public DriverWrp(String name, String accName, String email, Double mileage) {
            this.name = name;
            this.accName = accName;
            this.mileage = mileage;
            this.email = email;
        }
    }
}