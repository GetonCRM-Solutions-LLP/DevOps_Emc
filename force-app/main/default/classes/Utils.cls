/*
 *  @Author: GetOnCRM Solutions LLP
 *  @Createdate: 15th May 2020
 *  @Description:  Utils class for reusable methods
*/
public without sharing class Utils {
    public static Boolean RunTrigger(String objectName) {
        Configure_Trigger__c config = Configure_Trigger__c.getInstance('Default');
        return (Boolean) config.get('Enable_' + objectName);
    }

    /**
     * Method get Months in MM-YYYY format
     * @params 
     * @noOfMonths - number to get past months
     * @substitude - substitude to add (default it to 0)
     * 
     */
    public static List<String> fetchMonths(Integer noOfMonths, Integer substitude) {

        if (noOfMonths == null || noOfMonths <= 0) {
            return new List<String>();
        } else {
            List<String> months = new List<String>();
            for(Integer m = noOfMonths; m > 0; m --) {
                Date currentDate = date.today().addMonths(-1 * (m + substitude));
                months.add(  ( currentDate.Month() > 9 ? ''+ currentDate.Month() : '0' + currentDate.Month()) + '-' + currentDate.Year() );
            }
            
            return months;
        }
    }
    /**
     * Method get current Month in MM-YYYY format
     * @no-params 
     * 
     */
    public static String fetchCurrentMonth() {
        Date currentDate = date.today();
        return (currentDate.Month() > 9 ? ''+ currentDate.Month() : '0' + currentDate.Month()) + '-' + currentDate.Year();
    }

    /**
     * Method to check nulls
     * @params 
     * @param1 - value of varible
     */
    public static Boolean CheckNulls(Object param1) {
        return (param1 != null && String.valueOf(param1) != '');
    }

    /**
     * Method Split String
     * @params 
     * @param1 - String value to Split
     * @delimiter - delimiter to Split
     */
    public static List<String> SplitStringToList(String param1, String delimiter) {
        List<String> stringList = new List<String>();
        if(!param1.contains(delimiter)) return new List<String>{ param1.trim() };

        for(String s : param1.split(delimiter)) {
            stringList.add( s.trim() );
        }

        return stringList;
    }

    public static String ConvertMinuteToHours(Integer minutes){
        if(minutes > 0){
            integer days = minutes / 60 / 24 ;
            integer hours = (minutes - days * 60 * 24) / 60 ;
            integer mins = minutes - days * 60 * 24 - hours * 60 ;
            hours = hours + ( days * 24 );
            String timeSpentOnCase = hours+'h '+mins+'m';
            return timeSpentOnCase;
        }
        return '0';
    }

    public static String ConvertMinuteToDays(Integer minutes){
        if(minutes > 0){
            integer days = minutes / 60 / 24 ;
            integer hours = (minutes - days * 60 * 24) / 60 ;
            integer mins = minutes - days * 60 * 24 - hours * 60 ;
            String timeSpentOnCase = days+'d '+hours+'h '+mins+'m';
            return timeSpentOnCase;
        }
        return '0';
    }
     /**
     * Method send emails
     * @params 
     * @subject - Subject of email
     * @htmlbody - htmlbody of email
     * @toAddress - toAddress of email
     * @bccAddress - bccAddress of email
     * @CcAddress - CcAddress of email
     * @attachments - emails attachments
     * @parentId - Id of parent object record
     * @initiatedFrom - claas or trigger name
     */
    public static Messaging.SingleEmailMessage CreateEmail(String subject, String htmlbody, String[] toAddress, String[] ccAddress, String[] bccAddress, Messaging.EmailFileAttachment[] attachments) {

        if( !CheckNulls(subject) || !CheckNulls(htmlbody) || !CheckNulls(toAddress) || toAddress.isEmpty()) 
            return new Messaging.SingleEmailMessage();
        
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // Set the paramaters to the email object
        email.setSubject( subject );
        email.setToAddresses( toAddress );
        email.sethtmlBody( htmlbody );

        if(CheckNulls(attachments) && !attachments.isEmpty())
            email.setFileAttachments(attachments);
        if(CheckNulls(bccAddress) && !bccAddress.isEmpty()) {
            email.setBccAddresses(bccAddress);
        }
           
        if(CheckNulls(ccAddress) && !ccAddress.isEmpty()) {
            email.setCcAddresses(ccAddress);
        }

        return email;
    }

    public Static Email_Log__c CreateEmailLog( String subject, String htmlbody, String[] toAddress, String[] ccAddress, String[] bccAddress, String parentId, String initiatedFrom) {
        // Define the email log
        Email_Log__c log = new Email_Log__c();
        // Set the paramaters to the email log object
        log.Subject__C = subject;
        log.To_Address__c = String.join(toAddress, ';');
        log.HTML_Body__c = htmlbody;
        log.Initiated_From__c = initiatedFrom;
        log.Message_Date__c = System.Now();
        log.Status__c = 'Sent';

        if(CheckNulls(bccAddress) && !bccAddress.isEmpty()) {
            log.Bcc_Address__c = String.join(bccAddress, ';');
        }
           
        if(CheckNulls(ccAddress) && !ccAddress.isEmpty()) {
            log.cc_Address__c = String.join(ccAddress, ';');
        }
            
        if(CheckNulls(parentId)) {
            log.Related_To__c = parentId;
        }

        return log;
    }

    /**
     * Method send emails
     * @params 
     * @sobjectname - API Name of object
    **/
    public static List<String> getAllFields (String sobjectname){
        
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().SObjectType.getDescribe().fields.getMap();
  
        List<String> accessiblefields = new List<String>();
  
        for(Schema.SObjectField field : fields.values()){
            if(field.getDescribe().isAccessible())
                accessiblefields.add(field.getDescribe().getName());
        }
    
        return accessiblefields;
    }

    /**
     * Method to insert email logs
     */
    public static void SaveEmailLogs(List<Email_Log__c> emailLogs, Messaging.SendEmailResult[] result) {

        if(emailLogs.isEmpty())
            return;
            
        Integer index = 0;
        for(Messaging.SendEmailResult rr : result) {
            emailLogs.get(index).Status__c = rr.isSuccess() ? StaticValues.EMAIL_SENT : StaticValues.EMAIL_FAIL;
            index ++;
        }

        Database.insert(emailLogs, false);  
    }

    /**
     * Get Week number for date param
     */
    public static Integer weekOfMonth(Date todaysDate){
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
         
        //Calculating startWeekResidue
        Date dt = todaysDate.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(6);
        startWeekResidue = dt.daysBetween(dtFirstWeekend);
         
        //Calculating endWeekResidue
        Date dtLastWeekend = todaysDate.toStartOfWeek().addDays(-1);
        endWeekResidue = dtLastWeekend.daysBetween(todaysDate);
         
        //Counting the weeks
        weekCount = (todaysDate.day() - (startWeekResidue + endWeekResidue)) / 7;
        weekCount += (startWeekResidue > 0 ? 1 : 0 ) + ( endWeekResidue > 0 ? 1 : 0 );
        return weekCount;
    }

    /**
     * Get States List
     */
    public static List<String> FetchStates(){
        List<String> options = new List<String>();
        for(AggregateResult ar : [SELECT Count(Id), 
                                        MailingState 
                                    FROM Contact 
                                        WHERE MailingState != null 
                                        AND (Role__c = 'Driver' OR Role__c = 'Driver/Manager' OR Role__c = 'Admin/Driver') 
                                        Group By MailingState LIMIT 999]) {
            if(((String)ar.get('MailingState')).length() == 2)
                options.add((String)ar.get('MailingState'));
        }

        return options;
    }

    //String date Value Convert in to DateTime Fromat
    public Static DateTime ConvertToDateAndTime(String dateVal) {
        Datetime dateTimeOriginal = (DateTime)Json.deserialize('"'+dateVal+'"', DateTime.class);
        System.debug('dateTimeOriginal : '+dateTimeOriginal);
        return dateTimeOriginal;
    }

}