/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use to send email to partime and fulltime driver of ermi account and attach excel sheet of time and attenace.
 *                 Schedule it on every sunday.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 28 January 2021 | Sanket Goswami
 * @description: 
 */
global class WeeklyTimesheetForAlexis implements Database.Batchable<sObject>,Database.Stateful{
    public string header ='Name'+'\t'+'Date'+'\t'+ 'Mileage (mi)'+'\t'+'Driving Time'+'\t'+'Stay Time'+'\t'+'Total Time'+' \n';
    public string finalstr = header;
    public String startDate;
    public String endDate;
    public WeeklyTimesheetForAlexis() {
        startDate = String.valueof(System.today()-7);
        endDate = String.valueof(System.today());
        //startDate = '2021-03-28';
        //endDate = '2021-04-04';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query;
        if(!Test.isRunningTest()){
            query = 'SELECT id,name,External_Email__c FROM Contact WHERE (Driver_Type__c = \'Driver - Part Time\' OR Driver_Type__c = \'Driver - Full Time\') AND AccountId = \''+System.Label.ERMI_Account+'\'';
        }
        else {
            query = 'SELECT id,name,External_Email__c FROM Contact';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        
        for(Contact conObj : (List<Contact>) scope)
        {
            finalstr = finalstr + sendEmailToDrivers(conObj.id,startDate,endDate,conObj.Name);
        }
    }

    global void finish(Database.BatchableContext BC) 
    {
        List<Messaging.SingleEmailMessage> mails  = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Weekly_TimeSheet_Report' Limit 1];
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        String newBody = templateId.HtmlValue;
        List<String> dateSplit = new List<String>();
        List<String> dateSplit1 = new List<String>();
        if(String.valueOf(startDate) != null && String.valueOf(startDate).contains('-')) {
            dateSplit = String.valueOf(startDate).split('-');
        }
        if(String.valueOf(endDate) != null && String.valueOf(endDate).contains('-')) {
            dateSplit1 = String.valueOf(endDate).split('-');
        }
        newBody = newBody.replace('{Contact.Name}','Alexis Wright');
        newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        newBody = newBody.replace('{!startdate}',dateSplit[1]+'/'+dateSplit[2]+'/'+dateSplit[0]);
        newBody = newBody.replace('{!enddate}',dateSplit1[1]+'/'+dateSplit1[2]+'/'+dateSplit1[0]);
        Netchex_Email__c customSetting  = Netchex_Email__c.getValues('ScheduleWeeklyTimesheetReport');
        List<String> bccAddress = new List<String>();
        if(customSetting != null) {
            if(Utils.CheckNulls(customSetting.BCC_Address__c))   {
                bccAddress = Utils.SplitStringToList(customSetting.BCC_Address__c, ',');
            }
        }

        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                blob excel = blob.valueOf(finalstr);
                attach.setBody(excel);
                attach.setFileName('Weekly Time Sheet Report.xls');
            messaging.singleEmailMessage emailWithAttch = new messaging.singleEmailMessage();
            //String[] sendingTo = new String[]{email};
            String[] sendingTo = new String[]{System.Label.ErmiAdminAlexis};
            //String[] sendingTo = new String[]{'sanket.goswami@getoncrm.com'};
            emailWithAttch.setSubject(templateId.subject);
            emailWithAttch.setHtmlBody(newBody);
            emailWithAttch.setOrgWideEmailAddressId(owea.get(0).Id);
            emailWithAttch.setToaddresses(sendingTo);
            emailWithAttch.setBccAddresses(bccAddress);
            emailWithAttch.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            mails.add(emailWithAttch);
            if(!mails.isEmpty() && !Test.IsRunningTest() && customSetting.Send_Email_From_Code__c == true) {   
                Messaging.SendEmailResult [] result = Messaging.sendEmail(mails, false);
            }
    }

    public String sendEmailToDrivers(String id, String startDate, String endDate,String Name){
        List<mileageWrapper> mileageWrapperList = new List<mileageWrapper>();
        Map<Date,String> tripdateDayMap = new Map<Date,String>(); 
        Map<Date,Double> tripdateMileageMap = new Map<Date,Double>();
        Map<Date,Decimal> tripdateDrivingTimeMap = new Map<Date,Decimal>();
        Map<Date,Decimal> tripStayTimeMap = new Map<Date,Double>();
        Map<Date,Decimal> tripTotalTimeMap = new Map<Date,Double>();
        
        List<Employee_Mileage__c> milist = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c objMileages : [SELECT id,EmployeeReimbursement__r.Name,Trip_Date__c,Day_Of_Week__c, 
                                                        Mileage__c, Driving_Time__c,Origin_Name__c,
                                                        ConvertedStartTime__c, ConvertedEndTime__c, 
                                                        Stay_Time__c, EmployeeReimbursement__r.Contact_Id__c,
                                                        EmployeeReimbursement__r.Contact_Id__r.Name,Total_Time__c,
                                                        EmployeeReimbursement__r.Contact_Id__r.External_Email__c
                                                    FROM Employee_Mileage__c 
                                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                                    AND Trip_Date__c <= : Date.valueOf(endDate)
                                                    limit 9999]) {
            if( objMileages.Day_Of_Week__c != null){
                tripdateDayMap.put(objMileages.Trip_Date__c, objMileages.Day_Of_Week__c); 
            }
                        
        }

        for(AggregateResult ar : [SELECT Trip_Date__c tdate, SUM(Mileage__c) rtotal,
                                    SUM(Driving_Time__c) dtotal,
                                    SUM(Stay_Time__c) stotal,
                                    SUM(Total_Time__c) ttotal
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                    AND Trip_Date__c <= : Date.valueOf(endDate) group by Trip_Date__c ]){

                                        tripdateMileageMap.put((Date)ar.get('tdate'),(Decimal)ar.get('rtotal'));
                                         tripdateDrivingTimeMap.put((Date)ar.get('tdate'),(Decimal)ar.get('dtotal'));
                                         tripStayTimeMap.put((Date)ar.get('tdate'),(Decimal)ar.get('stotal'));
                                         tripTotalTimeMap.put((Date)ar.get('tdate'),(Decimal)ar.get('ttotal'));
        }
       
        String Recordstring;
        Integer totaldrivetime = 0;
        Double totalMileage = 0;
        Integer totalStay = 0 ;
        Integer weekTotalTime = 0;
        for(Date currentDate : tripdateDayMap.keySet())
        {
            mileageWrapper objMileageWrap = new mileageWrapper();
            objMileageWrap.tripDay = tripdateDayMap.get(currentDate);
            objMileageWrap.mileage = tripdateMileageMap.get(currentDate);
            objMileageWrap.totaldrivingTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripdateDrivingTimeMap.get(currentDate)));
            objMileageWrap.totalStayTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripStayTimeMap.get(currentDate)));
            objMileageWrap.totalTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripTotalTimeMap.get(currentDate)));
            
            totaldrivetime = totaldrivetime + Integer.valueOf(tripdateDrivingTimeMap.get(currentDate));
            totalMileage = totalMileage + tripdateMileageMap.get(currentDate);
            if(Integer.valueOf(tripStayTimeMap.get(currentDate)) != null){
                totalStay = totalStay + Integer.valueOf(tripStayTimeMap.get(currentDate));
            }
            weekTotalTime = weekTotalTime + Integer.valueOf(tripTotalTimeMap.get(currentDate));
            mileageWrapperList.add(objMileageWrap);
        }
        return Recordstring = Name+'\t'+startDate+' to '+endDate+'\t'+totalMileage+'\t'+Utils.ConvertMinuteToHours(totaldrivetime)+'\t'+Utils.ConvertMinuteToHours(totalStay)+'\t'+Utils.ConvertMinuteToHours(weekTotalTime)+'\n';
    }

    public class mileageWrapper{
        public string tripDay { get; set; }
        public decimal mileage { get; set; }
        public String totaldrivingTime { get; set; }
        public String totalStayTime { get; set; }
        public String totalTime { get; set; }
        public mileageWrapper(){
        }
    }
}