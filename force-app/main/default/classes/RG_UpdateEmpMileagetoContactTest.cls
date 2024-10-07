/*
* Batch Class Cover
*/
@istest
public class RG_UpdateEmpMileagetoContactTest {
    public static testmethod void main() {
        
        Batch_Configuration__c batchConfig = new Batch_Configuration__c();
        batchConfig.Emp_Mileage_Update_For_Emp_Mileage__c = true;
        batchConfig.Name='Test';
        insert batchConfig;
        
        
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        PageReference pageref = Page.RG_UpdateEmployeeMileageBatch;
        Test.setCurrentPage(pageref);
        
         
        
        //Create Account
        Account acc = new Account(Name = 'TestAcc',
                                Lock_date__c = system.today()); 
        insert acc;
        list<Contact> newContactList = new list<Contact>();
        Contact mgrInsert = new contact(lastName = 'testManagerEmail',
                                      accountid = acc.id,
                                      External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                      Fixed_Amount__c = 5000,
                                      Maintenance_and_Tires__c = 2000,
                                      Vehicle1Odometer__c = 120,
                                      Vehicle2Odometer__c = 150,
                                      MailingStreet = 'testMailingCity',
                                      MailingCity = 'testCity',
                                      MailingState = 'testState',
                                      MailingPostalCode = '110085',
                                      MailingCountry = 'TestCountry',
                                      MPG__c = 12,
                                      compliancestatus__c = 'Yes',
                                      Vehicle_Type__c = 'TestVechleType',
                                      Role__c = 'Manager',
                                      isCommunityUser__c = true,
                                      Monthly_Mileage_Limit__c = 100);
        insert mgrInsert;
        newContactList.add(new Contact(LastName = 'Nitesh Test',
                                       Monthly_Mileage_Limit__c = 200, 
                                       Accountid = acc.Id, 
                                       isCommunityUser__c = true,
                                       External_Email__c = 'nitesh'+DateTime.now().millisecond()+'@test.com',
                                       MailingCity = 'Bhopal',
                                       MailingState = 'MP'));
        for(integer i = 1;i <= 100; i++) { 
            newContactList.add(new Contact(lastName = 'test'+i,
                                           accountid = acc.id, 
                                           Manager__c  =  mgrInsert.Id, 
                                           Manager_External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                           External_Email__c = 'test'+i+'@test'+DateTime.now().millisecond()+'.com',
                                           Fixed_Amount__c = 5000,
                                           isCommunityUser__c = true,
                                           Maintenance_and_Tires__c = 2000,
                                           Vehicle1Odometer__c = 120,
                                           Vehicle2Odometer__c = 150,
                                           MailingStreet = 'testMailingCity'+i,
                                           MailingCity = 'testCity'+i,
                                           MailingState = 'testState'+i,
                                           MailingPostalCode = '110085',
                                           MailingCountry = 'TestCountry'+i,
                                           MPG__c = 12,
                                           compliancestatus__c = 'Yes',
                                           Vehicle_Type__c = 'TestVechleType'+i,
                                           Role__c = 'Driver',
                                           Monthly_Mileage_Limit__c = 100));
        }
        insert newContactList;
        
        //Reimbursement
        String temp1 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        string lastmonth =  temp1.left(2);
        if(lastmonth.contains('-'))
            lastmonth = '0'+temp1;
        else  
            lastmonth = temp1;
        String temp2 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-2).year();
        string lastmonth2 =  temp2.left(2);
        if(lastmonth2.contains('-'))
            lastmonth2 = '0'+temp2;
        else  
            lastmonth2 = temp2;
        list<Employee_Reimbursement__c> emprinblist =  new list<Employee_Reimbursement__c>();
        Employee_Reimbursement__c Emprimb = new Employee_Reimbursement__c(Name = 'rimbTest',
                                                                        Contact_Id__c =  newContactList[0].id, 
                                                                        Month__c = lastmonth2);
        Employee_Reimbursement__c Emprimb2 = new Employee_Reimbursement__c(Name = 'rimbTest',
                                                                         Contact_Id__c =  newContactList[0].id, 
                                                                         Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb3 = new Employee_Reimbursement__c(Name = 'rimbTest',
                                                                         Contact_Id__c =  newContactList[0].id, 
                                                                         Month__c = lastmonth);
        emprinblist.add(Emprimb);
        emprinblist.add(Emprimb2);
        insert emprinblist;
        
        list<Employee_Mileage__c> empMileage = new list<Employee_Mileage__c>();
        for(integer i = 1;i<=50;i++) { 
            empMileage.add(new Employee_Mileage__c(Name = 'empMil'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'nitesh@test.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimb2.id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMilApproved'+i,
                                                   Mileage__c = 20,
                                                   trip_status__c = 'Approved',
                                                   Approved_Date__c = date.today().toStartOfMonth().addDays(-1),
                                                   Contact_Email_Id__c = 'nitesh@test.com',
                                                   Trip_Date__c = date.today().addMonths(-1),
                                                   EmployeeReimbursement__c = Emprimb.id));
            
        }
        
        
        insert empMileage;
        
        Gas_Prices__c newGasPrice = new Gas_Prices__c(City__c = 'Bhopal',
                                                    Fuel_Price__c = 65,
                                                    Month_Year__c = Date.today().addmonths(-1).tostartofmonth(),
                                                    State__c = 'MP');
        insert newGasPrice;
        
        
        //Batch class 
        test.starttest();
        RG_EmpMileageUpdate empMileageobj = new RG_EmpMileageUpdate();
        empMileageobj.updatebatchEmployeeMileage();
        test.stoptest();
        
        list<Contact> con = [Select id, Name, External_Email__c,(Select id,Name, Month__c from Employee_Reimbursements__r) from Contact];
        
        list<Employee_Reimbursement__c> reimbMM = new list<Employee_Reimbursement__c>();
        for(Contact c : con) { 
            for(Employee_Reimbursement__c reimbM : c.Employee_Reimbursements__r) { 
                reimbMM.add(reimbM);
            }
        }
        
        
        
    } 
    
    public static testmethod void main2() { 
        
         TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
    
        Account acc = new Account(Name = 'TestAcc',Enable_Email_For_Managers__c = true); 
        insert acc; 
        list<Contact> newContactList = new list<Contact>();
        Contact mgrInsert = new contact(lastName = 'testManagerEmail',
                                      accountid = acc.id,
                                      External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                      Fixed_Amount__c = 5000,
                                      Maintenance_and_Tires__c = 2000,
                                      isCommunityUser__c = true,
                                      Vehicle1Odometer__c = 120,
                                      Vehicle2Odometer__c = 150,
                                      MailingStreet = 'testMailingCity',
                                      MailingCity = 'testCity',
                                      MailingState = 'testState',
                                      MailingPostalCode = '110085',
                                      MailingCountry = 'TestCountry',
                                      MPG__c = 12,
                                      compliancestatus__c = 'Yes',
                                      Vehicle_Type__c = 'TestVechleType',
                                      Role__c = 'admin',
                                      Monthly_Mileage_Limit__c = 100);
        insert mgrInsert;
        newContactList.add(new Contact(LastName = 'Nitesh Test', 
                                       Accountid = acc.Id, 
                                       isCommunityUser__c = true,
                                       External_Email__c = 'nitesh'+DateTime.now().millisecond()+'@test.com',
                                       Monthly_Mileage_Limit__c = 200,
                                       MailingCity = 'Bhopal',
                                       MailingState = 'MP'));
        for(integer i = 1;i<=10;i++) { 
            newContactList.add(new Contact(lastName = 'test'+i,
                                           accountid = acc.id,
                                           Manager__c = mgrInsert.id,
                                           isCommunityUser__c = true,
                                           Manager_External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                           External_Email__c = 'test'+i+'@test'+DateTime.now().millisecond()+'.com',
                                           Fixed_Amount__c = 5000,
                                           Maintenance_and_Tires__c = 2000,
                                           Vehicle1Odometer__c = 120,
                                           Vehicle2Odometer__c = 150,
                                           MailingStreet = 'testMailingCity'+i,MailingCity = 'testCity'+i,
                                           MailingState = 'testState'+i,
                                           MailingPostalCode = '110085',
                                           MailingCountry = 'TestCountry'+i,
                                           MPG__c = 12,
                                           compliancestatus__c = 'Yes',
                                           Vehicle_Type__c = 'TestVechleType'+i,
                                           Role__c = 'Manager',
                                           Monthly_Mileage_Limit__c = 100));
        }
        insert newContactList;
        list<contact> conlist  =  new list<contact>();
        for(integer i = 1;i<=4;i++) { 
            conlist.add(new Contact(lastName = 'test'+i,
                                    accountid = acc.id,
                                    Manager__c = newContactList[i-1].id,
                                    External_Email__c = 'testtest'+i+'@testtest'+DateTime.now().millisecond()+'.com',
                                    Fixed_Amount__c = 5000,
                                    Maintenance_and_Tires__c = 2000,
                                    Vehicle1Odometer__c = 120,
                                    Vehicle2Odometer__c = 150,
                                    MailingStreet = 'testMailingCity'+i,
                                    MailingCity = 'testCity'+i,
                                    MailingState = 'testState'+i,
                                    MailingPostalCode = '110085',
                                    MailingCountry = 'TestCountry'+i,
                                    MPG__c = 12,
                                    compliancestatus__c = 'Yes',
                                    Vehicle_Type__c = 'TestVechleType'+i,
                                    Role__c = 'Driver',
                                    Monthly_Mileage_Limit__c = 100));
        }
        insert conlist;
        
        list<user> userlist = [select IsActive,
                                    email,
                                    contact.account.Enable_Email_For_Managers__c,
                                    contactid 
                            from user 
                            where IsActive=:true 
                            and contactid!=null 
                            and contact.accountid != null 
                            and contact.account.Enable_Email_For_Managers__c = true];     //
        //Reimbursement
        String temp1 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        string lastmonth =  temp1.left(2);
        if(lastmonth.contains('-'))
            lastmonth = '0'+temp1;
        else  
            lastmonth = temp1;
        list<Employee_Reimbursement__c> Emprimblist = new list<Employee_Reimbursement__c>();
        Employee_Reimbursement__c Emprimb = new Employee_Reimbursement__c(Name = 'rimbTest1',
                                                                        contact_id__c =  newContactList[0].id, 
                                                                        Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb2 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  newContactList[1].id, 
                                                                         Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb3 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  conlist[0].id, 
                                                                         Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb4 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  conlist[1].id, 
                                                                         Month__c = lastmonth);
        Emprimblist.add(Emprimb);
        Emprimblist.add(Emprimb2);
        Emprimblist.add(Emprimb3);
        Emprimblist.add(Emprimb4);
        insert Emprimblist;
        
        list<Employee_Mileage__c> empMileage = new list<Employee_Mileage__c>();
        for(integer i = 1;i<=5;i++) { 
            empMileage.add(new Employee_Mileage__c(Name = 'empMil1'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testManagerr11@test.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimb.id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil2'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testManagerr11@test.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimb2.id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil3'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testtest1@testtest1.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimb3.id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil4'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testtest2@testtest2.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimb4.id));
        }
        insert empMileage;
       
        Gas_Prices__c newGasPrice = new Gas_Prices__c(City__c = 'Bhopal',
                                                    Fuel_Price__c = 65,
                                                    Month_Year__c = Date.today().addmonths(-1).tostartofmonth(),
                                                    State__c = 'MP');
        insert newGasPrice;
        
        test.starttest();
        RG_AutoApprovedEmailClass emailbatch = new RG_AutoApprovedEmailClass();
        database.executeBatch(emailbatch,20); 
        test.stoptest();
        list<Contact> con = [Select id, Name, External_Email__c,(Select id,Name, Month__c from Employee_Reimbursements__r) from Contact];
        
        list<Employee_Reimbursement__c> reimbMM = new list<Employee_Reimbursement__c>();
        for(Contact c : con) { 
            for(Employee_Reimbursement__c reimbM : c.Employee_Reimbursements__r) { 
                reimbMM.add(reimbM);
            }
        }
    }
    
    public static testmethod void main3() { 
        
         TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Account acc = new Account(Name = 'TestAcc'); 
        insert acc;
        list<Contact> newContactList = new list<Contact>();
        Contact mgrInsert = new contact(lastName = 'testManagerEmail',
                                      accountid = acc.id,
                                      External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                      Fixed_Amount__c = 5000,
                                      isCommunityUser__c = true,
                                      Maintenance_and_Tires__c = 2000,
                                      Vehicle1Odometer__c = 120,
                                      Vehicle2Odometer__c = 150,
                                      MailingStreet = 'testMailingCity',
                                      MailingCity = 'testCity',
                                      MailingState = 'testState',
                                      MailingPostalCode = '110085',
                                      MailingCountry = 'TestCountry',
                                      MPG__c = 12,
                                      compliancestatus__c = 'Yes',
                                      Vehicle_Type__c = 'TestVechleType',
                                      Role__c = 'admin',
                                      Monthly_Mileage_Limit__c = 100);
        insert mgrInsert;
        newContactList.add(new Contact(LastName = 'Nitesh Test', 
                                       Accountid = acc.Id, 
                                       isCommunityUser__c = true,
                                       Manager__c  =  mgrInsert.Id, 
                                       External_Email__c = 'nitesh'+DateTime.now().millisecond()+'@test.com',
                                       Monthly_Mileage_Limit__c = 200,
                                       MailingCity = 'Bhopal',
                                       MailingState = 'MP'));
        for(integer i = 1; i<=10; i++) { 
            newContactList.add(new Contact(lastName = 'test'+i,
                                           accountid = acc.id,
                                           isCommunityUser__c = true,
                                           Manager__c = mgrInsert.id,
                                           Manager_External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                           External_Email__c = 'test'+i+'@test'+DateTime.now().millisecond()+'.com',
                                           Fixed_Amount__c = 5000,
                                           Maintenance_and_Tires__c = 2000,
                                           Vehicle1Odometer__c = 120,
                                           Vehicle2Odometer__c = 150,
                                           MailingStreet = 'testMailingCity'+i,
                                           MailingCity = 'testCity'+i,
                                           MailingState = 'testState'+i,
                                           MailingPostalCode = '110085',
                                           MailingCountry = 'TestCountry'+i,
                                           MPG__c = 12,
                                           compliancestatus__c = 'Yes',
                                           Vehicle_Type__c = 'TestVechleType'+i,
                                           Role__c = 'Manager',
                                           Monthly_Mileage_Limit__c = 100));
        }
        insert newContactList;
        list<contact> conlist = new list<contact>();
        for(integer i=1; i<=4; i++) { 
            conlist.add(new Contact(lastName = 'test'+i,
                                    accountid = acc.id,
                                    isCommunityUser__c = true,
                                    Manager__c = newContactList[i-1].id,
                                    External_Email__c = 'testtest'+i+'@testtest'+DateTime.now().millisecond()+'.com',
                                    Fixed_Amount__c = 5000,
                                    Maintenance_and_Tires__c = 2000,
                                    Vehicle1Odometer__c = 120,
                                    Vehicle2Odometer__c = 150,
                                    MailingStreet = 'testMailingCity'+i,
                                    MailingCity = 'testCity'+i,
                                    MailingState = 'testState'+i,
                                    MailingPostalCode = '110085',
                                    MailingCountry = 'TestCountry'+i,
                                    MPG__c = 12,
                                    compliancestatus__c = 'Yes',
                                    Vehicle_Type__c = 'TestVechleType'+i,
                                    Role__c = 'Driver'));
        }
        insert conlist;
        //Reimbursement
        String temp1 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        string lastmonth =  temp1.left(2);
        if(lastmonth.contains('-'))
            lastmonth = '0'+temp1;
        else  
            lastmonth = temp1;
        list<Employee_Reimbursement__c> Emprimblist  =  new list<Employee_Reimbursement__c>();
        Employee_Reimbursement__c Emprimb = new Employee_Reimbursement__c(Name = 'rimbTest1',
                                                                        contact_id__c =  newContactList[0].id, 
                                                                        Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb2 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  newContactList[1].id, 
                                                                         Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb3 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  conlist[0].id, 
                                                                         Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb4 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  conlist[1].id, 
                                                                         Month__c = lastmonth);
        Emprimblist.add(Emprimb);
        Emprimblist.add(Emprimb2);
        Emprimblist.add(Emprimb3);
        Emprimblist.add(Emprimb4);
        insert Emprimblist;
        list<Employee_Mileage__c> empMileage = new list<Employee_Mileage__c>();
        for(integer i = 1;i <= 5; i++) { 
            empMileage.add(new Employee_Mileage__c(Name = 'empMil1'+i,
                                                   Mileage__c = 300,
                                                   Contact_Email_Id__c = 'testManagerr11@test.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[0].id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil2'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testManagerr11@test.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[1].id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil3'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testtest1@testtest1.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[2].id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil4'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testtest2@testtest2.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[3].id));
        }
        insert empMileage;
        
        for(Employee_Mileage__c m : empMileage) { 
            if(m.name.contains('empMil1'))
                m.EmployeeReimbursement__c = Emprimb.id;
            if(m.name.contains('empMil2'))
                m.EmployeeReimbursement__c = Emprimb2.id;
            if(m.name.contains('empMil3'))
                m.EmployeeReimbursement__c = Emprimb3.id;
            if(m.name.contains('empMil4'))
                m.EmployeeReimbursement__c = Emprimb4.id;
            
        }
        update empMileage;
        
        Gas_Prices__c newGasPrice = new Gas_Prices__c(City__c = 'Bhopal',
                                                      Fuel_Price__c = 65,
                                                      Month_Year__c = Date.today().addmonths(-1).tostartofmonth(),
                                                      State__c = 'MP');
        insert newGasPrice;
        
        test.starttest();
        RG_BatchForApprovingReimburse emailbatch = new RG_BatchForApprovingReimburse();
        database.executeBatch(emailbatch,4);
        test.stoptest();
        list<Contact> con = [Select id, Name, External_Email__c,(Select id,Name, Month__c from Employee_Reimbursements__r) from Contact];
        list<Employee_Mileage__c> mlist =  [select id, name from Employee_Mileage__c where EmployeeReimbursement__c In :  Emprimblist];
        list<Employee_Reimbursement__c> reimbMM = new list<Employee_Reimbursement__c>();
        for(Contact c : con) { 
            for(Employee_Reimbursement__c reimbM : c.Employee_Reimbursements__r) { 
                reimbMM.add(reimbM);
            }
        
        }
    }
    public static testmethod void main4() { 
    
         TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        
        Account acc = new Account(Name = 'TestAcc', Lock_Date__c = System.today().addDays(-1).addMonths(-1)); 
        insert acc;
        list<Contact> newContactList = new list<Contact>();
        Contact mgrInsert = new contact(lastName = 'testManagerEmail',
                                      accountid = acc.id,
                                      isCommunityUser__c = true,
                                      External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                      Fixed_Amount__c = 5000,
                                      Maintenance_and_Tires__c = 2000,
                                      Vehicle1Odometer__c = 120,
                                      Vehicle2Odometer__c = 150,
                                      MailingStreet = 'testMailingCity',
                                      MailingCity = 'testCity',
                                      MailingState = 'testState',
                                      MailingPostalCode = '110085',
                                      MailingCountry = 'TestCountry',
                                      MPG__c = 12,
                                      compliancestatus__c = 'Yes',
                                      Vehicle_Type__c = 'TestVechleType',
                                      Role__c = 'admin',
                                      Monthly_Mileage_Limit__c = 100);
        insert mgrInsert;
        newContactList.add(new Contact(LastName = 'Nitesh Test', 
                                       Accountid = acc.Id, 
                                       isCommunityUser__c = true,
                                       Manager__c  =  mgrInsert.Id, 
                                       External_Email__c = 'nitesh'+DateTime.now().millisecond()+'@test.com',
                                       Monthly_Mileage_Limit__c = 200,
                                       MailingCity = 'Bhopal',
                                       MailingState = 'MP'));
        for(integer i = 1; i<=10; i++) { 
            newContactList.add(new Contact(lastName = 'test'+i,
                                           accountid = acc.id,
                                           Manager__c = mgrInsert.id,
                                           isCommunityUser__c = true,
                                           Manager_External_Email__c = 'testManagerr11'+DateTime.now().millisecond()+'@test.com',
                                           External_Email__c = 'test'+i+'@test'+DateTime.now().millisecond()+'.com',
                                           Fixed_Amount__c = 5000,
                                           Maintenance_and_Tires__c = 2000,
                                           Vehicle1Odometer__c = 120,
                                           Vehicle2Odometer__c = 150,
                                           MailingStreet = 'testMailingCity'+i,
                                           MailingCity = 'testCity'+i,
                                           MailingState = 'testState'+i,
                                           MailingPostalCode = '110085',
                                           MailingCountry = 'TestCountry'+i,
                                           MPG__c = 12,
                                           compliancestatus__c = 'Yes',
                                           Vehicle_Type__c = 'TestVechleType'+i,
                                           Role__c = 'Manager',
                                           Monthly_Mileage_Limit__c = 100));
        }
        insert newContactList;
        list<contact> conlist = new list<contact>();
        for(integer i=1; i<=4; i++) { 
            conlist.add(new Contact(lastName = 'test'+i,
                                    account = acc,
                                    isCommunityUser__c = true,
                                    accountId = acc.Id,
                                    Manager__c = newContactList[i-1].id,
                                    External_Email__c = 'testtest'+i+'@testtest'+DateTime.now().millisecond()+'.com',
                                    Fixed_Amount__c = 5000,
                                    Maintenance_and_Tires__c = 2000,
                                    Vehicle1Odometer__c = 120,
                                    Vehicle2Odometer__c = 150,
                                    MailingStreet = 'testMailingCity'+i,
                                    MailingCity = 'testCity'+i,
                                    MailingState = 'testState'+i,
                                    MailingPostalCode = '110085',
                                    MailingCountry = 'TestCountry'+i,
                                    MPG__c = 12,
                                    compliancestatus__c = 'Yes',
                                    Vehicle_Type__c = 'TestVechleType'+i,
                                    Role__c = 'Driver'));
        }
        insert conlist;
        //Reimbursement
        String temp1 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        string lastmonth =  temp1.left(2);
        if(lastmonth.contains('-'))
            lastmonth = '0'+temp1;
        else  
            lastmonth = temp1;
        list<Employee_Reimbursement__c> Emprimblist  =  new list<Employee_Reimbursement__c>();
        Employee_Reimbursement__c Emprimb = new Employee_Reimbursement__c(Name = 'rimbTest1',
                                                                        contact_id__c =  newContactList[0].id, 
                                                                        Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb2 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  newContactList[1].id, 
                                                                         Month__c = lastmonth);
        Employee_Reimbursement__c Emprimb4 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__c =  conlist[1].id, 
                                                                         Month__c = lastmonth);
                                                                         
        temp1 = Date.today().addMonths(-2).month()+'-'+Date.today().addmonths(-2).year();
        lastmonth =  temp1.left(2);
        if(lastmonth.contains('-'))
            lastmonth = '0'+temp1;
        else  
            lastmonth = temp1;
        Employee_Reimbursement__c Emprimb3 = new Employee_Reimbursement__c(Name = 'rimbTest2',
                                                                         contact_id__r =  conlist[0],
                                                                         contact_id__c =  conlist[0].Id,
                                                                         Month__c = lastmonth);
            
        Emprimblist.add(Emprimb);
        Emprimblist.add(Emprimb2);
        Emprimblist.add(Emprimb3);
        Emprimblist.add(Emprimb4);
        insert Emprimblist;
        list<Employee_Mileage__c> empMileage = new list<Employee_Mileage__c>();
        for(integer i = 1;i <= 5; i++) { 
            empMileage.add(new Employee_Mileage__c(Name = 'empMil1'+i,
                                                   Mileage__c = 300,
                                                   Contact_Email_Id__c = 'testManagerr11@test.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[0].id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil2'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testManagerr11@test.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[1].id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil3'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testtest1@testtest1.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[2].id));
            empMileage.add(new Employee_Mileage__c(Name = 'empMil4'+i,
                                                   Mileage__c = 2,
                                                   Contact_Email_Id__c = 'testtest2@testtest2.com',
                                                   Trip_Date__c = date.today(),
                                                   EmployeeReimbursement__c = Emprimblist[3].id));
        }
        insert empMileage;
        
        for(Employee_Mileage__c m : empMileage) { 
            if(m.name.contains('empMil1'))
                m.EmployeeReimbursement__c = Emprimb.id;
            if(m.name.contains('empMil2'))
                m.EmployeeReimbursement__c = Emprimb2.id;
            if(m.name.contains('empMil3'))
                m.EmployeeReimbursement__r = Emprimb3;
            if(m.name.contains('empMil4'))
                m.EmployeeReimbursement__c = Emprimb4.id;
            
        }
        update empMileage;
        Gas_Prices__c newGasPrice = new Gas_Prices__c(City__c = 'Bhopal',
                                                      Fuel_Price__c = 65,
                                                      Month_Year__c = Date.today().addmonths(-1).tostartofmonth(),
                                                      State__c = 'MP');
        insert newGasPrice;
        
        test.starttest();
        RG_InsertLastMonthReimbursement insBth = new RG_InsertLastMonthReimbursement();
        database.executeBatch(insBth, 1);
        UpdateLastToLastMonthMileagesBatch lastToLast = new UpdateLastToLastMonthMileagesBatch();
        database.executeBatch(lastToLast, 1);
        test.stoptest();
        list<Contact> con = [Select id, Name, External_Email__c,(Select id,Name, Month__c from Employee_Reimbursements__r) from Contact];
        list<Employee_Mileage__c> mlist =  [select id, name from Employee_Mileage__c where EmployeeReimbursement__c In :  Emprimblist];
        list<Employee_Reimbursement__c> reimbMM = new list<Employee_Reimbursement__c>();
        for(Contact c : con) { 
            for(Employee_Reimbursement__c reimbM : c.Employee_Reimbursements__r) { 
                reimbMM.add(reimbM);
            }
        
        }
    }
}