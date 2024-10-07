/**
 * @description       : 
 * @author            : Vatsal Bhalani
 * @group             : 
 * @last modified on  : 09-23-2024
 * @last modified by  : Vatsal Bhalani
**/
public without sharing class ImportContactdatafromCSVController{

    public String exceptionMessage = '';
    public final String  strJSON;
    public list<CSVToContact> lstCSVToContact;
    public string accId;
    public static string adminMailId;
    public static string adminId;
    public Map<Integer,String> errorMap = new Map<Integer,String>();
    public List<Contact> lstAllContacts = new List<Contact>();
    public static String cellPhone;
    public static String reimbursementFrequency;
    public static TrueDialog_Keys__c tdKeys = TrueDialog_Keys__c.getInstance('TrueDialogKeys');
    public static List<String> lstManagerNames = new List<String>();
    public static map<String,Contact> mapManagerContacts = new map<String,Contact>();
    public static String csv = 'Error Message\n';
    public static Integer errorCount = 0;
    
    public ImportContactdatafromCSVController(String data, String accountId, String adminId) {
        
        try {
            // System.debug('file:: ' + data);
            // System.debug('accountId:: ' + accountId);
            // System.debug('AdminId:: ' + adminId);
            
            // if(String.isNotEmpty(data)){
                this.strJSON = data;
                // Parse the JSON data to CSVToContact list
                this.lstCSVToContact = CSVToContact.parse(this.strJSON);
                this.accId = accountId;
                // Fetch admin email based on adminId
                Contact adminContact = [SELECT Id, External_Email__c FROM Contact WHERE id = :adminId LIMIT 1];
                // System.debug('adminContact ===>  '+adminContact);
                adminMailId = adminContact.External_Email__c;
                adminId = adminContact.Id;
            // }
            
        } catch (Exception e) {
            System.debug('Something went Wrong.'+e.getMessage());
        }

    }

    // Method to start processing the CSV data
    public String processContacts() {

        if(this.lstCSVToContact.size() < 51){
            System.debug('Start processing contacts');
            boolean flag = false;
            checkRecursive.setting_SetLatLondAddressFlag(flag);
            

            Savepoint spMain = Database.setSavepoint();
            Map<String, String> existingVehicleMap = new Map<String, String>();

            try {

                tdKeys.Contact_Insert_From_File__c = true;
                update tdKeys;

                // TODO : existingVehicleMap Not Needed
                // Fetch existing vehicle mappings
                for (Vehicle_URL_Mapping__c veh : [SELECT Name, Id FROM Vehicle_URL_Mapping__c LIMIT 50000]) {
                    existingVehicleMap.put(veh.Name, veh.Id);
                }

                // Fetch account vehicle types
                String accVehicles;
                for (Account acc : [SELECT Id, Vehicle_Types__c, Cell_Phone__c, Reimbursement_Frequency__c FROM Account WHERE Id = :accId AND Vehicle_Types__c != null]) {
                    cellPhone=acc.Cell_Phone__c;
                    reimbursementFrequency=acc.Reimbursement_Frequency__c;
                    accVehicles = acc.Vehicle_Types__c;
                }

                // Process each contact in the parsed list
                for (CSVToContact con : this.lstCSVToContact) {
                    
                    fetchManagerContacts(con);
                }
                
                if(!lstManagerNames.isEmpty()){
                    for(Contact objManagerContact : [SELECT Id,Name, External_Email__c FROM Contact WHERE Name In :lstManagerNames]){
                        if(!mapManagerContacts.containsKey(objManagerContact.Name)){
                            mapManagerContacts.put(objManagerContact.Name, objManagerContact);
                        }
                    }
                }

                // Process each contact in the parsed list
                for (CSVToContact con : this.lstCSVToContact) {

                    // System.debug('Processing contact: ' + con);
                    // System.debug('pre error count : ' + errorCount);
                    if(con.Firstname.trim() != '' 
                        && con.LastName.trim() != ''
                        && con.EmailAddress.trim() != ''
                        && con.StandardVehicle.trim() != ''
                        && con.Role.trim() != ''
                        && con.City.trim() != ''
                        && con.State.trim() != ''
                        && con.ZipCode.trim() != ''
                        // && con.ManagersLastName.trim() != ''
                        // && con.ManagersFirstName.trim() != ''
                        && con.CellPhone.trim() != ''
                        && con.DrivingState.trim() != ''
                        && con.ActivationDate.trim() != ''){

                            Contact objNewContact = prepareContact(con, this.accId, accVehicles);
                            if(objNewContact != null){

                                this.lstAllContacts.add(objNewContact);
                            }
                    }else if(con.Firstname.trim() == '' && con.LastName.trim() == ''){
                        csv += 'In Some Contacts First Name and Last Name is Missing.\n';
                        errorCount++;
                    }else{
                        csv += 'In ' + con.FirstName + ' ' + con.LastName +' Contact Some Records are Empty.\n';
                        errorCount++;
                        // System.debug('Post error count ==> :: '+errorCount);
                    }

                }
                System.debug('before insert error count ==> :: '+errorCount);
                // Insert the contacts into the database
                if (!this.lstAllContacts.isEmpty() && errorCount == 0) {
                    Database.SaveResult[] insertResults = Database.insert(this.lstAllContacts, false);
                    System.debug('insertResults ======> '+insertResults);
                    errorCount += handleInsertResults(insertResults);
                    // System.debug('errorCount =====> '+errorCount);
                }

                // Update the contact mappings if necessary
                updateContactMappings();
                
            } catch (Exception e) {
                this.exceptionMessage = 'Exception: ' + e.getMessage() + ' at line ' + e.getLineNumber();
                //csv += 'Your job is rollback due to some error. Please upload again or connect administrator.';
                csv += 'Something went wrong. Please upload again or connect administrator.';
                System.debug('Exception occurred: ' + e.getMessage());
                errorCount++;
                Database.rollback(spMain);
            }
        }else{
            this.lstAllContacts.clear();
            csv += 'Total Number of Contacts must be less than 50.\n';
            errorCount++;
        }

        // Handle post-processing steps
        finishProcessing();

        if(errorCount>0){
            // System.debug('@@@ Insert failure @@@');
            return 'failure';
        }else{
            // System.debug('@@@ Insert Success @@@');
            return 'success';
        }
    }

    public static void fetchManagerContacts(CSVToContact csvRecordData){

        if(String.isNotEmpty(csvRecordData.ManagersLastName) && String.isNotEmpty(csvRecordData.ManagersFirstName)){
            String managerName = csvRecordData.ManagersFirstName.trim() + ' ' + csvRecordData.ManagersLastName.trim();
            // System.debug( managerName ==> ' managerName);
            
            lstManagerNames.add(managerName);

        }

    }
    // Method to prepare contact list from CSV data
    public static Contact prepareContact(CSVToContact csvRecordData, String accountId, String accVehicles) {

        Contact objContact = new Contact();
        try{

            
            set<String> setRoles = new set<String>{'Driver/Admin','Driver','Driver/Manager'};

            if(setRoles.contains(csvRecordData.Role)){
                objContact.Role__c = csvRecordData.Role;
            }else{
                csv += csvRecordData.FirstName + ' ' + csvRecordData.LastName +' has Invalid Role Value.\n';
                errorCount++;
                return null;
            }
            
            if (accountId != null) { 
                objContact.AccountId = accountId;
            }             
            objContact.FirstName = csvRecordData.FirstName;

            //below two field added to not activate community user when contact is created.
            objContact.isCommunityUser__c = true;
            objContact.IsCreatedFromCommunity__c = true;
        
            objContact.LastName = csvRecordData.LastName;

            if(isValidEmail(csvRecordData.EmailAddress)){
                objContact.Email = csvRecordData.EmailAddress;
                objContact.External_Email__c = csvRecordData.EmailAddress; 
            }else{
                csv += csvRecordData.FirstName + ' ' + csvRecordData.LastName +' has Invalid EmailAddress value.\n';
                errorCount++;
                return null;
            }


            if(isValidPhoneNumber(csvRecordData.CellPhone)){
                objContact.MobilePhone = csvRecordData.CellPhone;
                objContact.Phone = csvRecordData.CellPhone;
            }else{
                csv += csvRecordData.FirstName + ' ' + csvRecordData.LastName +' has Invalid CellPhone value.\n';
                errorCount++;
                return null;
            }
            objContact.MailingCity = csvRecordData.City;
            objContact.MailingState = csvRecordData.State;

            if(isValidZipCode(String.valueOf(csvRecordData.ZipCode))){
                objContact.MailingPostalCode = String.valueOf(csvRecordData.ZipCode);
            }else{
                csv += csvRecordData.FirstName + ' ' + csvRecordData.LastName +' has Invalid ZipCode Value.\n';
                errorCount++;
                return null;
            }

            objContact.Department = csvRecordData.Department;   
            objContact.Job_Title__c = csvRecordData.JobTitle;


            // Trim the manager's name once
            String managerName = csvRecordData.ManagersFirstName.trim() + ' ' + csvRecordData.ManagersLastName.trim();

            // Define a flag to track if the manager was found in the map
            Boolean managerExists = mapManagerContacts.containsKey(managerName);

            if (managerExists) {
                objContact.Manager__c = mapManagerContacts.get(managerName).Id;
                objContact.Manager_External_Email__c = mapManagerContacts.get(managerName).External_Email__c;
            } else if ( (setRoles.contains(csvRecordData.Role) && managerName.trim() != '') || csvRecordData.Role == 'Driver') {
                csv += 'No Manager exists with Name ' + managerName + ' for Contact ' + csvRecordData.FirstName + ' ' + csvRecordData.LastName + '.\n';
                errorCount++;
                return null;
            } else if(csvRecordData.Role == 'Driver/Manager') {
                // Assign admin details for 'Driver/Manager' if manager not found
                objContact.Manager__c = adminId;
                objContact.Manager_External_Email__c = adminMailId;
            }else{
                objContact.Manager__c = null;
                objContact.Manager_External_Email__c = null;
            }
            
            // String.valueOf(csvRecordData.ComplianceMileage)    ;
            //if(csvRecordData.StandardVehicle != ''){objContact.Vehicle_Type__c = csvRecordData.StandardVehicle; }  

            if(csvRecordData.DrivingState != ''){objContact.Driving_States__c = csvRecordData.DrivingState; }  

            if(String.valueOf(csvRecordData.InsuranceRate) != '' && csvRecordData.InsuranceRate != null && String.valueOf(csvRecordData.InsuranceRate) != 'null'){objContact.Insurance_Rate__c = Decimal.valueOf(csvRecordData.InsuranceRate);}
            if(String.valueOf(csvRecordData.LicenseandRegistration) != '' && csvRecordData.LicenseandRegistration != null && String.valueOf(csvRecordData.LicenseandRegistration) != 'null'){objContact.License_Ragistration__c = Decimal.valueOf(csvRecordData.LicenseandRegistration);}
            if(String.valueOf(csvRecordData.PersonalPropertyTax) != '' && csvRecordData.PersonalPropertyTax != null && String.valueOf(csvRecordData.PersonalPropertyTax) != 'null'){objContact.Taxes__c = Decimal.valueOf(csvRecordData.PersonalPropertyTax);}
            if(String.valueOf(csvRecordData.Depreciation) != '' && csvRecordData.Depreciation != null && String.valueOf(csvRecordData.Depreciation) != 'null'){objContact.Depreciation__c = Decimal.valueOf(csvRecordData.Depreciation);}
            if(String.valueOf(csvRecordData.AnnualFixedCost) != '' && csvRecordData.AnnualFixedCost != null && String.valueOf(csvRecordData.AnnualFixedCost) != 'null'){objContact.Annual_Fixed_Cost__c = Decimal.valueOf(csvRecordData.AnnualFixedCost);}
            if(String.valueOf(csvRecordData.FixedAmount) != '' && csvRecordData.FixedAmount != null && String.valueOf(csvRecordData.FixedAmount) != 'null'){objContact.Fixed_Amount__c = Decimal.valueOf(csvRecordData.FixedAmount) ; }
            if(String.valueOf(csvRecordData.FCA) != '' && csvRecordData.FCA != null && String.valueOf(csvRecordData.FCA) != 'null'){objContact.Fixed_Cost_Adjustment__c = Decimal.valueOf(csvRecordData.FCA);}
            if(String.valueOf(csvRecordData.TotalFixedAmount) != '' && csvRecordData.TotalFixedAmount != null && String.valueOf(csvRecordData.TotalFixedAmount) != 'null'){objContact.Total_Fixed_Costs__c = Decimal.valueOf(csvRecordData.TotalFixedAmount);}
            if(csvRecordData.Meeting != '') {objContact.Meeting__c = csvRecordData.Meeting;}
            // System.debug('con obj'+objContact);
            if(cellPhone!='Both'){
                objContact.Cell_Phone__c = cellPhone;
            }else{
                objContact.Cell_Phone__c = 'Employee Provide';
            }
            if(reimbursementFrequency!='Both'){

                objContact.Reimbursement_Frequency__c = reimbursementFrequency;
            }else{
                objContact.Reimbursement_Frequency__c = 'Monthly Reimbursement';
            }


            if(csvRecordData.DateAdded != '' && csvRecordData.DateAdded !=null&& String.valueOf(csvRecordData.DateAdded) != 'null') {
                // System.debug('con obj199');

                String dateYear = (csvRecordData.DateAdded.split('T')[0]).split('-')[0];
                // System.debug('DateAdded dateYear ==>'+dateYear);
                if(!dateYear.contains('2001') && Pattern.matches('^[0-9].*', dateYear)){
                    
                    Date dt=Date.valueof(csvRecordData.DateAdded.split('T')[0]);
                    System.debug('DateAdded1 ::: '+dt);

                    Date myDateIN=Date.newinstance(dt.year(), dt.MONTH(), dt.day());
                    System.debug('DateAdded2 :::'+myDateIN);
    
                    objContact.Added_Date__c = myDateIN;
                    System.debug('added date '+objContact.Added_Date__c);
                }
    
            } else {
                // System.debug('con obj208');
                objContact.Added_Date__c = System.today();
            }

            if(csvRecordData.ActivationDate != ''){
                System.debug('csvRecordData.ActivationDate'+csvRecordData.ActivationDate);
                String dateYear = (csvRecordData.ActivationDate.split('T')[0]);
                System.debug('ActivationDate dateYear ==>'+dateYear);
                
                System.debug('isValidDateFormat(csvRecordData.ActivationDate)  ==> '+isValidDateFormat(csvRecordData.ActivationDate));
                System.debug('isValidDateFormat(dateYear)  ==> '+isValidDateFormat(dateYear));
                
                if(!dateYear.contains('2001') && Pattern.matches('^[0-9].*', dateYear) && isValidDateFormat(dateYear)){

                    if(csvRecordData.ActivationDate.contains('T')){
                        Date dt1 = Date.valueof(csvRecordData.ActivationDate.split('T')[0]);
                        System.debug('ActivationDate1 :::'+dt1);
                        Date myDate1=Date.newinstance(dt1.year(), dt1.MONTH(), dt1.day());
                        System.debug('ActivationDate2 :::'+myDate1);
                        objContact.Activation_Date__c = myDate1;
                        System.debug('added date '+objContact.Activation_Date__c);
                    }
                    else{
                        String year = csvRecordData.ActivationDate.split('/')[2];
                        String month = csvRecordData.ActivationDate.split('/')[0];
                        String day = csvRecordData.ActivationDate.split('/')[1];
                        Date convActivationDate = date.newinstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
                        System.debug('convActivationDate : ' + convActivationDate);
                        objContact.Activation_Date__c =convActivationDate;
                        System.debug('added date '+objContact.Activation_Date__c);
                    }
                    
                    System.debug('Inside ActivationDate if'+System.today());
                    
                }else{
                    csv += csvRecordData.FirstName + ' ' + csvRecordData.LastName +' has Invalid Activation Date.\n';
                    errorCount++;
                    return null;
                }
            }

            if(String.valueOf(csvRecordData.MPG) != '' && String.valueOf(csvRecordData.MPG) != 'null' && csvRecordData.MPG != null){
                objContact.MPG__c = Decimal.valueOf(csvRecordData.MPG);
            }   
            if(String.valueOf(csvRecordData.Maint) != '' && String.valueOf(csvRecordData.Maint) != 'null' && csvRecordData.Maint != null){
                objContact.Maintenance__c = Decimal.valueOf(csvRecordData.Maint);
            }   
            if(String.valueOf(csvRecordData.Tires) != '' && String.valueOf(csvRecordData.Tires) != 'null' && csvRecordData.Tires != null){
                objContact.Tires__c = Decimal.valueOf(csvRecordData.Tires);
            }
            if(String.valueOf(csvRecordData.MaintTires) != '' && String.valueOf(csvRecordData.MaintTires) != 'null' && csvRecordData.MaintTires != null){
                objContact.Maintenance_and_Tires__c = Decimal.valueOf(csvRecordData.MaintTires) ; 
            } 
            
            // System.debug('accVehicles ==>'+accVehicles);
            List<String> vehicleSplit = new List<String>();
            //string[] vehicleSplit;
            try {
                if(accVehicles.contains(';')){
                    // System.debug('Insert into accVehicles if condition');
                    vehicleSplit =  accVehicles.split(';');
                }else{
                    vehicleSplit.add(accVehicles);
                }
            } catch (Exception e) {
                System.debug('vehicleSplit catch ==>'+e.getMessage());
            } 

            if(csvRecordData.StandardVehicle == ''){
                objContact.Vehicle_Type__c = vehicleSplit.get(vehicleSplit.size()-1);
            } else if(csvRecordData.StandardVehicle != '' && accVehicles.contains(csvRecordData.StandardVehicle)){
                objContact.Vehicle_Type__c = csvRecordData.StandardVehicle;
            }else{
                csv += csvRecordData.FirstName + ' ' + csvRecordData.LastName +' has Invalid StandardVehicle Value.\n';
                errorCount++;
                return null;
            }
            // else {
            //         System.debug('Vehicle name in else: '+ vehicleSplit[0]);
            //         objContact.Vehicle_Type__c = vehicleName;
            // }
    
            if(String.valueOf(csvRecordData.ComplianceMileage) != '' && String.valueOf(csvRecordData.ComplianceMileage) != 'null' && csvRecordData.ComplianceMileage != null){
                objContact.Compliance_Mileage__c = Decimal.valueOf(csvRecordData.ComplianceMileage);
            }
            if(csvRecordData.VehicleURL != ''){
                objContact.Car_Image__c = csvRecordData.VehicleURL;
            }
        }catch(Exception e){
            System.debug('objContact Creation Catch ==> '+e.getMessage());
            errorCount++;
            return null;
        }

        // System.debug('objContact :::' +objContact);
        // System.debug('objContact.Phone :::' + objContact.Phone);
        // System.debug('objContact.MobilePhone :::' +objContact.MobilePhone);
        return objContact;
    }

         // Function to validate date in mm/dd/yyyy format
    public static Boolean isValidDateFormat(String dateStr) {
        System.debug('isValidDateFormat :::' +dateStr);
        // Regular expression to match mm/dd/yyyy format strictly with valid ranges
        //String datePattern = '^((0[1-9])|(1[0-2]))[-\\/]((0[1-9])|([1][0-9])|([2][0-9])|(3[01]))[-\\/]([0-9]{4})$';
        // 09-15-2024
        String datePattern1 = '^((0?[1-9])|(1[0-2]))[-\\/]((0?[1-9])|([12][0-9])|(3[01]))[-\\/]([0-9]{4})$';
        // 2024-09-15
        String datePattern2 = '^([0-9]{4})[-\\/]((0?[1-9])|(1[0-2]))[-\\/]((0?[1-9])|([12][0-9])|(3[01]))$';
        
        // Check if the input matches the pattern first
        if (Pattern.matches(datePattern1, dateStr) || Pattern.matches(datePattern2, dateStr)) {
            return true;
        }
        return false;
     
    }


    private static Boolean isValidEmail(String email) {
        // Regex pattern to match a typical email format
        String emailPattern = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';
        
        // Validate email against the regex pattern
        return Pattern.matches(emailPattern, email);
    }
    private static Boolean isValidPhoneNumber(String phoneNumber) {
        // Remove any non-numeric characters from the phone number
        String cleanedNumber = phoneNumber.replaceAll('[^0-9]', '');

        // Ensure the original string does not contain non-numeric characters
        Boolean hasNonNumeric = phoneNumber.replaceAll('[0-9\\(\\)\\-\\s]', '').length() > 0;
        
        // Check if the cleaned number is exactly 10 digits long and no non-numeric characters exist in the original
        if (cleanedNumber.length() == 10 && !hasNonNumeric) {
            return true;
        }
        return false;
    }

    private static Boolean isValidZipCode(String zipCode) {
        // Remove any non-numeric characters from the ZIP code
        String cleanedZipCode = zipCode.replaceAll('[^0-9]', '');
        
        // Ensure no non-numeric characters were present in the original string
        Boolean hasNonNumeric = zipCode.replaceAll('[0-9]', '').length() > 0;
        
        // Check if the cleaned ZIP code is exactly 5 digits long and no non-numeric characters exist in the original
        if (cleanedZipCode.length() == 5 && !hasNonNumeric) {
            return true;
        }
        return false;
    }

    // Method to handle insert results
    private Integer handleInsertResults(Database.SaveResult[] insertResults) {
        Integer errorFlagCount = 0;

        for (Database.SaveResult sr : insertResults) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    String errorLog = JSON.serialize(err);
                    this.errorMap.put(errorFlagCount, err.getMessage());
                }
                errorFlagCount++;
            }
            
        }
        return errorFlagCount;
    }

    // Method to update contact mappings
    private void updateContactMappings() {
        Map<String, Contact> contactMap = new Map<String, Contact>();
        Id adminId;
        // System.debug('');
        for(Contact conObj : this.lstAllContacts){
            if(conObj.id != null){
                contactMap.put(conObj.Email, conObj);
                if(conObj.Role__c != null && conObj.Role__c != '' && conObj.Role__c != 'Driver' /*&& (conObj.Manager_External_Email__c == null || conObj.Manager_External_Email__c == '')*/){
                    adminId = conObj.id;
                }
            }
        }
        Map<String, Contact> oldContactMap = new Map<String, Contact>();
        if(accId != null && accId != ''){
            Account accountContactList = [Select id,(Select id,Email,Admin__c,Manager__c,Manager_External_Email__c from contacts) from account where id =: accId];
            
            for(Contact objContact : accountContactList.contacts){
                if(objContact.Id != null){
                    oldContactMap.put(objContact.Email, objContact);
                    if((objContact.Manager__c == null) && objContact.Manager_External_Email__c != null && !contactMap.containskey(objContact.Email)){
                        // System.debug('11-->');
                        contactMap.put(objContact.Email, objContact);
                    }                        
                    if(adminId != null) {
                        adminId = objContact.Admin__c;
                    }
                        
                }
            }
        }
        for(contact conObj : contactMap.values()){
            if((conObj.Manager__c == null) && conObj.Manager_External_Email__c != null){
                contactMap.get(conObj.Email).Manager__c = contactMap.containsKey(conObj.Manager_External_Email__c) ? contactMap.get(conObj.Manager_External_Email__c)?.Id : oldContactMap.containsKey(conObj.Manager_External_Email__c) ? oldContactMap.get(conObj.Manager_External_Email__c)?.Id : null;
                if(conObj.Manager_External_Email__c != null && conObj.Manager_External_Email__c != '') {
                    contactMap.get(conObj.Email).Admin__c = adminId;
                }
                    
            }
        }
        Database.saveResult[] insertDriverList = Database.update(contactMap.values(), false);
        // System.debug('updatedriverlis '+insertDriverList);
    }

    private void finishProcessing(){

        try{

            Map<Integer, List<String>> map100ChunksByKey = new Map<Integer, List<String>>();
            Integer i = 100;
            Integer j = 0;
            
            for(Contact con : this.lstAllContacts ){
     
               if(i==100){
                i=0; 
                j=j+1;
                map100ChunksByKey.put(j,new List<String>());
               }
               map100ChunksByKey.get(j).add(con.Id);
               i=i+1;
            }
            System.debug('map100ChunksByKey@@-'+map100ChunksByKey.keyset());
            for(Integer Key: map100ChunksByKey.keyset())
            {           
                if(!Test.isRunningTest()) {
                    contactTriggerHelper.bulkPutHTTP(map100ChunksByKey.get(Key));
                }            
            }           


        }catch(Exception e){
            System.debug('Too Many future callout in contactTriggerHelper.putHTTP ::: '+e.getMessage());
        }
      

        Set<String> tmpConIdSet = new Set<String>();
        for(contact con : this.lstAllContacts){
            tmpConIdSet.add(con.Id);     
        }
        Map<Id,Contact> contactIdMap =  new Map<Id, Contact>([select id, MobilePhone,
                                        Email,Account.True_Dialog__c FROM Contact 
                                        WHERE id IN: tmpConIdSet AND Account.True_Dialog__c=true ]);
        // System.debug('contactIdMap=='+ contactIdMap);
        Set<Id> contactIdSet=contactIdMap.keyset();

        if(contactIdSet.size() > 0 && tdKeys.Contact_Insert_From_File__c){

            // System.debug('Inside Insert Contacts to mlog');
            // System.debug('tdKeys.Contact_Insert_From_File__c =>'+tdKeys.Contact_Insert_From_File__c);

            TrueDialog_Keys__c tdKeys1 =TrueDialog_Keys__c.getValues('TrueDialogKeys');        
            TrueDialogContactAPI tdContactApi = new TrueDialogContactAPI(contactIdSet);
            Database.executeBatch(tdContactApi,200);
        }
        // System.debug('before process completed tdKeys.Contact_Insert_From_File__c =>'+tdKeys.Contact_Insert_From_File__c);
        tdKeys.Contact_Insert_From_File__c = false;
        update tdKeys;
        // System.debug('after process completed tdKeys.Contact_Insert_From_File__c =>'+tdKeys.Contact_Insert_From_File__c);


        String errorSubject;
        String htmlbody;
        Boolean emailFalg = false;
        // System.debug('exception message: '+this.exceptionMessage);
        // System.debug('error map is empty: '+this.errorMap.isEmpty());
        // System.debug('error map is empty: '+this.errorMap );
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [SELECT Id,Address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        
        if(((this.exceptionMessage == null || this.exceptionMessage == '') && !this.errorMap.isEmpty()) || errorCount>0) {
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            // System.debug('inside attachment construction if block: ');
            // String csv = 'Index,Error Message\n';
            for (Integer key : this.errorMap.keySet()) {
                String errorMessage = this.errorMap.get(key).replaceAll(',', ';');
                csv += key + ',' + errorMessage + '\n';
            }   
            System.debug('CSV---> '+csv);
            
            attach.setBody(blob.valueOf(csv));
            attach.setFileName('Contact Error File .Csv');
            errorSubject = 'Error Result Of Contact Csv File';
            htmlbody = 'Your job is not completed due to some record has error, so please see the attached csv file for error.';
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
            
        }else if((this.exceptionMessage == null || this.exceptionMessage == '') && this.errorMap.isEmpty()) {
            System.debug('no error in the contact list if block ');
            emailFalg = true;
        }else if(this.exceptionMessage != null && this.exceptionMessage != ''){
            System.debug('exception occured ');
            errorSubject = 'Your job is rollback';
            htmlbody = 'Your job is rollback due to the error '+this.exceptionMessage + ',  please upload again or connect administrator';
        }
        if (owea.size() > 0) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        System.debug('@@@ ::: 2 CSV---> '+csv);
        String adminMailId = adminMailId;
        List<String> testMailIds = System.Label.Error_Email_for_import_data.split(',');
        List<String> toAddresses = new List<String> {adminMailId};
        for(String mailId : testMailIds){
            toAddresses.add(mailId);
        }

        email.setToAddresses(toAddresses);

        email.setSubject(errorSubject);
        // System.debug('out side the attachment creation blockx');
        email.setHTMLBody(htmlbody);
        if(emailFalg == false) {
            System.debug('error flag is still false');
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
            System.debug('email result '+r)  ;
        }

    }     
}