/*
Author-Arpit Jain
Created Date-04/11/2016
Test Class for Controller ReportPageClass.
*/
@istest
public class ReportPageClass_Test 
{
    public static testmethod void main()
    {  
          

    
        //Account Create
        Account acc = new Account(Name='Test');
        insert acc;
        //Contact Create
        Contact con=new contact(accountid=acc.id,FirstName='Test',LastName='Class',Email='testclass@valetwaste.com',Phone='012362516',Business_Unit__c='A',External_Email__c='abc@gmail.com');
        insert con;
        //User Create
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Manager'];
      

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8',FirstName='Test', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId=p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Testingapexclass@gmail.com',Contactid=con.id);
    
        insert u;
     
        //Custom_Report Create
        Custom_Report__c cr=new custom_Report__c(Name='Test',Report_Soql__c='select Contact_Id__r.Employee_ID__c, Contact_Id__r.Name,Approved_Date__c,Total_Mileage__c,Variable_Rate__c from Employee_Reimbursement__c');
        insert cr; 
         
        PageReference pref = Page.ReportPage;
        pref.getParameters().put('id', cr.id);
        Test.setCurrentPage(pref);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cr);
        
        ReportPageClass rpc=new ReportPageClass(); 
        rpc.selectedbv.add('A');
        rpc.fromdate=date.today();
        rpc.getManagerNames(); 
        rpc.getBusinessunit();
        rpc.run();
        rpc.home();
        rpc.SaveAspdf();
        rpc.SaveAsExcel();
        rpc.back();
        rpc.updateAccount();
     
    }
    
        public static testmethod void main1()
    {
           User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
 
     System.runAs ( thisUser ) {
           

     
        //Account Create
        Account acc= new Account(Name='Test Account');
        insert acc;
        //Contact Create
        Contact con=new contact(accountid=acc.id,FirstName='Test',LastName='Class',Email='testclass@valetwaste.com',Phone='012362516',Business_Unit__c='A',External_Email__c='abc@gmail.com');
        insert con;
        //User Create
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User - Manager'];
      
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8',FirstName='Test', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId=p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Testingapexclass@gmail.com',Contactid=con.id);
        
      insert u;
     
        //Custom_Report Create
        Custom_Report__c cr=new custom_Report__c(Name='Test',Report_Soql__c='select Employee_ID__c,Name,Email,Activation_Date__c,Fixed_Amount__c,Manager__r.Name from contact');
        insert cr;
         
        PageReference pref = Page.ReportPage;
        pref.getParameters().put('id', cr.id);
        Test.setCurrentPage(pref);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cr);
        
        ReportPageClass rpc=new ReportPageClass(); 
        rpc.selectedbv.add('A');
        rpc.fromdate=date.today();
        rpc.getManagerNames(); 
        rpc.getBusinessunit();
        rpc.run();
     }
   }
}