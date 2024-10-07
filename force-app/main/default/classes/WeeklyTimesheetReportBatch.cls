/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use to send email to partime and fulltime driver of ermi account and attach excel sheet of time and attenace.
 *                 Schedule it on every sunday.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 27 October 2020 | Sanket Goswami
 * @description: 
 */
global class WeeklyTimesheetReportBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public WeeklyTimesheetReportBatch() {
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
        String startDate = String.valueof(System.today()-7);
        String endDate = String.valueof(System.today());
        //String startDate = '2021-03-28';
        //String endDate = '2021-04-04';
        for(Contact conObj : (List<Contact>) scope)
        {
            sendEmailToDrivers(conObj.id,startDate,endDate,conObj.External_Email__c);
        }
    }
    global void finish(Database.BatchableContext BC) 
    {
    }
    public void sendEmailToDrivers(String id, String startDate, String endDate,String email){
        List<mileageWrapper> mileageWrapperList = new List<mileageWrapper>();
        Map<Date,String> tripdateDayMap = new Map<Date,String>(); 
        Map<Date,Double> tripdateMileageMap = new Map<Date,Double>();
        Map<Date,Decimal> tripdateDrivingTimeMap = new Map<Date,Decimal>();
        Map<Date,Decimal> tripStayTimeMap = new Map<Date,Double>();
        Map<Date,Decimal> tripTotalTimeMap = new Map<Date,Double>();
        List<Messaging.SingleEmailMessage> mails  = new List<Messaging.SingleEmailMessage>();
        string header ='Date'+'\t'+'Day'+'\t'+ 'Mileage (mi)'+'\t'+'Driving Time'+'\t'+'Stay Time'+'\t'+'Total Time'+' \n';
        String finalstr = header;
        
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
           
            newBody = newBody.replace('{Contact.Name}',objMileages.EmployeeReimbursement__r.Contact_Id__r.Name);
            tripdateDayMap.put(objMileages.Trip_Date__c, objMileages.Day_Of_Week__c);
            if(tripdateMileageMap.size() > 0 && tripdateMileageMap.containsKey(objMileages.Trip_Date__c)){
                double mileage = tripdateMileageMap.get(objMileages.Trip_Date__c);
                mileage = mileage + objMileages.Mileage__c ;
                tripdateMileageMap.put(objMileages.Trip_Date__c, mileage);
            } else {
                tripdateMileageMap.put(objMileages.Trip_Date__c, objMileages.Mileage__c);
            }

            if(tripdateDrivingTimeMap.size() > 0 && tripdateDrivingTimeMap.containsKey(objMileages.Trip_Date__c)) {
                decimal driveTime = tripdateDrivingTimeMap.get(objMileages.Trip_Date__c);
                if(objMileages.Driving_Time__c != null){
                    driveTime = driveTime + objMileages.Driving_Time__c ;
                }
                tripdateDrivingTimeMap.put(objMileages.Trip_Date__c, driveTime);
            } else {
                tripdateDrivingTimeMap.put(objMileages.Trip_Date__c, objMileages.Driving_Time__c);
            }

            if(objMileages.Stay_Time__c != null) {
                if(tripStayTimeMap.size() > 0 && tripStayTimeMap.containsKey(objMileages.Trip_Date__c)) {
                    decimal stayTime = tripStayTimeMap.get(objMileages.Trip_Date__c);
                    stayTime = stayTime + objMileages.Stay_Time__c ;
                    tripStayTimeMap.put(objMileages.Trip_Date__c, stayTime);
                } else {
                    tripStayTimeMap.put(objMileages.Trip_Date__c, objMileages.Stay_Time__c);
                }
            }

            if(objMileages.Total_Time__c != null) {
                if(tripTotalTimeMap.size() > 0 && tripTotalTimeMap.containsKey(objMileages.Trip_Date__c)) {
                    decimal totalsTime = tripTotalTimeMap.get(objMileages.Trip_Date__c);
                    totalsTime = totalsTime + objMileages.Total_Time__c ;
                    tripTotalTimeMap.put(objMileages.Trip_Date__c, totalsTime);
                } else {
                    tripTotalTimeMap.put(objMileages.Trip_Date__c, objMileages.Total_Time__c);
                }
            }               
        }
        String Recordstring;
        Integer totaldrivetime = 0;
        Double totalMileage = 0;
        Integer totalStay = 0 ;
        Integer weekTotalTime = 0;
        for(Date currentDate : tripdateDayMap.keySet())
        {
            List<String> dateSplitted = new List<String>();
            if(String.valueOf(currentDate) != null && String.valueOf(currentDate).contains('-')) {
                dateSplitted = String.valueOf(currentDate).split('-');
            }
            mileageWrapper objMileageWrap = new mileageWrapper();
            if(!dateSplitted.isEmpty()) {
                objMileageWrap.tripDate = dateSplitted[1]+'/'+dateSplitted[2]+'/'+dateSplitted[0].substring(2,4);
            }
            objMileageWrap.tripDay = tripdateDayMap.get(currentDate);
            objMileageWrap.mileage = tripdateMileageMap.get(currentDate);
            objMileageWrap.totaldrivingTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripdateDrivingTimeMap.get(currentDate)));
            objMileageWrap.totalStayTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripStayTimeMap.get(currentDate)));
            objMileageWrap.totalTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripTotalTimeMap.get(currentDate)));
            
            totaldrivetime = totaldrivetime + Integer.valueOf(tripdateDrivingTimeMap.get(currentDate));
            totalMileage = totalMileage + tripdateMileageMap.get(currentDate);
            totalStay = totalStay + Integer.valueOf(tripStayTimeMap.get(currentDate));
            weekTotalTime = weekTotalTime + Integer.valueOf(tripTotalTimeMap.get(currentDate));
            Recordstring = objMileageWrap.tripDate+'\t'+objMileageWrap.tripDay+'\t'+objMileageWrap.mileage+'\t'+objMileageWrap.totaldrivingTime+'\t'+objMileageWrap.totalStayTime+'\t'+objMileageWrap.totalTime+'\n';
            finalstr = finalstr + Recordstring;
            mileageWrapperList.add(objMileageWrap);
        }
        Recordstring = ''+'\t'+''+'\t'+totalMileage+'\t'+Utils.ConvertMinuteToHours(totaldrivetime)+'\t'+Utils.ConvertMinuteToHours(totalStay)+'\t'+Utils.ConvertMinuteToHours(weekTotalTime)+'\n';
            finalstr = finalstr + Recordstring;

        if(mileageWrapperList.size() > 0) {
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                blob excel = blob.valueOf(finalstr);
                attach.setBody(excel);
                attach.setFileName('Weekly Time Sheet Report.xls');
            messaging.singleEmailMessage Emailwithattch = new messaging.singleEmailMessage();
            String[] sendingTo = new String[]{email};
            //String[] sendingTo = new String[]{'sanket.goswami@getoncrm.com'};
            Emailwithattch.setSubject(templateId.subject);
            Emailwithattch.setHtmlBody(newBody);
            Emailwithattch.setOrgWideEmailAddressId(owea.get(0).Id);
            Emailwithattch.setToaddresses(sendingTo);
            Emailwithattch.setBccAddresses(bccAddress);
            Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            mails.add(Emailwithattch);
        }
        if(!mails.isEmpty() && !Test.IsRunningTest() && customSetting.Send_Email_From_Code__c == true) {   
            Messaging.SendEmailResult [] result = Messaging.sendEmail(mails, false);
        }
    }
    public class mileageWrapper{
        public string tripDate { get; set; }
        public string tripDay { get; set; }
        public decimal mileage { get; set; }
        public String totaldrivingTime { get; set; }
        public String totalStayTime { get; set; }
        public String totalTime { get; set; }
        public mileageWrapper(){
        }
    }
}