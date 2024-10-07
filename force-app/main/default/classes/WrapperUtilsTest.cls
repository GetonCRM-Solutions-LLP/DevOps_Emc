@isTest
public class WrapperUtilsTest {
    public static testmethod void wrapperUtilstestMethod() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.Mileage_Lockdate__c = false;
        insert customSetting;
        
        WrapperUtils obj_WrapperUtils = new WrapperUtils();
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com');
            insert contact_1;

            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
    
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;       
    
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            insert obj_Manager_list;
    
            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            insert obj_Driver_list;
          user_1 = new User( 
            Email = 'yourusername@gmail.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = contact_1.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
          );
          insert user_1;
        }
     
        list<Gas_Prices__c> gaslist = RecordUtilityClass.buildGasPrice();
        insert gaslist;

        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        insert obj_Employee_Reimbursement_list;   
        
         list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList1 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweekReimbursementList1;    
        
        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list, empBIweekReimbursementList1[0].id);
        insert obj_Employee_Mileage_list;

        List<Employee_Reimbursement__c> obj_newreimbursements = new List<Employee_Reimbursement__c>();
        for(Contact obj:obj_Driver_list)
        {
            for(integer i=1;i<13;i++)
            {
                Employee_Reimbursement__c obj_Employee_Reimbursement = new Employee_Reimbursement__c();
                if(i<10)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'0'+String.valueOf(i)+'-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '0'+String.valueOf(i)+'-'+String.valueOf(System.today().year()-1);                               
                }
                else if(i==11)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'11-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '11-'+String.valueOf(System.today().year()-1);                 
                }
                else
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'12-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '12-'+String.valueOf(System.today().year()-1);              
                }
                obj_Employee_Reimbursement.Contact_Id__c = obj.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending';
                obj_Employee_Reimbursement.Approved_Date__c = null;
                obj_Employee_Reimbursement.IRS_Mileage_Rate__c = obj_IRS_Mileage_Rate[2].id;
                obj_newreimbursements.add(obj_Employee_Reimbursement);
            }
            for(integer i=1;i<=12;i++)
            {
                Employee_Reimbursement__c obj_Employee_Reimbursement = new Employee_Reimbursement__c();
                if(i<10)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'0'+String.valueOf(i)+'-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '0'+String.valueOf(i)+'-'+String.valueOf(System.today().year());                               
                }
                else if(i==11)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'11-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '11-'+String.valueOf(System.today().year());                 
                }
                else
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'12-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '12-'+String.valueOf(System.today().year());              
                }
                obj_Employee_Reimbursement.Contact_Id__c = obj.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending';
                obj_Employee_Reimbursement.Approved_Date__c = null;
                obj_Employee_Reimbursement.IRS_Mileage_Rate__c = obj_IRS_Mileage_Rate[2].id;
                obj_newreimbursements.add(obj_Employee_Reimbursement);
            }
            
        }
        insert obj_newreimbursements;
        
     
        
        List<Employee_Mileage__c> obj_Employee_Mileage_list1 = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_newreimbursements, empBIweekReimbursementList1[0].Id);
        insert obj_Employee_Mileage_list1;

        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List3 = RecordUtilityClass.getEmployee_Reimbursement(obj_Account.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List3);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
    

        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list2=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list6=RecordUtilityClass.getallEmployeeMileages(obj_list_mileages);
        if(obj_EmployeeMileages_list6!=null && obj_EmployeeMileages_list6.size()>0)
        {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list6)
            {
                if(i==0)
                {
                    i++;
                    obj.isSelected=true;
                    obj_EmployeeMileages_list2.add(obj);
                }
                else
                {
                    i--;
                    obj.isChecked = true;
                    obj_EmployeeMileages_list1.add(obj);
                }
                
            }
        }
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list_update = new List<Employee_Reimbursement__c>();
        List<string> obj_Employee_Reimbursement_list_update1 = new List<string>();
        for(Employee_Reimbursement__c obj:obj_newreimbursements)
        {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        for(Employee_Reimbursement__c obj:obj_newreimbursements)
        {
            
            obj_Employee_Reimbursement_list_update1.add(obj.id);
        }
    

        EmployeeReimbursements obj_EmployeeReimbursements = WrapperUtils.getEmployeeReimbursements(obj_Employee_Reimbursement_list[0]);
        List<EmployeeReimbursements> obj_EmployeeReimbursements_list2 = new List<EmployeeReimbursements>();
        obj_EmployeeReimbursements_list2.add(obj_EmployeeReimbursements);
        
        
        for(Employee_Reimbursement__c obj:obj_Employee_Reimbursement_list)
        {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        update obj_Employee_Reimbursement_list_update;

        WrapperUtils.getChartData(obj_admincontact.id,obj_admincontact.showTeamRecord__c,obj_Account.id,'Driver');
        WrapperUtils.getComplianceCalculation(obj_Driver_list[0].id,String.valueOf(System.Today().year()));
        List<Contact> obj_updated_Driver_list =  new List<Contact>();
        for(Contact obj_contact:obj_Driver_list)
        {
            obj_contact.Deactivated_Date__c = system.today();
            obj_contact.Last_Pay_Date__c = system.today();
            obj_contact.Driving_States__c='AK;AL;';
            obj_updated_Driver_list.add(obj_contact);
        }
        update obj_updated_Driver_list;
        
        WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Driver');

        obj_admincontact.showTeamRecord__c = true;
        update obj_admincontact;
        Test.startTest();
        System.runAs(user_1) {
            WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Driver');
            EmployeeDetails obj_EmployeeDetails = WrapperUtils.getEmployeeDetails(obj_Driver_list[0],110.50,230.50);
            List<EmployeeDetails> obj_list_EmployeeDetails1 = new List<EmployeeDetails>();
            obj_list_EmployeeDetails1.add(obj_EmployeeDetails);
            
            WrapperUtils.getContact(obj_EmployeeDetails);
            WrapperUtils.getNewContact(obj_EmployeeDetails);
            WrapperUtils.getMonthName('11-2019');
            WrapperUtils.getMonthno('November');
            WrapperUtils.getMonthandYear('November');
            WrapperUtils.getMileagesOfReimbursement(obj_list_mileages[0]);
            WrapperUtils.getLastMonthValue(-1);
        
            WrapperUtils.getPacketandMeetingDetails(obj_Driver_list[0].id);
            List<String> reimbusementidList = new List<String>();
            reimbusementidList.add(obj_Employee_Reimbursement_list_update1[0]);
            WrapperUtils.updateReimbursements(JSON.serialize(reimbusementidList));
            WrapperUtils.updateContactThresholdLimit(JSON.serialize(obj_Employee_Reimbursement_list));
            WrapperUtils.getManager(obj_Driver_list[0].id,obj_admincontact.id);
            WrapperUtils.getadminname(obj_Driver_list[0].id);
            // ManagerDashboard Class Methods
            Attachment att = new Attachment();
            att.parentID = obj_Driver_list[0].Id;
            att.name = 'test';
            att.body = blob.valueOf('Test');
            insert att;
            WrapperUtils.getDriverGasPrice('CA','ON');
            WrapperUtils.getAllReimbursements(String.valueOf(System.today().Year()),String.valueOf(obj_Driver_list[0].id),obj_Account.id);
            WrapperUtils.getReimbursementsList(obj_Driver_list[0].id,'Approved');
            WrapperUtils.getMileages('November','2019',obj_Driver_list[0].id);
            WrapperUtils.getMileages1('November',String.valueOf(system.today().year()),obj_Driver_list[0].id);
            WrapperUtils.getpastYearReimbursement(obj_Driver_list[0].id);
            WrapperUtils.getLast2Years();
            WrapperUtils.getReimbursementsListClone(obj_Driver_list[0].id);
            WrapperUtils.approveReimbursements('2019',obj_Driver_list[0].id,obj_Account.id,JSON.serialize(obj_EmployeeReimbursements_list2));
            WrapperUtils.updateLockDate(obj_Account.id,obj_Driver_list[0].id);
            WrapperUtils.UpdateReimbursementStatus(obj_Employee_Reimbursement_list[0].id);
            WrapperUtils.getMileagesBasedTA('2020-01-01','2021-12-01',obj_Driver_list[0].id);
            //WrapperUtils.approveMileagesClone1(JSON.serialize(obj_list_mileages));
            //WrapperUtils.approveMileagesClone1(JSON.serialize(obj_list_mileages), 'Approved');
            //WrapperUtils.getUnapprovedReimbursements(obj_Driver_list[0].id,obj_Account.id,true,'Driver/Manager');
            WrapperUtils.TripCallout(obj_Driver_list[0].id,'February','2020','1.0','12',obj_Employee_Reimbursement_list[0].id,'2.1','U');
            WrapperUtils.readFromFileInchunk('test',att.Name,String.valueOf(att.Id),String.valueOf(obj_Driver_list[0].Id),String.valueOf(obj_Account.Id),null);
        }
        Test.stopTest();   
    }
    public static testmethod void wrapperUtilstestMethod1() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.Mileage_Lockdate__c = false;
        insert customSetting;
        
        WrapperUtils obj_WrapperUtils = new WrapperUtils();
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
        System.runAs(admin) {
             Account account_1 = new Account( Name = 'Community'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com');
            insert contact_1;
            
            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
    
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;       
    
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            insert obj_Manager_list;
    
            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            for(Contact currentContact:obj_Driver_list)
            {
                currentContact.compliancestatus__c='No – Vehicle Age';
            }
            insert obj_Driver_list;
             user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
              );
              insert user_1;
        }
        list<Gas_Prices__c> gaslist = RecordUtilityClass.buildGasPrice();
        insert gaslist;

        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        insert obj_Employee_Reimbursement_list;     

        EmployeeReimbursementDetailsAdmin empClass = new EmployeeReimbursementDetailsAdmin(); 
        empClass = WrapperUtils.getEmployeeReimbursementDetails(obj_Employee_Reimbursement_list[0]); 
        WrapperUtils.getMonthNamefromno(11);
        
        list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList1 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweekReimbursementList1;
        
        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list, empBIweekReimbursementList1[0].id);
        insert obj_Employee_Mileage_list;

        List<Employee_Reimbursement__c> obj_newreimbursements = new List<Employee_Reimbursement__c>();
        for(Contact obj:obj_Driver_list)
        {
            for(integer i=1;i<13;i++)
            {
                Employee_Reimbursement__c obj_Employee_Reimbursement = new Employee_Reimbursement__c();
                if(i<10)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'0'+String.valueOf(i)+'-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '0'+String.valueOf(i)+'-'+String.valueOf(System.today().year()-1);                               
                }
                else if(i==11)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'11-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '11-'+String.valueOf(System.today().year()-1);                 
                }
                else
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'12-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '12-'+String.valueOf(System.today().year()-1);              
                }
                obj_Employee_Reimbursement.Contact_Id__c = obj.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending';
                obj_Employee_Reimbursement.Approved_Date__c = null;
                obj_Employee_Reimbursement.IRS_Mileage_Rate__c = obj_IRS_Mileage_Rate[2].id;
                obj_newreimbursements.add(obj_Employee_Reimbursement);
            }
            for(integer i=1;i<=12;i++)
            {
                Employee_Reimbursement__c obj_Employee_Reimbursement = new Employee_Reimbursement__c();
                if(i<10)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'0'+String.valueOf(i)+'-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '0'+String.valueOf(i)+'-'+String.valueOf(System.today().year());                               
                }
                else if(i==11)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'11-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '11-'+String.valueOf(System.today().year());                 
                }
                else
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'12-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '12-'+String.valueOf(System.today().year());              
                }
                obj_Employee_Reimbursement.Contact_Id__c = obj.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending';
                obj_Employee_Reimbursement.Approved_Date__c = null;
                obj_Employee_Reimbursement.IRS_Mileage_Rate__c = obj_IRS_Mileage_Rate[2].id;
                obj_newreimbursements.add(obj_Employee_Reimbursement);
            }
            
        }
        insert obj_newreimbursements;
    
        List<Employee_Mileage__c> obj_Employee_Mileage_list1 = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_newreimbursements, empBIweekReimbursementList1[0].id);
        insert obj_Employee_Mileage_list1;

        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List3 = RecordUtilityClass.getEmployee_Reimbursement(obj_Account.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List3);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
    

        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list2=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list6=RecordUtilityClass.getallEmployeeMileages(obj_list_mileages);
        if(obj_EmployeeMileages_list6!=null && obj_EmployeeMileages_list6.size()>0)
        {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list6)
            {
                if(i==0)
                {
                    i++;
                    obj.isSelected=true;
                    obj_EmployeeMileages_list2.add(obj);
                }
                else
                {
                    i--;
                    obj.isChecked = true;
                    obj_EmployeeMileages_list1.add(obj);
                }
                
            }
        }
    // WrapperUtils.approveMileagesForAdminDash(JSON.serialize(obj_EmployeeMileages_list1),JSON.serialize(obj_EmployeeMileages_list2));
    
        
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list_update = new List<Employee_Reimbursement__c>();
        List<string> obj_Employee_Reimbursement_list_update1 = new List<string>();
        for(Employee_Reimbursement__c obj:obj_newreimbursements)
        {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        for(Employee_Reimbursement__c obj:obj_newreimbursements)
        {
            
            obj_Employee_Reimbursement_list_update1.add(obj.id);
        }
    

        EmployeeReimbursements obj_EmployeeReimbursements = WrapperUtils.getEmployeeReimbursements(obj_Employee_Reimbursement_list[0]);
        List<EmployeeReimbursements> obj_EmployeeReimbursements_list2 = new List<EmployeeReimbursements>();
        obj_EmployeeReimbursements_list2.add(obj_EmployeeReimbursements);
        
        
        for(Employee_Reimbursement__c obj:obj_Employee_Reimbursement_list)
        {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        update obj_Employee_Reimbursement_list_update;
       
        WrapperUtils.getChartData(obj_admincontact.id,obj_admincontact.showTeamRecord__c,obj_Account.id,'Driver');
        WrapperUtils.getComplianceCalculation(obj_Driver_list[0].id,String.valueOf(System.Today().year()));
        List<Contact> obj_updated_Driver_list =  new List<Contact>();
        for(Contact obj_contact:obj_Driver_list)
        {
            obj_contact.Deactivated_Date__c = system.today();
            obj_contact.Last_Pay_Date__c = system.today();
            obj_contact.Driving_States__c='AK;AL;';
            obj_updated_Driver_list.add(obj_contact);
        }
        update obj_updated_Driver_list;

        
        WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Driver');

        obj_admincontact.showTeamRecord__c = true;
        update obj_admincontact;
        Test.startTest();
        System.runAs(user_1) {
            WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Driver');
            EmployeeDetails obj_EmployeeDetails = WrapperUtils.getEmployeeDetails(obj_Driver_list[0],110.50,230.50);
            List<EmployeeDetails> obj_list_EmployeeDetails1 = new List<EmployeeDetails>();
            obj_list_EmployeeDetails1.add(obj_EmployeeDetails);
            
            WrapperUtils.getContact(obj_EmployeeDetails);
            WrapperUtils.getNewContact(obj_EmployeeDetails);
            WrapperUtils.getMonthName('11-2019');
            WrapperUtils.getMonthno('November');
            WrapperUtils.getMonthandYear('November');
            WrapperUtils.getMileagesOfReimbursement(obj_list_mileages[0]);
            WrapperUtils.getLastMonthValue(-1);
        
            WrapperUtils.getPacketandMeetingDetails(obj_Driver_list[0].id);
            List<String> reimbusementidList = new List<String>();
            reimbusementidList.add(obj_Employee_Reimbursement_list_update1[0]);
            WrapperUtils.updateReimbursements(JSON.serialize(reimbusementidList));
            WrapperUtils.updateContactThresholdLimit(JSON.serialize(obj_Employee_Reimbursement_list));
            WrapperUtils.getManager(obj_Driver_list[0].id,obj_admincontact.id);
            WrapperUtils.getadminname(obj_Driver_list[0].id);
            // ManagerDashboard Class Methods
            Attachment att = new Attachment();
            att.parentID = obj_Driver_list[0].Id;
            att.name = 'test';
            att.body = blob.valueOf('Test');
            insert att;
            WrapperUtils.getDriverGasPrice('CA','ON');
            WrapperUtils.getAllReimbursements(String.valueOf(System.today().Year()),String.valueOf(obj_Driver_list[0].id),obj_Account.id);
            WrapperUtils.getReimbursementsList(obj_Driver_list[0].id,'Approved');
            WrapperUtils.getMileages('November','2019',obj_Driver_list[0].id);
            WrapperUtils.getMileages1('November',String.valueOf(system.today().year()),obj_Driver_list[0].id);
            WrapperUtils.getpastYearReimbursement(obj_Driver_list[0].id);
            WrapperUtils.getLast2Years();
            WrapperUtils.getReimbursementsListClone(obj_Driver_list[0].id);
            WrapperUtils.approveReimbursements('2019',obj_Driver_list[0].id,obj_Account.id,JSON.serialize(obj_EmployeeReimbursements_list2));
            WrapperUtils.updateLockDate(obj_Account.id,obj_Driver_list[0].id);
            WrapperUtils.UpdateReimbursementStatus(obj_newreimbursements[0].id);
            WrapperUtils.readFromFileInchunk('test',att.Name,String.valueOf(att.Id),String.valueOf(obj_Driver_list[0].Id),String.valueOf(obj_Account.Id),null);
        }
        Test.stopTest();   
    }
    public static testmethod void wrapperUtilstestMethod2() {
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        customSetting.MappingGasStayTime__c = true;
        customSetting.ContactTriggersendEmailForNewContact__c = true;
        customSetting.ContactTriCommunityReimCreate__c = true;
        customSetting.Mileage_Lockdate__c = false;
        insert customSetting;
        
        WrapperUtils obj_WrapperUtils = new WrapperUtils();
        List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMD' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
         System.runAs(admin) {
             Account account_1 = new Account( Name = 'Community'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',External_Email__c= 'abc@gmail.com');
            insert contact_1;
            
            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
    
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;       
    
            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            insert obj_Manager_list;
    
            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            for(Contact currentContact:obj_Driver_list)
            {
                currentContact.compliancestatus__c='Resubmit Insurance – you submitted an insurance card';
            }
            insert obj_Driver_list;
            user_1 = new User( 
            Email = 'yourusername@gmail.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = contact_1.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
          );
          insert user_1;
        }
        list<Gas_Prices__c> gaslist = RecordUtilityClass.buildGasPrice();
        insert gaslist;

        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        insert obj_Employee_Reimbursement_list;       
         
         list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList1 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweekReimbursementList1;
        
        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list, empBIweekReimbursementList1[0].id);
        insert obj_Employee_Mileage_list;

        List<Employee_Reimbursement__c> obj_newreimbursements = new List<Employee_Reimbursement__c>();
    for(Contact obj:obj_Driver_list)
        {
            for(integer i=1;i<13;i++)
            {
                Employee_Reimbursement__c obj_Employee_Reimbursement = new Employee_Reimbursement__c();
                if(i<10)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'0'+String.valueOf(i)+'-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '0'+String.valueOf(i)+'-'+String.valueOf(System.today().year()-1);                               
                }
                else if(i==11)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'11-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '11-'+String.valueOf(System.today().year()-1);                 
                }
                else
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'12-'+String.valueOf(System.today().year()-1);               
                    obj_Employee_Reimbursement.Month__c = '12-'+String.valueOf(System.today().year()-1);              
                }
                obj_Employee_Reimbursement.Contact_Id__c = obj.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending';
                obj_Employee_Reimbursement.Approved_Date__c = null;
                obj_Employee_Reimbursement.IRS_Mileage_Rate__c = obj_IRS_Mileage_Rate[2].id;
                obj_newreimbursements.add(obj_Employee_Reimbursement);
            }
            for(integer i=1;i<=12;i++)
            {
                Employee_Reimbursement__c obj_Employee_Reimbursement = new Employee_Reimbursement__c();
                if(i<10)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'0'+String.valueOf(i)+'-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '0'+String.valueOf(i)+'-'+String.valueOf(System.today().year());                               
                }
                else if(i==11)
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'11-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '11-'+String.valueOf(System.today().year());                 
                }
                else
                {
                    obj_Employee_Reimbursement.Name = obj.name+':'+'12-'+String.valueOf(System.today().year());               
                    obj_Employee_Reimbursement.Month__c = '12-'+String.valueOf(System.today().year());              
                }
                obj_Employee_Reimbursement.Contact_Id__c = obj.Id;
                obj_Employee_Reimbursement.Status__c = 'Pending';
                obj_Employee_Reimbursement.Approved_Date__c = null;
                obj_Employee_Reimbursement.IRS_Mileage_Rate__c = obj_IRS_Mileage_Rate[2].id;
                obj_newreimbursements.add(obj_Employee_Reimbursement);
            }
            
        }
        insert obj_newreimbursements;
    
        List<Employee_Mileage__c> obj_Employee_Mileage_list1 = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_newreimbursements, empBIweekReimbursementList1[0].id);
        insert obj_Employee_Mileage_list1;

        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List3 = RecordUtilityClass.getEmployee_Reimbursement(obj_Account.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List3);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
    

        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list2=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list6=RecordUtilityClass.getallEmployeeMileages(obj_list_mileages);
        if(obj_EmployeeMileages_list6!=null && obj_EmployeeMileages_list6.size()>0)
        {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list6)
            {
                if(i==0)
                {
                    i++;
                    obj.isSelected=true;
                    obj_EmployeeMileages_list2.add(obj);
                }
                else
                {
                    i--;
                    obj.isChecked = true;
                    obj_EmployeeMileages_list1.add(obj);
                }
                
            }
        }
    // WrapperUtils.approveMileagesForAdminDash(JSON.serialize(obj_EmployeeMileages_list1),JSON.serialize(obj_EmployeeMileages_list2));
    
        
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list_update = new List<Employee_Reimbursement__c>();
        List<string> obj_Employee_Reimbursement_list_update1 = new List<string>();
        for(Employee_Reimbursement__c obj:obj_newreimbursements)
        {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        for(Employee_Reimbursement__c obj:obj_newreimbursements)
        {
            
            obj_Employee_Reimbursement_list_update1.add(obj.id);
        }
        

        EmployeeReimbursements obj_EmployeeReimbursements = WrapperUtils.getEmployeeReimbursements(obj_Employee_Reimbursement_list[0]);
        List<EmployeeReimbursements> obj_EmployeeReimbursements_list2 = new List<EmployeeReimbursements>();
        obj_EmployeeReimbursements_list2.add(obj_EmployeeReimbursements);
        
        
        for(Employee_Reimbursement__c obj:obj_Employee_Reimbursement_list)
        {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        update obj_Employee_Reimbursement_list_update;

        WrapperUtils.getChartData(obj_admincontact.id,obj_admincontact.showTeamRecord__c,obj_Account.id,'Driver');
        WrapperUtils.getComplianceCalculation(obj_Driver_list[0].id,String.valueOf(System.Today().year()));
        List<Contact> obj_updated_Driver_list =  new List<Contact>();
        for(Contact obj_contact:obj_Driver_list)
        {
            obj_contact.Deactivated_Date__c = system.today();
            obj_contact.Last_Pay_Date__c = system.today();
            obj_contact.Driving_States__c='AK;AL;';
            obj_updated_Driver_list.add(obj_contact);
        }
        update obj_updated_Driver_list;

        
        WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Driver');

        obj_admincontact.showTeamRecord__c = true;
        update obj_admincontact;
        Test.startTest();
            System.runAs(user_1) {
            WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Driver');
            EmployeeDetails obj_EmployeeDetails = WrapperUtils.getEmployeeDetails(obj_Driver_list[0],110.50,230.50);
            List<EmployeeDetails> obj_list_EmployeeDetails1 = new List<EmployeeDetails>();
            obj_list_EmployeeDetails1.add(obj_EmployeeDetails);
            
            WrapperUtils.getContact(obj_EmployeeDetails);
            WrapperUtils.getNewContact(obj_EmployeeDetails);
            WrapperUtils.getMonthName('11-2019');
            WrapperUtils.getMonthno('November');
            WrapperUtils.getMonthandYear('November');
            WrapperUtils.getMileagesOfReimbursement(obj_list_mileages[0]);
            WrapperUtils.getLastMonthValue(-1);
        
            WrapperUtils.getPacketandMeetingDetails(obj_Driver_list[0].id);
            List<String> reimbusementidList = new List<String>();
            reimbusementidList.add(obj_Employee_Reimbursement_list_update1[0]);
            WrapperUtils.updateReimbursements(JSON.serialize(reimbusementidList));
            WrapperUtils.updateContactThresholdLimit(JSON.serialize(obj_Employee_Reimbursement_list));
            WrapperUtils.getManager(obj_Driver_list[0].id,obj_admincontact.id);
            WrapperUtils.getadminname(obj_Driver_list[0].id);
            // ManagerDashboard Class Methods
            Attachment att = new Attachment();
            att.parentID = obj_Driver_list[0].Id;
            att.name = 'test';
            att.body = blob.valueOf('Test');
            insert att;
            WrapperUtils.getDriverGasPrice('CA','ON');
            WrapperUtils.getAllReimbursements(String.valueOf(System.today().Year()),String.valueOf(obj_Driver_list[0].id),obj_Account.id);
            WrapperUtils.getReimbursementsList(obj_Driver_list[0].id,'Approved');
            WrapperUtils.getMileages('November','2019',obj_Driver_list[0].id);
            WrapperUtils.getMileages1('November',String.valueOf(system.today().year()),obj_Driver_list[0].id);
            WrapperUtils.getpastYearReimbursement(obj_Driver_list[0].id);
            WrapperUtils.getLast2Years();
            WrapperUtils.getReimbursementsListClone(obj_Driver_list[0].id);
            WrapperUtils.approveReimbursements('2019',obj_Driver_list[0].id,obj_Account.id,JSON.serialize(obj_EmployeeReimbursements_list2));
            WrapperUtils.updateLockDate(obj_Account.id,obj_Driver_list[0].id);
            WrapperUtils.readFromFileInchunk('test',att.Name,String.valueOf(att.Id),String.valueOf(obj_Driver_list[0].Id),String.valueOf(obj_Account.Id),null);
            WrapperUtils.getUnapprovedReimbursements(obj_Driver_list[0].id,obj_Account.id,true,'Driver/Manager');
            WrapperUtils.getUnapprovedReimbursements(obj_Driver_list[0].id,obj_Account.id,true,'Admin');
            WrapperUtils.getUnapprovedReimbursements(obj_Driver_list[0].id,obj_Account.id,false,'Admin');
            WrapperUtils.getLastMonthReimbursements(obj_Driver_list[0].id,obj_Account.id,true,'Admin');
            WrapperUtils.getLastMonthReimbursements(obj_Driver_list[0].id,obj_Account.id,false,'Admin');
            WrapperUtils.getLastMonthReimbursements(obj_Driver_list[0].id,obj_Account.id,true,'Manager');
            }
        Test.stopTest();   
    }
}