global class ImportAdminDriverInformation implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts{
    global final blob dataDocuments;
    global String exceptionMessage = '';
    global Map<Integer,String> errorMap = new Map<Integer,String>();
    global List<Contact> allContactList = new List<Contact>();
    global ImportAdminDriverInformation (Blob data){
        this.dataDocuments=data;
    }
    global Iterable<String> start(Database.BatchableContext BC){     
        return new CSVIterator(this.dataDocuments.toString(), '\n');
    }
    global void execute(Database.BatchableContext info, List<String> scope){
        Savepoint spMain = Database.setSavepoint();
        List<Vehicle_URL_Mapping__c> allVehiclelist = new List<Vehicle_URL_Mapping__c>();
        Map<String, String> VehicleNameUrlMap = new Map<String, String>();
        Set<String> existingVehiclelist = new Set<String>();
        String accountIdFromCsv;
        try{
            //Getting all vehicle details
            for (Vehicle_URL_Mapping__c veh : [SELECT Name FROM Vehicle_URL_Mapping__c limit 50000]) {
                existingVehiclelist.add(veh.Name);
            }
            
            //geting account detalil from the csv and preparing map with the account details
            Map<String,String> accfieldsValueMap = new Map<String,String>();
            for(String row : scope){
                string[] csvRecordData = row.split(',');
                if (csvRecordData[0] != '' && csvRecordData[1] != '') {
                    accfieldsValueMap.put(csvRecordData[0], csvRecordData[1]); 
                    if(csvRecordData[0] == 'Account Id'){
                        accountIdFromCsv = csvRecordData[1];
                    }
                }
                if(csvRecordData[33] != '' && csvRecordData[38] != '' && existingVehiclelist.contains(csvRecordData[33]) == false){
                    VehicleNameUrlMap.put(csvRecordData[33], csvRecordData[38]);
                }
            }

            //Insert Vehicles
            for(String vName : VehicleNameUrlMap.keySet()) {
                Vehicle_URL_Mapping__c vehicleObj = new Vehicle_URL_Mapping__c();
                vehicleObj.Name = vName;
                vehicleObj.Year__c = vName.substringBefore(' ');
                vehicleObj.vehicle__c = vName.substringAfter(' ');
                vehicleObj.URL__c = VehicleNameUrlMap.get(vName);
                allVehiclelist.add(vehicleObj);
            }
            Database.UpsertResult[] urVehicleList = Database.upsert(allVehiclelist, Vehicle_URL_Mapping__c.Name );
            
            //preparing the account records data
            Account accObj = InsertUpsertAccountData(accfieldsValueMap);
            
            for(String row : scope){
                String[] csvRecordData = row.split(',');
                allContactList.add(preparecontactList(accObj, csvRecordData));
            }
            if(!allContactList.isEmpty()){
                Database.saveResult[] insertDriverList = Database.insert(allContactList, false);
                Integer erroFlagCount = 0;
                for (Database.saveResult sr : insertDriverList) {
                    if (sr.isSuccess() == false) {
                        for(Database.Error objErr : sr.getErrors()) {
                            errorMap.put(erroFlagCount, objErr.getMessage());
                            System.debug('errorMap-->'+errorMap);
                        }
                    }
                    erroFlagCount ++;
                }
            }
            Map<String, Contact> contactMap = new Map<String, Contact>();
            Id adminId;
            for(Contact conObj : allContactList){
                if(conObj.id != null){
                    contactMap.put(conObj.Email, conObj);
                    if(conObj.Role__c != null && conObj.Role__c != '' && conObj.Role__c != 'Driver' && (conObj.Manager_External_Email__c == null || conObj.Manager_External_Email__c == '')){
                        adminId = conObj.id;
                    }
                }
            }
            Map<String, Contact> oldContactMap = new Map<String, Contact>();
            if(accountIdFromCsv != null && accountIdFromCsv != ''){
                Account accountContactList = [Select id,(Select id,Email,Manager__c,Manager_External_Email__c from contacts) from account where id =: accountIdFromCsv];
                for(Contact conListObj : accountContactList.contacts){
                    if(conListObj.Id != null){
                        oldContactMap.put(conListObj.Email, conListObj);
                        System.debug('conListObj.Manager__c'+conListObj.Manager__c);
                        System.debug('conListObj.Manager__c'+conListObj.Manager__c);
                        if((conListObj.Manager__c == null) && conListObj.Manager_External_Email__c != null && !contactMap.containskey(conListObj.Email)){
                            System.debug('11-->');
                            contactMap.put(conListObj.Email, conListObj);
                        }
                        if(adminId != null)
                            adminId = conListObj.Admin__c;
                    }
                }
            }
            System.debug('oldContactMap.size()-->'+oldContactMap.size());
            for(contact conObj : contactMap.values()){
                if((conObj.Manager__c == null) && conObj.Manager_External_Email__c != null){
                    contactMap.get(conObj.Email).Manager__c = contactMap.containsKey(conObj.Manager_External_Email__c) ? contactMap.get(conObj.Manager_External_Email__c)?.Id : oldContactMap.containsKey(conObj.Manager_External_Email__c) ? oldContactMap.get(conObj.Manager_External_Email__c)?.Id : null;
                    if(conObj.Manager_External_Email__c != null && conObj.Manager_External_Email__c != '')
                        contactMap.get(conObj.Email).Admin__c = adminId;
                }
            }
            Database.saveResult[] insertDriverList = Database.update(contactMap.values(), false);
        }catch(Exception e){
            System.debug('Exception:- '+e.getMessage()+' '+e.getLineNumber());
            exceptionMessage = 'Exception:-'+e.getMessage()+' '+e.getLineNumber();
            Database.rollback(spMain);
        }
    }
    public static account InsertUpsertAccountData(Map<String, String> accfieldsValueMap){
        Account accObj = new Account();
        accObj.Name = accfieldsValueMap.get('Company Name');
        accObj.Logo_Document_Id__c = accfieldsValueMap.get('Company Logo');
        accObj.Triplog_API__c = accfieldsValueMap.get('mLog API');
        accObj.Bodily_Injury__c = accfieldsValueMap.get('Bodily Injury');
        accObj.Uninsured_Motorist__c = accfieldsValueMap.get('Uninsured Motorist');
        accObj.Property_Damage__c = accfieldsValueMap.containskey('Property Damage') ? Decimal.valueOf(accfieldsValueMap.get('Property Damage')) : 0;
        accObj.Comprehensive__c = accfieldsValueMap.containskey('Comprehensive') ? Decimal.valueOf(accfieldsValueMap.get('Comprehensive')) : 0;
        accObj.Collision__c = accfieldsValueMap.containskey('Collision') ? Decimal.valueOf(accfieldsValueMap.get('Collision')) : 0;
        accObj.Umbrella_Coverage__c = accfieldsValueMap.containskey('Umbrella Coverage') ? Decimal.valueOf(accfieldsValueMap.get('Umbrella Coverage')) : 0;
        if(accfieldsValueMap.containskey('Account Id')){
            accObj.id =  accfieldsValueMap.get('Account Id');
        }
        System.debug('accObj '+accObj);
        Database.UpsertResult accUpsertResult = Database.upsert(accObj,false);
        return accObj;
    }
    public static Contact preparecontactList(Account accObj, String[] csvRecordData){
        String invalidNumbers = '[^0-9]';
        Contact conObj = new Contact();
        conObj.Role__c = csvRecordData[2] ;
        if (accObj.Id != null) { conObj.AccountId = accObj.Id;}             
        conObj.FirstName = csvRecordData[3];

        //below two field added to not activate community user when contact is created.
        conObj.isCommunityUser__c = false;
        conObj.IsCreatedFromCommunity__c = false;
    
        conObj.LastName = csvRecordData[4];
        conObj.Email = csvRecordData[5];
        conObj.External_Email__c = csvRecordData[5];  
        conObj.MobilePhone = csvRecordData[6];
        conObj.Phone = csvRecordData[6];
        conObj.MailingCity = csvRecordData[7];
        conObj.MailingState = csvRecordData[8];
        conObj.MailingPostalCode = csvRecordData[9];
        conObj.Department = csvRecordData[10];   
        conObj.Job_Title__c = csvRecordData[11];
        conObj.Manager_First_Name__c = csvRecordData[12];
        conObj.Manager_Last_Name__c = csvRecordData[13];
        string managerExtEmail = csvRecordData[14];
        if (managerExtEmail != '') {
            conObj.Manager_External_Email__c = managerExtEmail;
        }

        if(csvRecordData[15] != ''){conObj.Vehicle_Type__c = csvRecordData[15]; }  
        if(csvRecordData[16] != '' && csvRecordData[16] != null && csvRecordData[16] != 'null'){conObj.Insurance_Rate__c = Decimal.valueOf(csvRecordData[16]);}
        if(csvRecordData[17] != '' && csvRecordData[17] != null && csvRecordData[17] != 'null'){conObj.License_Ragistration__c = Decimal.valueOf(csvRecordData[17]);}
        if(csvRecordData[18] != '' && csvRecordData[18] != null && csvRecordData[18] != 'null'){conObj.Taxes__c = Decimal.valueOf(csvRecordData[18]);}
        if(csvRecordData[19] != '' && csvRecordData[19] != null && csvRecordData[19] != 'null'){conObj.Depreciation__c = Decimal.valueOf(csvRecordData[19]);}
        if(csvRecordData[20] != '' && csvRecordData[20] != null && csvRecordData[20] != 'null'){conObj.Annual_Fixed_Cost__c = Decimal.valueOf(csvRecordData[20]);}
        if(csvRecordData[21] != '' && csvRecordData[21] != null && csvRecordData[21] != 'null'){conObj.Business_Use__c = Decimal.valueOf(csvRecordData[21].replaceAll( invalidNumbers, '' ));}
        if(csvRecordData[22] != '' && csvRecordData[22] != null && csvRecordData[22] != 'null'){conObj.Fixed_Amount__c = Decimal.valueOf(csvRecordData[22]) ; }
        if(csvRecordData[23] != '' && csvRecordData[23] != null && csvRecordData[23] != 'null'){conObj.Fixed_Cost_Adjustment__c = Decimal.valueOf(csvRecordData[23]);}
        if(csvRecordData[24] != '' && csvRecordData[24] != null && csvRecordData[24] != 'null'){conObj.Total_Fixed_Costs__c = Decimal.valueOf(csvRecordData[24]);}
        if(csvRecordData[25] != '') {conObj.Meeting__c = csvRecordData[25];}
        //conObj.Packet__c = csvRecordData[26];
        if(csvRecordData[27] != '') {
            conObj.Added_Date__c = convertDateFormat(csvRecordData[27]);
        }

        if(csvRecordData[28] != ''){
            conObj.Activation_Date__c = convertDateFormat(csvRecordData[28]);    
        }
        if(csvRecordData[29] != '' && csvRecordData[29] != 'null' && csvRecordData[29] != null){conObj.MPG__c = Decimal.valueOf(csvRecordData[29]);}   
        if(csvRecordData[30] != '' && csvRecordData[30] != 'null' && csvRecordData[30] != null){conObj.Maintenance__c = Decimal.valueOf(csvRecordData[30]);}   
        if(csvRecordData[31] != '' && csvRecordData[31] != 'null' && csvRecordData[31] != null){conObj.Tires__c = Decimal.valueOf(csvRecordData[31]);}
        if(csvRecordData[32] != '' && csvRecordData[32] != 'null' && csvRecordData[32] != null){conObj.Maintenance_and_Tires__c = Decimal.valueOf(csvRecordData[32]) ; }            
        if(csvRecordData[33] != ''){conObj.Vehicle_Type__c = csvRecordData[33];}
        if(csvRecordData[34] != ''){conObj.Insurance_Plan__c = csvRecordData[34];}
        if(csvRecordData[35] != ''){conObj.Vehicle_Age__c = csvRecordData[35];}
        if(csvRecordData[36] != '' && csvRecordData[36] != 'null' && csvRecordData[36] != null){conObj.Vehicle_Value__c = Decimal.valueOf(csvRecordData[36]);}
        if(csvRecordData[37] != '' && csvRecordData[37] != 'null' && csvRecordData[37] != null){conObj.Compliance_Mileage__c = Decimal.valueOf(csvRecordData[37]);}
        if(csvRecordData[38] != ''){conObj.Car_Image__c = csvRecordData[38];}
        if(csvRecordData[39] != ''){conObj.Company_Logo__c = csvRecordData[39];}
        if(csvRecordData[40] != ''){conObj.mLog_API__c = csvRecordData[40];}
        return conObj;
    }
    public static Date convertDateFormat(String csvRecordData){
        String[] dts;
        Date myDateIN;
        if(csvRecordData.contains('/')){
            dts = csvRecordData.split('/');
            if(dts[2].contains(' ')){ 
                dts[2] = dts[2].split(' ')[0];
                System.debug('dts-->'+dts);
                myDateIN = Date.newinstance(Integer.valueOf(dts[0]), Integer.valueOf(dts[1]), Integer.valueOf(dts[2]));
            }else{
                System.debug('dts-->'+dts);
                myDateIN = Date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
        }else if(csvRecordData.contains('-')){
            dts = csvRecordData.split('-');
            if(dts[2].contains(' ')){ 
                dts[2] = dts[2].split(' ')[0];
                System.debug('dts-->'+dts);
                myDateIN = Date.newinstance(Integer.valueOf(dts[0]), Integer.valueOf(dts[1]), Integer.valueOf(dts[2]));
            }else{
                System.debug('dts-->'+dts);
                myDateIN = Date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
            }
            System.debug('myDateIN-->'+myDateIN);
        }
        return myDateIN;
    }
    
    global void finish(Database.BatchableContext info){   
        for(Contact con : allContactList){
            if(con.id != null)
            try{
                contactTriggerHelper.putHTTPCallout(con.AccountId,con.External_Email__c);
            }catch(Exception e){}
        }
        
        /*AsyncApexJob asyncJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                        from AsyncApexJob where Id =: info.getJobId()]; asyncJob.Status != 'Completed' ||*/
        String errorEmail=System.Label.Error_Email_for_import_data;
        //String errorEmail='snehal.gat@kiwiqa.com';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {errorEmail};
        email.setToAddresses(toAddresses);
        String errorSubject;
        String htmlbody;
        Boolean emailFalg = false;
        System.debug('exceptionMessage-->'+exceptionMessage);
        System.debug('errorMap-->'+errorMap);
        System.debug('errorEmail-->'+errorEmail);
        if((exceptionMessage == null || exceptionMessage == '') && !errorMap.isEmpty()) {
            System.debug('exceptionMessage-->'+exceptionMessage);
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            String finalstr;
            
            string header ='Company Detail'+','+'Company Detail'+','+'Role'+','+ 'First Name'+','+'Last Name'+','+'Email Address'+','+'Cell Phone'+','+'City'+','+'State'+','+'Zip Code'+','+'Department'+','+'Job Title'+','+'Managers First Name'+','+'Managers Last Name'+','+'Managers Email'+','+'Vehicle'+','+'Insurance Rate'+','+'License and Registration'+','+'Personal Property Tax'+','+'Depreciation'+','+'Annual Fixed Cost'+','+'Business Use'+','+'Fixed Amount'+','+'FCA'+','+'Total Fixed Amount'+','+'Meeting'+','+'Packet'+','+'Date Added'+','+'Activation Date'+','+'MPG'+','+'Maint'+','+'Tires'+','+'Maint/Tires'+','+'Standard Vehicle'+','+'Insurance Plan'+','+'Vehicle Age'+','+'Vehicle Value'+','+'Compliance Mileage'+','+'Vehicle URL'+','+'Company Logo'+','+'mLog API'+','+'Error'+' \n';
            finalstr = header;
            String CellPhone,ManagersEmail,Vehicle,insuraceRate,LicenseandRegistration,PersonalPropertyTax,Depreciation,AnnualFixedCost,BusinessUse,
            FixedAmount,FCA,TotalFixedAmount,Meeting,addedDate,activationDate,MPG,Maint,Tires,MaintTires,StandardVehicle,InsurancePlan,VehicleAge,
            VehicleValue,ComplianceMileage,VehicleURL,CompanyLogo,mLogAPI;

            for(Integer mapkey : errorMap.keySet()){
                CellPhone = String.valueof(allContactList.get(mapkey)?.Phone) != null ? String.valueof(allContactList.get(mapkey)?.Phone) : '';
                ManagersEmail = allContactList.get(mapkey).Manager_External_Email__c != null ? allContactList.get(mapkey).Manager_External_Email__c : '';
                Vehicle = allContactList.get(mapkey).Vehicle_Type__c != null ? allContactList.get(mapkey).Vehicle_Type__c : '';
                insuraceRate = String.valueof(allContactList.get(mapkey)?.Insurance_Rate__c) != null ? String.valueof(allContactList.get(mapkey)?.Insurance_Rate__c)  : '';
                LicenseandRegistration = String.valueof(allContactList.get(mapkey).License_Ragistration__c) != null ? String.valueof(allContactList.get(mapkey).License_Ragistration__c) : '';
                PersonalPropertyTax = String.valueof(allContactList.get(mapkey).Taxes__c) != null ? String.valueof(allContactList.get(mapkey).Taxes__c) : '';
                Depreciation = String.valueof(allContactList.get(mapkey).Depreciation__c) != null ? String.valueof(allContactList.get(mapkey).Depreciation__c) : '';
                AnnualFixedCost = String.valueof(allContactList.get(mapkey).Annual_Fixed_Cost__c) != null ? String.valueof(allContactList.get(mapkey).Annual_Fixed_Cost__c) : '';
                BusinessUse = String.valueof(allContactList.get(mapkey).Business_Use__c) != null ? String.valueof(allContactList.get(mapkey).Business_Use__c) : '';
                FixedAmount = String.valueof(allContactList.get(mapkey).Fixed_Amount__c) != null ? String.valueof(allContactList.get(mapkey).Fixed_Amount__c) : '';
                FCA = String.valueof(allContactList.get(mapkey).Fixed_Cost_Adjustment__c) != null ? String.valueof(allContactList.get(mapkey).Fixed_Cost_Adjustment__c) : '';
                TotalFixedAmount = String.valueof(allContactList.get(mapkey).Total_Fixed_Costs__c) != null ? String.valueof(allContactList.get(mapkey).Total_Fixed_Costs__c) : '';
                Meeting = allContactList.get(mapkey).Meeting__c != null ? allContactList.get(mapkey).Meeting__c : '';
                MPG = String.valueof(allContactList.get(mapkey).MPG__c) != null ? String.valueof(allContactList.get(mapkey).MPG__c) : '';
                Maint = String.valueof(allContactList.get(mapkey).Maintenance__c) != null ? String.valueof(allContactList.get(mapkey).Maintenance__c) : '';
                Tires = String.valueof(allContactList.get(mapkey).Tires__c) != null ? String.valueof(allContactList.get(mapkey).Tires__c) : '';
                MaintTires = String.valueof(allContactList.get(mapkey).Maintenance_and_Tires__c) != null ? String.valueof(allContactList.get(mapkey).Maintenance_and_Tires__c): '';
                StandardVehicle = allContactList.get(mapkey).Vehicle_Type__c != null ? allContactList.get(mapkey).Vehicle_Type__c : '';
                InsurancePlan = allContactList.get(mapkey).Insurance_Plan__c != null ? allContactList.get(mapkey).Insurance_Plan__c : '';
                VehicleAge = String.valueOf(allContactList.get(mapkey).Vehicle_Age__c) != null ? allContactList.get(mapkey).Vehicle_Age__c : '';
                VehicleValue = String.valueOf(allContactList.get(mapkey).Vehicle_Value__c) != null ? String.valueof(allContactList.get(mapkey).Vehicle_Value__c): '';
                ComplianceMileage = String.valueOf(allContactList.get(mapkey).Compliance_Mileage__c) != null ? String.valueof(allContactList.get(mapkey).Compliance_Mileage__c) : '';
                VehicleURL = allContactList.get(mapkey).Car_Image__c != null ? allContactList.get(mapkey).Car_Image__c : '';
                CompanyLogo = allContactList.get(mapkey).Company_Logo__c != null? allContactList.get(mapkey).Company_Logo__c: '';
                mLogAPI = allContactList.get(mapkey).mLog_API__c != null ? allContactList.get(mapkey).mLog_API__c : '';
                //String addedDate;
                //String activationDate;
                System.debug('allContactList.get(mapkey).Added_Date__c-->'+allContactList.get(mapkey).Added_Date__c);
                if(allContactList.get(mapkey).Added_Date__c != null)
                    addedDate = allContactList.get(mapkey).Added_Date__c != null ? allContactList.get(mapkey).Added_Date__c.day() + '/' + allContactList.get(mapkey).Added_Date__c.month()+'/'+ allContactList.get(mapkey).Added_Date__c.year() : '';
                if(allContactList.get(mapkey)?.Activation_Date__c != null)
                    activationDate = allContactList.get(mapkey).Activation_Date__c != null ? allContactList.get(mapkey).Activation_Date__c.day() + '/' + allContactList.get(mapkey).Activation_Date__c.month()+'/'+ allContactList.get(mapkey).Activation_Date__c.year() : '';
                //String Recordstring = 'Account Id'+','+allContactList.get(mapkey).AccountId+','+allContactList.get(mapkey).Role__c+','+allContactList.get(mapkey).FirstName+','+allContactList.get(mapkey).LastName+','+allContactList.get(mapkey).Email+','+allContactList.get(mapkey).Phone+','+allContactList.get(mapkey).MailingCity+','+allContactList.get(mapkey).MailingState+','+allContactList.get(mapkey).MailingPostalCode+','+allContactList.get(mapkey).Department+','+allContactList.get(mapkey).Job_Title__c+','+allContactList.get(mapkey).Manager_First_Name__c+','+allContactList.get(mapkey).Manager_Last_Name__c+','+allContactList.get(mapkey).Manager_External_Email__c+','+allContactList.get(mapkey).Vehicle_Type__c+','+insuraceRate +','+allContactList.get(mapkey).License_Ragistration__c+','+allContactList.get(mapkey).Taxes__c+','+allContactList.get(mapkey).Depreciation__c+','+allContactList.get(mapkey).Annual_Fixed_Cost__c+','+allContactList.get(mapkey).Business_Use__c+','+allContactList.get(mapkey).Fixed_Amount__c+','+allContactList.get(mapkey).Fixed_Cost_Adjustment__c+','+allContactList.get(mapkey).Total_Fixed_Costs__c+','+allContactList.get(mapkey).Meeting__c+','+''+','+addedDate+','+activationDate+','+allContactList.get(mapkey).MPG__c+','+allContactList.get(mapkey).Maintenance__c+','+allContactList.get(mapkey).Tires__c+','+allContactList.get(mapkey).Maintenance_and_Tires__c+','+allContactList.get(mapkey).Vehicle_Type__c+','+allContactList.get(mapkey).Insurance_Plan__c+','+allContactList.get(mapkey).Vehicle_Age__c+','+allContactList.get(mapkey).Vehicle_Value__c+','+allContactList.get(mapkey).Compliance_Mileage__c+','+allContactList.get(mapkey).Car_Image__c+','+allContactList.get(mapkey).Company_Logo__c+','+allContactList.get(mapkey).mLog_API__c+','+errorMap.get(mapkey)+'    \n';
                String Recordstring = 'Account Id'+','+allContactList.get(mapkey).AccountId+','+allContactList.get(mapkey).Role__c+','+allContactList.get(mapkey).FirstName+','+allContactList.get(mapkey).LastName+','+allContactList.get(mapkey).Email+','+CellPhone+','+allContactList.get(mapkey).MailingCity+','+allContactList.get(mapkey).MailingState+','+allContactList.get(mapkey).MailingPostalCode+','+allContactList.get(mapkey).Department+','+allContactList.get(mapkey).Job_Title__c+','+allContactList.get(mapkey).Manager_First_Name__c+','+allContactList.get(mapkey).Manager_Last_Name__c+','+ManagersEmail+','+Vehicle+','+insuraceRate +','+LicenseandRegistration+','+PersonalPropertyTax+','+Depreciation+','+AnnualFixedCost+','+BusinessUse+','+FixedAmount+','+FCA+','+TotalFixedAmount+','+Meeting+','+''+','+addedDate+','+activationDate+','+MPG+','+Maint+','+Tires+','+MaintTires+','+StandardVehicle+','+InsurancePlan+','+VehicleAge+','+VehicleValue+','+ComplianceMileage+','+VehicleURL+','+CompanyLogo+','+mLogAPI+','+errorMap.get(mapkey)+'    \n';
                finalstr = finalstr + Recordstring;
            }          
            
            attach.setBody(blob.valueOf(finalstr));
            attach.setFileName('Contact Error File .Csv');
            errorSubject = 'Error Result Of Account/Contact Csv File';
            htmlbody = 'Your job is not completed due to some record has error, so please see the last column in attached csv file for error';
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
        }if((exceptionMessage == null || exceptionMessage == '') && errorMap.isEmpty()) {
            emailFalg = true;
            System.debug('exceptionMessage == errorMap.isEmpty()-->');
        }else if(exceptionMessage != null && exceptionMessage != ''){
            errorSubject = 'Your job is rollback';
            htmlbody = 'Your job is rollback due to the error '+exceptionMessage + ',  please upload again or connect administrator';
        }
        email.setSubject(errorSubject);
        email.setHTMLBody(htmlbody);
        if(emailFalg == false)
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
    } 
}