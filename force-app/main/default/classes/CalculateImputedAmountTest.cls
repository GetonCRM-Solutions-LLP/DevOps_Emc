@isTest
public with sharing class CalculateImputedAmountTest {
    public static testmethod void CalimputedIncomeMethod1(){
        RecordUtilityClass.createRecordsAdminDashboardController();
        Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation        
        currentAccount.Tax_Calculation_Year__c = string.valueOf(System.Today().year());        
        update currentAccount;

        Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
        Contact selectedDriver = RecordUtilityClass.getDriverContact();
        selectedDriver.Deactivated_Date__c = DateTime.Now().AddDays(1);
        update selectedDriver;
        List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);

        PageReference pageRef = Page.calculateimputedincome;	
		
		pageRef.getParameters().put('Id',String.valueOf(currentAccount.Id)); 
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.standardController(currentAccount);		
		CalculateImputedAmount calImpAmount = new CalculateImputedAmount(sc);
        calImpAmount.backMethod();
        calImpAmount.contAnnualTaxUpadte();
    }

    public static testmethod void CalimputedIncomeMethod2(){
        RecordUtilityClass.createRecordsAdminDashboardController();
        Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
        currentAccount.Tax_Calculation_Year__c = 'Eighteen';        
        update currentAccount;

        Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
        Contact selectedDriver = RecordUtilityClass.getDriverContact();
        List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);

        PageReference pageRef = Page.calculateimputedincome;	
		
		pageRef.getParameters().put('Id',String.valueOf(currentAccount.Id)); 
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.standardController(currentAccount);		
		CalculateImputedAmount calImpAmount = new CalculateImputedAmount(sc);
        calImpAmount.contAnnualTaxUpadte();        
    }
    public static testmethod void CalimputedIncomeMethod3(){
        RecordUtilityClass.createRecordsAdminDashboardController();
        Account currentAccount = RecordUtilityClass.getAccount(); // retriving the Accounts EmployeeMileagesForCalculation
        currentAccount.Tax_Calculation_Year__c = '2018';        
        update currentAccount;

        Contact currentAdmin = RecordUtilityClass.getAdminContact(); // Retriving the Admin with limit 1
        Contact selectedDriver = RecordUtilityClass.getDriverContact();
        List<Employee_Reimbursement__c> empReimbursementList = RecordUtilityClass.getEmployee_Reimbursement(currentAccount.id);

        PageReference pageRef = Page.calculateimputedincome;	
		
		pageRef.getParameters().put('Id',String.valueOf(currentAccount.Id)); 
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.standardController(currentAccount);		
		CalculateImputedAmount calImpAmount = new CalculateImputedAmount(sc);
        calImpAmount.contAnnualTaxUpadte();
        
    }
}