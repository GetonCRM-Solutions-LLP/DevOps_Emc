/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : 
 * 1.This class will be called when any contact register the webinar OR attend a session
 * 2.Provide this class access to GoToWebinar Site guest user.
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/


@RestResource(urlMapping='/gotowebinar/webhook/*')
global without sharing class GoToWebinarService {


    public static RestRequest req = RestContext.request;
    public static RestResponse res = RestContext.response;
    public static Map<String, Object> fetchRequestBody = new  Map<String, Object>();
    

         /** 
    * ********************************************************
    * getConnection- This HttpGet is only created for Creating a connection between 
    * salesforce and GoToWebinar For the Webhook Registration.
    * ********************************************************
    */
    @HttpGet
    global static void getConnection() {
        System.debug('In get request body'+req.requestbody.tostring());
    }



    /** 
    * ********************************************************
    * getWebinarDetails -
    * 1.This class will be called when any contact register the webinar OR attend a session
    * 2.In the method we are checking that webinar is already exist in salesforce 
        if yes: we are checking that contact is exist or not by using email Id
            If Yes: we are checking the event:
            if event = 'registrant.joined'
                then we are updating the contact Meeting__c and Registration_Date__c field
            If event =  'registrant.joined'
                then we are checking if that session is exist or not 
                if yes:
                    We are updating the GoTo_Session__c in Contact.
                If No :
                    we are creating a session record.
    * ********************************************************
    */

    @HttpPost
    global static void getWebinarDetails() {
    
        System.debug('GoToWebinarService ReguestBody:'+req.requestbody.tostring());
     
        fetchRequestBody = (Map<String, Object>)JSON.deserializeUntyped(req.requestbody.tostring());
        String gotoWebinarKey = String.valueOf(fetchRequestBody.get('webinarKey'));
        String eventName = String.valueOf(fetchRequestBody.get('eventName'));

        List<GoTo_Webinar__c>  lstGoToWebinar = [SELECT id,Webinar_Key__c 
                                                    FROM GoTo_Webinar__c 
                                                    WHERE Webinar_Key__c =: gotoWebinarKey ];
         

        if(lstGoToWebinar.size()>0){
          
            String contactEmail = String.valueOf(fetchRequestBody.get('email'));
            List<Contact> lstContact = [SELECT id,Email,Registration_Date__c,Meeting__c
                                            FROM Contact 
                                            WHERE Email =: contactEmail];

            if(lstContact.size()>0){
                if(eventName == 'registrant.added'){           
                    String registrationDate = String.valueOf(fetchRequestBody.get('registrationDate'));
                    lstContact[0].Registration_Date__c = DateTime.valueOf(registrationDate.replace('T',' '));
                    lstContact[0].Meeting__c = 'Scheduled';    
                    lstContact[0].GoTo_Webinar__c = lstGoToWebinar[0].id;    
                }
                System.debug('Event Name:'+eventName);
                if(eventName == 'registrant.joined'){
                    String joinTime = String.valueOf(fetchRequestBody.get('joinTime'));
                    String sessionKey = String.valueOf(fetchRequestBody.get('sessionKey'));
                    String webinarKey = String.valueOf(fetchRequestBody.get('webinarKey'));

                    List<GoTo_Session__c> lstGoToSession = [Select id from GoTo_Session__c 
                                                            WHERE Session_Key__c =: sessionKey  ];

                    if(lstGoToSession.size()<1 ){
                        GoTo_Session__c gotoSession = new GoTo_Session__c();
                        gotoSession.GoTo_Webinar__c = lstGoToWebinar[0].id;
                        gotoSession.Session_Key__c = sessionKey;
                        gotoSession.Start_Time__c = DateTime.valueOf(joinTime.replace('T',' '));
                        gotoSession.Webinar_Key__c = webinarKey;
                        gotoSession.Webinar_Name__c =  String.valueOf(fetchRequestBody.get('webinarTitle'));

                        insert gotoSession;
                       
                        lstContact[0].GoTo_Session__c = gotoSession.id;      
                    }else{
                        lstContact[0].GoTo_Session__c = lstGoToSession[0].id;  
                    }
                    lstContact[0].Webinar_Join_Time__c = DateTime.valueOf(joinTime.replace('T',' '));
                    lstContact[0].Meeting__c = 'Attended';                   
                }
                
                if(lstContact.size() > 0){
                    update lstContact;
                }
            }
        }
    }
}

// {
        //     "eventName": "registrant.added",
        //     "eventVersion": "1.0.0",
        //     "product": "g2w",
        //     "eventKey": "a0bdb0f1-3315-43f2-bc47-82b427ea46a3",
        //     "firstName": "Dhanraj",
        //     "lastName": "Khatri",
        //     "email": "dhanrajkhatri4533@gmail.com",
        //     "responses": [],
        //     "registrationDate": "2022-08-29T05:53:56.172Z",
        //     "status": "APPROVED",
        //     "webinarKey": 8414462857135018000,
        //     "webinarTitle": "Test Driver Meeting",
        //     "experienceType": "CLASSIC",
        //     "recurrenceType": "series",
        //     "webinarCreatorKey": 1150664589213251600,
        //     "registrantKey": 6912712492608419000,
        //     "joinUrl": "https://global.gotowebinar.com/join/8414462857135018255/734865148",
        //     "timestamp": "2022-08-29T05:53:57.122Z"
        //   }
        

        // {
        //     "eventName": "registrant.joined",
        //     "eventVersion": "1.0.0",
        //     "product": "g2w",
        //     "eventKey": "5e8f1e6c-cd7c-452f-8c19-0544dfcfb648",
        //     "sessionKey": 28976871,
        //     "webinarKey": 9094719706211488000,
        //     "firstName": "Niraj",
        //     "lastName": "Sahedani",
        //     "email": "niraj.sahedani@getoncrm.com",
        //     "webinarCreatorKey": 1150664589213251600,
        //     "webinarTitle": "Webinar Testing 29-08",
        //     "experienceType": "CLASSIC",
        //     "recurrenceType": "single_session",
        //     "registrantKey": 3932311403175301000,
        //     "joinTime": "2022-08-29T08:51:16.693Z",
        //     "timestamp": "2022-08-29T08:51:17.072Z"
        //   }