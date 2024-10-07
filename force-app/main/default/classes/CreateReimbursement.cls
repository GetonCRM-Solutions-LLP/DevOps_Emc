global class CreateReimbursement implements  Database.Batchable<Contact>, Database.Stateful {
    global final blob dataDocuments;
    global String exceptionMessage = '';
    global Map<Integer,String> errorMap = new Map<Integer,String>();
    global List<Employee_Reimbursement__c> reimToInsert = new List<Employee_Reimbursement__c>();
    public Integer currentMonth;
    public string tempYear;
    public List<IRS_Mileage_Rate__c> objIRSRate;
    public String lastMonth;
    
    public CreateReimbursement (){
        currentMonth = date.today().Month();
        tempYear = String.valueOf(date.today().Year());
        objIRSRate = new List<IRS_Mileage_Rate__c>();
        objIRSRate = [SELECT id,year__c,IRS_Rate__c FROM IRS_Mileage_Rate__c Where year__c =: tempYear Limit 1];
        lastMonth = Utils.fetchMonths(1, -1)[0];
    }
    global List<Contact> start(Database.BatchableContext BC) {
        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        system.debug('firstDayOfMonth=='+ firstDayOfMonth);
        system.debug('lastDayOfMonth=='+ lastDayOfMonth);
        List<Contact> conList = new List<Contact>();
        if(!Test.isRunningTest()){
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c 
                       FROM contact 
                       WHERE Role__c != 'Admin' 
                       AND Role__c != 'Manager' 
                       AND (Deactivated_Date__c = NULL 
                            OR (NOT (Deactivated_Date__c < TODAY )))
                       AND Account.isUsingTriplog__c = true 
                       AND Activation_Date__c <= : lastDayOfMonth];
        } else {
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c FROM contact WHERE Role__c != 'Admin' AND Role__c != 'Manager'];
        }
        return conList;
    }
    global Void execute(Database.BatchableContext BC, List<SObject> Scope) { 
        try {
            for(Contact currentContact : (List<Contact>) Scope){
                Employee_Reimbursement__c er = new Employee_Reimbursement__c();
                er.Fixed_Amount__c = currentContact.Fixed_Amount__c;
                er.Status__c = 'Pending';
                er.Maintenance_and_Tires__c = currentContact.Maintenance_and_Tires__c;
                er.MPG__c = currentContact.MPG__c;
                er.Contact_Id__c = currentContact.id;
                er.Name = currentContact.Name + ':' + lastMonth;
                er.Month__c = lastMonth;
                er.Fuel_Price__c = 0;
                er.Number_of_Pay_Period__c = 2;
                if(!objIRSRate.isEmpty()){
                    er.IRS_Mileage_Rate__c = objIRSRate[0].ID;
                }
                reimToInsert.add(er);
            }
            if(!reimToInsert.isEmpty() || Test.isRunningTest()) {
                Database.saveResult[] insertReimList = Database.insert(reimToInsert, false);
                Integer erroFlagCount = 0;
                for (Database.saveResult sr : insertReimList) {
                    if (sr.isSuccess() == false) {
                        for(Database.Error objErr : sr.getErrors()) {
                            String errorlog = json.serialize(objErr);
                            errorMap.put(erroFlagCount, objErr.getMessage());
                        }
                        System.debug('Error in insert Reimbursement ' + errorMap);
                    }
                    erroFlagCount ++;
                }
            } 
        }  catch(Exception e){
            System.debug('Exception:- '+e.getMessage()+' '+e.getLineNumber());
            exceptionMessage = 'Exception:-'+e.getMessage()+' '+e.getLineNumber();
        }
    }
    global Void finish(Database.BatchableContext BC) {
        String errorEmail=System.Label.Error_Email_for_not_Create_Reimbursement;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {errorEmail};
            email.setToAddresses(toAddresses);
        String errorSubject;
        String htmlbody;
        Boolean emailFalg = false;
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        String finalstr;
        string header ='Name'+','+'ContactId'+','+'Error'+' \n';
        finalstr = header;
        String Name,ContactId;
        attach.setFileName('Employee Reimbursement Error File .Csv');
        errorSubject = 'Error Result Of Employee Reimbursement Csv File';
        htmlbody = 'Your job is not completed due to some record has error, so please see the last column in attached csv file for error';
        if((exceptionMessage == null || exceptionMessage == '') && !errorMap.isEmpty()) {            
            for(Integer mapkey : errorMap.keySet()){
                Name = String.valueOf(reimToInsert.get(mapkey).Name) != null ? reimToInsert.get(mapkey).Name : '';
                ContactId = String.valueOf(reimToInsert.get(mapkey).Contact_Id__c) != null ? reimToInsert.get(mapkey).Contact_Id__c : '';
                String Recordstring = reimToInsert.get(mapkey).Name +',' + reimToInsert.get(mapkey).Contact_Id__c +',' + errorMap.get(mapkey)+'    \n';
                finalstr = finalstr + Recordstring;
            } 
            attach.setBody(blob.valueOf(finalstr));            
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
        }if((exceptionMessage == null || exceptionMessage == '') && errorMap.isEmpty()) {
            emailFalg = true;
            System.debug('exceptionMessage == errorMap.isEmpty()-->');
        } 
        email.setSubject(errorSubject);
        email.setHTMLBody(htmlbody);
        if(emailFalg == false)
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
    }
}