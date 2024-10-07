/****************************************************
Description: Test class for RG_CreateNewUserPageClass
*****************************************************/
@isTest
public class RG_CreateNewUserPageClass_Test {
    public static String[] csvFileLines;
    public static Blob csvFileBody;
   

    public static testmethod void RG_CreateNewUserPageTestMethod() {
          
        /*SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'RG_CreateNewUserPageClass';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;*/

        SendEmail__c customSetting2 =  new SendEmail__c();
        customSetting2.Name = 'Send Email For Compliance';
        customSetting2.Send_email_from_code__c= true;
        insert customSetting2;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'RG_CreateNewUserPageClass';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Account acc = TestUtilityClass.getTestSingleAccount();
        acc.Vehicle_Types__c = '2019 Full Size Sedan';
        update acc;

        Contact con = new Contact();
        
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Test City';
        con.MailingState = 'ON';
        con.MailingPostalCode = '123';
        con.MailingCountry = 'CA';
        con.Phone = '1232434445';
        con.External_Email__c = 'minkesh.patel1478@gmail.com';
        con.Deactivated_Date__c = Null;
        con.isCommunityUser__c = True;
        con.Role__c = 'Admin';
        con.Vehicle_Type__c  = '2019 Full Size Sedan';
        con.Monthly_Mileage_Limit__c = 0;
        
        insert con;
     
        con.compliancestatus__c = 'No – Vehicle Value';
        con.Vehicle_Type__c = '2019 Full-Size Sedan';

        List<contact> conList = new List<contact>();
        conList.add(con);
        update conList;
       
       
        //conListids.add(manager.Id);
        //Create Contact For Driver
        Contact driCon = new contact (accountid = Acc.id, 
                                        FirstName = 'Test1', 
                                        LastName = 'Usertest2',
                                        email = 'atindrasinh123.goc@gmail.com',
                                        Deactivated_Date__c = date.today(),
                                        Role__c = 'Driver',
                                        Vehicle_Type__c  = '2019 Full Size Sedan',
                                        External_Email__c = 'atindrasinh123.goc@gmail.com',
                                        Manager__c = conList[0].id);
        insert driCon;
        
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Document Text');
        documentObj.ContentType = 'application/vnd.ms-excel';
        documentObj.DeveloperName = 'Inserted_Contact_File_Test';
        documentObj.IsPublic = true;
        documentObj.Name = 'Inserted Contact File';
        documentObj.FolderId = [select id from folder where name = 'Shared Documents'].id;
        insert documentObj;

        Document documentObjTwo = new Document();
        documentObjTwo.Body = Blob.valueOf('Some Document Text');
        documentObjTwo.ContentType = 'application/vnd.ms-excel';
        documentObjTwo.DeveloperName = 'Duplicate_Contact_File_Test';
        documentObjTwo.IsPublic = true;
        documentObjTwo.Name = 'Duplicate Contact File';
        documentObjTwo.FolderId = [select id from folder where name = 'Shared Documents'].id;
        insert documentObjTwo;
        
        Document documentObjThree = new Document();
        documentObjThree.Body = Blob.valueOf('Some Document Text');
        documentObjThree.ContentType = 'application/vnd.ms-excel';
        documentObjThree.DeveloperName = 'Sample_Template_Test';
        documentObjThree.IsPublic = true;
        documentObjThree.Name = 'Sample Template';
        documentObjThree.FolderId = [select id from folder where name = 'Shared Documents'].id;
        insert documentObjThree;
        
        List<user> userlist = new List<user>();
        
          Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Driver']; 
          User user = new User(Alias = 'standt', 
                            Email='standarduser1@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser2@testorg.com',
                            Contactid = conList[0].ID,
                            IsActive = True
                        );
            userlist.add(user);
           insert userlist;
        Test.startTest();
        
          System.runAs(userlist[0]) {
            userlist = [SELECT profile.name,
                              contactid,
                              Contact.FirstName,
                              contact.account.Vehicle_Types__c, 
                              Contact.External_Email__c,
                              Contact.Account.Name,
                              Contact.AccountId,
                              Contact.Account.Triplog_API__c,
                              Contact.Role__c
                              /*Give_Other_Admin_Access__c*/
                       FROM User 
                       WHERE Id =: UserInfo.getUserId()]  ;
           
            RG_CreateNewUserPageClass newUser = new RG_CreateNewUserPageClass();
            Apexpages.currentpage().getparameters().put('contactId',String.valueOf(userlist.get(0).ContactId));
            newUser.uName = 'test';
            newUser.contactSelectId = driCon.Id;
            newUser.userConId = driCon.Id;
            newUser.Index ='test';  
            //newUser.contactDataAsString = csvFileBody.toString();
   
            newUser.selectedMultiValue = 'test';                          
            newUser.init();
        
            newUser.admin = true;
            
            newUser.redirect();
            newUser.backMethod();
            
            newUser.save();
            newUser.dueDate = date.today();
            String str = 'Employee_ID__c, Firstname, LastName, External_Email__c, ' + 
                            'Vehicle_Type__c, Role__c, MailingCity, MailingState, ' + 
                            'MailingPostalCode, AccountId, Activation_Date__c, Manager__c\n ' + 
                            '1, Tests, Testing, test190@testing.com, ' + 
                            '2017 Toyota Camry,Driver,CA,USA, ' + 
                            '123456,Test Account,03-03-2018,Test Testing\n' +
                            '2, Second, Testing, atindrasinh.goc@gmail.com, ' + 
                            '2017 Toyota Camry,Driver,CA,USA, ' + 
                            '123456,Test Account,03-03-2018,Test Testing';
            csvFileBody = Blob.valueOf(str);
            String csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 
            newUser.csvFileBody = csvFileBody;
            newUser.readFromFile();
            newUser.deactivationDate = date.today();
            newUser.saveMethod();
            newUser.deActiveMessage();
            newUser.saveUserNameMethod();
            newUser.updateContactSingle();
            newUser.saveData();
            newUser.ulist = [SELECT Id,
                                    ContactId,
                                    Contact.Name,
                                    LastName,
                                    Email,
                                    Contact.File_Number__c,
                                    Contact.Deactivated_Date__c, 
                                    Contact.Vehicle_Type__c,
                                    Contact.Employee_ID__c, 
                                    Contact.Email, 
                                    Contact.Manager__c, 
                                    Contact.MailingPostalCode,
                                    Contact.Driving_States__c, 
                                    Contact.MobilePhone,
                                    Contact.Role__c,
                                    IsActive  FROM User WHERE Id =: userInfo.getUserId() and IsActive = true AND ContactId != NULL and accountid != null LIMIT 1];
            system.debug('ulist'+[select Id,
                                    ContactId,
                                    Contact.Name,
                                    LastName,
                                    Email,
                                    Contact.File_Number__c,
                                    Contact.Deactivated_Date__c, 
                                    Contact.Vehicle_Type__c,
                                    Contact.Employee_ID__c, 
                                    Contact.Email, 
                                    Contact.Manager__c, 
                                    Contact.MailingPostalCode,
                                    Contact.Driving_States__c, 
                                    Contact.MobilePhone,
                                    Contact.Role__c,
                                    IsActive FROM User WHERE  Id =: userInfo.getUserId() and IsActive = true AND ContactId != NULL and accountid != null LIMIT 1]);
            newUser.updatecontact();
            //newUser.senEmailToAdminWithCsv();
            newUser.TabOne();
            newUser.TabTwo();
            newUser.goHome();
            newUser.rol = 'Driver';
            newUser.MonthlyReim();
            newUser.rol = 'Manager';
            newUser.MonthlyReim();
            RG_CreateNewUserPageClass.postHTTPCreateNewUserTriplog(new list<Id>{conList[0].id});
            conList[0].External_Email__c = 'test@mail.com';
            conList[0].FirstName = 'test@mail.com';
            conList[0].LastName = 'test@mail.com';
            conList[0].Role__c = 'Driver/Manager';
            newuser.contlist = new list<Contact>{conList[0]};
            newuser.save();
          }
          Test.stopTest();
    }
    
}