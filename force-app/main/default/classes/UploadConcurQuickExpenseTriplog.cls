/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This class for post call in triplog and send total mileages.This class is called by Concer button on reimbursement object.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 05 June 2020 | Sanket Goswami
 * @description: 
 * AI-000435
 */
global class UploadConcurQuickExpenseTriplog {
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    Webservice static String postTotalReimbursement(Id accid,String empReMonth,String contactEmail,String totalReimburement){
        String resStatus;
        List<Account> accountList = [SELECT id,Triplog_API__c  FROM Account WHERE Triplog_API__c != null AND Id =: accid];
        Contact ConLst;
        if(contactEmail!=null){
            ConLst =[SELECT id from Contact WHERE email =:contactEmail];
        }
        String apiToken = accountList[0].Triplog_API__c;
        String baseURL = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        baseURL = (baseURL + '/api/uploadConcurQuickExpense');
        String todayDate = String.valueof(system.today().year()+'-'+date.today().addmonths(-1).month()+'-'+system.today().day());
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('email', contactEmail);
        gen.writeStringField('date', todayDate);
        if(totalReimburement == null){
          gen.writeNumberField('amount', 0);
          }else{
          gen.writeNumberField('amount', decimal.valueof(totalReimburement));
          }
        
        gen.writeStringField('expenseTypeCode','01466');
        gen.writeEndObject();
        String jsonstringconvert = gen.getAsString();

        List<Tripslog__c> objTripsloglist = new List<Tripslog__c>();
        Tripslog__c obj = new Tripslog__c();
        obj.Body__c = jsonstringconvert;
        obj.Endpoint__c = baseURL;
        obj.Total_Trips__c = 0;
        obj.Total_Mileages__c = 0;
        obj.Response__c = 'UploadConcurQuickExpenseTriplog';
        obj.Contact__c=ConLst.Id;
        try {
            if(!Test.isRunningTest()) {
                HttpResponse res = ApiCalloutUtility.executeCallout(apiToken,'POST',baseURL,'',jsonstringconvert);
                system.debug('res'+res);
                obj.Response_Data__c = res.getBody();
                obj.Status__c = res.getStatusCode() == 200 ? 'Success' : 'Fail';
                obj.Deactivation_Flow__c = res.getStatusCode() == 200 ? true : false;
                List<String> resData = obj.Response_Data__c.split(':');
                resStatus = resData[1].substringBetween('"', '"}');
            }
        } catch(System.CalloutException er) {
            resStatus = 'Fail to send Expense to triplog';
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
        }
        objTripsloglist.add(obj);
        if(!objTripsloglist.isEmpty()) {
            insert objTripsloglist;
        }
        return resStatus;
    }

    Webservice static void postTotalReimbursementForAllUser(Id accid){
        List<Account> accountList = [SELECT id,Triplog_API__c  FROM Account WHERE Triplog_API__c != null AND Id =: accid];
        String apiToken = accountList[0].Triplog_API__c;
        String baseURL = !MLOGACCOUNT.Contains(apiToken) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
        baseURL = (baseURL + '/api/uploadConcurQuickExpense');
        
        String lastMonth = Utils.fetchMonths(1, 0)[0]; 
        List<Tripslog__c> objTripsloglist = new List<Tripslog__c>();
        String todayDate = String.valueof(system.today().year()+'-'+date.today().addmonths(-1).month()+'-'+system.today().day());
        for(Employee_Reimbursement__c objReimbursemnt : [SELECT Id,Month__c,Total_Monthly_Reimbursement__c,Contact_Id__r.External_Email__c ,Contact_Id__c
                                                            FROM Employee_Reimbursement__c 
                                                            WHERE Month__c =: lastMonth 
                                                            AND Contact_Id__r.AccountId =: accid limit 9999
                                                        ]){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('email', objReimbursemnt.Contact_Id__r.External_Email__c );
            gen.writeStringField('date', todayDate);
          //  gen.writeStringField('amount', String.valueOf(objReimbursemnt.Total_Monthly_Reimbursement__c));
            if(objReimbursemnt.Total_Monthly_Reimbursement__c == null){
                gen.writeNumberField('amount', 0);
            }else{
                gen.writeNumberField('amount', objReimbursemnt.Total_Monthly_Reimbursement__c);
            }
            gen.writeStringField('expenseTypeCode','01466');
            gen.writeEndObject();
            String jsonstringconvert = gen.getAsString();
    
            Tripslog__c obj = new Tripslog__c();
            obj.Body__c = jsonstringconvert;
            obj.Endpoint__c = baseURL;
            obj.Total_Trips__c = 0;
            obj.Total_Mileages__c = 0;
            obj.Response__c = 'UploadConcurQuickExpenseTriplog';
            obj.Contact__c=objReimbursemnt.Contact_Id__c;
            try {
                if(!Test.isRunningTest()) {
                    HttpResponse res = ApiCalloutUtility.executeCallout(apiToken,'POST',baseURL,'',jsonstringconvert);
                    system.debug('res'+res);
                    obj.Response_Data__c = res.getBody();
                    obj.Status__c = res.getStatusCode() == 200 ? 'Success' : 'Fail';
                    obj.Deactivation_Flow__c = res.getStatusCode() == 200 ? true : false;
                }
            } catch(System.CalloutException er) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
            }
            objTripsloglist.add(obj);
        }
        
        if(!objTripsloglist.isEmpty()) {
            insert objTripsloglist;
        }
    }
    /*Webservice static void postTotalReimbursementForAllUser(){
        String apiToken = System.label.Triplog_Concer_Expense_API;
        String month = WrapperUtils.getLastMonthValue(-1);
        List<reimbursementWrapper> reimbursementWrapperList = new List<reimbursementWrapper>();
        for(Employee_Reimbursement__c reim : [SELECT id,Contact_Email__c, Month__c, Total_Monthly_Reimbursement__c FROM Employee_Reimbursement__c WHERE Month__c =: month]){
            reimbursementWrapper objReimbursementWrap = new reimbursementWrapper();
            objReimbursementWrap.email = reim.Contact_Email__c;
            objReimbursementWrap.month = reim.Month__c;
            objReimbursementWrap.amount = String.valueOf(reim.Total_Monthly_Reimbursement__c);
            reimbursementWrapperList.add(objReimbursementWrap);
        }
        String body = JSON.serialize(reimbursementWrapperList);
        
        Http postHTTP = new Http();
        HttpRequest postReq = new HttpRequest(); 
        HttpResponse postRes = new HttpResponse();
        postReq.setEndpoint(StaticValues.Concer_Quick_Expense);
        postReq.setMethod('POST');
        postReq.setTimeout(120000);
        postReq.setBody(body);
        postReq.setHeader('Content-Type', 'application/json');
        postReq.setHeader('Authorization', 'apikey '+ apiToken);

        if(!Test.isRunningTest()){
            postRes = postHTTP.send(postReq);
                if(postRes.getStatusCode() == 200) {
                    System.debug('postRes.getStatusCode()'+postRes.getStatusCode());
                }
        }   else {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
        }
    }

    public class reimbursementWrapper{
        public string email { get; set; }
        public string month { get; set; }
        public string amount { get; set; }
    }*/
}