@isTest
public class GoToWebinarTest {
    
    @isTest
    public static void getAllwebinarsTest(){
        
        Test.setMock(HttpCalloutMock.class, new GoToWebinarMockCallout());   
        Account acc = TestDataFactory.createAccount(false, 'Test', false);
        acc.Webinar_Key__c = '1442461824433625869';
        insert acc;
        
        GoTo_Webinar__c goToWebinar = new GoTo_Webinar__c();  
        goToWebinar.Account__c = acc.Id;
        goToWebinar.Subject__c = 'Test';
        goToWebinar.Description__c = 'description';
        //goToWebinar.Start_Time__c = DateTime.valueOf('2022-08-27T12:39:00.000+0000');
        // goToWebinar.End_Time__c = DateTime.valueOf('2022-08-27T17:15:00.000+0000');
        goToWebinar.Webinar_Key__c = '1442461824433625869';
        insert goToWebinar;
        
        GoTo_Session__c  goToSession = new GoTo_Session__c();
        goToSession.Webinar_Key__c='1442461824433625869';
        goToSession.Webinar_Name__c = 'Venergy Group Test';
        goToSession.Session_Key__c = '29009245';
        goToSession.Attendance_Percentage__c = 100;
        goToSession.Recurrence_Period__c = 'intermittent';
        goToSession.Start_Time__c = System.now();
        goToSession.End_Time__c =System.now()+1 ;
        goToSession.Registration_Link_Clicked_Count__c = 100;
        goToSession.Question_Asked__c = 100;
        goToSession.Survey_Count__c = 100;
        goToSession.Poll_Count__c = 100;
        goToSession.Percentage_Polls_Completed__c = 100;
        goToSession.Percentage_Surveys_Completed__c = 100;
        goToSession.Registrant_Count__c = 100;
        goToSession.Attendance_Percentage__c = 100;
        
        insert goToSession;
        
        GoToWebinarSyncController.getAllwebinars(); 
    }
    
    @isTest
    public static void createGoToWebinarTest(){
        
        Test.setMock(HttpCalloutMock.class, new GoToWebinarMockCallout());   
        Account acc = TestDataFactory.createAccount(false, 'Test', false);
        acc.Webinar_Key__c = '1442461824433625869';
        insert acc;
        
        Test.startTest();
        GoToWebinarController.createGoToWebinar(acc.Id, 'Test Webinar', 'Test Description', System.now(), System.now()+1);
        Test.stopTest();
    }
    
    @isTest
    public static void getAccessTokenTest(){
        
        Test.setMock(HttpCalloutMock.class, new GoToWebinarMockCallout());   
        
        PageReference pageRef = Page.TrueDialog;
        Test.setCurrentPage(pageRef);// Add your VF page Name here
        ApexPages.currentPage().getParameters().put('code', 'samplecode');
        //ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        GoToWebinarVFController obj = new GoToWebinarVFController();
        obj.getAuthCode();
        GoToWebinarVFController.getAccessToken();
    }
   
    @isTest
    public static void getConnectionTest(){
        
        RestRequest request = new RestRequest();
        request.requestUri = 'https://partialdev-gasmanager.cs220.force.com/GoToWebinar/services/apexrest/gotowebinar/webhook';
        request.httpMethod = 'GET';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{}');
        
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;
        
        GoToWebinarService.getConnection();
        
    }
    @isTest
    public static void getWebinarDetailsTest(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10, 0956);
        //List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account accountObj;
        System.runAs(admin) {
            accountObj = TestDataFactory.createAccount(true,'demo',true);
            Contact contactObj = TestDataFactory.createCICDContact(false,accountObj.Id);
            contactObj.External_Email__c = 'dhanrajkhatri4533@gmail.com';
            insert contactObj;
        }
        
        GoTo_Webinar__c goToWebinar = new GoTo_Webinar__c();  
        goToWebinar.Account__c = accountObj.Id;
        goToWebinar.Subject__c = 'Test';
        goToWebinar.Description__c = 'description';
        //goToWebinar.Start_Time__c = DateTime.valueOf('2022-08-27T12:39:00.000+0000');
        // goToWebinar.End_Time__c = DateTime.valueOf('2022-08-27T17:15:00.000+0000');
        goToWebinar.Webinar_Key__c = '8414462857135018000';
        insert goToWebinar;
        
        GoTo_Session__c  goToSession = new GoTo_Session__c();
        goToSession.Webinar_Key__c='8414462857135018000';
        goToSession.Webinar_Name__c = 'Venergy Group Test';
        goToSession.Session_Key__c = '29009245';
        goToSession.Attendance_Percentage__c = 100;
        goToSession.Recurrence_Period__c = 'intermittent';
        goToSession.Start_Time__c = System.now();
        goToSession.End_Time__c =System.now()+1 ;
        goToSession.Registration_Link_Clicked_Count__c = 100;
        goToSession.Question_Asked__c = 100;
        goToSession.Survey_Count__c = 100;
        goToSession.Poll_Count__c = 100;
        goToSession.Percentage_Polls_Completed__c = 100;
        goToSession.Percentage_Surveys_Completed__c = 100;
        goToSession.Registrant_Count__c = 100;
        goToSession.Attendance_Percentage__c = 100;
        insert goToSession;
        
        String requestBody = '{ "eventName": "registrant.added", "eventVersion": "1.0.0", "product": "g2w", "eventKey": "a0bdb0f1-3315-43f2-bc47-82b427ea46a3", "firstName": "Dhanraj", "lastName": "Khatri", "email": "dhanrajkhatri4533@gmail.com", "responses": [], "registrationDate": "2022-08-29T05:53:56.172Z", "status": "APPROVED", "webinarKey": 8414462857135018000, "webinarTitle": "Test Driver Meeting", "experienceType": "CLASSIC", "recurrenceType": "series", "webinarCreatorKey": 1150664589213251600, "registrantKey": 6912712492608419000, "joinUrl": "https://global.gotowebinar.com/join/8414462857135018255/734865148", "timestamp": "2022-08-29T05:53:57.122Z" }';
        
        RestRequest request = new RestRequest();
        request.requestUri = 'https://partialdev-gasmanager.cs220.force.com/GoToWebinar/services/apexrest/gotowebinar/webhook';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestBody);
        
        RestResponse res = new RestResponse();
        RestContext.request = request;
        RestContext.response = res;
        
        GoToWebinarService.getWebinarDetails();
        
        String requestBody1 = '{ "eventName": "registrant.joined", "eventVersion": "1.0.0", "product": "g2w", "eventKey": "5e8f1e6c-cd7c-452f-8c19-0544dfcfb648", "sessionKey": 28976871, "webinarKey": 9094719706211488000, "firstName": "Niraj", "lastName": "Sahedani", "email": "niraj.sahedani@getoncrm.com", "webinarCreatorKey": 1150664589213251600, "webinarTitle": "Webinar Testing 29-08", "experienceType": "CLASSIC", "recurrenceType": "single_session", "registrantKey": 3932311403175301000, "joinTime": "2022-08-29T08:51:16.693Z", "timestamp": "2022-08-29T08:51:17.072Z" }';
        
        RestRequest request1 = new RestRequest();
        request1.requestUri = 'https://partialdev-gasmanager.cs220.force.com/GoToWebinar/services/apexrest/gotowebinar/webhook';
        request1.httpMethod = 'POST';
        request1.addHeader('Content-Type', 'application/json');
        request1.requestBody = Blob.valueOf(requestBody1);
        
        RestResponse res1 = new RestResponse();
        RestContext.request = request1;
        RestContext.response = res1;
        
        GoToWebinarService.getWebinarDetails(); 
    }
    
    
    @isTest
    public static void getWebinarDetailsTest2(){
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c sendEmailCustomSetting = TestDataFactory.sendEmailCustomSetting(true, 'Send Email For Compliance');
        IRS_Mileage_Rate__c irsRateObj = TestDataFactory.createIRSRate(true,0);
        List<Address__c> objAddress = TestDataFactory.createAddress(true, 10, 0956);
        //List<Address__c> objAddress = TestDataFactory.createAddress(true, 10);
        Vehicle_URL_Mapping__c vehicleObj = TestDataFactory.createVehicleData(true,0);
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        
        Account acc = new Account();     
        List<Contact> conList = new List<Contact>();
        
        UserRole userRole = TestDataFactory.getUserRole();
        Profile profileObj = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole.Id);
        User userObj;
        Account accountObj;
        System.runAs(admin) {
            accountObj = TestDataFactory.createAccount(true,'demo',true);
            Contact contactObj = TestDataFactory.createCICDContact(false,accountObj.Id);
            contactObj.External_Email__c = 'dhanrajkhatri4533@gmail.com';
            insert contactObj;
        }
        
        GoTo_Webinar__c goToWebinar = new GoTo_Webinar__c();  
        goToWebinar.Account__c = accountObj.Id;
        goToWebinar.Subject__c = 'Test';
        goToWebinar.Description__c = 'description';
        //goToWebinar.Start_Time__c = DateTime.valueOf('2022-08-27T12:39:00.000+0000');
        // goToWebinar.End_Time__c = DateTime.valueOf('2022-08-27T17:15:00.000+0000');
        goToWebinar.Webinar_Key__c = '8414462857135018000';
        insert goToWebinar;
        
        GoTo_Session__c  goToSession = new GoTo_Session__c();
        goToSession.Webinar_Key__c='8414462857135018000';
        goToSession.Webinar_Name__c = 'Venergy Group Test';
        goToSession.Session_Key__c = '29009245';
        goToSession.Attendance_Percentage__c = 100;
        goToSession.Recurrence_Period__c = 'intermittent';
        goToSession.Start_Time__c = System.now();
        goToSession.End_Time__c =System.now()+1 ;
        goToSession.Registration_Link_Clicked_Count__c = 100;
        goToSession.Question_Asked__c = 100;
        goToSession.Survey_Count__c = 100;
        goToSession.Poll_Count__c = 100;
        goToSession.Percentage_Polls_Completed__c = 100;
        goToSession.Percentage_Surveys_Completed__c = 100;
        goToSession.Registrant_Count__c = 100;
        goToSession.Attendance_Percentage__c = 100;
        insert goToSession;
        
        String requestBody1 = '{ "eventName": "registrant.joined", "eventVersion": "1.0.0", "product": "g2w", "eventKey": "5e8f1e6c-cd7c-452f-8c19-0544dfcfb648", "sessionKey": 28976871, "webinarKey": 8414462857135018000, "firstName": "Niraj", "lastName": "Sahedani", "email": "dhanrajkhatri4533@gmail.com", "webinarCreatorKey": 1150664589213251600, "webinarTitle": "Webinar Testing 29-08", "experienceType": "CLASSIC", "recurrenceType": "single_session", "registrantKey": 3932311403175301000, "joinTime": "2022-08-29T08:51:16.693Z", "timestamp": "2022-08-29T08:51:17.072Z" }';
        
        RestRequest request1 = new RestRequest();
        request1.requestUri = 'https://partialdev-gasmanager.cs220.force.com/GoToWebinar/services/apexrest/gotowebinar/webhook';
        request1.httpMethod = 'POST';
        request1.addHeader('Content-Type', 'application/json');
        request1.requestBody = Blob.valueOf(requestBody1);
        
        RestResponse res1 = new RestResponse();
        RestContext.request = request1;
        RestContext.response = res1;
        
        GoToWebinarService.getWebinarDetails();
        
    }
    
    @isTest
    public static void GoToWebinarMockCalloutTest(){
        Test.StartTest();
            GoToWebinarGenerateTokenSchedule webishc = new GoToWebinarGenerateTokenSchedule();
            String sch = '0 0 15 * * ?';
            system.schedule('Test check', sch, webishc);
        Test.setMock(HttpCalloutMock.class, new GoToWebinarMockCallout());
        Test.stopTest();
        //GoToWebinarGenerateTokenSchedule
    }
    
    @isTest
    public static void updateWebhookURLTest(){
        Test.setMock(HttpCalloutMock.class, new GoToWebinarMockCallout()); 
        GoToWebinarWebhookRegistration.updateWebhookURL();
    }
    
    @IsTest
    
    public static void DeployCallbackContextTest () {
    
       CustomMetadataUtil metadata = new CustomMetadataUtil();

    Test.startTest();
    
    metadata.handleResult(new Metadata.DeployResult(), new Metadata.DeployCallbackContext());
    
    Test.stopTest();
    
    }
    
}