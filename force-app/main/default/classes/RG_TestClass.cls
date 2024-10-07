/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
*
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class RG_TestClass {
    static testmethod void myUnitTest() {
        // TO DO: implement unit test
        Test.StartTest();
         TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        list<account> acclist = new  list<account>();
        for(integer i = 0; i < 10; i++) {
            acclist.add(new  account(Name = 'test' + i));
        }
        Insert acclist;
        //Contact Record Create 
        //Cover RG_CommunityUserCreateTgr class
        list<contact> conlist = new  list<contact>();
        Contact mgrInsert = new  contact(firstname='first1Name121',lastName = 'testManagerEmail011', accountid = acclist[0].id, External_Email__c = 'testManagerr11@test12.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100);
        Insert mgrInsert;
        system.debug('Manager insert print=============' + mgrInsert);
        for(integer i = 0; i < 8; i++) {
            conlist.add(new  contact(FirstName='FirstName101'+ i,lastName = 'LastTest110' + i, Manager__c = mgrInsert.id, accountid = acclist[i].id, Manager_External_Email__c = 'testManager91'+i+'@test01' + i + '.com', External_Email__c = 'test77' + i + '@test11' + i + '.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity' + i, MailingCity = 'testCity' + i, MailingState = 'testState' + i, MailingPostalCode = '110085', MailingCountry = 'TestCountry' + i, MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType' + i, Role__c = 'Driver', Monthly_Mileage_Limit__c = 100));
        }
        conlist.add(new  contact(FirstName='FirstName201',lastName = 'testManager201', accountid = acclist[0].id, External_Email__c = 'test_Managr101@test99.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100));
        conlist.add(new  contact(FirstName='FirstName301',lastName = 'testAdmin301', accountid = acclist[0].id, External_Email__c = 'test_Admin1@test089.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Admin', Monthly_Mileage_Limit__c = 100));
        Insert conlist;
        for(Contact c: conlist) {
            System.debug('Conta===' + c);
        }
        //CoverAuditTrail Trigger
        list<Contact> updatecon = new  list<Contact>();
        for(Contact c: conlist) {
            c.FirstName = 'xxxx';
            c.External_Email__c = c.Id+'@xyz.com';
            c.Fixed_Amount__c = 8000;
            c.Maintenance_and_Tires__c = 3000;
            c.Vehicle1Odometer__c = 130;
            c.Vehicle2Odometer__c = 160;
            c.MailingStreet = 'Sector-11';
            c.MailingCity = 'Delhi';
            c.MailingState = 'Delhi NCR';
            c.MailingPostalCode = '110086';
            c.MailingCountry = 'India';
            c.MPG__c = 15;
            c.compliancestatus__c = 'Yes';
            c.Vehicle_Type__c = 'TestVechleTypett';
            updatecon.add(c);
        }
        Update updatecon;
        list<Id> portaluserId = new  list<Id>();
        for(Contact c: conlist) {
            portaluserId.add(c.id);
        }
        System.debug('protalUser' + portaluserId.Size());
        list<User> u = [SELECT
            Id, 
            UserName, 
            Profile.Name, 
            ContactId,
            Contact.AccountId
        FROM
            User
        WHERE
            Contact.id in: portaluserId];
        System.debug('Ussserr' + u);
        //Employee Reimbursement Create
        list<Employee_Reimbursement__c> empReimbList = new  list<Employee_Reimbursement__c>();
        // String lastmonth = string.valueof(Date.today().addMonths(-1).month())+'-'+string.valueof(Date.today().addmonths(-1).year());
        string temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        string lastmonth = temp1.left(2);
        if(lastmonth.contains('-')) {
            lastmonth = '0' + temp1;
        } else {
            lastmonth = temp1;
        }
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'ManagerReimbursement', Contact_Id__c = conlist[8].id, Month__c = lastmonth,Status__c = 'Pending',Approved_Date__c= null));
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = conlist[0].id, Month__c = lastmonth));
        empReimbList.add(new  Employee_Reimbursement__c(Name = 'DriverReimbursement', Contact_Id__c = mgrInsert.id, Month__c = lastmonth));
        Insert empReimbList;
        //Employee Mileage Create
        list<Employee_Mileage__c> empMileage = new  list<Employee_Mileage__c>();
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-10), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToIndore', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-9), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Indore', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToHyderabad', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-8), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Hyderabad', Mileage__c = 10, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToBangalore', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-7), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Bangalore', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToPune', Contact_Email_Id__c = 'abc@abc.com', Trip_Date__c = Date.today().addDays(-6), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Pune', Mileage__c = 20, EmployeeReimbursement__c = empReimbList[0].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToBhopal', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-5), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Bhopal', Mileage__c = 50, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToGurgao', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-4), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Gurgao', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToJaipur', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-3), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Jaipur', Mileage__c = 80, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToRohtak', Contact_Email_Id__c = 'xyz@xyz.com', Trip_Date__c = Date.today().addDays(-2), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Rohtak', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[1].id));
        empMileage.add(new  Employee_Mileage__c(Name = 'DelToRohtak', Contact_Email_Id__c = 'testManagerr11@test.com', Trip_Date__c = Date.today().addDays(-2), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Rohtak', Mileage__c = 30, EmployeeReimbursement__c = empReimbList[2].id));
        Insert empMileage;
        //Gas price insert
        list<Gas_Prices__c> gaslist = new  list<Gas_Prices__c>();
        for(integer i = 0; i < 5; i++) {
            gaslist.add(new  Gas_Prices__c(City__c = 'Delhi' + i, Fuel_Price__c = 65, Month_Year__c = date.today().adddays(-i), State__c = 't' + i));
        }
        Insert gaslist;

        List<AuditTrail__c> auditTrailList = [SELECT Id,Contact__c,Field__c,NewValue__c,OldValue__c,Timestamp__c,Modifiedby__c from AuditTrail__c where Contact__c =:conlist[1].Id ORDER BY Timestamp__c DESC];
        //RG_MyTeamRecordsClass cover
        PageReference myteamRecordref = Page.RG_DashboardAdmin1;
        Test.setCurrentPage(myteamRecordref);
        Contact cc = [SELECT
            id, 
            Name, 
            Manager__c, 
            Manager__r.id, 
            External_Email__c,
            AccountId
        FROM
            Contact
        WHERE
            Role__c = 'Driver'
        LIMIT 1];
        system.debug('Contact Manager ==============' + cc);
        id managerid = cc.Manager__r.id;
        string na = cc.Name;
        myteamRecordref.getParameters().put('supid', managerid);
        system.debug('contid-testcls==============' + managerid);
        RG_MyTeamRecordsClass myteamrecord = new  RG_MyTeamRecordsClass();
        myteamrecord.cwraplist.add(new RG_MyTeamRecordsClass.ConWrapper(conlist[0].Id,empReimbList[0].Contact_Id__r.Name,empReimbList[0].Contact_Id__r.Monthly_Mileage_Limit__c,empReimbList[0].Status__c,empReimbList[0].Approved_Date__c,false,empReimbList[0].Total_Mileage__c,empReimbList[0].Total_Approved__c,empReimbList[0]));
        myteamrecord.cwraplist[0].conb = true;
        myteamrecord.pageredirect();
        myteamrecord.UpdateRecord();
        // System.runAs(u[0]){ 
        //RG_MonthlyReimbursementSummary
        PageReference monthlyReimbursementSummaryref = Page.RG_MonthlyReimbursementSummary;
        Test.setCurrentPage(monthlyReimbursementSummaryref);
        monthlyReimbursementSummaryref.getParameters().put('id', conlist[0].id);
        monthlyReimbursementSummaryref.getParameters().put('man', conlist[0].id);
        monthlyReimbursementSummaryref.getParameters().put('dr', conlist[0].id);
        RG_MyMonthlyReimbursment myMonthlyReimb = new  RG_MyMonthlyReimbursment();
        myMonthlyReimb.imDriver = true;
        myMonthlyReimb.imMan = true;
        myMonthlyReimb.imManDr = true;
        myMonthlyReimb.isManagerDriver = true;
        myMonthlyReimb.isSuperManagerDriver = true;

        myMonthlyReimb.updateByMonth();
        myMonthlyReimb.closePopup();
        myMonthlyReimb.showPopup();
        myMonthlyReimb.savePDF();
        myMonthlyReimb.backMethod();
        myMonthlyReimb.sendConfirmationEmail();
        //RG_Charting cover
        //RG_Charting class Cover
        PageReference pagerefCharting = Page.Rg_Charting;
        Test.setCurrentPage(pagerefCharting);
        System.debug('mgrInsert:'+mgrInsert);
        pagerefCharting.getParameters().put('id', mgrInsert.Id);
        pagerefCharting.getParameters().put('un', 'ap');
        RG_Charting charting = new  RG_Charting();
        //RG_Charting_ContactsRecords cover
        PageReference pagerefChartingRecord = Page.RG_Charting_MyRecords;
        Test.setCurrentPage(pagerefChartingRecord);
        pagerefChartingRecord.getParameters().put('id', conlist[0].id);
        RG_Charting_ContactsRecords chartingContactRecord = new  RG_Charting_ContactsRecords(new  ApexPages.StandardController(conlist[0]));
        //RG_CommunityCustomLoginController cover
        PageReference CommunitiesLoginref = Page.RG_Login;
        Test.setCurrentPage(CommunitiesLoginref);
        RG_CommunityCustomLoginController commLogin = new  RG_CommunityCustomLoginController();
        commLogin.login();
        commLogin.login();
        commLogin.login();
        /*    //RG_MyTeamRecordsClass cover
        PageReference myteamRecordref2=Page.RG_DashboardAdmin1;
        Test.setCurrentPage(myteamRecordref2);
        
        Contact cc2=[Select id, Name,Manager__c,Manager__r.id, External_Email__c from Contact where Role__c='Driver' LIMIT 1];
        system.debug('Contact Manager =============='+cc2);
        id managerid2=cc2.Manager__c;
        string na2=cc2.Name;
        
        myteamRecordref.getParameters().put('supid',managerid2);
        system.debug('contid-testcls=============='+managerid2);
        
        Contact cccc = [select id,lastName,Role__c,manager__r.Name,Monthly_Mileage_Limit__c,Account.name,(select id,Status__c,Month__c, name from Employee_Reimbursements__r ) from Contact where manager__c=:managerid2 and Name=:na2 limit 1];
        System.debug('Contactttttttttttttt================'+cccc);
        RG_MyTeamRecordsClass myteamrecord2=new RG_MyTeamRecordsClass();
        myteamrecord2.pageredirect();
        myteamrecord2.UpdateRecord();
        //   RG_MyTeamRecordsClass myteamrecordStd=new RG_MyTeamRecordsClass(new ApexPages.StandardController(conlist[0]));
        // myteamrecordStd.updateMileage();
        */
        //RG_UnApprovedRecordsByNameClass cover
        PageReference pagerefunapprovedRecordByname = Page.RG_UnApprovedRecordsByName;
        Test.setCurrentPage(pagerefunapprovedRecordByname);
        pagerefunapprovedRecordByname.getParameters().put('p', conlist[0].id);
        RG_UnApprovedRecordsByNameClass unapprovedRecord = new  RG_UnApprovedRecordsByNameClass();
        unapprovedRecord.wraplist.add(new RG_UnApprovedRecordsByNameClass.RembWrap(empReimbList[0],empMileage,gaslist,auditTrailList));
        unapprovedRecord.wraplist[0].isSelected = true;
        /*integer i = 0;
        for(RG_UnApprovedRecordsByNameClass.RembWrap m: unapprovedRecord.wraplist) {
            //m.b = true;
            //m.isSelected= true;
            for(RG_UnApprovedRecordsByNameClass.MileWrap rr: m.mlist) {
                //rr.boo = true;
                //rr.isApproved = true;
                i++;
                if(i == 1) {
                    break;
                }
            }
        }*/
        unapprovedRecord.updateByMonth();
        //RG_Charting_MyRecordsClass
        PageReference pagerefChartingref = Page.RG_Charting_MyRecords;
        Test.setCurrentPage(pagerefChartingref);
        pagerefChartingref.getParameters().put('id', conlist[0].id);
        RG_Charting_MyRecordsClass rgchartmyRecordcls = new  RG_Charting_MyRecordsClass();
        //RG_UnApprovedRecordsClass
        PageReference UnApprovedRecords = Page.RG_UnApprovedRecords;
        Test.setCurrentPage(UnApprovedRecords);
        RG_UnApprovedRecordsClass unapprovedRecordcls = new  RG_UnApprovedRecordsClass();
        for(RG_UnApprovedRecordsClass.RembWrap r: unapprovedRecordcls.wraplist) {
            r.b = true;
            r.isCheck = true;
        }
        unapprovedRecordcls.UpdateRecord();
        unapprovedRecordcls.sendEmail();
        //}
        Test.StopTest();
    }
    public static testmethod void unitTest2() {
     TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
    
        account a = new  account(name = 'testAcount');
        Insert a;
        Contact manager = new  Contact();
        manager.AccountId = a.Id;
        manager.LastName = 'Test';
        manager.External_Email__c = 'manageremail@test.com';
        Insert manager;

        Contact newDriver = new  Contact();
        newDriver.AccountId = a.Id;
        newDriver.LastName = 'Test';
        newDriver.Role__c = 'Driver';
        newDriver.External_Email__c = 'driveremail@test.com';
        Insert newDriver;

        newDriver.Role__c = 'Manager';
        update newDriver;
        
        Contact mgrInsert = new  contact(FirstName = 'test', lastName = 'testManagerEmail', accountid = a.id, External_Email__c = 'testManagerr111@test.com', Fixed_Amount__c = 5000, Maintenance_and_Tires__c = 2000, Vehicle1Odometer__c = 120, Vehicle2Odometer__c = 150, MailingStreet = 'testMailingCity', MailingCity = 'testCity', MailingState = 'testState', MailingPostalCode = '110085', MailingCountry = 'TestCountry', MPG__c = 12, compliancestatus__c = 'Yes', Vehicle_Type__c = 'TestVechleType', Role__c = 'Manager', Monthly_Mileage_Limit__c = 100, Manager__c = manager.Id);
        Insert mgrInsert;
        
        Contact roleContact = new Contact();
        roleContact.AccountId = a.Id;
        roleContact.LastName = 'Test';
        roleContact.Role__c = 'Driver';
        roleContact.Manager__c = mgrInsert.Id;
        roleContact.External_Email__c = 'driverTesr@test.com';
        Insert roleContact;

        List<User> mockUsers = [SELECT
            Id
        FROM
            User
        WHERE
            ContactId = : mgrInsert.Id
        LIMIT 1];
        System.runAs(mockUsers[0]) {
            string lastmonth = string.valueof(Date.today().addMonths(-1).month()) + '-' + string.valueof(Date.today().addmonths(-1).year());
            Employee_Reimbursement__c reim = new  Employee_Reimbursement__c(Name = 'ManagerReimbursement', Contact_Id__c = roleContact.id, Month__c = lastmonth, Approved_Date__c = null);
            Insert reim;
            Employee_Mileage__c mileage1 = new  Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'testManagerr111@test.com', Trip_Date__c = Date.today().addMonths(-1), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = reim.id, Approved_Date__c = null, Rejected__c = false);
            Employee_Mileage__c mileage2 = new  Employee_Mileage__c(Name = 'DelToMumbai', Contact_Email_Id__c = 'testManagerr111@test.com', Trip_Date__c = Date.today().addMonths(-1), Trip_Origin__c = 'Delhi', Trip_Destination__c = 'Mumbai', Mileage__c = 20, EmployeeReimbursement__c = reim.id, Approved_Date__c = null, Rejected__c = false);
            list<Employee_Mileage__c> milelist = new  list<Employee_Mileage__c>();
            milelist.add(mileage1);
            milelist.add(mileage2);
            Insert milelist;
            Gas_Prices__c gas = new  Gas_Prices__c(City__c = 'Delhi', Fuel_Price__c = 65, Month_Year__c = date.today().addMonths(1), State__c = 'NY');
            Insert gas;
            list<Gas_Prices__c> gasprice = new  list<Gas_Prices__c>();
            gasprice.add(gas);

            //RG_MyTeamRecordsClass cover
            PageReference myteamRecordref = Page.RG_DashboardAdmin1;
            Test.setCurrentPage(myteamRecordref);

            myteamRecordref.getParameters().put('supid', mgrInsert.Id);
            system.debug('contid-testcls==============' + mgrInsert.Id);
            RG_MyTeamRecordsClass myteamrecord = new  RG_MyTeamRecordsClass();
            myteamrecord.clist.clear();
            //myteamrecord.cwraplist.add(new RG_MyTeamRecordsClass.ConWrapper(conlist[0].Id,empReimbList[0].Contact_Id__r.Name,empReimbList[0].Contact_Id__r.Monthly_Mileage_Limit__c,empReimbList[0].Status__c,empReimbList[0].Approved_Date__c,false,empReimbList[0].Total_Mileage__c,empReimbList[0].Total_Approved__c,empReimbList[0]));
            //myteamrecord.cwraplist[0].conb = true;
            myteamrecord.pageredirect();
            myteamrecord.backMethod();
            myteamrecord.UpdateRecord();

            PageReference monthlyReimbursementSummaryref = Page.RG_MonthlyReimbursementSummary;
            Test.setCurrentPage(monthlyReimbursementSummaryref);
            monthlyReimbursementSummaryref.getParameters().put('id', mgrInsert.id);
            RG_MyMonthlyReimbursment myMonthlyReimb = new  RG_MyMonthlyReimbursment();
            myMonthlyReimb.wlist.add(new  RG_MyMonthlyReimbursment.ReimbursementWrapper(reim, 'December', '2017', milelist, false, mgrInsert, gasprice));
            myMonthlyReimb.wlist.add(new  RG_MyMonthlyReimbursment.ReimbursementWrapper(reim, 'February', '2018', milelist, false, mgrInsert, gasprice));
            if(myMonthlyReimb.wlist.size()>0) {
                myMonthlyReimb.wlist[0].isSelected = true;
                myMonthlyReimb.wlist[1].isSelected = false;
                myMonthlyReimb.wlist[1].milageWrapperList[0].isRejected = true;
                myMonthlyReimb.wlist[1].milageWrapperList[1].isApproved = true;
                myMonthlyReimb.updateByMonth();
                for(RG_UnApprovedRecordsClass.RembWrap r: new  RG_UnApprovedRecordsClass().wraplist) {
                    r.b = true;
                    r.isCheck = true;
                }
            }
            RG_UnApprovedRecordsClass unapprovedRecordcls = new  RG_UnApprovedRecordsClass();
            unapprovedRecordcls.UpdateRecord();
            RG_UnApprovedRecordsClass.RembWrap rWrap = new  RG_UnApprovedRecordsClass.RembWrap(new List<Employee_Reimbursement__c>{reim}, true, true, gasprice);
            unapprovedRecordcls.wraplist.add(rWrap);
            for(RG_UnApprovedRecordsClass.RembWrap r: unapprovedRecordcls.wraplist) {
                r.b = true;
                r.isCheck = true;
            }
            unapprovedRecordcls.sendEmail();
        }
    }
}