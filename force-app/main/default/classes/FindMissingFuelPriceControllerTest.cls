@isTest
public class FindMissingFuelPriceControllerTest {
    @isTest static void fuelTest1() {

        Test.startTest();
        FindMissingFuelPriceController findMissCtrl = new FindMissingFuelPriceController();       
        List<SelectOption> options = findMissCtrl.getdateMonthList();

        PageReference pageRef = Page.FindMissingFuelPrice;
        Test.setCurrentPage(pageRef);
        findMissCtrl.emailTo = 'test@gmail.com';
        findMissCtrl.selectedValue = '10-2019';
        findMissCtrl.submit();	
        Test.stopTest();
    }

    @isTest static void fuelTest2() {

        Test.startTest();
        FindMissingFuelPriceController findMissCtrl = new FindMissingFuelPriceController();       
        List<SelectOption> options = findMissCtrl.getdateMonthList();

        PageReference pageRef = Page.FindMissingFuelPrice;
        Test.setCurrentPage(pageRef);        
        findMissCtrl.selectedValue = '10-2019';
        findMissCtrl.submit();	
        Test.stopTest();
    }
}