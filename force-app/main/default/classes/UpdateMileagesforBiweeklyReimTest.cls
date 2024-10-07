@isTest
public class UpdateMileagesforBiweeklyReimTest {
    
    @isTest
    public static void TestMethod1(){
        
        TriggerConfig__c customEmailSetting =  new TriggerConfig__c();
        customEmailSetting.Name = 'Defaulttrigger';
        customEmailSetting.ContactTriggersendEmailForNewContact__c = true;
        customEmailSetting.ContactTriCommunityReimCreate__c = true;
        insert customEmailSetting;
        
     //   List<IRS_Mileage_Rate__c> obj_IRS_Mileage_Rate =  RecordUtilityClass.insertIrsRate();
         
        Address__c obj_Address = new Address__c();
        obj_Address.State__c ='Alabama';
        obj_Address.City__c ='Abbeville';
        obj_Address.Abbreviation__c ='AL';
        obj_Address.ZIP_Code__c ='36310'; 
        obj_Address.Time_Zone__c = 'America/Anchorage';
        List<Address__c> obj_list_Address = new List<Address__c>();
        obj_list_Address.add(obj_Address);
        insert obj_list_Address;
        
        Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
        veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh.vehicle__c = 'Full-Size Sedan';
        veh.Year__c = '2019';
        insert veh;
        
        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        SendEmail__c customSetting =  new SendEmail__c();
        customSetting.Name = 'Send Email For Compliance';
        customSetting.Send_email_from_code__c= true;
        insert customSetting;
        
        //Insert Account data Using Utility class
       
        Account  acc = new Account();
        acc.name = 'test account';
            acc.Triplog_API__c = 'fde76cdde14449bea46b321225ac8fd1';
            acc.Pay_Period_Start_Date__c = System.today().addDays(-100);
            acc.Pay_Period_Days__c = 13;
            Insert acc;
            
           contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.AccountId = acc.Id;
            con.Fixed_Amount__c = 10;
            con.MailingStreet = 'Test Street';
            con.MailingCity = 'Test City';
            con.MailingState = 'AL';
            con.Triplog_UserID__c = '23rcdssf';
            con.MailingPostalCode = '36310';
           // con.Manager__c = con2.Id;
            con.MailingCountry = 'CA';
            con.Phone = '1232434445';
            con.External_Email__c = 'minkesh.patel14232378@gmail.com';
            con.isCommunityUser__c = True;
            con.Role__c = 'Driver';
            con.Monthly_Mileage_Limit__c = 0;
            con.IsCreatedFromCommunity__c = true; 
            con.Vehicle_Type__c  = '2019 Full-Size Sedan';
            con.compliancestatus__c = 'Yes';
            con.Time_Zone__c = 'US/Eastern';
            insert con;
   
        Decimal days = acc.Pay_Period_Days__c;
        List<String> dateRange = new List<String>();
        String startDate = string.valueof(acc.Pay_Period_Start_Date__c);
        string[] splitsdate = startDate.split('-');
        string splitStartDate = splitsdate[1]+'/'+splitsdate[2]+'/'+splitsdate[0];
        String enddate = String.valueof(date.valueof(startDate).addDays(Integer.valueof(days)));
        string[] splitdate = enddate.split('-');
        string splitEndDate = splitdate[1]+'/'+splitdate[2]+'/'+splitdate[0];
        if(date.valueof(enddate) < date.today()){
            dateRange.add(splitStartDate+' to '+ splitEndDate);
        }        
        
        Bi_Weekly_Reimbursement__c biReim = new Bi_Weekly_Reimbursement__c();
        bireim.Approved_Date__c = system.today().addDays(-1);
        bireim.Status__c = 'Pending';
        bireim.Name = dateRange[0];
        bireim.Start_Date__c = Date.parse('10/03/2021');
        bireim.End_Date__c = Date.parse('10/16/2021');
        bireim.Contact__c = con.id;
        insert bireim;

        
        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        er.Name = '11/21/2021 to 12/04/2021';
        er.Month__c = '03-2021';
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 10.00; 
        er.Fixed_Amount__c = con.Fixed_Amount__c;
        er.Status__c = 'Pending';
        er.Maintenance_and_Tires__c = con.Maintenance_and_Tires__c;
        er.MPG__c = con.MPG__c;
        insert er;

        Employee_Mileage__c emp = new Employee_Mileage__c();
        emp.Bi_Weekly_Reimbursement__c = bireim.Id;
        emp.EmployeeReimbursement__c = er.id;
        emp.Contact_Email_Id__c = con.External_Email__c;
        emp.Name = 'Test Mileage Record';
        emp.Trip_Status__c = StaticValues.noApprovedYet;
        emp.Mileage__c = 10.00;
        emp.Fuel_price__c = 10.00;
        emp.TimeZone__c = 'US/Mountain' ;
        emp.StartTime__c = system.now();
        emp.EndTime__c =  system.now();
        emp.Trip_Date__c = date.today().adddays(-1);
        emp.Approved_Date__c = null;
        emp.Maintenance_and_Tires__c = 1.2;
        emp.Origin_Name__c = 'test';
        emp.Notes__c = 'test';
        emp.Tag__c = 'test';        
        emp.Destination_Name__c = 'test';        
 //       emp1.Mileage_Lock_Date__c = system.today();
        insert emp;
        
        Test.startTest();
        
                UpdateMileagesforBiweeklyReim sendBatch = new UpdateMileagesforBiweeklyReim();       
        database.executebatch(sendBatch);
        Test.stopTest();
  
    }
}