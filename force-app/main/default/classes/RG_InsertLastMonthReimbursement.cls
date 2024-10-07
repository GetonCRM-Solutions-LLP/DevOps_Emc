Public class RG_InsertLastMonthReimbursement implements Database.Batchable<Contact>, Database.Stateful {

    public string attachementString = 'City, State, Date\n'; 
    public String month;
    public String emailaddress;
    public Map<String,Decimal> missingfuelpricemap;
    public Map<String, Decimal> fuelPriceMap;
    public List<Employee_Reimbursement__c> reimToInsert {get;set;}
    List<String> yearList = new List<String>();
    IRS_Mileage_Rate__c objIRSRate;
    
    public RG_InsertLastMonthReimbursement() {
        yearList.add(getLastMonth());
        objIRSRate = [SELECT id,year__c,IRS_Rate__c 
                        FROM IRS_Mileage_Rate__c 
                        WHERE year__c =: yearList Limit 1];
        
        fuelPriceMap = new  Map<String, Decimal>(); 
        missingfuelpricemap = new Map<String,Decimal>();      
        setFuelPriceInMap(Date.today().addmonths(-1).tostartofmonth());
    }
    public RG_InsertLastMonthReimbursement(String passedMonth)  {   
        yearList.add(getLastMonth());
        objIRSRate = [SELECT id,year__c,IRS_Rate__c 
                        FROM IRS_Mileage_Rate__c 
                        WHERE year__c =: yearList Limit 1];
            
        month = passedMonth;
        fuelPriceMap = new  Map<String, Decimal>();
        missingfuelpricemap = new Map<String,Decimal>();         
        setFuelPriceInMap(getDate(passedMonth));
    }
    public RG_InsertLastMonthReimbursement(String passedMonth,String paasedEmailaddress)    {
        yearList.add(getLastMonth());
        objIRSRate = [SELECT id,year__c,IRS_Rate__c 
                            FROM IRS_Mileage_Rate__c 
                            WHERE year__c =: yearList Limit 1];
       
        emailaddress = paasedEmailaddress;
        month = passedMonth;
        fuelPriceMap = new  Map<String, Decimal>(); 
        missingfuelpricemap = new Map<String,Decimal>();  
        setFuelPriceInMap(getDate(passedMonth));
    }
    Public List<Contact> start(Database.BatchableContext bc) {    
            List<Contact> allActiveContacts = new List<Contact>([SELECT Id, Name, Account.Name, isCommunityUser__c, Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c, MailingState, MailingCity 
                                                                    FROM Contact 
                                                                    WHERE (Deactivated_Date__c = NULL OR Deactivated_Date__c > Today) 
                                                                            AND (Role__c = 'Driver' OR Role__c = 'Driver/Manager' OR Role__c =: StaticValues.roleAdminDriver) 
                                                                            AND (Driver_Type__c != 'Driver - Part Time' OR Driver_Type__c != 'Driver - Full Time')  
                                                                            //AND AccountId != '0010Z00001ygUen'
                                                                            AND Account.Name != 'Test Accounts'  
                                                                            AND Account.isUsingTriplog__c = true
                                                                            AND MailingState != null
                                                                            AND MailingCity != null ]); 
        return allActiveContacts;
    }
    
    Public Void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        reimToInsert   = new List<Employee_Reimbursement__c>();
        if(month!=null) {
            for(Contact currentContact : (List<Contact>) scope) {
               Decimal fuelPrice = emptyFuelPrice(currentContact);
            }
        }
        else {
            String lastMonth = getLastMonthValue(-1);
            for(Contact contact : (List<Contact>) scope) {
                Decimal fuelPrice = emptyFuelPrice(contact); 
                               
                Employee_Reimbursement__c er = new Employee_Reimbursement__c();
                er.Fixed_Amount__c = contact.Fixed_Amount__c;
                er.Status__c = 'Pending';
                er.Maintenance_and_Tires__c = contact.Maintenance_and_Tires__c;
                er.MPG__c = contact.MPG__c;
                er.Contact_Id__c = contact.id;
                er.Name = contact.Name + ':' + lastMonth;
                er.Month__c = lastMonth;
                er.Fuel_Price__c = fuelPrice;
                er.IRS_Mileage_Rate__c = objIRSRate.ID;
                reimToInsert.add(er);                 
            }
        }
        if(!reimToInsert.isEmpty()) {
            insert reimToInsert;
        }
    }
    Public String getLastMonthValue(Integer value) {
        String tempDate = date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }
        return lastMonth;
    }
    Public String getLastMonth()    {
        Integer currentMonth = date.today().Month();
        string tempYear = String.valueOf(date.today().Year());
        if(currentMonth == 1)   {
            tempYear = String.valueOf(date.today().addMonths(-1).Year());
        }
        return tempYear;
    }
    
    Public Decimal emptyFuelPrice(Contact currentContact)   {
        Decimal fuelPrice = 0;
        String conString = currentContact.Mailingcity + '-' + currentContact.MailingState;
        conString = conString.toUpperCase();
        if(fuelPriceMap.containsKey(conString)) {
            fuelPrice = fuelPriceMap.get(conString);
        }
        if(fuelPrice==0)    {
            missingfuelpricemap.put(conString,0);
        }
        return fuelPrice;
    }
    Public Date getDate(String passedMonth) {
        Date fuelpricedate = date.newinstance(Integer.valueOf(month.split('-')[1]),Integer.valueOf(month.split('-')[0]), 1);
        return fuelpricedate;
    }
    Public void setFuelPriceInMap(Date fuelpricedate)   {
        for(Gas_Prices__c currentFuelPrice : [SELECT Fuel_Price__c, Month_State_City__c, Month_Year__c, State__c, City__c 
                                                FROM Gas_Prices__c 
                                                WHERE Month_Year__c = :fuelpricedate]) {
            String temp = currentFuelPrice.city__c + '-' + currentFuelPrice.State__c;
            fuelPriceMap.put(temp.touppercase(), currentFuelPrice.Fuel_Price__c);
        }
    }
    Public Void finish(Database.BatchableContext bc) {
        //Sending Mail
        for(String currentcitystate : missingfuelpricemap.keySet()) {
            String splittedCityState='';
            if(currentcitystate.contains('-'))  {
                if(!String.isBlank(month))  {
                    splittedCityState=currentcitystate.split('-')[0] + ','+ currentcitystate.split('-')[1] + ','+String.valueOf(month.split('-')[0])+'/'+'2'+'/'+String.valueOf(month.split('-')[1])+'\n';
                }
                else {
                    splittedCityState=currentcitystate.split('-')[0] + ','+ currentcitystate.split('-')[1] + ','+String.valueOf(Date.today().addmonths(-1).month())+'/'+'2'+'/'+String.valueOf(Date.today().addmonths(-1).year())+'\n';
                }  
            }
            attachementString = attachementString + splittedCityState;
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(attachementString);
        string csvname = 'Missing Fuel Price.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> emails = new List<String>();
        if(!String.isBlank(emailaddress))   {
            if(emailaddress.contains(','))  {
                emails = emailaddress.split(',');                
            }
            else {
                emails.add(emailaddress);                
            }
            email.setToAddresses(emails);
        }
        else {
            String toAddresses = '';
            toAddresses = Label.Email_To_Address;
            if(!String.isBlank(toAddresses))    {
                if(toAddresses.contains(','))   {
                    emails = toAddresses.split(',');                   
                }
                else {
                    emails.add(toAddresses);
                } 
                email.setToAddresses(emails);
            }
        }
        if(!String.isBlank(month))  {
            email.setSubject('Missing Fuel Price for '+month);
        }
        else {
            email.setSubject('Missing Fuel Price for '+getLastMonthValue(-1));
        }                 
        email.setPlainTextBody('Hi, Please Find the CSV for Missing Details. Thank you.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        
        if(!Test.isRunningTest()) {
            Messaging.SendEmailResult [] sendSinglemail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        GetTripBatchClass getTrip = new GetTripBatchClass('U');
    }
}