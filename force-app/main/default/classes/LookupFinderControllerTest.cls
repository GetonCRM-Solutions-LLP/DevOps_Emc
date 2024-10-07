@isTest
public class LookupFinderControllerTest {
    @isTest static void myUnitTest() {
        PageReference pageRef = Page.LooupFinder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('searchString','test');
        ApexPages.currentPage().getParameters().put('sObj','Contact');
        ApexPages.currentPage().getParameters().put('field','Name');
        ApexPages.currentPage().getParameters().put('fType','');
        LookupFinderController obj = new LookupFinderController();
        obj.LoadMore();
    }
	@isTest static void myUnitTest2() {
        PageReference pageRef = Page.LooupFinder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('searchString','test');
        ApexPages.currentPage().getParameters().put('sObj','Employee_Mileage__c');
        ApexPages.currentPage().getParameters().put('field','EmployeeReimbursement__r.Contact_Id__r.Account.name');
        ApexPages.currentPage().getParameters().put('fType','Reference');
        LookupFinderController obj1 = new LookupFinderController();
        obj1.LoadMore();
    }
	@isTest static void myUnitTest3() {
        PageReference pageRef = Page.LooupFinder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('searchString','test');
        ApexPages.currentPage().getParameters().put('sObj','Employee_Mileage__c');
        ApexPages.currentPage().getParameters().put('field','EmployeeReimbursement__r.Contact_Id__r.Name');
        ApexPages.currentPage().getParameters().put('fType','Reference');
        LookupFinderController obj1 = new LookupFinderController();
        obj1.LoadMore();
    }
}