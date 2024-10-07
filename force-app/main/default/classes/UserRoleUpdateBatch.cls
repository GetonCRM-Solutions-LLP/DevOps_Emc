global class UserRoleUpdateBatch implements Database.Batchable<sObject>,Database.Stateful{
    global Map<String, String> roleToProfileId;
    global List<User> userList;
    global List<User> userList1;
    global list<string> UserReq;
    public string header = 'Account Name, Contact Name, Role,Old Profile\n';
    public string finalstr = header ; 
    global UserRoleUpdateBatch() {

        userList = new List<User>();
        userList1 = new List<User>();
        roleToProfileId = new  Map<String, String>();
        UserReq = new List<string>();
        UserReq.add('Customer Community Login User - Driver');
        UserReq.add('Customer Community Login User - Manager');
        UserReq.add('Customer Community Login User - Manager/Driver');
        UserReq.add('Customer Community Login User - Super Manager');
        UserReq.add('Customer Community Login User - Super Manager/Driver');
        for(Profile prof : [SELECT Id, Name FROM Profile WHERE Name IN : UserReq]) {
            if(prof.Name == 'Customer Community Login User - Driver') {
                roleToProfileId.put('Driver', prof.Id);
            }
            if(prof.Name == 'Customer Community Login User - Manager') {
                roleToProfileId.put('Manager', prof.Id);
            }
            if(prof.Name == 'Customer Community Login User - Manager/Driver') {
                roleToProfileId.put('Driver/Manager', prof.Id);
            }
            if(prof.Name == 'Customer Community Login User - Super Manager') {
                roleToProfileId.put('Admin', prof.Id);
            }
            if(prof.Name == 'Customer Community Login User - Super Manager/Driver') {
                roleToProfileId.put(StaticValues.roleAdminDriver, prof.Id);
            }
        }
        for(User u:[SELECT Id, ContactId,contact.Name,Contact.FirstName,Contact.LastName,Contact.Email,Name,Email,FirstName,LastName,ProfileId,Profile.Name,Contact.Account.Name,Contact.Deactivated_Date__c, Contact.Role__c
                                    FROM USER
                                    WHERE IsActive = true and Profile.Name IN : UserReq and (Contact.Deactivated_Date__c = null OR Contact.Deactivated_Date__c > today) and Contact.Role__c != null])
                                    {
                                        if((u.Contact.Role__c == 'Driver' && u.ProfileId != roleToProfileId.get('Driver')) ||
                                           (u.Contact.Role__c == 'Manager' && u.ProfileId != roleToProfileId.get('Manager')) || 
                                           (u.Contact.Role__c == 'Driver/Manager' && u.ProfileId != roleToProfileId.get('Driver/Manager'))||
                                           (u.Contact.Role__c == 'Admin' && u.ProfileId != roleToProfileId.get('Admin')) || 
                                           (u.Contact.Role__c == StaticValues.roleAdminDriver && u.ProfileId != roleToProfileId.get(StaticValues.roleAdminDriver)) || 
                                           (u.Name != u.Contact.Name || u.Email != u.Contact.Email)) 
                                            
                                        {                                            
                                            userList.add(u);
                                        }
                                    }
    }

    global List<User> start(Database.BatchableContext BC) {
        return userList;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        for(User u: (List<User>)scope)
        {
            string recordString  = u.contact.Account.Name + ',' + u.contact.Name + ',' + u.Contact.Role__c + ',' + u.Profile.Name +  '\n';
            finalstr = finalstr + recordString;            
            u.ProfileId = roleToProfileId.get(u.Contact.Role__c);
            if(u.Name != u.Contact.Name){
                u.FirstName = u.Contact.FirstName;
                u.LastName = u.Contact.LastName;
            } 
            if(u.Email != u.Contact.Email){
                u.Email = u.Contact.Email;
            }           
            userList1.add(u);
        }
        if(userList1.size()>0)
        {
            update userList1;
        }
    }

    global void finish(Database.BatchableContext BC) {
        if(userList1.size()>0)
        {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(finalstr);
            string csvname = 'Updated Users.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {'sanket.goc@gmail.com'};
           
            email.setToAddresses(toAddresses);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            email.setSubject('Updated Profiles for Users '+ string.valueOf(System.now()));         
            email.setPlainTextBody('Hi, Please Find the CSV for Updated Profiles for Users. Thank you.');            
            if(!Test.isRunningTest()) 
            {
                Messaging.SendEmailResult [] sendSinglemail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
        
    }
}