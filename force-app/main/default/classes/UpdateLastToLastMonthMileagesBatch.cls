global class UpdateLastToLastMonthMileagesBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    public Map<String, Employee_Reimbursement__c> obj_map_contactid_reimbersement {get;set;}
    public Set<String> uniqueemail {get;set;}
    public List<Employee_Mileage__c> obj_unapprovedMileage_List {get;set;}
    public List<Employee_Mileage__c> obj_Mileage_to_update= new List<Employee_Mileage__c>();
    public string header = 'Mileage ID,Reimbersment Name,Maintenance and Tires,MPG,Month,Contact name\n';
    public string finalstr = header ; 
    
    global list<Employee_Mileage__c> start(Database.BatchableContext BC) 
    {
        obj_map_contactid_reimbersement = new Map<String, Employee_Reimbursement__c>();
        List<Employee_Mileage__c> obj_Mileage_List = new List<Employee_Mileage__c>();
        String emp = label.defaultreimbursementid;
        List<String> obj_accountnames = new List<String>();
        List<String> obj_accountnames1 = new List<String>();
        
        RG_InsertLastMonthReimbursement obj_RG_InsertLastMonthReimbursement = new  RG_InsertLastMonthReimbursement();
        String lastMonth = obj_RG_InsertLastMonthReimbursement.getLastMonthValue(-1);    
        List<String> last2Months = new List<String>();
        uniqueemail= new Set<String>();
        last2Months.add(obj_RG_InsertLastMonthReimbursement.getLastMonthValue(-2));
        last2Months.add(obj_RG_InsertLastMonthReimbursement.getLastMonthValue(-3));
        if(System.Label.TripstobeLogged!=null || System.Label.TripstobeLogged!= '')
        {
            if(System.Label.TripstobeLogged.contains(','))
            {
                obj_accountnames= System.Label.TripstobeLogged.split(',');
            }
            for(String s:obj_accountnames)
            {
                s = s.trim();
                if(s.contains(','))
                {
                    s = s.replace(',','');
                }
                obj_accountnames1.add(s);                
            }
            obj_unapprovedMileage_List = [SELECT Id,Trip_Date__c,Contact_Email_Id__c,EmployeeReimbursement__r.contact_Id__r.account.Lock_date__c,EmployeeReimbursement__r.contact_Id__r.account.Name,EmployeeReimbursement__r.Month__c,EmployeeReimbursement__r.contact_Id__r.Name,EmployeeReimbursement__r.contact_Id__r.accountId,approved_date__c FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.contact_Id__r.accountId != null AND EmployeeReimbursement__r.Month__c IN : last2Months AND EmployeeReimbursement__c !=: emp AND Approved_Date__c = null AND Trip_Status__c =: Label.Not_Approved_Yet_Mileage_Status AND Rejected__c = false and EmployeeReimbursement__r.contact_Id__r.account.Name =:obj_accountnames1];
        }
        else
        {
            obj_unapprovedMileage_List = [SELECT Id,Trip_Date__c,Contact_Email_Id__c,EmployeeReimbursement__r.contact_Id__r.account.Lock_date__c,EmployeeReimbursement__r.contact_Id__r.account.Name,EmployeeReimbursement__r.Month__c,EmployeeReimbursement__r.contact_Id__r.Name,EmployeeReimbursement__r.contact_Id__r.accountId,approved_date__c FROM Employee_Mileage__c WHERE EmployeeReimbursement__r.contact_Id__r.accountId != null AND EmployeeReimbursement__r.Month__c IN : last2Months AND EmployeeReimbursement__c !=: emp AND Approved_Date__c = null AND Trip_Status__c =:Label.Not_Approved_Yet_Mileage_Status AND Rejected__c = false];
        }
        for(Employee_Mileage__c obj_currentMileage: obj_unapprovedMileage_List) 
        {
            if(String.isNotBlank(obj_currentMileage.Contact_Email_Id__c)) 
            {
                // checks that Contact 's email address is not blank
                obj_currentMileage.From_Previous_Months__c = true;
                obj_Mileage_List.add(obj_currentMileage);
                uniqueemail.add(obj_currentMileage.Contact_Email_Id__c);
            }
        }
        if(Test.isRunningTest()) 
        {
            List<Employee_Mileage__c> mileagesTemp = new List<Employee_Mileage__c>();
            if(obj_Mileage_List.size() >= 1) 
            {
                mileagesTemp.add(obj_Mileage_List[0]);
            }
            obj_Mileage_List= new List<Employee_Mileage__c>(mileagesTemp);
        }
        List<Employee_Reimbursement__c> lastMonthReimbursements = new List<Employee_Reimbursement__c>([SELECT Id, Contact_Email__c, Contact_Id__r.Maintenance_and_Tires__c, Contact_Id__r.MPG__c FROM Employee_Reimbursement__c WHERE Contact_Email__c IN : uniqueemail AND Month__c =: lastMonth]);
        for(Employee_Reimbursement__c er : lastMonthReimbursements) 
        {
            obj_map_contactid_reimbersement.put(er.Contact_Email__c, er);
        }
        return obj_Mileage_List;
    }    
    global void execute(Database.BatchableContext BC, List<Employee_Mileage__c> Scope) 
    {
        if(Scope.size()>0)
        {
            try
            {
                for(Employee_Mileage__c obj_Employee_Mileage :Scope)
                {
                    if(obj_map_contactid_reimbersement.containsKey(obj_Employee_Mileage.Contact_Email_Id__c))
                    {
                        obj_Employee_Mileage.EmployeeReimbursement__c =  obj_map_contactid_reimbersement.get(obj_Employee_Mileage.Contact_Email_Id__c).id;
                        obj_Employee_Mileage.Maintenance_and_Tires__c =  obj_map_contactid_reimbersement.get(obj_Employee_Mileage.Contact_Email_Id__c).Contact_Id__r.Maintenance_and_Tires__c;
                        obj_Employee_Mileage.MPG__c = obj_map_contactid_reimbersement.get(obj_Employee_Mileage.Contact_Email_Id__c).Contact_Id__r.MPG__c;
                        obj_Mileage_to_update.add(obj_Employee_Mileage);
                        string recordString = obj_Employee_Mileage.id+ ',' + obj_Employee_Mileage.EmployeeReimbursement__r.Name + ',' + obj_Employee_Mileage.Maintenance_and_Tires__c + ','+ obj_Employee_Mileage.MPG__c +','+obj_Employee_Mileage.EmployeeReimbursement__r.Month__c+','+obj_Employee_Mileage.EmployeeReimbursement__r.contact_Id__r.Name+'\n';
                        finalstr = finalstr + recordString;
                    }
                }
                if(obj_Mileage_to_update.size()>0)
                {
                    update obj_Mileage_to_update;
                }
            }
            catch(Exception e)
            {
                System.Debug(e);
            }
        }
    }    
    global void finish(Database.BatchableContext BC) 
    {
        //Sending Mail
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(finalstr);
        string csvname = 'Update Last to Last Month Mileage.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'natavar.goc@gmail.com'};
            email.setSubject('Mileage Status');
        email.setToAddresses(toAddresses);
        if(obj_Mileage_to_update.isEmpty()) {
            email.setPlainTextBody('Hi, All mileages Carryforworded from previous months. Thank you.');
        } else {
            email.setPlainTextBody('Hi, Please Find the CSV for Carryforworded mileage last to last month. Thank you.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});    
        }
        if(!Test.isRunningTest()) {
            Messaging.SendEmailResult [] sendSinglemail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
}