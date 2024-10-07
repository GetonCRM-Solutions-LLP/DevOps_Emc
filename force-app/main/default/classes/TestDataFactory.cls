@isTest
public with sharing class TestDataFactory {

    static Integer j=0;
    /** 
    * ********************************************************
    * Developer Name - Dhanraj Khatri
    * This method is test data for create TrueDialog_Keys__c custom setting record.
    * ********************************************************
    */
    public static TrueDialog_Keys__c createTrueDialog(Boolean doInsert){
        TrueDialog_Keys__c tdKeys = new TrueDialog_Keys__c();
            
        tdKeys.Client_Id__c='1ab59fe33353401b8fd8da05716caaf5';
        tdKeys.Client_Secret__c='Jx8$z9*T/rY5';
        tdKeys.Base_URL__c  = 'https://api.truedialog.com/api/v2.1/account/';
        tdKeys.Account_Id__c = '18409';
        tdKeys.Callback_Token__c='bd054ccb-372b-40d3-a304-26cd540b4768';
        tdkeys.Channel_Id__c='22'; 
        tdkeys.Name='TrueDialogKeys';
        tdKeys.Subscription_Id__c='22639';
        tdKeys.Contact_Insert_From_File__c = True;
        tdKeys.Batch_Notification_Email__c='dhanrajkhatri453@gmail.com';


        if(doInsert){
            insert tdKeys;
        }
        return tdKeys;
     
    }


    /** 
    * ********************************************************
    * This method is test data for create IRS_Mileage_Rate__c.
    * ********************************************************
    */
    public static IRS_Mileage_Rate__c createIRSRate(Boolean doInsert,Integer checkYear) {
        IRS_Mileage_Rate__c objIRSRate = new IRS_Mileage_Rate__c();
        objIRSRate.year__c = String.valueof(System.today().year() - checkYear);
        objIRSRate.IRS_Rate__c = 0.578;
        if(doInsert){
            insert objIRSRate;
        }
        return objIRSRate;
    }
    /** 
    * ********************************************************
    * This method is test data for send email custom setting.
    * ********************************************************
    */
    public static SendEmail__c sendEmailCustomSetting(Boolean doInsert,String name){
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = name;
        customSetting.Send_email_from_code__c = true;
        if(doInsert){
            insert customSetting;
        }
        return customSetting;
    }

    public static SendEmailonDeactivation__c sendEmailCustomSetting(Boolean doInsert,String name, String bccEmailId){
    SendEmailonDeactivation__c objSendEmail = new SendEmailonDeactivation__c();
        objSendEmail.Name = name; //YearToDateReimbursementStatement
        objSendEmail.BCCEmailaddresses__c = bccEmailId;
        objSendEmail.Send_to_Driver__c = true;
        
        if(doInsert){
            insert objSendEmail;
        }
        return objSendEmail;

    }
     /** 
    * ********************************************************
    * This method is test data for send email to me custom setting.
    * ********************************************************
    */
    public static SendEmailToMe__c sendEmailToMeCustomSetting(Boolean doInsert,String name){
        SendEmailToMe__c customSetting =  new SendEmailToMe__c();
        customSetting.Name = name;
        customSetting.Send_email_to_me__c = true;
        if(doInsert){
            insert customSetting;
        }
        return customSetting;
    }

     /** 
    * ********************************************************
    * This method is test data for daylight custom setting.
    * ********************************************************
    */
    public static daylight_saving_time_config__c dayLightCustomSetting(Boolean doInsert,String name, date startdate, date endDate){
        daylight_saving_time_config__c customSetting =  new daylight_saving_time_config__c();
            customSetting.Name = '2022';
            customSetting.Start_Date__c = System.today();
            customSetting.End_Date__c = System.today() + 60;
        if(doInsert){
            insert customSetting;
        }
        return customSetting;
    }
    /** 
    * ********************************************************
    * This method is test data for trigger config custom setting.
    * ********************************************************
    */
    public static TriggerConfig__c triggerConfigCustomSetting(Boolean doInsert){
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.ContactTriBiReimCreate__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasPriceTriggerUpdateConvertedDat__c = true;
        customSetting.MappingMileage__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.MapTriAppReje__c = true;
        customSetting.Mileage_Lockdate__c = true;
        customSetting.mileageremoveapprovaldate__c   = true;
        customSetting.TrackHistory__c = true;
        customSetting.UserTrigger__c = true;
        customSetting.insertDriverAggrementFile__c = false;
        customSetting.IRSVehicleCHeck__c = false;
        customSetting.BiWeeklyReimbursementTrigger__c = true;
        customSetting.updateWorkingDays__c = true;
        customSetting.Mileage_Lock_date_on_Reimbursement__c =  false;
        customSetting.AddressTrigger__c=true;
        CustomSetting.ContentDocumentLinkTrigger__c=true;
        
        SendEmailonDeactivation__c objSendEmail = new SendEmailonDeactivation__c();
        objSendEmail.Name ='InsuranceIdUpdate'; //YearToDateReimbursementStatement
        objSendEmail.BCCEmailaddresses__c = 'tezt@gmail.com,test.email.com';
        objSendEmail.Send_to_me__c = true;
        insert objSendEmail;
        
        if(doInsert){
            insert customSetting;
        }
        return customSetting;        
    }
    /** 
    * ********************************************************
    * This method is test data for NewDashboard Message custom setting.
    * ********************************************************
    */
    public static NewDashboardMessage__c newMsgCustomSetting(Boolean doInsert){
        NewDashboardMessage__c newMsg = new NewDashboardMessage__c();
        newMsg.Name = 'Message';
        newMsg.File_Loader__c = 'Please wait while your insurance is uploaded.';
        if(doInsert){
            insert newMsg;
        }
        return newMsg;
    }


     /** 
    * ********************************************************
    * This method is test data for NewDashboard Message custom setting.
    * ********************************************************
    */
    public static NewDashboardVideoLink__c NewDashboardVideoLink(Boolean doInsert){
        NewDashboardVideoLink__c videoLink = new NewDashboardVideoLink__c();
        videoLink.Name = 'Video Link';
        videoLink.Donwload_instruction_for_Android__c = 'https://hubs.ly/Q017h3yM0';
        videoLink.Donwload_instruction_for_IOS__c = 'https://hubs.ly/Q017h3LM0';
        videoLink.Download_mLog_Link_For_Android__c = 'https://www.youtube.com/embed/htP2Xfub3aQ?autoplay=1';
        videoLink.Download_mLog_Link_For_IOS__c = 'https://www.youtube.com/embed/Zs7lqXOSkzo?autoplay=1';
        videoLink.Insurance_Link__c = 'https://2511299.fs1.hubspotusercontent-na1.net/hubfs/2511299/2022%20mBurse%20Insurance%20Upload.mp4?t=1651067128970&utm_campaign=2022%20Insurance%20Video&utm_source=email';
        videoLink.mLog_Preview_Company_Provided_Link__c = ' https://hubs.ly/Q0191tsl0';
        videoLink.mLog_Preview_Employee_Provided_Link__c = 'https://hubs.ly/Q018ZZcw0';
        videoLink.mLog_Support_Link__c = '';
        videoLink.Plan_Preview_Link__c = 'https://hubs.ly/Q018-6YH0';
        videoLink.Privacy_Pledge_Link__c = 'https://hubs.ly/Q0192ss-0';
        videoLink.Welcome_Link__c = 'https://hubs.ly/Q0191trW0';
        if(doInsert){
            insert videoLink;
        }
        return videoLink;
    }
    
    /** 
    * ********************************************************
    * This method is test data for Hello sign custom setting.
    * ********************************************************
    */
    public static Hello_Sign__c helloSignCustomSetting(Boolean doInsert){
        Hello_Sign__c customHello = new Hello_Sign__c();
        customHello.Name = 'Hello_Sign';
        customHello.Admin_Email__c = 'test@gmail.com';
        customHello.Admin_Name__c = 'Test';
        customHello.TestMode__c = true;
        if(doInsert){
            insert customHello;
        }
        return customHello;
    }


    /** 
    * ********************************************************
    * This method is create test data for Vehicle URL Mapping object
    * ********************************************************
    */
    public static Vehicle_URL_Mapping__c createVehicleData(Boolean doInsert,Integer checkYear) {   
        Vehicle_URL_Mapping__c vehicleObj = new Vehicle_URL_Mapping__c();
        vehicleObj.Name = String.valueof(System.today().year() - checkYear) + ' Mileage Rate';
        vehicleObj.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093359.jpg';
        vehicleObj.vehicle__c =  'Mileage Rate';
        vehicleObj.Year__c = String.valueof(System.today().year() - checkYear);
        if(doInsert){
            insert vehicleObj;
        }
        return vehicleObj;
    }
    /** 
    * ********************************************************
    * This method is create test data for Userrole
    * ********************************************************
    */
    public static UserRole getUserRole() {   
        UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        return userRole;
    }
    /** 
    * ********************************************************
    * This method is create test data for Profile
    * ********************************************************
    */
    public static Profile getUserProfile() {   
        //Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User - Driver' LIMIT 1];
        return profileObj;
    }
    /** 
    * ********************************************************
    * This method is create test data for Profile
    * ********************************************************
    */
    public static User getSystemAdminUser(Id userRole) {   
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId =: userRole LIMIT 1];
        return admin;
    }
    /** 
    * ********************************************************
    * This method is create test data for User record
    * ********************************************************
    */
    public static User createUser(Boolean doInsert,Id profileId,Id contactId) {   
        User userObj = new User( 
            Email = 'abc@gmail.com',
            ProfileId = profileId, 
            UserName = 'abctreywert@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = contactId,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            IsActive = true
        );
        if(doInsert){
            insert userObj;
        }
        return userObj;
    }
    /** 
    * ********************************************************
    * This method is test data for create Account.
    * ********************************************************
    */
    public static Account createAccount(Boolean doInsert,String accountName,Boolean checkByWeek) {
        Account accountObj = new Account( Name = accountName);
        accountObj.Bi_Weekly_Pay_Period__c = checkByWeek;
        accountObj.Pay_Period_Days__c = 13;
        accountObj.Pay_Period_Start_Date__c = system.today().adddays(-14);
        accountObj.Triplog_API__c = '28beeea973f34daf89050a9b6a3b1a71';
        accountObj.Triplog_Status__c = 'U';
        accountObj.isUsingTriplog__c = True;
        accountObj.Cell_Phone__c='Both';
        accountObj.Reimbursement_Frequency__c='Both';
        
        if(doInsert){
            insert accountObj;
        }
        return accountObj;
    }


    /**
     * **********************************************************
     * This Method is used for creating vehicle value List
     * ********************************************************** 
     */
    public static List<Vehicle_Value__c> createVehicleValue(Boolean doInsert, String AccId, String vehicleName){
        List<Vehicle_Value__c> vehicleValueList = new List<Vehicle_Value__c>();
        Vehicle_Value__c vehValue = new Vehicle_Value__c();
        vehValue.Account__c = AccId;
        vehValue.Vehicle_URL_Mapping__c = vehicleName;
        vehValue.Value__c = 15000;
        vehicleValueList.add(vehValue);
        if(doInsert){
            insert vehicleValueList;
        }
        return vehicleValueList;
    }

    /** 
    * ********************************************************
    * This method is test data for create Contact.It is use for CICD deployment.
    * ********************************************************
    */
    public static Contact createCICDContact(Boolean doInsert,Id accountId) {
        Contact contactObj = new Contact(AccountId = accountId, LastName = 'xgeek',External_Email__c='abc@gmail.com', MobilePhone = '1234567890',Cell_Phone__c='Company Provide',Reimbursement_Frequency__c='Monthly Reimbursement',Activation_Date__c=system.today());
        if(doInsert){
            insert contactObj;
        }
        return contactObj;
    }
    /** 
    * ********************************************************
    * This method is test data for create Driver Contact.
    * ********************************************************
    */
    public static List<Contact> createDriverContact(Boolean doInsert,Id accountId,String role, String vehicleName, String emailName, Integer nmbrRecord) {
        List<Contact> conList = new List<Contact>();
        for(Integer i = 1; i <= nmbrRecord; i++){                
            Contact con = new Contact();        
            con.FirstName = 'Priyanka';
            con.LastName = 'Gajera'+String.valueOf(Math.random() * 10);
            con.Employee_ID__c = '123456';
            con.AccountId = accountId;
            con.Email = emailName + i +String.valueOf(Math.random() * 10) +'@gmail.com';
            con.External_Email__c = emailName + i +String.valueOf(Math.random() * 10) +'@gmail.com';
            con.Phone = '1234566787';
            con.MobilePhone = '123456678'+j;
            con.Time_Zone__c = 'US/Mountain';
            con.Driving_States__c='AK; AL; AR; GA';
            con.Driver_Type__c = 'Driver - Full Time';
            con.Deactivated_Date__c = null;
            con.Insurance_Attachment_Id__c = Null;
            con.Vehicle_Type__c = vehicleName;  
            con.Role__c = role;
            con.compliancestatus__c = 'Yes';
            con.isCommunityUser__c = false;
            con.IsCreatedFromCommunity__c = false;
            con.Triplog_UserID__c = '23rcdsf';
            con.ReimbursementStatementBatch__c = true;            
            con.Manager__c = null;   
            con.Monthly_Mileage_Limit__c = -1;  
            con.MailingState = 'AK';
            con.MailingCity = 'Atlanta';            
            con.Cell_Phone__c='Employee Provide';
            con.Reimbursement_Frequency__c='Monthly Reimbursement';
            con.Activation_Date__c=system.today();
            conList.add(con);
            j=j+1;
        }       
        if(doInsert){
            insert conList;
        }
        return conList;
    }
    /** 
    * ********************************************************
    * This method is test data for create Driver Contact.
    * ********************************************************
    */
    public static Contact createDriverContacts(Boolean doInsert,Id accountId,String role, String vehicleName, String emailName,String monthyCS) {
                      
        Contact con = new Contact();        
        con.FirstName = 'Priyanka';
        con.LastName = 'Gajera'+String.valueOf(Math.random() * 10);
        con.Employee_ID__c = '123456';
        con.AccountId = accountId;
        con.External_Email__c = emailName + '@gmail.com';
        con.Phone = '1234566787';
        con.MobilePhone = '123456678'+j;
        con.Time_Zone__c = 'US/Mountain';
        con.Driver_Type__c = 'Driver - Full Time';
        con.Deactivated_Date__c = null;
        con.Insurance_Attachment_Id__c = Null;
        con.Vehicle_Type__c = vehicleName;  
        con.Role__c = role;
        con.monthly_compliance_status__c = monthyCS;
        con.isCommunityUser__c = false;
        con.IsCreatedFromCommunity__c = false;
        con.Triplog_UserID__c = '23rcdsf';
        con.ReimbursementStatementBatch__c = true;            
        con.Manager__c = null;   
        con.Monthly_Mileage_Limit__c = -1;  
        con.MailingState = 'AK';
        con.MailingCity = 'Atlanta';            
        con.Cell_Phone__c='Employee Provide';
        con.Reimbursement_Frequency__c='Monthly Reimbursement';
        con.Activation_Date__c=system.today();
        if(doInsert){
            insert con;
        }
        return con;
    }
    /** 
    * ********************************************************
    * This method is test data for create Employee Reimbursement.
    * ********************************************************
    */
    public static List<Employee_Reimbursement__c> createPendingReimbursement(Boolean doInsert,List<Contact> contactList,Integer nmbrRecord,Id irsRate)
    {        
        list<Employee_Reimbursement__c> reimbursementList = new list<Employee_Reimbursement__c>();
        for(Contact currentContact : contactList) {
            for(Integer i = 0; i <= nmbrRecord; i++) {            
                Employee_Reimbursement__c objReimbursement = new Employee_Reimbursement__c();
                objReimbursement.Name = currentContact.name+':'+getLastMonthValue(-i);               
                objReimbursement.Month__c = getLastMonthValue(-i);               
                objReimbursement.Contact_Id__c = currentContact.Id;
                objReimbursement.Status__c = 'Pending'; 
                objReimbursement.IRS_Mileage_Rate__c = irsRate;
                objReimbursement.Fixed_Amount__c  = 121;
                objReimbursement.Monthly_Fixed_Amount__c = 123;
                objReimbursement.Approved_Date__c = null;     
                objReimbursement.Number_of_Pay_Period__c = i;
                objReimbursement.Mileage_Lock_Date__c = null;
                reimbursementList.add(objReimbursement);
            }
        }
        if(doInsert){
            insert reimbursementList;
        }
        return reimbursementList;
    }

    /** 
    * ********************************************************
    * This method is use for creating string of reimbursement month.
    * Param value means if you pass 0 as a value then it return current month.
    * ********************************************************
    */
    public static String getLastMonthValue(Integer value) {
        String tempDate = date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }
        return lastMonth;
    }
    /**
     * **********************************************************
     * This Method is used for creating bi weekly reimbursement
     * ********************************************************** 
     */

    public static List<Bi_Weekly_Reimbursement__c> createBiweeklyReim(Boolean doInsert,List<Contact> contactList,date startDate, date endDate, Integer nmbrRecord,Id irsRate){
        List<Bi_Weekly_Reimbursement__c> biweeklyreimList = new List<Bi_Weekly_Reimbursement__c>();
        for(Contact currentContact : contactList) {
            for(Integer i = 1; i <= nmbrRecord; i++) {
                Bi_Weekly_Reimbursement__c objbiweeklyReim = new Bi_Weekly_Reimbursement__c();
                objbiweeklyReim.Name = startDate + ' to ' + endDate;
                objbiweeklyReim.Start_Date__c =  startDate;
                objbiweeklyReim.End_Date__c = endDate;                           
                objbiweeklyReim.Contact__c = currentContact.Id;
                objbiweeklyReim.Status__c = 'Pending'; 
                objbiweeklyReim.IRS_Mileage_Rate__c = irsRate;
                objbiweeklyReim.Fixed_Amount__c  = 121;
                objbiweeklyReim.Approved_Date__c = null;     
                objbiweeklyReim.Number_of_Pay_Period__c = i;
                biweeklyreimList.add(objbiweeklyReim);
            }
        }
        if(doInsert){
            insert biweeklyreimList;
        }
        return biweeklyreimList;   
    }

    /**
     * **********************************************************
     * This Method is used for creating Employee Mileages
     * ********************************************************** 
     */
    public static List<Employee_Mileage__c> getEmpMileage(Boolean doInsert, Integer nmbrRecord,List<Employee_Reimbursement__c> reimList, List<Bi_Weekly_Reimbursement__c> biweeklyReimList){
        List<Employee_Mileage__c> empMilageList = new List<Employee_Mileage__c>();
        for(Employee_Reimbursement__c reim :reimList){
            for(Integer i = 0; i <= nmbrRecord; i++) {        
                Long timestamp = System.currentTimeMillis();
                Integer randomNumber = (Integer)Math.floor(Math.random() * 10000);
                String uniqueString = timestamp + '_' + randomNumber;
                Employee_Mileage__c empMileage = new Employee_Mileage__c();
                empMileage.Name = 'Test Mileage' +String.valueOf(Math.random() * 100);
                empMileage.Contact_Email_Id__c = 'parasdhanani'+String.valueOf(Math.random() * 100)+'@gmail.com';  
                empMileage.EmployeeReimbursement__c = Reim.id;
                empMileage.Trip_Date__c = system.today();
                empMileage.Bi_Weekly_Reimbursement__c = biweeklyReimList[0].id;
                empMileage.Activity__c =  'Business';
                empMileage.EMP_Mileage__c = Integer.valueOf(Math.random() * 100);
                empMileage.Trip_Status__c= 'Not Approved Yet';
                empMileage.Fuel_price__c =  3.21;
                empMileage.Day_Of_Week__c = 'Tuesday';
                empMileage.MPG__c =  24.30;
                empMileage.TimeZone__c = 'US/Mountain' ;
                empMileage.Origin_Name__c = 'Test Origin' + String.valueOf(Math.random() * 100) ;
                empMileage.Trip_Destination__c = 'Test Destination' + String.valueOf(Math.random() * 100);
                empMileage.Trip_Status__c = StaticValues.noApprovedYet;
                empMileage.Approved_Date__c = null;
                empMileage.Tag__c = 'Admin';
                empMileage.Rejected__c = false;
                empMileage.Trip_Id__c  = 143576 + Integer.valueOf(Math.random()* 10000000)+randomNumber;
                empMilageList.add(empMileage);
            }
        }
        if(doInsert){
            insert empMilageList;
        }
        return empMilageList; 
    }
     /**
     * **********************************************************
     * This Method is used for creating Attachment
     * ********************************************************** 
     */
    public static Attachment createAttachment(Boolean doInsert,String contactId) {
        Attachment attach = new Attachment();     
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = contactId;
        if(doInsert){
            insert attach;
        }
        return attach;
    }
    /**
     * **********************************************************
     * This Method is used for creating an address List
     * ********************************************************** 
     */
    public static List<Address__c> createAddress(Boolean doInsert, Integer nmbrRecord, Integer zipcode){
        List<Address__c> addressList = new List<Address__c>();
        for(Integer i = 0; i <= nmbrRecord; i++) {
            Address__c addrs = new Address__c();
            addrs.State__c ='Alabama';
            addrs.City__c ='Abbeville';
            addrs.Abbreviation__c ='AL';
            addrs.ZIP_Code__c = string.valueof(zipcode + i); 
            //addrs.ZIP_Code__c ='36310'; 
            addrs.Time_Zone__c = 'America/Anchorage';
            addressList.add(addrs);
        }
        if(doInsert){
            insert addressList;
        }
        return addressList;
    }
    
     public static Batch_Setup__c getTestBatchSetup(Boolean doInsert){
        Batch_Setup__c bsSet = new Batch_Setup__c();
        
        bsSet.Name = 'Test Batch';
        bsSet.AutoApprovedEmail__c = True;
        bsSet.BatchForApprovingReimburse__c = True;
        bsSet.GetTripBatch__c = True;
        bsSet.InsertLastMonthReimbursement__c = True;
        bsSet.UpdateLastToLastMonthMileagesBatch__c = True;
         if(doInsert){
            insert bsSet;
        }
        return bsSet;
    } 
}