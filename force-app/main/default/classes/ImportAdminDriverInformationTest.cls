@isTest
public class ImportAdminDriverInformationTest {
    public static testmethod void test() {
        Test.startTest();
        String strOriginal ='Company Detail,Company Detail,Role,First Name,Last Name,Email Address,Cell Phone,City,State,Zip Code,Department,Job Title,Managers First Name,Managers Last Name,Managers Email,Vehicle,Insurance Rate,License and Registration,Personal Property Tax,Depreciation,Annual Fixed Cost,Business Use,Fixed Amount,FCA,Total Fixed Amount,Meeting ,Packet ,Date Added,Activation Date,MPG,Maint,Tires ,Maint/Tires,Standard Vehicle,Insurance Plan,Vehicle Age,Vehicle Value,Compliance Mileage,Vehicle URL,Company Logo,mLog API,Company Insurance\nCompany Name,Test QA8,Driver,Andrew,Tatt,test1@gmail.com,770-873-1531,Villa Rica,GA,30180,ENV,Inspector/Consultant,Kevin,Madison,test37@gmail.com,2022 Pick Up Truck,,102,733,4435,8404,75%,500.04,,500.04,Attended,Sent,12-28-2021,01/01/2022,25.5,0.0738,0.0689,0.1427,2022 Pick Up Truck,100/300/50,7,27360,5000,https://f.hubspotusercontent40.net/hubfs/2511299/2022-Chevy-Silverado.jpeg,https://f.hubspotusercontent40.net/hubfs/2511299/HB-Next.png,87ade80a855f4137b7244912ef0541bb,Bodily Injury,"100,000/300,000"\n';
    
        Blob  b = Blob.valueOf(strOriginal);
        importDataFromCSVController i = new importDataFromCSVController ();
        i.csvFileBody = b;
        i.ReadFile();
        Test.stopTest();
   }
}