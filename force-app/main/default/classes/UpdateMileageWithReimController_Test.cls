@isTest
public class UpdateMileageWithReimController_Test
{
    public static testMethod Void UpdateMileageWithReimController_TestMethod1() 
    {
         TriggerConfig__c customSetting =  new TriggerConfig__c();
        customSetting.Name = 'Defaulttrigger';
        customSetting.MappingGasPriceTrigger__c = true;
        insert customSetting;
        Account account = new Account();
        account.name = 'Test Account';
        insert account;
           
        Contact contact = new Contact();
        contact.lastname = 'Test Contact';
        contact.AccountId = account.Id;
        contact.External_Email__c = 'test@test.com';
        contact.Fixed_Amount__c = 0.0;
        contact.MailingState = 'CA';
        contact.MailingCity = 'Canyon';
        insert contact;
        
        Employee_Reimbursement__c erRec = new Employee_Reimbursement__c();
        erRec.Contact_Id__c = contact.Id;
        erRec.month__c = '01-2018';
        erRec.Name = contact.lastname+':'+erRec.month__c;
        erRec.Status__c = 'Pending';
        erRec.Fuel_Price__c = 2.22;
        erRec.Approved_Date__c = system.today() - 3;
        erRec.Fixed_Amount__c = 10.10;
        insert erRec;
        
        Employee_Mileage__c empMileageRec = new Employee_Mileage__c();
        empMileageRec.Contact_Email_Id__c = 'test1@test1.gmail.com';
        empMileageRec.Name = 'Test Mileage Record';
        empMileageRec.EmployeeReimbursement__c = erRec.id;
        empMileageRec.Fuel_price__c = erRec.Fuel_Price__c;
        empMileageRec.Trip_Status__c = 'Approved';
        empMileageRec.Approved_Date__c = system.today() - 1;
        insert empMileageRec;
        
        UpdateMileageWithReimController.WrapperMainTable obj_WrapperMainTable = new UpdateMileageWithReimController.WrapperMainTable(empMileageRec,'black',false);
        
        PageReference pageRef = Page.UpdateMileageWithReim;
        Test.setCurrentPage(pageRef);
        
        UpdateMileageWithReimController.SearchCriteriaRow obj_SearchCriteriaRow = new UpdateMileageWithReimController.SearchCriteriaRow(1,'Fuel_price__c','=','2','Double','Double');
        
        UpdateMileageWithReimController.SearchCriteriaRow obj_SearchCriteriaRow1 = new UpdateMileageWithReimController.SearchCriteriaRow(1,'Approved_Date__c','=','1/1/2018','Date','Date');
        UpdateMileageWithReimController.SearchCriteriaRow obj_SearchCriteriaRow2 = new UpdateMileageWithReimController.SearchCriteriaRow(1,'Contact_Email_Id__c','=','abc','EMAIL','EMAIL'); 
         
        UpdateMileageWithReimController obj_UpdateMileageWithReimController = new UpdateMileageWithReimController();
        obj_UpdateMileageWithReimController.advcriteriaRows.add(obj_SearchCriteriaRow);
        obj_UpdateMileageWithReimController.advcriteriaRows.add(obj_SearchCriteriaRow1);
        obj_UpdateMileageWithReimController.advcriteriaRows.add(obj_SearchCriteriaRow2);
        obj_UpdateMileageWithReimController.filterCriteria='1 AND 2 AND 3';
        obj_UpdateMileageWithReimController.buildQueryforSearch();
        obj_UpdateMileageWithReimController.getMonth();
        obj_UpdateMileageWithReimController.next();
        obj_UpdateMileageWithReimController.previous();
        obj_UpdateMileageWithReimController.getripstatus();
        obj_UpdateMileageWithReimController.getFieldType('Approved_Date__c');
        obj_UpdateMileageWithReimController.getFieldType('Contact_Email_Id__c');
        obj_UpdateMileageWithReimController.getFieldType('EmployeeReimbursement__c');
        obj_UpdateMileageWithReimController.getFieldType('Mileage__c');
        obj_UpdateMileageWithReimController.getFieldType('Fuel_price__c');
        obj_UpdateMileageWithReimController.getFieldType('Maintenance_and_Tires__c');
        obj_UpdateMileageWithReimController.getFieldType('MPG__c');
        obj_UpdateMileageWithReimController.getFieldType('Trip_Date__c');
        obj_UpdateMileageWithReimController.getFieldType('Trip_Status__c');
       // obj_UpdateMileageWithReimController.getFieldType('Month__c');
        obj_UpdateMileageWithReimController.getFieldType('Trip_Date_Month__c');
        obj_UpdateMileageWithReimController.addAdvCriteriaRow();
        
        Apexpages.currentpage().getparameters().put('rowNum','1');
        
        obj_UpdateMileageWithReimController.removeAdvCriteriaRow();
        Apexpages.currentpage().getparameters().put('fieldName','Fuel_price__c');
        Apexpages.currentpage().getparameters().put('idx','1');
        obj_UpdateMileageWithReimController.findFieldType();
        Apexpages.currentpage().getparameters().put('fieldName','Approved_Date__c');
        Apexpages.currentpage().getparameters().put('idx','2');
        obj_UpdateMileageWithReimController.findFieldType();
        obj_UpdateMileageWithReimController.selectedMonth='06-2018';
        obj_UpdateMileageWithReimController.maintableDataList[0].IsPRSelected = true;
        obj_UpdateMileageWithReimController.updateMileage();
        obj_UpdateMileageWithReimController.refresh();
        obj_UpdateMileageWithReimController.ClearAll();
        Apexpages.currentpage().getparameters().put('clickedRowAPIname','Fuel_price__c');
        
        obj_UpdateMileageWithReimController.SortToggle();
        UpdateMileageWithReimController.BuildWhere('','');
        UpdateMileageWithReimController.BuildWhere('abc','');
        
    }
}