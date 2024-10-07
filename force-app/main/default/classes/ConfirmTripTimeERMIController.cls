/**
* @Author: GetonCRM Solutions LLP
* @Description: This class is use for checking driver was confirm or error biweekly reimbursement for ERMI account.Based on checkbox value we will redirect on paege.
* @Modification logs
* ========================================================================================================================
* @Date: 20 January 2022 | Sanket Goswami
* @description: EMC-238
*/
public with sharing class ConfirmTripTimeERMIController {
    public static String contactId;
    public string mileageDetailWrapper {get; set;}
    public OrgWideEmailAddress[] owea;
    public ConfirmTripTimeERMIController (){
        contactId = ApexPages.currentPage().getParameters().get('id');
        if(contactId != null){
        }
        try {
            owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com' ];
        }  catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
    }
    /*This method is used to display biweekly reimbursement data of last completed biweekly reimbursment period */
    @AuraEnabled
    public static string getMileageData(String contactId){
        List<MileageWrapper> mileageWrapList = new List<MileageWrapper >();
        try {
            for(Bi_Weekly_Reimbursement__c  biweek : [SELECT id, name, Confirm_Hours__c, Error_Hours__c,
                                                      Total_Time__c, Total_Drive_Time__c,Count_Error_Check__c, 
                                                      Total_Stay_Time__c, Total_Approved_Pending_Mileage__c,
                                                      Contact__r.FirstName, Contact_Email__c, Contact__r.Role__c, Contact__r.Driver_Type__c 
                                                      FROM Bi_Weekly_Reimbursement__c 
                                                      WHERE Contact__c =: contactId 
                                                      AND Start_Date__c != null 
                                                      AND End_Date__c != null 
                                                      AND End_Date__c <= TODAY 
                                                      WITH SECURITY_ENFORCED
                                                      order by End_Date__c desc limit 1 ]){
                                                          MileageWrapper milWrap = new MileageWrapper(); 
                                                          milWrap.biWeekId = biweek.Id;   
                                                          milWrap.biWeekPayperiod = biweek.Name;  
                                                          milWrap.driverName = biweek.Contact__r.FirstName;
                                                          milWrap.driverEmail = biweek.Contact_Email__c ;    
                                                          milWrap.mileage = biweek.Total_Approved_Pending_Mileage__c ;
                                                          milWrap.confirmCheck = biweek.Confirm_Hours__c;
                                                          milWrap.errorCheck = biweek.Error_Hours__c;
                                                          milWrap.driverRole = biweek.Contact__r.Role__c;
                                                          milWrap.driverType = biweek.Contact__r.Driver_Type__c;  /*Added by Megha */                               
                                                          milWrap.driveTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweek.Total_Drive_Time__c));
                                                          milWrap.stayTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweek.Total_Stay_Time__c));
                                                          milWrap.totalTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweek.Total_Time__c));
                                                          milWrap.countErrorCheck = biweek.Count_Error_Check__c != null ? Integer.valueOf(biweek.Count_Error_Check__c) : 0;
                                                          mileageWrapList.add(milWrap);
                                                      }
        }  catch(System.QueryException qe) {
        }        
        String wrapjson = JSON.serialize(mileageWrapList);
        return wrapjson;
    }
    /*This method is used for update checkbox value and send confirm email to driver if he confirm the data */
    //@RemoteAction
    @AuraEnabled
    public static string updateBiWeekData(String biweekData)
    {
        List<Bi_Weekly_Reimbursement__c> updateBiweekList = new List<Bi_Weekly_Reimbursement__c >();
        map<id,Bi_Weekly_Reimbursement__c > conMap = new map<id,Bi_Weekly_Reimbursement__c >();
        if(biweekData != null)
        {
            List<MileageWrapper> biweekWrapUpdateList = new List<MileageWrapper>();
            biweekWrapUpdateList = (List<MileageWrapper>)Json.deserialize(biweekData,List<MileageWrapper>.class);
            
            for(MileageWrapper conwrap : biweekWrapUpdateList ){
                System.debug('conwrap'+conwrap);
                Bi_Weekly_Reimbursement__c biweek = new Bi_Weekly_Reimbursement__c ();
                biweek.Id = Id.valueOf(conwrap.biWeekId) ;
                biweek.Confirm_Hours__c = conwrap.confirmCheck ; 
                biweek.Error_Hours__c = conwrap.errorCheck ;
                biweek.Count_Error_Check__c = conwrap.countErrorCheck ;
                if(biweek.Confirm_Hours__c == true){
                    biweek.Confirm_Hours_Time__c = System.Now();
                    biweek.Status__c = 'Approved';
                    biweek.Approved_Date__c = System.today();
                    Integer countError = 0;
                    sendConfirmEmail(conwrap.driverEmail,conwrap.driverName,conwrap.biWeekPayperiod,conwrap.mileage,conwrap.DriveTime,conwrap.StayTime,conwrap.TotalTime,countError,conwrap.driverType);
                }
                updateBiweekList.add(biweek );                
            }
        }
        conMap.putall(updateBiweekList);
        if(conMap.size() > 0){            
            update conMap.values();
        }        
        return 'Success';
    }
    /*This method is used to send a email to driver and admin when he click on confirm or error checkbox */
    public static void sendConfirmEmail (String conEmail,String driverName,String biweekName,Decimal mileage,String driveTime,String stayTime,String totalTime,Integer countError,String driverType){
        List<Messaging.SingleEmailMessage> emailist = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        List<String> bccAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        EmailTemplate templateId;
        String newemailBody;
        String subject;
        try {
            if(countError == 0 && driverType == 'Driver - Salary'){    
                templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Ermi_Mileage_Correct' Limit 1];
                ccAddress.add(System.Label.ErmiAdminAlexis); 
                ccAddress.add(System.Label.ErmiAdminConnie); 
            } else if(countError == 0 && driverType != 'Driver - Salary'){
                templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Ermi_Time_And_Mileage_Correct' Limit 1];
                ccAddress.add(System.Label.ErmiAdminAlexis); 
                ccAddress.add(System.Label.ErmiAdminConnie);
                bccAddress.add(System.Label.ErmibccAddress);
            } else if(countError == 1 || countError == 2 || countError == 3) {
                templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Ermi_Error_Count_1' Limit 1];                
                if(countError == 1){
                    subject = (templateId.Subject).replace('{count}', '1st');
                } else if (countError == 2){
                    subject = (templateId.Subject).replace('{count}', '2nd');
                } else {
                    subject = (templateId.Subject).replace('{count}', '3rd');
                    templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Ermi_Error_Count_2' Limit 1];
                    bccAddress.add(System.Label.DriverServicesEmail);
                    bccAddress.add(System.Label.ErmibccAddress);
                    ccAddress.add(System.Label.ErmiAdminAlexis); 
                    ccAddress.add(System.Label.ErmiAdminConnie);
                }
                bccAddress.add(System.Label.CountError1Ermi);            
            } else if(countError == 4 ) {
                /*templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'Ermi_Error_Count_2' Limit 1];
                bccAddress.add(System.Label.DriverServicesEmail);
                bccAddress.add(System.Label.ErmibccAddress);
                ccAddress.add(System.Label.ErmiAdminAlexis); 
                ccAddress.add(System.Label.ErmiAdminConnie);*/
            }
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        toAddress.add(conEmail);
        newemailBody = templateId.HtmlValue;
        if(countError != 4 && driverType != 'Driver - Salary'){
            String htmlTemplate = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                + mileage +'</td><td style="border:2px solid black;">'
                + driveTime+'</td><td style="border:2px solid black;">' 
                + stayTime+'</td><td style="border:2px solid black;">'
                + totalTime +'</td>'                         
                +'</tr>';
            
            newemailBody = newemailBody.replace('{tableDynamicData}', htmlTemplate);
            newemailBody = newemailBody.replace('{!BiweekName}', biweekName);
        } else if(countError != 4 && driverType == 'Driver - Salary'){
            String htmlTemplate = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                + mileage +'</td>'                                    
                +'</tr>';
            newemailBody = newemailBody.replace('{tableDynamicData}', htmlTemplate);
            newemailBody = newemailBody.replace('{!BiweekName}', biweekName);
        }
        newemailBody = newemailBody.replace('{!DriverName}', driverName);        
        newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        messaging.singleEmailMessage email;
        if(countError == 0){
            email = Utils.CreateEmail(templateId.Subject,newemailBody,toAddress,ccAddress,bccAddress,null);
        }  else if(countError == 1 || countError == 2 || countError == 3 || countError == 4){
            email = Utils.CreateEmail(subject,newemailBody,toAddress,ccAddress,bccAddress,null);
        } 
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        email.setOrgWideEmailAddressId(owea[0].Id);       
        emailist.add(email);
        SendEmail__c  sendEmailObj = SendEmail__c.getValues('ConfirmTripTimeERMIController');
        if(emailist.size() > 0 && !Test.isRunningTest() && sendEmailObj.Send_email_from_code__c == true){
            Messaging.SendEmailResult [] result = Messaging.sendEmail(emailist, false);
        }        
    }
    @AuraEnabled
    public static void sendErrorEmail (String conEmail,String driverName,String biweekName,Decimal mileage,String driveTime,String stayTime,String totalTime,Integer countError,String driverType){
        if(countError != null ){
            sendConfirmEmail(conEmail,driverName,biweekName,mileage,driveTime,stayTime,totalTime,countError,driverType);
        }
    }
    
    @AuraEnabled
    public static String deleteTripsForErmi (String contactId,String startdate,String enddate){   
        delete [select id from Employee_Mileage__c where Trip_Date__c >=: Date.parse(startdate) AND Trip_Date__c <=: Date.parse(enddate) AND Trip_Status__c = 'Not Approved Yet' AND EmployeeReimbursement__r.Contact_Id__c =: contactId ];
        return 'success';
    }
    //This method is use for sync trips for Ermi account.When driver has any issue on synced trips then this method is clicked.
    @AuraEnabled
    public static String syncTripsForErmi (String contactId,String startdate,String enddate){
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        if( startdate != null && enddate != null && contactId != null){
            set<string> monthList = new set<String>();
            String contactName;
            String contactEmail;
            if(startdate.contains('/')) {
                list<String> lstSplitDate = startdate.split('/');
                monthList.add(lstSplitDate[0]+'-'+ lstSplitDate[2]); 
            }
            Id reimId;
            if(monthList.size() > 0) {
                try {
                    for(Employee_Reimbursement__c reim : [SELECT id 
                                                          FROM Employee_Reimbursement__c 
                                                          WHERE Month__c IN: monthList 
                                                          AND Contact_Id__c =: contactId 
                                                          WITH SECURITY_ENFORCED]){
                                                              reimId = reim.ID;
                                                          }
                    for(Bi_Weekly_Reimbursement__c bireim : [SELECT id,name,Contact__r.FirstName,
                                                             Start_Date__c, End_Date__c, 
                                                             Contact__r.External_Email__c, 
                                                             Contact__c, MPG__c, Maintenance_and_Tires__c, 
                                                             Fuel_Price__c, Contact__r.Account.Triplog_API__c
                                                             FROM Bi_Weekly_Reimbursement__c 
                                                             WHERE Start_Date__c =: Date.parse(startdate)
                                                             AND End_Date__c =: Date.parse(enddate)
                                                             AND Contact__c =: contactId 
                                                             WITH SECURITY_ENFORCED ]){
                                                                 contactName = bireim.Contact__r.FirstName;
                                                                 contactEmail = bireim.Contact__r.External_Email__c;
                                                                 if(!Test.isRunningTest() && reimId != null){
                                                                     date sd = date.parse(startdate);
                                                                     date ed = date.parse(enddate);
                                                                     GetTripCalloutforCommute.GetTripCalloutForCommuteMileage(reimId, bireim.Contact__r.External_Email__c, bireim.Contact__c, String.valueof(sd), String.valueof(ed), String.valueOf(bireim.Fuel_Price__c), String.valueOf(bireim.MPG__c), String.valueOf(bireim.Maintenance_and_Tires__c), bireim.Contact__r.Account.Triplog_API__c, '' ,false, 'Business',true,bireim.Id);
                                                                 }
                                                             } 
                } catch(Exception qe) {
                    System.debug(qe.getMessage());
                }                
            }
            List<Messaging.SingleEmailMessage> emailist = new List<Messaging.SingleEmailMessage>();
            EmailTemplate templateId;
            EmailTemplate adminTemplateId;
            String newemailBody;
            List<String> toAddress = new List<String>();
            try {
                templateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'SendDriverConfirmTA' Limit 1];
                adminTemplateId = [SELECT Id, Subject,HtmlValue, body FROM EmailTemplate WHERE developerName = 'SendAdminConfirmTA' Limit 1];
            } catch(System.QueryException qe) {
            }
            if(templateId != null){
                newemailBody = templateId.HtmlValue;
                String subjectModify;
                subjectModify = templateId.Subject;
                if(contactName != null){
                    newemailBody = newemailBody.replace('{!ContactName}', contactName) ;
                    subjectModify = subjectModify.replace('{!ContactName}', contactName);
                }
                toAddress.add(contactEmail);
                newemailBody = newemailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                messaging.singleEmailMessage email = new messaging.singleEmailMessage();
                email = Utils.CreateEmail(subjectModify,newemailBody,toAddress,null,null,null);                
                email.setOrgWideEmailAddressId(owea[0].Id);  
                emailist.add(email);  
            }                      
            
            String newAdminEmailBody;
            String subjectModify;
            if(adminTemplateId != null){
                newAdminEmailBody = adminTemplateId.HtmlValue;
                newAdminEmailBody = newAdminEmailBody.replace('{!ContactName}', 'Alexis');
                newAdminEmailBody = newAdminEmailBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                subjectModify = adminTemplateId.Subject;
                if(contactName != null){
                    subjectModify = subjectModify.replace('{!DriverName}', contactName);
                } 
                messaging.singleEmailMessage email2 = new messaging.singleEmailMessage();
                List<String> toAddressDriver = new List<String>();
                toAddressDriver.add(System.Label.ErmiAdminAlexis);
                email2 = Utils.CreateEmail(subjectModify,newAdminEmailBody,toAddressDriver,null,null,null);
                email2.setOrgWideEmailAddressId(owea[0].Id);  
                emailist.add(email2); 
            }                                   
            SendEmail__c  sendEmailObj = SendEmail__c.getValues('ConfirmTripSyncErmi'); 
            if(emailist.size() > 0 && !Test.isRunningTest() && sendEmailObj.Send_email_from_code__c == true){
                Messaging.SendEmailResult [] result2 = Messaging.sendEmail(emailist, false);
            }                     
        }
        return 'sucess';
    }
    @AuraEnabled
    public static String reimMileages (String biweekReim){
        List<EmployeeMileages> mileages = new List<EmployeeMileages>();
        for(Employee_Mileage__c miles : [SELECT id,Name,Trip_Status__c,Original_Origin_Name__c,Original_Destination_Name__c,Trip_Date__c,Trip_Origin__c,Trip_Destination__c,Bi_Weekly_Reimbursement__c,
                                         Approved_Date__c,Mileage__c,Variable__c,EmployeeReimbursement__c,TimeZone__c,Tag__c,
                                         Bi_Weekly_Reimbursement__r.month__c,Bi_Weekly_Reimbursement__r.Total_Pending__c,Stay_Time__c,
                                         Bi_Weekly_Reimbursement__r.Total_Mileage__c,Bi_Weekly_Reimbursement__r.Contact__c,Driving_Time__c,Total_Time__c,
                                         CreatedDate,Rejected__c,Origin_Name__c,Tracing_Style__c,StartTime__c,EndTime__c,Mileage_Lock_Date__c,
                                         Day_Of_Week__c,Destination_Name__c,Bi_Weekly_Reimbursement__r.Contact__r.External_Email__c,Bi_Weekly_Reimbursement__r.Half_Fixed_Amount__c, 
                                         Maintenance_and_Tires__c,Fuel_price__c,Bi_Weekly_Reimbursement__r.Total_Variable_Rate__c,ConvertedStartTime__c,ConvertedEndTime__c, 
                                         Bi_Weekly_Reimbursement__r.Total_Rejected__c,Notes__c,Bi_Weekly_Reimbursement__r.Mileage_Lock_Date__c,Activity__c,
                                         EmployeeReimbursement__r.Contact_Id__r.Account.Bi_Weekly_Pay_Period__c,High_Risk_Mileage__c
                                         FROM Employee_Mileage__c 
                                         WHERE Bi_Weekly_Reimbursement__c =: biweekReim order by ConvertedStartTime__c asc]){
                                             mileages.add(BiWeeklyWrapperUtils.getMileagesOfReimbursement(miles));
                                         }
        System.debug(JSON.serialize(mileages));
        return JSON.serialize(mileages);
    }
    
    public class MileageWrapper {
        public string biWeekId { get; set; }
        public string biWeekPayperiod {get; set;}
        public Decimal mileage { get; set; }
        public string driveTime { get; set; }
        public string stayTime { get; set; }        
        public string totalTime { get; set; }
        public string driverEmail {get; set;}
        public string driverName {get; set;}
        public string driverRole {get; set;}
        public string driverType {get;set;} /*Added by Megha */ 
        public Boolean confirmCheck { get; set; }
        public Boolean errorCheck { get; set; }
        public Integer countErrorCheck { get; set; }
    }
}