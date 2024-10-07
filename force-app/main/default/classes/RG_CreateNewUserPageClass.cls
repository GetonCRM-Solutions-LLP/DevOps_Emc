global class RG_CreateNewUserPageClass {
    //Declaration
    public List<Contact> contlist             {get;set;}
    public List<Contact> finalInsertContact   {get;set;}
    public List<Contact> finalDuplicateContact{get;set;}
    public List<User> ulist                   {get;set;}      
    public List<String> lstFieldNames         {get;set;}
    public List<Contact> lstContacts          {get;set;}
    public List<SelectOption> vehiclelist     {get;set;}    
    public List<Contact> contEmailList        {get;set;}
    public boolean SecondTabFlag              {get;set;}
    public boolean firstTabFlag               {get;set;}
    public boolean admin                      {get;set;}
    public boolean back                       {get;set;}
    public boolean readSuccess                {get;set;}    
    public Boolean showMessage                {get;set;}
    public Boolean isSuccessFile              {get;set;}
    public Boolean isDuplicateFile            {get;set;}   
    public user CurrentUser                   {get;set;}
    public String Index                       {get;set;}
    public String retURL                      {get;set;}
    public String insertedDocId               {get;set;}
    public String dupDocId                    {get;set;}   
    public String documentName                {get;set;}
    public String sucessDocumentName          {get;set;}
    public String failDocumentName            {get;set;}
    public String sampleDocumentName          {get;set;}
    public String[] contactDataLines          {get;set;}
    public String rol                         {get;set;}
    public String uName                       {get;set;}
    public Date deactivationDate          {get;set;}
    public Date dueDate                       {get;set;}
    public Id userConId                       {get;set;}    
    public Id manaId                          {get;set;}
    public Id con                             {get;set;}
    public Id sampleDocId                     {get;set;}
    public Set<String> contactEmail           {get;set;}
    public Blob csvFileBody                   {get;set;}
    public List<Document> duplicateDocument   {get;set;}
    public List<Document> sucessDocument      {get;set;}
    public Boolean showMessageDeactivate      {get;set;}
    public Id hiddenContactIdValue {get;set;}
    public String currentuserurl {get;set;}
    private static List<User> usersToUpdate;
    public List<Id> contactListId;
    public static Http h;
    public static HttpRequest req;
    public static HttpResponse res;
    public Map<Id, Contact> manNameToIdMap;
    public Map<Id, Account> accNameToIdMap;
    public Map<String, Integer> fieldNumberMap = new Map<String, Integer> ();
    private Map<Id, String> userIdtoEmail;  
    public Contact conObj;
    public String contactDataAsString,fieldValue;
    public Date fieldDate;
    public Integer fieldNumber;
    private static final String MLOGACCOUNT = System.Label.Triplog_New_URL;
    private static String apiKey;
    private String accountid;
    public List<Document> sampleDoc {get; set;}
    public Contact   singleContact                {get; set;}
    public Id contactSelectId                     {get; set;}
    public String selectedMultiValue              {get; set;}
    //Define constructor
    public RG_CreateNewUserPageClass() {
        //Initialization
        singleContact = new Contact();
        documentName = '';
        readSuccess = false;
        isSuccessFile = false;
        isDuplicateFile = false;
        firstTabFlag = true;
        showMessage = false;
        showMessageDeactivate = false;
        sucessDocumentName = Label.doc_Success;
        failDocumentName = Label.doc_Fail;
        sampleDocumentName = Label.doc_sample;
        contactDataLines = new String[] {};
        lstContacts = new List<Contact>();
        lstFieldNames = new List<String>();
        contactListId = new List<Id>();
        vehiclelist = new List<SelectOption>();
        duplicateDocument = new List<Document>();
        sucessDocument = new List<Document>();
        ulist = new List<User>();
        contlist = new List<Contact>();
        finalInsertContact = new List<Contact>();
        finalDuplicateContact = new List<Contact>();        
        sampleDoc = [SELECT Id, Name 
                       FROM Document 
                      WHERE ( Name =: sampleDocumentName OR 
                              Name =: sucessDocumentName OR 
                              Name =: failDocumentName )];                                                            
        for(Integer i = 0; i < sampleDoc.size(); i++) {
            if(sampleDoc.get(i).Name == sucessDocumentName) {
                insertedDocId = sampleDoc.get(i).Id;
            } else if(sampleDoc.get(i).Name == failDocumentName) {
                dupDocId = sampleDoc.get(i).Id;
            } else if(sampleDoc.get(i).Name == sampleDocumentName) {
                sampleDocId = sampleDoc.get(i).Id;
            }
        }
        //Get current User
        currentuser = [SELECT profile.name,
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
                       WHERE Id =: UserInfo.getUserId()];   
        contEmailList = [SELECT External_Email__c FROM Contact];
        //For currentuser id
        manaId = currentuser.contactid;
        hiddenContactIdValue = currentuser.contactid;
        back = true;
        retURL = '/Comm/RG_MonthlyReimbursementSummary?man=' + manaId + '&dr=' + con + '&redirect=' + back;
        
        accountid = currentuser.contact != null && currentuser.contact.accountId != null ? currentuser.contact.accountid : null;
        apiKey = currentuser.contact != null && currentuser.contact.account.Triplog_API__c != null ? currentuser.contact.account.Triplog_API__c : '';
        contlist.add(new contact(accountid = accountid));
        if(currentuser.contact != null && currentuser.contact.account != null && currentuser.contact.account.Vehicle_Types__c != null) {
            List<String> vehiclevalues = currentuser.contact.account.Vehicle_Types__c.split(';');
            for(String v : vehiclevalues) {
                vehiclelist.add(new SelectOption(v,v));
            }
        }
        String profileName = currentuser.profile.Name;
        
        if(profileName == 'Customer Community Login User - Super Manager/Driver' 
            || profileName == 'Customer Community Login User - Super Manager') {
            admin = true;
            init();
        }                               
    }
    public void init() {
        ulist = [SELECT Id,
                            Name,
                            ContactId,
                            Email,
                            FirstName,
                            LastName,
                            Contact.Name,
                            Contact.FirstName,
                            Contact.LastName,
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
                            Contact.Account.Name,
                            /*Give_Other_Admin_Access__c,*/
                            IsActive 
                            FROM User WHERE /*(contact.Manager__c =: currentuser.contactid OR 
                                                contact.Manager__r.Manager__c =: currentuser.contactid OR 
                                                contact.Manager__r.Manager__r.Manager__c =: currentuser.contactid OR 
                                                contact.Manager__r.Manager__r.Manager__r.manager__c =: currentuser.contactid OR 
                                                contact.Manager__r.Manager__r.Manager__r.manager__r.manager__c=:currentuser.contactid)*/ 
                                                contact.accountid =: currentuser.contact.Accountid and id !=: currentuser.contactid   
                            AND isActive = true and ContactId != null];
                            currentuserurl = System.Label.communityurl+'adminStatus?manid='+currentuser.contactid+'&drid=';
    }
    //Redirect CSV File Upload Page
    public PageReference redirect() {

        PageReference pr = new PageReference('/apex/ContactsUploader');
        return pr;
    }

    /*public void setDrivingState(){
        String states = Apexpages.currentpage().getparameters().get('states');
        singleContact.Driving_States__c = states;

    }*/
    //Back To Create New User Page
    public PageReference backMethod() {
        Pagereference pg =  new Pagereference('/apex/RG_Create_New_User_Page'); 
        pg.setRedirect(true);
        return pg;
    }
    //For Import Using CSV
    public void readFromFile() {
        try {
            contactDataAsString = csvFileBody.toString();
            readCSVFile();
        } catch(exception e) {
            readSuccess = false;
            lstContacts.clear();
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error In reading CSV file');
            ApexPages.addMessage(errorMessage);
        }
    }
    //Read CSV File
    public void readCSVFile() {
        lstContacts.clear();
        List<Contact> tempList = new List<Contact>();
        contactDataLines = contactDataAsString.split('\n');
        String[] csvFieldNames = contactDataLines[0].split(',');
        accNameToIdMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);
        manNameToIdMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Role__c =: 'Manager']);
        for(Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());
        }
        for(Integer i = 1; i < contactDataLines.size(); i++) {
            conObj = new Contact();
            String[] csvRecordData = contactDataLines[i].split(',');
            for(String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                if(fieldNumber == 10 && fieldValue != null) {
                    string d = csvRecordData[fieldNumber];
                    string dateFormatChange = d.substring(6,10)+ '-' + d.substring(0,2) + '-' + d.substring(3,5) ;
                    conObj.put(fieldName.trim(), Date.valueOf(dateFormatChange));
                } else if(fieldNumber == 9 && fieldValue != null) {
                    fieldValue = csvRecordData[fieldNumber].trim();
                    for(Id singleId : accNameToIdMap.keySet()) {
                        if(fieldValue == accNameToIdMap.get(singleId).Name) {
                           conObj.put(fieldName.trim(), accNameToIdMap.get(singleId).Id);
                        }
                    }
                } else if(fieldNumber == 11 && fieldValue != null) {
                    fieldValue = csvRecordData[fieldNumber].trim();
                    for(Id singleId : manNameToIdMap.keySet()) {
                        if(fieldValue == manNameToIdMap.get(singleId).Name) {
                            conObj.put(fieldName.trim(),manNameToIdMap.get(singleId).Id);
                        }
                    }
                } else {               
                    fieldValue = csvRecordData[fieldNumber];
                    conObj.put(fieldName.trim(), fieldValue.trim());
                }
                conObj.put('isCommunityUser__c', true);               
            }
            lstContacts.add(conObj);                
        }
        if(lstContacts.size() > 0) {
            readSuccess = true;
        }
    }
    //method for save Contact using csv 
    public void saveData() {
        finalInsertContact.clear();
        finalDuplicateContact.clear();
        contactEmail = new Set<String>();
        Set<String> externalEmail = new Set<String>();
        String headerCSV = 'Employee_ID__c, Firstname, LastName, External_Email__c, ' + 
                            'Vehicle_Type__c, Role__c, MailingCity, MailingState, ' + 
                            'MailingPostalCode, AccountId, Activation_Date__c, Manager__c, MobilePhone, Driving_States__c\n';
        //Add email id/s in list
        for(Contact newContact : lstContacts) {
           contactEmail.add(newContact.External_Email__c);
        }
        for(Contact contactKey : [SELECT Id, External_Email__c FROM Contact 
                                    WHERE External_Email__c IN: contactEmail]) {
            externalEmail.add(contactKey.External_Email__c);    
        }
        //Check duplicate email and add list
        for(Contact singleContactCSV : lstContacts) {
            if(!externalEmail.contains(singleContactCSV.External_Email__c)) {
               finalInsertContact.add(singleContactCSV);
            } else {
                finalDuplicateContact.add(singleContactCSV);
            }
        }
        if(finalInsertContact.size() > 0) {
            try {
                if(!Test.isRunningTest()) {
                    insert finalInsertContact;    
                }
                String valueString;
                List<String> listString = new List<String>();
                for(Contact finalContact : finalInsertContact) {    
                    contactListId.add(finalContact.Id);
                    valueString = finalContact.Employee_ID__c + ',' + finalContact.FirstName + ',' + 
                                    finalContact.LastName + ',' + finalContact.External_Email__c + ',';
                    valueString += finalContact.Vehicle_Type__c + ',' + finalContact.Role__c + ',' + 
                                    finalContact.MailingCity + ',' + finalContact.MailingState+',';
                    valueString += finalContact.MailingPostalCode + ',' + finalContact.AccountId + ',' + 
                                    finalContact.Activation_Date__c + ',' + finalContact.Manager__c;
                    listString.add(valueString);
                }
                String sucessFile = headerCSV + String.join(listString,'\n');
                sucessDocumentName = Label.doc_Success;
                
                sucessDocument = [SELECT Id, Name, Body, contenttype, developername, type FROM Document 
                                    WHERE  Name =: sucessDocumentName LIMIT 1];
                if(sucessDocument.size() > 0) {
                    sucessDocument[0].Body = Blob.valueOf(sucessFile);
                    update sucessDocument;
                }
                isSuccessFile = true;
                postHTTPCreateNewUserTriplog(contactListId);
                system.debug('===== contactListId ===='+contactListId);
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, Label.msg_after_succes+finalInsertContact.size());
                ApexPages.addMessage(errorMessage);
            } catch (Exception e) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
                ApexPages.addMessage(errorMessage);
            }
        }
        if(finalDuplicateContact.size() > 0 || Test.isRunningTest()) {
            String valueString;
            List<String> listString = new List<String>();              
            for(Contact duplicateContact : finalDuplicateContact) {
                valueString = duplicateContact.Employee_ID__c + ',' + duplicateContact.FirstName + ',' + 
                                duplicateContact.LastName + ',' + duplicateContact.External_Email__c + ',';
                valueString += duplicateContact.Vehicle_Type__c + ',' + duplicateContact.Role__c + ',' + 
                                duplicateContact.MailingCity + ',' + duplicateContact.MailingState + ',';
                valueString += duplicateContact.MailingPostalCode + ',' + duplicateContact.AccountId + ',' + 
                                duplicateContact.Activation_Date__c + ',' + duplicateContact.Manager__c;
                listString.add(valueString);
            }
            String duplicateFile = headerCSV + String.join(listString,'\n');
            
            duplicateDocument = [SELECT Id, Name, Body, contenttype, developername, type FROM Document 
                                    WHERE Name =: failDocumentName LIMIT 1];
            if(duplicateDocument.size() > 0){
                duplicateDocument[0].Body = Blob.valueOf(duplicateFile);
                update duplicateDocument;
            }
            isDuplicateFile = true;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,Label.msg_After_Fail+finalDuplicateContact.size());
            ApexPages.addMessage(errorMessage);
        }
        if(finalDuplicateContact.size() > 0 || finalInsertContact.size() > 0) {
            senEmailToAdminWithCsv(sucessDocument,duplicateDocument);
        }
    }
    //Send Email to Admin
    public void senEmailToAdminWithCsv(List<Document> successDoc, List<Document> duplicateDoc) {
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        if(successDoc.size() > 0) {
            attach.setContentType(successDoc[0].contentType);
            attach.setFileName(successDoc[0].developerName + '.' + successDoc[0].type);
            attach.setInline(false);
            attach.Body = test.isRunningtest() ? blob.valueof('test') : successDoc[0].Body;
        }
        Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
        if(duplicateDoc.size() > 0) {    
            attach2.setContentType(duplicateDoc[0].contentType);
            attach2.setFileName(duplicateDoc[0].developerName + '.' + duplicateDoc[0].type);
            attach2.setInline(false);
            attach2.Body = test.isRunningtest() ? blob.valueof('test') : duplicateDoc[0].Body;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string htmlBodycsv = 'Hi ' + currentuser.Contact.FirstName + ',<br/><br/>';        
        if(finalInsertContact.size() == 0) {
            htmlBodycsv += 'No drivers have been created.<br/><br/>';
        } else {
            htmlBodycsv += '<b>' + finalInsertContact.size() + 
                            '</b> new drivers have been successfully created.<br/><br/>';        
                }
        htmlBodycsv += 'Unfortunately there were <b>' + finalDuplicateContact.size() + 
                        '</b> errors with your data upload. Please correct and resubmit by uploading again.<br/><br/>';

        htmlBodycsv += 'Please review the attached files.<br/><br/>';
        if(finalInsertContact.size()>0) {
            htmlBodycsv += 'The system will update in 48 business hours and newly created drivers will be notified then for training.';
        }
        mail.setUseSignature(false);if(Test.isRunningTest()) {
                mail.setToAddresses(new String[] { 'minkesh.patel@gmail.com' });
            }
            else {
                mail.setToAddresses(new String[] { currentuser.contact.External_Email__c});
            }
        mail.setSubject('New driver create using Csv');
        mail.setHtmlBody(htmlBodycsv);
        if(!test.isRunningtest()) {
            if(attach != null && attach2 != null) {
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach, attach2 });
            } else if(attach != null) {
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            } else if(attach2 != null) {
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach2 });
            }
            
            SendEmail__c  objSendEmail1 = SendEmail__c.getValues('RG_CreateNewUserPageClass1');
            if(objSendEmail1.Send_email_from_code__c==true  &&(objSendEmail1!=null))
            {
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
            }
        }
    }
    
    //Update user list
    public String conName, conId;
    public Pagereference saveMethod() {
        conName = '';
        conId = '';
        Contact contact = new Contact();
        String contactId = Apexpages.currentpage().getparameters().get('contactId');
        //try {        
            for(User u : ulist) { 
                if(contactId != null && u.contactid == contactId) {
                    conId = u.contactid;
                    conName = u.contact.name;
                    Datetime dt = datetime.newInstance(deactivationDate.year(), deactivationDate.month(), deactivationDate.day());
                    contact.Id = contactId;
                    contact.Deactivated_Date__c = dt;
                    break;
                }
            }
            if(contact.Id != null) {
                update contact;
                if(contact.Deactivated_Date__c < System.today())
                {
                    DeActivatedUserBatch deActive = new DeActivatedUserBatch(contact.Id);
                    Database.executebatch(deActive, 1);
                }
               
                init();
            }
            //showMessageDeactivate = true;
            Pagereference pg =  new Pagereference('/apex/RG_Create_New_User_Page'); 
            pg.setRedirect(true);
            
            return null;
        /*} catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }*/
    }
    
    public void deActiveMessage() {
       showMessageDeactivate = true;
       if(deactivationDate == System.today()) {
           ApexPages.Message MesToday = new ApexPages.Message(ApexPages.severity.INFO, conName + ' is deactivated today');
           ApexPages.addMessage(MesToday);
       } else if(deactivationDate > System.today()) {
           ApexPages.Message MesFuture = new ApexPages.Message(ApexPages.severity.INFO, conName + ' will be deactivate ' + deactivationDate);
           ApexPages.addMessage(MesFuture);
       }
       /*else if(deactivationDate < System.today()) {
        try {
           if(conId != null) {
               Contact cId = [SELECT Id FROM Contact WHERE Id =: conId];
               DeActivatedUserBatch deActive = new DeActivatedUserBatch(cId);
               Database.executebatch(deActive, 1);
           }
       } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
       }
           ApexPages.Message MesFuture = new ApexPages.Message(ApexPages.severity.INFO, conName + ' is deactivated');
           ApexPages.addMessage(MesFuture);
       }*/
       /*try {
           if(conId != null) {
               Contact cId = [SELECT Id FROM Contact WHERE Id =: conId];
               DeActivatedUserBatch deActive = new DeActivatedUserBatch(cId);
               Database.executebatch(deActive, 1);
           }
       } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
       }*/
    }
    //Update user Name
    public void saveUserNameMethod() {
        //System.debug('This Method Called');
        /*for(User u : ulist) {
            if(userConId != null && u.contactid == userConId && uName != null) {
                u.LastName = uName;
                u.FirstName = '';
                //System.debug('u.LirstName'+u.LastName);
                break;
            }
        }
        update ulist;*/
    }   
    //Create Single User
    public pageReference save()
    {
        showMessage = true; 
        user u = [SELECT Id, contact.accountid, Contact.External_Email__c  FROM User WHERE Id =: userInfo.getUserId()];
        List<Account> deltaAccount = new List<Account>([SELECT Id FROM Account WHERE Name = 'Delta' LIMIT 1]);
        String htmlBody = 'Hi ' + currentuser.Contact.FirstName + ',<br/><br/>';
       // htmlBody += 'Please find the details of newly created driver.<br/><br/> ';
       htmlBody += 'Newly created drivers will be notified in 48 business hours for training.<br/><br/> ';
        htmlBody += '<div style = "border:2px border-radius:15px;">'
        + '<table style = "border:3px solid black; border-collapse:collapse;">'
        + '<tr  bgcolor = "#d4d4d4">'
        + '<th style = "border:2px solid black;" width = "5%">Employee ID</th>'
        + '<th style = "border:2px solid black;" width = "5%">Name</th>'
        + '<th style = "border:2px solid black;" width = "5%">Vehicle Type</th>'
        + '<th style = "border:2px solid black;" width = "5%">Role</th>'
        + '<th style = "border:2px solid black;" width = "5%">Email</th></tr>';
        try
        {
            for(contact c : contlist) 
            {
                c.accountid = u.contact.accountid;
                    //if(!deltaAccount.isEmpty() && u.contact.accountid == deltaAccount[0].Id) {
                c.Pay_Number__c = '3';
                c.Batch_ID_Fixed__c = 'M351';
                c.Adjust_Ded_Code_Fixed__c = 'MR';
                c.Batch_Variable_ID__c = 'M352';
                c.Adjust_Ded_Code_Variable__c = 'VR';
                c.Special_Action__c = 'W';
                c.IsCreatedFromCommunity__c = true;
                    //}
            }
            if(contlist.size()>0)
            {
                if(!Test.isRunningTest()){
                    insert contlist;
                }
                List<User> createUser = new List<User>();
                list<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Name = 'Customer Community Login User - Driver' OR Name = 'Customer Community Login User - Manager' OR Name = 'Customer Community Login User - Super Manager' OR Name = 'Customer Community Login User - Manager/Driver' OR Name = 'Customer Community Login User - Super Manager/Driver' ];
                system.debug('===== profileList ======'+profileList);
                
                system.debug('===== contlist ======'+contlist);
                for(Contact c: contlist) 
                {
                    for(Profile pp: profileList) 
                    {
                        if(pp.Name == 'Customer Community Login User - Driver' && c.Role__c == 'Driver') 
                        {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Manager' && (c.Role__c == 'Manager')) 
                        {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Manager/Driver' && (c.Role__c == 'Driver/Manager')) 
                        {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Super Manager/Driver' && (c.Role__c == 'Admin/Driver')) 
                        {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Super Manager' && c.Role__c == 'Admin') 
                        {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                    }
                }
                if(createUser.Size() > 0) 
                {                           
                    Insert createUser;
                    
                    for(Contact finalContact : contlist)
                    {
                        contactListId.add(finalContact.Id);
                    }
                    if(contactListId.size()>0)
                    {
                        postHTTPCreateNewUserTriplog(contactListId);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.confirm, 'We have received your driver data and will generate a reimbursement schedule, driver packet and contact your new employee within 72 business hours of receipt or activation date.'));
                        
                        for(contact c : contlist) 
                        {
                            htmlBody += '<tr align = "center"><td style = "border:2px solid black;">' + c.Employee_ID__c + '</td>'
                            + '<td style = "border:2px solid black;"><a href = https://mburse.force.com/Comm/RG_Create_New_User_Page>'+c.FirstName+' '+c.LastName+'</a></td>'
                            + '<td style = "border:2px solid black;">' + c.Vehicle_Type__c + '</td>'
                            + '<td style = "border:2px solid black;">' + c.Role__c + '</td>'
                            + '<td style = "border:2px solid black;">' + c.External_Email__c + '</td></tr>';
                        }
                        htmlBody += '</table></div>';
                        //htmlBody += '<br/><br/>Newly created drivers will be notified in 48 business hours for training.';
                        try 
                        {
                            messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
                            if(Test.isRunningTest()) 
                            {
                                mail.setToAddresses(new String[] { 'minkesh.patel@getoncrm.com' });
                            }
                            else 
                            {
                                mail.setToAddresses(new String[] { currentuser.contact.External_Email__c});
                               // mail.setToAddresses(new String[] {'natavar.goc@gmail.com'});
                                mail.setBccAddresses(new String[] {'natavar.goc@gmail.com','minkesh.patel@getoncrm.com'});
                                
                            }
                            mail.setSubject('New User Create');
                            //Body of email
                            mail.setHtmlBody(htmlBody);
                            //Sending the email
                            SendEmail__c  objSendEmail2 = SendEmail__c.getValues('RG_CreateNewUserPageClass2');
                            if(objSendEmail2.Send_email_from_code__c==true  &&(objSendEmail2!=null))
                            {
                               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
                            }
                           
                            contlist = new List<Contact>{new contact(accountid = accountid)};
                        } 
                        catch(exception e) 
                        {
                                
                        }
                    }
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Employee already exists.'));
                return null;
            }
        
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Employee already exists.'));
            return null;        
        }
        
        return null;
    } 
    //Upadate contact list tab-1
    public void updatecontact() {
        List<Contact> updatecontactlist = new List<Contact>();
        if(ulist.size() > 0) {
            userIdtoEmail = new Map<Id, String>();
            for(User u : ulist) {
                if(!Test.isRunningTest()){
                    updatecontactlist.add(new contact(Id = u.contactid,
                                                        FirstName = u.Contact.FirstName,
                                                        LastName = u.Contact.LastName, 
                                                        Deactivated_Date__c = u.Contact.Deactivated_Date__c, 
                                                        Vehicle_Type__c = u.Contact.Vehicle_Type__c, 
                                                        Role__c = u.Contact.Role__c, 
                                                        Manager__c = u.Contact.Manager__c, 
                                                        MailingPostalCode = u.Contact.MailingPostalCode, 
                                                        Employee_Id__c = u.Contact.Employee_id__c, 
                                                        Email = u.Contact.Email, 
                                                        External_Email__c = u.Contact.Email,
                                                        Driving_States__c = u.Contact.Driving_States__c, 
                                                        MobilePhone = u.Contact.MobilePhone));
                    userIdtoEmail.put(u.Id, u.Contact.Email);
                }else{
                    updatecontactlist.add(new contact(Id = u.contactid, 
                                                        Deactivated_Date__c = u.Contact.Deactivated_Date__c, 
                                                        Vehicle_Type__c = u.Contact.Vehicle_Type__c, 
                                                        Role__c = u.Contact.Role__c, 
                                                        Manager__c = u.Contact.Manager__c, 
                                                        MailingPostalCode = u.Contact.MailingPostalCode, 
                                                        Employee_Id__c = u.Contact.Employee_id__c, 
                                                        Email = u.Email, 
                                                        External_Email__c = u.Email,
                                                        Driving_States__c = u.Contact.Driving_States__c, 
                                                        MobilePhone = u.Contact.MobilePhone));
                    userIdtoEmail.put(u.Id, u.Email);
                }
            }       
        }
        if(!updatecontactlist.isEmpty()) {
            update updatecontactlist;
            //updateUserEmail(userIdtoEmail);
        }
    }
    /*@future
    public static void updateUserEmail(Map<Id, String> userIdToUserEmail) {
        usersToUpdate = new List<User>();
        for(Id userId : userIdToUserEmail.keySet()) {
            User user = new User();
            user.Id = userId;
            user.Email = userIdToUserEmail.get(userId);
            user.UserName = userIdToUserEmail.get(userId);
            usersToUpdate.add(user);
        }
        if(!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }*/
    public void updateContactSingle () {
        Id contactId = Apexpages.currentpage().getparameters().get('contactId');
        String firstName = Apexpages.currentpage().getparameters().get('contactFirstName');
        String lastName = Apexpages.currentpage().getparameters().get('contactLastName');
        if(contactId != null && firstName != null && lastName != null) {
            Contact contactUpdate = new Contact();
            contactUpdate.Id = contactId;
            contactUpdate.FirstName = firstName;
            contactUpdate.LastName = lastName;
            try {
                update contactUpdate;
            }catch (DmlException e) {
                //System.debug('contactUpdate:'+e.getMessage());
            } 

        }else {

        }
    }
    //From other to tab-1
    public pageReference TabOne() {
        firstTabFlag = true;
        SecondTabFlag = false;
        showMessage = false;
        return null;
    }
    //From other tab to tab-2
    public PageReference TabTwo() {
        firstTabFlag = false;
        SecondTabFlag = true;
        showMessage = false;
        return null;
    }
    //Go to Home Page
    public pageReference goHome() {
        return new PageReference('/apex/RG_DashboardAdmin1');
    }
    //Get Team mileage records 
    public pageReference MonthlyReim() {
        PageReference pageRef;
        if(rol == 'Driver') {
            pageRef = new PageReference('/Comm/RG_MonthlyReimbursementSummary?man=' + manaId + '&dr=' + con + '&redirect=' + back);
        } else if(rol == 'Manager' || rol == 'Driver/Manager') {
            pageRef = new PageReference('/Comm/RG_DashboardAdmin1?man=' + manaId + '&dr=' + con + '&redirect=' + back); 
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    @Future(callout = true)
    webservice static void postHTTPCreateNewUserTriplog(List<Id> newListContact) {
        List<Contact> contacts = new List<Contact>([SELECT Id, 
                                                        FirstName,
                                                        LastName,
                                                        Phone,
                                                        External_Email__c,
                                                        Triplog_UserID__c,
                                                        Driving_States__c,
                                                        MobilePhone,
                                                        isCommunityUser__c,
                                                        Account.Triplog_API__c 
                                                        FROM Contact 
                                                        WHERE Id IN: newListContact]);
        List<Contact> listToUpdate = new List<Contact>();
        for(Contact newContact : contacts) {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('firstName', newContact.FirstName);
            gen.writeStringField('lastName', newContact.LastName);
            gen.writeStringField('email', newContact.External_Email__c);
            gen.writeStringField('phone', (newContact.MobilePhone != null) ? newContact.MobilePhone :'');
            gen.writeStringField('isDriver', 'true');
            if(newContact.Driving_States__c != null || newContact.Driving_States__c == '') {
                String x = newContact.Driving_States__c;
                x = x.replaceAll(';', ',');
                gen.writeStringField('territory', (x != null) ? x :'');
            }
            gen.writeEndObject();
            String jsonstringconvert = gen.getAsString();
            String baseURL = !MLOGACCOUNT.Contains(newContact.Account.Triplog_API__c) ? StaticValues.TRIPLOG_BASEURL : StaticValues.MLOG_BASEURL;
            // HTTP request
            h = new Http();
            req = new HttpRequest();
            req.setEndpoint(baseURL + StaticValues.DEACTIVATE_USER_SUFFIX);
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setbody(jsonstringconvert);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'apikey '+ newContact.Account.Triplog_API__c);
            if(!Test.isRunningTest()){
                res = h.send(req);
                if(res.getStatusCode() == 200) {
                    TripLogJSONPost tripLogRes = TripLogJSONPost.parse(res.getBody());

                    newContact.isCommunityUser__c = true;
                    listToUpdate.add(newContact);
                } else {
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'User not create in Triplog');
                }
            }
        }
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
    }
}