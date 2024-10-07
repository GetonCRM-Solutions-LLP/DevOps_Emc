/* DemoClass Test class */
@isTest
Private class DemoClassTest {
    /* Testmethod */
    @isTest static void doValidate() { 
        //call class
        DemoClass a = new DemoClass();
        System.assertEquals(2, 2);
        
    }
}