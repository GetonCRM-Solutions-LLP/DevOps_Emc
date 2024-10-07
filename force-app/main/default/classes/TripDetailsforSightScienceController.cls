public  class TripDetailsforSightScienceController {
	public static List<tripDetailWrapper> tripDetailWrapperList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public TripDetailsforSightScienceController() {
        
    }
    public static String formatedTime(Time times){
        String formattedTime;
        Integer hours = times.hour();
        String ampm = 'AM';

        if (hours >= 12) {
            if (hours > 12) {
                hours -= 12;
            }
            ampm = 'PM';
        }

        formattedTime = String.valueOf(hours) + ':' + String.valueOf(times.minute()) + ':'+String.valueOf(times.second())+' ' + ampm;

        System.debug('12-Hour Time: ' + formattedTime);
        return formattedTime;
    }
    @AuraEnabled(cacheable=true)
    public static void checkBiweeklyPayPeriod(String startDT,String endDt,String ConId){
        try {
            System.debug('startdt== '+Date.parse(startDT));
            System.debug('enddt== '+Date.parse(endDt));
            System.debug('ConId == '+ConId);
            Date StartDate =Date.parse(startDT);
            Date EndDate =Date.parse(endDt);

            Contact con =[SELECT id,FirstName,Email,AccountId,Account.Name From Contact Where Id=:ConId limit 1];
            System.debug('accid == '+ con.AccountId);
            tripDetailWrapperList = new List<tripDetailWrapper>();
            for(Employee_Mileage__c milList : [SELECT EmployeeReimbursement__r.Contact_Id_Name__c,Trip_Date__c,ConvertedStartTime__c,ConvertedEndTime__c,Trip_Status__c,Trip_Origin__c,Trip_Destination__c,EMP_Mileage__c,Approved_Date__c,Approval_Name__c
                                            FROM Employee_Mileage__c
                                            WHERE EmployeeReimbursement__r.Contact_Id__r.AccountId =: con.AccountId  AND  Trip_Date__c >= :StartDate
                                            AND Trip_Date__c <= :EndDate]){
                tripDetailWrapper objWrapper = new tripDetailWrapper();
                objWrapper.name = milList.EmployeeReimbursement__r.Contact_Id_Name__c != null ? milList.EmployeeReimbursement__r.Contact_Id_Name__c : null;
                objWrapper.TripDate = milList.Trip_Date__c != null ? milList.Trip_Date__c : null;
                objWrapper.startTime = milList.ConvertedStartTime__c != null ? milList.ConvertedStartTime__c : null;
                objWrapper.endTime = milList.ConvertedEndTime__c != null ? milList.ConvertedEndTime__c: null;
                objWrapper.status = milList.Trip_Status__c != null ? milList.Trip_Status__c : null;
                objWrapper.origin = milList.Trip_Origin__c != null ? milList.Trip_Origin__c : null;
                objWrapper.destination = milList.Trip_Destination__c != null ? milList.Trip_Destination__c : null;
                objWrapper.mileage = milList.EMP_Mileage__c != null ? milList.EMP_Mileage__c : null;
                objWrapper.ApprovalDate = milList.Approved_Date__c != null ? milList.Approved_Date__c : null;
                objWrapper.ApprovalName = milList.Approval_Name__c != null ? milList.Approval_Name__c : null;
                tripDetailWrapperList.add(objWrapper);
            }
            String Subject ;
            String HTMLbody;
            Boolean emailFalg = false;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            System.debug('inside attachment construction if block: ');
            String csv = 'Name,Trip Date,Start Time,End Time,Status,Origin,Destination,Mileage,Approval Date,Approval Name\n';
            for(tripDetailWrapper objWrapper:tripDetailWrapperList){
                string tripdate =String.valueOf(Date.newInstance(objWrapper.TripDate.year(), objWrapper.TripDate.month(), objWrapper.TripDate.day()));
                string StartTime;
                if(objWrapper.startTime!= null){
                    Time myTime =Time.newInstance(objWrapper.startTime.hour(), objWrapper.startTime.minute(), objWrapper.startTime.second(),0);

                    StartTime =formatedTime(myTime);
                }
                string endTime;
                if(objWrapper.endTime!= null){
                    Time myEndTime =Time.newInstance(objWrapper.endTime.hour(), objWrapper.endTime.minute(), objWrapper.endTime.second(),0);
                    endTime =formatedTime(myEndTime);
                }
                string origin;
                if(objWrapper.origin!= null){
                origin ='"'+objWrapper.origin+'"';
                }
                string Destination;
                if(objWrapper.destination!= null){
                Destination ='"'+objWrapper.destination+'"';
                }
                csv += objWrapper.name+ ',' + tripdate+ ',' +StartTime+ ',' +endTime+ ',' +objWrapper.status+','+origin+','+Destination+','+objWrapper.mileage+ ',' +objWrapper.approvalDate+ ',' +objWrapper.approvalName+ ',' +  '\n';
            }
            System.debug('CSV---> '+csv);
            attach.setBody(blob.valueOf(csv));
            attach.setFileName('Trip detail report.Csv');
            Subject = 'Your Trip Detail Report';
            htmlbody = '<p> Hi  '+ con.FirstName +',</p>' + ' <p>Attached is your trip detail report you requested. </p> '+'<p>Regards<Br> Driver Services,</p>'+'<p><img src="{!$Label.Driver_Forword_Logo}" alt="Image"></p>'+'<p>This email message, including any attachments are for the sole use of the intended recipient(s) and may contain confidential and privileged information. Any unauthorized review, use disclosure or distribution is prohibited. If you are not the intended recipient, please contact the sender by reply e-mail and destroy all copies of the original message.</p>';
            htmlbody=htmlbody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            String RecieverEmail = con.Email;
            String[] toAddresses = new String[] {RecieverEmail};
            email.setToAddresses(toAddresses);

            email.setSubject(Subject);
            System.debug('out side the attachment creation blockx');
            email.setHTMLBody(htmlbody);
            System.debug('error flag is still false');
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
            system.debug('email result '+r)  ;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    public class tripDetailWrapper{
        public string Name { get; set; }
        public date TripDate { get; set; }
        public dateTime startTime { get; set; }
        public dateTime endTime { get; set; }
        public string status { get; set; }
        public String origin { get; set; }
        public String destination { get; set; }
        public Decimal mileage { get; set; }
        public date approvalDate { get; set; }
        public string approvalName { get; set; }
    }
}