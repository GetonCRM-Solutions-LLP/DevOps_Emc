/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : 
 * 1.This class is called from GoToSessionQuestionBatch
 * 2.Batch Class For Fetching Session Quetion And Answer For All Session that is 
 * already exist in salesforce.  
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/



public with sharing class GoToSessionQuestionBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
  
   

     /** 
    * ********************************************************
    *  Batch start method-
    * query GoTo_Session__c record for returning to execute method.
    * ********************************************************
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        query = 'select id,name,Webinar_Key__c,Webinar_Name__c,Session_Key__c,Attendance_Percentage__c FROM GoTo_Session__c ';
        return Database.getQueryLocator(query);
    }


    
     /** 
    * ********************************************************
    *  Batch Execute method-
    *  1.This method call 'questions' API for getting all the QNA details for every session
    2.Link Quetion Record with Session Record and upsert All QNA details in GoTo_Session_Question__c object 
    * ********************************************************
    */
    
    public void execute(Database.BatchableContext BC,  List<GoTo_Session__c> scope) {   

        List<GoTo_Session_Question__c> lstGotoSessionQuestion = new List<GoTo_Session_Question__c>();
        Map<String,String> emailIdMap = new Map<String,String>();
        Set<String> emailSet = new Set<String>();

        HttpResponse httpRes = new HttpResponse();
        
        for(GoTo_Session__c goToSession : scope ){

            httpRes = GoToWebinarAPICallout.executeCallout('GET','questions',null,goToSession.Session_Key__c);

            System.debug('httpRes.getBody()--------'+httpRes.getBody());
            System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());
        
            if(httpRes.getStatusCode() == 200){

                String responseBody = httpRes.getBody();

                GoToSessionQuestionWrapper sessionQuestions = new GoToSessionQuestionWrapper();
                List<GoToSessionQuestionWrapper> lstGoToSessionQuestionWrapper = sessionQuestions.parse(responseBody);

                for(GoToSessionQuestionWrapper goToQuestion : lstGoToSessionQuestionWrapper){
                    emailSet.add(goToQuestion.askedBy);        
                }

                for(Contact con : [Select id,email FROM Contact WHERE Email IN:emailSet]){
                    emailIdMap.put(con.Email,con.Id);
                }
                
                for(GoToSessionQuestionWrapper goToQuestion : lstGoToSessionQuestionWrapper){
                    String dateAsked = String.valueOf(goToQuestion.dateAsked);
                    
                    GoTo_Session_Question__c questionSingle = new GoTo_Session_Question__c();
                    questionSingle.Question__c = goToQuestion.question;
                    questionSingle.Asked_By_Email__c = goToQuestion.askedBy;
                    questionSingle.Date_Asked__c = DateTime.valueOf(dateAsked.replace('T',' '));
                    String externalId = goToQuestion.askerKey+goToQuestion.dateAsked;
                    questionSingle.Question_External_Id__c = externalId;
                    questionSingle.GoTo_Session__c = goToSession.Id;
  
                    List<Answers> lstAns = goToQuestion.Answers;
                    String answerCombination = '';

                    for(Answers answer : lstAns){
                        answerCombination =answerCombination + answer.answer+','; 
                    }
                    answerCombination = answerCombination.removeEnd(',');

                    questionSingle.Answers__c = answerCombination;

                    System.debug('emailIdMap.get(goToQuestion.askedBy);'+emailIdMap.get(goToQuestion.askedBy));
                    if(emailIdMap.containsKey( goToQuestion.askedBy)){
                        questionSingle.Contact__c = emailIdMap.get(goToQuestion.askedBy);
                    }

                    lstGotoSessionQuestion.add(questionSingle);
                    
                }
            }
        } 
           
        if(lstGoToSessionQuestion.size()>0){
            upsert lstGoToSessionQuestion Question_External_Id__c; 
        }     
    }


    public void finish(Database.BatchableContext BC){
        System.debug('GoToSessionQuestionBatch is Finished');
    }

    public class GoToSessionQuestionWrapper {
 
        public String question;
        public String askedBy;
        public String askerKey;
        public String dateAsked;
        public List<Answers> answers;
    
        public List<GoToSessionQuestionWrapper> parse(String json) {
            return (List<GoToSessionQuestionWrapper>) System.JSON.deserialize(json, List<GoToSessionQuestionWrapper>.class);
        }
    }

    public class Answers {
        public String answer;
        public String answeredBy;
        public String answererRole;
        public String answerTime;
        public String answererEmail;
    }
}