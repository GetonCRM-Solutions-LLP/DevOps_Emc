/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This batch class is use for change activity status in mlog and also send email to driver.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 08 September 2021 | Sanket Goswami
 * @description: 
 */
global class ChangeActivityInMlogEmail implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    public static final String MLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
    public string driverInfo;
    public string newActivity;
    String baseURL;
    String body;
    String conAdminID;
    Contact conObj ;
    OrgWideEmailAddress[] owea;
    List<EmailTemplate> temp ;
    
    public ChangeActivityInMlogEmail(String activity,String driverData) {
        driverInfo = driverData;
        newActivity = activity;
        body = '{"activity":'+newActivity+'}';
        owea = [select Id from OrgWideEmailAddress where Address =:'driverservices@mburse.com'];
        temp = new List<EmailTemplate>([SELECT id, Subject, body, HTMLValue FROM EmailTemplate 
                                                                    WHERE DeveloperName = 'Email_For_Update_Commute_Activity']);                                                    
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select Id from Account order by Name limit 5]);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        String rosterURL;
        List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>(); 
        TriplogPutCall__c objTriplog = TriplogPutCall__c.getValues('GetDriverData');
        List<ChangeActivityJSON2Apex> tripJson = ChangeActivityJSON2Apex.parse(driverInfo);
        for(ChangeActivityJSON2Apex objMileages : tripJson) {
            if(objMileages.adminId != null){
                conAdminID = objMileages.adminId;
            }
            if(objMileages.tripId != null && objMileages.accApi != null){
                baseURL = !MLOGACCOUNT.Contains(objMileages.accApi) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                rosterURL = baseURL + '/api/trips/'+objMileages.tripId;
                String jsonSubset;
                try {
                    if(!Test.isRunningTest() && objTriplog.TriplogPut__c == true) {
                        HttpResponse res = ApiCalloutUtility.executeCallout(objMileages.accApi,'PUT',rosterURL,'',body);
                        Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        jsonSubset = JSON.serialize(jsonMap.get('message'));
                        system.debug('jsonSubset'+jsonSubset);
                    }
                } catch(System.CalloutException er) {
                }
            }
        }
       
        if(!String.isBlank(conAdminID) || !String.isEmpty(conAdminID)){
            conObj = [SELECT id,Name FROM Contact WHERE id =: conAdminID LIMIT 1];
        }
        for(ChangeActivityJSON2Apex objMileages : tripJson) {

            decimal tripMileage;
            if(newActivity == 'Commute' && decimal.valueof(objMileages.actualMileage) >= 30){
             tripMileage = decimal.valueof(objMileages.actualMileage) - 30;
            } else if(newActivity == 'Commute'){
                tripMileage = 0;
            } else if (newActivity == 'Business'){
                tripMileage = decimal.valueof(objMileages.actualMileage);
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            String[] sendingTo = new String[]{objMileages.conEmail};
            mail.setToAddresses(sendingTo );
            mail.setSubject(temp[0].Subject);
            string htmlbody = '';
            htmlbody = temp[0].HTMLValue;
            htmlbody = htmlbody.replace('{!ContactFirstName}',objMileages.conName);
            htmlbody = htmlbody.replace('{!AdminName}',conObj.Name);
            htmlbody = htmlbody.replace('{tripdate}',String.valueof(objMileages.tripdate));
            htmlbody = htmlbody.replace('{oldacitivy}',objMileages.oldActivity);
            htmlbody = htmlbody.replace('{newacitivy}',newActivity);
            htmlbody = htmlbody.replace('{mileage}',String.valueof(tripMileage));
            mail.setPlainTextBody(htmlbody);
            List<String> bccaddress = new list<String>();
            bccaddress.add('driverservices@mburse.com');
            mail.setBccAddresses(bccaddress);
            mail.setHtmlBody(htmlbody);
            mail_list.add(mail);
        }
        SendEmail__c  sendEmailObj = SendEmail__c.getValues('GetDriverData');
        if((sendEmailObj!=null) && sendEmailObj.Send_email_from_code__c==true && mail_list.size()>0 && !Test.isRunningTest()) {
            Messaging.sendEmail(mail_list);  
        } 
    }
    global void finish(Database.BatchableContext BC) {

    }
}