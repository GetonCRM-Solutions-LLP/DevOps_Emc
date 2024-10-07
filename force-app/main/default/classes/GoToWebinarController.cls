/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : 
 * 1.This class is called from GoToWebinarQueueable
 * 2.Batch Class For Fetching Session Performance For All Session that is already exist in salesforce.  
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/

public class GoToWebinarController {


     /** 
    * ********************************************************
    *  createGoToWebinar - 
    * 1.Called from LWC(Embedded in VF page) for creating GoToWeinar
    * 2.Call 'webinars' API for creating Webinar in GoToWebinar and 
        creating a GoToWebinar Record with webinar key when status code is 201 
    * ********************************************************
    */
    @AuraEnabled
    public static Map<String,String> createGoToWebinar(String accountId,
                                        String subject,
                                        String description,
                                        DateTime startTime,
                                        DateTime endTime){

        Map<String,String> statusMap = new Map<String,String>();                                    
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();                                    
        String msgToDisplay,result;
        String goToWebinarId;

        GoToWebinarWrapper.Webinars webinar = new  GoToWebinarWrapper.Webinars();                     
        String requestBody = webinar.requestBodyForPostGoToWebinar(accountId,subject,description,startTime,endTime);

        httpRes = GoToWebinarAPICallout.executeCallout('POST','webinars',requestBody,null);

        System.debug('Webianr create Response Body');
        System.debug('httpRes.getBody()--------'+httpRes.getBody());
        System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());
        
        if(httpRes.getStatusCode() < 300){
                              
            webinar = webinar.parse(httpRes.getBody());
            
            GoTo_Webinar__c goToWebinar = new GoTo_Webinar__c();
            goToWebinar.Account__c = accountId;
            goToWebinar.Webinar_Key__c	= webinar.webinarKey;
            insert goToWebinar;
            System.debug('AccountId'+accountId);
            List<Contact> lstCon = [Select id,Meeting__c from Contact where accountId=:accountId];
            System.debug('lstCOn Size:'+lstCon.size());
            for(Contact con : lstCon){
                con.Meeting__c = 'Sent';
            }
            update lstCon;

            GoToWebinarController.getSingleWebinarDetails(accountId, goToWebinar.Id,goToWebinar.Webinar_Key__c);

            statusMap.put('success',goToWebinar.Id);

        }else{
            GoToWebinarWrapper.ErrorResponse errorResponse = new  GoToWebinarWrapper.ErrorResponse();                     
            errorResponse = errorResponse.parse(httpRes.getBody());
            System.debug('Error Message:'+ errorResponse.Details);

            statusMap.put('error',errorResponse.Details);
            
        }
        System.debug('Map:'+statusMap);
        return statusMap;
    }

         /** 
    * ********************************************************
    *  getSingleWebinarDetails - 
    * 1. called from  createGoToWebinar method.
    * 2. This API is called for fetching webinar details that is recently created becuase while 
        POST api it does not all details.
    * ********************************************************
    */

	 @future(callout=true)
     public static void getSingleWebinarDetails(String accountId,String goToWeinarId,String webinarKey){
        
        System.debug('***accountId:'+accountId);

        HttpResponse httpRes = new HttpResponse();

        httpRes = GoToWebinarAPICallout.executeCallout('GET','webinars',null,webinarKey);

        System.debug('httpRes.getBody()--------'+httpRes.getBody());
        System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());

        
        if(httpRes.getStatusCode() == 200){
            GoToWebinarWrapper.Webinars singleWebinar = new  GoToWebinarWrapper.Webinars();                     
            singleWebinar = singleWebinar.parse(httpRes.getBody());
            System.debug('**Single Webinar**'+singleWebinar);
            
            GoTo_Webinar__c goToWebinarSingle = new GoTo_Webinar__c();
			goToWebinarSingle.Account__c=accountId;
            goToWebinarSingle.Webinar_Key__c = singleWebinar.webinarKey;
            goToWebinarSingle.Webinar_Id__c = singleWebinar.webinarID;
            goToWebinarSingle.Registration_URL__c = singleWebinar.registrationUrl;
            goToWebinarSingle.Number_Of_Registrants__c = singleWebinar.numberOfRegistrants; 
            goToWebinarSingle.Subject__c = singleWebinar.subject;
            goToWebinarSingle.Description__c = singleWebinar.description;
            goToWebinarSingle.End_Time__c = singleWebinar.Times[0].endTime;
            goToWebinarSingle.Start_Time__c = singleWebinar.Times[0].startTime;

            goToWebinarSingle.id = goToWeinarId;
            update goToWebinarSingle;
            
            
            Account acc = new Account();
            acc.Id = accountId;
            acc.Schedule_Goto_Meeting__c = singleWebinar.registrationUrl;
            acc.Webinar_Key__c= singleWebinar.webinarKey;
            update acc;
        }
    }
    

    // public static string convertDatetimeInAMPMformat(String datetimejson, String timezone){
            
    //     Datetime inDateTime = (Datetime)(json.deserialize('"'+datetimejson+'"', datetime.class));
    //     String dtString = inDateTime.format('MM/dd/yyyy HH:mm:ss a zz', timezone);
    //     Integer hour = Integer.valueOf(dtString.subString(11,13));

    //     if(hour>12){
    //         String hournew = (hour-12)<10?'0'+String.valueOf(hour-12):String.valueOf(hour-12);
    //         dtString = dtString.substringBefore(' ')+' '+hournew+':'+dtString.substringAfter(':');
    //     }
    //     return dtString;
    // }

      /** 
    * ********************************************************
    *  getSingleWebinarDetails - 
    * 1.Called From VF Page For Syncing All the details for Webinar,Session Quetion,Session Performance
    * ********************************************************
    */
    // public  static void getAllwebinars() {
    //     System.enqueueJob(new GoToWebinarQueueable());
    // }  
}