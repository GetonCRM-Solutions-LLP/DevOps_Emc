/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use for post a monthly fixed amount for partime driver.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 11 August 2020 | Sanket Goswami
 * @description: 
 */
global class NetchexSalaryPartFixAmountBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    public string tripEntryDate;
    // public string tripendDate;
    public DateTime runningTime;
    global string jsonResponse;
    public string adminEmailAdd;
    public string adminName;
    public NetchexSalaryPartFixAmountBatch(DateTime runTime, String startDate, String emailAddress, String name) {
        tripEntryDate = startDate;
        // tripendDate = endDate;
        adminEmailAdd = emailAddress;
        this.runningTime = runTime;
        adminName = name;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        String query;
        if(!Test.isRunningTest()){
            query = 'SELECT Contact_Id__r.Employee_Netchex_Id__c,Contact_Id__r.Driver_Type__c,Monthly_Fixed_Amount__c,Fixed_Amount__c FROM Employee_Reimbursement__c WHERE (Contact_Id__r.Driver_Type__c = \'Driver - Part Time\')AND Contact_Id__r.AccountId = \''+System.Label.ERMI_Account+'\' AND Contact_Id__r.Employee_Netchex_Id__c != null AND Contact_Id__r.Deactivated_Date__c = null AND Month__c = \''+lastMonth+'\'';
        }
        else {
            query = 'SELECT Contact_Id__r.Employee_Netchex_Id__c,Contact_Id__r.Driver_Type__c,Monthly_Fixed_Amount__c,Fixed_Amount__c FROM Employee_Reimbursement__c';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<ReibursementWrapper> reimbWrapperList = new List<ReibursementWrapper>();
        for(Employee_Reimbursement__c reimbObj : (List<Employee_Reimbursement__c>) scope)
        {
            //string dateOfMonth = Date.Today().Year()+'-'+(Date.Today().Month()-1)+'-30';
            ReibursementWrapper objWrapper = new ReibursementWrapper();
            objWrapper.CompanyCode = 'LIL';
            objWrapper.EntryDate = Date.valueof(tripEntryDate);
            objWrapper.EmployeeId = reimbObj.Contact_Id__r.Employee_Netchex_Id__c;
            objWrapper.GrossToNetCode = '1';
            objWrapper.TypeCode = 'EXR';
            if(reimbObj.Monthly_Fixed_Amount__c == null){
                objWrapper.HoursOrAmount = 0;
            }
            else {
                objWrapper.HoursOrAmount = reimbObj.Monthly_Fixed_Amount__c;
            }
            reimbWrapperList.add(objWrapper);
        }
        String jsonList = JSON.serialize(reimbWrapperList);
        System.debug('====='+jsonList);
        if(!reimbWrapperList.isEmpty()){
            jsonResponse = timesheetImport(jsonList, runningTime );
        }  
    }

    global void finish(Database.BatchableContext BC) {
        EmailTemplate templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Netchex_Report' Limit 1];
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        List<String> toAddress = new List<String>();
        List<String> bccAddress = new List<String>();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setFileName('Monthly Part Time Fixed Amount Payment Report.xls');
        Netchex_Email__c customSetting  = Netchex_Email__c.getValues('NetchexSalaryPartFixAmountBatch');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String newemailBody = templateId.HtmlValue;
        Date todayDate = system.today();
        newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        newemailBody = newemailBody.replace('{Contact.Name}', adminName);
        newemailBody = newemailBody.replace('{!reportname}', 'Monthly Part Time Fixed Amount Payment Report');
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
            
            messaging.singleEmailMessage email = Utils.CreateEmail('Monthly Part Time Fixed Amount Payment Report',newemailBody,toAddress,null,bccAddress,null);
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
            obj.Response__c = 'NetchexSalaryPartFixAmountBatch';
            if(!Test.isRunningTest()) {
                HttpResponse res = ApiCalloutUtility.executeCallout(StaticValues.Netchex_APIKey,'POST',StaticValues.Netchex_Timesheet_Connect,'HeaderBasic',body);
                system.debug('res'+res);
                obj.Response_Data__c = res.getBody();
                obj.Status__c = res.getStatusCode() == 200 ? 'Success' : 'Fail';
                jsonBody = res.getBody();
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