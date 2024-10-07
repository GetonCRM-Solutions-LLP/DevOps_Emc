/* *************************************************************************************************
* Author : GetonCRM Solutions LLP                                                                      
* Created Date : 08/02/2022                                                                            
* Description : This Batch is used to create BiWeekly Reimbursement For PL Marketing Account and       
*                Sonora Quest Account automatically to the next day of the current Biweekly            
*                Reimbursement is Finished. 
* Modified Functionality :- Create BiWeekly Reimbursement for all Biweekly Reimbursement 
* -------------------------------------------------------------------------------------------------
* Modified By : Paras Dhanani                                                                          
* Modified Date : 21-03-2023                                                                           
***************************************************************************************************/

Public class CreateBiweeklyReim Implements Database.Batchable<sObject> ,  database.stateful {
    
    Public date myDate;
    Public date dateStr;
    Public string currentYearVal;
    Public string accName;
    Public List<String> accNameList;
    Public date fuelPriceDate;
    Public String currentMonthDateStr ;
    List<IRS_Mileage_Rate__c> objIRSRate;
    Map<String,String> employeereimMap = new Map<String,String>();
    public Map<Integer,String> errorMap = new Map<Integer,String>();
    //public Integer errorFlagCount = 0;
    public List<Bi_Weekly_Reimbursement__c> biweeklyreimToInsert   = new List<Bi_Weekly_Reimbursement__c>();
    public String exceptionMessage = '';
    
    Public CreateBiweeklyReim(){
        myDate = system.today();
        accName = System.Label.BiWeekly_Reim_create;
        accNameList = new List<String>();
        accNameList=accName.split(',');
        currentYearVal = String.valueOf(date.today().Year());
        date startdate = system.today().adddays(1);
        currentMonthDateStr = DateTime.newInstance(startdate.year(),startdate.month(),startdate.day()).format('MM-yyyy');
        objIRSRate = [SELECT id,year__c,IRS_Rate__c FROM IRS_Mileage_Rate__c Where year__c =: currentYearVal Limit 1];
    }
    Public List<Contact> start(Database.BatchableContext bc)    {
        Date myDate = system.today();
        List<Contact> conList = new List<Contact>();
        if(!Test.isRunningTest()){
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c,Account.Pay_Period_Start_Date__c, 
                       Account.Pay_Period_Days__c,MailingCity, MailingState 
                       FROM contact 
                       WHERE Account.Name =: accNameList  
                       AND Role__c != 'Admin' 
                       AND Role__c != 'Manager' 
                       AND Deactivated_Date__c = NULL
                       AND Reimbursement_Frequency__c = 'Bi-Weekly Reimbursement'
                       //AND Biweek_Reimbursement__c = true
                       //AND Account.isUsingTriplog__c = true 
                       AND Activation_Date__c <=: myDate 
                       WITH SECURITY_ENFORCED ];
        } else {
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c,Account.Pay_Period_Start_Date__c, 
                       Account.Pay_Period_Days__c,MailingCity,MailingState
                       FROM contact 
                       WHERE Role__c != 'Admin' 
                       AND Role__c != 'Manager'
                       WITH SECURITY_ENFORCED ];
        }
        return conList; 
    }
    
    Public void execute(Database.BatchableContext bc, list<contact> conList)    {
        date newStartDate;
        Date endDate;
        date newEnddate;
        String nameNewStartDate;
        String namenewEnddate;
        Integer payDays;
        Date payStartDate;
        map<id,date> accIdvsPayLastEndDates = new map<id,date>();
        map<id,Decimal> accIdvsDays = new map<id,Decimal>();
        map<id,String> accIdvsNewStartDateName = new map<id,String>();
        map<id,String> accIdvsNewEndDateName = new map<id,String>();
        map<id,Date> accIdvsNewStartDate = new map<id,Date>();
        map<id,Date> accIdvsNewEndDate = new map<id,Date>();
        
        string[] currentDate = string.valueOf(myDate).split('-');
        
        if(integer.valueOf(currentDate[1]) == 01){
            fuelPriceDate = date.valueOf(string.valueOf(integer.valueOf(currentDate[0])-1) + '-12' + '-01' );   
        } else {
            fuelPriceDate = date.valueOf(currentDate[0] + '-' + string.valueOf(integer.valueOf(currentDate[1])-1) + '-01');
        } 
        
        map<string, Decimal> monthStateCityVsFuelPriceMap = new map<string, Decimal>(); 
        for(Gas_Prices__c objGasPrice : [SELECT id,
                                         name,
                                         City__c,
                                         State__c, 
                                         Fuel_Price__c, 
                                         Month_Year__c,
                                         Month_State_City__c 
                                         FROM Gas_Prices__c 
                                         WHERE  Month_Year__c =: date.valueOf(fuelPriceDate)]) {
                                             monthStateCityVsFuelPriceMap.put(objGasPrice.Month_State_City__c, objGasPrice.Fuel_Price__c); 
                                         }
        
        for(Employee_Reimbursement__c employeereimListObj : [Select id,Contact_Id__c,Month__c from Employee_Reimbursement__c where Contact_Id__r.Account.Name =: accNameList and Month__c =:currentMonthDateStr]){
            employeereimMap.put(employeereimListObj.Contact_Id__c, employeereimListObj.id);
        }
        for(Account acc : [select id,Pay_Period_Days__c,Pay_Period_Start_Date__c from account where Name =: accNameList]){
            payDays = Integer.valueOf(acc.Pay_Period_Days__c);
            payStartdate = acc.Pay_Period_Start_Date__c;
            List<Date> dtList = new list<Date>();
            do {
                endDate = payStartdate.addDays(payDays);
                if(payStartdate <= system.today() && system.today() <= endDate) {
                    dtList.add(payStartdate);
                    dtList.add(endDate);
                }
                payStartdate = endDate.addDays(1);
            } while(endDate < System.today());
            newStartDate = endDate.addDays(1);
            string sNewStartDate = string.valueOf(newStartDate);
            String[] sdsplit = sNewStartDate.split('-');
            nameNewStartDate = sdsplit[1] + '/' + sdsplit[2] + '/' + sdsplit[0];
            newEnddate =  newStartDate.addDays(payDays);
            string enewEnddate = string.valueOf(newEnddate);
            String[] sedsplit = enewEnddate.split('-');
            namenewEnddate = sedsplit[1] + '/' + sedsplit[2] + '/' + sedsplit[0];
            accIdvsNewStartDate.put(acc.Id,newStartDate);
            accIdvsNewStartDateName.put(acc.Id,nameNewStartDate);
            accIdvsNewEndDate.put(acc.Id,newEnddate);
            accIdvsNewEndDateName.put(acc.Id,namenewEnddate);
            accIdvsPayLastEndDates.put(acc.Id, endDate);
            system.debug('accIdvsPayLastEndDates==' + accIdvsPayLastEndDates);
            accIdvsDays.put(acc.Id,payDays);
        }
        try {
        for(Contact con : [SELECT id,AccountId,Account.Pay_Period_Days__c, Deactivated_Date__c,Account.Pay_Period_Start_Date__c,Account.Bi_Weekly_Pay_Period__c,MPG__c, Maintenance_and_Tires__c,Fixed_Amount__c,MailingCity,MailingState
                           FROM Contact 
                           WHERE id =: conList]) {
                               if(accIdvsPayLastEndDates.containskey(con.AccountId) || test.isRunningTest()){
                                   if(accIdvsPayLastEndDates.get(con.AccountId) == system.today()){
                                   		Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
                                       br.name = accIdvsNewStartDateName.get(con.AccountId) + ' to ' + accIdvsNewEndDateName.get(con.AccountId);
                                       br.Contact__c = con.Id;
                                       br.Start_Date__c = accIdvsNewStartDate.get(con.AccountId);
                                       br.End_Date__c = accIdvsNewEndDate.get(con.AccountId);
                                       br.MPG__c = con.MPG__c;
                                       br.Maintenance_and_Tires__c = con.Maintenance_and_Tires__c;
                                       br.Fixed_Amount__c = con.Fixed_Amount__c;
                                       br.Status__c = 'Pending';
                                       if(employeereimMap.containsKey(con.Id)){
                                           br.Employee_Reimbursement__c = employeereimMap.get(con.Id);
                                       }
                                       if(integer.valueOf(currentDate[1]) == 01){
                                           if (monthStateCityVsFuelPriceMap.containsKey(con.MailingCity+ con.MailingState + '12' + string.valueOf(integer.valueOf(currentDate[0])-1)) ) {
                                               br.Fuel_Price__c = monthStateCityVsFuelPriceMap.get(con.MailingCity+ con.MailingState + '12' + string.valueOf(integer.valueOf(currentDate[0])-1)) ;
                                           }   else {
                                               br.Fuel_Price__c = 0;
                                           }
                                       }   else {
                                           if (monthStateCityVsFuelPriceMap.containsKey(con.MailingCity+ con.MailingState + string.valueOf(integer.valueOf(currentDate[1])-1) + currentDate[0]) ) {
                                               br.Fuel_Price__c = monthStateCityVsFuelPriceMap.get(con.MailingCity+ con.MailingState + string.valueOf(integer.valueOf(currentDate[1])-1) + currentDate[0]);
                                           }   else {
                                               br.Fuel_Price__c = 0;
                                           }
                                       }
                                       if(!objIRSRate.isEmpty()){
                                           br.IRS_Mileage_Rate__c = objIRSRate[0].ID;
                                       }
                                       biweeklyreimToInsert.add(br);
                                       system.debug('biweeklyreimToInsert=='+biweeklyreimToInsert);
                                   }
                               }
                               System.debug('Error in insert Reimbursement ' + errorMap);
                           }
            if(!biweeklyreimToInsert.isEmpty() || Test.isRunningTest()){
                                           Database.SaveResult[] insertBiweeklyReim= Database.insert(biweeklyreimToInsert, false);
                                           Integer errorFlagCount = 0;
                                           if(insertBiweeklyReim.size() > 0){
                                               for(Database.SaveResult sr:insertBiweeklyReim){
                                                   if (sr.isSuccess() == false) {
                                                       system.debug('Insert into false if condition==');
                                                       for(Database.Error objErr : sr.getErrors()) {
                                                           errorMap.put(errorFlagCount, objErr.getMessage());
                                                           errorFlagCount++;
                                                       }
                                                   }
                                                   
                                               }  
                                           }
                                       }
                               } catch(DmlException e) {
                                           System.debug('The following exception has occurred: ' + e.getMessage());
                                           exceptionMessage = 'Exception:-'+e.getMessage()+' '+e.getLineNumber();
                                       }
    } 
    Public void finish(Database.BatchableContext bc){
        
        String errorEmail=System.Label.Error_Email_for_not_Create_BiWeeklyReimberssment;
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
        attach.setFileName('Employee Biweekly Reimbursement Error File .Csv');
        errorSubject = 'Error Result Of Employee Biweekly Reimbursement Csv File';
        htmlbody = 'Your job is not completed due to some record has error, so please see the last column in attached csv file for error';
        system.debug('exceptionMessage==' + exceptionMessage);
        system.debug('errorMap==' + errorMap);
        if((exceptionMessage == null || exceptionMessage == '') && !errorMap.isEmpty()) {            
            for(Integer mapkey : errorMap.keySet()){
                 system.debug('errorMapkeyset==' + errorMap.keySet());
                    Name = String.valueOf(biweeklyreimToInsert.get(mapkey).Name) != null ? biweeklyreimToInsert.get(mapkey).Name : '';
                    ContactId = String.valueOf(biweeklyreimToInsert.get(mapkey).Contact__c) != null ? biweeklyreimToInsert.get(mapkey).Contact__c : '';
                    String Recordstring = biweeklyreimToInsert.get(mapkey).Name +',' + biweeklyreimToInsert.get(mapkey).Contact__c +',' + errorMap.get(mapkey)+'    \n';
                    finalstr = finalstr + Recordstring;
            } 
            system.debug('finalstr==' + finalstr);
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