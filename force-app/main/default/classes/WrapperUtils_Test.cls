@isTest
public class WrapperUtils_Test {

    public static testmethod void wrapperUtilstestMethod1() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c triggerCustomSetting1 = TestDataFactory.sendEmailCustomSetting(false,'EmployeeReimbursementTrigger');
        triggerCustomSetting1.Send_email_from_code__c = false;
        insert triggerCustomSetting1;
        WrapperUtils obj_WrapperUtils = new WrapperUtils();
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate = TestDataFactory.createIRSRate(true,0);
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        UserRole userRole_1 = TestDataFactory.getUserRole();
        Profile profile_1 = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole_1.Id);
        User user_1;
        Account obj_Account;
        Contact obj_admincontact;
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
        System.runAs(admin) {            
            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
            Contact contactObj = TestDataFactory.createCICDContact(true,obj_Account.Id);
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;       

            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            insert obj_Manager_list;

            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            for(Contact currentContact:obj_Driver_list) {
                currentContact.monthly_compliance_status__c='No – Insurance Card';
            }
            insert obj_Driver_list;
            user_1 = TestDataFactory.createUser(true, profile_1.Id, contactObj.Id);
        }
    
        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        Integer MonthNumber =1;
        Integer YearOfReimbursement= System.today().year(); 
        for(Employee_Reimbursement__c emr:obj_Employee_Reimbursement_list){
            if(MonthNumber>12){
                MonthNumber = 1;
            }
            emr.Month__c= (MonthNumber < 10 ? '0' : '') + String.valueOf(MonthNumber) +'-'+YearOfReimbursement;
            if(MonthNumber==12){
                emr.Month__c = '12-'+(YearOfReimbursement-1);
            }
            MonthNumber++;
            System.debug('emr.Month__c ==>'+emr.Month__c);
            System.debug('emr.Name ==>'+emr.Name);
        }
        //System.debug('@@@ obj_Employee_Reimbursement_list @@@'+obj_Employee_Reimbursement_list);
        insert obj_Employee_Reimbursement_list;  
        
        //String myJSON = JSON.serialize(obj_Employee_Reimbursement_list[0] );
        
        list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList4 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweekReimbursementList4;
        
        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list, empBIweekReimbursementList4[0].id);
        insert obj_Employee_Mileage_list;

        List<Employee_Reimbursement__c> obj_newreimbursements = TestDataFactory.createPendingReimbursement(true, obj_Driver_list, 10, obj_IRS_Mileage_Rate.id);
       
        list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList5 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweekReimbursementList5;
    
        List<Employee_Mileage__c> obj_Employee_Mileage_list1 = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_newreimbursements, empBIweekReimbursementList5[0].id);
        insert obj_Employee_Mileage_list1;

        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List3 = RecordUtilityClass.getEmployee_Reimbursement(obj_Account.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List3);
        
        List<String> milIdList = new List<String>();
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
        milIdList.add(obj_list_mileages[0].Id);
        
        /*List<string> EmpmilList = new List<string>();
        EmpmilList.add(obj_Employee_Mileage_list[0]); 
        */
        
        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list2=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list6=RecordUtilityClass.getallEmployeeMileages(obj_list_mileages);
        if(obj_EmployeeMileages_list6!=null && obj_EmployeeMileages_list6.size()>0) {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list6) {
                if(i==0) {
                    i++;
                    obj.isSelected=true;
                    obj_EmployeeMileages_list2.add(obj);
                } else {
                    i--;
                    obj.isChecked = true;
                    obj_EmployeeMileages_list1.add(obj);
                }                
            }
        }
    
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list_update = new List<Employee_Reimbursement__c>();
        List<string> obj_Employee_Reimbursement_list_update1 = new List<string>();
        for(Employee_Reimbursement__c obj:obj_newreimbursements) {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        for(Employee_Reimbursement__c obj:obj_newreimbursements) {            
            obj_Employee_Reimbursement_list_update1.add(obj.id);
        }
        EmployeeReimbursements obj_EmployeeReimbursements = WrapperUtils.getEmployeeReimbursements(obj_Employee_Reimbursement_list[0],23, 1);
        List<EmployeeReimbursements> obj_EmployeeReimbursements_list2 = new List<EmployeeReimbursements>();
        obj_EmployeeReimbursements_list2.add(obj_EmployeeReimbursements); 
        
        List<EmployeeReimbursements> obj_EmployeeReimbursements_list3 = new List<EmployeeReimbursements>();
        for(Integer i=0; i<12; i++){
            EmployeeReimbursements objEmpReim = WrapperUtils.getEmployeeReimbursements(obj_Employee_Reimbursement_list[i],23, 1); 
            obj_EmployeeReimbursements_list3.add(objEmpReim);   
        }
        
        for(Employee_Reimbursement__c obj:obj_Employee_Reimbursement_list) {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        //update obj_Employee_Reimbursement_list_update;
        

        WrapperUtils.getChartData(obj_admincontact.id,obj_admincontact.showTeamRecord__c,obj_Account.id,'Driver');
   
        WrapperUtils.TripCallout(obj_Driver_list[0].id,'January','2024','5.00','50',obj_newreimbursements[0].id,'50','Not Approved Yet');
        List<Contact> obj_updated_Driver_list =  new List<Contact>();
        for(Contact obj_contact:obj_Driver_list) {
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
            System.runAs(admin) { 
                //WrapperUtils.getComplianceCalculation(obj_Driver_list[0].id,String.valueOf(System.Today().year()));
            }
            System.runAs(user_1) {

                WrapperUtils.approveReimbursements('2024',obj_Driver_list[0].id,obj_Account.id,JSON.serialize(obj_EmployeeReimbursements_list3));
                WrapperUtils.getComplianceCalculation(obj_Driver_list[0].id,String.valueOf(System.Today().year()));

                WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Driver');
                WrapperUtils.getChartData(obj_admincontact.id,true,obj_Account.id,'Admin');
                WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Admin');
                WrapperUtils.getChartData(obj_admincontact.id,true,obj_Account.id,'Manager');
                WrapperUtils.getChartData(obj_admincontact.id,false,obj_Account.id,'Manager');
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
                
                WrapperUtils.getDriverFuelVariableRate(String.valueOf(obj_Driver_list[0].Id));
                WrapperUtils.getLastMonthReimbursements(String.valueOf(obj_Driver_list[0].Id), String.valueOf(obj_Account.Id), true, 'Driver');
                WrapperUtils.getLastMonthReimbursements(String.valueOf(obj_Driver_list[0].Id), String.valueOf(obj_Account.Id), true, 'Admin');
                WrapperUtils.getLastMonthReimbursements(String.valueOf(obj_Driver_list[0].Id), String.valueOf(obj_Account.Id), false, 'Admin');
                WrapperUtils.getLastMonthReimbursements(String.valueOf(obj_Driver_list[0].Id), String.valueOf(obj_Account.Id), true, 'Manager');
                WrapperUtils.getLastMonthReimbursements(String.valueOf(obj_Driver_list[0].Id), String.valueOf(obj_Account.Id), false, 'Manager');
                WrapperUtils.updateReimbursements(JSON.serialize(reimbusementidList));
                WrapperUtils.UpdateReimbursementStatus(obj_Employee_Reimbursement_list[0].Id);
                WrapperUtils.UpdateMileages(milIdList,'Not Approved Yet');

                // WrapperUtils.approveReimbursements('2024',obj_Driver_list[0].id,obj_Account.id,JSON.serialize(obj_Employee_Mileage_list));
                // WrapperUtils.getComplianceCalculation(obj_Driver_list[0].id,String.valueOf(System.Today().year()));
                
                String reimbursement = RecordUtilityClass.getUnapprovedReimbursements(obj_admincontact.id,obj_Account.id,true,'Admin');
                List<EmployeeMileagesForCalculation> employeereimbursementList = new List<EmployeeMileagesForCalculation>();
                employeereimbursementList = (List<EmployeeMileagesForCalculation>)JSON.deserialize(reimbursement,List<EmployeeMileagesForCalculation>.Class);
                system.debug('employeereimbursementList=='+ employeereimbursementList);
                WrapperUtils.getMileagesBasedTA(String.valueOf(System.today().addDays(-30)),String.valueOf(System.today().addDays(30)),String.valueOf(obj_admincontact.id));
                WrapperUtils.getUnapprovedMileages(JSON.serialize(employeereimbursementList[0]));
                // WrapperUtils.getComplianceCalculation(obj_Driver_list[0].id,String.valueOf(System.Today().year()));


                
                //WrapperUtils.approveMileagesClone1(JSON.serialize(EmpmilList ));
               // WrapperUtils.approveMileagesForAdminDash('true', 'true', 'Not Approved Yet', 'Test Mileages', 'test.email@gmail.com');
            }
        Test.stopTest();   
    }
    public static testmethod void wrapperUtilstestMethod2() {
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);
        SendEmail__c triggerCustomSetting1 = TestDataFactory.sendEmailCustomSetting(false,'EmployeeReimbursementTrigger');
        triggerCustomSetting1.Send_email_from_code__c = false;
        insert triggerCustomSetting1;

        WrapperUtils obj_WrapperUtils = new WrapperUtils();
        
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate = TestDataFactory.createIRSRate(true,0);
        
        RecordUtilityClass.sendEmailforCompliance();
        RecordUtilityClass.enableMappingGasPriceTrigger();
        RecordUtilityClass.vehicleUrlMapping();
        
        TrueDialog_Keys__c tdKeys = TestDataFactory.createTrueDialog(true);
        UserRole userRole_1 = TestDataFactory.getUserRole();
        Profile profile_1 = TestDataFactory.getUserProfile();
        User admin = TestDataFactory.getSystemAdminUser(userRole_1.Id);
        User user_1;
        Account obj_Account;
        Contact obj_admincontact;
        
        List<Contact> obj_Manager_list;
        List<Contact> obj_Driver_list;
        List<Contact> obj_Driver_list2;
        
        System.runAs(admin) {            
            obj_Account = RecordUtilityClass.buildAccount();
            insert obj_Account;
            Contact contactObj = TestDataFactory.createCICDContact(true,obj_Account.Id);
            obj_admincontact = RecordUtilityClass.buildAdminContact(obj_Account);
            insert obj_admincontact;       

            obj_Manager_list = RecordUtilityClass.buildManagerContact(obj_Account,obj_admincontact);
            insert obj_Manager_list;

            obj_Driver_list = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            for(Contact currentContact:obj_Driver_list) {
                currentContact.monthly_compliance_status__c='No – Insurance Card';
            }
            insert obj_Driver_list;

            // obj_Driver_list2 = RecordUtilityClass.buildDriverContact(obj_Account,obj_Manager_list[0]);
            // for(Contact currentContact:obj_Driver_list2) {
            //     currentContact.monthly_compliance_status__c='No – Insurance Card';
            // }
            // obj_Driver_list2[0].FirstName = 'Test';
            // obj_Driver_list2[0].LastName = 'ContactDriver';
            // obj_Driver_list2[0].External_Email__c = 'ContactDriver@gmail.com';
            // obj_Driver_list2[0].email = 'ContactDriver@gmail.com';

            // insert obj_Driver_list2;
            user_1 = TestDataFactory.createUser(true, profile_1.Id, contactObj.Id);
        }
    
        list<Employee_Reimbursement__c> obj_Employee_Reimbursement_list = RecordUtilityClass.buildPendingEmployee_Reimbursement(obj_Driver_list);
        insert obj_Employee_Reimbursement_list;  
        
        //String myJSON = JSON.serialize(obj_Employee_Reimbursement_list[0] );
        
        list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList4 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweekReimbursementList4;
        
        List<Employee_Mileage__c> obj_Employee_Mileage_list = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_Employee_Reimbursement_list, empBIweekReimbursementList4[0].id);
        insert obj_Employee_Mileage_list;

        List<Employee_Reimbursement__c> obj_newreimbursements = TestDataFactory.createPendingReimbursement(true, obj_Driver_list, 10, obj_IRS_Mileage_Rate.id);
       
        list<Bi_Weekly_Reimbursement__c> empBIweekReimbursementList5 = RecordUtilityClass.buildPendingBiReimbursement(obj_Driver_list);
        insert empBIweekReimbursementList5;
    
        List<Employee_Mileage__c> obj_Employee_Mileage_list1 = RecordUtilityClass.buildNoApprovedYetEmployeeMileages(obj_newreimbursements, empBIweekReimbursementList5[0].id);
        insert obj_Employee_Mileage_list1;

        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_List3 = RecordUtilityClass.getEmployee_Reimbursement(obj_Account.id);
        List<EmployeeReimbursementDetailsAdmin> obj_EmployeeReimbursementDetailsAdmin_List = RecordUtilityClass.getListofEmployeeReimbursementDetailsAdmin(obj_Employee_Reimbursement_List3);
        List<Employee_Mileage__c> obj_list_mileages =  RecordUtilityClass.getMileagesList();
        /*List<string> EmpmilList = new List<string>();
        EmpmilList.add(obj_Employee_Mileage_list[0]); 
        */
        
        List<EmployeeMileages> obj_EmployeeMileages_list1=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list2=new List<EmployeeMileages>();
        List<EmployeeMileages> obj_EmployeeMileages_list6 = RecordUtilityClass.getallEmployeeMileages(obj_list_mileages);
        if(obj_EmployeeMileages_list6!=null && obj_EmployeeMileages_list6.size()>0) {
            Integer i=0;
            for(EmployeeMileages obj:obj_EmployeeMileages_list6) {
                if(i==0) {
                    i++;
                    obj.isSelected=true;
                    obj_EmployeeMileages_list2.add(obj);
                } else {
                    i--;
                    obj.isChecked = true;
                    obj_EmployeeMileages_list1.add(obj);
                }                
            }
        }
    
        List<Employee_Reimbursement__c> obj_Employee_Reimbursement_list_update = new List<Employee_Reimbursement__c>();
        List<string> obj_Employee_Reimbursement_list_update1 = new List<string>();
        for(Employee_Reimbursement__c obj:obj_newreimbursements) {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        for(Employee_Reimbursement__c obj:obj_newreimbursements) {            
            obj_Employee_Reimbursement_list_update1.add(obj.id);
        }
        EmployeeReimbursements obj_EmployeeReimbursements = WrapperUtils.getEmployeeReimbursements(obj_Employee_Reimbursement_list[0],23, 1);
        List<EmployeeReimbursements> obj_EmployeeReimbursements_list2 = new List<EmployeeReimbursements>();
        obj_EmployeeReimbursements_list2.add(obj_EmployeeReimbursements);    
        
        for(Employee_Reimbursement__c obj:obj_Employee_Reimbursement_list) {
            obj.Approved_Date__c = system.today();
            obj.Status__c = 'Approved';
            obj_Employee_Reimbursement_list_update.add(obj);
        }
        //update obj_Employee_Reimbursement_list_update;
        

        List<Contact> obj_updated_Driver_list =  new List<Contact>();
        for(Contact obj_contact:obj_Driver_list) {
            obj_contact.Deactivated_Date__c = system.today();
            obj_contact.Last_Pay_Date__c = system.today();
            obj_contact.Driving_States__c='AK;AL;';
            obj_updated_Driver_list.add(obj_contact);
        }
        update obj_updated_Driver_list;
        obj_admincontact.showTeamRecord__c = true;
        update obj_admincontact;
        Test.startTest();
        WrapperUtils.getUnapprovedReimbursements(String.valueOf(obj_admincontact.Id), String.valueOf(obj_Account.Id), true, 'Admin');
        WrapperUtils.getUnapprovedReimbursements(String.valueOf(obj_admincontact.Id), String.valueOf(obj_Account.Id), false, 'Admin');
        WrapperUtils.getUnapprovedReimbursements(String.valueOf(obj_Manager_list[0].Id), String.valueOf(obj_Account.Id), true, 'Manager');
        WrapperUtils.getUnapprovedReimbursements(String.valueOf(obj_Manager_list[0].Id), String.valueOf(obj_Account.Id), false, 'Manager');
       // WrapperUtils.approveMileagesForAdminDash(String.valueOf(obj_Manager_list[0].Id), String.valueOf(obj_Account.Id), false, 'Manager');     
        WrapperUtils.getMonthNamefromno(01);

        List<Employee_Mileage__c> obj_list_mileages2 =  RecordUtilityClass.getMileagesList();
        for(Employee_Mileage__c objEmpReim : obj_list_mileages2){
            objEmpReim.Approved_Date__c = System.today();
            objEmpReim.Trip_Status__c = 'Approved';
            objEmpReim.EmployeeReimbursement__r.Mileage_Lock_Date__c = System.today(); 
            objEmpReim.Approval_Name__c = 'TestUser';
            objEmpReim.Stay_Time__c = null;
            objEmpReim.Trip_Status__c = 'Rejected';
            objEmpReim.Original_Destination_Name__c = 'loc1';
            objEmpReim.Original_Origin_Name__c = 'loc11';
            objEmpReim.Destination_Name__c = 'des1';
            objEmpReim.Mileage__c = null;
        }
        update obj_list_mileages2;
        WrapperUtils.getMileagesOfReimbursement(obj_list_mileages2[0]);
 
        System.runAs(admin) {
            obj_Driver_list[0].Final_Payroll_Amount__c = 23;
            obj_Driver_list[0].Division__c = 34;
            obj_Driver_list[0].First_Payroll__c = '50%';
            obj_Driver_list[0].Last_Pay_Date__c = null;
            obj_Driver_list[0].Code__c = '345';
            obj_Driver_list[0].District__c = 'Florida';
            obj_Driver_list[0].Deactivated_Date__c = null;
            obj_Driver_list[0].Freeze__c = null;
            obj_Driver_list[0].Driving_States__c = null;
            obj_Driver_list[0].LOA_Fixed_Amount__c = 43;
            obj_Driver_list[0].LOA_Start_Date__c = System.today();
            obj_Driver_list[0].LOA_End_Date__c = System.today().addMonths(1);
            obj_Driver_list[0].Payroll_Period__c = '07/25/21 to 08/07/21';
            update obj_Driver_list;
        }
        EmployeeDetails obj_EmployeeDetails = WrapperUtils.getEmployeeDetails(obj_Driver_list[0],110.50,230.50);
        WrapperUtils.getContact(obj_EmployeeDetails);  
        
        System.runAs(admin) {
            obj_newreimbursements[0].Mileage_Lock_Date__c = System.today();
            obj_newreimbursements[0].Approved_Date__c = System.today();
            update obj_newreimbursements;
        }
        WrapperUtils.getEmployeeReimbursementDetails(obj_newreimbursements[0]);
        WrapperUtils.ReportUnlock(String.valueOf(obj_Account.Id));
        Test.stopTest();   
    }
}