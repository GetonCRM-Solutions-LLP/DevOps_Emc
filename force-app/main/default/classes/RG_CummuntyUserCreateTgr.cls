/*
Author - Nitesh Kumawat (ApplikonTech IT Solution)
Date - 30 Sept 2016

*/
public with sharing class RG_CummuntyUserCreateTgr {
    public static Boolean isRecursive = false;

    public static void CommunityUserCreate(List<Contact> con) {
        list<User> createUser = new  list<User>();
        list<Contact> conlistUpdate = new  list<Contact>();
        map<string, Id> conemailtoid = new  map<string, ID>();
        for(Contact conlist: [SELECT
            id, 
            Manager__c, 
            External_Email__c, 
            Email
        FROM
            Contact]) {
            if(string.isNotBlank(conlist.External_Email__c)) {
                conemailtoid.put(conlist.External_Email__c.touppercase(), conlist.id);
            }
        }
        list<Profile> p = [SELECT
            Id, 
            Name
        FROM
            Profile
        WHERE
            Name = 'Customer Community Login User - Driver' OR Name = 'Customer Community Login User - Manager' OR Name = 'Customer Community Login User - Super Manager' OR Name = 'Customer Community Login User - Manager/Driver' OR Name = 'Customer Community Login User - Super Manager/Driver'];
        system.debug('Profile Size' + p.Size());
        if(Trigger.isbefore) {
            System.debug('conemailtoid.size==>' + conemailtoid.size());
            System.debug('conemailtoid==>' + conemailtoid);
            for(Contact cc: con) {
                if(string.isNotBlank(cc.Manager_External_Email__c)) {
                    if(conemailtoid.containsKey(cc.Manager_External_Email__c.touppercase())) {
                        cc.Manager__c = conemailtoid.get(cc.Manager_External_Email__c.touppercase());
                    }
                    //cc.accountid=Label.Accountid;
                    // if(cc.accountid==null)
                    // cc.addError('Account is Compulsary');
                }
            }
        }
        if(Trigger.isAfter) {
            for(Contact c: con) {
                if(c.IsCreatedFromCommunity__c == false) {
                    for(Profile pp: p) {
                        if(pp.Name == 'Customer Community Login User - Driver' && c.Role__c == 'Driver') {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Manager' && (c.Role__c == 'Manager')) {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Manager/Driver' && (c.Role__c == 'Driver/Manager')) {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Super Manager/Driver' && (c.Role__c == 'Admin/Driver')) {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                        if(pp.Name == 'Customer Community Login User - Super Manager' && c.Role__c == 'Admin') {
                            createUser.add(new  User(FirstName = c.FirstName, LastName = c.LastName, Email = c.External_Email__c, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = c.External_Email__c, Profileid = pp.Id, Alias = c.External_Email__c.left(8), ContactId = c.id));
                        }
                    }
                }
            }
        }
        if(createUser.Size() > 0) {
            Insert createUser;
        }
    }
    
    @future
    public static Void changeProfileRole(Set<Id> conIds) {
        string str = 'true';
        if(str.equalsIgnoreCase(Label.Is_Update_User_Profile)) {
            Map<Id, string> conIdRole = new  Map<Id, string>();
            Map<string, string> roleToProfileId = new  Map<string, string>();
            List<User> users = new  List<User>();
            for(Contact con: [SELECT
                Id, 
                Role__c
            FROM
                Contact
            WHERE
                Id IN : conIds]) {
                conIdRole.put(con.Id, con.Role__c);
            }
            users = [SELECT
                Id, 
                ContactId, 
                ProfileId
            FROM
                USER
            WHERE
                ContactId IN : conIds];
            for(Profile profile: [SELECT
                Id, 
                Name
            FROM
                Profile]) {
                if(profile.Name == 'Customer Community Login User - Driver') {
                    roleToProfileId.put('Driver', profile.Id);
                }
                if(profile.Name == 'Customer Community Login User - Manager') {
                    roleToProfileId.put('Manager', profile.Id);
                }
                if(profile.Name == 'Customer Community Login User - Manager/Driver') {
                    roleToProfileId.put('Driver/Manager', profile.Id);
                }
                if(profile.Name == 'Customer Community Login User - Super Manager') {
                    roleToProfileId.put('Admin', profile.Id);
                }
            }
            for(User user: users) {
                if(conIdRole.containsKey(user.ContactId) && roleToProfileId.containsKey(conIdRole.get(user.ContactId))) {
                    user.profileId = roleToProfileId.get(conIdRole.get(user.ContactId));
                }
            }
            if(!users.isEmpty()) {
                Update users;
            }
        }
    }
    public static Void setAdminAsManager(List<Contact> newContacts) {
        Set<Id> accountIds = new  Set<Id>();
        List<Contact> contacts = new  List<Contact>();
        List<Contact> contactsToInsert = new  List<Contact>();
        Map<Id, Id> accountToContact = new  Map<Id, Id>();
        for(Contact contact: newContacts) {
            if(contact.Manager__c == null && contact.Role__c != 'Admin') {
                accountIds.add(contact.AccountId);
                contacts.add(contact);
            }
        }
        for(Contact contact: [SELECT
            Id, 
            AccountId
        FROM
            Contact
        WHERE
            AccountId in: accountIds AND Role__c = 'Admin']) {
            accountToContact.put(contact.AccountId, contact.Id);
        }
        for(Contact contact: contacts) {
            if(accountToContact.containsKey(contact.AccountId)) {
                Contact contactClone = contact.clone(false, false, false, false);
                contactClone.Id = contact.Id;
                contactClone.Manager__c = accountToContact.get(contact.AccountId);
                contactsToInsert.add(contactClone);
            }
        }
        if(!contactsToInsert.isEmpty()) {
            isRecursive = true;
            update contactsToInsert;
            isRecursive = false;
        }
    }
    
    public static void updateComplianceStatus(List<Contact> newCon, Map<ID, Contact> conOldMap) {
        List<String> emails = new List<String>();
        EmailTemplate emTmp = new EmailTemplate();
        Messaging.SingleEmailMessage mail;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        // Define Email Template
        Map<String,EmailTemplate> nameWithTemplate = new Map<String,EmailTemplate>();
        for(EmailTemplate e : [SELECT Id, Name, developerName, Subject, body FROM EmailTemplate]) {
            nameWithTemplate.put(e.developerName, e);
        }
        OrgWideEmailAddress[] owea;
        owea = [select Id, address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        for(Contact con : newCon) {
            if(con.Role__c == 'Driver' && (conOldMap.get(con.id).compliancestatus__c != con.compliancestatus__c)) {
                emails.add(con.External_Email__c);
                if(con.compliancestatus__c == 'Yes' && nameWithTemplate.containskey('Driver_Compliance_Status_Yes')) {
                    emTmp = nameWithTemplate.get('Driver_Compliance_Status_Yes');
                } else if(con.compliancestatus__c == 'No – Vehicle Age' && nameWithTemplate.containskey('Driver_Compliance_Status_No_Vehicle_Age')) {
                    emTmp = nameWithTemplate.get('Driver_Compliance_Status_No_Vehicle_Age');
                } else if(con.compliancestatus__c == 'No – Vehicle Value' && nameWithTemplate.containskey('Driver_Compliance_Status_No_Vehicle_Value')) {
                    emTmp = nameWithTemplate.get('Driver_Compliance_Status_No_Vehicle_Value');
                } else if(con.compliancestatus__c == 'No – Insurance not meeting minimum' && nameWithTemplate.containskey('Driver_Compliance_Status_No_Insurance_not_meeting_minimum')) {
                    emTmp = nameWithTemplate.get('Driver_Compliance_Status_No_Insurance_not_meeting_minimum');
                } else if(con.compliancestatus__c == 'Resubmit Insurance – you submitted an insurance card' && nameWithTemplate.containskey('Driver_Compliance_Status_Resubmit_Insurance')) {
                    emTmp = nameWithTemplate.get('Driver_Compliance_Status_Resubmit_Insurance');
                }else{
                    emTmp = null;
                }
                system.debug('=====emTmp===>'+emTmp);
                //system.debug('=====emTmp===>'+emTmp);
                if(!emails.isEmpty() && emTmp != null) {
                    mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(emails);
                    //Set Email Subject
                    mail.setSubject(emTmp.Subject);
                    //Body of Email
                    mail.setPlainTextBody(emTmp.Body.replace('{!Contact.FirstName}', con.FirstName));
                    if(owea.size()>0) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    mail.setBccAddresses(new String[] {'natavar.goc@gmail.com','Minkesh.patel@getoncrm.com'});
                    mails.add(mail);                    
                }
            }
        }
        //Sending the Email
        SendEmail__c  objSendEmail = SendEmail__c.getValues('Send Email For Compliance');
        if(objSendEmail.Send_email_from_code__c==true)
        {
            Messaging.sendEmail(mails);
        }
           
    }

    @future
    public static void updateUserEmail (Set<Id> contactIds) {
        List<User> listofUsers = new List<User>();
        if(!contactIds.isEmpty()) {
            for(User singleUser : [SELECT Id,Email,UserName,ContactId,Contact.External_Email__c FROM User WHERE ContactId IN: contactIds]) {
                singleUser.UserName = singleUser.Contact.External_Email__c;
                singleUser.Email = singleUser.Contact.External_Email__c;
                listofUsers.add(singleUser);
            }
        }
        if(!listofUsers.isEmpty()) {
            try {
                update listofUsers;
            }catch (DmlException e) {
                System.debug('listofUsers:'+e.getMessage());
            }
        }
    }
    
    @future
    public static void updateUserData (Set<Id> contactNameChange) {
        List<User> updateUser = new List<User>();
        if(!contactNameChange.isEmpty()) {
            for(User userData : [SELECT Id,Contact.FirstName,Contact.LastName FROM User WHERE ContactId IN: contactNameChange]) {
                userData.FirstName = userData.Contact.FirstName;
                userData.LastName = userData.Contact.LastName;
                updateUser.add(userData);
            }
        }
        if(!updateUser.isEmpty()) {
            try {
                update updateUser;
            } catch (DmlException e) {
                System.debug('updateUser:' +e.getMessage());
            }
        }
    }
    public static Void sendEmailToAdmin(List<Contact> newContacts, Map<Id, Contact> oldContacts, List<Contact> oldCons) {
        OrgWideEmailAddress[] owea = [SELECT
            Id, 
            address
        FROM
            OrgWideEmailAddress
        WHERE
            Address = 'driverservices@mburse.com'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<Id, String> oldContactIdToName = new Map<Id, String>();
        List<Contact> contacts = new List<Contact>([SELECT Id, Name, FirstName, LastName, Deactivated_Date__c, Role__c, Vehicle_Type__c, Manager__c, Manager__r.Name, Manager__r.FirstName, Manager__r.LastName,
            MailingPostalCode, Employee_ID__c, Email, File_Number__c FROM Contact WHERE Id IN : newContacts]);
        for(Contact oldCon : [SELECT Id,Name, Manager__r.Name FROM Contact WHERE Id IN : oldCons]) {
            oldContactIdToName.put(oldCon.Id, oldCon.Name);
        }
        for(Contact contact : contacts) {
            if(!owea.isEmpty() && contact.Deactivated_Date__c != oldContacts.get(contact.Id).Deactivated_Date__c ||
                contact.Role__c != oldContacts.get(contact.Id).Role__c ||
                contact.Vehicle_Type__c != oldContacts.get(contact.Id).Vehicle_Type__c ||
                contact.Manager__c != oldContacts.get(contact.Id).Manager__c ||
                contact.MailingPostalCode != oldContacts.get(contact.Id).MailingPostalCode ||
                contact.Employee_ID__c != oldContacts.get(contact.Id).Employee_ID__c ||
                contact.Email != oldContacts.get(contact.Id).Email ||
                contact.File_Number__c != oldContacts.get(contact.Id).File_Number__c) {
                string htmlBody = 'Hi, the following details of drivers have been changed. <br/><br/>';
                htmlBody += '<div style="border:2px border-radius:15px;">' + '<table style="border:3px solid black; border-collapse:collapse;">' + '<tr  bgcolor="#d4d4d4">' + '<th style="border:2px solid black;" width="5%">User</th>' + '<th style="border:2px solid black;" width="5%">Deactivation Date</th>' + '<th style="border:2px solid black;" width="5%">Role</th>' + '<th style="border:2px solid black;" width="5%">Standard Vehicle</th>' + '<th style="border:2px solid black;" width="5%">Manager</th>' + '<th style="border:2px solid black;" width="5%">Home Zip Code</th>' + '<th style="border:2px solid black;" width="5%">Employee Id</th>' + '<th style="border:2px solid black;" width="5%">Email</th>' + '<th style="border:2px solid black;" width="5%">File Number</th>';
                htmlBody += +'</tr>';
                htmlBody += +'<tr align="center">' + '<td style="border:2px solid black;">' + contact.FirstName + ' ' +contact.LastName + '</td>';
                if(contact.Deactivated_Date__c != oldContacts.get(contact.Id).Deactivated_Date__c) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContacts.get(contact.Id).Deactivated_Date__c + ' To ' + contact.Deactivated_Date__c + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                if(contact.Role__c != oldContacts.get(contact.Id).Role__c) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContacts.get(contact.Id).Role__c + ' To ' + contact.Role__c + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                if(contact.Vehicle_Type__c != oldContacts.get(contact.Id).Vehicle_Type__c) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContacts.get(contact.Id).Vehicle_Type__c + ' To ' + contact.Vehicle_Type__c + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                if(contact.Manager__c != oldContacts.get(contact.Id).Manager__c) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContactIdToName.get(oldContacts.get(contact.Id).Manager__c) + ' To ' + contact.Manager__r.FirstName +  ' ' + contact.Manager__r.LastName + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                if(contact.MailingPostalCode != oldContacts.get(contact.Id).MailingPostalCode) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContacts.get(contact.Id).MailingPostalCode + ' To ' + contact.MailingPostalCode + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                if(contact.Employee_ID__c != oldContacts.get(contact.Id).Employee_ID__c) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContacts.get(contact.Id).Employee_ID__c + ' To ' + contact.Employee_ID__c + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                if(contact.Email != oldContacts.get(contact.Id).Email ) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContacts.get(contact.Id).Email + ' To ' + contact.Email + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                if(contact.File_Number__c != oldContacts.get(contact.Id).File_Number__c) {
                    htmlBody += +'<td style="border:2px solid black;"> From ' + oldContacts.get(contact.Id).File_Number__c + ' To ' + contact.File_Number__c + '</td>';
                } else {
                    htmlBody += +'<td style="border:2px solid black;"> None </td>';
                }
                htmlBody += +'</tr>';
                htmlBody += '</table>';
                messaging.singleEmailMessage mail = new  messaging.singleEmailMessage();
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
                //Setting user email in to address con.External_Email__c
                string[] toAddresses;
                toAddresses = new string[]{System.Label.DriverServicesEmail};
                // Assign the addresses for the To and CC lists to the mail object
                mail.setToAddresses(toAddresses);
                //Email subject to be changed
                mail.setSubject('Updated User Details');
                //Body of email
                mail.setHtmlBody(htmlBody);
                mail.setBccAddresses(new String[] {'natavar.goc@gmail.com','Minkesh.patel@getoncrm.com'});
                mails.add(mail);
            }
        }
        if(!mails.isEmpty()) {
            //Messaging.sendEmail(mails);
        }
    }
    
}