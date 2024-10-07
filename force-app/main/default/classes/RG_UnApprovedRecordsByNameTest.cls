@isTest
public class RG_UnApprovedRecordsByNameTest{
    public static testmethod void test1(){

        TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;

       
        SendEmail__c customSetting1 =  new SendEmail__c();
        customSetting1.Name = 'Send Email For Compliance';
        customSetting1.Send_email_from_code__c= true;
        insert customSetting1;

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'test1';
        con.AccountId = acc.Id;
        con.External_Email__c = 'test@testing.com';
        con.Enable_Reports__c = true;
        insert con;

        User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User - Super Manager/Driver'].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         //UserRoleId = r.Id,
         ContactId= con.Id
            );

        Employee_Reimbursement__c er = new Employee_Reimbursement__c();
        er.Contact_Id__c = con.Id;
        
        er.month__c = getLastMonthValue(-1);
        er.Name = con.lastname+':'+er.month__c;
        er.Status__c = 'Pending';
        er.Fuel_Price__c = 1;  //String.valueof(er.Fuel_Price__c); // 
        er.MPG__c = 10.00;
        er.Maintenance_and_Tires__c = 24;//String.valueof(er.Maintenance_and_Tires__c);
      //  er.Fuel_Price__c = 1;
        er.MPG__c = 10;
        er.Maintenance_and_Tires__c = 10;
        er.Fixed_Amount__c = 10.10;
        er.Triplog_Status__c = 'U';
        insert er;
        
        
        Employee_Mileage__c emp1 = new Employee_Mileage__c();
        emp1.Contact_Email_Id__c = 'test_Managr101@test99.com';
        emp1.Name = 'Test Mileage Record';
        emp1.EmployeeReimbursement__c = er.id;
       // emp1.Approved_Date__c = system.today();
        insert emp1;

        List<Employee_Reimbursement__c> emplist = new List<Employee_Reimbursement__c>();
        
        Employee_Reimbursement__c emp = new Employee_Reimbursement__c();
        emp.Approved_Date__c = null;
        emp.Name = 'test';
        emp.Status__c = 'Approved';
        emp.Contact_Id__c = con.Id;
        emplist.add(emp);
        insert emplist;


        Employee_Reimbursement__c emp2 = new Employee_Reimbursement__c();
        emp2.Contact_Id__c = con.Id;
        emp2.Name = 'test';
        insert emp2;


        Employee_Reimbursement__c    empre = new Employee_Reimbursement__c();
        empre.Name = 'test';
        empre.Contact_Id__c = con.Id;
        insert empre;

        List<Employee_Mileage__c> listemp2 = new List<Employee_Mileage__c>();
        Employee_Mileage__c emp3 = new Employee_Mileage__c();
        emp3.Name = 'test';     
        emp3.EmployeeReimbursement__c = emp.Id;
        emp3.Trip_Status__c = 'Approved';
        emp3.Approved_Date__c = Date.today();
        emp3.Rejected__c = false;
        emp3.Contact_Email_Id__c = 'test@gmail.com';
        emp3.Carry_Forward_Mileage__c = true;
        //emp3.Approved_Date__c = system.today();
        listemp2.add(emp3);
        insert listemp2;


        List<Employee_Mileage__c> listempdata = new List<Employee_Mileage__c>();
        Employee_Mileage__c empdata = new Employee_Mileage__c();
        empdata.Name = 'test';
        empdata.EmployeeReimbursement__c = empre.Id;
        empdata.Contact_Email_Id__c = 'test@gmail.com';
        empdata.Approved_Date__c = null;
        empdata.Rejected__c = true;

        listempdata.add(empdata);
        insert listempdata;


        list<Gas_Prices__c> listgas = new list<Gas_Prices__c>();
        Gas_Prices__c gas = new Gas_Prices__c();
        gas.Month_Year__c = system.today();
        listgas.add(gas);
        insert listgas;


        List<AuditTrail__c> listaud = new List<AuditTrail__c>();
        AuditTrail__c aud = new AuditTrail__c();
        aud.Contact__c = con.Id;
        aud.NewValue__c = 'test';
        listaud.add(aud);
        insert listaud;

        ApexPages.currentPage().getParameters().put('p',con.Id);
        RG_UnApprovedRecordsByNameClass unapp = new RG_UnApprovedRecordsByNameClass();
        PageReference pageRef = Page.RG_UnApprovedRecordsByName;
        Test.setCurrentPage(pageRef);

        
        unapp.isSuperManager = true;
        unapp.isSuperManagerDriver = true;
        unapp.EnableReports = true;
        unapp.conid = con.Id;
        unapp.updateByMonth();
        //unapp.getMileages(true,listempdata,true);
        //unapp.getunSelectedmileages(listempdata);
        RG_UnApprovedRecordsByNameClass.RembWrap rem = new RG_UnApprovedRecordsByNameClass.RembWrap(emp2,listemp2,listgas,listaud);
        rem.Variable = 10;
        rem.isSelected = true;
        rem.isEditable = true;

        list<RG_UnApprovedRecordsByNameClass.MileWrap> milageData = new list<RG_UnApprovedRecordsByNameClass.MileWrap>();
        RG_UnApprovedRecordsByNameClass.MileWrap mile = new RG_UnApprovedRecordsByNameClass.MileWrap(empdata,listaud,listgas);
        mile.VariableReimbursement2 = 10;
        mile.Variable = 9;
        mile.mainttire = 8;
        mile.isRejected = true;
        milageData.add(mile);
        unapp.getunSelectedmileages(milageData);
        
    }

    public static String getLastMonthValue(Integer value) {
        String tempDate = date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
        String lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }
        return lastMonth;
    }

    
}