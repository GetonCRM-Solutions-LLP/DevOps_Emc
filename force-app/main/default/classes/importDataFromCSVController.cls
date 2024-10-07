public class importDataFromCSVController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public importDataFromCSVController(){
    }
    public PageReference ReadFile(){ 
        ImportAdminDriverInformation batch=new ImportAdminDriverInformation(csvFileBody);
        Database.executeBatch(batch,100);
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'File uploaded successfully and Check Your Mail For Failure Records'));
        //r=true;
        return Null;
    } 
}