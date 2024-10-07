/*************************************************************************************
* Author :- GetOnCRM Solutions														 *	
* Created Date:- 10/01/2022														 	 *
* Description :- This Class is used to update fuel price field of 				     *
* Biweekly Reimbursement based on gas price of last month.                           *
* EX :- If the start date of biweekly reim is 02/09/2022 than the fuel price of      *
* biweekly Reim is update with fuel price of 01/01/2022 of gas price object.         *
* ---------------------------------------------------------------------------------- *
* Updated By :- Paras Dhanani || updated on 24/01/2022								 *														     
**************************************************************************************/

public class UpdateBiWeeklyreimFuelPriceController {
    public Bi_Weekly_Reimbursement__c biWeeklyReimId{get; set;}
    public String urltoredirect {get;set;}
    static string accId ;
    static date mydate ;
    static date biWeeklyStartDate; 
    static date biWeeklyEndDate; 
    
    public UpdateBiWeeklyreimFuelPriceController()  { }
    
    public UpdateBiWeeklyreimFuelPriceController(ApexPages.StandardController controller)
    {
        biWeeklyReimId = (Bi_Weekly_Reimbursement__c)controller.getRecord();
        urltoredirect ='https://'+ URL.getSalesforceBaseUrl().getHost()+'/'+ biWeeklyReimId.id;      
        system.debug('biWeeklyReimId==' +biWeeklyReimId);
    } 
    
    public pagereference updatefuelprice() {
        for(Bi_Weekly_Reimbursement__c biweeklyreimList : [SELECT id, 
                                                           Start_Date__c, 
                                                           Contact__r.AccountId,End_Date__c,
                                                           Month_State_City__c
                                                           FROM Bi_Weekly_Reimbursement__c 
                                                           WHERE (Fuel_Price__c = null or Fuel_Price__c = 0) and Id  =: biWeeklyReimId.Id]) {
                                                               accId = biweeklyreimList.Contact__r.AccountId;
                                                               string startdate;
                                                               if(biweeklyreimList.Start_Date__c != null){
                                                                   startDate = string.valueOf(biweeklyreimList.Start_Date__c) ;
                                                                   biWeeklyStartdate =biweeklyreimList.Start_Date__c;
                                                               }
                                                               if(biweeklyreimList.End_Date__c != null){
                                                                   biWeeklyEndDate = biweeklyreimList.End_Date__c;    
                                                               } 
                                                               
                                                               
                                                               if(startdate != null && startdate.contains('-'))	{
                                                                   string[] startdatesplit = startdate.split('-');  
                                                                   if(integer.valueOf(startdatesplit[1]) == 01){
                                                                       mydate = date.valueOf(string.valueOf(integer.valueOf(startdatesplit[0])-1) + '-12' + '-01' );   
                                                                   } else {
                                                                       mydate = date.valueOf(startdatesplit[0] + '-' + string.valueOf(integer.valueOf(startdatesplit[1])-1) + '-01');
                                                                   }
                                                               }
                                                           }
       	system.debug('biWeeklyStartDate==' + biWeeklyStartDate);
        system.debug('mydate==' + mydate);
        Set<string> conCity = new set<string>();
        Set<string> conState = new set<string>();
        Set<string> conId = new set<string>();
        for (Contact conList : [SELECT Id,  Name, External_Email__c, Email,MailingCity, MailingState,  AccountId, Account.Triplog_API__c 
                                FROM Contact 
                                WHERE AccountId =: accId
                                	AND isCommunityUser__c = true 
                                	AND Deactivated_Date__c = null 
                                	AND (Role__c =: StaticValues.ROLE_DRIVER OR Role__c =: StaticValues.roleAdminDriver OR Role__c =: StaticValues.ROLE_DRIVERMANAGER)])
        {
                                    conCity.add(conList.MailingCity);
                                    conState.add(conList.MailingState);
                                    conId.add(conList.Id);
                                }
        map<string, Decimal> monthStateCityVsFuelPriceMap = new map<string, Decimal>(); 
        for(Gas_Prices__c obj_GasPrice : [SELECT id,
                                          name,
                                          City__c,
                                          State__c, 
                                          Fuel_Price__c, 
                                          Month_Year__c,
                                          Month_State_City__c 
                                          FROM Gas_Prices__c 
                                          WHERE City__c =: conCity
                                          	AND State__c =: conState
                                          	AND Month_Year__c =: mydate]) {
                                              monthStateCityVsFuelPriceMap.put(obj_GasPrice.Month_State_City__c, obj_GasPrice.Fuel_Price__c); 
                                          }
        system.debug('monthStateCityVsFuelPriceMap=='+ monthStateCityVsFuelPriceMap); 
        List<Bi_Weekly_Reimbursement__c> updatefuelPriceList = new List<Bi_Weekly_Reimbursement__c>();
        for(Bi_Weekly_Reimbursement__c biweeklyreim : [SELECT id,
                                                       name,
                                                       Month_State_City__c, 
                                                       Start_Date__c, 
                                                       Fuel_Price__c
                                                       FROM Bi_Weekly_Reimbursement__c 
                                                       WHERE (Fuel_Price__c = null or Fuel_Price__c = 0)
                                                       	AND Contact__c  =: conId 
                                                       	AND Start_Date__c =: biWeeklyStartDate
                                                       	AND End_Date__c =: biWeeklyEndDate ]) {
                                                           if(monthStateCityVsFuelPriceMap.containsKey(biweeklyreim.Month_State_City__c)) {
                                                               biweeklyreim.Fuel_Price__c = monthStateCityVsFuelPriceMap.get(biweeklyreim.Month_State_City__c);
                                                               updatefuelPriceList.add(biweeklyreim);
                                                           }
                                                       }
        if(!updatefuelPriceList.isEmpty()) {
                try{
                    update updatefuelPriceList;    
                }	catch(DmlException e) {
            }           
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Fuel Price is Updated!');
            ApexPages.addMessage(myMsg);
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No records found to Update.');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public pagereference backtoBiWkkelyReimbursement()
    {
        pagereference pg = new pagereference(urltoredirect);
        return pg;
    } 
}