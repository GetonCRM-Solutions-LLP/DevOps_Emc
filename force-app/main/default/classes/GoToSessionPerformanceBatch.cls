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


public class GoToSessionPerformanceBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    

     /** 
    * ********************************************************
    *  Batch start method-
    * query GoTo_Session__c record for returning to execute method.
    * ********************************************************
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        query = 'select id,name,Webinar_Key__c, Webinar_Name__c, Session_Key__c, Attendance_Percentage__c  from GoTo_Session__c ';
        return Database.getQueryLocator(query);
    }

         /** 
    * ********************************************************
    *  Batch Execute Method-
    * 1.Call session performance api for every session and update the session performance 
        in GoTo_Session__c Object.
    * ********************************************************
    */
    public void execute(Database.BatchableContext BC,  List<GoTo_Session__c> scope) {   

        List<GoTo_Session__c> lstGotoSession = new List<GoTo_Session__c>();

        HttpResponse httpRes = new HttpResponse();
        
        for(GoTo_Session__c goToSession : scope ){
            httpRes = GoToWebinarAPICallout.executeCallout('GET','performance',null,goToSession.Session_Key__c);
            
            if(httpRes.getStatusCode() == 200){
                System.debug('*****Performance Body:'+httpRes.getBody());

                Map<String,Object> results = ( Map<String,Object>) JSON.deserializeUntyped(httpRes.getBody());
                Map<String, Object> attendance = (Map<String, Object>) results.get('attendance');//List<GTW_Attendee__c> g2wAttenObjUpsertList = new List<GTW_Attendee__c>();
                Map<String, Object> pollsAndSurveys = (Map<String, Object>) results.get('pollsAndSurveys');  
                Map<String,Object> sessionInfo = (Map<String, Object>) results.get('sessionInfo'); 

                goToSession.Webinar_Name__c = (String)sessionInfo.get('webinarName');
                goToSession.Recurrence_Period__c = (String)sessionInfo.get('recurrencePeriod');
                System.debug('***webinarID:'+sessionInfo.get('webinarId'));
                goToSession.Webinar_Id__c = (String)sessionInfo.get('webinarId');
                String startTime = String.valueOf(sessionInfo.get('startTime'));
          
                goToSession.Start_Time__c = DateTime.valueOf(startTime.replace('T',' '));
                String endTime = String.valueOf(sessionInfo.get('endTime'));
                goToSession.End_Time__c  =  DateTime.valueOf(endTime.replace('T',' '));
                goToSession.Registration_Link_Clicked_Count__c =(Integer) sessionInfo.get('registrationLinkClickedCount');
               
                goToSession.Question_Asked__c = (Integer)pollsAndSurveys.get('questionsAsked');
                goToSession.Survey_Count__c = (Integer)pollsAndSurveys.get('surveyCount');
                goToSession.Poll_Count__c = (Integer)pollsAndSurveys.get('pollCount');
                goToSession.Percentage_Polls_Completed__c = (Integer)pollsAndSurveys.get('percentagePollsCompleted');
                goToSession.Percentage_Surveys_Completed__c  = (Integer)pollsAndSurveys.get('percentagePollsCompleted');
               
                goToSession.Registrant_Count__c = Integer.valueOf(attendance.get('registrantCount'));
                goToSession.Attendance_Percentage__c = Integer.valueOf(attendance.get('percentageAttendance'));
              
            }
        } 
        
        if(scope.size() > 0){
            update scope;
        }
        
    }

     /** 
    * ********************************************************
    *  Batch Finish Method-
    * On Batch finished it will call GoToSessionQuestionBatch Batch class for fetching all
    * the QNA for every session
    * ********************************************************
    */
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new GoToSessionQuestionBatch(),50);
        System.debug('Batch is Finished');
    }
}

 // {
    //     "sessionInfo": {
    //         "webinarName": "Smart Fundraising Driver Meeting",
    //         "recurrencePeriod": "intermittent",
    //         "webinarId": "359618939",
    //         "sessionKey": "26265904",
    //         "registrationLinkClickedCount": 7,
    //         "timeZone": "America/Denver",
    //         "startTime": "2021-08-02T15:46:28Z",
    //         "endTime": "2021-08-02T17:01:44Z",
    //         "experienceType": "classic",
    //         "registrationEmailOpenedCount": 0
    //     },
    //     "pollsAndSurveys": {
    //         "surveyCount": 0,
    //         "questionsAsked": 0,
    //         "pollCount": 0,
    //         "percentagePollsCompleted": 0,
    //         "percentageSurveysCompleted": 0
    //     },
    //     "attendance": {
    //         "percentageAttendance": 100,
    //         "registrantCount": 2,
    //         "averageInterestRating": 94.5,
    //         "averageAttendanceTimeSeconds": 2147,
    //         "averageAttentiveness": 100
    //     }
    // }