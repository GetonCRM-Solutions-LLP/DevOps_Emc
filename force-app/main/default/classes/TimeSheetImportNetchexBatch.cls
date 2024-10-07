/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use for post a staytime and drivetime total to Netchex on monthly and biweekly basis.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 08 July 2020 | Sanket Goswami
 * @description: 
 * AI-000443
 */
global class TimeSheetImportNetchexBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    public string tripstartDate;
    public string tripendDate;
    public DateTime runningTime;
    public string adminEmailAdd;
    public string adminName;
    global string jsonResponse;
    global TimeSheetImportNetchexBatch(String startDate, String endDate, DateTime runTime,String emailAddress,String name) {
        tripstartDate = startDate;
        tripendDate = endDate;
        this.runningTime = runTime;
        adminEmailAdd = emailAddress;
        adminName = name;
        System.debug('tripstartDate'+tripstartDate+'tripendDate'+tripendDate);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        if(!Test.isRunningTest()){
            query =  'SELECT id,Employee_Netchex_Id__c,Code__c FROM contact WHERE (Driver_Type__c = \'Driver - Full Time\' OR Driver_Type__c = \'Driver - Part Time\')AND AccountId = \''+System.Label.ERMI_Account+'\' AND Employee_Netchex_Id__c != null AND Deactivated_Date__c = null';
        }
        else{
            query = 'SELECT id,Employee_Netchex_Id__c,Code__c FROM contact LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<ReibursementWrapper> reimbWrapperList = new List<ReibursementWrapper>();
        Map<Id, Decimal> reimbTotalTimeMap = new Map<Id, Decimal>();
        System.debug('inside execute');
        for(AggregateResult ar : [SELECT EmployeeReimbursement__r.Contact_Id__c rid, SUM(Drive_Stay_Time__c) rtotal 
                                FROM Employee_Mileage__c 
                                WHERE (EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Full Time' 
                                        OR EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c = 'Driver - Part Time') 
                                        AND EmployeeReimbursement__r.Contact_Id__r.AccountId =: System.Label.ERMI_Account
                                        AND EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c = null
                                        AND Trip_Date__c >= : Date.valueOf(tripstartDate)
                                        AND Trip_Date__c <= : Date.valueOf(tripendDate) group by EmployeeReimbursement__r.Contact_Id__c]) {
                                reimbTotalTimeMap.put((Id)ar.get('rid'), (Decimal) ar.get('rtotal')); 
        }

        for(contact currentContact : (List<contact>) scope)
        {
            ReibursementWrapper objWrapper = new ReibursementWrapper();
            objWrapper.CompanyCode = 'LIL';
            objWrapper.EntryDate = Date.valueof(tripendDate);
            objWrapper.EmployeeId = currentContact.Employee_Netchex_Id__c;
            objWrapper.GrossToNetCode = '1';
            objWrapper.TypeCode = 'R';
            if(reimbTotalTimeMap.get(currentContact.Id) == null ){
                objWrapper.HoursOrAmount = 0;
            }
            else{
                objWrapper.HoursOrAmount = (reimbTotalTimeMap.get(currentContact.Id)).divide(60, 2);
            }
            
            reimbWrapperList.add(objWrapper);
        }

        String jsonList = JSON.serialize(reimbWrapperList);
        System.debug('====='+jsonList);
        if(!reimbWrapperList.isEmpty()){
            jsonResponse = timesheetImport(jsonList, runningTime);
        }   
    }

    global void finish(Database.BatchableContext BC) {
        EmailTemplate templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Netchex_Report' Limit 1];
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        List<String> toAddress = new List<String>();
        List<String> bccAddress = new List<String>();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setFileName('Bi-weekly Time and Attendance Payment Report.xls');
        Netchex_Email__c customSetting  = Netchex_Email__c.getValues('TimeSheetImportNetchexBatch');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String newemailBody = templateId.HtmlValue;
        Date todayDate = system.today();
        newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        newemailBody = newemailBody.replace('{Contact.Name}', adminName);
        newemailBody = newemailBody.replace('{!reportname}', 'Bi-weekly Time and Attendance Payment');
        newemailBody = newemailBody.replace('{!todaydate}', todayDate.month()+'/'+todayDate.day()+'/'+todayDate.year());
        toAddress.add(adminEmailAdd);
        string header ='Success'+'\t'+'EmployeeId'+'\t'+'CompanyCode'+'\t'+ 'EntryDate'+'\t'+'TypeCode'+'\t'+'HoursOrAmount'+'\t'+'Message'+' \n';
        String finalstr = header;
        if(customSetting != null) {
            if(Utils.CheckNulls(customSetting.BCC_Address__c))   {
                bccAddress = Utils.SplitStringToList(customSetting.BCC_Address__c, ',');
            }
        }
        if(jsonResponse != null && jsonResponse != ''){
            List<NetchexJsonDeserialize> jsonDsc = NetchexJsonDeserialize.parse(jsonResponse);
            for(NetchexJsonDeserialize objJson : jsonDsc){
                String Recordstring = objJson.IsSuccess+'\t'+objJson.ObjectInstance.EmployeeId+'\t'+objJson.ObjectInstance.CompanyCode+'\t'+objJson.ObjectInstance.EntryDate+'\t'+objJson.ObjectInstance.TypeCode+'\t'+objJson.ObjectInstance.HoursOrAmount+'\t'+objJson.Messages+'\n';
                finalstr = finalstr + Recordstring;
            }
            blob excel = blob.valueOf(finalstr);
            attach.setBody(excel);
            
            messaging.singleEmailMessage email = Utils.CreateEmail('Bi-weekly Time and Attendance Payment Report',newemailBody,toAddress,null,bccAddress,null);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            email.setOrgWideEmailAddressId(owea.get(0).Id);
            emails.add(email);
            if(!emails.isEmpty() && !Test.IsRunningTest() && customSetting.Send_Email_From_Code__c == true) {                    
                Messaging.SendEmailResult [] result = Messaging.sendEmail(emails, false);
            }
        }
    }

    webservice static string timesheetImport(String body, DateTime runningTime ){
        String jsonBody = '';
        try {
            List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();
            Tripslog__c obj = new Tripslog__c();
            obj.Body__c = body;
            obj.Endpoint__c = StaticValues.Netchex_Timesheet_Connect;
            obj.Total_Trips__c = 0;
            obj.Total_Mileages__c = 0;
            obj.Log_Time__c = runningTime;
            obj.Response__c = 'TimeSheetImportNetchexBatch';
            HttpResponse res;
            if(!Test.isRunningTest()) {
                res = ApiCalloutUtility.executeCallout(StaticValues.Netchex_APIKey,'POST',StaticValues.Netchex_Timesheet_Connect,'HeaderBasic',body);
                system.debug('res'+res);
                obj.Response_Data__c = res.getBody();
                jsonBody = res.getBody();
                obj.Status__c = res.getStatusCode() == 200 ? 'Success' : 'Fail';
            }
          
            obj_Tripslog_list.add(obj);
            if(!obj_Tripslog_list.isEmpty()) {
                insert obj_Tripslog_list;
            }
        } catch(System.CalloutException er) {
            System.debug('CalloutException'+er);
        }
        return jsonBody;
    }

    public class ReibursementWrapper{
        public string CompanyCode { get; set; }
        public datetime EntryDate { get; set; }
        public string EmployeeId { get; set; }
        public string GrossToNetCode { get; set; }
        public string TypeCode { get; set; }
        public double HoursOrAmount { get; set; }
    }
}