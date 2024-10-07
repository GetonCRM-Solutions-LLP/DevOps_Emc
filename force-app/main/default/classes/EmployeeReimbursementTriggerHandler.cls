/*Description: Trigger populates Fuel Price and Fixed Amount values of Employee Reimbersment object.
Fuel Price is populated from Gas Price record having same City, State as Contact Mailing Address AND
having same month and year in Month Year field as Employee Reimbersment's Month field.
Fixed Price is populated from Contact's Fixed Price.
*/
public with sharing class EmployeeReimbursementTriggerHandler {   
    static List<Employee_Reimbursement__c> reimList;   
    static List<IRS_Mileage_Rate__c> objIRSRate;
    static String tempYear = String.valueOf(date.today().Year());
    static List<string> vehicleTypeList =  System.Label.Vehicle_Type.split(',');

    public static Void mileagefieldupdate(List<Employee_Reimbursement__c> empReimbursList, Map<Id,Employee_Reimbursement__c> empReimburseOld, Map<Id,Employee_Reimbursement__c> empReimburseNew) {         
        List<Employee_Mileage__c> mileageUpdatelist = new List<Employee_Mileage__c>();
        Employee_Reimbursement__c reimForMil = new Employee_Reimbursement__c();
        for(Employee_Mileage__c empmilege : [SELECT id, name, Trip_Status__c, Rejected__c, EmployeeReimbursement__c,EmployeeReimbursement__r.Status__c, Approved_Date__c,Trip_Approval_Time__c 
                                                FROM Employee_Mileage__c WHERE EmployeeReimbursement__c in : empReimbursList]) {              
            if(empmilege.EmployeeReimbursement__r.Status__c == 'Approved'){
                //this static value is used for bypass from here when MappingGasPriceTrigger is called. this is while 'Mileage update after the lock date' is updated  
                StaticValues.isCalledFromReimTri = true;
                reimForMil = empReimburseNew.get(empmilege.EmployeeReimbursement__c);            
                if(empmilege.Approved_Date__c == null) {
                    empmilege.Approved_Date__c = reimForMil.Approved_Date__c;                    
                }
                if(empmilege.Trip_Approval_Time__c == null){
                    empmilege.Trip_Approval_Time__c = reimForMil.Reimbursement_Approval_Time__c;
                }
                if(empmilege.Trip_Status__c == StaticValues.noApprovedYet && (empmilege.Trip_Status__c != 'Rejected' || empmilege.Rejected__c == false) ) {
                    empmilege.Trip_Status__c = 'Approved';
                }
                if(empmilege.Rejected__c == true){
                    empmilege.Trip_Status__c = 'Rejected';
                }
                mileageUpdatelist.add(empmilege);
            }
        }
        if(!mileageUpdatelist.isEmpty()) {
            update mileageUpdatelist;    
        }     
    }
    public static void updateStatusMail(Map<Id,Employee_Reimbursement__c> empReimburseNew){
        List<String> accountNamesList = new List<String>();
        accountNamesList = Label.SendEmailToManagerAccount.split(',');
        List<String> accountNamesList2 = new List<String>();
        accountNamesList2 = Label.SendEmailToAdminAccount.split(',');
        
        List<Employee_Reimbursement__c> empReimList = new List<Employee_Reimbursement__c>();
        empReimList = [Select id, 
                              name,
                              Contact_Id__c,
                              Contact_Id__r.Manager__c,                              
                              Contact_Id__r.Manager__r.Manager__c,
                              Contact_Id__r.Name,
                              Contact_Id__r.Email,
                              Contact_Id__r.Manager__r.Role__c,
                              Contact_Id__r.Manager__r.Manager__r.Role__c,
                              Contact_Id__r.Account.Name, 
                              Total_Mileage__c,
                              Variable_Rate__c, 
                              Monthly_Variable_Amount__c,
                              Fixed_Amount__c,
                              Total_Monthly_Reimbursement__c,
                              Month__c
                       From Employee_Reimbursement__c 
                       Where Id In: empReimburseNew.keyset() and 
                             (Contact_Id__r.Account.Name In:accountNamesList OR Contact_Id__r.Account.Name In:accountNamesList2)
                       Order by Contact_Id__c Asc];        
        
        Map<String,String> emailMap = new Map<String,String>();
        for(Employee_Reimbursement__c emp:empReimList){
            List<String> monthAndYear = new List<String>();
            datetime monthValue = System.Now();
            if(emp.Month__c != null && emp.Month__c.contains('-'))
            {
                monthAndYear = emp.Month__c.split('-');
                monthValue = datetime.newInstance(Integer.valueOf(monthAndYear[1]), integer.valueOf(monthAndYear[0]), 1,00,00,00);
            }
            String monthName = monthValue.format('MMMMM'); 
            String htmlTemplate = '';
            String htmlTemplate2 = '';
            String htmlTemplate3 = '';

            if(accountNamesList.contains(emp.Contact_Id__r.Account.Name)){
                if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__r.Manager__c)) {
                    htmlTemplate = emailMap.get(emp.Contact_Id__r.Manager__c);
                    htmlTemplate = htmlTemplate + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'
                                                + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                + monthName +'</td><td style="border:2px solid black;">'
                                                + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                +'</tr>';
                } else {                 
                    htmlTemplate = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                    + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                    + monthName +'</td><td style="border:2px solid black;">'
                                    + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                    + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                    +'</tr>';
                }
                emailMap.put(emp.Contact_Id__r.Manager__c,htmlTemplate);                
                if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__c)) {
                    htmlTemplate2 = emailMap.get(emp.Contact_Id__c);
                    htmlTemplate2 = htmlTemplate2 + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                                  + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                  + monthName +'</td><td style="border:2px solid black;">'
                                                  + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                  + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                  +'</tr>';
                } else {                 
                    htmlTemplate2 = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">' 
                                    + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'   
                                    + monthName +'</td><td style="border:2px solid black;">'
                                    + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                    + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                    +'</tr>';
                }
                emailMap.put(emp.Contact_Id__c,htmlTemplate2);
            }
            if(accountNamesList2.contains(emp.Contact_Id__r.Account.Name)){            
                if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__r.Manager__c) && (emp.Contact_Id__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Role__c == 'Driver/Admin')) {
                    htmlTemplate3 = emailMap.get(emp.Contact_Id__r.Manager__c);
                    htmlTemplate3 = htmlTemplate3 + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                                  + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                  + monthName +'</td><td style="border:2px solid black;">'
                                                  + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                  + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                  +'</tr>';
                } else if(emailMap.size() > 0 && emailMap.containsKey(emp.Contact_Id__r.Manager__r.Manager__c) && (emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Driver/Admin')) {
                    htmlTemplate3 = emailMap.get(emp.Contact_Id__r.Manager__r.Manager__c);
                    htmlTemplate3 = htmlTemplate3 + '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">'  
                                                  + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'  
                                                  + monthName +'</td><td style="border:2px solid black;">'
                                                  + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                                  + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                                  + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                                  +'</tr>';
                } else {                 
                    htmlTemplate3 = '<tr align="center" style="border:2px solid black;"> <td style="border:1px solid black;">' 
                                    + emp.Contact_Id__r.Name +'</td><td style="border:2px solid black;">'   
                                    + monthName +'</td><td style="border:2px solid black;">'
                                    + emp.Total_Mileage__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Variable_Rate__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Monthly_Variable_Amount__c +'</td><td style="border:2px solid black;">' +'$' 
                                    + emp.Fixed_Amount__c+'</td><td style="border:2px solid black;">'+'$' 
                                    + emp.Total_Monthly_Reimbursement__c +'</td>' 
                                    +'</tr>';
                }
                if(emp.Contact_Id__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Role__c == 'Driver/Admin'){
                    emailMap.put(emp.Contact_Id__r.Manager__c,htmlTemplate3);                    
                } else if(emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Admin' || emp.Contact_Id__r.Manager__r.Manager__r.Role__c == 'Driver/Admin'){
                    emailMap.put(emp.Contact_Id__r.Manager__r.Manager__c,htmlTemplate3);                    
                } 
            }
        }
        
        EmailTemplate emailTemplate = [SELECT Id,
                                              HtmlValue,
                                              Name,
                                              Subject 
                                        FROM EmailTemplate 
                                        WHERE DeveloperName = 'year_to_date_reimbursement_statement_template2']; 
                                        
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();

        List<String> bccList = new List<String>();
        bccList = System.Label.Send_Email_Bcc_Address.split(',');
        SendEmail__c sendCustomSet = SendEmail__c.getValues('EmployeeReimbursementTrigger');
        SendEmailToMe__c sendMeCustomSet = SendEmailToMe__c.getValues('EmployeeReimbursementTriggerHandler');

        for(Contact currentContact : [Select id, Name, Email, FirstName From Contact Where Id In: emailMap.keySet()]) {
           String htmlTemplate = '';
           if(emailMap.containsKey(currentContact.id)) {
                htmlTemplate = emailMap.get(currentContact.id);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String newBody = emailTemplate.HtmlValue;
                newBody = newBody.replace('{tableDynamicData}',htmlTemplate);
                newBody = newBody.replace('{!Employee_Reimbursement__c.Contact_Id_Name__c}',currentContact.FirstName);
                newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
                mail.setSubject(emailTemplate.Subject);
                mail.setHtmlBody(newBody);
                List<String> toAddress = new List<String>();
                toAddress.add(currentContact.Email);
                mail.setToAddresses(toAddress);
                if(!bccList.isEmpty() && bccList != null && sendMeCustomSet != null && sendMeCustomSet.Send_email_to_me__c == true){                
                    mail.setBccAddresses(bccList);
                }  
                singleEmailMessageList.add(mail);          
           }
        }
        if(!singleEmailMessageList.isEmpty() && !Test.isRunningTest() && sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true) {   
            Messaging.sendEmail(singleEmailMessageList);
        }
    }

    public static void checkDeactivatedContact(List<Employee_Reimbursement__c> empReimbursList){
        for(Employee_Reimbursement__c empReimb : empReimbursList) {
            if(empReimb.Contact_Id_Deactivated_Date__c != null ) {
                Datetime convertDateTimeToDate = empReimb.Contact_Id_Deactivated_Date__c;  
                Date modifiedDate = convertDateTimeToDate.Date();
                if(modifiedDate != System.today()) {
                    empReimb.AddError('User is deactivated so you can not create a reimbursement.');
                }
            }
            if((empReimb.Status__c == 'Approved' || empReimb.Status__c == 'Rejected') && empReimb.Approved_Date__c == null) { 
                empReimb.AddError('Please insert Approval date');
            }
        }
    }
    // EMC - 271
    // Whenever Reimbursement is created or updated at that time this is check the value of Contct's Vehicle type 
    // if vehicle type is 'IRS Mileage Rate' than the mpg and fuel price is set to 0 for the reimbursement and 
    // Maintanace and tires is set as the IRS Mileage Rate of that year which is in IRS Mileage rate.
    public static void  IRSVehicleCheck(Set<Id> reimIdslst) {
        List<Employee_Reimbursement__c> reimList = new List<Employee_Reimbursement__c>();
        List<Employee_Reimbursement__c> reimListtoUpdate = new List<Employee_Reimbursement__c>();
        Map<String, Decimal> yearvsIRSMap = new Map<String, Decimal>();
        
        for(IRS_Mileage_Rate__c irsRate : [SELECT id,year__c,IRS_Rate__c FROM IRS_Mileage_Rate__c]){
            yearvsIRSMap.put(irsRate.year__c, irsRate.IRS_Rate__c);
        }
        
         if(!Test.isRunningTest()){
             reimList = [SELECT id,name,MPG__c, Maintenance_and_Tires__c, Fuel_Price__c, Year__C 
                                                FROM Employee_Reimbursement__c   
                                                WHERE Contact_id__r.Deactivated_Date__c = null
                                                        AND Id IN: reimIdslst
                                                       AND Contact_id__r.Vehicle_Type__c =: vehicleTypeList];
         }  else {
             reimList = [SELECT id,name,MPG__c, Maintenance_and_Tires__c, Fuel_Price__c, Year__C 
                                                FROM Employee_Reimbursement__c   
                                                WHERE Contact_id__r.Deactivated_Date__c = null
                                                LIMIT 1];
         }
        for(Employee_Reimbursement__c  reim : reimList){
            reim.Fuel_Price__c = 0;
            reim.MPG__c = 0;
            IF(yearvsIRSMap.containsKey(String.valueOf(reim.Year__C))){
                reim.Maintenance_and_Tires__c = yearvsIRSMap.get(String.valueOf(reim.Year__C));
            }
            reimListtoUpdate.add(reim);
        }
        try {
            if(!reimListtoUpdate.isEmpty()){
                Update reimListtoUpdate;
            }
        } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }

    public static void checkLockDate(List<Employee_Reimbursement__c> empReimbursList){
        for(Employee_Reimbursement__c empReimList : empReimbursList) {
            if(empReimList.Mileage_Lock_Date__c != null){
                empReimList.addError('Please Remove Mileage Lock date value time of Creation new Record');
            }
        }
    }
    
    // @Date : 17/05/2024 || Vatsal Bhalani
    public static void updateFifthMessage(Map<Id,Employee_Reimbursement__c> empReimOld, Map<Id,Employee_Reimbursement__c> empReimNew){

        //List<Id> updatedEmpReimContactId = new List<Id>(); 
        Set<Id> setContactIds = new Set<Id>();

        // FETCH CONTACT_ID OF Employee_Mileage__c WHICH'S Mileage_Lock_Date__c IS CHANGED AND Mileage_Lock_Date__c IS NOT NULL 
        for (Employee_Reimbursement__c objEmpReim : empReimNew.values()) {
            Date oldLockDt = empReimOld.get(objEmpReim.Id).Mileage_Lock_Date__c;
            if(objEmpReim.Mileage_Lock_Date__c != oldLockDt && objEmpReim.Mileage_Lock_Date__c != null && objEmpReim.Total_Approved__c > 0){
               // updatedEmpReimContactId.add(objEmpReim.Contact_Id__c);
                setContactIds.add(objEmpReim.Contact_Id__c);
            }
        }

        System.debug('@@@ setContactIds ==> '+setContactIds);
        List<Message__c> lstMessages = [SELECT Id, Notification_Message__c, Unread__c, Contacts__c
                                                    FROM Message__c
                                                        WHERE Contacts__c IN: setContactIds
                                                        AND Notification_Message__c LIKE '%mileage has been approved%'
                                                        AND CreatedDate = THIS_YEAR];

        DateTime dtCurrentMonth = System.today().addMonths(-1);
        String currentMonth = String.valueOf(dtCurrentMonth.format('MMMM'));
        String currentMonthLikeValue = (currentMonth + ' mileage has been approved');

        for(Message__c objMsg : lstMessages){
            if(objMsg.Notification_Message__c.contains(currentMonthLikeValue)){
                setContactIds.remove(objMsg.Contacts__c);
            }
        }

        List<Message__c> lstMessagesToInsert = new List<Message__c>();
        for(Id conId : setContactIds){
            Message__c objMsg = new Message__c(
                Unread__c = true,
                Notification_Message__c = 'Your ' + currentMonth + ' mileage has been approved.',
                Contacts__c = conId
            );
            lstMessagesToInsert.add(objMsg);
        }

        if(!lstMessagesToInsert.isEmpty()){
            Database.insert(lstMessagesToInsert, false);
        }
    }

     // @Date : 20/05/2024 || Vatsal Bhalani
     public static void updateSixthSeventhMessage(Map<Id,Employee_Reimbursement__c> empReimOld, Map<Id,Employee_Reimbursement__c> empReimNew){

        Map<String, Employee_Reimbursement__c> updatedContactEmpReimMap = new Map<String, Employee_Reimbursement__c>();
        Set<Id> setFlaggedMilConIds = new Set<Id>();
        Set<Id> setUnapprovedMilConIds = new Set<Id>();
        DateTime dtLastMonth = System.today().addMonths(-1);
        String lastMonthval = String.valueOf(dtLastMonth.format('MMMM'));
        List<Message__c> lstMsgToInsert = new List<Message__c>();
             
        List<Employee_Reimbursement__c> empReimList = [SELECT ID, Total_Rejected__c, Total_Pending__c, Mileage_Lock_Date__c, Contact_Id__c, Contact_Id__r.Activation_Date__c, Contact_Id__r.Deactivated_Date__c, Contact_Id__r.Account.isUsingTriplog__c 
                                                            FROM Employee_Reimbursement__c 
                                                            WHERE ID IN : empReimNew.keySet()
                                                            AND Contact_Id__r.Activation_Date__c != null 
                                                            AND Contact_Id__r.Deactivated_Date__c = null 
                                                            AND Contact_Id__r.Account.isUsingTriplog__c = true  
                                                            AND (Contact_Id__r.Role__c ='Driver' 
                                                                OR Contact_Id__r.Role__c ='Driver/Admin' 
                                                                OR Contact_Id__r.Role__c ='Driver/Manager')];

            //System.debug('empReimList ==>'+empReimList);

            //FETCH CONTACT_ID OF Employee_Mileage__c WHICH'S Mileage_Lock_Date__c IS CHANGED AND Mileage_Lock_Date__c IS NOT NULL 
            for (Employee_Reimbursement__c reimObj : empReimList) {
                Date oldLockDt = empReimOld.get(reimObj.Id).Mileage_Lock_Date__c;
                if(reimObj.Mileage_Lock_Date__c != oldLockDt && 
                    reimObj.Mileage_Lock_Date__c != null){
                    updatedContactEmpReimMap.put(reimObj.Contact_Id__c, reimObj);
                    setFlaggedMilConIds.add(reimObj.Contact_Id__c);
                    setUnapprovedMilConIds.add(reimObj.Contact_Id__c);
                }
            }            
			// system.debug('@@ contactReimMap ==> '+updatedContactEmpReimMap);
			// system.debug('@@ before setFlaggedMilConIds ==> '+setFlaggedMilConIds);
			// system.debug('@@ before setUnapprovedMilConIds ==> '+setUnapprovedMilConIds);


            List<Message__c> msgList = [SELECT Id,Contacts__c,Notification_Message__c,Unread__c 
                                            FROM Message__c 
                                            WHERE (Notification_Message__c LIKE '%flagged mileage for%'
											OR Notification_Message__c LIKE '%unapproved mileage will move to the next reimbursement period%') 
                                            AND Contacts__c IN :updatedContactEmpReimMap.keySet()
                                            AND CreatedDate = THIS_YEAR];    

            for(Message__c objMsg : msgList){
                if(objMsg.Notification_Message__c.contains(lastMonthval) && objMsg.Notification_Message__c.contains('flagged mileage for')){
                    setFlaggedMilConIds.remove(objMsg.Contacts__c);
                }
                if(objMsg.Notification_Message__c.contains(lastMonthval) && objMsg.Notification_Message__c.contains('unapproved mileage will move to the next reimbursement period')){
                    setUnapprovedMilConIds.remove(objMsg.Contacts__c);
                }
            }

            // system.debug('@@ after setFlaggedMilConIds ==> '+setFlaggedMilConIds);
			// system.debug('@@ after setUnapprovedMilConIds ==> '+setUnapprovedMilConIds);

            for(Id conId : setFlaggedMilConIds){
                Decimal flaggedMileage = updatedContactEmpReimMap.get(conId).Total_Rejected__c;
                List<String> args = new String[]{'0','number','###,###,###.##'};
                String updatedFlaggedMileage = String.format(flaggedMileage.format(), args);
                if(flaggedMileage>0){
                Message__c objMsg = new Message__c(
                    Unread__c = true,
                    Notification_Message__c = 'You had '+ updatedFlaggedMileage +' flagged mileage for ' + lastMonthval + '.',
                    Contacts__c = conId
                ); 
                lstMsgToInsert.add(objMsg);
            }
            }
            for(Id conId : setUnapprovedMilConIds){
                Decimal pendingMileage = updatedContactEmpReimMap.get(conId).Total_Pending__c;
                List<String> args = new String[]{'0','number','###,###,###.##'};
                String updatedPendingMileage = String.format(pendingMileage.format(), args);
                if(pendingMileage>0){
                Message__c objMsg = new Message__c(
                    Unread__c = true,
                    Notification_Message__c = 'You had '+ updatedPendingMileage +' miles in ' + lastMonthval + ' that were not approved. Any unapproved mileage will move to the next reimbursement period for review/approval.',
                    Contacts__c = conId
                ); 
                lstMsgToInsert.add(objMsg);
                }
            }
            // system.debug('@@ lstMsgToInsert ==> '+lstMsgToInsert);

            if(!lstMsgToInsert.isEmpty()){
                Database.insert(lstMsgToInsert, false);
            }
    }
}