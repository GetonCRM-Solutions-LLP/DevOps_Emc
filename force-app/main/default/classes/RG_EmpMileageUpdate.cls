public class RG_EmpMileageUpdate {
    
    public RG_EmpMileageUpdate(){
    
    }
    
    //Excute Batch
    public pagereference updatebatchEmployeeMileage(){
        RG_UpdateEmpMileagetoContact upEmpBatch=new RG_UpdateEmpMileagetoContact();
        Database.executeBatch(upEmpBatch,150); 
        return null;
    } 
    
     //Excute Contact Email Batch
    public pagereference sendEmailToContact()
    {
       
        RG_ContactBatchEmail EmailBatch=new RG_ContactBatchEmail();
        Database.executeBatch(EmailBatch,8); 
        return null;
    }
     
    

}