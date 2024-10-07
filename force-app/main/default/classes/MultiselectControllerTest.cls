@isTest
public class MultiselectControllerTest {
    @isTest static void myUnitTest() {
        MultiselectController obj = new MultiselectController();
        obj.leftOptions = new List<SelectOption>();
        obj.rightOptions = new List<SelectOption>();
        List<SelectOption> selOpts = obj.leftOptions;
        List<SelectOption> selOptsRight = obj.rightOptions;
        obj.leftOptionsHidden = 'value1&value2';
        obj.rightOptionsHidden = 'value1';
    }
     
}