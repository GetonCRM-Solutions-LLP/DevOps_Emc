public class EmailChangeNotification {

    public static void changedEmailNotification(List<Contact> conlist, Map<ID,Contact> oldConMap){

        For(Contact con: conlist){
            if(oldconMap.containsKey(con.Id)){
                //System.debug('accId: ' + con.Account.Id);
                //System.debug('email: ' + con.Email);
                if(!Test.isRunningTest()){
                    emailChangeInMlog(con.id, oldconMap.get(con.Id).Email,false);
                }
            }
        }
    }
    private static void sleep(integer milliseconds) 
    {
            Double timeDiff = 0;
            DateTime firstTime = System.now();
            do
            {
                timeDiff = System.now().getTime() - firstTime.getTime();
            }
            while(timeDiff <= milliseconds);
    }
    public Static void sendEmailForSignInMlog(String oldEmail,String newEmail,String firstName) {
        System.debug('oldEmail: ' + oldEmail);
        System.debug('newEmail: ' + newEmail);
        System.debug('newEmail: ' + firstName);
        
        try {
            String subject;
            String htmlbody;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
            EmailTemplate objEmailTemplate = [SELECT Id, Name, developerName, subject, body,HtmlValue FROM EmailTemplate where developerName ='EmailChangeTemplateForSignInToMlog' LIMIT 1];
            subject = 'Sign Back into Mlog';
            htmlbody = objEmailTemplate.HtmlValue;
            htmlbody = htmlbody.replace('{!$Record__Prior.Email}', oldEmail);
            htmlbody = htmlbody.replace('{!$Record.Email}', newEmail);
            htmlbody = htmlbody.replace('{!$Record.FirstName}', firstName);

            String[] toAddresses = new String[] {newEmail};
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            email.setToAddresses(toAddresses);
            email.setSubject(subject);
            email.setHTMLBody(htmlbody);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    System.debug('Failed to send email: ' + result.getErrors()[0].getMessage());
                } else {
                    System.debug('Email sent successfully.');
                }
            }
        } catch (Exception e ) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }


    @future(callout=true)
    public static void emailChangeInMlog(String conId,String oldEmail ,Boolean userStatus) {
        System.debug('inside putHTTPEnableUserTriplog');
        Http h;
        HttpRequest req;
        HttpResponse res;
        String mLOGACCOUNT = System.Label.Triplog_New_URL + ',' + System.Label.Triplog_New_URL2;
        Integer maxRetries = 3;
        Integer retries = 0;

        for(Contact conObj : [SELECT id, Triplog_UserID__c, Email, Account.Id, Account.Triplog_API__c,FirstName FROM Contact WHERE id = :conId]) {
            if(conObj.Triplog_UserID__c != null && conObj.Account.Triplog_API__c != null){
                String baseURL = !mLOGACCOUNT.Contains(conObj.Account.Triplog_API__c) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeBooleanField('disabled', userStatus);
                gen.writeStringField('email', conObj.Email);
                gen.writeEndObject();
                h = new Http();
                req = new HttpRequest();
                req.setEndpoint(baseURL + '/api/users/' + conObj.Triplog_UserID__c);
                req.setMethod('PUT');
                req.setTimeout(120000);
                req.setBody(gen.getAsString());
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'apikey ' + conObj.Account.Triplog_API__c);

                while (retries < maxRetries) {
                    try {
                        
                            res = h.send(req);
                            System.debug('Response Status Code: ' + res.getStatusCode());
                            System.debug('Response Body: ' + res.getBody());
                            if (res.getStatusCode() == 200) {
                                RosterController.putHTTP(conObj.Account.Id, conObj.Email);
                                sendEmailForSignInMlog(oldEmail,conObj.Email,conObj.FirstName);
                                System.debug('User triplog status updated successfully.');
                                break;
                            } else if (res.getStatusCode() == 400) {
                                System.debug('Bad Request: ' + res.getBody());
                                break;
                            } else if (res.getStatusCode() == 401) {
                                System.debug('Unauthorized: ' + res.getBody());
                                break;
                            } else if (res.getStatusCode() == 404) {
                                System.debug('User not found: ' + res.getBody());
                                retries++;
                                if (retries >= maxRetries) {
                                    System.debug('Max retries reached. User not found: ' + conObj.Triplog_UserID__c);
                                } else {
                                    System.debug('Retrying... Attempt: ' + retries);
                                    sleep(2000); 
                                }
                            } else if (res.getStatusCode() == 500) {
                                System.debug('Internal Server Error: ' + res.getBody());
                                break;
                            } else {
                                System.debug('Unexpected error: ' + res.getStatusCode() + ' ' + res.getBody());
                                break;
                            }
                        
                    } catch (Exception e) {
                        System.debug('Exception: ' + e.getMessage());
                        break;
                    }
                }
            }
        }
    }
}