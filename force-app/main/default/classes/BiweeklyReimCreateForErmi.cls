/* ******************************************************************************************************
 * Author : GetonCRM Solutions LLP																		*
 * Created Date : 02/02/2022																			*
 * Description : This Batch is use to create BiWeekly Reimbursement For ERMI  Account automatically 	*
 * 				  to the next day of the current Biweekly Reimbursement is Finished.					*
 * -----------------------------------------------------------------------------------------------------*
 * Modified By : Paras Dhanani																			*
 * Modified Date : 21/03/2022																			*
 *******************************************************************************************************/

Global class BiweeklyReimCreateForErmi Implements Database.Batchable<sObject> ,  database.stateful {
    
    Public date myDate;
    Public  date dateStr;
    Public string tempYear;
    Public string accId;
    Public date fuelPriceDate ;
    List<IRS_Mileage_Rate__c> objIRSRate;
    Map<String,String> employeereimMap = new Map<String,String>();
    
    global BiweeklyReimCreateForErmi(){
        myDate = system.today();
        accId = System.Label.ERMI_Account;
        tempYear = String.valueOf(date.today().Year());
        date startdate = system.today().adddays(1);
		String currentMonthDateStr = DateTime.newInstance(startdate.year(),startdate.month(),startdate.day()).format('MM-yyyy');
        System.debug('Current month in Date: '+currentMonthDateStr);    
        objIRSRate = [SELECT id,year__c,IRS_Rate__c FROM IRS_Mileage_Rate__c Where year__c =: tempYear Limit 1];
        
        for(Employee_Reimbursement__c employeereimListObj : [Select id,Contact_Id__c,Month__c from Employee_Reimbursement__c where Contact_Id__r.AccountId =: accId and Month__c =:currentMonthDateStr]){
            employeereimMap.put(employeereimListObj.Contact_Id__c, employeereimListObj.id);
        }
        System.debug('map:'+employeereimMap);
        
        /*for(Bi_Weekly_Reimbursement__c biweeklyreimList : [SELECT Id,Start_Date__c,Contact__c from Bi_Weekly_Reimbursement__c where Contact__r.AccountId =: accId]){
            date startDateofBiWeekly = biweeklyreimList.Start_Date__c;
            String currentMonthDateStr = DateTime.newInstance(startDateofBiWeekly.year(),startDateofBiWeekly.month(),startDateofBiWeekly.day()).format('MM-yyyy');
            if(employeereimMap.containsKey(currentMonthDateStr)){
                
            }
            //String dateEmployee_Reimbursement__c = employeereimMap.get(biweeklyreimList.Id);
        }*/
    }
    
    Global List<Contact> start(Database.BatchableContext bc)	{
        List<Contact> conList = new List<Contact>();
        if(!Test.isRunningTest()){
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c,Account.Pay_Period_Start_Date__c, 
                       Account.Pay_Period_Days__c,MailingCity, MailingState
                       FROM contact 
                       where AccountId =: accId 
                       AND Role__c != 'Admin' 
                       AND Role__c != 'Manager' 
                       AND Deactivated_Date__c = NULL 
                       AND Account.isUsingTriplog__c = true
                       AND Driver_Type__c != NULL
                       AND Activation_Date__c <=: myDate];
        } else {
            conList = [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c,Account.Pay_Period_Start_Date__c, 
                       Account.Pay_Period_Days__c,MailingCity, MailingState  
                       FROM contact 
                       WHERE Role__c != 'Admin' 
                       AND Role__c != 'Manager'];
        } 
        return conList;   
    }
    
    Global void execute(Database.BatchableContext BC, list<contact> conList)	{
        system.debug('conList=='+ conList);
        system.debug('conListsize=='+ conList.size());
        Decimal days;
        for(contact conListobj : conList){
            days = (conListobj.account.Pay_Period_Days__c != null ? conListobj.account.Pay_Period_Days__c : null);
        }
        string startdate = string.valueOf(system.today().adddays(1));
        string[] splitsdate = startDate.split('-');
        string splitStartDate = splitsdate[1]+'/'+splitsdate[2]+'/'+splitsdate[0];
        String enddate = String.valueof(date.valueof(startDate).addDays(Integer.valueof(days)));
        string[] splitdate = enddate.split('-');
        string splitEndDate = splitdate[1]+'/'+splitdate[2]+'/'+splitdate[0];
        string[] currentDate = string.valueOf(myDate).split('-');
       
        if(integer.valueOf(currentDate[1]) == 01){
            fuelPriceDate = date.valueOf(string.valueOf(integer.valueOf(currentDate[0])-1) + '-12' + '-01' );   
        } else {
            fuelPriceDate = date.valueOf(currentDate[0] + '-' + string.valueOf(integer.valueOf(currentDate[1])-1) + '-01');
        } 
    string[] splitedfuelPriceDate = string.valueOf(fuelPriceDate).split('-');

            map<string, Decimal> monthStateCityVsFuelPriceMap = new map<string, Decimal>(); 
           for(Gas_Prices__c obj_GasPrice : [SELECT id,
           name,
           City__c,
           State__c, 
           Fuel_Price__c, 
           Month_Year__c,
           Month_State_City__c 
           FROM Gas_Prices__c 
           WHERE  Month_Year__c =: date.valueOf(fuelPriceDate)]) {
                    monthStateCityVsFuelPriceMap.put(obj_GasPrice.Month_State_City__c, obj_GasPrice.Fuel_Price__c); 
           }

        List<Bi_Weekly_Reimbursement__c> biweeklyreimToInsert   = new List<Bi_Weekly_Reimbursement__c>();
        for(contact con :  (List<Contact>) conList) {
            Bi_Weekly_Reimbursement__c br = new Bi_Weekly_Reimbursement__c();
            br.Name = splitStartDate + ' to ' + splitEndDate ; 
            br.Contact__c = con.Id;
            br.Start_Date__c = date.parse(splitStartDate);
            br.End_Date__c = date.parse(splitEndDate);
            br.MPG__c = con.MPG__c;
            br.Maintenance_and_Tires__c = con.Maintenance_and_Tires__c;
            br.Fixed_Amount__c = con.Fixed_Amount__c;
            br.Status__c = 'Pending';
            br.Count_Error_Check__c = 0;
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
        }
        if(!biweeklyreimToInsert.isEmpty() && !Test.isRunningTest()){
            Database.insert(biweeklyreimToInsert, false);
        }
    } 
    Global void finish(Database.BatchableContext BC){}   
}