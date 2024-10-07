/**
 * Class for fetching all webinar details that is created from salesforce.
 */

public class GoToWebinarQueueable implements Queueable,Database.AllowsCallouts{
    public static void execute(QueueableContext qc){

        List<GoTo_Webinar__c> gtowList = [Select id,Account__c,name,Description__c, Subject__c, 
                                                  Start_Time__c,End_Time__c,Webinar_Key__c  
                                              FROM GoTo_Webinar__c];

        Map<String,GoTo_Webinar__c> gotoWebinarMap = new Map<String,GoTo_Webinar__c>();

        for(GoTo_Webinar__c gtow : gtowList){
             gotoWebinarMap.put(gtow.Webinar_Key__c,gtow);
        }
        
        GoToWebinar__mdt goToWebinar = [Select id,MasterLabel, Access_Token__c,Account_Key__c,
                                                DeveloperName, Organizer_Key__c, QualifiedApiName, Refresh_Token__c, 
                                                Token_Created_Time__c, Token_Expire_Time__c,Client_Id__c, Client_Secret__c, 
                                                Authentication_Endpoint__c, Endpoint__c,Redirect_URL__c  
                                            FROM GoToWebinar__mdt
                                            WHERE MasterLabel ='G2W oAuth' LIMIT 1];
       
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        String twoYearLaterDate =  String.valueOf((System.now()).addyears(2));
        String twoYearLaterDateFormatted = twoYearLaterDate.replace(' ','T')+'Z';

        String twoYearBeforeDate =  String.valueOf((System.now()).addyears(-2));
        String twoYearBeforeDateFormatted = twoYearLaterDate.replace(' ','T')+'Z';

        String fromTime = '2022-08-01T10:00:00Z';
        String toTime = '2023-09-20T10:00:00Z';//String.valueOf(System.now());
        String page = '0';
        String size = '200';
        String endpoint = goToWebinar.Endpoint__c +'/organizers/'+ goToWebinar.Organizer_Key__c +
                            '/webinars?fromTime='+ fromTime +
                            '&toTime='+ toTime +
                            '&page='+ page +'&size='+ size;

        System.debug('endpint:'+endpoint);

        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ goToWebinar.Access_Token__c);

        try{
            httpRes = http.send(httpReq);

            System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());   
            System.debug('***Http Response**'+httpRes.getBody());
            
            if(httpRes.getStatusCode() < 300){

                String responseBody = httpRes.getBody();
                responseBody = responseBody.replace('_embedded','x_embedded');

                GoToWebinarWrapper goToWebinarWrapper = new  GoToWebinarWrapper();                     
                goToWebinarWrapper = goToWebinarWrapper.parse(responseBody);

                List<GoTo_Webinar__c> lstGoToWebinar = new List<GoTo_Webinar__c>();

                Map<String,String> keyAccountIdMap = new Map<String,String>();

                for(Account acc : [Select id,Webinar_Key__c from account where Webinar_Key__c !=null]){
                    keyAccountIdMap.put(acc.Webinar_Key__c,acc.Id);
                }

                for(GoToWebinarWrapper.Webinars singleWebinar :GoToWebinarWrapper.x_embedded.webinars){

                    if(keyAccountIdMap.containsKey(singleWebinar.webinarKey)){
                        
                        System.debug('Account Id in If'+keyAccountIdMap.get(singleWebinar.webinarKey));
                        GoTo_Webinar__c goToWebinarSingle = new GoTo_Webinar__c();

                        goToWebinarSingle.Account__c=keyAccountIdMap.get(singleWebinar.webinarKey);
                        goToWebinarSingle.Webinar_Key__c = singleWebinar.webinarKey;
                        goToWebinarSingle.Registration_URL__c = singleWebinar.registrationUrl;
                        
                        goToWebinarSingle.Subject__c = singleWebinar.subject;
                        goToWebinarSingle.Description__c = singleWebinar.description;
                        goToWebinarSingle.End_Time__c = singleWebinar.Times[0].endTime;
                        goToWebinarSingle.Start_Time__c = singleWebinar.Times[0].startTime;
                        goToWebinarSingle.Webinar_Id__c = singleWebinar.webinarID;
                        lstGoToWebinar.add(goToWebinarSingle);
                    }

                }
                
                if(lstGoToWebinar.size() > 0 ){
                    upsert lstGoToWebinar Webinar_Key__c;
                }

                Database.executeBatch(new GoToSessionPerformanceBatch(),50);

            }else{
                System.debug('error---'+httpRes.getBody());
            }
            }catch(System.Exception e){
                System.debug('sys error--'+e.getMessage()); 
            }     
        }
}