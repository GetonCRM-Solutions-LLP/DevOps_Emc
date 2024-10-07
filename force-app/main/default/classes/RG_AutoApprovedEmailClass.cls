public class RG_AutoApprovedEmailClass implements Database.Batchable<sObject> {
    public list<contact> start(Database.BatchableContext BC) {
     List<String> obj_accountnames = new List<String>();
     List<String> obj_accountnames1 = new List<String>();
        if(System.Label.TripstobeLogged!=null || System.Label.TripstobeLogged!= '')
        {
            if(System.Label.TripstobeLogged.contains(','))
            {
                obj_accountnames= System.Label.TripstobeLogged.split(',');
            }
            for(String s:obj_accountnames)
            {
                s = s.trim();
                if(s.contains(','))
                {
                    s = s.replace(',','');
                }
                obj_accountnames1.add(s);                
            }           
        }        
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        list<user> userlist;
        if(obj_accountnames1.size()>0)
        {
            userlist = [SELECT email,contactid FROM user WHERE IsActive = : true AND contactid != null AND contact.accountid != null AND contact.account.Enable_Email_For_Managers__c = true and contact.account.Name =:obj_accountnames1];
        }
        else
        {
           userlist = [SELECT email,contactid FROM user WHERE IsActive = : true AND contactid != null AND contact.accountid != null AND contact.account.Enable_Email_For_Managers__c = true]; 
        }
        
        list<id> cIdList = new  list<id>();
        for(user u: userlist) 
        {
            cIdList.add(u.contactid);
        }
        list<contact> conlist;
        Datetime currentDate = System.now();
        if(obj_accountnames1.size()>0 && !Test.isRunningTest())
        {
            conlist = [SELECT id,Role__c,
                                account.Enable_Email_For_Managers__c,
                                Deactivated_Date__c,External_Email__c,
                                Account.Approval_Template_Message__c,
                                Monthly_Mileage_Limit__c,name,
                                (SELECT Role__c,id,name,
                                Monthly_Mileage_Limit__c 
                                FROM drivers__r) 
                            FROM contact 
                            WHERE id in: cIdList 
                                AND accountid != null 
                                AND account.Enable_Email_For_Managers__c = true 
                                AND Role__c != ''
                                AND ( Driver_Type__c != 'Driver - Full Time' or Driver_Type__c != 'Driver - Part Time' )
                                AND account.Name =:obj_accountnames1 
                                AND (Deactivated_Date__c = NULL OR Deactivated_Date__c <=: currentDate)];            
        }
        else if(obj_accountnames1.size()==0 && !Test.isRunningTest())
        {
           conlist = [SELECT id,Role__c,
                            account.Enable_Email_For_Managers__c,
                            Deactivated_Date__c,External_Email__c,
                            Account.Approval_Template_Message__c,
                            Monthly_Mileage_Limit__c,name,
                            (SELECT Role__c,id,name,
                                Monthly_Mileage_Limit__c 
                                FROM drivers__r) 
                        FROM contact 
                        WHERE id in: cIdList 
                            AND accountid != null 
                            AND account.Enable_Email_For_Managers__c = true 
                            AND Role__c != '' 
                            AND ( Driver_Type__c != 'Driver - Full Time' or Driver_Type__c != 'Driver - Part Time' )
                            AND (Deactivated_Date__c = NULL OR Deactivated_Date__c <=: currentDate)];
        }
        else
        {
           conlist = [SELECT id,Role__c,account.Enable_Email_For_Managers__c,Deactivated_Date__c,External_Email__c,Account.Approval_Template_Message__c,Monthly_Mileage_Limit__c,name,(SELECT Role__c,id,name, Monthly_Mileage_Limit__c FROM drivers__r) FROM contact WHERE id in: cIdList AND accountid != null AND account.Enable_Email_For_Managers__c = true AND Role__c != '' LIMIT 1];
        }

        return conlist;
    }
    public void execute(Database.BatchableContext BC, list<contact> conlist) {
        System.debug('conlist.size===>>' + conlist.size());
        OrgWideEmailAddress[] owea = [SELECT
            Id, 
            address
        FROM
            OrgWideEmailAddress
        WHERE
            Address = 'driverservices@mburse.com'];
        list<id> cIdList = new  list<id>();
        for(contact c: conlist) {
            for(contact co: c.drivers__r) {
                cIdList.add(co.id);
            }
        }
        System.debug('cIdList==>> ' + cIdList);
        String lastMonth = Utils.fetchMonths(1, 0)[0];
        list<contact> contactlist = [SELECT
            id, 
            Role__c, 
            account.Enable_Email_For_Managers__c, 
            Manager__c, 
            Manager__r.Manager__r.External_Email__c, 
            Manager__r.External_Email__c, 
            name, 
            External_Email__c, 
            (SELECT
                id, 
                month__c, 
                status__c
            FROM
                Employee_Reimbursements__r
            WHERE
                month__c = : lastmonth), 
            Monthly_Mileage_Limit__c,
            Deactivated_Date__c
        FROM
            contact
        WHERE
            manager__c in: cIdList
            AND ( Driver_Type__c != 'Driver - Full Time' or Driver_Type__c != 'Driver - Part Time' )];
        list<Employee_Reimbursement__c> reimlist = [SELECT
            id, 
            contact_id__c, 
            month__c, 
            status__c
        FROM
            Employee_Reimbursement__c
        WHERE
            month__c = : lastmonth AND contact_id__c in: cIdList
            AND ( Contact_Id__r.Driver_Type__c != 'Driver - Full Time' or Contact_Id__r.Driver_Type__c != 'Driver - Part Time' )];
        list<Employee_Mileage__c> milelist = [SELECT
            Mileage__c, 
            From_Previous_Months__c, 
            EmployeeReimbursement__c
        FROM
            Employee_Mileage__c
        WHERE
            EmployeeReimbursement__r.Month__c = : lastmonth
            AND ( EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c != 'Driver - Full Time' or EmployeeReimbursement__r.Contact_Id__r.Driver_Type__c != 'Driver - Part Time' )];
        System.debug(reimlist.size() + ' contactlist==>> ' + milelist.size());
        map<id, decimal> emReimToTotalMileagemap = new  map<id, decimal>();
        map<id, Employee_Reimbursement__c> conIdToReimMap = new  map<id, Employee_Reimbursement__c>();
        map<id, list<contact>> manToDriverMap = new  map<id, list<contact>>();
        for(Employee_Mileage__c m: milelist) {
            decimal mileage = 0;
            if(emReimToTotalMileagemap.get(m.EmployeeReimbursement__c) != null) {
                mileage = emReimToTotalMileagemap.get(m.EmployeeReimbursement__c);
            }
          //  if(m.mileage__c != null && !m.From_Previous_Months__c) {
            if(m.mileage__c != null) {
                mileage += m.mileage__c;
            }
            emReimToTotalMileagemap.put(m.EmployeeReimbursement__c, mileage);
        }
        for(Employee_Reimbursement__c r: reimlist) {
            conIdToReimMap.put(r.contact_Id__c, r);
        }
        for(contact c: contactlist) {
            list<contact> con = new  list<contact>();
            if(manToDriverMap.get(c.manager__c) != null) {
                con.addAll(manToDriverMap.get(c.manager__c));
            }
            con.add(c);
            manToDriverMap.put(c.manager__c, con);
        }
        string month = string.valueOf(Date.today().addMonths(-1).month());
        string m = (month == '1') ? 'January' : (month == '2') ? 'February' : (month == '3') ? 'March' : (month == '4') ? 'April' : (month == '5') ? 'May' : (month == '6') ? 'June' : (month == '7') ? 'July' : (month == '8') ? 'August' : (month == '9') ? 'September' : (month == '01') ? 'January' : (month == '02') ? 'February' : (month == '03') ? 'March' : (month == '04') ? 'April' : (month == '05') ? 'May' : (month == '06') ? 'June' : (month == '07') ? 'July' : (month == '08') ? 'August' : (month == '09') ? 'September' : (month == '10') ? 'October' : (month == '11') ? 'November' : (month == '12') ? 'December' : 'Invalid Month';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id,HtmlValue,Name,Subject FROM EmailTemplate WHERE DeveloperName =:'Auto_Approval_Template'];
        for(contact con: conlist) {
            String html = '';
           
            String newBody = emailTemplate.HtmlValue;
            if(!String.isBlank(con.Account.Approval_Template_Message__c)) {
                String accountMessage = con.Account.Approval_Template_Message__c;
                accountMessage = accountMessage.replace('{month}', m);
                newBody = newBody.replace('{account.Approval_Template_Message__c}',accountMessage);
            }else {
                newBody = newBody.replace('{account.Approval_Template_Message__c}','');
            }
            if(con.role__c == 'admin' || con.role__c == 'admin/driver') {
                String reportTo = '<th style="border:2px solid black;" width="5%">Report To</th>';
                newBody = newBody.replace('{reportToTR}',reportTo);
            }else {
                newBody = newBody.replace('{reportToTR}','');
            }
            for(contact co: con.drivers__r) {
                if(conIdToReimMap.get(co.id) != null) {
                    decimal mileage = 0;
                    decimal monthlyLimit = 0;
                    if(co.Monthly_Mileage_Limit__c != null) {
                        monthlyLimit = co.Monthly_Mileage_Limit__c;
                    }
                    if(emReimToTotalMileagemap.get(conIdToReimMap.get(co.id).id) != null) {
                        mileage = emReimToTotalMileagemap.get(conIdToReimMap.get(co.id).id);
                    }
                    if(mileage > 0){
                        html = '<tr align="center">' + '<td style="border:2px solid black;">' + co.Name + '</td>' + '<td style="border:2px solid black;">' + conIdToReimMap.get(co.id).Month__c + '</td>' + '<td style="border:2px solid black;">' + monthlyLimit + '</td>' + '<td style="border:2px solid black;">' + mileage + '</td>' + '<td style="border:2px solid black;">' + conIdToReimMap.get(co.id).status__c + '</td>';
                        if(con.role__c == 'admin' || con.role__c == 'admin/driver') {
                            html += +'<td style="border:2px solid black;" width="5%">' + con.Name + '</td>';
                        }
                        html += +'</tr>';
                    }
                }
                if(manToDriverMap.get(co.id) != null) {
                    for(contact c: manToDriverMap.get(co.id)) {
                        if(c.Employee_Reimbursements__r.size() > 0) {
                            decimal mileage = 0;
                            decimal monthlyLimit = 0;
                            if(c.Monthly_Mileage_Limit__c != null) {
                                monthlyLimit = c.Monthly_Mileage_Limit__c;
                            }
                            if(emReimToTotalMileagemap.get(c.Employee_Reimbursements__r[0].id) != null) {
                                mileage = emReimToTotalMileagemap.get(c.Employee_Reimbursements__r[0].id);
                            }
                            if(mileage > 0){
                                html += +'<tr align="center">' + '<td style="border:2px solid black;">' + c.Name + '</td>' + '<td style="border:2px solid black;">' + c.Employee_Reimbursements__r[0].Month__c + '</td>' + '<td style="border:2px solid black;">' + monthlyLimit + '</td>' + '<td style="border:2px solid black;">' + mileage + '</td>' + '<td style="border:2px solid black;">' + c.Employee_Reimbursements__r[0].status__c + '</td>';
                                if(con.role__c == 'admin' || con.role__c == 'admin/driver') {
                                    html += +'<td style="border:2px solid black;" width="5%">' + co.Name + '</td>';
                                }
                                html += +'</tr>';    
                            }
                            
                        }
                    }
                }
                newBody = newBody.replace('{tableDynamicData}',html);
            }
            
            if(con.drivers__r.size() > 0 && con.External_Email__c != null && con.account.Enable_Email_For_Managers__c) {
                messaging.singleEmailMessage mail = new  messaging.singleEmailMessage();
                if(owea.size() > 0) 
                {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                //Setting user email in to address con.External_Email__c
                string[] toAddresses;
                SendEmailToMe__c  objSendEmailToMe = SendEmailToMe__c.getValues('RG_AutoApprovedEmailClass');
                if(objSendEmailToMe.Send_email_to_me__c == true){
                    toAddresses = new string[]{'priyanka.goc@gmail.com','natavar.goc@gmail.com'};
                }
                else
                {
                    toAddresses = new string[]{con.External_Email__c};
                }
               // toAddresses = new string[]{'natavar.goc@gmail.com'};
                // Assign the addresses for the To and CC lists to the mail object
                mail.setToAddresses(toAddresses);
                //Email subject to be changed
                mail.setSubject(emailTemplate.Subject);
                mail.setBCCAddresses(new string[]{'minkesh.patel@getoncrm.com','natavar.goc@gmail.com'});
                //Body of email
                
                mail.setHtmlBody(newBody);
                if(newBody.contains('</td>')){
                    mails.add(mail);    
                }
            }
        }

        SendEmail__c  objSendEmail = SendEmail__c.getValues('RG_AutoApprovedEmailClass');
        if(!mails.isEmpty() && !Test.isRunningTest()  &&(objSendEmail!=null) && (objSendEmail.Send_email_from_code__c==true)) {
            
                Messaging.sendEmail(mails);
            
        }
    }
    public void finish(Database.BatchableContext BC) {
       /* Batch_Setup__c batchsetupConfig = new Batch_Setup__c();
        batchsetupConfig = [Select AutoApprovedEmail__c From Batch_Setup__c ];
        if(batchsetupConfig.AutoApprovedEmail__c == false){
            batchsetupConfig.AutoApprovedEmail__c = true;
            update batchsetupConfig;  
        } */ 
    }
}