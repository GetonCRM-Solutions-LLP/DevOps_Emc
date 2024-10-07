@isTest
public class ApproveMileageBatchTest {
    public static testmethod void GetTriptest() {          
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Mileage Rate';
        veh.Year__c = '2019';
        insert veh;
        
        TriggerConfig__c triggerCustomSetting = TestDataFactory.triggerConfigCustomSetting(true);

        SendEmailToMe__c  objSendEmailToMe = new SendEmailToMe__c();
        objSendEmailToMe.Name = 'GetTripCallOutApprovePutCall';
        objSendEmailToMe.Send_email_to_me__c = true;
        insert objSendEmailToMe;
        
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account acc = new Account();           
        acc.Name = 'Delta account';
        acc.Triplog_API__c = '123456789';
        Acc.Triplog_Status__c = 'U';
        acc.Pay_Period_Start_Date__c = system.today().adddays(-30);
        acc.Pay_Period_Days__c = 13;
        insert Acc;
        
         
        list<contact>conlist=TestDataFactory.createDriverContact(true,Acc.Id,'Driver','2019 Mileage Rate','minkesh.patel1478',1);
        
        
        Contact con = new Contact();
        con.lastname = 'Test Con';
        con.AccountId = Acc.Id;
        con.Activation_Date__c = system.today();
        con.External_Email__c = 'minkesh.patel1357@gmail.com';
        con.Email = 'minkesh.patel1357@gmail.com';
        con.Triplog_Status__c = 'U';
        con.compliancestatus__c = 'No – Vehicle Age';
        con.isCommunityUser__c = true;
        con.Reimbursement_Frequency__c='Monthly Reimbursement';
        insert con;
        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = conlist[0].Id;
        er.month__c = '09-2020';
        er.Name = contact.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
        er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        List<Bi_Weekly_Reimbursement__c> Biweek = new List<Bi_Weekly_Reimbursement__c>();
        List<Employee_Reimbursement__c> Reim = new List<Employee_Reimbursement__c>();
        
        Bi_Weekly_Reimbursement__c bob = new Bi_Weekly_Reimbursement__c();
        bob.name = '9/19/2021 to 10/2/2021';
        bob.Contact__c = con.id;
        insert bob;
        Biweek.add(bob);
        Reim.add(er);
        
        List<Employee_Mileage__c> emp =new List<Employee_Mileage__c>();
        emp=TestDataFactory.getEmpMileage(True,3,reim,biweek);
            
        String ids = '["'+er.id+'"]';
        String biids = '["'+bob.id+'"]';
        ApproveMileageBatch obj = new ApproveMileageBatch(ids,false,true);
        DataBase.executeBatch(obj);
         Test.startTest();
         ApproveMileageBatch obj1 = new ApproveMileageBatch(biids,true,true);
        DataBase.executeBatch(obj1);
        ApproveMileageBatch obj2 = new ApproveMileageBatch(biids,true,false);
        DataBase.executeBatch(obj2);       
            Test.stopTest();   
    }
}