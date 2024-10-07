@istest
public class RG_ContactBatchEmailTest
{
    public static testmethod void main()
    {
        
        PageReference pageref=Page.RG_UpdateEmployeeMileageBatch;
        Test.setCurrentPage(pageref);
        //Create Account
        Account acc=new Account(Name='TestAcc'); 
        insert acc;
        //Contact
        Contact cont=new contact(lastName='Abc',accountid=acc.id,External_Email__c='abctest@test.com');
        insert cont;
        //Reimbursement
        Employee_Reimbursement__c Emprimb=new Employee_Reimbursement__c(Name='Test',Contact_Id__c= cont.id, Month__c='8-2016',Fuel_Price__c=200,Fixed_Amount__c=500);
        insert Emprimb;
         Employee_Reimbursement__c Emprimb1=new Employee_Reimbursement__c(Name='Test',Contact_Id__c= cont.id);
        insert Emprimb1;

        //Batch class 
        test.starttest();
        RG_EmpMileageUpdate empMileage=new RG_EmpMileageUpdate();
        empMileage.sendEmailToContact(); 
        test.stoptest();
       
    }
}