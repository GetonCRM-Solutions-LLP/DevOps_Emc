@istest
public class scheduledIntMntBatchTest {
    public static testMethod void scheduledIntMntBatchTestMethod() {
    
        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
    
        Account acc=new Account(Name='TestAcc'); 
        insert acc;
        system.debug('@@acc-->'+acc);
        list<Contact> newContactList=new list<Contact>();
        Contact mgrInsert=new contact(lastName='testManagerEmail',accountid=acc.id,External_Email__c='testManagerr11@test.com',Fixed_Amount__c=5000,Maintenance_and_Tires__c=2000,Vehicle1Odometer__c=120,Vehicle2Odometer__c=150,MailingStreet='testMailingCity',MailingCity='testCity',MailingState='testState',MailingPostalCode='110085',MailingCountry='TestCountry',MPG__c=12,compliancestatus__c='Yes',Vehicle_Type__c='TestVechleType',Role__c='admin',Monthly_Mileage_Limit__c=100);
        insert mgrInsert;
        newContactList.add(new Contact(LastName='Nitesh Test', Accountid=acc.Id, Manager__c = mgrInsert.Id, External_Email__c='nitesh@test.com',Monthly_Mileage_Limit__c=200,MailingCity='Bhopal',MailingState='MP'));
        for(integer i=1;i<=10;i++){
            newContactList.add(new Contact(lastName='test'+i,accountid=acc.id,Manager__c=mgrInsert.id,Manager_External_Email__c='testManagerr11@test.com',External_Email__c='test'+i+'@test.com',Fixed_Amount__c=5000,Maintenance_and_Tires__c=2000,Vehicle1Odometer__c=120,Vehicle2Odometer__c=150,MailingStreet='testMailingCity'+i,MailingCity='testCity'+i,MailingState='testState'+i,MailingPostalCode='110085',MailingCountry='TestCountry'+i,MPG__c=12,compliancestatus__c='Yes',Vehicle_Type__c='TestVechleType'+i,Role__c='Manager',Monthly_Mileage_Limit__c=100));
        }
        insert newContactList;
        
        System.debug('@@ContactSize-->'+newContactList.size());
        //Reimbursement
        String temp1 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        string lastmonth= temp1.left(2);
        if(lastmonth.contains('-'))
            lastmonth='0'+temp1;
        else  
            lastmonth=temp1;
        list<Employee_Reimbursement__c> Emprimblist = new list<Employee_Reimbursement__c>();
        Employee_Reimbursement__c Emprimb=new Employee_Reimbursement__c(Name='rimbTest1',contact_id__c= newContactList[0].id, Month__c=lastmonth);
        Employee_Reimbursement__c Emprimb2=new Employee_Reimbursement__c(Name='rimbTest2',contact_id__c= newContactList[1].id, Month__c=lastmonth);
        Employee_Reimbursement__c Emprimb3=new Employee_Reimbursement__c(Name='rimbTest2',contact_id__c= newContactList[0].id, Month__c=lastmonth);
        Employee_Reimbursement__c Emprimb4=new Employee_Reimbursement__c(Name='rimbTest2',contact_id__c= newContactList[1].id, Month__c=lastmonth);
        Emprimblist.add(Emprimb);
        Emprimblist.add(Emprimb2);
        Emprimblist.add(Emprimb3);
        Emprimblist.add(Emprimb4);
        insert Emprimblist;
        //system.debug([select id,name from Employee_Reimbursement__c]);       
        list<Employee_Mileage__c> empMileage=new list<Employee_Mileage__c>();
        for(integer i=1;i<=5;i++){
            empMileage.add(new Employee_Mileage__c(Name='empMil1'+i,Mileage__c=300,Contact_Email_Id__c='testManagerr11@test.com',Trip_Date__c=date.today(),EmployeeReimbursement__c=Emprimblist[0].id));
            empMileage.add(new Employee_Mileage__c(Name='empMil2'+i,Mileage__c=2,Contact_Email_Id__c='testManagerr11@test.com',Trip_Date__c=date.today(),EmployeeReimbursement__c=Emprimblist[1].id));
            empMileage.add(new Employee_Mileage__c(Name='empMil3'+i,Mileage__c=2,Contact_Email_Id__c='testtest1@testtest1.com',Trip_Date__c=date.today(),EmployeeReimbursement__c=Emprimblist[2].id));
            empMileage.add(new Employee_Mileage__c(Name='empMil4'+i,Mileage__c=2,Contact_Email_Id__c='testtest2@testtest2.com',Trip_Date__c=date.today(),EmployeeReimbursement__c=Emprimblist[3].id));
        }
        insert empMileage;
        
        for(Employee_Mileage__c m:empMileage){
            if(m.name.contains('empMil1'))
                m.EmployeeReimbursement__c=Emprimb.id;
            if(m.name.contains('empMil2'))
                m.EmployeeReimbursement__c=Emprimb2.id;
            if(m.name.contains('empMil3'))
                m.EmployeeReimbursement__c=Emprimb3.id;
            if(m.name.contains('empMil4'))
                m.EmployeeReimbursement__c=Emprimb4.id;
            
            
        }
        update empMileage;
        
        
        
        Gas_Prices__c newGasPrice=new Gas_Prices__c(City__c='Bhopal',Fuel_Price__c=65,Month_Year__c=Date.today().addmonths(-1).tostartofmonth(),State__c='MP');
        insert newGasPrice;
        Test.startTest();
        scheduledIntMntBatch schBt = new scheduledIntMntBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test schedule',sch,schBt);
        Test.stopTest();
    }
}